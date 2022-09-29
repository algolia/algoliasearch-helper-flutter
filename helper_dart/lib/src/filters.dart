import 'package:meta/meta.dart';

import 'extensions.dart';
import 'filter.dart';
import 'filter_group.dart';

/// Map of filter groups convenience type.
typedef FilterGroupMap<T> = Map<FilterGroupID, Set<T>>;

/// Filter groups: facet, tag, numeric and hierarchical.
@sealed
abstract class Filters {
  /// Map of facet filter groups.
  FilterGroupMap<FilterFacet> get facetGroups;

  /// Map of tag filter groups.
  FilterGroupMap<FilterTag> get tagGroups;

  /// Map of numeric filter groups.
  FilterGroupMap<FilterNumeric> get numericGroups;

  /// Map of hierarchical filter groups.
  Map<String, HierarchicalFilter> get hierarchicalGroups;

  /// Get [FilterFacet] group by [groupID].
  Set<FilterFacet>? getFacetFilters(FilterGroupID groupID);

  /// Get [FilterTag] group by [groupID].
  Set<FilterTag>? getTagFilters(FilterGroupID groupID);

  /// Get [FilterNumeric] group by [groupID].
  Set<FilterNumeric>? getNumericFilters(FilterGroupID groupID);

  /// Get [HierarchicalFilter] by [attribute].
  HierarchicalFilter? getHierarchicalFilters(String attribute);

  /// Get all filter groups as single map.
  Map<FilterGroupID, Set<Filter>> getGroups();

  /// Get all filters by [groupID].
  Set<Filter> getFilters({FilterGroupID? groupID});

  /// Get all filters as a single [Set] of [Filter]s.
  Set<Filter> _getAllFilters();

  /// Get all filters by [groupID] as a single [Set] of [Filter]s.
  Set<Filter> _getFiltersByGroupID(FilterGroupID groupID);

  /// Checks if [filter] with [groupID] exists.
  bool contains(FilterGroupID groupID, Filter filter);

  /// Get all filters as a [Set] of [FilterGroup]s.
  Set<FilterGroup> toFilterGroups();

  /// Create a copy with given parameters.
  @factory
  Filters copyWith({
    Map<FilterGroupID, Set<FilterFacet>>? facetGroups,
    Map<FilterGroupID, Set<FilterTag>>? tagGroups,
    Map<FilterGroupID, Set<FilterNumeric>>? numericGroups,
    Map<String, HierarchicalFilter>? hierarchicalGroups,
  });
}

/// Immutable filters implementation.
/// **All operations create a new object with requested changes.**
@sealed
abstract class ImmutableFilters implements Filters {
  /// ImmutableFilters's factory.
  factory ImmutableFilters({
    Map<FilterGroupID, Set<FilterFacet>> facetGroups = const {},
    Map<FilterGroupID, Set<FilterTag>> tagGroups = const {},
    Map<FilterGroupID, Set<FilterNumeric>> numericGroups = const {},
    Map<String, HierarchicalFilter> hierarchicalGroups = const {},
  }) =>
      _ImmutableFilters(
        facetGroups: facetGroups,
        tagGroups: tagGroups,
        numericGroups: numericGroups,
        hierarchicalGroups: hierarchicalGroups,
      );

  /// Adds [filters] to the provided [groupID].
  ImmutableFilters add(FilterGroupID groupID, Iterable<Filter> filters);

  /// Get filters with the provided [map].
  ImmutableFilters set(Map<FilterGroupID, Set<Filter>> map);

  /// Toggles [filter] in given [groupID].
  ImmutableFilters toggle(FilterGroupID groupID, Filter filter);

  /// Removes [filters] from [groupID].
  ImmutableFilters remove(FilterGroupID groupID, Iterable<Filter> filters);

  /// Adds [hierarchicalFilter] to given [attribute].
  ImmutableFilters addHierarchical(
    String attribute,
    HierarchicalFilter hierarchicalFilter,
  );

  /// Removes [HierarchicalFilter] of given [attribute].
  ImmutableFilters removeHierarchical(String attribute);

  /// Clears [groupIDs].
  /// If none provided, all filters will be cleared.
  ImmutableFilters clear([Iterable<FilterGroupID>? groupIDs]);

