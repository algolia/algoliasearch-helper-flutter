/// Represents a search filter
class Filter {
  const Filter._(this.attribute, this.isNegated);

  final String attribute;
  final bool isNegated;

  /// Creates [FilterFacet] instance.
  static FilterFacet facet(
    String attribute,
    dynamic value, [
    bool isNegated = false,
    int? score,
  ]) =>
      FilterFacet._(attribute, value, isNegated, score);

  /// Creates [FilterTag] instance.
  static FilterTag tag(String value, [bool isNegated = false]) =>
      FilterTag._(value, isNegated);

  /// Creates [FilterNumeric] instance as numeric comparison.
  static FilterNumeric comparison(
    String attribute,
    NumericOperator operator,
    num number, [
    bool isNegated = false,
  ]) =>
      FilterNumeric.comparison(attribute, operator, number, isNegated);

  /// Creates [FilterNumeric] instance as numeric comparison.
  static FilterNumeric range(
    String attribute,
    num lowerBound,
    num upperBound, [
    bool isNegated = false,
  ]) =>
      FilterNumeric.range(attribute, lowerBound, upperBound, isNegated);
}

/// A [FilterFacet] matches exactly an [attribute] with a [value].
/// An optional [score] allows to assign a priority between several
/// [FilterFacet] that are evaluated in the same filter group.
class FilterFacet implements Filter {
  const FilterFacet._(
    this.attribute,
    this.value, [
    this.isNegated = false,
    this.score,
  ]);

  @override
  final String attribute;
  @override
  final bool isNegated;
  final dynamic value;
  final int? score;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterFacet &&
          runtimeType == other.runtimeType &&
          attribute == other.attribute &&
          isNegated == other.isNegated &&
          value == other.value &&
          score == other.score;

  @override
  int get hashCode =>
      attribute.hashCode ^ isNegated.hashCode ^ value.hashCode ^ score.hashCode;

  @override
  String toString() => 'FilterFacet{'
      'attribute: $attribute,'
      ' isNegated: $isNegated,'
      ' value: $value,'
      ' score: $score'
      '}';
}

/// A [FilterTag] filters on a specific [value].
/// It uses a reserved keywords `_tags` as [attribute].
class FilterTag implements Filter {
  const FilterTag._(this.value, [this.isNegated = false]);

  @override
  final String attribute = '_tag';
  @override
  final bool isNegated;
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterTag &&
          runtimeType == other.runtimeType &&
          attribute == other.attribute &&
          isNegated == other.isNegated &&
          value == other.value;

  @override
  int get hashCode => attribute.hashCode ^ isNegated.hashCode ^ value.hashCode;

  @override
  String toString() => 'FilterTag{'
      ' attribute: $attribute,'
      ' isNegated: $isNegated,'
      ' value: $value'
      '}';
}

/// A [FilterNumeric] filters on a numeric [value].
class FilterNumeric implements Filter {
  const FilterNumeric._(this.attribute, this.value, [this.isNegated = false]);

  @override
  final String attribute;
  @override
  final bool isNegated;
  final NumericValue value;

  /// Creates numeric value as a comparison.
  factory FilterNumeric.comparison(
    String attribute,
    NumericOperator operator,
    num number, [
    bool isNegated = false,
  ]) {
    final value = NumericComparison._(operator, number);
    return FilterNumeric._(attribute, value, isNegated);
  }

  /// Creates numeric value as a range.
  factory FilterNumeric.range(
    String attribute,
    num lowerBound,
    num upperBound, [
    bool isNegated = false,
  ]) {
    final value = NumericRange._(lowerBound, upperBound);
    return FilterNumeric._(attribute, value, isNegated);
  }
}

/// Represents a filter numeric value.
abstract class NumericValue {
  NumericValue._();
}

/// Numeric range comprised within a [lowerBound] and an [upperBound].
class NumericRange implements NumericValue {
  const NumericRange._(this.lowerBound, this.upperBound);

  final num lowerBound;
  final num upperBound;
}

/// Numeric comparison of a [number] using a [NumericOperator].
class NumericComparison implements NumericValue {
  const NumericComparison._(this.operator, this.number);

  final NumericOperator operator;
  final num number;
}

/// Numeric comparison operators
enum NumericOperator {
  less('<'),
  lessOrEquals('<='),
  equals('='),
  notEquals('!='),
  greaterOrEquals('>='),
  greater('>');

  const NumericOperator(this.operator);

  final String operator;
}

/// Filter for hierarchical
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
  String toString() => 'HierarchicalFilter{'
      'attributes: $attributes,'
      ' path: $path,'
      ' filter: $filter'
      '}';
}
