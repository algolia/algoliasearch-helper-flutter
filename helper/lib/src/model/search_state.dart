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
    this.aroundLatLngViaIP,
    this.aroundLatLng,
    this.aroundRadius,
    this.minimumAroundRadius,
    this.aroundPrecision,
    this.insideBoundingBox,
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

  ///
  /// **AroundLatLngViaIP**
  ///
  /// Search for entries around a given location automatically computed from
  /// the requester’s IP address.
  /// By computing a central geolocation (from an IP), this has three
  /// consequences:
  ///   - a radius / circle is computed automatically, based on the density of the records near the point defined by this setting
  ///   - only records that fall within the bounds of the circle are returned
  ///   - records are ranked according to the distance from the center of the
  ///   circle
  ///
  /// **Usage notes:**
  ///   - With this setting, you are using the end user’s IP to define a central
  ///   axis point of a circle in geo-coordinates.
  ///   - Algolia automatically calculates the size of the circular radius
  ///     around this central axis.
  ///     - To control the precise size of the radius, you would use
  ///       [aroundRadius].
  ///     - To control a minimum size, you would use [minimumAroundRadius].
  ///   - If you are sending the request from your servers, you must set
  ///     the X-Forwarded-For HTTP header with the front-end user’s IP address
  ///     for it to be used as the basis for the computation of the search
  ///     location.
  ///   - Note: This setting differs from [aroundLatLng], which allows you to
  ///     specify the exact latitude and longitude of the center of the circle.
  ///   - This parameter will be ignored if used along with [insideBoundingBox]
  ///     or [insidePolygon]
  ///   - We currently only support IPv4 addresses. If the end user has an IPv6
  ///     address, this parameter won’t work as intended.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/aroundLatLngViaIP/)
  ///
  final bool? aroundLatLngViaIP;

  ///
  /// **AroundLatLng**
  ///
  /// Search for entries around a central geolocation, enabling a geo search
  /// within a circular area.
  ///
  /// By defining this central point, there are three consequences:
  ///   - a radius / circle is computed automatically, based on the density of the records near the point defined by this setting
  ///   - only records that fall within the bounds of the circle are returned
  ///   - records are ranked according to the distance from the center of the
  ///   circle
  ///
  /// **Usage notes:**
  ///   - With this setting, you are defining a central point of a circle, whose
  ///   geo-coordinates are expressed as two floats separated by a comma.
  ///   - Note: This setting differs from [aroundLatLngViaIP], which uses the
  ///   end user’s IP to determine the geo-coordinates.
  ///   - This parameter will be ignored if used along with [insideBoundingBox]
  ///   or [insidePolygon]
  ///   - To control the maximum size of the radius, you would use
  ///     [aroundRadius].
  ///   - To control the minimum size, you would use [minimumAroundRadius].
  ///   - The size of this radius depends on the density of the area around the
  ///     central point. If there are a large number of hits close to the
  ///     central point, the radius can be small. The less hits near the center,
  ///     the larger the radius will be.
  ///   - Note: If the results returned are less than the number of hits per
  ///     page (hitsPerPage), then the number returned will be less than the
  ///     hitsPerPage. For example, if you recieve 15 results, you could still
  ///     see a larger number of hits per page, such as hitsPerPage=20.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/aroundLatLng/)
  ///
  final String? aroundLatLng;

  ///
  /// **AroundRadius**
  ///
  /// Define the maximum radius for a geo search (in meters).
  ///
  /// **Usage notes:**
  ///   - This setting only works within the context of a radial (circuler) geo
  ///     search, enabled by `aroundLatLngViaIP` or `aroundLatLng`.
  ///   - ***How the radius is calculated:***
  ///     - If you specify the meters of the radius (instead of `all`), then
  ///       only records that fall within the bounds of the circle (as defined
  ///       by the radius) will be returned. Additionally, the ranking of the
  ///       returned hits will be based on the distance from the central axis
  ///       point.
  ///     - If you use `all`, there is no longer any filtering based on the
  ///       radius. All relevant results are returned, but the ranking is still
  ///       based on the distance from the central axis point.
  ///     - If you do not use this setting, and yet perform a radial geo search
  ///       (using `aroundLatLngViaIP` or `aroundLatLng`), the radius is
  ///       automatically computed from the density of the searched area. See
  ///       also `minimumAroundRadius`, which determines the minimum size of the
  ///       radius.
  ///   - For this setting to have any effect on your ranking, the geo criterion
  ///     must be included in your ranking formula (which is the case by
  ///     default).
  ///
  /// **Options:**
  ///   - `radius_in_meters`: Integer value (in meters) representing the radius
  ///     around the coordinates specified during the query.
  ///   - `all`: Disables the radius logic, allowing all results to be returned,
  ///     regardless of distance. Ranking is still based on proximity to the
  ///     central axis point. This option is faster than specifying a high
  ///     integer value.
  ///
  /// value must be a `int` or `'all'`
  ///
  /// `1 = 1 Meter`
  ///
  /// `Therefore for 1000 = 1 Kilometer`
  ///
  /// `'aroundRadius' => 1000` // 1km
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/aroundRadius/)
  ///
  final dynamic aroundRadius;

  ///
  /// **AroundPrecision**
  ///
  /// Precision of geo search (in meters), to add grouping by geo location to
  /// the ranking formula.
  ///
  /// When ranking hits, geo distances are grouped into ranges of
  /// `aroundPrecision` size. All hits within the same range are considered
  /// equal with respect to the `geo` ranking parameter.
  ///
  /// For example, if you set `aroundPrecision` to `100`, any two objects lying
  /// in the range `[0, 99m]` from the searched location will be considered
  /// equal; same for `[100, 199]`, `[200, 299]`, etc.
  ///
  /// Usage notes:
  ///   - For this setting to have any effect, the [geo criterion](https://www.algolia.com/doc/guides/managing-results/must-do/custom-ranking/in-depth/ranking-criteria#geo-if-applicable)
  ///     must be included in your ranking formula (which is the case by
  ///     default).
  ///
  /// `1 = 1 Meter`
  ///
  /// `Therefore for 1000 = 1 Kilometer`
  ///
  /// `'aroundPrecision' => 1000` // 1km
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/aroundPrecision/)
  ///
  final int? aroundPrecision;

  ///
  /// **MinimumAroundRadius**
  ///
  /// Minimum radius (in meters) used for a geo search when `aroundRadius` is
  /// not set.
  ///
  /// When a radius is automatically generated, the area of the circle might be
  /// too small to include enough records. This setting allows you to increase
  /// the size of the circle, thus ensuring sufficient coverage.
  ///
  /// **Usage notes:**
  ///   - This setting only works within the context of a circular geo search,
  ///     enabled by `aroundLatLng` or `aroundLatLngViaIP`.
  ///   - This parameter is ignored when `aroundRadius` is set.
  ///
  /// `1 = 1 Meter`
  ///
  /// `Therefore for 1000 = 1 Kilometer`
  ///
  /// `'minimumAroundRadius' => 1000` // 1km
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/minimumAroundRadius/)
  ///
  final int? minimumAroundRadius;

  ///
  /// **InsideBoundingBox**
  ///
  /// Search inside a rectangular area (in geo coordinates).
  ///
  /// The rectangle is defined by two diagonally opposite points (hereafter `p1`
  /// and `p2`), hence by 4 floats: `p1Lat`, `p1Lng`, `p2Lat`, `p2Lng`.
  ///
  /// For example: `insideBoundingBox = [ 47.3165, 4.9665, 47.3424, 5.0201 ]`
  ///
  /// **Usage notes**
  ///   - You may specify multiple bounding boxes, in which case the search will
  ///     use the union (OR) of the rectangles. To do this, pass either:
  ///     - more than 4 values (must be a multiple of 4: 8, 12…); example:
  ///       `47.3165,4.9665,47.3424,5.0201,40.9234,2.1185,38.6430,1.9916`;
  ///   - [aroundLatLng] and [aroundLatLngViaIP] will be ignored if used along
  ///     with this parameter.
  ///   - Be careful when your coordinates cross over the `180th meridian`.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/insideBoundingBox/)
  ///
  final List<double>? insideBoundingBox;

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
    bool? aroundLatLngViaIP,
    String? aroundLatLng,
    dynamic aroundRadius,
    int? aroundPrecision,
    int? minimumAroundRadius,
    List<double>? insideBoundingBox,
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
        aroundLatLngViaIP: aroundLatLngViaIP ?? this.aroundLatLngViaIP,
        aroundLatLng: aroundLatLng ?? this.aroundLatLng,
        aroundRadius: aroundRadius ?? this.aroundRadius,
        aroundPrecision: aroundPrecision ?? this.aroundPrecision,
        minimumAroundRadius: minimumAroundRadius ?? this.minimumAroundRadius,
        insideBoundingBox: insideBoundingBox ?? this.insideBoundingBox,
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
          clickAnalytics == other.clickAnalytics &&
          aroundLatLngViaIP == other.aroundLatLngViaIP &&
          aroundLatLng == other.aroundLatLng &&
          aroundRadius == other.aroundRadius &&
          aroundPrecision == other.aroundPrecision &&
          minimumAroundRadius == other.minimumAroundRadius &&
          insideBoundingBox.equals(other.insideBoundingBox);

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
      clickAnalytics.hashCode ^
      aroundLatLngViaIP.hashCode ^
      aroundLatLng.hashCode ^
      aroundRadius.hashCode ^
      aroundPrecision.hashCode ^
      minimumAroundRadius.hashCode ^
      insideBoundingBox.hashing();

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
      'clickAnalytics: $clickAnalytics, '
      'aroundLatLngViaIP: $aroundLatLngViaIP, '
      'aroundLatLng: $aroundLatLng, '
      'aroundRadius: $aroundRadius, '
      'aroundPrecision: $aroundPrecision, '
      'minimumAroundRadius: $minimumAroundRadius, '
      'insideBoundingBox: $insideBoundingBox}';
}
