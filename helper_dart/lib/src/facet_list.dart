import 'dart:async';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'disposable.dart';
import 'disposable_mixin.dart';
import 'event_tracker.dart';
import 'extensions.dart';
import 'filter.dart';
import 'filter_group.dart';
import 'filter_state.dart';
import 'filters.dart';
import 'hits_searcher.dart';
import 'logger.dart';
import 'search_response.dart';
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
/// final facetList = FacetList(
///  searcher: searcher,
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
    required HitsSearcher searcher,
    required FilterState filterState,
    required String attribute,
    FilterOperator operator = FilterOperator.or,
    SelectionMode selectionMode = SelectionMode.multiple,
    bool persistent = false,
    String? clickEventName,
  }) =>
      _FacetList(
        searcher: searcher,
        filterState: filterState,
        attribute: attribute,
        groupID: FilterGroupID(attribute, operator),
        selectionMode: selectionMode,
        persistent: persistent,
        eventTracker: searcher.eventTracker,
        clickEventName: clickEventName ?? 'click$attribute',
      );

  /// Create [FacetList] instance.
  factory FacetList.create({
    required HitsSearcher searcher,
    required FilterState filterState,
    required String attribute,
    required FilterGroupID groupID,
    SelectionMode selectionMode = SelectionMode.multiple,
    bool persistent = false,
    String? clickEventName,
  }) =>
      _FacetList(
        searcher: searcher,
        filterState: filterState,
        attribute: attribute,
        groupID: groupID,
        selectionMode: selectionMode,
        persistent: persistent,
        eventTracker: searcher.eventTracker,
        clickEventName: clickEventName ?? 'click$attribute',
      );

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

/// Default implementation of [FacetList].
class _FacetList with DisposableMixin implements FacetList {
  /// Create [_FacetList] instance.
  _FacetList({
    required this.searcher,
    required this.filterState,
    required this.attribute,
    required this.groupID,
    required this.selectionMode,
    required this.persistent,
    required this.eventTracker,
    required this.clickEventName,
  }) {
    if (searcher.isDisposed) {
      _log.warning('creating an instance with disposed searcher');
    }

    if (filterState.isDisposed) {
      _log.warning('creating an instance with disposed filter state');
    }

    // Setup search state by adding `attribute` to the search state
    searcher.applyState(
      (state) => state.copyWith(
        facets: List.from((state.facets ?? [])..add(attribute)),
        disjunctiveFacets: groupID.operator == FilterOperator.or
            ? {...?state.disjunctiveFacets, attribute}
            : state.disjunctiveFacets,
      ),
    );

    _subscriptions
      ..add(_facets.connect())
      ..add(_responseFacets.connect())
      ..add(_selections.connect());
  }

  /// Hits Searcher component
  final HitsSearcher searcher;

  /// FilterState component.
  final FilterState filterState;

  final EventTracker eventTracker;

  /// Facet filter attribute
  final String attribute;

  /// Name of the click filter event
  final String clickEventName;

  /// Filter group ID.
  final FilterGroupID groupID;

  /// Whether the facets can have single or multiple selections.
  final SelectionMode selectionMode;

  /// Should the selection be kept even if it does not match current results.
  final bool persistent;

  /// Events logger
  final Logger _log = algoliaLogger('FacetList');

  /// Selectable facets lists stream.
  late final _facets = _selectableFacetsStream()
      .distinct(const DeepCollectionEquality().equals)
      .publishValue();

  /// List of facets lists values from search responses.
  late final _responseFacets = _searcherFacetsStream().publishValue();

  /// Set of selected facet values from the filter state.
  late final _selections = _filtersSelectionsStream().publishValue();

  /// Streams subscriptions composite.
  final CompositeSubscription _subscriptions = CompositeSubscription();

  @override
  Stream<List<SelectableFacet>> get facets => _facets;

  @override
  List<SelectableFacet>? snapshot() => _facets.valueOrNull;

  /// Create stream of [SelectableFacet] lists from
  /// [_responseFacets] and [_selections].
  Stream<List<SelectableFacet>> _selectableFacetsStream() => Rx.combineLatest2(
        _responseFacets,
        _selections,
        (List<Facet> facets, Set<String> selections) {
          final facetsList = _buildSelectableFacets(facets, selections);
          return persistent
              ? _buildPersistentSelectableFacets(facetsList, selections)
              : facetsList;
        },
      );

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

  /// Build facets lists stream from [searcher].
  Stream<List<Facet>> _searcherFacetsStream() => searcher.responses.map(
        (response) =>
            response.disjunctiveFacets[attribute] ??
            response.facets[attribute] ??
            [],
      );

  /// Build selections stream from [filterState] filters updates.
  Stream<Set<String>> _filtersSelectionsStream() => filterState.filters.map(
        (filters) =>
            filters
                .getFacetFilters(groupID)
                ?.map((e) => e.value.toString())
                .toSet() ??
            {},
      );

  @override
  void toggle(String value) {
    _trackClickIfNeeded(value);
    _selectionsSet(value).then((selections) {
      filterState.modify((filters) async {
        final filtersSet =
            selections.map((value) => Filter.facet(attribute, value)).toSet();
        filters = await _clearFilters(filters);
        return filters.add(groupID, filtersSet);
      });
    });
  }

  void _trackClickIfNeeded(String selection) {
    _selections.first.then((selections) {
      if (!selections.contains(selection)) {
        eventTracker.trackClick(clickEventName, attribute, selection);
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

  /// Clear filters from [StatelessFilters] depending
  Future<StatelessFilters> _clearFilters(StatelessFilters filters) async {
    switch (selectionMode) {
      case SelectionMode.single:
        return filters.clear([groupID]);
      case SelectionMode.multiple:
        final filtersToRemove = _facetsToRemove();
        return filters.remove(groupID, await filtersToRemove);
    }
  }

  /// Get the set of facets to remove in case of multiple selection mode.
  /// In case of persistent selection, current selections are kept.
  Future<Set<FilterFacet>> _facetsToRemove() async {
    final currentFilters = (await _responseFacets.first)
        .map((facet) => Filter.facet(attribute, facet.value))
        .toSet();
    if (!persistent) return currentFilters;

    final currentSelections = (await _selections.first)
        .map((selection) => Filter.facet(attribute, selection))
        .toSet();
    return {...currentFilters, ...currentSelections};
  }

  @override
  void doDispose() {
    _log.finest('FacetList disposed');
    _subscriptions.cancel();
  }
}
