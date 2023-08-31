import 'package:algoliasearch/algoliasearch.dart' as algolia;
import 'package:logging/logging.dart';

import '../lib_version.dart';
import '../logger.dart';
import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import '../query_builder.dart';
import 'algolia_client_extensions.dart';
import 'hits_search_service.dart';

class AlgoliaHitsSearchService implements HitsSearchService {
  /// Creates [HitsSearchService] instance.
  AlgoliaHitsSearchService({
    required String applicationID,
    required String apiKey,
  }) : this.create(
          algolia.SearchClient(
            appId: applicationID,
            apiKey: apiKey,
            options: const algolia.ClientOptions(
              agentSegments: [
                algolia.AgentSegment(
                  value: 'algolia-helper-dart',
                  version: libVersion,
                )
              ],
            ),
          ),
        );

  /// Creates [HitsSearchService] instance.
  AlgoliaHitsSearchService.create(
    this._client,
  ) : _log = algoliaLogger('SearchService');

  /// Search events logger.
  final Logger _log;

  /// Algolia API client
  final algolia.SearchClient _client;

  @override
  Future<SearchResponse> search(SearchState state) =>
      state.isDisjunctiveFacetingEnabled
          ? _disjunctiveSearch(state)
          : _singleQuerySearch(state);

  /// Build a single search request using [state] and get a search result.
  Future<SearchResponse> _singleQuerySearch(SearchState state) async {
    _log.fine('run search with state: $state');
    try {
      final rawResponse = await _client.search(
        searchMethodParams: algolia.SearchMethodParams(
          requests: [
            state.toRequest(),
          ],
        ),
      );
      final response = algolia.SearchResponse.fromJson(
        rawResponse.results.first as Map<String, dynamic>,
      ).toSearchResponse();
      _log.fine('received response: $response');
      return response;
    } catch (exception) {
      _log.severe('exception: $exception');
      throw _client.launderException(exception);
    }
  }

  /// Build multiple search requests using [state] and get a search result.
  Future<SearchResponse> _disjunctiveSearch(SearchState state) async {
    _log.fine('Start disjunctive search: $state');
    try {
      final queryBuilder = QueryBuilder(state);
      final queries = queryBuilder.build().map((it) => it.toRequest()).toList();
      final rawResponses = await _client.searchMultiIndex(
        queries: queries,
      );
      final responses = rawResponses.map((e) => e.toSearchResponse()).toList();
      _log.fine('Search responses: $responses');
      return queryBuilder.merge(responses);
    } catch (exception) {
      _log.severe('Search exception thrown: $exception');
      throw _client.launderException(exception);
    }
  }
}
