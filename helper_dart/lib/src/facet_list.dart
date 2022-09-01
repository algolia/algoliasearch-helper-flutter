import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'extensions.dart';
import 'filter.dart';
import 'filter_group.dart';
import 'filter_state.dart';
import 'hits_searcher.dart';
import 'immutable_filters.dart';
import 'logger.dart';
import 'search_response.dart';
import 'selectable_item.dart';

/// FacetList (refinement list) is a filtering components that displays facets,
/// and lets the user refine their search results by filtering on specific
/// values.
@experimental
abstract class FacetList {
  /// Create [FacetList] instance.
  factory FacetList({
    required HitsSearcher searcher,
    required FilterState filterState,
    required String attribute,
    FilterOperator operator = FilterOperator.or,
    SelectionMode selectionMode = SelectionMode.multiple,
    bool persistent = false,
  }) =>
      _FacetList(
        searcher: searcher,
        filterState: filterState,
        attribute: attribute,
        groupID: FilterGroupID(attribute, operator),
        selectionMode: selectionMode,
        persistent: persistent,
      );

  /// Create [FacetList] instance.
  factory FacetList.create({
    required HitsSearcher searcher,
    required FilterState filterState,
    required String attribute,
    required FilterGroupID groupID,
    SelectionMode selectionMode = SelectionMode.multiple,
    bool persistent = false,
  }) =>
      _FacetList(
        searcher: searcher,
        filterState: filterState,
        attribute: attribute,
        groupID: groupID,
        selectionMode: selectionMode,
        persistent: persistent,
      );

  /// Stream of [Facet] list with selection status.
  Stream<List<SelectableFacet>> get facets;

  /// Snapshot of the latest [facets] value.
  List<SelectableFacet>? snapshot();

  /// Select a facet by it's value.
  void select(String selection);

  /// Dispose the component.
  void dispose();
}

/// Elements selection mode.
enum SelectionMode { single, multiple }

/// [Facet] with selection status.
typedef SelectableFacet = SelectableItem<Facet>;

/// Implementation of [FacetList].
class _FacetList implements FacetList {
  /// Create [_FacetList] instance.
  _FacetList({
    required this.searcher,
    required this.filterState,
    required this.attribute,
    required this.groupID,
    required this.selectionMode,
    required this.persistent,
  }) : _log = algoliaLogger('FacetList') {
    // Setup search state by adding `attribute` to the search state
    searcher.applyState(
      (state) => state.copyWith(
        facets: List.from(
          (state.facets ?? [])..add(attribute),
        ),
      ),
    );

    // Setup subject streams. Not using addStream since we can't stop subjects.
    _subscriptions
      ..add(_responseFacets.subscribe(_searcherFacetsStream()))
      ..add(_selections.subscribe(_filtersSelectionsStream()))
      ..add(_facets.subscribe(_selectableFacetsStream()));
  }

  /// Hits Searcher component
  final HitsSearcher searcher;

  /// FilterState component.
  final FilterState filterState;

  /// Facet filter attribute
  final String attribute;

  /// Filter group ID.
  final FilterGroupID groupID;

  /// Whether the facets can have single or multiple selections.
  final SelectionMode selectionMode;

  /// Should the selection be kept even if it does not match current results.
  final bool persistent;

  /// Events logger
  final Logger _log;

  /// Selectable facets lists stream.
  final BehaviorSubject<List<SelectableFacet>> _facets = BehaviorSubject();

  /// List of facets lists values from search responses.
  final BehaviorSubject<List<Facet>> _responseFacets = BehaviorSubject();

  /// Set of selected facet values from the filter state.
  final BehaviorSubject<Set<String>> _selections = BehaviorSubject();

  /// Streams subscriptions composite.
  final CompositeSubscription _subscriptions = CompositeSubscription();

  @override
  Stream<List<SelectableFacet>> get facets => _facets.stream.distinct();

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
  void select(String selection) {
    final selections = _selectionsSet(selection);
    filterState.modify((filters) {
      final filtersSet =
          selections.map((value) => Filter.facet(attribute, value)).toSet();
      filters = _clearFilters(filters);
      return filters.add(groupID, filtersSet);
    });
  }

  /// Get new set of selection after a selection operation.
  Set<String> _selectionsSet(String selection) {
    final current = _selections.valueOrNull ?? {};
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

  /// Clear filters from [ImmutableFilters] depending
  ImmutableFilters _clearFilters(ImmutableFilters filters) {
    switch (selectionMode) {
      case SelectionMode.single:
        return filters.clear([groupID]);
      case SelectionMode.multiple:
        final filtersToRemove = _facetsToRemove();
        return filters.remove(groupID, filtersToRemove);
    }
  }

  /// Get the set of facets to remove in case of multiple selection mode.
  /// In case of persistent selection, current selections are kept.
  Set<FilterFacet> _facetsToRemove() {
    final currentFilters = _responseFacets.valueOrNull
            ?.map((facet) => Filter.facet(attribute, facet.value))
            .toSet() ??
        {};
    if (!persistent) return currentFilters;

    final currentSelections = _selections.valueOrNull
            ?.map((selection) => Filter.facet(attribute, selection))
            .toSet() ??
        {};
    return {...currentFilters, ...currentSelections};
  }

  @override
  void dispose() {
    _log.finest('component dispose');
    // Cancel all subscriptions
    _subscriptions.cancel();
    // Close all subjects
    _responseFacets.close();
    _selections.close();
    _facets.close();
  }
}
