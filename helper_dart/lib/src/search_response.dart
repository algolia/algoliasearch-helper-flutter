import 'package:meta/meta.dart';

/// Search operation response.
class SearchResponse {
  @internal
  SearchResponse(this.raw)
      : hits = Hit._fromList(raw['hits']),
        disjunctiveFacets = {},
        hierarchicalFacets = {};

  /// Raw search response
  final Map<String, dynamic> raw;

  /// Search hits list
  final Iterable<Hit> hits;

  Map<String, Map<String, int>> disjunctiveFacets;

  Map<String, Map<String, int>> hierarchicalFacets;

  String get params => raw['params'] as String;

  String? get queryID => raw['queryID'] as String?;

  String get query => raw['query'] as String;

  int get hitsPerPage => raw['hitsPerPage'] as int? ?? 0;

  int get length => raw['length'] as int? ?? 0;

  int get nbHits => raw['nbHits'] as int? ?? 0;

  int get nbPages => raw['nbPages'] as int? ?? 0;

  int get offset => raw['offset'] as int? ?? 0;

  int get page => raw['page'] as int? ?? 0;

  Map<String, Map<String, int>> get facets =>
      raw['facets'] as Map<String, Map<String, int>>? ?? {};

  Map<String, Map<String, int>> get facetsStats =>
      raw['facets_stats'] as Map<String, Map<String, int>>? ?? {};

  bool get exhaustiveNbHits => raw['exhaustiveNbHits'] as bool;

  int get processingTimeMS => raw['processingTimeMS'] as int? ?? 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResponse &&
          runtimeType == other.runtimeType &&
          raw == other.raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => 'SearchResponse{raw: $raw}';
}

/// Represents search hit result
class Hit {
  Hit(this.json);

  factory Hit._from(Map hit) {
    final raw = Map<String, dynamic>.from(hit);
    return Hit(raw);
  }

  static Iterable<Hit> _fromList(data) {
    final hits = data as List?;
    if (hits == null) return const [];
    return List<Map>.from(hits).map(Hit._from).toList();
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
  String toString() => 'Hit{json: $json}';
}
