import 'package:logging/logging.dart';

import 'exception.dart';
import 'extensions.dart';
import 'filter_group.dart';
import 'filter_group_converter.dart';
import 'logger.dart';
import 'query_builder.dart';
import 'search_response.dart';
import 'search_state.dart';

/// A contract search Service handling search requests and responses.
abstract class HitsSearchService {
  /// Send a search request [state] and asynchronously get a [SearchResponse].
  Future<SearchResponse> search(SearchState state);
}
/*
/// Implementation of [HitsSearchService] using [Algolia] client.
class AlgoliaSearchService implements HitsSearchService {
  /// Creates [HitsSearchService] instance.
  AlgoliaSearchService({
    required String applicationID,
    required String apiKey,
    required List<String> extraUserAgents,
    required bool disjunctiveFacetingEnabled,
  }) : this.create(
          Algolia.init(
            applicationId: applicationID,
            apiKey: apiKey,
            extraUserAgents: extraUserAgents,
          ),
          disjunctiveFacetingEnabled,
        );

  /// Creates [HitsSearchService] instance.
  AlgoliaSearchService.create(this._client, this._disjunctiveFacetingEnabled)
      : _log = algoliaLogger('SearchService');

  /// Algolia API client
  final Algolia _client;

  /// Disjunctive faceting enablement status
  final bool _disjunctiveFacetingEnabled;

  /// Search events logger.
  final Logger _log;

  /// Run search query using [state] and get a search result.
  @override
  Future<SearchResponse> search(SearchState state) =>
      _disjunctiveFacetingEnabled
          ? _disjunctiveSearch(state)
          : _singleQuerySearch(state);

  /// Build a single search request using [state] and get a search result.
  Future<SearchResponse> _singleQuerySearch(SearchState state) async {
    _log.fine('Run search with state: $state');
    try {
      final response = await _client.queryOf(state).getObjects();
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
      final queries = queryBuilder.build().map(_client.queryOf).toList();
      final responses =
          await _client.multipleQueries.addQueries(queries).getObjects();
      _log.fine('Search responses: $responses');
      return queryBuilder
          .merge(responses.map((r) => r.toSearchResponse()).toList());
    } catch (exception) {
      _log.severe('Search exception thrown: $exception');
      throw _launderException(exception);
    }
  }

  /// Coerce an [AlgoliaError] to a [SearchError].
  Exception _launderException(error) =>
      error is AlgoliaError ? error.toSearchError() : Exception(error);
}

/// Extensions over [Algolia] client.
extension AlgoliaExt on Algolia {
  /// Create [AlgoliaQuery] instance based on [state].
  AlgoliaQuery queryOf(SearchState state) {
    AlgoliaQuery query = index(state.indexName);
    state.analytics?.let((it) => query = query.setAnalytics(enabled: it));
    state.attributesToHighlight
        ?.let((it) => query = query.setAttributesToHighlight(it));
    state.attributesToRetrieve
        ?.let((it) => query = query.setAttributesToRetrieve(it));
    state.attributesToSnippet
        ?.let((it) => query = query.setAttributesToSnippet(it));
    state.facetFilters?.let((it) => query = query.setFacetFilters(it));
    state.facets?.let((it) => query = query.setFacets(it));
    state.highlightPostTag?.let((it) => query = query.setHighlightPostTag(it));
    state.highlightPreTag?.let((it) => query = query.setHighlightPreTag(it));
    state.hitsPerPage?.let((it) => query = query.setHitsPerPage(it));
    state.maxFacetHits?.let((it) => query = query.setMaxFacetHits(it));
    state.maxValuesPerFacet
        ?.let((it) => query = query.setMaxValuesPerFacet(it));
    state.numericFilters?.let((it) => query = query.setNumericFilters(it));
    state.optionalFilters?.let((it) => query = query.setOptionalFilters(it));
    state.page?.let((it) => query = query.setPage(it));
    state.query?.let((it) => query = query.query(it));
    state.ruleContexts?.let((it) => query = query.setRuleContexts(it));
    state.sumOrFiltersScore
        ?.let((it) => query = query.setSumOrFiltersScore(it));
    state.tagFilters?.let((it) => query = query.setTagFilters(it));
    state.userToken?.let((it) => query = query.setUserToken(it));
    state.filterGroups?.let((it) => query = query.setFilterGroups(it));
    state.clickAnalytics
        ?.let((it) => query = query.setClickAnalytics(enabled: it));
    return query;
  }

  /// Create multiple queries from search
  AlgoliaMultiIndexesReference multipleQueriesOf(SearchState state) =>
      multipleQueries
        ..addQueries(
          QueryBuilder(state).build().map(queryOf).toList(),
        );
}

/// Extensions over [AlgoliaQuery].
extension AlgoliaQueryExt on AlgoliaQuery {
  /// Filter hits by facet value.
  AlgoliaQuery setFacetFilters(List<String> facetFilters) {
    var query = this;
    for (var facetList in facetFilters) {
      query = query.facetFilter(facetList);
    }
    return query;
  }

  /// Filter on numeric attributes.
  AlgoliaQuery setNumericFilters(List<String> numericFilters) {
    var query = this;
    for (var numericFilter in numericFilters) {
      query = query.setNumericFilter(numericFilter);
    }
    return query;
  }

  /// Create filters for ranking purposes, where records that match the filter
  /// are ranked highest.
  AlgoliaQuery setOptionalFilters(List<String> optionalFilters) {
    var query = this;
    for (var optionalFilter in optionalFilters) {
      query = query.setOptionalFilter(optionalFilter);
    }
    return query;
  }

  /// Filter hits by tags.
  AlgoliaQuery setTagFilters(List<String> tagFilters) {
    var query = this;
    for (var tagFilter in tagFilters) {
      query = query.setTagFilter(tagFilter);
    }
    return query;
  }

  /// Set filters as SQL-like [String] representation.
  AlgoliaQuery setFilterGroups(Set<FilterGroup> filterGroups) {
    final sql = const FilterGroupConverter().sql(filterGroups);
    return sql != null ? filters(sql) : this;
  }
}

/// Extensions over [AlgoliaQuerySnapshot].
extension AlgoliaQuerySnapshotExt on AlgoliaQuerySnapshot {
  /// Converts API response to [SearchResponse].
  SearchResponse toSearchResponse() => SearchResponse(toMap());
}

/// Extensions over [AlgoliaError].
extension AlgoliaErrorExt on AlgoliaError {
  /// Converts API error to [SearchError].
  SearchError toSearchError() => SearchError(error, statusCode);
}
*/