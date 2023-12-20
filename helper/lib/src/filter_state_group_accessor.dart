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
  late final Stream<Set<String>> selections = filterState.filters.map(
    (filters) =>
        filters
            .getFacetFilters(groupID)
            ?.map((e) => e.value.toString())
            .toSet() ??
        {},
  );

  @override
  void applySelectionsDiff(
    Set<String> selectionsToAdd,
    Set<String>? selectionsToRemove,
  ) {
    filterState.modify((filters) async {
      if (selectionsToRemove == null) {
        filters = filters.clear([groupID]);
      } else {
        final filtersToRemove = selectionsToRemove.map(
          (value) => Filter.facet(attribute, value),
        );
        filters = filters.remove(groupID, filtersToRemove);
      }
      final filtersToAdd = selectionsToAdd
          .map((value) => Filter.facet(attribute, value))
          .toSet();
      return filters.add(groupID, filtersToAdd);
    });
  }
}
