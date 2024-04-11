import 'package:meta/meta.dart';

/// Represents a search filter:
/// - [FilterFacet] to filter on facet values
/// - [FilterTag] to filter on tags
/// - [FilterNumeric] to filter on numeric attributes
///
/// ## Facet filter
///
/// Create [FilterFacet] by calling [facet] method:
///
/// ```dart
/// // color:red
/// final filter = Filter.facet('color', 'red');
/// ```
///
/// ## Tag filter
///
/// Create [FilterTag] by calling [tag] method:
///
/// ```dart
/// // _tags:book
/// final filter = Filter.tag('book');
/// ```
///
/// ## Numeric filter
///
/// [FilterNumeric] filters on a numeric value by range (lower/upper bounds)
/// or by comparing it with a [NumericOperator].
///
/// ### Numeric comparison
///
/// Create [FilterNumeric] comparing a numeric value using [NumericOperator],
/// by calling [comparison] method:
///
/// ```dart
/// // 'price <= 42'
/// final filter = Filter.comparison('price', NumericOperator.lessOrEquals, 42);
/// ```
///
/// ### Numeric range
///
/// Create [FilterNumeric] with a numeric range by calling [range] method:
///
/// ```dart
/// // rating:3 TO 5
/// final filter = Filter.range('rating', lowerBound: 3, upperBound: 5);
/// ```
sealed class Filter {
  /// Creates [Filter] instance.
  const Filter._(this.attribute, this.isNegated);

  /// The [attribute] this filter applies on.
  final String attribute;

  /// Whether or not the filter is negated.
  final bool isNegated;

  /// Creates [FilterFacet] instance.
  @factory
  static FilterFacet facet(
    String attribute,
    dynamic value, {
    bool isNegated = false,
    int? score,
  }) =>
      FilterFacet._(attribute, value, isNegated, score);

  /// Creates [FilterTag] instance.
  @factory
  static FilterTag tag(String value, [bool isNegated = false]) =>
      FilterTag._(value, isNegated);

  /// Creates [FilterNumeric] instance as numeric comparison.
  @factory
  static FilterNumeric comparison(
    String attribute,
    NumericOperator operator,
    num number, {
    bool isNegated = false,
  }) =>
      FilterNumeric.comparison(attribute, operator, number, isNegated);

  /// Creates [FilterNumeric] instance as numeric range.
  @factory
  static FilterNumeric range(
    String attribute, {
    required num lowerBound,
    required num upperBound,
    bool isNegated = false,
  }) =>
      FilterNumeric.range(attribute, lowerBound, upperBound, isNegated);

  /// Negates a [FilterFacet].
  @factory
  Filter not();
}

/// A [FilterFacet] matches exactly an [attribute] with a [value].
/// An optional [score] allows to assign a priority between several
/// [FilterFacet] that are evaluated in the same filter group.
final class FilterFacet implements Filter {
  /// Creates [FilterFacet] instance.
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

  /// Facet filter value (String, bool or num).
  final dynamic value;

  /// Filter facet score.
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

  /// Make a copy of the facet filter.
  FilterFacet copyWith({
    String? attribute,
    dynamic value,
    bool? isNegated,
    int? score,
  }) =>
      FilterFacet._(
        attribute ?? this.attribute,
        value ?? this.value,
        isNegated ?? this.isNegated,
        score ?? this.score,
      );

  @override
  FilterFacet not() => copyWith(isNegated: !isNegated);
}

/// A [FilterTag] filters on a specific [value].
/// It uses a reserved keywords `_tags` as [attribute].
final class FilterTag implements Filter {
  /// Creates [FilterTag] instance.
  const FilterTag._(this.value, [this.isNegated = false]);

  @override
  final String attribute = '_tags';
  @override
  final bool isNegated;

  /// Filter tag value.
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

  /// Make a copy of the tag filter.
  FilterTag copyWith({
    String? value,
    bool? isNegated,
  }) =>
      FilterTag._(
        value ?? this.value,
        isNegated ?? this.isNegated,
      );

  @override
  FilterTag not() => copyWith(isNegated: !isNegated);
}

