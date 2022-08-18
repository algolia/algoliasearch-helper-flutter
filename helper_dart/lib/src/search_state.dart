import 'package:collection/collection.dart';

import 'filter_group.dart';
import 'utils.dart';

/// Representation of search state.
class SearchState {
  const SearchState({
    required this.indexName,
    this.query,
    this.page,
    this.hitsPerPage,
    this.facets,
    this.disjunctiveFacets,
    this.filterGroups,
    this.attributesToRetrieve,
    this.attributesToHighlight,
    this.analytics,
    this.ruleContexts,
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

  /// Set of filter groups
  final Set<FilterGroup>? filterGroups;

  /// List of attributes to retrieve
  final List<String>? attributesToRetrieve;

  /// List of attributes to highlight
  final List<String>? attributesToHighlight;

  /// Whether the current query will be taken into account in the Analytics
  final bool? analytics;

  /// Search rule contexts
  final List<String>? ruleContexts;

  /// Make a copy of the search state.
  SearchState copyWith({
    String? indexName,
    String? query,
    int? page,
    int? hitsPerPage,
    List<String>? facets,
    Set<String>? disjunctiveFacets,
    Set<FilterGroup>? filterGroups,
    List<String>? attributesToRetrieve,
    List<String>? attributesToHighlight,
    bool? analytics,
    List<String>? ruleContexts,
  }) =>
      SearchState(
        indexName: indexName ?? this.indexName,
        query: query ?? this.query,
        page: page ?? this.page,
        hitsPerPage: hitsPerPage ?? this.hitsPerPage,
        facets: facets ?? this.facets,
        disjunctiveFacets: disjunctiveFacets ?? this.disjunctiveFacets,
        filterGroups: filterGroups ?? this.filterGroups,
        attributesToRetrieve: attributesToRetrieve ?? this.attributesToRetrieve,
        attributesToHighlight:
            attributesToHighlight ?? this.attributesToHighlight,
        analytics: analytics ?? this.analytics,
        ruleContexts: ruleContexts ?? this.ruleContexts,
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
          listEq(facets, other.facets) &&
          setEq(disjunctiveFacets, other.disjunctiveFacets) &&
          const SetEquality().equals(filterGroups, other.filterGroups) &&
          listEq(attributesToRetrieve, other.attributesToRetrieve) &&
          listEq(attributesToHighlight, other.attributesToHighlight) &&
          analytics == other.analytics &&
          listEq(ruleContexts, other.ruleContexts);

  @override
  int get hashCode =>
      indexName.hashCode ^
      query.hashCode ^
      page.hashCode ^
      hitsPerPage.hashCode ^
      facets.hashCode ^
      disjunctiveFacets.hashCode ^
      filterGroups.hashCode ^
      attributesToRetrieve.hashCode ^
      attributesToHighlight.hashCode ^
      analytics.hashCode ^
      ruleContexts.hashCode;

  @override
  String toString() => 'SearchState{'
      'indexName: $indexName,'
      ' query: $query,'
      ' page: $page,'
      ' hitsPerPage: $hitsPerPage,'
      ' facets: $facets,'
      ' disjunctiveFacets: $disjunctiveFacets,'
      ' filterGroups: $filterGroups,'
      ' attributesToRetrieve: $attributesToRetrieve,'
      ' attributesToHighlight: $attributesToHighlight,'
      ' analytics: $analytics,'
      ' ruleContexts: $ruleContexts'
      '}';
}
