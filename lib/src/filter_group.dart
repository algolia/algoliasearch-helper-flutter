import 'filter.dart';

class FilterGroupID {
  FilterGroupID(this.name, this.operator);

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

abstract class FilterGroup<T> {
  FilterGroup(this.filters, this.name);

  Set<T> filters;
  String? name;
}

class FilterGroupAnd<T> implements FilterGroup<T> {
  FilterGroupAnd(this.filters, this.name);

  @override
  Set<T> filters;

  @override
  String? name;
}
