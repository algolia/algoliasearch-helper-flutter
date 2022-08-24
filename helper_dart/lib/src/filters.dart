import 'package:meta/meta.dart';

import 'extensions.dart';
import 'filter.dart';
import 'filter_group.dart';

/// Map of filter groups convenience type.
typedef FilterGroupMap<T> = Map<FilterGroupID, Set<T>>;

/// Filter groups: facet, tag, numeric and hierarchical.
class Filters {
  /// Creates [Filters] instance.
  @internal
  const Filters(
    this.facetGroups,
    this.tagGroups,
    this.numericGroups,
    this.hierarchicalGroups,
  );

  /// Map of facet filter groups.
  final FilterGroupMap<FilterFacet> facetGroups;

  /// Map of tag filter groups.
  final FilterGroupMap<FilterTag> tagGroups;

  /// Map of numeric filter groups.
  final FilterGroupMap<FilterNumeric> numericGroups;

  /// Map of hierarchical filter groups.
  final Map<String, HierarchicalFilter> hierarchicalGroups;

  /// Get [FilterFacet] group by [groupID].
  Set<FilterFacet>? getFacetFilters(FilterGroupID groupID) =>
      facetGroups[groupID];

  /// Get [FilterTag] group by [groupID].
  Set<FilterTag>? getTagFilters(FilterGroupID groupID) => tagGroups[groupID];

  /// Get [FilterNumeric] group by [groupID].
  Set<FilterNumeric>? getNumericFilters(FilterGroupID groupID) =>
      numericGroups[groupID];

  /// Get [HierarchicalFilter] by [attribute].
  HierarchicalFilter? getHierarchicalFilters(String attribute) =>
      hierarchicalGroups[attribute];

  /// Get all filter groups as single map.
  Map<FilterGroupID, Set<Filter>> getGroups() =>
      {...facetGroups, ...tagGroups, ...numericGroups};

  /// Get all filters by [groupID].
  Set<Filter> getFilters({FilterGroupID? groupID}) =>
      groupID == null ? _getAllFilters() : _getFiltersByGroupID(groupID);

  /// Get all filters as a single [Set] of [Filter]s.
  Set<Filter> _getAllFilters() {
    final facetFilters = facetGroups.values.expand((element) => element);
    final tagFilters = tagGroups.values.expand((element) => element);
    final numericFilters = numericGroups.values.expand((element) => element);
    return {...facetFilters, ...tagFilters, ...numericFilters};
  }

  /// Get all filters by [groupID] as a single [Set] of [Filter]s.
  Set<Filter> _getFiltersByGroupID(FilterGroupID groupID) {
    final facetFilters = getFacetFilters(groupID);
    final tagFilters = getTagFilters(groupID);
    final numericFilters = getTagFilters(groupID);
    return {...?facetFilters, ...?tagFilters, ...?numericFilters};
  }

  /// Checks if [filter] with [groupID] exists.
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
  Set<FilterGroup> toFilterGroups() {
    final facets = facetGroups.toList(FacetFilterGroup.new).unmodifiable();
    final tags = tagGroups.toList(TagFilterGroup.new).unmodifiable();
    final numerics =
        numericGroups.toList(NumericFilterGroup.new).unmodifiable();
    final hierarchical = hierarchicalGroups
        .toList((name, filter) => HierarchicalFilterGroup(name, {filter}))
        .unmodifiable();
    return {...facets, ...tags, ...numerics, ...hierarchical};
  }

  /// Create a copy with given parameters.
  Filters copyWith({
    Map<FilterGroupID, Set<FilterFacet>>? facetGroups,
    Map<FilterGroupID, Set<FilterTag>>? tagGroups,
    Map<FilterGroupID, Set<FilterNumeric>>? numericGroups,
    Map<String, HierarchicalFilter>? hierarchicalGroups,
  }) =>
      Filters(
        facetGroups ?? this.facetGroups,
        tagGroups ?? this.tagGroups,
        numericGroups ?? this.numericGroups,
        hierarchicalGroups ?? this.hierarchicalGroups,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Filters &&
          runtimeType == other.runtimeType &&
          facetGroups == other.facetGroups &&
          tagGroups == other.tagGroups &&
          numericGroups == other.numericGroups &&
          hierarchicalGroups == other.hierarchicalGroups;

  @override
  int get hashCode =>
      facetGroups.hashCode ^
      tagGroups.hashCode ^
      numericGroups.hashCode ^
      hierarchicalGroups.hashCode;

  @override
  String toString() => 'Filters{'
      ' facetGroups: $facetGroups,'
      ' tagGroups: $tagGroups,'
      ' numericGroups: $numericGroups,'
      ' hierarchicalGroups: $hierarchicalGroups'
      '}';
}
