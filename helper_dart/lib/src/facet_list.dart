import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'filter.dart';
import 'filter_group.dart';
import 'filter_state.dart';
import 'hits_searcher.dart';
import 'search_response.dart';

/// FacetList (refinement list) is a filtering components that displays facets,
/// and lets the user refine their search results by filtering on specific
/// values.
/// TODO: only supports single select, TBD: add multi selection
@experimental
class FacetList {
  /// Create [FacetList] instance.
  FacetList({
    required this.searcher,
    required this.filterState,
    required this.attribute,
    required this.groupID,
  }) {
    // searcher setup
    searcher.applyState((state) => state.copyWith(
        facets: List.from((state.facets ?? [])..add(attribute))));

    // setup selection stream events listener.
    updateFilterState = _selectionEvents.stream.listen((selections) {
      final filters =
          selections.map((value) => Filter.facet(attribute, value)).toSet();
      filterState
        ..clear([groupID])
        ..add(groupID, filters);
    });
  }

  /// Create [FacetList] instance.
  FacetList.create(
      {required HitsSearcher searcher,
      required FilterState filterState,
      required String attribute,
      FilterOperator operator = FilterOperator.or})
      : this(
            searcher: searcher,
            filterState: filterState,
            attribute: attribute,
            groupID: FilterGroupID(attribute, operator));

  /// Hits Searcher component
  final HitsSearcher searcher;

  /// FilterState component.
  final FilterState filterState;

  /// Facet filter attribute
  final String attribute;

  /// Filter group ID.
  final FilterGroupID groupID;

  /// Selection events stream
  final _selectionEvents = BehaviorSubject<Set<String>>.seeded({});

  late final StreamSubscription updateFilterState;

  Stream<List<SelectableFacet>> get facets => Rx.combineLatest2(
      _items,
      _selections,
      (List<Facet> facets, Set<String> selections) => facets
          .map((facet) =>
              SelectableFacet(facet, selections.contains(facet.value)))
          .toList());

  /// List facets items.
  Stream<List<Facet>> get _items => searcher.responses.map((response) =>
      response.disjunctiveFacets[attribute] ??
      response.facets[attribute] ??
      []);

  /// Set of selected facet values.
  Stream<Set<String>> get _selections => filterState.filters.map((filters) =>
      filters
          .getFacetFilters(groupID)
          ?.map((e) => e.value.toString())
          .toSet() ??
      {});

  /// Select a facet by it's value.
  void select(String selection) {
    final selections =
        _selectionEvents.value.contains(selection) ? <String>{} : {selection};
    _selectionEvents.sink.add(selections);
  }

  /// Dispose the component.
  void dispose() {
    updateFilterState.cancel();
  }
}

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
