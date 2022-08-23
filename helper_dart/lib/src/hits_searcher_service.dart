import 'package:algolia/algolia.dart';
import 'package:logging/logging.dart';

import 'exception.dart';
import 'logger.dart';
import 'query_builder.dart';
import 'search_response.dart';
import 'search_state.dart';
import 'utils.dart';

/// Service handling search requests.
class HitsSearchService {
  HitsSearchService(this.client, this.disjunctiveFacetingEnabled)
      : _log = defaultLogger;

  final Algolia client;
  final bool disjunctiveFacetingEnabled;
  final Logger _log;

  /// Search responses as a stream.
  Stream<SearchResponse> search(SearchState state) =>
      Stream.fromFuture(_search(state));

  /// Run search query using [state] and get a search result.
  Future<SearchResponse> _search(SearchState state) =>
      disjunctiveFacetingEnabled
          ? _disjunctiveSearch(state)
          : _singleQuerySearch(state);

  /// Build a single search request using [state] and get a search result.
  Future<SearchResponse> _singleQuerySearch(SearchState state) async {
    _log.fine('Run search with state: $state');
    try {
      final response = await client.queryOf(state).getObjects();
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
      final queries = queryBuilder.build().map(client.queryOf).toList();
      final responses =
          await client.multipleQueries.addQueries(queries).getObjects();
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
    state.query?.let((it) => query = query.query(it));
    state.page?.let((it) => query = query.setPage(it));
    state.hitsPerPage?.let((it) => query = query.setHitsPerPage(it));
    state.query?.let((it) => query = query.query(it));
    state.facets?.let((it) => query = query.setFacets(it));
    state.ruleContexts?.let((it) => query = query.setRuleContexts(it));

    state.query?.let((it) => query = query.query(it));
    state.page?.let((it) => query = query.setPage(it));
    state.hitsPerPage?.let((it) => query = query.setHitsPerPage(it));
    state.facets?.let((it) => query = query.setFacets(it));
    state.filterGroups?.let((it) => query = query.setFilterGroups(it));
    state.ruleContexts?.let((it) => query = query.setRuleContexts(it));
    state.facetFilters?.let((it) => query = query.setFacetFilters(it));
    state.advancedSyntax
        ?.let((it) => query = query.setAdvancedSyntax(enabled: it));
    state.allowTyposOnNumericTokens
        ?.let((it) => query = query.setAllowTyposOnNumericTokens(it));
    state.analytics?.let((it) => query = query.setAnalytics(enabled: it));
    state.analyticsTags?.let((it) => query = query.setAnalyticsTags(it));
    state.aroundLatLng?.let((it) => query = query.setAroundLatLng(it));
    state.aroundLatLngViaIP
        ?.let((it) => query = query.setAroundLatLngViaIP(it));
    state.aroundPrecision?.let((it) => query = query.setAroundPrecision(it));
    state.aroundRadius?.let((it) => query = query.setAroundRadius(it));
    state.attributesToHighlight
        ?.let((it) => query = query.setAttributesToHighlight(it));
    state.attributesToRetrieve
        ?.let((it) => query = query.setAttributesToRetrieve(it));
    state.attributesToSnippet
        ?.let((it) => query = query.setAttributesToSnippet(it));
    state.clickAnalytics
        ?.let((it) => query = query.setClickAnalytics(enabled: it));
    state.disableExactOnAttributes
        ?.let((it) => query = query.setDisableExactOnAttributes(it));
    state.disableTypoToleranceOnAttributes
        ?.let((it) => query = query.setDisableTypoToleranceOnAttributes(it));
    state.distinct?.let((it) => query = query.setDistinct(value: it));
    state.enableABTest?.let((it) => query = query.setEnableABTest(enabled: it));
    state.enablePersonalization
        ?.let((it) => query = query.setEnablePersonalization(enabled: it));
    state.enableRules?.let((it) => query = query.setEnableRules(enabled: it));
    state.facetingAfterDistinct
        ?.let((it) => query = query.setFacetingAfterDistinct(enable: it));
    state.getRankingInfo
        ?.let((it) => query = query.setGetRankingInfo(enabled: it));
    state.highlightPostTag?.let((it) => query = query.setHighlightPostTag(it));
    state.highlightPreTag?.let((it) => query = query.setHighlightPreTag(it));
    state.ignorePlurals?.let((it) => query = query.setIgnorePlurals(it));
    state.length?.let((it) => query = query.setLength(it));
    state.maxFacetHits?.let((it) => query = query.setMaxFacetHits(it));
    state.maxValuesPerFacet
        ?.let((it) => query = query.setMaxValuesPerFacet(it));
    state.minWordSizeFor1Typo
        ?.let((it) => query = query.setMinWordSizeFor1Typo(it));
    state.minWordSizeFor2Typos
        ?.let((it) => query = query.setMinWordSizeFor2Typos(it));
    state.minimumAroundRadius
        ?.let((it) => query = query.setMinimumAroundRadius(it));
    state.naturalLanguages?.let((it) => query = query.setNaturalLanguages(it));
    state.numericFilters?.let((it) => query = query.setNumericFilters(it));
    state.offset?.let((it) => query = query.setOffset(it));
    state.optionalFilters?.let((it) => query = query.setOptionalFilters(it));
    state.percentileComputation
        ?.let((it) => query = query.setPercentileComputation(enabled: it));
    state.personalizationImpact
        ?.let((it) => query = query.setPersonalizationImpact(value: it));
    state.queryLanguages?.let((it) => query = query.setQueryLanguages(it));
    state.removeStopWords?.let((it) => query = query.setRemoveStopWords(it));
    state.replaceSynonymsInHighlight
        ?.let((it) => query = query.setReplaceSynonymsInHighlight(enabled: it));
    state.restrictHighlightAndSnippetArrays?.let(
        (it) => query = query.setRestrictHighlightAndSnippetArrays(enable: it));
    state.restrictSearchableAttributes
        ?.let((it) => query = query.setRestrictSearchableAttributes(it));
    state.similarQuery?.let((it) => query = query.setSimilarQuery(it));
    state.snippetEllipsisText
        ?.let((it) => query = query.setSnippetEllipsisText(it));
    state.sumOrFiltersScore
        ?.let((it) => query = query.setSumOrFiltersScore(it));
    state.synonyms?.let((it) => query = query.setSynonyms(enabled: it));
    state.tagFilters?.let((it) => query = query.setTagFilters(it));
    state.typoTolerance?.let((it) => query = query.setTypoTolerance(it));
    state.userToken?.let((it) => query = query.setUserToken(it));
    return query;
  }

  /// Create multiple queries from search
  AlgoliaMultiIndexesReference multipleQueriesOf(SearchState state) =>
      multipleQueries
        ..addQueries(
          QueryBuilder(state).build().map(queryOf).toList(),
        );
}

extension AlgoliaQueryExt on AlgoliaQuery {
  /// Filter hits by facet value
  AlgoliaQuery setFacetFilters(List<String> facetFilters) {
    var query = this;
    for (var facetList in facetFilters) {
      query = query.facetFilter(facetList);
    }
    return query;
  }

  AlgoliaQuery setNumericFilters(List<String> numericFilters) {
    var query = this;
    for (var numericFilter in numericFilters) {
      query = query.setNumericFilter(numericFilter);
    }
    return query;
  }

  AlgoliaQuery setOptionalFilters(List<String> optionalFilters) {
    var query = this;
    for (var optionalFilter in optionalFilters) {
      query = query.setOptionalFilter(optionalFilter);
    }
    return query;
  }
}

/// Extensions over [AlgoliaQuerySnapshot].
extension AlgoliaQuerySnapshotExt on AlgoliaQuerySnapshot {
  SearchResponse toSearchResponse() => SearchResponse(toMap());
}

/// Extensions over a list of [AlgoliaQuerySnapshot].
extension ListAlgoliaQuerySnapshotExt on List<AlgoliaQuerySnapshot> {
  SearchResponse toSearchResponseFor(SearchState state) =>
      QueryBuilder(state).merge(map((e) => e.toSearchResponse()).toList());
}

/// Extensions over [AlgoliaError].
extension AlgoliaErrorExt on AlgoliaError {
  SearchError toSearchError() => SearchError(error, statusCode);
}
