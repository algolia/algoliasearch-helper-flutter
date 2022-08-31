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
    bool persistent = true,
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
    bool persistent = true,
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
  List<SelectableFacet> snapshot();

  /// Select a facet by it's value.
  void select(String selection);

  /// Dispose the component.
  void dispose();
}

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
    // Setup search state
    searcher.applyState(
      (state) => state.copyWith(
        facets: List.from(
          (state.facets ?? [])..add(attribute),
        ),
      ),
    );

    // Setup selection events
    _selectionEvents.stream.listen((selections) {
      filterState.modify((filters) {
        final filtersSet =
            selections.map((value) => Filter.facet(attribute, value)).toSet();
        filters = _clearFilters(filters);
        return filters.add(groupID, filtersSet);
      });
    });
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

  /// Selection events stream
  final _selectionEvents = BehaviorSubject<Set<String>>.seeded({});

  @override
  Stream<List<SelectableFacet>> get facets => _facets.stream;

  @override
  List<SelectableFacet> snapshot() => _facets.value;

  /// Facets list subject stream, derived from [_items] and [_selections].
  late final BehaviorSubject<List<SelectableFacet>> _facets = BehaviorSubject()
    ..addStream(
      Rx.combineLatest2(
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
      ),
    );

  /// List facets items.
  late final BehaviorSubject<List<Facet>> _items = BehaviorSubject()
    ..addStream(
      searcher.responses.map(
        (response) =>
            response.disjunctiveFacets[attribute] ??
            response.facets[attribute] ??
            [],
      ),
    );

  /// Set of selected facet values.
  late final BehaviorSubject<Set<String>> _selections = BehaviorSubject()
    ..addStream(
      filterState.filters.map(
        (filters) =>
            filters
                .getFacetFilters(groupID)
                ?.map((e) => e.value.toString())
                .toSet() ??
            {},
      ),
    );

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

  @override
  void select(String selection) {
    final selections = _selectionsSet(selection);
    _selectionEvents.sink.add(selections);
  }

  /// Get new set of selection after a selection operation.
  Set<String> _selectionsSet(String selection) {
    final current = _selectionEvents.value;
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
  void dispose() {
    _selectionEvents.close();
    _facets.close();
    _selections.close();
    _items.close();
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
