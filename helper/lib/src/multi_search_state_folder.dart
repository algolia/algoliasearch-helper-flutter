import 'model/multi_search_response.dart';
import 'model/multi_search_state.dart';
import 'query_builder.dart';

/// `MultiSearchStateFolder` is responsible for handling the folding and
/// unfolding processes within multiple search operations, specifically taking
/// into account disjunctive faceting. Disjunctive faceting is a search strategy
/// where facets are combined using an OR logic, and this class manages the
/// transformation of search states and responses to accommodate this strategy.
/// It efficiently handles the unfolding of states into sub-queries and the
/// folding of responses into a unified format.
final class MultiSearchStateFolder {
  final List<QueryBuilder?> _queryBuilders = [];

  /// Creates a new instance of `MultiSearchStateFolder`.
  MultiSearchStateFolder();

  /// Unfolds the given list of `MultiSearchState` instances into a list
  /// that may include sub-queries, considering factors such as disjunctive
  /// faceting. It expands the search states into a format that can be processed
  /// further.
  ///
  /// - Parameters:
  ///   - states: The list of `MultiSearchState` instances to unfold.
  /// - Returns: An extended list of `MultiSearchState` instances.
  List<MultiSearchState> unfoldStates(List<MultiSearchState> states) {
    final unfoldedRequests = <MultiSearchState>[];

    for (final state in states) {
      switch (state) {
        case SearchState():
          if (state.isDisjunctiveFacetingEnabled) {
            final builder = QueryBuilder(state);
            final queries = builder.build();
            _queryBuilders.add(builder);
            unfoldedRequests.addAll(queries);
          } else {
            _queryBuilders.add(null);
            unfoldedRequests.add(state);
          }
        case FacetSearchState():
          unfoldedRequests.add(state);
      }
    }
    return unfoldedRequests;
  }

  /// Folds the given list of `MultiSearchResponse` instances into a unified
  /// and compact form, merging responses where necessary, considering
  /// disjunctive faceting. It translates the individual responses into a single
  /// coherent structure.
  ///
  /// - Parameters:
  ///   - unfoldedResponses: The list of `MultiSearchResponse` instances to fold
  /// - Returns: A reduced list of `MultiSearchResponse` instances.
  List<MultiSearchResponse> foldResponses(
    List<MultiSearchResponse> unfoldedResponses,
  ) {
    final foldedResponses = <MultiSearchResponse>[];
    while (unfoldedResponses.isNotEmpty) {
      final response = unfoldedResponses.first;
      switch (response) {
        case SearchResponse():
          final builder = _queryBuilders.removeAt(0);
          if (builder != null) {
            final queriesCount = builder.totalQueriesCount;
            final currentUnfoldedResponses = unfoldedResponses
                .sublist(0, queriesCount)
                .map((e) => e as SearchResponse)
                .toList();
            final mergedResponse = builder.merge(currentUnfoldedResponses);
            foldedResponses.add(mergedResponse);
            unfoldedResponses.removeRange(0, queriesCount);
          } else {
            foldedResponses.add(response);
            unfoldedResponses.removeAt(0);
          }
        case FacetSearchResponse():
          foldedResponses.add(response);
          unfoldedResponses.removeAt(0);
      }
    }
    return foldedResponses;
  }
}