  /// Clears all except [groupIDs].
  ImmutableFilters clearExcept(Iterable<FilterGroupID> groupIDs);

  @override
  ImmutableFilters copyWith({
    Map<FilterGroupID, Set<FilterFacet>>? facetGroups,
    Map<FilterGroupID, Set<FilterTag>>? tagGroups,
    Map<FilterGroupID, Set<FilterNumeric>>? numericGroups,
    Map<String, HierarchicalFilter>? hierarchicalGroups,
  });
}

/// Default implementation of [ImmutableFilters].
class _ImmutableFilters implements ImmutableFilters {
  /// Creates [_ImmutableFilters] instance.
  const _ImmutableFilters({
    this.facetGroups = const {},
    this.tagGroups = const {},
    this.numericGroups = const {},
    this.hierarchicalGroups = const {},
  });

  @override
  final FilterGroupMap<FilterFacet> facetGroups;

  @override
  final Map<String, HierarchicalFilter> hierarchicalGroups;

  @override
  final FilterGroupMap<FilterNumeric> numericGroups;

  @override
  final FilterGroupMap<FilterTag> tagGroups;

  /// Get [FilterFacet] group by [groupID].
  @override
  Set<FilterFacet>? getFacetFilters(FilterGroupID groupID) =>
      facetGroups[groupID];

  /// Get [FilterTag] group by [groupID].
  @override
  Set<FilterTag>? getTagFilters(FilterGroupID groupID) => tagGroups[groupID];

  /// Get [FilterNumeric] group by [groupID].
  @override
  Set<FilterNumeric>? getNumericFilters(FilterGroupID groupID) =>
      numericGroups[groupID];

  /// Get [HierarchicalFilter] by [attribute].
  @override
  HierarchicalFilter? getHierarchicalFilters(String attribute) =>
      hierarchicalGroups[attribute];

  /// Get all filter groups as single map.
  @override
  Map<FilterGroupID, Set<Filter>> getGroups() =>
      {...facetGroups, ...tagGroups, ...numericGroups};

  /// Get all filters by [groupID].
  @override
  Set<Filter> getFilters({FilterGroupID? groupID}) =>
      groupID == null ? _getAllFilters() : _getFiltersByGroupID(groupID);

  /// Get all filters as a single [Set] of [Filter]s.
  @override
  Set<Filter> _getAllFilters() {
    final facetFilters = facetGroups.values.expand((element) => element);
    final tagFilters = tagGroups.values.expand((element) => element);
    final numericFilters = numericGroups.values.expand((element) => element);
    return {...facetFilters, ...tagFilters, ...numericFilters};
  }

  /// Get all filters by [groupID] as a single [Set] of [Filter]s.
  @override
  Set<Filter> _getFiltersByGroupID(FilterGroupID groupID) {
    final facetFilters = getFacetFilters(groupID);
    final tagFilters = getTagFilters(groupID);
    final numericFilters = getTagFilters(groupID);
    return {...?facetFilters, ...?tagFilters, ...?numericFilters};
  }

  /// Checks if [filter] with [groupID] exists.
  @override
  bool contains(FilterGroupID groupID, Filter filter) {
    switch (filter.runtimeType) {
      case FilterFacet:
        return facetGroups[groupID]?.contains(filter) ?? false;
      case FilterTag:
        return tagGroups[groupID]?.contains(filter) ?? false;
      case FilterNumeric:
        return numericGroups[groupID]?.contains(filter) ?? false;
      default:
        return false;
    }
  }

  /// Get all filters as a [Set] of [FilterGroup]s.
  @override
  Set<FilterGroup> toFilterGroups() {
    final facets = facetGroups.toList(FacetFilterGroup.new).unmodifiable();
    final tags = tagGroups.toList(TagFilterGroup.new).unmodifiable();
    final numerics =
        numericGroups.toList(NumericFilterGroup.new).unmodifiable();
    final hierarchical = hierarchicalGroups
        .toList(
          (name, group) => HierarchicalFilterGroup(
            FilterGroupID.and(name),
            {group.filter},
            group.path,
            group.attributes,
          ),
        )
        .unmodifiable();
    return {...facets, ...tags, ...numerics, ...hierarchical};
  }

