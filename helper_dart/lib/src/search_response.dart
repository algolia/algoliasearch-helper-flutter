import 'package:collection/collection.dart';

import 'extensions.dart';

/// Search operation response.
class SearchResponse {
  /// Creates [SearchResponse] instance.
  SearchResponse(this.raw)
      : hits = Hit._fromList(raw['hits']),
        disjunctiveFacets = {},
        hierarchicalFacets = {};

  /// Raw search response
  final Map<String, dynamic> raw;

  /// Search hits list
  final List<Hit> hits;

  /// A mapping of each facet name to the corresponding facet counts for
  /// disjunctive facets.
  Map<String, List<Facet>> disjunctiveFacets;

  /// A mapping of each facet name to the corresponding facet counts for
  /// hierarchical facets.
  Map<String, List<Facet>> hierarchicalFacets;

  /// An url-encoded string of all query parameters.
  String get params => raw['params'] as String;

  /// Identifies the query uniquely.
  String? get queryID => raw['queryID'] as String?;

  /// An echo of the query text.
  String get query => raw['query'] as String;

  /// The maximum number of hits returned per page.
  /// Not returned if you use offset & length for pagination.
  int get hitsPerPage => raw['hitsPerPage'] as int? ?? 0;

  /// The number of hits matched by the query.
  int get nbHits => raw['nbHits'] as int? ?? 0;

  /// The number of returned pages.
  /// Calculation is based on the total number of hits (nbHits) divided by
  /// the number of hits per page (hitsPerPage), rounded up to the nearest
  /// integer.
  int get nbPages => raw['nbPages'] as int? ?? 0;

  /// Index of the current page (zero-based).
  int get page => raw['page'] as int? ?? 0;

  /// A mapping of each facet name to the corresponding facet counts.
  /// Returned only if `SearchState.facets` is non-empty.
  Map<String, List<Facet>> get facets =>
      Facet._fromMap(raw['facets'] as Map<String, dynamic>? ?? {});

  /// Statistics for numerical facets.
  /// Returned only if `SearchState.facets` is non-empty and at least one of
  /// the returned facets contains numerical values.
  Map<String, Map<String, num>> get facetsStats =>
      (raw['facets_stats'] as Map<String, dynamic>?)?.map(
            (key, value) =>
            MapEntry(key, Map<String, num>.from(value as Map? ?? {})),
      ) ??
          {};

  /// Whether the nbHits is exhaustive (true) or approximate (false).
  /// An approximation is done when the query takes more than 50ms to be
  /// processed (this can happen when using complex filters on millions on
  /// records).
  bool get exhaustiveNbHits => raw['exhaustiveNbHits'] as bool;

  /// Time the server took to process the request, in milliseconds.
  /// This does not include network time.
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
class Hit extends DelegatingMap<String, dynamic> {
  /// Creates [Hit] instance.
  Hit(this._json) : super(_json);

  /// Creates [Hit] instance from [hit].
  factory Hit._from(Map hit) {
    final raw = Map<String, dynamic>.from(hit);
    return Hit(raw);
  }

  /// Creates List of [Hit] from [data].
  static List<Hit> _fromList(data) {
    final hits = data as List?;
    if (hits == null) return const [];
    return List<Map>.from(hits).map(Hit._from).toList();
  }

  /// Hit raw json as map
  final Map<String, dynamic> _json;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hit && runtimeType == other.runtimeType && _json == other._json;

  @override
  int get hashCode => _json.hashCode;

  @override
  String toString() => 'Hit{json: $_json}';
}

/// A value of a given facet, together with its number of occurrences.
/// Useful when an ordered list of facet values has to be presented to the user.
class Facet {
  /// Creates [Facet] instance.
  const Facet(this.value, this.count, [this.highlighted]);

  /// Creates Map of attributes and [Facet] lists from [json].
  static Map<String, List<Facet>> _fromMap(Map<String, dynamic> json) =>
      json.map((key, value) {
        final facetsMap = Map<String, int>.from(value as Map? ?? {});
        final facetsList = facetsMap.toList(Facet.new);
        return MapEntry(key, facetsList);
      });

  /// Name of the facet. Is equal to the value associated to an attribute.
  final String value;

  /// Number of times this [value] occurs for a given attribute.
  final int count;

  /// Highlighted value.
  final String? highlighted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Facet &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          count == other.count &&
          highlighted == other.highlighted;

  @override
  int get hashCode => value.hashCode ^ count.hashCode ^ highlighted.hashCode;

  @override
  String toString() =>
      'Facet{value: $value, count: $count, highlighted: $highlighted}';
}
