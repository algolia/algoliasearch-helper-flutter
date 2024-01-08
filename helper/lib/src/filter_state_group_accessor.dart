import 'facet_list.dart';
import 'filter.dart';
import 'filter_group.dart';
import 'filter_state.dart';

class FiltersGroupAccessor extends SelectionState {
  /// FilterState component.
  final FilterState filterState;

  /// Filter group ID.
  final FilterGroupID groupID;

  /// Filter attribute
  final String attribute;

  FiltersGroupAccessor({
    required this.filterState,
    required this.groupID,
    required this.attribute,
  });

  @override
  late final Stream<Set<String>> selectionsStream = filterState.filters.map(
    (filters) =>
        filters
            .getFacetFilters(groupID)
            ?.map((e) => e.value.toString())
            .toSet() ??
        {},
  );

  @override
  Set<String> get selections =>
      filterState
          .snapshot()
          .getFacetFilters(groupID)
          ?.map((e) => e.value.toString())
          .toSet() ??
      {};

  @override
  void setSelections(
    Set<String> selections,
  ) {
    filterState.modify((filters) async {
      filters = filters.clear([groupID]);
      final filtersToAdd =
          selections.map((value) => Filter.facet(attribute, value)).toSet();
      return filters.add(groupID, filtersToAdd);
    });
  }
}
