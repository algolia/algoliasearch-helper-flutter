import 'filter.dart';
import 'filter_group.dart';

abstract class FilterGroupBuilder<T extends Filter> {
  FilterGroupBuilder(this._groupID);

  final FilterGroupID _groupID;
  final Set<T> _filters = {};

  void filter(T filter);

  FilterGroup<T> build();
}

/// Builder for [FacetFilterGroup].
class FacetGroupBuilder extends FilterGroupBuilder<FilterFacet> {
  FacetGroupBuilder({
    String name = '',
    FilterOperator operator = FilterOperator.and,
  }) : super(FilterGroupID(name, operator));

  FacetGroupBuilder.of(super.groupID);

  @override
  void filter(FilterFacet filter) {
    _filters.add(filter);
  }

  void facet(
    String attribute,
    dynamic value, {
    bool isNegated = false,
    int? score,
  }) {
    final facet = Filter.facet(
      attribute,
      value,
      isNegated: isNegated,
      score: score,
    );
    filter(facet);
  }

  @override
  FacetFilterGroup build() => FacetFilterGroup(_groupID, _filters);
}

/// Builder for [TagFilterGroup].
class TagGroupBuilder extends FilterGroupBuilder<FilterTag> {
  TagGroupBuilder({
    String name = '',
    FilterOperator operator = FilterOperator.and,
  }) : super(FilterGroupID(name, operator));

  TagGroupBuilder.of(super.groupID);

  @override
  void filter(FilterTag filter) {
    _filters.add(filter);
  }

  void tag(String value, [bool isNegated = false]) {
    final tag = Filter.tag(value, isNegated);
    filter(tag);
  }

  @override
  TagFilterGroup build() => TagFilterGroup(_groupID, _filters);
}

/// Builder for [NumericFilterGroup].
class NumericGroupBuilder extends FilterGroupBuilder<FilterNumeric> {
  NumericGroupBuilder({
    String name = '',
    FilterOperator operator = FilterOperator.and,
  }) : super(FilterGroupID(name, operator));

  NumericGroupBuilder.of(super.groupID);

  @override
  void filter(FilterNumeric filter) {
    _filters.add(filter);
  }

  void range(
    String attribute, {
    required num lowerBound,
    required num upperBound,
    bool isNegated = false,
  }) {
    final range = Filter.range(attribute,
        lowerBound: lowerBound, upperBound: upperBound, isNegated: isNegated);
    filter(range);
  }

  void comparison(
    String attribute,
    NumericOperator operator,
    num number, {
    bool isNegated = false,
  }) {
    final comparison =
        Filter.comparison(attribute, operator, number, isNegated: isNegated);
    filter(comparison);
  }

  @override
  NumericFilterGroup build() => NumericFilterGroup(_groupID, _filters);
}

/// Builder for [MultiFilterGroup].
class MultiFilterGroupBuilder extends FilterGroupBuilder<Filter> {
  MultiFilterGroupBuilder({
    String name = '',
  }) : super(FilterGroupID.and(name));

  MultiFilterGroupBuilder.of(super.groupID)
      : assert(groupID.operator == FilterOperator.and);

  @override
  void filter(Filter filter) {
    _filters.add(filter);
  }

  void facet(
    String attribute,
    dynamic value, {
    bool isNegated = false,
    int? score,
  }) {
    final facet = Filter.facet(
      attribute,
      value,
      isNegated: isNegated,
      score: score,
    );
    filter(facet);
  }

  void tag(String value, [bool isNegated = false]) {
    final tag = Filter.tag(value, isNegated);
    filter(tag);
  }

  void range(
    String attribute, {
    required num lowerBound,
    required num upperBound,
    bool isNegated = false,
  }) {
    final range = Filter.range(attribute,
        lowerBound: lowerBound, upperBound: upperBound, isNegated: isNegated);
    filter(range);
  }

  void comparison(
    String attribute,
    NumericOperator operator,
    num number, {
    bool isNegated = false,
  }) {
    final comparison =
        Filter.comparison(attribute, operator, number, isNegated: isNegated);
    filter(comparison);
  }

  @override
  MultiFilterGroup build() => MultiFilterGroup(_groupID, _filters);
}
