import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'extensions.dart';
import 'filter.dart';
import 'filter_group.dart';
import 'filter_state.dart';
import 'hits_searcher.dart';
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
  }) {
    // Searcher setup
    searcher.applyState(
      (state) => state.copyWith(
        facets: List.from((state.facets ?? [])..add(attribute)),
      ),
    );

    // Setup selection stream events listener.
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

  /// Selection events subscription
  late final StreamSubscription _selectionsSubscription =
      _selectionEvents.stream.listen((selections) {
    final filters =
        selections.map((value) => Filter.facet(attribute, value)).toSet();

    switch (selectionMode) {
      case SelectionMode.single:
        filterState.clear([groupID]);
        break;
      case SelectionMode.multiple:
        filterState.remove(groupID, _facetsToRemove());
        break;
    }

    filterState
      ..clear([groupID])
      ..add(groupID, filters);
  });

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
              (facet) =>
                  SelectableFacet(facet, selections.contains(facet.value)),
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
  late final ValueStream<Set<String>> _selections = filterState.filters
      .map(
        (filters) =>
            filters
                .getFacetFilters(groupID)
                ?.map((e) => e.value.toString())
                .toSet() ??
            {},
      )
      .shareValue();

  /// Select a facet by it's value.
  void select(String selection) {
    _selectionsSet(selection);
    final selections = _selectionsSet(selection);
    _selectionEvents.sink.add(selections);
  }

  /// Get new set of selection after a selection operation.
  Set<String> _selectionsSet(String selection) {
    final current = _selectionEvents.value;
    switch (selectionMode) {
      case SelectionMode.single:
        return current.contains(selection)
            ? const {}
            : {selection}.unmodifiable();
      case SelectionMode.multiple:
        final set = current.modifiable();
        final updated = current.contains(selection)
            ? (set..add(selection))
            : (set..remove(selection));
        return updated.unmodifiable();
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
  const SelectableItem(this.item, this.isSelected);

  final T item;
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
