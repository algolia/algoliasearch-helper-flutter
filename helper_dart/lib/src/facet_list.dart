import 'dart:async';

import 'package:algolia_helper/src/immutable_filters.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'extensions.dart';
import 'filter.dart';
import 'filter_group.dart';
import 'filter_state.dart';
import 'hits_searcher.dart';
import 'logger.dart';
import 'search_response.dart';

/// FacetList (refinement list) is a filtering components that displays facets,
/// and lets the user refine their search results by filtering on specific
/// values.
@experimental
class FacetList {
  /// Create [FacetList] instance.
  FacetList({
    required this.searcher,
    required this.filterState,
    required this.attribute,
    required this.groupID,
    this.selectionMode = SelectionMode.multiple,
    this.persistent = true,
  }) : _log = algoliaLogger {
    // Searcher setup
    searcher.applyState(
      (state) => state.copyWith(
        facets: List.from(
          (state.facets ?? [])..add(attribute),
        ),
      ),
    );

    // Setup selection stream events listener.
    _selectionsSubscription = _selectionEvents.stream.listen((selections) {
      _log.finest('[FacetList] Selections: $selections');
      filterState.modify((filters) {

        final filtersSet =
            selections.map((value) => Filter.facet(attribute, value)).toSet();
        _log.finest('[FacetList] Before clear: $filters');
        filters = _clearFilters(filters);
        _log.finest('[FacetList] After clear: $filters');
        _log.finest('[FacetList] FilterState to add: $groupID -> $filtersSet');
        filters = filters.add(groupID, filtersSet);
        _log.finest('[FacetList] FilterState after add: $filters');
        return filters;
      });
    });
  }

  /// Clear filters from [ImmutableFilters] depending
  ImmutableFilters _clearFilters(ImmutableFilters filters) {
    switch (selectionMode) {
      case SelectionMode.single:
        return filters.clear([groupID]);
      case SelectionMode.multiple:
        final filtersToRemove = _facetsToRemove();
        _log.finest('[FacetList] filters to remove: $filtersToRemove');
        return filters.remove(groupID, filtersToRemove);
    }
  }

  /// Create [FacetList] instance.
  FacetList.create({
    required HitsSearcher searcher,
    required FilterState filterState,
    required String attribute,
    FilterOperator operator = FilterOperator.or,
    SelectionMode selectionMode = SelectionMode.multiple,
    bool persistent = true,
  }) : this(
          searcher: searcher,
          filterState: filterState,
          attribute: attribute,
          groupID: FilterGroupID(attribute, operator),
          selectionMode: selectionMode,
          persistent: persistent,
        );

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

  /// Selection events stream
  final _selectionEvents = BehaviorSubject<Set<String>>.seeded({});

  /// Events logger
  final Logger _log;

  /// Selection events subscription
  late final StreamSubscription _selectionsSubscription;

  /// Get the set of facets to remove in case of multiple selection mode.
  /// In case of persistent selection, current selections are kept.
  Set<FilterFacet> _facetsToRemove() {
    final currentFilters = _items.valueOrNull
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

  /// Stream of [Facet] list with selection status.
  Stream<List<SelectableFacet>> get facets => Rx.combineLatest2(
        _items,
        _selections,
        (List<Facet> facets, Set<String> selections) => facets
            .map(
              (facet) => SelectableFacet(
                item: facet,
                isSelected: selections.contains(facet.value),
              ),
            )
            .toList(),
      );

  /// List facets items.
  late final ValueStream<List<Facet>> _items = searcher.responses
      .map(
        (response) =>
            response.disjunctiveFacets[attribute] ??
            response.facets[attribute] ??
            [],
      )
      .shareValue();

  /// Set of selected facet values.
  late final ValueStream<Set<String>> _selections = filterState.filters.map(
    (filters) {
      _log.finest('[FacetList] FilterState filters: $filters');
      return filters
              .getFacetFilters(groupID)
              ?.map((e) => e.value.toString())
              .toSet() ??
          {};
    },
  ).shareValue();

  /// Select a facet by it's value.
  void select(String selection) {
    final selections = _selectionsSet(selection);
    _selectionEvents.sink.add(selections);
  }

  /// Get new set of selection after a selection operation.
  Set<String> _selectionsSet(String selection) {
    final current = _selectionEvents.value;
    _log.finest(
        '[FaceList] current selections: $current -> $selection selected');
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

  /// Dispose the component.
  void dispose() {
    _selectionsSubscription.cancel();
  }
}

/// Elements selection mode.
enum SelectionMode { single, multiple }

/// Represents a value with selection status.
class SelectableItem<T> {
  /// Creates [SelectableItem] instance.
  const SelectableItem({required this.item, required this.isSelected});

  /// Item value.
  final T item;

  /// Selection status.
  final bool isSelected;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectableItem &&
          runtimeType == other.runtimeType &&
          item == other.item &&
          isSelected == other.isSelected;

  @override
  int get hashCode => item.hashCode ^ isSelected.hashCode;

  @override
  String toString() => 'SelectableItem{item: $item, isSelected: $isSelected}';
}

/// [Facet] with selection status.
typedef SelectableFacet = SelectableItem<Facet>;
