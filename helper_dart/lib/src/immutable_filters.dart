import 'package:meta/meta.dart';

import 'extensions.dart';
import 'filter.dart';
import 'filter_group.dart';
import 'filters.dart';

/// Immutable filters implementation.
/// **All operations create a new object with requested changes.**
class ImmutableFilters extends Filters {
  /// Creates [ImmutableFilters] instance.
  @internal
  const ImmutableFilters({
    Map<FilterGroupID, Set<FilterFacet>> facetGroups = const {},
    Map<FilterGroupID, Set<FilterTag>> tagGroups = const {},
    Map<FilterGroupID, Set<FilterNumeric>> numericGroups = const {},
    Map<String, HierarchicalFilter> hierarchicalGroups = const {},
  }) : super(facetGroups, tagGroups, numericGroups, hierarchicalGroups);

  /// Adds [filters] to the provided [groupID].
  ImmutableFilters add(FilterGroupID groupID, Iterable<Filter> filters) {
    var current = this;
    for (final filter in filters) {
      switch (filter.runtimeType) {
        case FilterFacet:
          current = current.copyWith(
            facetGroups: facetGroups.add(groupID, filter as FilterFacet),
          );
          break;
        case FilterTag:
          current = current.copyWith(
            tagGroups: tagGroups.add(groupID, filter as FilterTag),
          );
          break;
        case FilterNumeric:
          current = current.copyWith(
            numericGroups: numericGroups.add(groupID, filter as FilterNumeric),
          );
          break;
      }
    }
    return current;
  }

  /// Get filters with the provided [map].
  ImmutableFilters set(Map<FilterGroupID, Set<Filter>> map) {
    var filters = const ImmutableFilters();
    for (final entry in map.entries) {
      filters = filters.add(entry.key, entry.value);
    }
    return filters;
  }

  /// Toggles [filter] in given [groupID].
  ImmutableFilters toggle(FilterGroupID groupID, Filter filter) =>
      contains(groupID, filter)
          ? remove(groupID, [filter])
          : add(groupID, [filter]);

  /// Removes [filters] from [groupID].
  ImmutableFilters remove(FilterGroupID groupID, Iterable<Filter> filters) {
    for (final filter in filters) {
      switch (filter.runtimeType) {
        case FilterFacet:
          return copyWith(
            facetGroups: facetGroups.delete(groupID, filter as FilterFacet),
          );
        case FilterTag:
          return copyWith(
            tagGroups: tagGroups.delete(groupID, filter as FilterTag),
          );
        case FilterNumeric:
          return copyWith(
            numericGroups:
                numericGroups.delete(groupID, filter as FilterNumeric),
          );
      }
    }
    return this;
  }

  /// Adds [hierarchicalFilter] to given [attribute].
  ImmutableFilters addHierarchical(
    String attribute,
    HierarchicalFilter hierarchicalFilter,
  ) {
    if (hierarchicalGroups.containsKey(attribute)) return this;
    final groups = Map<String, HierarchicalFilter>.from(hierarchicalGroups)
      ..[attribute] = hierarchicalFilter;
    return copyWith(hierarchicalGroups: Map.unmodifiable(groups));
  }

  /// Removes [HierarchicalFilter] of given [attribute].
  ImmutableFilters removeHierarchical(String attribute) {
    if (!hierarchicalGroups.containsKey(attribute)) return this;
    final groups = Map<String, HierarchicalFilter>.from(hierarchicalGroups)
      ..remove(attribute);
    return copyWith(hierarchicalGroups: Map.unmodifiable(groups));
  }

  /// Clears [groupIDs].
  /// If none provided, all filters will be cleared.
  ImmutableFilters clear([Iterable<FilterGroupID>? groupIDs]) {
    if (groupIDs == null || groupIDs.isEmpty) return const ImmutableFilters();
    return ImmutableFilters(
      facetGroups: facetGroups.deleteGroups(groupIDs),
      numericGroups: numericGroups.deleteGroups(groupIDs),
      tagGroups: tagGroups.deleteGroups(groupIDs),
    );
  }

  /// Clears all except [groupIDs].
  ImmutableFilters clearExcept(Iterable<FilterGroupID> groupIDs) {
    if (groupIDs.isEmpty) return const ImmutableFilters();
    return ImmutableFilters(
      facetGroups: facetGroups.deleteGroupsExcept(groupIDs),
      numericGroups: numericGroups.deleteGroupsExcept(groupIDs),
      tagGroups: tagGroups.deleteGroupsExcept(groupIDs),
    );
  }

  @override
  ImmutableFilters copyWith({
    Map<FilterGroupID, Set<FilterFacet>>? facetGroups,
    Map<FilterGroupID, Set<FilterTag>>? tagGroups,
    Map<FilterGroupID, Set<FilterNumeric>>? numericGroups,
    Map<String, HierarchicalFilter>? hierarchicalGroups,
  }) =>
      ImmutableFilters(
        facetGroups: facetGroups ?? this.facetGroups,
        tagGroups: tagGroups ?? this.tagGroups,
        numericGroups: numericGroups ?? this.numericGroups,
        hierarchicalGroups: hierarchicalGroups ?? this.hierarchicalGroups,
      );
}

/// Extensions over [FilterGroupMap].
extension FilterGroupMapExt<T extends Filter> on FilterGroupMap<T> {
  /// Returns new filter group instance with updated values.
  FilterGroupMap<T> add(FilterGroupID groupID, T filter) {
    final current = Set<T>.from(this[groupID] ?? const {});
    if (current.contains(filter)) return this; // already exists, fast way out
    final filters = Set.unmodifiable(current..add(filter));
    final updated = Map.from(this)..addEntries([MapEntry(groupID, filters)]);
    return Map<FilterGroupID, Set<T>>.unmodifiable(updated);
  }

  /// Returns new filter group instance with updated values.
  FilterGroupMap<T> delete(FilterGroupID groupID, T filter) {
    final current = Set<T>.from(this[groupID] ?? const {});
    if (!current.contains(filter)) return this; // do not exists, fast way out
    final filters = Set<T>.unmodifiable(current..remove(filter));
    final updated = filters.isEmpty
        ? FilterGroupMap<T>.from(this).apply((it) => it.remove(groupID))
        : FilterGroupMap<T>.from(this)
            .apply((it) => it.addEntries([MapEntry(groupID, filters)]));
    return FilterGroupMap<T>.unmodifiable(updated);
  }

  /// Returns new filter group instance without deleted groups.
  FilterGroupMap<T> deleteGroups(Iterable<FilterGroupID> groupIDs) {
    final current = FilterGroupMap<T>.from(this);
    for (final groupID in groupIDs) {
      current.remove(groupID);
    }
    return current.length != length
        ? FilterGroupMap<T>.unmodifiable(current)
        : this;
  }

  /// Returns new filter group instance without deleted groups.
  FilterGroupMap<T> deleteGroupsExcept(Iterable<FilterGroupID> groupIDs) {
    final deletable = keys.where((groupID) => !groupIDs.contains(groupID));
    return deleteGroups(deletable);
  }
}
