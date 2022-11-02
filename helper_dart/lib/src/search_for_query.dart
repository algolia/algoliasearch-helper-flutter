import 'search_state.dart';

/// Search query execution condition logic.
abstract class SearchCondition {
  /// Search trigger logic. Return `true` to run search operations.
  bool isValid(SearchState state);

  /// Trigger search depending on [condition] result.
  const factory SearchCondition(StateCondition condition) = _ConditionCustom;

  /// Trigger search for all queries. No conditions applied.
  const factory SearchCondition.none() = _ConditionNone;

  /// Trigger if the query length is greater or equals to [length].
  const factory SearchCondition.lengthAtLeast(int length) = _ConditionLength;
}

/// Checks whether a [state] stratifies a condition.
typedef StateCondition = bool Function(SearchState state);

/// Trigger search for all queries.
class _ConditionNone implements SearchCondition {
  const _ConditionNone();

  @override
  bool isValid(SearchState state) => true;
}

/// Trigger if the query length is greater or equals to [length].
class _ConditionLength implements SearchCondition {
  const _ConditionLength(this.length);

  final int length;

  @override
  bool isValid(SearchState state) => (state.query?.length ?? 0) >= length;
}

/// Trigger search condition depending on [condition] result.
class _ConditionCustom implements SearchCondition {
  const _ConditionCustom(this.condition);

  final StateCondition condition;

  @override
  bool isValid(SearchState state) => condition(state);
}
