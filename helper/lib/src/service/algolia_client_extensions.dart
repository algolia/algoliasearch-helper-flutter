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
      filters: filters,
      query: query,
      similarQuery: similarQuery,
      facetFilters: facetFilters,
      optionalFilters: optionalFilters,
      numericFilters: numericFilters,
      tagFilters: tagFilters,
      sumOrFiltersScores: sumOrFiltersScores,
      restrictSearchableAttributes: restrictSearchableAttributes,
      facets: facets,
      facetingAfterDistinct: facetingAfterDistinct,
      page: page,
      offset: offset,
      length: length,
      aroundLatLng: aroundLatLng,
      aroundLatLngViaIP: aroundLatLngViaIP,
      aroundRadius: aroundRadius,
      aroundPrecision: aroundPrecision,
      minimumAroundRadius: minimumAroundRadius,
      insideBoundingBox: insideBoundingBox,
      insidePolygon: insidePolygon,
      naturalLanguages: naturalLanguages,
      ruleContexts: ruleContexts,
      personalizationImpact: personalizationImpact,
      userToken: userToken,
      getRankingInfo: getRankingInfo,
      synonyms: synonyms,
      clickAnalytics: clickAnalytics,
      analytics: analytics,
      analyticsTags: analyticsTags,
      percentileComputation: percentileComputation,
      enableABTest: enableABTest,
      attributesToRetrieve: attributesToRetrieve,
      ranking: ranking,
      relevancyStrictness: relevancyStrictness,
      attributesToHighlight: attributesToHighlight,
      attributesToSnippet: attributesToSnippet,
      highlightPreTag: highlightPreTag,
      highlightPostTag: highlightPostTag,
      snippetEllipsisText: snippetEllipsisText,
      restrictHighlightAndSnippetArrays: restrictHighlightAndSnippetArrays,
      hitsPerPage: hitsPerPage,
      minWordSizefor1Typo: minWordSizefor1Typo,
      minWordSizefor2Typos: minWordSizefor2Typos,
      typoTolerance: typoTolerance,
      allowTyposOnNumericTokens: allowTyposOnNumericTokens,
      disableTypoToleranceOnAttributes: disableTypoToleranceOnAttributes,
      ignorePlurals: ignorePlurals,
      removeStopWords: removeStopWords,
      queryLanguages: queryLanguages,
      decompoundQuery: decompoundQuery,
      enableRules: enableRules,
      enablePersonalization: enablePersonalization,
      queryType: queryType,
      removeWordsIfNoResults: removeWordsIfNoResults,
      mode: mode,
      semanticSearch: semanticSearch,
      advancedSyntax: advancedSyntax,
      optionalWords: optionalWords,
      disableExactOnAttributes: disableExactOnAttributes,
      exactOnSingleWordQuery: exactOnSingleWordQuery,
      alternativesAsExact: alternativesAsExact,
      advancedSyntaxFeatures: advancedSyntaxFeatures,
      distinct: distinct,
      replaceSynonymsInHighlight: replaceSynonymsInHighlight,
      minProximity: minProximity,
      responseFields: responseFields,
      maxValuesPerFacet: maxValuesPerFacet,
      sortFacetValuesBy: sortFacetValuesBy,
      attributeCriteriaComputedByMinProximity:
          attributeCriteriaComputedByMinProximity,
      renderingContent: renderingContent,
      enableReRanking: enableReRanking,
      reRankingApplyFilter: reRankingApplyFilter,
      indexName: indexName,
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
      filters: filters,
      query: searchState.query,
      similarQuery: searchState.similarQuery,
      facetFilters: searchState.facetFilters,
      optionalFilters: searchState.optionalFilters,
      numericFilters: searchState.numericFilters,
      tagFilters: searchState.tagFilters,
      sumOrFiltersScores: searchState.sumOrFiltersScores,
      restrictSearchableAttributes: searchState.restrictSearchableAttributes,
      facets: searchState.facets,
      facetingAfterDistinct: searchState.facetingAfterDistinct,
      page: searchState.page,
      offset: searchState.offset,
      length: searchState.length,
      aroundLatLng: searchState.aroundLatLng,
      aroundLatLngViaIP: searchState.aroundLatLngViaIP,
      aroundRadius: searchState.aroundRadius,
      aroundPrecision: searchState.aroundPrecision,
      minimumAroundRadius: searchState.minimumAroundRadius,
      insideBoundingBox: searchState.insideBoundingBox,
      insidePolygon: searchState.insidePolygon,
      naturalLanguages: searchState.naturalLanguages,
      ruleContexts: searchState.ruleContexts,
      personalizationImpact: searchState.personalizationImpact,
      userToken: searchState.userToken,
      getRankingInfo: searchState.getRankingInfo,
      synonyms: searchState.synonyms,
      clickAnalytics: searchState.clickAnalytics,
      analytics: searchState.analytics,
      analyticsTags: searchState.analyticsTags,
      percentileComputation: searchState.percentileComputation,
      enableABTest: searchState.enableABTest,
      attributesToRetrieve: searchState.attributesToRetrieve,
      ranking: searchState.ranking,
      relevancyStrictness: searchState.relevancyStrictness,
      attributesToHighlight: searchState.attributesToHighlight,
      attributesToSnippet: searchState.attributesToSnippet,
      highlightPreTag: searchState.highlightPreTag,
      highlightPostTag: searchState.highlightPostTag,
      snippetEllipsisText: searchState.snippetEllipsisText,
      restrictHighlightAndSnippetArrays:
          searchState.restrictHighlightAndSnippetArrays,
      hitsPerPage: searchState.hitsPerPage,
      minWordSizefor1Typo: searchState.minWordSizefor1Typo,
      minWordSizefor2Typos: searchState.minWordSizefor2Typos,
      typoTolerance: searchState.typoTolerance,
      allowTyposOnNumericTokens: searchState.allowTyposOnNumericTokens,
      disableTypoToleranceOnAttributes:
          searchState.disableTypoToleranceOnAttributes,
      ignorePlurals: searchState.ignorePlurals,
      removeStopWords: searchState.removeStopWords,
      queryLanguages: searchState.queryLanguages,
      decompoundQuery: searchState.decompoundQuery,
      enableRules: searchState.enableRules,
      enablePersonalization: searchState.enablePersonalization,
      queryType: searchState.queryType,
      removeWordsIfNoResults: searchState.removeWordsIfNoResults,
      mode: searchState.mode,
      semanticSearch: searchState.semanticSearch,
      advancedSyntax: searchState.advancedSyntax,
      optionalWords: searchState.optionalWords,
      disableExactOnAttributes: searchState.disableExactOnAttributes,
      exactOnSingleWordQuery: searchState.exactOnSingleWordQuery,
      alternativesAsExact: searchState.alternativesAsExact,
      advancedSyntaxFeatures: searchState.advancedSyntaxFeatures,
      distinct: searchState.distinct,
      replaceSynonymsInHighlight: searchState.replaceSynonymsInHighlight,
      minProximity: searchState.minProximity,
      responseFields: searchState.responseFields,
      maxValuesPerFacet: searchState.maxValuesPerFacet,
      sortFacetValuesBy: searchState.sortFacetValuesBy,
      attributeCriteriaComputedByMinProximity:
          searchState.attributeCriteriaComputedByMinProximity,
      renderingContent: searchState.renderingContent,
      enableReRanking: searchState.enableReRanking,
      reRankingApplyFilter: searchState.reRankingApplyFilter,
      indexName: searchState.indexName,
      maxFacetHits: searchState.maxFacetHits,
    );
    return search;
  }
}

extension AlgoliaFacetSearchResponseExt
    on algolia.SearchForFacetValuesResponse {
  FacetSearchResponse toSearchResponse() => FacetSearchResponse(toJson());
}