  /// Adds [filters] to the provided [groupID].
  @override
  ImmutableFilters add(FilterGroupID groupID, Iterable<Filter> filters) {
    ImmutableFilters current = this;
    for (final filter in filters) {
      switch (filter.runtimeType) {
        case FilterFacet:
          current = current.copyWith(
            facetGroups:
                current.facetGroups.add(groupID, filter as FilterFacet),
          );
          break;
        case FilterTag:
          current = current.copyWith(
            tagGroups: current.tagGroups.add(groupID, filter as FilterTag),
          );
          break;
        case FilterNumeric:
          current = current.copyWith(
            numericGroups:
                current.numericGroups.add(groupID, filter as FilterNumeric),
          );
          break;
      }
    }
    return current;
  }

  /// Get filters with the provided [map].
  @override
  ImmutableFilters set(Map<FilterGroupID, Set<Filter>> map) {
    ImmutableFilters filters = const _ImmutableFilters();
    for (final entry in map.entries) {
      filters = filters.add(entry.key, entry.value);
    }
    return filters;
  }

  /// Toggles [filter] in given [groupID].
  @override
  ImmutableFilters toggle(FilterGroupID groupID, Filter filter) =>
      contains(groupID, filter)
          ? remove(groupID, [filter])
          : add(groupID, [filter]);

  /// Removes [filters] from [groupID].
  @override
  ImmutableFilters remove(FilterGroupID groupID, Iterable<Filter> filters) {
    ImmutableFilters current = this;
    for (final filter in filters) {
      switch (filter.runtimeType) {
        case FilterFacet:
          current = current.copyWith(
            facetGroups:
                current.facetGroups.delete(groupID, filter as FilterFacet),
          );
          break;
        case FilterTag:
          current = current.copyWith(
            tagGroups: current.tagGroups.delete(groupID, filter as FilterTag),
          );
          break;
        case FilterNumeric:
          current = current.copyWith(
            numericGroups:
                current.numericGroups.delete(groupID, filter as FilterNumeric),
          );
          break;
      }
    }
    return current;
  }

  /// Adds [hierarchicalFilter] to given [attribute].
  @override
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
  @override
  ImmutableFilters removeHierarchical(String attribute) {
    if (!hierarchicalGroups.containsKey(attribute)) return this;
    final groups = Map<String, HierarchicalFilter>.from(hierarchicalGroups)
      ..remove(attribute);
    return copyWith(hierarchicalGroups: Map.unmodifiable(groups));
  }

  /// Clears [groupIDs].
  /// If none provided, all filters will be cleared.
  @override
  ImmutableFilters clear([Iterable<FilterGroupID>? groupIDs]) {
    if (groupIDs == null || groupIDs.isEmpty) {
      return const _ImmutableFilters();
    }
    return _ImmutableFilters(
      facetGroups: facetGroups.deleteGroups(groupIDs),
      numericGroups: numericGroups.deleteGroups(groupIDs),
      tagGroups: tagGroups.deleteGroups(groupIDs),
    );
  }

  /// Clears all except [groupIDs].
  @override
  ImmutableFilters clearExcept(Iterable<FilterGroupID> groupIDs) {
    if (groupIDs.isEmpty) return const _ImmutableFilters();
    return _ImmutableFilters(
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
      _ImmutableFilters(
        facetGroups: facetGroups ?? this.facetGroups,
        tagGroups: tagGroups ?? this.tagGroups,
        numericGroups: numericGroups ?? this.numericGroups,
        hierarchicalGroups: hierarchicalGroups ?? this.hierarchicalGroups,
      );

  @override
  String toString() => 'Filters{'
      'facetGroups: $facetGroups, '
      'tagGroups: $tagGroups, '
      'numericGroups: $numericGroups, '
      'hierarchicalGroups: $hierarchicalGroups'
      '}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Filters &&
          runtimeType == other.runtimeType &&
          facetGroups.equals(other.facetGroups) &&
          tagGroups.equals(other.tagGroups) &&
          numericGroups.equals(other.numericGroups) &&
          hierarchicalGroups.equals(other.hierarchicalGroups);

  @override
  int get hashCode =>
      facetGroups.hashing() ^
      tagGroups.hashing() ^
      numericGroups.hashing() ^
      hierarchicalGroups.hashing();
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
