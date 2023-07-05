import 'package:algoliasearch/algoliasearch_lite.dart' as algolia;
import 'package:logging/logging.dart';

import 'exception.dart';
import 'extensions.dart';
import 'filter_group_converter.dart';
import 'hits_search_service.dart';
import 'lib_version.dart';
import 'logger.dart';
import 'query_builder.dart';
import 'search_response.dart';
import 'search_state.dart';

class AlgoliaHitsSearchService implements HitsSearchService {
  /// Creates [HitsSearchService] instance.
  AlgoliaHitsSearchService({
    required String applicationID,
    required String apiKey,
    required bool disjunctiveFacetingEnabled,
  }) : this.create(
          algolia.SearchClient(
              appId: applicationID,
              apiKey: apiKey,
              options: const algolia.ClientOptions(agentSegments: [
                algolia.AgentSegment(
                  value: 'algolia-helper-dart',
                  version: libVersion,
                )
              ]),),
          disjunctiveFacetingEnabled,
        );

  /// Creates [HitsSearchService] instance.
  AlgoliaHitsSearchService.create(
      this._client, this._disjunctiveFacetingEnabled)
      : _log = algoliaLogger('SearchService');

  /// Search events logger.
  final Logger _log;

  /// Algolia API client
  final algolia.SearchClient _client;

  /// Disjunctive faceting enablement status
  final bool _disjunctiveFacetingEnabled;

  @override
  Future<SearchResponse> search(SearchState state) =>
      _disjunctiveFacetingEnabled
          ? _disjunctiveSearch(state)
          : _singleQuerySearch(state);

  /// Build a single search request using [state] and get a search result.
  Future<SearchResponse> _singleQuerySearch(SearchState state) async {
    _log.fine('Run search with state: $state');
    try {
      final response = await _client.searchIndex(request: state.toRequest());
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

extension AlgolisSearchExt on SearchState {
  algolia.SearchForHits toRequest() {
    final filters = filterGroups?.let(
      (it) => const FilterGroupConverter().sql(it),
    );
    final search = algolia.SearchForHits(
      indexName: indexName,
      analytics: analytics,
      attributesToHighlight: attributesToHighlight,
      attributesToRetrieve: attributesToRetrieve,
      attributesToSnippet: attributesToSnippet,
      facetFilters: facetFilters,
      facets: facets,
      highlightPostTag: highlightPostTag,
      highlightPreTag: highlightPreTag,
      hitsPerPage: hitsPerPage,
      maxFacetHits: maxFacetHits,
      maxValuesPerFacet: maxValuesPerFacet,
      numericFilters: numericFilters,
      optionalFilters: optionalFilters,
      page: page,
      query: query,
      ruleContexts: ruleContexts,
      sumOrFiltersScores: sumOrFiltersScore,
      tagFilters: tagFilters,
      userToken: userToken,
      filters: filters,
      clickAnalytics: clickAnalytics,
    );
    return search;
  }
}

extension AlgoliaSearchResponseExt on algolia.SearchResponse {
  SearchResponse toSearchResponse() => SearchResponse(toJson());
}

/// Extensions over [AlgoliaException].
extension AlgoliaExceptionExt on algolia.AlgoliaApiException {
  /// Converts API error to [SearchError].
  SearchError toSearchError() =>
      SearchError({'message': error.toString()}, statusCode);
}
