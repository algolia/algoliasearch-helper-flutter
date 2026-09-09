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
    // From https://github.com/algolia/algoliasearch-client-dart/blob/8af282c763eed34cca11bec968518a8ffa0011d2/packages/client_search/lib/src/model/search_for_facets.dart
    // Without: params, filters, facet, facetQuery, type
    this.query,
    this.similarQuery,
    this.facetFilters,
    this.optionalFilters,
    this.numericFilters,
    this.tagFilters,
    this.sumOrFiltersScores,
    this.restrictSearchableAttributes,
    this.facets,
    this.facetingAfterDistinct,
    this.page,
    this.offset,
    this.length,
    this.aroundLatLng,
    this.aroundLatLngViaIP,
    this.aroundRadius,
    this.aroundPrecision,
    this.minimumAroundRadius,
    this.insideBoundingBox,
    this.insidePolygon,
    this.naturalLanguages,
    this.ruleContexts,
    this.personalizationImpact,
    this.userToken,
    this.getRankingInfo,
    this.synonyms,
    this.clickAnalytics,
    this.analytics,
    this.analyticsTags,
    this.percentileComputation,
    this.enableABTest,
    this.attributesToRetrieve,
    this.ranking,
    this.relevancyStrictness,
    this.attributesToHighlight,
    this.attributesToSnippet,
    this.highlightPreTag,
    this.highlightPostTag,
    this.snippetEllipsisText,
    this.restrictHighlightAndSnippetArrays,
    this.hitsPerPage,
    this.minWordSizefor1Typo,
    this.minWordSizefor2Typos,
    this.typoTolerance,
    this.allowTyposOnNumericTokens,
    this.disableTypoToleranceOnAttributes,
    this.ignorePlurals,
    this.removeStopWords,
    this.queryLanguages,
    this.decompoundQuery,
    this.enableRules,
    this.enablePersonalization,
    this.queryType,
    this.removeWordsIfNoResults,
    this.mode,
    this.semanticSearch,
    this.advancedSyntax,
    this.optionalWords,
    this.disableExactOnAttributes,
    this.exactOnSingleWordQuery,
    this.alternativesAsExact,
    this.advancedSyntaxFeatures,
    this.distinct,
    this.replaceSynonymsInHighlight,
    this.minProximity,
    this.responseFields,
    this.maxValuesPerFacet,
    this.sortFacetValuesBy,
    this.attributeCriteriaComputedByMinProximity,
    this.renderingContent,
    this.enableReRanking,
    this.reRankingApplyFilter,
    required this.indexName,
    this.maxFacetHits,
    // Helper-specific parameters
    this.disjunctiveFacets,
    this.isDisjunctiveFacetingEnabled = true,
    this.filterGroups,
  });

  /// Search query.
  final String? query;

  /// Keywords to be used instead of the search query to conduct a more broader search Using the `similarQuery` parameter changes other settings - `queryType` is set to `prefixNone`. - `removeStopWords` is set to true. - `words` is set as the first ranking criterion. - All remaining words are treated as `optionalWords` Since the `similarQuery` is supposed to do a broad search, they usually return many results. Combine it with `filters` to narrow down the list of results.
  final String? similarQuery;

  /// One of types:
  /// - [List<List<FacetFilters>>]
  /// - [String]
  /// - [List<String>]
  final dynamic facetFilters;

  /// One of types:
  /// - [String]
  /// - [List<List<OptionalFilters>>]
  /// - [List<String>]
  final dynamic optionalFilters;

  /// One of types:
  /// - [List<List<NumericFilters>>]
  /// - [String]
  /// - [List<String>]
  final dynamic numericFilters;

  /// One of types:
  /// - [List<List<TagFilters>>]
  /// - [String]
  /// - [List<String>]
  final dynamic tagFilters;

  /// Whether to sum all filter scores If true, all filter scores are summed. Otherwise, the maximum filter score is kept. For more information, see [filter scores](https://www.algolia.com/doc/guides/managing-results/refine-results/filtering/in-depth/filter-scoring/#accumulating-scores-with-sumorfiltersscores).
  final bool? sumOrFiltersScores;

  /// Restricts a search to a subset of your searchable attributes. Attribute names are case-sensitive.
  final List<String>? restrictSearchableAttributes;

  /// Facets for which to retrieve facet values that match the search criteria and the number of matching facet values To retrieve all facets, use the wildcard character `*`. For more information, see [facets](https://www.algolia.com/doc/guides/managing-results/refine-results/faceting/#contextual-facet-values-and-counts).
  final List<String>? facets;

  /// Whether faceting should be applied after deduplication with `distinct` This leads to accurate facet counts when using faceting in combination with `distinct`. It's usually better to use `afterDistinct` modifiers in the `attributesForFaceting` setting, as `facetingAfterDistinct` only computes correct facet counts if all records have the same facet values for the `attributeForDistinct`.
  final bool? facetingAfterDistinct;

  /// Page of search results to retrieve.
  // minimum: 0
  final int? page;

  /// Position of the first hit to retrieve.
  final int? offset;

  /// Number of hits to retrieve (used in combination with `offset`).
  // minimum: 0
  // maximum: 1000
  final int? length;

  /// Coordinates for the center of a circle, expressed as a comma-separated string of latitude and longitude.  Only records included within a circle around this central location are included in the results. The radius of the circle is determined by the `aroundRadius` and `minimumAroundRadius` settings. This parameter is ignored if you also specify `insidePolygon` or `insideBoundingBox`.
  final String? aroundLatLng;

  /// Whether to obtain the coordinates from the request's IP address.
  final bool? aroundLatLngViaIP;

  /// One of types:
  /// - [AroundRadiusAll]
  /// - [int]
  final dynamic aroundRadius;

  /// One of types:
  /// - [List<Range>]
  /// - [int]
  final dynamic aroundPrecision;

  /// Minimum radius (in meters) for a search around a location when `aroundRadius` isn't set.
  // minimum: 1
  final int? minimumAroundRadius;

  /// One of types:
  /// - [List<List<double>>]
  /// - [String]
  final dynamic insideBoundingBox;

  /// Coordinates of a polygon in which to search.  Polygons are defined by 3 to 10,000 points. Each point is represented by its latitude and longitude. Provide multiple polygons as nested arrays. For more information, see [filtering inside polygons](https://www.algolia.com/doc/guides/managing-results/refine-results/geolocation/#filtering-inside-rectangular-or-polygonal-areas). This parameter is ignored if you also specify `insideBoundingBox`.
  final List<List<double>>? insidePolygon;

  /// ISO language codes that adjust settings that are useful for processing natural language queries (as opposed to keyword searches) - Sets `removeStopWords` and `ignorePlurals` to the list of provided languages. - Sets `removeWordsIfNoResults` to `allOptional`. - Adds a `natural_language` attribute to `ruleContexts` and `analyticsTags`.
  final List<SupportedLanguage>? naturalLanguages;

  /// Assigns a rule context to the search query [Rule contexts](https://www.algolia.com/doc/guides/managing-results/rules/rules-overview/how-to/customize-search-results-by-platform/#whats-a-context) are strings that you can use to trigger matching rules.
  final List<String>? ruleContexts;

  /// Impact that Personalization should have on this search The higher this value is, the more Personalization determines the ranking compared to other factors. For more information, see [Understanding Personalization impact](https://www.algolia.com/doc/guides/personalization/personalizing-results/in-depth/configuring-personalization/#understanding-personalization-impact).
  // minimum: 0
  // maximum: 100
  final int? personalizationImpact;

  /// Unique pseudonymous or anonymous user identifier.  This helps with analytics and click and conversion events. For more information, see [user token](https://www.algolia.com/doc/guides/sending-events/concepts/usertoken/).
  final String? userToken;

  /// Whether the search response should include detailed ranking information.
  final bool? getRankingInfo;

  /// Whether to take into account an index's synonyms for this search.
  final bool? synonyms;

  /// Whether to include a `queryID` attribute in the response The query ID is a unique identifier for a search query and is required for tracking [click and conversion events](https://www.algolia.com/guides/sending-events/getting-started/).
  final bool? clickAnalytics;

  /// Whether this search will be included in Analytics.
  final bool? analytics;

  /// Tags to apply to the query for [segmenting analytics data](https://www.algolia.com/doc/guides/search-analytics/guides/segments/).
  final List<String>? analyticsTags;

  /// Whether to include this search when calculating processing-time percentiles.
  final bool? percentileComputation;

  /// Whether to enable A/B testing for this search.
  final bool? enableABTest;

  /// Attributes to include in the API response To reduce the size of your response, you can retrieve only some of the attributes. Attribute names are case-sensitive - `*` retrieves all attributes, except attributes included in the `customRanking` and `unretrievableAttributes` settings. - To retrieve all attributes except a specific one, prefix the attribute with a dash and combine it with the `*`: `[\"*\", \"-ATTRIBUTE\"]`. - The `objectID` attribute is always included.
  final List<String>? attributesToRetrieve;

  /// Determines the order in which Algolia returns your results.  By default, each entry corresponds to a [ranking criteria](https://www.algolia.com/doc/guides/managing-results/relevance-overview/in-depth/ranking-criteria/). The tie-breaking algorithm sequentially applies each criterion in the order they're specified. If you configure a replica index for [sorting by an attribute](https://www.algolia.com/doc/guides/managing-results/refine-results/sorting/how-to/sort-by-attribute/), you put the sorting attribute at the top of the list.  **Modifiers**  - `asc(\"ATTRIBUTE\")`.   Sort the index by the values of an attribute, in ascending order. - `desc(\"ATTRIBUTE\")`.   Sort the index by the values of an attribute, in descending order.  Before you modify the default setting, you should test your changes in the dashboard, and by [A/B testing](https://www.algolia.com/doc/guides/ab-testing/what-is-ab-testing/).
  final List<String>? ranking;

  /// Relevancy threshold below which less relevant results aren't included in the results You can only set `relevancyStrictness` on [virtual replica indices](https://www.algolia.com/doc/guides/managing-results/refine-results/sorting/in-depth/replicas/#what-are-virtual-replicas). Use this setting to strike a balance between the relevance and number of returned results.
  final int? relevancyStrictness;

  /// Attributes to highlight By default, all searchable attributes are highlighted. Use `*` to highlight all attributes or use an empty array `[]` to turn off highlighting. Attribute names are case-sensitive With highlighting, strings that match the search query are surrounded by HTML tags defined by `highlightPreTag` and `highlightPostTag`. You can use this to visually highlight matching parts of a search query in your UI For more information, see [Highlighting and snippeting](https://www.algolia.com/doc/guides/building-search-ui/ui-and-ux-patterns/highlighting-snippeting/js/).
  final List<String>? attributesToHighlight;

  /// Attributes for which to enable snippets. Attribute names are case-sensitive Snippets provide additional context to matched words. If you enable snippets, they include 10 words, including the matched word. The matched word will also be wrapped by HTML tags for highlighting. You can adjust the number of words with the following notation: `ATTRIBUTE:NUMBER`, where `NUMBER` is the number of words to be extracted.
  final List<String>? attributesToSnippet;

  /// HTML tag to insert before the highlighted parts in all highlighted results and snippets.
  final String? highlightPreTag;

  /// HTML tag to insert after the highlighted parts in all highlighted results and snippets.
  final String? highlightPostTag;

  /// String used as an ellipsis indicator when a snippet is truncated.
  final String? snippetEllipsisText;

  /// Whether to restrict highlighting and snippeting to items that at least partially matched the search query. By default, all items are highlighted and snippeted.
  final bool? restrictHighlightAndSnippetArrays;

  /// Number of hits per page.
  // minimum: 1
  // maximum: 1000
  final int? hitsPerPage;

  /// Minimum number of characters a word in the search query must contain to accept matches with [one typo](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/typo-tolerance/in-depth/configuring-typo-tolerance/#configuring-word-length-for-typos).
  final int? minWordSizefor1Typo;

  /// Minimum number of characters a word in the search query must contain to accept matches with [two typos](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/typo-tolerance/in-depth/configuring-typo-tolerance/#configuring-word-length-for-typos).
  final int? minWordSizefor2Typos;

  /// One of types:
  /// - [TypoToleranceEnum]
  /// - [bool]
  final dynamic typoTolerance;

  /// Whether to allow typos on numbers in the search query Turn off this setting to reduce the number of irrelevant matches when searching in large sets of similar numbers.
  final bool? allowTyposOnNumericTokens;

  /// Attributes for which you want to turn off [typo tolerance](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/typo-tolerance/). Attribute names are case-sensitive Returning only exact matches can help when - [Searching in hyphenated attributes](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/typo-tolerance/how-to/how-to-search-in-hyphenated-attributes/). - Reducing the number of matches when you have too many.   This can happen with attributes that are long blocks of text, such as product descriptions Consider alternatives such as `disableTypoToleranceOnWords` or adding synonyms if your attributes have intentional unusual spellings that might look like typos.
  final List<String>? disableTypoToleranceOnAttributes;

  /// One of types:
  /// - [BooleanString]
  /// - [bool]
  /// - [List<SupportedLanguage>]
  final dynamic ignorePlurals;

  /// One of types:
  /// - [bool]
  /// - [List<SupportedLanguage>]
  final dynamic removeStopWords;

  /// Languages for language-specific query processing steps such as plurals, stop-word removal, and word-detection dictionaries  This setting sets a default list of languages used by the `removeStopWords` and `ignorePlurals` settings. This setting also sets a dictionary for word detection in the logogram-based [CJK](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/handling-natural-languages-nlp/in-depth/normalization/#normalization-for-logogram-based-languages-cjk) languages. To support this, you must place the CJK language **first**  **You should always specify a query language.** If you don't specify an indexing language, the search engine uses all [supported languages](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/handling-natural-languages-nlp/in-depth/supported-languages/), or the languages you specified with the `ignorePlurals` or `removeStopWords` parameters. This can lead to unexpected search results. For more information, see [Language-specific configuration](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/handling-natural-languages-nlp/in-depth/language-specific-configurations/).
  final List<SupportedLanguage>? queryLanguages;

  /// Whether to split compound words in the query into their building blocks For more information, see [Word segmentation](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/handling-natural-languages-nlp/in-depth/language-specific-configurations/#splitting-compound-words). Word segmentation is supported for these languages: German, Dutch, Finnish, Swedish, and Norwegian. Decompounding doesn't work for words with [non-spacing mark Unicode characters](https://www.charactercodes.net/category/non-spacing_mark). For example, `Gartenstühle` won't be decompounded if the `ü` consists of `u` (U+0075) and `◌̈` (U+0308).
  final bool? decompoundQuery;

  /// Whether to enable rules.
  final bool? enableRules;

  /// Whether to enable Personalization.
  final bool? enablePersonalization;

  final QueryType? queryType;

  final RemoveWordsIfNoResults? removeWordsIfNoResults;

  final Mode? mode;

  final SemanticSearch? semanticSearch;

  /// Whether to support phrase matching and excluding words from search queries Use the `advancedSyntaxFeatures` parameter to control which feature is supported.
  final bool? advancedSyntax;

  /// One of types:
  /// - [String]
  /// - [List<String>]
  final dynamic optionalWords;

  /// Searchable attributes for which you want to [turn off the Exact ranking criterion](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/override-search-engine-defaults/in-depth/adjust-exact-settings/#turn-off-exact-for-some-attributes). Attribute names are case-sensitive This can be useful for attributes with long values, where the likelihood of an exact match is high, such as product descriptions. Turning off the Exact ranking criterion for these attributes favors exact matching on other attributes. This reduces the impact of individual attributes with a lot of content on ranking.
  final List<String>? disableExactOnAttributes;

  final ExactOnSingleWordQuery? exactOnSingleWordQuery;

  /// Determine which plurals and synonyms should be considered an exact matches By default, Algolia treats singular and plural forms of a word, and single-word synonyms, as [exact](https://www.algolia.com/doc/guides/managing-results/relevance-overview/in-depth/ranking-criteria/#exact) matches when searching. For example - \"swimsuit\" and \"swimsuits\" are treated the same - \"swimsuit\" and \"swimwear\" are treated the same (if they are [synonyms](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/adding-synonyms/#regular-synonyms)) - `ignorePlurals`.   Plurals and similar declensions added by the `ignorePlurals` setting are considered exact matches - `singleWordSynonym`.   Single-word synonyms, such as \"NY\" = \"NYC\", are considered exact matches - `multiWordsSynonym`.   Multi-word synonyms, such as \"NY\" = \"New York\", are considered exact matches.
  final List<AlternativesAsExact>? alternativesAsExact;

  /// Advanced search syntax features you want to support - `exactPhrase`.   Phrases in quotes must match exactly.   For example, `sparkly blue \"iPhone case\"` only returns records with the exact string \"iPhone case\" - `excludeWords`.   Query words prefixed with a `-` must not occur in a record.   For example, `search -engine` matches records that contain \"search\" but not \"engine\" This setting only has an effect if `advancedSyntax` is true.
  final List<AdvancedSyntaxFeatures>? advancedSyntaxFeatures;

  /// One of types:
  /// - [bool]
  /// - [int]
  final dynamic distinct;

  /// Whether to replace a highlighted word with the matched synonym By default, the original words are highlighted even if a synonym matches. For example, with `home` as a synonym for `house` and a search for `home`, records matching either \"home\" or \"house\" are included in the search results, and either \"home\" or \"house\" are highlighted With `replaceSynonymsInHighlight` set to `true`, a search for `home` still matches the same records, but all occurrences of \"house\" are replaced by \"home\" in the highlighted response.
  final bool? replaceSynonymsInHighlight;

  /// Minimum proximity score for two matching words This adjusts the [Proximity ranking criterion](https://www.algolia.com/doc/guides/managing-results/relevance-overview/in-depth/ranking-criteria/#proximity) by equally scoring matches that are farther apart For example, if `minProximity` is 2, neighboring matches and matches with one word between them would have the same score.
  // minimum: 1
  // maximum: 7
  final int? minProximity;

  /// Properties to include in the API response of search and browse requests By default, all response properties are included. To reduce the response size, you can select which properties should be included An empty list may lead to an empty API response (except properties you can't exclude) You can't exclude these properties: `message`, `warning`, `cursor`, `abTestVariantID`, or any property added by setting `getRankingInfo` to true Your search depends on the `hits` field. If you omit this field, searches won't return any results. Your UI might also depend on other properties, for example, for pagination. Before restricting the response size, check the impact on your search experience.
  final List<String>? responseFields;

  /// Maximum number of facet values to return for each facet.
  // maximum: 1000
  final int? maxValuesPerFacet;

  /// Order in which to retrieve facet values - `count`.   Facet values are retrieved by decreasing count.   The count is the number of matching records containing this facet value - `alpha`.   Retrieve facet values alphabetically This setting doesn't influence how facet values are displayed in your UI (see `renderingContent`). For more information, see [facet value display](https://www.algolia.com/doc/guides/building-search-ui/ui-and-ux-patterns/facet-display/js/).
  final String? sortFacetValuesBy;

  /// Whether the best matching attribute should be determined by minimum proximity This setting only affects ranking if the Attribute ranking criterion comes before Proximity in the `ranking` setting. If true, the best matching attribute is selected based on the minimum proximity of multiple matches. Otherwise, the best matching attribute is determined by the order in the `searchableAttributes` setting.
  final bool? attributeCriteriaComputedByMinProximity;

  final RenderingContent? renderingContent;

  /// Whether this search will use [Dynamic Re-Ranking](https://www.algolia.com/doc/guides/algolia-ai/re-ranking/) This setting only has an effect if you activated Dynamic Re-Ranking for this index in the Algolia dashboard.
  final bool? enableReRanking;

  /// One of types:
  /// - [List<List<ReRankingApplyFilter>>]
  /// - [String]
  /// - [List<String>]
  final dynamic reRankingApplyFilter;

  /// Index name (case-sensitive).
  final String indexName;

  /// Maximum number of facet values to return when [searching for facet values](https://www.algolia.com/doc/guides/managing-results/refine-results/faceting/#search-for-facet-values).
  // maximum: 100
  final int? maxFacetHits;

  /// Disjunctive facets list
  final Set<String>? disjunctiveFacets;

  /// Whether disjunctive faceting is enabled
  final bool isDisjunctiveFacetingEnabled;

  /// Set of filter groups
  final Set<FilterGroup>? filterGroups;

  /// Make a copy of the search state.
  SearchState copyWith({
    String? query,
    String? similarQuery,
    dynamic facetFilters,
    dynamic optionalFilters,
    dynamic numericFilters,
    dynamic tagFilters,
    bool? sumOrFiltersScores,
    List<String>? restrictSearchableAttributes,
    List<String>? facets,
    bool? facetingAfterDistinct,
    int? page,
    int? offset,
    int? length,
    String? aroundLatLng,
    bool? aroundLatLngViaIP,
    dynamic aroundRadius,
    dynamic aroundPrecision,
    int? minimumAroundRadius,
    dynamic insideBoundingBox,
    List<List<double>>? insidePolygon,
    List<SupportedLanguage>? naturalLanguages,
    List<String>? ruleContexts,
    int? personalizationImpact,
    String? userToken,
    bool? getRankingInfo,
    bool? synonyms,
    bool? clickAnalytics,
    bool? analytics,
    List<String>? analyticsTags,
    bool? percentileComputation,
    bool? enableABTest,
    List<String>? attributesToRetrieve,
    List<String>? ranking,
    int? relevancyStrictness,
    List<String>? attributesToHighlight,
    List<String>? attributesToSnippet,
    String? highlightPreTag,
    String? highlightPostTag,
    String? snippetEllipsisText,
    bool? restrictHighlightAndSnippetArrays,
    int? hitsPerPage,
    int? minWordSizefor1Typo,
    int? minWordSizefor2Typos,
    dynamic typoTolerance,
    bool? allowTyposOnNumericTokens,
    List<String>? disableTypoToleranceOnAttributes,
    dynamic ignorePlurals,
    dynamic removeStopWords,
    List<SupportedLanguage>? queryLanguages,
    bool? decompoundQuery,
    bool? enableRules,
    bool? enablePersonalization,
    QueryType? queryType,
    RemoveWordsIfNoResults? removeWordsIfNoResults,
    Mode? mode,
    SemanticSearch? semanticSearch,
    bool? advancedSyntax,
    dynamic optionalWords,
    List<String>? disableExactOnAttributes,
    ExactOnSingleWordQuery? exactOnSingleWordQuery,
    List<AlternativesAsExact>? alternativesAsExact,
    List<AdvancedSyntaxFeatures>? advancedSyntaxFeatures,
    dynamic distinct,
    bool? replaceSynonymsInHighlight,
    int? minProximity,
    List<String>? responseFields,
    int? maxValuesPerFacet,
    String? sortFacetValuesBy,
    bool? attributeCriteriaComputedByMinProximity,
    RenderingContent? renderingContent,
    bool? enableReRanking,
    dynamic reRankingApplyFilter,
    String? indexName,
    int? maxFacetHits,
    Set<String>? disjunctiveFacets,
    bool? isDisjunctiveFacetingEnabled,
    Set<FilterGroup>? filterGroups,
  }) =>
      SearchState(
        query: query ?? this.query,
        similarQuery: similarQuery ?? this.similarQuery,
        facetFilters: facetFilters ?? this.facetFilters,
        optionalFilters: optionalFilters ?? this.optionalFilters,
        numericFilters: numericFilters ?? this.numericFilters,
        tagFilters: tagFilters ?? this.tagFilters,
        sumOrFiltersScores: sumOrFiltersScores ?? this.sumOrFiltersScores,
        restrictSearchableAttributes:
            restrictSearchableAttributes ?? this.restrictSearchableAttributes,
        facets: facets ?? this.facets,
        facetingAfterDistinct:
            facetingAfterDistinct ?? this.facetingAfterDistinct,
        page: page ?? this.page,
        offset: offset ?? this.offset,
        length: length ?? this.length,
        aroundLatLng: aroundLatLng ?? this.aroundLatLng,
        aroundLatLngViaIP: aroundLatLngViaIP ?? this.aroundLatLngViaIP,
        aroundRadius: aroundRadius ?? this.aroundRadius,
        aroundPrecision: aroundPrecision ?? this.aroundPrecision,
        minimumAroundRadius: minimumAroundRadius ?? this.minimumAroundRadius,
        insideBoundingBox: insideBoundingBox ?? this.insideBoundingBox,
        insidePolygon: insidePolygon ?? this.insidePolygon,
        naturalLanguages: naturalLanguages ?? this.naturalLanguages,
        ruleContexts: ruleContexts ?? this.ruleContexts,
        personalizationImpact:
            personalizationImpact ?? this.personalizationImpact,
        userToken: userToken ?? this.userToken,
        getRankingInfo: getRankingInfo ?? this.getRankingInfo,
        synonyms: synonyms ?? this.synonyms,
        clickAnalytics: clickAnalytics ?? this.clickAnalytics,
        analytics: analytics ?? this.analytics,
        analyticsTags: analyticsTags ?? this.analyticsTags,
        percentileComputation:
            percentileComputation ?? this.percentileComputation,
        enableABTest: enableABTest ?? this.enableABTest,
        attributesToRetrieve: attributesToRetrieve ?? this.attributesToRetrieve,
        ranking: ranking ?? this.ranking,
        relevancyStrictness: relevancyStrictness ?? this.relevancyStrictness,
        attributesToHighlight:
            attributesToHighlight ?? this.attributesToHighlight,
        attributesToSnippet: attributesToSnippet ?? this.attributesToSnippet,
        highlightPreTag: highlightPreTag ?? this.highlightPreTag,
        highlightPostTag: highlightPostTag ?? this.highlightPostTag,
        snippetEllipsisText: snippetEllipsisText ?? this.snippetEllipsisText,
        restrictHighlightAndSnippetArrays: restrictHighlightAndSnippetArrays ??
            this.restrictHighlightAndSnippetArrays,
        hitsPerPage: hitsPerPage ?? this.hitsPerPage,
        minWordSizefor1Typo: minWordSizefor1Typo ?? this.minWordSizefor1Typo,
        minWordSizefor2Typos: minWordSizefor2Typos ?? this.minWordSizefor2Typos,
        typoTolerance: typoTolerance ?? this.typoTolerance,
        allowTyposOnNumericTokens:
            allowTyposOnNumericTokens ?? this.allowTyposOnNumericTokens,
        disableTypoToleranceOnAttributes: disableTypoToleranceOnAttributes ??
            this.disableTypoToleranceOnAttributes,
        ignorePlurals: ignorePlurals ?? this.ignorePlurals,
        removeStopWords: removeStopWords ?? this.removeStopWords,
        queryLanguages: queryLanguages ?? this.queryLanguages,
        decompoundQuery: decompoundQuery ?? this.decompoundQuery,
        enableRules: enableRules ?? this.enableRules,
        enablePersonalization:
            enablePersonalization ?? this.enablePersonalization,
        queryType: queryType ?? this.queryType,
        removeWordsIfNoResults:
            removeWordsIfNoResults ?? this.removeWordsIfNoResults,
        mode: mode ?? this.mode,
        semanticSearch: semanticSearch ?? this.semanticSearch,
        advancedSyntax: advancedSyntax ?? this.advancedSyntax,
        optionalWords: optionalWords ?? this.optionalWords,
        disableExactOnAttributes:
            disableExactOnAttributes ?? this.disableExactOnAttributes,
        exactOnSingleWordQuery:
            exactOnSingleWordQuery ?? this.exactOnSingleWordQuery,
        alternativesAsExact: alternativesAsExact ?? this.alternativesAsExact,
        advancedSyntaxFeatures:
            advancedSyntaxFeatures ?? this.advancedSyntaxFeatures,
        distinct: distinct ?? this.distinct,
        replaceSynonymsInHighlight:
            replaceSynonymsInHighlight ?? this.replaceSynonymsInHighlight,
        minProximity: minProximity ?? this.minProximity,
        responseFields: responseFields ?? this.responseFields,
        maxValuesPerFacet: maxValuesPerFacet ?? this.maxValuesPerFacet,
        sortFacetValuesBy: sortFacetValuesBy ?? this.sortFacetValuesBy,
        attributeCriteriaComputedByMinProximity:
            attributeCriteriaComputedByMinProximity ??
                this.attributeCriteriaComputedByMinProximity,
        renderingContent: renderingContent ?? this.renderingContent,
        enableReRanking: enableReRanking ?? this.enableReRanking,
        reRankingApplyFilter: reRankingApplyFilter ?? this.reRankingApplyFilter,
        indexName: indexName ?? this.indexName,
        maxFacetHits: maxFacetHits ?? this.maxFacetHits,
        disjunctiveFacets: disjunctiveFacets ?? this.disjunctiveFacets,
        isDisjunctiveFacetingEnabled:
            isDisjunctiveFacetingEnabled ?? this.isDisjunctiveFacetingEnabled,
        filterGroups: filterGroups ?? this.filterGroups,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchState &&
          other.query == query &&
          other.similarQuery == similarQuery &&
          other.facetFilters == facetFilters &&
          other.optionalFilters == optionalFilters &&
          other.numericFilters == numericFilters &&
          other.tagFilters == tagFilters &&
          other.sumOrFiltersScores == sumOrFiltersScores &&
          other.restrictSearchableAttributes == restrictSearchableAttributes &&
          other.facets == facets &&
          other.facetingAfterDistinct == facetingAfterDistinct &&
          other.page == page &&
          other.offset == offset &&
          other.length == length &&
          other.aroundLatLng == aroundLatLng &&
          other.aroundLatLngViaIP == aroundLatLngViaIP &&
          other.aroundRadius == aroundRadius &&
          other.aroundPrecision == aroundPrecision &&
          other.minimumAroundRadius == minimumAroundRadius &&
          other.insideBoundingBox == insideBoundingBox &&
          other.insidePolygon == insidePolygon &&
          other.naturalLanguages == naturalLanguages &&
          other.ruleContexts == ruleContexts &&
          other.personalizationImpact == personalizationImpact &&
          other.userToken == userToken &&
          other.getRankingInfo == getRankingInfo &&
          other.synonyms == synonyms &&
          other.clickAnalytics == clickAnalytics &&
          other.analytics == analytics &&
          other.analyticsTags == analyticsTags &&
          other.percentileComputation == percentileComputation &&
          other.enableABTest == enableABTest &&
          other.attributesToRetrieve == attributesToRetrieve &&
          other.ranking == ranking &&
          other.relevancyStrictness == relevancyStrictness &&
          other.attributesToHighlight == attributesToHighlight &&
          other.attributesToSnippet == attributesToSnippet &&
          other.highlightPreTag == highlightPreTag &&
          other.highlightPostTag == highlightPostTag &&
          other.snippetEllipsisText == snippetEllipsisText &&
          other.restrictHighlightAndSnippetArrays ==
              restrictHighlightAndSnippetArrays &&
          other.hitsPerPage == hitsPerPage &&
          other.minWordSizefor1Typo == minWordSizefor1Typo &&
          other.minWordSizefor2Typos == minWordSizefor2Typos &&
          other.typoTolerance == typoTolerance &&
          other.allowTyposOnNumericTokens == allowTyposOnNumericTokens &&
          other.disableTypoToleranceOnAttributes ==
              disableTypoToleranceOnAttributes &&
          other.ignorePlurals == ignorePlurals &&
          other.removeStopWords == removeStopWords &&
          other.queryLanguages == queryLanguages &&
          other.decompoundQuery == decompoundQuery &&
          other.enableRules == enableRules &&
          other.enablePersonalization == enablePersonalization &&
          other.queryType == queryType &&
          other.removeWordsIfNoResults == removeWordsIfNoResults &&
          other.mode == mode &&
          other.semanticSearch == semanticSearch &&
          other.advancedSyntax == advancedSyntax &&
          other.optionalWords == optionalWords &&
          other.disableExactOnAttributes == disableExactOnAttributes &&
          other.exactOnSingleWordQuery == exactOnSingleWordQuery &&
          other.alternativesAsExact == alternativesAsExact &&
          other.advancedSyntaxFeatures == advancedSyntaxFeatures &&
          other.distinct == distinct &&
          other.replaceSynonymsInHighlight == replaceSynonymsInHighlight &&
          other.minProximity == minProximity &&
          other.responseFields == responseFields &&
          other.maxValuesPerFacet == maxValuesPerFacet &&
          other.sortFacetValuesBy == sortFacetValuesBy &&
          other.attributeCriteriaComputedByMinProximity ==
              attributeCriteriaComputedByMinProximity &&
          other.renderingContent == renderingContent &&
          other.enableReRanking == enableReRanking &&
          other.reRankingApplyFilter == reRankingApplyFilter &&
          other.indexName == indexName &&
          other.maxFacetHits == maxFacetHits &&
          other.disjunctiveFacets == disjunctiveFacets &&
          other.isDisjunctiveFacetingEnabled == isDisjunctiveFacetingEnabled &&
          other.filterGroups == filterGroups;

  @override
  int get hashCode =>
      query.hashCode +
      similarQuery.hashCode +
      facetFilters.hashCode +
      optionalFilters.hashCode +
      numericFilters.hashCode +
      tagFilters.hashCode +
      sumOrFiltersScores.hashCode +
      restrictSearchableAttributes.hashCode +
      facets.hashCode +
      facetingAfterDistinct.hashCode +
      page.hashCode +
      offset.hashCode +
      length.hashCode +
      aroundLatLng.hashCode +
      aroundLatLngViaIP.hashCode +
      aroundRadius.hashCode +
      aroundPrecision.hashCode +
      minimumAroundRadius.hashCode +
      (insideBoundingBox == null ? 0 : insideBoundingBox.hashCode) +
      insidePolygon.hashCode +
      naturalLanguages.hashCode +
      ruleContexts.hashCode +
      personalizationImpact.hashCode +
      userToken.hashCode +
      getRankingInfo.hashCode +
      synonyms.hashCode +
      clickAnalytics.hashCode +
      analytics.hashCode +
      analyticsTags.hashCode +
      percentileComputation.hashCode +
      enableABTest.hashCode +
      attributesToRetrieve.hashCode +
      ranking.hashCode +
      relevancyStrictness.hashCode +
      attributesToHighlight.hashCode +
      attributesToSnippet.hashCode +
      highlightPreTag.hashCode +
      highlightPostTag.hashCode +
      snippetEllipsisText.hashCode +
      restrictHighlightAndSnippetArrays.hashCode +
      hitsPerPage.hashCode +
      minWordSizefor1Typo.hashCode +
      minWordSizefor2Typos.hashCode +
      typoTolerance.hashCode +
      allowTyposOnNumericTokens.hashCode +
      disableTypoToleranceOnAttributes.hashCode +
      ignorePlurals.hashCode +
      removeStopWords.hashCode +
      queryLanguages.hashCode +
      decompoundQuery.hashCode +
      enableRules.hashCode +
      enablePersonalization.hashCode +
      queryType.hashCode +
      removeWordsIfNoResults.hashCode +
      mode.hashCode +
      semanticSearch.hashCode +
      advancedSyntax.hashCode +
      (optionalWords == null ? 0 : optionalWords.hashCode) +
      disableExactOnAttributes.hashCode +
      exactOnSingleWordQuery.hashCode +
      alternativesAsExact.hashCode +
      advancedSyntaxFeatures.hashCode +
      distinct.hashCode +
      replaceSynonymsInHighlight.hashCode +
      minProximity.hashCode +
      responseFields.hashCode +
      maxValuesPerFacet.hashCode +
      sortFacetValuesBy.hashCode +
      attributeCriteriaComputedByMinProximity.hashCode +
      renderingContent.hashCode +
      enableReRanking.hashCode +
      reRankingApplyFilter.hashCode +
      indexName.hashCode +
      maxFacetHits.hashCode +
      disjunctiveFacets.hashCode +
      isDisjunctiveFacetingEnabled.hashCode +
      filterGroups.hashCode;

  @override
  String toString() => 'SearchState{'
      'query: $query, '
      'similarQuery: $similarQuery, '
      'facetFilters: $facetFilters, '
      'optionalFilters: $optionalFilters, '
      'numericFilters: $numericFilters, '
      'tagFilters: $tagFilters, '
      'sumOrFiltersScores: $sumOrFiltersScores, '
      'restrictSearchableAttributes: $restrictSearchableAttributes, '
      'facets: $facets, '
      'facetingAfterDistinct: $facetingAfterDistinct, '
      'page: $page, '
      'offset: $offset, '
      'length: $length, '
      'aroundLatLng: $aroundLatLng, '
      'aroundLatLngViaIP: $aroundLatLngViaIP, '
      'aroundRadius: $aroundRadius, '
      'aroundPrecision: $aroundPrecision, '
      'minimumAroundRadius: $minimumAroundRadius, '
      'insideBoundingBox: $insideBoundingBox, '
      'insidePolygon: $insidePolygon, '
      'naturalLanguages: $naturalLanguages, '
      'ruleContexts: $ruleContexts, '
      'personalizationImpact: $personalizationImpact, '
      'userToken: $userToken, '
      'getRankingInfo: $getRankingInfo, '
      'synonyms: $synonyms, '
      'clickAnalytics: $clickAnalytics, '
      'analytics: $analytics, '
      'analyticsTags: $analyticsTags, '
      'percentileComputation: $percentileComputation, '
      'enableABTest: $enableABTest, '
      'attributesToRetrieve: $attributesToRetrieve, '
      'ranking: $ranking, '
      'relevancyStrictness: $relevancyStrictness, '
      'attributesToHighlight: $attributesToHighlight, '
      'attributesToSnippet: $attributesToSnippet, '
      'highlightPreTag: $highlightPreTag, '
      'highlightPostTag: $highlightPostTag, '
      'snippetEllipsisText: $snippetEllipsisText, '
      'restrictHighlightAndSnippetArrays: $restrictHighlightAndSnippetArrays, '
      'hitsPerPage: $hitsPerPage, '
      'minWordSizefor1Typo: $minWordSizefor1Typo, '
      'minWordSizefor2Typos: $minWordSizefor2Typos, '
      'typoTolerance: $typoTolerance, '
      'allowTyposOnNumericTokens: $allowTyposOnNumericTokens, '
      'disableTypoToleranceOnAttributes: $disableTypoToleranceOnAttributes, '
      'ignorePlurals: $ignorePlurals, '
      'removeStopWords: $removeStopWords, '
      'queryLanguages: $queryLanguages, '
      'decompoundQuery: $decompoundQuery, '
      'enableRules: $enableRules, '
      'enablePersonalization: $enablePersonalization, '
      'queryType: $queryType, '
      'removeWordsIfNoResults: $removeWordsIfNoResults, '
      'mode: $mode, '
      'semanticSearch: $semanticSearch, '
      'advancedSyntax: $advancedSyntax, '
      'optionalWords: $optionalWords, '
      'disableExactOnAttributes: $disableExactOnAttributes, '
      'exactOnSingleWordQuery: $exactOnSingleWordQuery, '
      'alternativesAsExact: $alternativesAsExact, '
      'advancedSyntaxFeatures: $advancedSyntaxFeatures, '
      'distinct: $distinct, '
      'replaceSynonymsInHighlight: $replaceSynonymsInHighlight, '
      'minProximity: $minProximity, '
      'responseFields: $responseFields, '
      'maxValuesPerFacet: $maxValuesPerFacet, '
      'sortFacetValuesBy: $sortFacetValuesBy, '
      'attributeCriteriaComputedByMinProximity: $attributeCriteriaComputedByMinProximity, '
      'renderingContent: $renderingContent, '
      'enableReRanking: $enableReRanking, '
      'reRankingApplyFilter: $reRankingApplyFilter, '
      'indexName: $indexName, '
      'maxFacetHits: $maxFacetHits, '
      'disjunctiveFacets: $disjunctiveFacets, '
      'isDisjunctiveFacetingEnabled: $isDisjunctiveFacetingEnabled, '
      'filterGroups: $filterGroups}';
}
