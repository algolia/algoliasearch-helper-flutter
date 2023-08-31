part of 'multi_search_state.dart';

/// Represents a search operation state, and an abstraction over search queries.
///
/// ## Example
///
/// ```dart
/// const searchState = SearchState(
///   indexName: 'MY_INDEX_NAME',
///   query: 'shoes',
///   page: 1,
///   hitsPerPage: 20,
///   attributesToRetrieve: ['name', 'description', 'price'],
/// );
/// ```
class SearchState implements MultiSearchState {
  /// Creates [SearchState] instance.
  const SearchState({
    required this.indexName,
    this.analytics,
    this.attributesToHighlight,
    this.attributesToRetrieve,
    this.attributesToSnippet,
    this.disjunctiveFacets,
    this.isDisjunctiveFacetingEnabled = true,
    this.facetFilters,
    this.facets,
    this.filterGroups,
    this.highlightPostTag,
    this.highlightPreTag,
    this.hitsPerPage,
    this.maxFacetHits,
    this.maxValuesPerFacet,
    this.numericFilters,
    this.optionalFilters,
    this.page,
    this.query,
    this.ruleContexts,
    this.sumOrFiltersScore,
    this.tagFilters,
    this.userToken,
    this.clickAnalytics,
  });

  /// Index name
  final String indexName;

  /// Search query string
  final String? query;

  /// Search page number
  final int? page;

  /// Number of hits per page
  final int? hitsPerPage;

  /// Search facets list
  final List<String>? facets;

  /// Disjunctive facets list
  final Set<String>? disjunctiveFacets;

  /// Whether disjunctive faceting is enabled
  final bool isDisjunctiveFacetingEnabled;

  /// Set of filter groups
  final Set<FilterGroup>? filterGroups;

  /// Search rule contexts
  final List<String>? ruleContexts;

  /// Filter hits by facet value.
  final List<String>? facetFilters;

  /// List of attributes to highlight.
  final List<String>? attributesToHighlight;

  /// Gives control over which attributes to retrieve and which not to retrieve.
  final List<String>? attributesToRetrieve;

  /// List of attributes to snippet,
  /// with an optional maximum number of words
  /// to snippet.
  final List<String>? attributesToSnippet;

  /// The HTML name to insert after the highlighted parts in all highlight
  /// and snippet results.
  final String? highlightPostTag;

  /// The HTML name to insert before the highlighted parts in all highlight
  /// and snippet results.
  final String? highlightPreTag;

  /// Maximum number of facet hits to return during a search for facet values.
  final int? maxFacetHits;

  /// Maximum number of facet values to return for each facet during a regular
  /// search.
  final int? maxValuesPerFacet;

  /// Filter on numeric attributes.
  final List<String>? numericFilters;

  /// Create filters for ranking purposes,
  /// where records that match the filter
  /// are ranked highest.
  final List<String>? optionalFilters;

  /// Determines how to calculate the total score for filtering.
  final bool? sumOrFiltersScore;

  /// Filter hits by tags.
  final List<String>? tagFilters;

  /// Associates a certain user token with the current search.
  final String? userToken;

  /// Whether the current query will be taken into account in the Analytics.
  final bool? analytics;

  /// Add a query ID parameter to the response for tracking click and conversion
  /// events.
  final bool? clickAnalytics;

