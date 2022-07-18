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
}
