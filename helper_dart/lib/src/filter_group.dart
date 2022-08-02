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

enum FilterOperator { and, or }

class HierarchicalFilter {
  HierarchicalFilter(this.attributes, this.path, this.filter);

  final List<String> attributes;
  final List<FilterFacet> path;
  final FilterFacet filter;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HierarchicalFilter &&
          runtimeType == other.runtimeType &&
          attributes == other.attributes &&
          path == other.path &&
          filter == other.filter;

  @override
  int get hashCode => attributes.hashCode ^ path.hashCode ^ filter.hashCode;

  @override
  String toString() {
    return 'HierarchicalFilter{attributes: $attributes, path: $path, filter: $filter}';
  }
}
