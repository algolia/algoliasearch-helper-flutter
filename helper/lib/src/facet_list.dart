import 'dart:async';

import 'package:algolia_insights/algolia_insights.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'disposable.dart';
import 'disposable_mixin.dart';
import 'extensions.dart';
import 'filter_state.dart';
import 'logger.dart';
import 'model/facet.dart';
import 'searcher/hits_searcher.dart';
import 'selectable_item.dart';

/// FacetList (refinement list) is a filtering components that displays facets,
/// and lets the user refine their search results by filtering on specific
/// values.
///
/// ## Create Facet List
///
/// Create [FacetList] with given [HitsSearcher] and [FilterState] components :
///
/// ```dart
/// // Create a HitsSearcher
/// final searcher = HitsSearcher(
///  applicationID: 'MY_APPLICATION_ID',
///  apiKey: 'MY_API_KEY',
///  indexName: 'MY_INDEX_NAME',
/// );
///
/// // Create a FilterState
/// final filterState = FilterState();
///
/// // Create a FacetList
/// final facetList = searcher.buildFacetList(
///  filterState: filterState,
///  attribute: 'MY_ATTRIBUTE',
/// );
/// ```
///
/// ## Get selectable facet lists
///
/// Get selectable facets changes by listening to [facets] submissions:
///
/// ```dart
/// facetList.facets.listen((facets) {
///   for (var facet in facets) {
///     print("${facet.item} ${facet.isSelected ? 'x' : '-'}");
///   }
/// });
/// ```
///
/// ### Toggle facet
///
/// Call [toggle] to selected/deselect a facet value:
///
/// ```dart
/// facetList.toggle('MY_FACET_VALUE');
/// ```
///
/// ## Dispose
///
/// Call [dispose] to release underlying resources:
///
/// ```dart
/// facetList.dispose();
/// ```
@experimental
@sealed
abstract class FacetList implements Disposable {
  /// Create [FacetList] instance.
  factory FacetList({
    required Stream<List<Facet>> facetsStream,
    required SelectionState state,
    SelectionMode selectionMode = SelectionMode.multiple,
    bool persistent = false,
    FilterEventTracker? eventTracker,
  }) =>
      _FacetList(
        facetsStream: facetsStream,
        state: state,
        selectionMode: selectionMode,
        persistent: persistent,
        eventTracker: eventTracker,
      );

  /// Create [FacetList] instance.
  factory FacetList.create({
    required Stream<List<Facet>> facetsStream,
    required SelectionState state,
    SelectionMode selectionMode = SelectionMode.multiple,
    bool persistent = false,
    FilterEventTracker? eventTracker,
  }) =>
      _FacetList(
        facetsStream: facetsStream,
        state: state,
        selectionMode: selectionMode,
        persistent: persistent,
        eventTracker: eventTracker,
      );

  /// Selection state
  SelectionState get state;

  /// Insights events tracking component
  FilterEventTracker? get eventTracker;

  /// Stream of [Facet] list with selection status.
  Stream<List<SelectableFacet>> get facets;

  /// Snapshot of the latest [facets] value.
  List<SelectableFacet>? snapshot();

  /// Select/deselect the provided facet value depending on the current
  /// selection state.
  void toggle(String value);
}

/// Elements selection mode.
enum SelectionMode { single, multiple }

/// [Facet] with selection status.
typedef SelectableFacet = SelectableItem<Facet>;

abstract class SelectionState {
  /// Gets a stream of the current selection set.
  ///
  /// This stream emits the latest set of selected items as `Set<String>`.
  Stream<Set<String>> get selections;

  /// Applies a differential update to the current selections.
  ///
  /// This method applies a set of selections to add and optionally a set
  /// of selections to remove. If the removal set is `null`, it indicates
  /// that all existing selections should be cleared.
  ///
  /// [selectionsToAdd]: The set of selections to add.
  /// [selectionsToRemove]: An optional set of selections to remove.
  /// `null` indicates that all existing selections should be cleared.
  void applySelectionsDiff(
    Set<String> selectionsToAdd,
    Set<String>? selectionsToRemove,
  );
}

/// Default implementation of [FacetList].
class _FacetList with DisposableMixin implements FacetList {
  /// Create [_FacetList] instance.
  _FacetList({
    required this.facetsStream,
    required this.state,
    required this.selectionMode,
    required this.persistent,
    required this.eventTracker,
  }) {
    _subscriptions
      ..add(_facets.connect())
      ..add(_inputFacets.connect())
      ..add(
        _selections.connect(),
      );
  }

  final Stream<List<Facet>> facetsStream;

  @override
  final FilterEventTracker? eventTracker;

  /// Whether the facets can have single or multiple selections.
  final SelectionMode selectionMode;

  @override
  final SelectionState state;

  /// Should the selection be kept even if it does not match current results.
  final bool persistent;

