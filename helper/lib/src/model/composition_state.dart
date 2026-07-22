import '../extensions.dart';
import '../filter_group.dart';

/// Represents a composition run operation state, and an abstraction over
/// composition search queries.
///
/// A [CompositionState] targets a single composition identified by its
/// [compositionID] and exposes the subset of search parameters supported by
/// the Composition run endpoint (`/1/compositions/{compositionID}/run`).
///
/// ## Example
///
/// ```dart
/// const compositionState = CompositionState(
///   compositionID: 'MY_COMPOSITION_ID',
///   query: 'shoes',
///   page: 1,
///   hitsPerPage: 20,
/// );
/// ```
class CompositionState {
  /// Creates [CompositionState] instance.
  const CompositionState({
    required this.compositionID,
    this.query,
    this.page,
    this.hitsPerPage,
    this.facets,
    this.disjunctiveFacets,
    this.filterGroups,
    this.facetFilters,
    this.numericFilters,
    this.optionalFilters,
    this.ruleContexts,
    this.analytics,
    this.analyticsTags,
    this.clickAnalytics,
    this.userToken,
    this.enableABTest,
    this.enablePersonalization,
    this.enableReRanking,
    this.enableRules,
    this.sortBy,
    this.relevancyStrictness,
    this.getRankingInfo,
    this.naturalLanguages,
    this.queryLanguages,
    this.aroundLatLng,
    this.aroundLatLngViaIP,
    this.aroundRadius,
    this.aroundPrecision,
    this.minimumAroundRadius,
    this.insideBoundingBox,
    this.insidePolygon,
    this.injectedItems,
  });

  /// Unique Composition ObjectID to run.
  final String compositionID;

  /// Search query string.
  final String? query;

  /// Search page number.
  final int? page;

  /// Number of hits per page.
  final int? hitsPerPage;

  /// Search facets list.
  final List<String>? facets;

  /// Disjunctive facets list.
  ///
  /// Disjunctive facets are annotated with the `disjunctive(...)` modifier in
  /// the composition `facets` parameter when they have a selected value.
  final Set<String>? disjunctiveFacets;

  /// Set of filter groups.
  final Set<FilterGroup>? filterGroups;

  /// Filter hits by facet value.
  final List<String>? facetFilters;

  /// Filter on numeric attributes.
  final List<String>? numericFilters;

  /// Create filters for ranking purposes, where records that match the filter
  /// are ranked highest.
  final List<String>? optionalFilters;

  /// Composition rule contexts.
  final List<String>? ruleContexts;

  /// Whether the current query will be taken into account in the Analytics.
  final bool? analytics;

  /// Tags to apply to the query for segmenting analytics data.
  final List<String>? analyticsTags;

  /// Add a query ID parameter to the response for tracking click and conversion
  /// events.
  final bool? clickAnalytics;

  /// Associates a certain user token with the current search.
  final String? userToken;

  /// Whether to enable index level A/B testing for this run request.
  final bool? enableABTest;

  /// Whether to enable Personalization.
  final bool? enablePersonalization;

  /// Whether this search will use Dynamic Re-Ranking.
  final bool? enableReRanking;

  /// Whether to enable composition rules.
  final bool? enableRules;

  /// Indicates which sorting strategy to apply for the request.
  final String? sortBy;

  /// Relevancy threshold below which less relevant results aren't included in
  /// the results.
  final int? relevancyStrictness;

  /// Whether the run response should include detailed ranking information.
  final bool? getRankingInfo;

  /// ISO language codes that adjust settings that are useful for processing
  /// natural language queries.
  final List<String>? naturalLanguages;

  /// Languages for language-specific query processing steps.
  final List<String>? queryLanguages;

  /// Coordinates for the center of a circle, expressed as a comma-separated
  /// string of latitude and longitude.
  final String? aroundLatLng;

  /// Whether to obtain the coordinates from the request's IP address.
  final bool? aroundLatLngViaIP;

  /// Maximum radius for a geo search (in meters). Value must be an [int] or
  /// `'all'`.
  final dynamic aroundRadius;

  /// Precision of a geo search (in meters).
  final int? aroundPrecision;

