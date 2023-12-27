import 'extensions.dart';
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
  void applySelectionsDiff(
      String value,
    Set<String> selectionsToAdd,
    Set<String>? selectionsToRemove,
    SelectionMode selectionMode,
  ) {
    filterState.modify((filters) async {
      final currentSelections = filters
              .getFacetFilters(groupID)
              ?.map((e) => e.value.toString())
              .toSet() ??
          {};
      final selections =
          _selectionsSet(currentSelections, value, selectionMode);
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

  /// Get new set of selection after a selection operation.
  /// We use async operation here since [selections] can take some time to get
  /// current filters (just after initialization).
  static Set<String> _selectionsSet(
    Set<String> current,
    String selection,
    SelectionMode selectionMode,
  ) {
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
}
