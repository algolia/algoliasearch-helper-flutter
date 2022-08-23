import 'package:collection/collection.dart';

import 'filter.dart';
import 'filter_group.dart';
import 'utils.dart';

/// Converts [FilterGroup] to an SQL like syntax.
class FilterGroupConverter {
  /// Creates [FilterGroupConverter] instance.
  const FilterGroupConverter();

  /// Converts [FilterGroup] to its SQL-like [String] representation.
  /// Returns `null` if the list is empty.
  String? toSQL(Set<FilterGroup<Filter>> filterGroups) {
    if (filterGroups.isEmpty) return null;
    final groups = filterGroups.whereNot((element) => element.isEmpty);
    return groups.joinToString(
      separator: ' AND ',
      transform: (group) => group.joinToString(
        prefix: '(',
        postfix: ')',
        separator: _separatorOf(group),
        transform: (filter) => const FilterConverter().toSQL(filter),
      ),
    );
  }

  /// Get separator string (i.e. AND/OR) of a [group].
  String _separatorOf(FilterGroup group) {
    switch (group.groupID.operator) {
      case FilterOperator.and:
        return ' AND ';
      case FilterOperator.or:
        return ' OR ';
    }
  }
}

/// Converts [Filter] to an SQL like syntax.
class FilterConverter {
  /// Creates [FilterConverter] instance.
  const FilterConverter();

  /// Converts [Filter] to its SQL-like [String] representation.
  String toSQL(Filter filter) {
    switch (filter.runtimeType) {
      case FilterFacet:
        return _facetToSQL(filter as FilterFacet);
      case FilterTag:
        return _tagToSQL(filter as FilterTag);
      case FilterNumeric:
        return _numericToSQL(filter as FilterNumeric);
      default:
        throw ArgumentError('Filter type ${filter.runtimeType} not supported');
    }
  }

  /// Converts [FilterFacet] to its SQL-like [String] representation.
  String _facetToSQL(FilterFacet filter) {
    final value = _valueToSQL(filter.value);
    final attribute = _escape(filter.attribute);
    final score = filter.score != null ? '<score=${filter.score}>' : '';
    final expression = '$attribute:$value$score';
    return filter.isNegated ? 'NOT $expression' : expression;
  }

  /// Converts [FilterTag] to its SQL-like [String] representation.
  String _tagToSQL(FilterTag filter) {
    final expression = '${filter.value}:${_escape(filter.value)}';
    return filter.isNegated ? 'NOT $expression' : expression;
  }

  /// Converts [FilterNumeric] to its SQL-like [String] representation.
  String _numericToSQL(FilterNumeric filter) {
    switch (filter.value.runtimeType) {
      case NumericRange:
        return _rangeToSQL(
            filter.value as NumericRange, filter.attribute, filter.isNegated);
      case NumericComparison:
        return _comparisonToSQL(filter.value as NumericComparison,
            filter.attribute, filter.isNegated);
      default:
        throw ArgumentError('Filter type ${filter.runtimeType} not supported');
    }
  }

  /// Converts [NumericRange] to its SQL-like [String] representation.
  String _rangeToSQL(NumericRange range, String attribute, bool isNegated) {
    final escapedAttribute = _escape(attribute);
    final lowerBound = range.lowerBound;
    final upperBound = range.upperBound;
    final expression = '$escapedAttribute:$lowerBound TO $upperBound';
    return isNegated ? 'NOT $expression' : expression;
  }

  /// Converts [FilterNumeric] with [NumericComparison] value to its SQL-like
  /// [String] representation.
  String _comparisonToSQL(
    NumericComparison comparison,
    String attribute,
    bool isNegated,
  ) {
    final escapedAttribute = _escape(attribute);
    final operator = comparison.operator.operator;
    final number = comparison.number;
    final expression = '$escapedAttribute $operator $number';
    return isNegated ? 'NOT $expression' : expression;
  }

  /// Converts [value] to its SQL-like [String] representation.
  String _valueToSQL(dynamic value) {
    switch (value.runtimeType) {
      case String:
        return _escape(value as String);
      case num:
      case bool:
        return value.toString();
      default:
        throw ArgumentError('value type ${value.runtimeType} not supported');
    }
  }

  /// String escape [value].
  String _escape(String value) => '\"$value\"';
}
