/// Search operation response.
class SearchResponse {
  SearchResponse(this.raw);

  /// Raw search response
  final Map<String, dynamic> raw;

  List<dynamic> get hits => raw['hits'] ?? [];

  String get params => raw['params'];

  String? get queryID => raw['queryID'];

  String get query => raw['query'];

  int get hitsPerPage => raw['hitsPerPage'] ?? 0;

  int get length => raw['length'] ?? 0;

  int get nbHits => raw['nbHits'] ?? 0;

  int get nbPages => raw['nbPages'] ?? 0;

  int get offset => raw['offset'] ?? 0;

  int get page => raw['page'] ?? 0;

  Map<String, dynamic> get facets => raw['facets'] ?? {};

  Map<String, dynamic> get facetsStats => raw['facets_stats'] ?? {};

  bool get exhaustiveNbHits => raw['exhaustiveNbHits'];

  int get processingTimeMS => raw['processingTimeMS'] ?? 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResponse &&
          runtimeType == other.runtimeType &&
          raw == other.raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() {
    return 'SearchResponse{raw: $raw}';
  }
}
