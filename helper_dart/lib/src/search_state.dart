import 'filter_group.dart';

/// Representation of search state.
class SearchState {
  const SearchState(
      {required this.indexName,
      this.query,
      this.page,
      this.hitsPerPage,
      this.facets,
      this.filterGroups,
      this.ruleContexts});

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

  /// Set of filter groups
  final Set<FilterGroup>? filterGroups;

  /// Search rule contexts
  final List<String>? ruleContexts;

  /// Make a copy of the search state.
  SearchState copyWith(
      {String? indexName,
      String? query,
      int? page,
      int? hitsPerPage,
      List<String>? facets,
      Set<FilterGroup>? filterGroups,
      List<String>? ruleContexts}) {
    return SearchState(
        indexName: indexName ?? this.indexName,
        query: query ?? this.query,
        page: page ?? this.page,
        hitsPerPage: hitsPerPage ?? this.hitsPerPage,
        facets: facets ?? this.facets,
        filterGroups: filterGroups ?? this.filterGroups,
        ruleContexts: ruleContexts ?? this.ruleContexts);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchState &&
          runtimeType == other.runtimeType &&
          indexName == other.indexName &&
          query == other.query &&
          page == other.page &&
          hitsPerPage == other.hitsPerPage &&
          facets == other.facets &&
          filterGroups == other.filterGroups &&
          ruleContexts == other.ruleContexts;

  @override
  int get hashCode =>
      indexName.hashCode ^
      query.hashCode ^
      page.hashCode ^
      hitsPerPage.hashCode ^
      facets.hashCode ^
      filterGroups.hashCode ^
      ruleContexts.hashCode;

  @override
  String toString() {
    return 'SearchState{indexName: $indexName, query: $query, page: $page, hitsPerPage: $hitsPerPage, facets: $facets, filterGroups: $filterGroups, ruleContexts: $ruleContexts}';
  }
}
