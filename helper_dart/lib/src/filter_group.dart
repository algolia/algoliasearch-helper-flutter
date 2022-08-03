import 'package:algolia_helper_dart/algolia.dart';

import 'filter.dart';

/// Identifier of a filter group.
/// The group name is for access purpose only, won't be used for the actual filters generation.
class FilterGroupID {
  FilterGroupID([this.name = "", this.operator = FilterOperator.and]);

  /// Create and [FilterGroupID] with operator [FilterOperator.and].
  factory FilterGroupID.and([String name = ""]) =>
      FilterGroupID(name, FilterOperator.and);

  /// Create and [FilterGroupID] with operator [FilterOperator.or].
  factory FilterGroupID.groupOr([String name = ""]) =>
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
  String toString() {
    return 'FilterGroupID{name: $name, operator: $operator}';
  }
}

/// Group filter operator
enum FilterOperator { and, or }

/// Represents a filter group
abstract class FilterGroup<T> {
  FilterGroup(this.groupID, this.filters);

  final FilterGroupID groupID;
  final Set<T> filters;
}

/// Facets filter group
class FacetFilterGroup extends FilterGroup<FilterFacet> {
  FacetFilterGroup(super.groupID, super.filters);
}

/// Tags filter group
class TagFilterGroup extends FilterGroup<FilterTag> {
  TagFilterGroup(super.groupIDr, super.filters);
}

/// Numeric facets filter group
class NumericFilterGroup extends FilterGroup<FilterNumeric> {
  NumericFilterGroup(super.groupID, super.filters);
}

/// Hierarchical filter group
class HierarchicalFilterGroup extends FilterGroup<HierarchicalFilter> {
  HierarchicalFilterGroup(String name, Set<HierarchicalFilter> filters)
      : super(FilterGroupID(name, FilterOperator.and), filters);
}
