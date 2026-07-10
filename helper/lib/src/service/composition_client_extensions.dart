import 'package:algolia_client_composition/algolia_client_composition.dart'
    as composition;
import 'package:collection/collection.dart';

import '../exception.dart';
import '../extensions.dart';
import '../filter.dart';
import '../filter_group.dart';
import '../filter_group_converter.dart';
import '../model/composition_facet_search_response.dart';
import '../model/composition_facet_search_state.dart';
import '../model/composition_response.dart';
import '../model/composition_state.dart';

/// Coerce an [composition.AlgoliaApiException] to a [SearchError].
Exception launderCompositionException(dynamic error) =>
    error is composition.AlgoliaApiException
        ? SearchError({'message': error.error.toString()}, error.statusCode,
            error)
        : SearchError({'message': error.toString()}, 0, error);

extension CompositionStateExt on CompositionState {
  /// Build a Composition run [composition.RequestBody] from this state.
  composition.RequestBody toRequestBody() =>
      composition.RequestBody(params: _toParams());

  /// Build a composition [composition.Params] from this state.
  composition.Params _toParams() {
    final filters = filterGroups?.let(
      (it) => const FilterGroupConverter().sql(it),
    );
    return composition.Params(
      query: query,
      page: page,
      hitsPerPage: hitsPerPage,
      facets: _buildFacets(),
      filters: filters,
      facetFilters: facetFilters,
      numericFilters: numericFilters,
      optionalFilters: optionalFilters,
      ruleContexts: ruleContexts,
      analytics: analytics,
      analyticsTags: analyticsTags,
      clickAnalytics: clickAnalytics,
      userToken: userToken,
      enableABTest: enableABTest,
      enablePersonalization: enablePersonalization,
      enableReRanking: enableReRanking,
      enableRules: enableRules,
      sortBy: sortBy,
      relevancyStrictness: relevancyStrictness,
      getRankingInfo: getRankingInfo,
      naturalLanguages: _toLanguages(naturalLanguages),
      queryLanguages: _toLanguages(queryLanguages),
      aroundLatLng: aroundLatLng,
      aroundLatLngViaIP: aroundLatLngViaIP,
      aroundRadius: aroundRadius,
      aroundPrecision: aroundPrecision,
      minimumAroundRadius: minimumAroundRadius,
      insideBoundingBox: insideBoundingBox,
      insidePolygon: insidePolygon,
      injectedItems: _toInjectedItems(injectedItems),
    );
  }

  /// Build the `facets` parameter by combining plain [facets] with
  /// [disjunctiveFacets], annotating disjunctive facets with the
  /// `disjunctive(...)` modifier only when they have a selected value.
  ///
  /// Annotating only selected disjunctive facets keeps the request under the
  /// Composition API limit of 20 disjunctive facets.
  List<String>? _buildFacets() {
    final plain = facets ?? const <String>[];
    final disjunctive = disjunctiveFacets ?? const <String>{};
    if (plain.isEmpty && disjunctive.isEmpty) return null;

    final refined = _refinedAttributes();
    final result = <String>{...plain};
    for (final facet in disjunctive) {
      result.add(refined.contains(facet) ? 'disjunctive($facet)' : facet);
    }
    if (result.contains('*')) return ['*'];
    final sorted = result.toList()..sort();
    return sorted;
  }

  /// Set of facet attributes that have at least one selected facet filter.
  Set<String> _refinedAttributes() {
    final attributes = <String>{};
    for (final group in filterGroups ?? const <FilterGroup>{}) {
      for (final filter in group) {
        if (filter is FilterFacet) {
          attributes.add(filter.attribute);
        }
      }
    }
    return attributes;
  }
}

extension CompositionFacetSearchStateExt on CompositionFacetSearchState {
  /// Build a composition [composition.SearchForFacetValuesRequest].
  composition.SearchForFacetValuesRequest toRequest() =>
      composition.SearchForFacetValuesRequest(
        params: composition.SearchForFacetValuesParams(
          query: facetQuery,
          searchQuery: state._toParams(),
        ),
      );
}

extension CompositionSearchResponseExt on composition.SearchResponse {
  /// Convert a Composition run [composition.SearchResponse] to a helper
  /// [CompositionResponse]. When the composition is multifeed, feed results
  /// are exposed through [CompositionResponse.feeds] (ordered).
  CompositionResponse toCompositionResponse() {
    final items = results.map((item) => item.toJson()).toList();
    if (items.isEmpty) {
      return CompositionResponse(const {});
    }
    final feeds = items
        .where((item) => item['feedID'] != null)
        .map(CompositionResponse.new)
        .toList();
    return CompositionResponse(items.first, feeds: feeds);
  }
}

extension CompositionFacetSearchResponseExt
    on composition.SearchForFacetValuesResponse {
  /// Convert a composition [composition.SearchForFacetValuesResponse] to a
  /// helper [CompositionFacetSearchResponse].
  CompositionFacetSearchResponse toFacetSearchResponse() {
    final first = results?.firstOrNull;
    return CompositionFacetSearchResponse(first?.toJson() ?? const {});
  }
}

List<composition.SupportedLanguage>? _toLanguages(List<String>? languages) =>
    languages?.map(composition.SupportedLanguage.fromJson).toList();

Map<String, composition.ExternalInjectedItem>? _toInjectedItems(
  Map<String, dynamic>? items,
) =>
    items?.map(
      (key, value) => MapEntry(
        key,
        composition.ExternalInjectedItem.fromJson(
          Map<String, dynamic>.from(value as Map),
        ),
      ),
    );