  /// Events logger
  final Logger _log = algoliaLogger('FacetList');

  /// Selectable facets lists stream combining [_inputFacets]
  /// and [_selections]
  late final _facets = Rx.combineLatest2(
    _inputFacets,
    _selections,
    (List<Facet> facets, Set<String> selections) => _selectableFacets(
      facets,
      selections,
      persistent,
    ),
  ).distinct(const DeepCollectionEquality().equals).publishValue();

  /// Stream of input facets lists values.
  late final _inputFacets = facetsStream.publishValue();

  /// Set of selected facet values from the filter state.
  late final _selections = state.selections.publishValue();

  /// Streams subscriptions composite.
  final CompositeSubscription _subscriptions = CompositeSubscription();

  @override
  Stream<List<SelectableFacet>> get facets => _facets;

  @override
  List<SelectableFacet>? snapshot() => _facets.valueOrNull;

  void _trackClickIfNeeded(String selection) {
    _selections.first.then((selections) {
      if (!selections.contains(selection)) {
        eventTracker?.clickedFilters(
          eventName: 'Filter Applied',
          values: [selection],
        );
      }
    });
  }

  @override
  void toggle(String value) {
    _trackClickIfNeeded(value);
    _log.finest('current selections: $_selections.first -> $value selected');
    _selectionsSet(_selections, value, selectionMode).then((selections) {
      switch (selectionMode) {
        case SelectionMode.single:
          state.applySelectionsDiff(
            selections,
            null,
          );
        case SelectionMode.multiple:
          final input = _inputFacets.first
              .then((value) => value.map((facet) => facet.value).toSet());
          final current = _selections.first.then((value) => value.toSet());
          _facetsToRemove(
            input,
            current,
            persistent,
          ).then(
            (toRemove) => state.applySelectionsDiff(
              selections,
              toRemove,
            ),
          );
      }
    });
  }

  /// Creates a list of `SelectableItem<Facet>` from a given list of `Facet`
  /// and a set of selections.
  ///
  /// This function maps each `Facet` in the provided list to a
  /// `SelectableFacet` by checking if the facet's value is contained within the
  /// given set of selections. Each `SelectableFacet` will have its `isSelected`
  /// property set accordingly. For persistent selections, facets that are
  /// currently selected but not present in the provided facet list will also be
  /// included.
  ///
  /// [facets]: The list of `Facet` from which the `SelectableFacet` list will
  /// be created.
  /// [selections]: The set of currently selected facet values. Each value in
  /// this set corresponds to a `Facet`'s value that should be marked as
  /// selected.
  /// [persistent]: A boolean indicating whether selections should persist even
  /// when they are not present in the current facet list. If true, facets that
  /// are selected but not present in the provided list will be added to the
  /// result with a count of 0.
  ///
  /// Returns a list of `SelectableFacet`, which includes all facets from the
  /// provided list marked as selected or not based on the selections set, and,
  /// if persistent is true, any additional facets that are selected but not
  /// present in the initial list.
  static List<SelectableItem<Facet>> _selectableFacets(
    List<Facet> facets,
    Set<String> selections,
    bool persistent,
  ) {
    final facetList = facets
        .map(
          (facet) => SelectableFacet(
            item: facet,
            isSelected: selections.contains(facet.value),
          ),
        )
        .toList();

    if (!persistent) {
      return facetList;
    }

    final presentValues = facets.map((facet) => facet.value).toSet();
    final persistentFacetList = selections
        .whereNot(presentValues.contains)
        .map(
          (selection) => SelectableFacet(
            item: Facet(selection, 0),
            isSelected: true,
          ),
        )
        .toList();

    return [...persistentFacetList, ...facetList];
  }

  /// Get the set of facets to remove in case of multiple selection mode.
  /// In case of persistent selection, current selections are kept.
  static Future<Set<String>> _facetsToRemove(
    Future<Set<String>> input,
    Future<Set<String>> current,
    bool persistent,
  ) async {
    final inputValues = await input;
    if (!persistent) return inputValues;

    final currentValues = await current;
    return {...inputValues, ...currentValues};
  }

  /// Get new set of selection after a selection operation.
  /// We use async operation here since [selections] can take some time to get
  /// current filters (just after initialization).
  static Future<Set<String>> _selectionsSet(
    Stream<Set<String>> selections,
    String selection,
    SelectionMode selectionMode,
  ) async {
    final current = await selections.first;
    switch (selectionMode) {
      case SelectionMode.single:
        return current.contains(selection) ? {} : {selection};
      case SelectionMode.multiple:
        final set = current.modifiable();
        return current.contains(selection)
            ? (set..remove(selection))
            : (set..add(selection));
    }
  }

  @override
  void doDispose() {
    _log.finest('FacetList disposed');
    _subscriptions.cancel();
  }
}