  /// Minimum radius (in meters) for a search around a location when
  /// `aroundRadius` isn't set.
  final int? minimumAroundRadius;

  /// Search inside a rectangular area (in geo coordinates).
  final List<List<double>>? insideBoundingBox;

  /// Coordinates of a polygon in which to search.
  final List<List<double>>? insidePolygon;

  /// A map of externally injected objectID groups from an external source.
  ///
  /// Keys are group identifiers, values are the raw JSON representation of an
  /// external injected item (`{'items': [...]}`).
  final Map<String, dynamic>? injectedItems;

  /// Make a copy of the composition state.
  CompositionState copyWith({
    String? compositionID,
    String? query,
    int? page,
    int? hitsPerPage,
    List<String>? facets,
    Set<String>? disjunctiveFacets,
    Set<FilterGroup>? filterGroups,
    List<String>? facetFilters,
    List<String>? numericFilters,
    List<String>? optionalFilters,
    List<String>? ruleContexts,
    bool? analytics,
    List<String>? analyticsTags,
    bool? clickAnalytics,
    String? userToken,
    bool? enableABTest,
    bool? enablePersonalization,
    bool? enableReRanking,
    bool? enableRules,
    String? sortBy,
    int? relevancyStrictness,
    bool? getRankingInfo,
    List<String>? naturalLanguages,
    List<String>? queryLanguages,
    String? aroundLatLng,
    bool? aroundLatLngViaIP,
    dynamic aroundRadius,
    int? aroundPrecision,
    int? minimumAroundRadius,
    List<List<double>>? insideBoundingBox,
    List<List<double>>? insidePolygon,
    Map<String, dynamic>? injectedItems,
  }) =>
      CompositionState(
        compositionID: compositionID ?? this.compositionID,
        query: query ?? this.query,
        page: page ?? this.page,
        hitsPerPage: hitsPerPage ?? this.hitsPerPage,
        facets: facets ?? this.facets,
        disjunctiveFacets: disjunctiveFacets ?? this.disjunctiveFacets,
        filterGroups: filterGroups ?? this.filterGroups,
        facetFilters: facetFilters ?? this.facetFilters,
        numericFilters: numericFilters ?? this.numericFilters,
        optionalFilters: optionalFilters ?? this.optionalFilters,
        ruleContexts: ruleContexts ?? this.ruleContexts,
        analytics: analytics ?? this.analytics,
        analyticsTags: analyticsTags ?? this.analyticsTags,
        clickAnalytics: clickAnalytics ?? this.clickAnalytics,
        userToken: userToken ?? this.userToken,
        enableABTest: enableABTest ?? this.enableABTest,
        enablePersonalization:
            enablePersonalization ?? this.enablePersonalization,
        enableReRanking: enableReRanking ?? this.enableReRanking,
        enableRules: enableRules ?? this.enableRules,
        sortBy: sortBy ?? this.sortBy,
        relevancyStrictness: relevancyStrictness ?? this.relevancyStrictness,
        getRankingInfo: getRankingInfo ?? this.getRankingInfo,
        naturalLanguages: naturalLanguages ?? this.naturalLanguages,
        queryLanguages: queryLanguages ?? this.queryLanguages,
        aroundLatLng: aroundLatLng ?? this.aroundLatLng,
        aroundLatLngViaIP: aroundLatLngViaIP ?? this.aroundLatLngViaIP,
        aroundRadius: aroundRadius ?? this.aroundRadius,
        aroundPrecision: aroundPrecision ?? this.aroundPrecision,
        minimumAroundRadius: minimumAroundRadius ?? this.minimumAroundRadius,
        insideBoundingBox: insideBoundingBox ?? this.insideBoundingBox,
        insidePolygon: insidePolygon ?? this.insidePolygon,
        injectedItems: injectedItems ?? this.injectedItems,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompositionState &&
          runtimeType == other.runtimeType &&
          compositionID == other.compositionID &&
          query == other.query &&
          page == other.page &&
          hitsPerPage == other.hitsPerPage &&
          facets.equals(other.facets) &&
          disjunctiveFacets.equals(other.disjunctiveFacets) &&
          filterGroups.equals(other.filterGroups) &&
          facetFilters.equals(other.facetFilters) &&
          numericFilters.equals(other.numericFilters) &&
          optionalFilters.equals(other.optionalFilters) &&
          ruleContexts.equals(other.ruleContexts) &&
          analytics == other.analytics &&
          analyticsTags.equals(other.analyticsTags) &&
          clickAnalytics == other.clickAnalytics &&
          userToken == other.userToken &&
          enableABTest == other.enableABTest &&
          enablePersonalization == other.enablePersonalization &&
          enableReRanking == other.enableReRanking &&
          enableRules == other.enableRules &&
          sortBy == other.sortBy &&
          relevancyStrictness == other.relevancyStrictness &&
          getRankingInfo == other.getRankingInfo &&
          naturalLanguages.equals(other.naturalLanguages) &&
          queryLanguages.equals(other.queryLanguages) &&
          aroundLatLng == other.aroundLatLng &&
          aroundLatLngViaIP == other.aroundLatLngViaIP &&
          aroundRadius == other.aroundRadius &&
          aroundPrecision == other.aroundPrecision &&
          minimumAroundRadius == other.minimumAroundRadius &&
          insideBoundingBox.equals(other.insideBoundingBox) &&
          insidePolygon.equals(other.insidePolygon) &&
          injectedItems.equals(other.injectedItems);

  @override
  int get hashCode =>
      compositionID.hashCode ^
      query.hashCode ^
      page.hashCode ^
      hitsPerPage.hashCode ^
      facets.hashing() ^
      disjunctiveFacets.hashing() ^
      filterGroups.hashing() ^
      facetFilters.hashing() ^
      numericFilters.hashing() ^
      optionalFilters.hashing() ^
      ruleContexts.hashing() ^
      analytics.hashCode ^
      analyticsTags.hashing() ^
      clickAnalytics.hashCode ^
      userToken.hashCode ^
      enableABTest.hashCode ^
      enablePersonalization.hashCode ^
      enableReRanking.hashCode ^
      enableRules.hashCode ^
      sortBy.hashCode ^
      relevancyStrictness.hashCode ^
      getRankingInfo.hashCode ^
      naturalLanguages.hashing() ^
      queryLanguages.hashing() ^
      aroundLatLng.hashCode ^
      aroundLatLngViaIP.hashCode ^
      aroundRadius.hashCode ^
      aroundPrecision.hashCode ^
      minimumAroundRadius.hashCode ^
      insideBoundingBox.hashing() ^
      insidePolygon.hashing() ^
      injectedItems.hashing();

  @override
  String toString() => 'CompositionState{'
      'compositionID: $compositionID, '
      'query: $query, '
      'page: $page, '
      'hitsPerPage: $hitsPerPage, '
      'facets: $facets, '
      'disjunctiveFacets: $disjunctiveFacets, '
      'filterGroups: $filterGroups, '
      'facetFilters: $facetFilters, '
      'numericFilters: $numericFilters, '
      'optionalFilters: $optionalFilters, '
      'ruleContexts: $ruleContexts, '
      'analytics: $analytics, '
      'analyticsTags: $analyticsTags, '
      'clickAnalytics: $clickAnalytics, '
      'userToken: $userToken, '
      'enableABTest: $enableABTest, '
      'enablePersonalization: $enablePersonalization, '
      'enableReRanking: $enableReRanking, '
      'enableRules: $enableRules, '
      'sortBy: $sortBy, '
      'relevancyStrictness: $relevancyStrictness, '
      'getRankingInfo: $getRankingInfo, '
      'naturalLanguages: $naturalLanguages, '
      'queryLanguages: $queryLanguages, '
      'aroundLatLng: $aroundLatLng, '
      'aroundLatLngViaIP: $aroundLatLngViaIP, '
      'aroundRadius: $aroundRadius, '
      'aroundPrecision: $aroundPrecision, '
      'minimumAroundRadius: $minimumAroundRadius, '
      'insideBoundingBox: $insideBoundingBox, '
      'insidePolygon: $insidePolygon, '
      'injectedItems: $injectedItems}';
}
