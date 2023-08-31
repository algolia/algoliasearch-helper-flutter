import 'package:algoliasearch/algoliasearch.dart' as algolia;

import '../exception.dart';
import '../extensions.dart';
import '../filter_group_converter.dart';
import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';

extension ClientHelperAdapter on algolia.SearchClient {
  /// Coerce an [AlgoliaException] to a [SearchError].
  Exception launderException(dynamic error) =>
      error is algolia.AlgoliaApiException
          ? error.toSearchError()
          : Exception(error);
}

/// Extensions over [AlgoliaException].
extension AlgoliaExceptionExt on algolia.AlgoliaApiException {
  /// Converts API error to [SearchError].
  SearchError toSearchError() =>
      SearchError({'message': error.toString()}, statusCode);
}

extension AlgolisSearchStateExt on SearchState {
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

extension AlgolisFacetSearchStateExt on FacetSearchState {
  algolia.SearchForFacets toRequest() {
    final filters = searchState.filterGroups?.let(
      (it) => const FilterGroupConverter().sql(it),
    );
    final search = algolia.SearchForFacets(
      facet: facet,
      facetQuery: facetQuery,
      type: algolia.SearchTypeFacet.facet,
      indexName: searchState.indexName,
      analytics: searchState.analytics,
      attributesToHighlight: searchState.attributesToHighlight,
      attributesToRetrieve: searchState.attributesToRetrieve,
      attributesToSnippet: searchState.attributesToSnippet,
      facetFilters: searchState.facetFilters,
      facets: searchState.facets,
      highlightPostTag: searchState.highlightPostTag,
      highlightPreTag: searchState.highlightPreTag,
      hitsPerPage: searchState.hitsPerPage,
      maxFacetHits: searchState.maxFacetHits,
      maxValuesPerFacet: searchState.maxValuesPerFacet,
      numericFilters: searchState.numericFilters,
      optionalFilters: searchState.optionalFilters,
      page: searchState.page,
      query: searchState.query,
      ruleContexts: searchState.ruleContexts,
      sumOrFiltersScores: searchState.sumOrFiltersScore,
      tagFilters: searchState.tagFilters,
      userToken: searchState.userToken,
      filters: filters,
      clickAnalytics: searchState.clickAnalytics,
    );
    return search;
  }
}

extension AlgoliaFacetSearchResponseExt
    on algolia.SearchForFacetValuesResponse {
  FacetSearchResponse toSearchResponse() => FacetSearchResponse(toJson());
}
