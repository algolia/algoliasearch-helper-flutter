import 'package:collection/collection.dart';

import 'extensions.dart';
import 'filter.dart';

/// Identifier of a filter group.
/// The group name is for access purpose only, won't be used for the actual
/// filters generation.
class FilterGroupID {
  const FilterGroupID([this.name = '', this.operator = FilterOperator.and]);

  /// Create and [FilterGroupID] with operator [FilterOperator.and].
  factory FilterGroupID.and([String name = '']) => FilterGroupID(name);

  /// Create and [FilterGroupID] with operator [FilterOperator.or].
  factory FilterGroupID.or([String name = '']) =>
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
abstract class FilterGroup<T> extends DelegatingSet<T> {
  /// Creates [FilterGroupID] instance.
  const FilterGroup._(this.groupID, this._filters) : super(_filters);

  /// Creates [FilterGroup] as [FacetFilterGroup].
  static FacetFilterGroup facet({
    String name = '',
    Set<FilterFacet> filters = const {},
    FilterOperator operator = FilterOperator.and,
  }) =>
      FacetFilterGroup(FilterGroupID(name, operator), filters);

  /// Creates [FilterGroup] as [TagFilterGroup].
  static TagFilterGroup tag({
    String name = '',
    Set<FilterTag> filters = const {},
    FilterOperator operator = FilterOperator.and,
  }) =>
      TagFilterGroup(FilterGroupID(name, operator), filters);

  /// Creates [FilterGroup] as [NumericFilterGroup].
  static NumericFilterGroup numeric({
    String name = '',
    Set<FilterNumeric> filters = const {},
    FilterOperator operator = FilterOperator.and,
  }) =>
      NumericFilterGroup(FilterGroupID(name, operator), filters);

  /// Creates [FilterGroup] as [HierarchicalFilterGroup].
  static HierarchicalFilterGroup hierarchical({
    String name = '',
    Set<HierarchicalFilter> filters = const {},
  }) =>
      HierarchicalFilterGroup(name, filters);

  /// Filter group ID (name and operator)
  final FilterGroupID groupID;

  /// Set of filters.
  final Set<T> _filters;

  /// Create a copy with given parameters.
  FilterGroup<T> copyWith({FilterGroupID? groupID, Set<T>? filters});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterGroup &&
          runtimeType == other.runtimeType &&
          groupID == other.groupID &&
          _filters.equals(other._filters);

  @override
  int get hashCode => groupID.hashCode ^ _filters.hashing();
}

/// Facets filter group
class FacetFilterGroup extends FilterGroup<FilterFacet> {
  /// Creates an [FilterGroup] instance.
  const FacetFilterGroup(super.groupID, super.filters) : super._();

  /// Make a copy of the facet filters group.
  @override
  FilterGroup<FilterFacet> copyWith({
    FilterGroupID? groupID,
    Set<FilterFacet>? filters,
  }) =>
      FacetFilterGroup(
        groupID ?? this.groupID,
        filters ?? _filters,
      );

  @override
  String toString() =>
      'FacetFilterGroup{groupID: $groupID, filters: $_filters}';
}

/// Tags filter group
class TagFilterGroup extends FilterGroup<FilterTag> {
  /// Creates an [TagFilterGroup] instance.
  const TagFilterGroup(super.groupID, super.filters) : super._();

  /// Make a copy of the tag filters group.
  @override
  FilterGroup<FilterTag> copyWith({
    FilterGroupID? groupID,
    Set<FilterTag>? filters,
  }) =>
      TagFilterGroup(
        groupID ?? this.groupID,
        filters ?? _filters,
      );

  @override
  String toString() => 'TagFilterGroup{groupID: $groupID, filters: $_filters}';
}

/// Numeric facets filter group
class NumericFilterGroup extends FilterGroup<FilterNumeric> {
  /// Creates an [NumericFilterGroup] instance.
  const NumericFilterGroup(super.groupID, super.filters) : super._();

  /// Make a copy of the numeric filters group.
  @override
  FilterGroup<FilterNumeric> copyWith({
    FilterGroupID? groupID,
    Set<FilterNumeric>? filters,
  }) =>
      NumericFilterGroup(
        groupID ?? this.groupID,
        filters ?? _filters,
      );

  @override
  String toString() =>
      'NumericFilterGroup{groupID: $groupID, filters: $_filters}';
}

/// Hierarchical filter group
class HierarchicalFilterGroup extends FilterGroup<HierarchicalFilter> {
  /// Creates an [HierarchicalFilterGroup] instance.
  HierarchicalFilterGroup(String name, Set<HierarchicalFilter> filters)
      : this._(FilterGroupID(name), filters);

  /// Creates an [HierarchicalFilterGroup] instance.
  HierarchicalFilterGroup._(super.groupID, super.filters) : super._() {
    assert(groupID.operator == FilterOperator.and);
  }

  /// Make a copy of the hierarchical filters group.
  @override
  FilterGroup<HierarchicalFilter> copyWith({
    FilterGroupID? groupID,
    Set<HierarchicalFilter>? filters,
  }) =>
      HierarchicalFilterGroup._(
        groupID ?? this.groupID,
        filters ?? _filters,
      );

  @override
  String toString() =>
      'HierarchicalFilterGroup{groupID: $groupID, filters: $_filters}';
}
