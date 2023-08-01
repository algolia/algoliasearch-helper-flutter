import 'package:algoliasearch/algoliasearch.dart' as algolia;
import 'package:logging/logging.dart';

import '../exception.dart';
import '../lib_version.dart';
import '../logger.dart';
import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import '../query_builder.dart';
import 'algolia_client_helper.dart';
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
    _log.fine('Run search with state: $state');
    try {
      final result = await _client.post(
        path: '/indexes/*/queries',
        body: algolia.SearchMethodParams(requests: [state.toRequest()]),
      );
      final results = (result as Map)['results'] as List<Map<String, dynamic>>;
      final response = algolia.SearchResponse.fromJson(
        results.first,
      );
      _log.fine('Search response: $response');
      return response.toSearchResponse();
    } catch (exception) {
      _log.severe('Search exception: $exception');
      throw _launderException(exception);
    }
  }

  /// Build multiple search requests using [state] and get a search result.
  Future<SearchResponse> _disjunctiveSearch(SearchState state) async {
    _log.fine('Start disjunctive search: $state');
    try {
      final queryBuilder = QueryBuilder(state);
      final queries = queryBuilder.build().map((it) => it.toRequest()).toList();
      final responses = await _client.searchMultiIndex(
        queries: queries,
      );
      _log.fine('Search responses: $responses');
      return queryBuilder
          .merge(responses.results.map((r) => r.toSearchResponse()).toList());
    } catch (exception) {
      _log.severe('Search exception thrown: $exception');
      throw _launderException(exception);
    }
  }

  /// Coerce an [AlgoliaException] to a [SearchError].
  Exception _launderException(error) => error is algolia.AlgoliaApiException
      ? error.toSearchError()
      : Exception(error);
}
