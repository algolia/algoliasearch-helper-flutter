import 'package:collection/collection.dart';

import 'filter.dart';
import 'filter_group.dart';

/// Converts [FilterGroup] to an SQL like syntax.
class FilterGroupConverter {
  /// Creates [FilterGroupConverter] instance.
  const FilterGroupConverter();

  /// Converts [FilterGroup] to its SQL-like [String] representation.
  /// Returns `null` if the list is empty.
  String? sql(Set<FilterGroup> filterGroups) {
    final groups = filterGroups.whereNot((element) => element.isEmpty);
    if (groups.isEmpty) return null;
    return groups.map(_sqlGroup).join(' AND ');
  }

  /// Same as [sql], but removes quotes for readability purposes.
  String? unquoted(Set<FilterGroup<Filter>> filterGroups) =>
      sql(filterGroups)?.replaceAll('"', '');

  /// Convert a filter group to an SQL-like syntax
  String _sqlGroup(FilterGroup<Filter> group) {
    final sql = group
        .map((filter) => const FilterConverter().sql(filter))
        .join(_separatorOf(group));
    return '($sql)';
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
  String sql(Filter filter) {
    switch (filter) {
      case FilterFacet():
        return _sqlFacet(filter);
      case FilterTag():
        return _sqlTag(filter);
      case FilterNumeric():
        return _sqlNumeric(filter);
    }
  }

  /// Converts [FilterFacet] to its SQL-like [String] representation.
  String _sqlFacet(FilterFacet filter) {
    final value = _sqlValue(filter.value);
    final attribute = _escape(filter.attribute);
    final score = filter.score != null ? '<score=${filter.score}>' : '';
    final expression = '$attribute:$value$score';
    return filter.isNegated ? 'NOT $expression' : expression;
  }

  /// Converts [FilterTag] to its SQL-like [String] representation.
  String _sqlTag(FilterTag filter) {
    final attribute = filter.attribute;
    final escapedValue = _escape(filter.value);
    final expression = '$attribute:$escapedValue';
    return filter.isNegated ? 'NOT $expression' : expression;
  }

  /// Converts [FilterNumeric] to its SQL-like [String] representation.
  String _sqlNumeric(FilterNumeric filter) {
    var value = filter.value;
    switch (value) {
      case NumericRange():
        return _sqlRange(
          value,
          filter.attribute,
          filter.isNegated,
        );
      case NumericComparison():
        return _sqlComparison(
          value,
          filter.attribute,
          filter.isNegated,
        );
      default:
        throw ArgumentError('Filter type ${filter.runtimeType} not supported');
    }
  }

  /// Converts [NumericRange] to its SQL-like [String] representation.
  String _sqlRange(NumericRange range, String attribute, bool isNegated) {
    final escapedAttribute = _escape(attribute);
    final lowerBound = range.lowerBound;
    final upperBound = range.upperBound;
    final expression = '$escapedAttribute:$lowerBound TO $upperBound';
    return isNegated ? 'NOT $expression' : expression;
  }

  /// Converts [FilterNumeric] with [NumericComparison] value to its SQL-like
  /// [String] representation.
  String _sqlComparison(
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
  String _sqlValue(dynamic value) {
    switch (value) {
      case String():
        return _escape(value);
      case int():
      case double():
      case bool():
        return value.toString();
      default:
        throw ArgumentError('value type ${value.runtimeType} not supported');
    }
  }

  /// String escape [value].
  String _escape(String value) => '"$value"';
}
