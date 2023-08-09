import '../../algolia_helper.dart';

class SearchRequest<State extends MultiSearchState> {
  /// Creates [SearchRequest] instance.
  SearchRequest(this.state, [this.attempts = 1]);

  /// Search state query
  final State state;

  /// Count of query attempts
  final int attempts;

  /// Create a copy with given parameters.
  SearchRequest<State> copyWith({
    State? state,
    int? attempts,
  }) =>
      SearchRequest(
        state ?? this.state,
        attempts ?? this.attempts,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchRequest &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          attempts == other.attempts;

  @override
  int get hashCode => state.hashCode ^ attempts.hashCode;

  @override
  String toString() => 'SearchRequest{state: $state, attempt: $attempts}';
}
