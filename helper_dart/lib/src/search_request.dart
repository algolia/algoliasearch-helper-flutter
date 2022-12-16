import 'search_state.dart';

class SearchRequest {
  /// Creates [SearchRequest] instance.
  SearchRequest(this.state, [this.attempts = 1]);

  /// Search state query
  final SearchState state;

  /// Count of query attempts
  final int attempts;

  /// Create a copy with given parameters.
  SearchRequest copyWith({
    SearchState? state,
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
