import 'package:algoliasearch/algoliasearch.dart' as algolia;
import 'package:logging/logging.dart';

import '../logger.dart';
import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import '../query_builder.dart';
import 'algolia_client_helper.dart';
import 'multi_search_service.dart';

final class AlgoliaMultiSearchService extends MultiSearchService {
  /// Search events logger.
  final Logger _log;

  /// Algolia API client
  final algolia.SearchClient _client;

  AlgoliaMultiSearchService(String applicationID, String apiKey)
      : this.create(algolia.SearchClient(appId: applicationID, apiKey: apiKey));

  AlgoliaMultiSearchService.create(this._client)
      : _log = algoliaLogger('MultiSearchService');

  @override
  Future<List<MultiSearchResponse>> search(
    List<MultiSearchState> states,
  ) async {
    _log.fine('Start multi search: $states');
    final builders = <QueryBuilder?>[];

    final unfoldedRequests = <MultiSearchState>[];

    for (final state in states) {
      switch (state) {
        case SearchState():
          if (state.isDisjunctiveFacetingEnabled) {
            final builder = QueryBuilder(state);
            final queries = builder.build();
            builders.add(builder);
            unfoldedRequests.addAll(queries);
          } else {
            builders.add(null);
            unfoldedRequests.add(state);
          }
        case FacetSearchState():
          unfoldedRequests.add(state);
      }
    }

    final unfoldedResponses = await _client.multiSearch(unfoldedRequests);

    final foldedResponses = <MultiSearchResponse>[];

    while (unfoldedResponses.isNotEmpty) {
      final response = unfoldedResponses.first;
      switch (response) {
        case SearchResponse():
          final builder = builders.removeAt(0);
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
