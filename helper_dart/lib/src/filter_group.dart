import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

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
abstract class FilterGroup<T extends Filter> extends DelegatingSet<T> {
  /// Creates [FilterGroupID] instance.
  const FilterGroup._(this.groupID, this._filters) : super(_filters);

  /// Creates [FilterGroup] as [FacetFilterGroup].
  @factory
  static FacetFilterGroup facet({
    required Set<FilterFacet> filters,
    String name = '',
    FilterOperator operator = FilterOperator.and,
  }) =>
      FacetFilterGroup(FilterGroupID(name, operator), filters);

  /// Creates [FilterGroup] as [TagFilterGroup].
  @factory
  static TagFilterGroup tag({
    required Set<FilterTag> filters,
    String name = '',
    FilterOperator operator = FilterOperator.and,
  }) =>
      TagFilterGroup(FilterGroupID(name, operator), filters);

  /// Creates [FilterGroup] as [NumericFilterGroup].
  @factory
  static NumericFilterGroup numeric({
    required Set<FilterNumeric> filters,
    String name = '',
    FilterOperator operator = FilterOperator.and,
  }) =>
      NumericFilterGroup(FilterGroupID(name, operator), filters);

  /// Creates [FilterGroup] as [HierarchicalFilterGroup].
  @factory
  static HierarchicalFilterGroup hierarchical({
    required Set<FilterFacet> filters,
    required List<FilterFacet> path,
    required List<String> attributes,
    String name = '',
  }) =>
      HierarchicalFilterGroup(
        FilterGroupID.and(name),
        filters,
        path,
        attributes,
      );

  /// Filter group ID (name and operator)
  final FilterGroupID groupID;

  /// Set of filters.
  final Set<T> _filters;

  /// Create a copy with given parameters.
  @factory
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
  /// Creates a [FilterGroup] instance.
  const FacetFilterGroup(super.groupID, super.filters) : super._();

  /// Make a copy of the facet filters group.
  @override
  FacetFilterGroup copyWith({
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
  /// Creates a [TagFilterGroup] instance.
  const TagFilterGroup(super.groupID, super.filters) : super._();

  /// Make a copy of the tag filters group.
  @override
  TagFilterGroup copyWith({
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
  /// Creates a [NumericFilterGroup] instance.
  const NumericFilterGroup(super.groupID, super.filters) : super._();

  /// Make a copy of the numeric filters group.
  @override
  NumericFilterGroup copyWith({
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
class HierarchicalFilterGroup extends FilterGroup<FilterFacet> {
  /// Creates an [HierarchicalFilterGroup] instance.
  HierarchicalFilterGroup(
    super.groupID,
    super.filters,
    this.path,
    this.attributes,
  ) : super._() {
    assert(groupID.operator == FilterOperator.and);
  }

  /// Filter facets path.
  final List<FilterFacet> path;

  /// Attributes names.
  final List<String> attributes;

  /// Make a copy of the hierarchical filters group.
  @override
  HierarchicalFilterGroup copyWith({
    FilterGroupID? groupID,
    Set<FilterFacet>? filters,
    List<FilterFacet>? path,
    List<String>? attributes,
  }) =>
      HierarchicalFilterGroup(
        groupID ?? this.groupID,
        filters ?? _filters,
        path ?? this.path,
        attributes ?? this.attributes,
      );

  @override
  String toString() =>
      'HierarchicalFilterGroup{groupID: $groupID, filters: $_filters}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is HierarchicalFilterGroup &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          attributes == other.attributes;

  @override
  int get hashCode => super.hashCode ^ path.hashCode ^ attributes.hashCode;
}