  /// Make a copy of the search state.
  SearchState copyWith({
    List<String>? attributesToHighlight,
    List<String>? attributesToRetrieve,
    List<String>? attributesToSnippet,
    List<String>? facetFilters,
    List<String>? facets,
    List<String>? numericFilters,
    List<String>? optionalFilters,
    List<String>? ruleContexts,
    List<String>? tagFilters,
    Set<FilterGroup>? filterGroups,
    Set<String>? disjunctiveFacets,
    bool? isDisjunctiveFacetingEnabled,
    String? highlightPostTag,
    String? highlightPreTag,
    String? indexName,
    String? query,
    String? userToken,
    bool? analytics,
    bool? sumOrFiltersScore,
    int? hitsPerPage,
    int? maxFacetHits,
    int? maxValuesPerFacet,
    int? page,
    bool? clickAnalytics,
  }) =>
      SearchState(
        attributesToHighlight:
            attributesToHighlight ?? this.attributesToHighlight,
        attributesToRetrieve: attributesToRetrieve ?? this.attributesToRetrieve,
        attributesToSnippet: attributesToSnippet ?? this.attributesToSnippet,
        facetFilters: facetFilters ?? this.facetFilters,
        facets: facets ?? this.facets,
        numericFilters: numericFilters ?? this.numericFilters,
        optionalFilters: optionalFilters ?? this.optionalFilters,
        ruleContexts: ruleContexts ?? this.ruleContexts,
        tagFilters: tagFilters ?? this.tagFilters,
        filterGroups: filterGroups ?? this.filterGroups,
        disjunctiveFacets: disjunctiveFacets ?? this.disjunctiveFacets,
        isDisjunctiveFacetingEnabled:
            isDisjunctiveFacetingEnabled ?? this.isDisjunctiveFacetingEnabled,
        highlightPostTag: highlightPostTag ?? this.highlightPostTag,
        highlightPreTag: highlightPreTag ?? this.highlightPreTag,
        indexName: indexName ?? this.indexName,
        query: query ?? this.query,
        userToken: userToken ?? this.userToken,
        analytics: analytics ?? this.analytics,
        sumOrFiltersScore: sumOrFiltersScore ?? this.sumOrFiltersScore,
        hitsPerPage: hitsPerPage ?? this.hitsPerPage,
        maxFacetHits: maxFacetHits ?? this.maxFacetHits,
        maxValuesPerFacet: maxValuesPerFacet ?? this.maxValuesPerFacet,
        page: page ?? this.page,
        clickAnalytics: clickAnalytics ?? this.clickAnalytics,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchState &&
          runtimeType == other.runtimeType &&
          indexName == other.indexName &&
          query == other.query &&
          page == other.page &&
          hitsPerPage == other.hitsPerPage &&
          facets.equals(other.facets) &&
          disjunctiveFacets.equals(other.disjunctiveFacets) &&
          isDisjunctiveFacetingEnabled
              .equals(other.isDisjunctiveFacetingEnabled) &&
          filterGroups.equals(other.filterGroups) &&
          ruleContexts.equals(other.ruleContexts) &&
          facetFilters.equals(other.facetFilters) &&
          attributesToHighlight.equals(other.attributesToHighlight) &&
          attributesToRetrieve.equals(other.attributesToRetrieve) &&
          attributesToSnippet.equals(other.attributesToSnippet) &&
          highlightPostTag == other.highlightPostTag &&
          highlightPreTag == other.highlightPreTag &&
          maxFacetHits == other.maxFacetHits &&
          maxValuesPerFacet == other.maxValuesPerFacet &&
          numericFilters.equals(other.numericFilters) &&
          optionalFilters.equals(other.optionalFilters) &&
          sumOrFiltersScore == other.sumOrFiltersScore &&
          tagFilters.equals(other.tagFilters) &&
          analytics == other.analytics &&
          userToken == other.userToken &&
          clickAnalytics == other.clickAnalytics;

  @override
  int get hashCode =>
      indexName.hashCode ^
      query.hashCode ^
      page.hashCode ^
      hitsPerPage.hashCode ^
      facets.hashing() ^
      disjunctiveFacets.hashing() ^
      isDisjunctiveFacetingEnabled.hashing() ^
      filterGroups.hashing() ^
      ruleContexts.hashing() ^
      facetFilters.hashing() ^
      attributesToHighlight.hashing() ^
      attributesToRetrieve.hashing() ^
      attributesToSnippet.hashing() ^
      highlightPostTag.hashCode ^
      highlightPreTag.hashCode ^
      maxFacetHits.hashCode ^
      maxValuesPerFacet.hashCode ^
      numericFilters.hashing() ^
      optionalFilters.hashing() ^
      sumOrFiltersScore.hashCode ^
      tagFilters.hashing() ^
      analytics.hashCode ^
      userToken.hashCode ^
      clickAnalytics.hashCode;

  @override
  String toString() => 'SearchState{'
      'indexName: $indexName, '
      'query: $query, '
      'analytics: $analytics, '
      'attributesToHighlight: $attributesToHighlight, '
      'attributesToRetrieve: $attributesToRetrieve, '
      'attributesToSnippet: $attributesToSnippet, '
      'disjunctiveFacets: $disjunctiveFacets, '
      'isDisjunctiveFacetingEnabled: $isDisjunctiveFacetingEnabled, '
      'facetFilters: $facetFilters, '
      'facets: $facets, '
      'filterGroups: $filterGroups, '
      'highlightPostTag: $highlightPostTag, '
      'highlightPreTag: $highlightPreTag, '
      'hitsPerPage: $hitsPerPage, '
      'maxFacetHits: $maxFacetHits, '
      'maxValuesPerFacet: $maxValuesPerFacet, '
      'numericFilters: $numericFilters, '
      'optionalFilters: $optionalFilters, '
      'page: $page, '
      'ruleContexts: $ruleContexts, '
      'sumOrFiltersScore: $sumOrFiltersScore, '
      'tagFilters: $tagFilters, '
      'userToken: $userToken, '
      'clickAnalytics: $clickAnalytics}';
}
