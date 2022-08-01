/// Search operation response.
class SearchResponse {
  SearchResponse(this.raw)
      : hits = (raw['hits'] as List<dynamic>? ?? [])
            .map((hit) => Hit.from(hit))
            .toList();

  /// Raw search response
  final Map<String, dynamic> raw;

  /// Search hits list
  final List<Hit> hits;

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

/// Represents search hit result
class Hit {
  Hit(this.json);

  factory Hit.from(Map hit) {
    final raw = Map<String, dynamic>.from(hit);
    return Hit(raw);
  }

  /// Hit raw json as map
  final Map<String, dynamic> json;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hit && runtimeType == other.runtimeType && json == other.json;

  @override
  int get hashCode => json.hashCode;

  @override
  String toString() {
    return 'Hit{json: $json}';
  }
}
