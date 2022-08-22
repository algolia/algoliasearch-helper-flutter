import 'filter.dart';

/// Identifier of a filter group.
/// The group name is for access purpose only, won't be used for the actual
/// filters generation.
class FilterGroupID {
  const FilterGroupID([this.name = '', this.operator = FilterOperator.and]);

  /// Create and [FilterGroupID] with operator [FilterOperator.and].
  factory FilterGroupID.and([String name = '']) => FilterGroupID(name);

  /// Create and [FilterGroupID] with operator [FilterOperator.or].
  factory FilterGroupID.groupOr([String name = '']) =>
      FilterGroupID(name, FilterOperator.or);

  final String name;
  final FilterOperator operator;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterGroupID &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          operator == other.operator;

  @override
  int get hashCode => name.hashCode ^ operator.hashCode;

  @override
  String toString() => 'FilterGroupID{'
      ' name: $name,'
      ' operator: $operator'
      '}';
}

/// Group filter operator
enum FilterOperator { and, or }

/// Represents a filter group
abstract class FilterGroup<T> {
  const FilterGroup(this.groupID, this.filters);

  final FilterGroupID groupID;
  final Set<T> filters;

  FilterGroup<T> copyWith({FilterGroupID? groupID, Set<T>? filters});
}

/// Facets filter group
class FacetFilterGroup extends FilterGroup<FilterFacet> {
  const FacetFilterGroup(super.groupID, super.filters);

  /// Make a copy of the facet filters group.
  @override
  FilterGroup<FilterFacet> copyWith({
    FilterGroupID? groupID,
    Set<FilterFacet>? filters,
  }) =>
      FacetFilterGroup(
        groupID ?? this.groupID,
        filters ?? this.filters,
      );

  @override
  String toString() => 'FacetFilterGroup{'
      ' id: $groupID,'
      ' filters: $filters'
      '}';
}

/// Tags filter group
class TagFilterGroup extends FilterGroup<FilterTag> {
  const TagFilterGroup(super.groupID, super.filters);

  /// Make a copy of the tag filters group.
  @override
  FilterGroup<FilterTag> copyWith({
    FilterGroupID? groupID,
    Set<FilterTag>? filters,
  }) =>
      TagFilterGroup(
        groupID ?? this.groupID,
        filters ?? this.filters,
      );

  @override
  String toString() => 'TagFilterGroup{'
      ' id: $groupID,'
      ' filters: $filters'
      '}';
}

/// Numeric facets filter group
class NumericFilterGroup extends FilterGroup<FilterNumeric> {
  const NumericFilterGroup(super.groupID, super.filters);

  /// Make a copy of the numeric filters group.
  @override
  FilterGroup<FilterNumeric> copyWith({
    FilterGroupID? groupID,
    Set<FilterNumeric>? filters,
  }) =>
      NumericFilterGroup(
        groupID ?? this.groupID,
        filters ?? this.filters,
      );

  @override
  String toString() => 'NumericFilterGroup{'
      ' id: $groupID,'
      ' filters: $filters'
      '}';
}

/// Hierarchical filter group
class HierarchicalFilterGroup extends FilterGroup<HierarchicalFilter> {
  HierarchicalFilterGroup(String name, Set<HierarchicalFilter> filters)
      : this._(FilterGroupID(name), filters);

  const HierarchicalFilterGroup._(super.groupID, super.filters);

  /// Make a copy of the hierarchical filters group.
  @override
  FilterGroup<HierarchicalFilter> copyWith({
    FilterGroupID? groupID,
    Set<HierarchicalFilter>? filters,
  }) =>
      HierarchicalFilterGroup._(
        groupID ?? this.groupID,
        filters ?? this.filters,
      );

  @override
  String toString() => 'HierarchicalFilterGroup{'
      ' id: $groupID,'
      ' filters: $filters'
      '}';
}
