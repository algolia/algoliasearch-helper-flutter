import 'filter.dart';

class FilterGroupID {
  FilterGroupID(this.name, this.operator);

  final String name;
  final FilterOperator operator;
}

enum FilterOperator { and, or }

class HierarchicalFilter {
  HierarchicalFilter(this.attributes, this.path, this.filter);

  final List<String> attributes;
  final List<FilterFacet> path;
  final FilterFacet filter;
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