/// A [FilterNumeric] filters on a numeric [value] by range (lower/upper bounds)
/// or by comparing it with [NumericOperator].
///
/// ### Numeric comparison
///
/// Create [FilterNumeric] comparing a numeric value using [NumericOperator],
/// by calling [FilterNumeric.comparison] constructor:
///
/// ```dart
/// final filter = Filter.comparison('price', NumericOperator.lessOrEquals, 42);
/// ```
///
/// ### Numeric range
///
/// Create [FilterNumeric] with a numeric range by calling [FilterNumeric.range]
/// constructor:
///
/// ```dart
/// final filter = Filter.range('rating', lowerBound: 3, upperBound: 5);
/// ```
final class FilterNumeric implements Filter {
  /// Creates [FilterNumeric] instance.
  const FilterNumeric._(this.attribute, this.value, [this.isNegated = false]);

  @override
  final String attribute;
  @override
  final bool isNegated;

  /// Filter numeric value.
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

  /// Make a copy of the numeric filter.
  FilterNumeric copyWith({
    String? attribute,
    NumericValue? value,
    bool? isNegated,
  }) =>
      FilterNumeric._(
        attribute ?? this.attribute,
        value ?? this.value,
        isNegated ?? this.isNegated,
      );

  @override
  FilterNumeric not() => copyWith(isNegated: !isNegated);
}

/// Represents a filter numeric value:
/// - [NumericRange] for a range between lower/upper bounds
/// - [NumericComparison] to compares a number using a numeric operator
sealed class NumericValue {
  /// Creates an [NumericValue] instance.
  NumericValue._();
}

/// Numeric range comprised within a [lowerBound] and an [upperBound].
final class NumericRange implements NumericValue {
  /// Creates [NumericRange] instance.
  const NumericRange._(this.lowerBound, this.upperBound);

  /// The minimum value for the input.
  final num lowerBound;

  /// The maximum value for the input.
  final num upperBound;
}

/// Numeric comparison of a [number] using a [NumericOperator].
final class NumericComparison implements NumericValue {
  /// Creates [NumericComparison] instance.
  const NumericComparison._(this.operator, this.number);

  /// Comparison operator to apply.
  final NumericOperator operator;

  /// Numeric value to filter on.
  final num number;
}

/// Numeric comparison operators.
/// Supported operators are: `<`, `<=`, `=`, `!=`, `>=` and `>`.
enum NumericOperator {
  /// Numeric operator `<`
  less('<'),

  /// Numeric operator `<=`
  lessOrEquals('<='),

  /// Numeric operator `=`
  equals('='),

  /// Numeric operator `!=`
  notEquals('!='),

  /// Numeric operator `>=`
  greaterOrEquals('>='),

  /// Numeric operator `>`
  greater('>');

  /// Numeric operator constructor
  const NumericOperator(this.operator);

  /// String representation of the operator.
  final String operator;
}

/// Filter over a hierarchy of facet attributes.
///
/// ## Create a hierarchical filter
///
/// ````dart
/// const level0 = 'category.lvl0';
/// const level1 = 'category.lvl1';
/// final filterShoes = Filter.facet(level0, 'Shoes');
/// final filterShoesRunning = Filter.facet(level1, 'Shoes > Running');
///
/// final hierarchicalFilter = HierarchicalFilter(
///   [level0, level1],
///   [filterShoes, filterShoesRunning],
///   filterShoesRunning,
/// );
/// ```
final class HierarchicalFilter {
  /// Creates an [HierarchicalFilter] instance.
  HierarchicalFilter(this.attributes, this.path, this.filter);

  /// Attributes names.
  final List<String> attributes;

  /// Filter facets path.
  final List<FilterFacet> path;

  /// Filter facet value.
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

  /// Make a copy of the numeric filter.
  HierarchicalFilter copyWith({
    List<String>? attributes,
    List<FilterFacet>? path,
    FilterFacet? filter,
  }) =>
      HierarchicalFilter(
        attributes ?? this.attributes,
        path ?? this.path,
        filter ?? this.filter,
      );
}
