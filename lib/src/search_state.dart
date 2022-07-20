class SearchState {
  const SearchState({this.query, this.page, this.hitsPerPage, this.facets});

  final String? query;
  final int? page;
  final int? hitsPerPage;
  final List<String>? facets;

  SearchState copyWith(
      {String? query, int? page, int? hitsPerPage, List<String>? facets}) {
    return SearchState(
      query: query ?? this.query,
      page: page ?? this.page,
      hitsPerPage: hitsPerPage ?? this.hitsPerPage,
      facets: facets ?? this.facets,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchState &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          page == other.page &&
          hitsPerPage == other.hitsPerPage &&
          facets == other.facets;

  @override
  int get hashCode =>
      query.hashCode ^ page.hashCode ^ hitsPerPage.hashCode ^ facets.hashCode;

  @override
  String toString() {
    return 'SearchState{query: $query, page: $page, hitsPerPage: $hitsPerPage, facets: $facets}';
  }
}
