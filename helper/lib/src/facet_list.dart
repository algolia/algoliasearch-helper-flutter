import 'dart:async';

import 'package:algolia_insights/algolia_insights.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'disposable.dart';
import 'disposable_mixin.dart';
import 'extensions.dart';
import 'filter_group.dart';
import 'filter_state.dart';
import 'filter_state_group_accessor.dart';
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
    required FilterState filterState,
    required String attribute,
    FilterOperator operator = FilterOperator.or,
    SelectionMode selectionMode = SelectionMode.multiple,
    bool persistent = false,
    FilterEventTracker? eventTracker,
  }) =>
      _FacetList(
        facetsStream: facetsStream,
        state: FiltersGroupAccessor(
          filterState: filterState,
          groupID: FilterGroupID(
            attribute,
            operator,
          ),
          attribute: attribute,
        ),
        selectionMode: selectionMode,
        persistent: persistent,
        eventTracker: eventTracker,
      );

  /// Create [FacetList] instance.
  factory FacetList.create({
    required Stream<List<Facet>> facetsStream,
    required FilterState filterState,
    required String attribute,
    required FilterGroupID groupID,
    SelectionMode selectionMode = SelectionMode.multiple,
    bool persistent = false,
    FilterEventTracker? eventTracker,
  }) =>
      _FacetList(
        facetsStream: facetsStream,
        state: FiltersGroupAccessor(
          filterState: filterState,
          groupID: groupID,
          attribute: attribute,
        ),
        selectionMode: selectionMode,
        persistent: persistent,
        eventTracker: eventTracker,
      );

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

abstract class SelectionsState {
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
      ..add(_responseFacets.connect())
      ..add(
        _selections.connect(),
      );
  }

  final Stream<List<Facet>> facetsStream;

  @override
  final FilterEventTracker? eventTracker;

  /// Whether the facets can have single or multiple selections.
  final SelectionMode selectionMode;

  final SelectionsState state;

  /// Should the selection be kept even if it does not match current results.
  final bool persistent;

  /// Events logger
  final Logger _log = algoliaLogger('FacetList');

  /// Selectable facets lists stream combining [_responseFacets]
  /// and [_selections]
  late final _facets = Rx.combineLatest2(
    _responseFacets,
    _selections,
    (List<Facet> facets, Set<String> selections) {
      final facetsList = _buildSelectableFacets(facets, selections);
      return persistent
          ? _buildPersistentSelectableFacets(facetsList, selections)
          : facetsList;
    },
  ).distinct(const DeepCollectionEquality().equals).publishValue();

  /// List of facets lists values from search responses.
  late final _responseFacets = facetsStream.publishValue();

  /// Set of selected facet values from the filter state.
  late final _selections = state.selections.publishValue();

  /// Streams subscriptions composite.
  final CompositeSubscription _subscriptions = CompositeSubscription();

  @override
  Stream<List<SelectableFacet>> get facets => _facets;

  @override
  List<SelectableFacet>? snapshot() => _facets.valueOrNull;

  /// Builds a list of [SelectableFacet] from [facets] and [selections].
  List<SelectableFacet> _buildSelectableFacets(
    List<Facet> facets,
    Set<String> selections,
  ) =>
      facets
          .map(
            (facet) => SelectableFacet(
              item: facet,
              isSelected: selections.contains(facet.value),
            ),
          )
          .toList();

  /// Builds a list of [SelectableFacet] with persistent selections
  /// from [facetsList] and [selections].
  List<SelectableFacet> _buildPersistentSelectableFacets(
    List<SelectableItem<Facet>> facetsList,
    Set<String> selections,
  ) =>
      selections
          .where(
            (selection) => facetsList.every(
              (selectableFacet) => selectableFacet.item.value != selection,
            ),
          )
          .map(
            (selection) => SelectableFacet(
              item: Facet(selection, 0),
              isSelected: true,
            ),
          )
          .toList()
        ..addAll(facetsList);

  @override
  void toggle(String value) {
    _trackClickIfNeeded(value);
    _selectionsSet(value).then((selections) {
      switch (selectionMode) {
        case SelectionMode.single:
          state.applySelectionsDiff(
            selections,
            null,
          );
        case SelectionMode.multiple:
          _facetsToRemove().then(
            (value) => state.applySelectionsDiff(
              selections,
              value,
            ),
          );
      }
    });
  }

  /// Get the set of facets to remove in case of multiple selection mode.
  /// In case of persistent selection, current selections are kept.
  Future<Set<String>> _facetsToRemove() async {
    final currentFilters =
        (await _responseFacets.first).map((facet) => facet.value).toSet();
    if (!persistent) return currentFilters;

    final currentSelections = (await _selections.first).toSet();
    return {...currentFilters, ...currentSelections};
  }

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

  /// Get new set of selection after a selection operation.
  /// We use async operation here since [_selections] can take some time to get
  /// current filters (just after initialization).
  Future<Set<String>> _selectionsSet(String selection) async {
    final current = await _selections.first;
    _log.finest('current facet selections: $current -> $selection selected');
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
