import 'package:algoliasearch/algoliasearch.dart' as algolia;

import 'facet.dart';
import 'multi_search_response.dart';

/// Composition run operation response.
///
/// Wraps a single composition run result (a `results` item returned by the
/// Composition run endpoint). When the composition is a multifeed one, the
/// individual feed results are exposed through [feeds] (ordered), and this
/// response points to the first feed.
class CompositionResponse {
  /// Creates [CompositionResponse] instance.
  CompositionResponse(this.raw, {List<CompositionResponse>? feeds})
      : hits = _hitsFromList(raw['hits'] as List<dynamic>?),
        feeds = feeds == null || feeds.isEmpty ? null : List.unmodifiable(feeds),
        disjunctiveFacets = {},
        hierarchicalFacets = {};

  /// Raw composition result response
  final Map<String, dynamic> raw;

  /// Search hits list
  final List<Hit> hits;

  /// Ordered list of feed results for a multifeed composition.
  ///
  /// `null` when the composition run returned a single (non-feed) result.
  final List<CompositionResponse>? feeds;

  /// A mapping of each facet name to the corresponding facet counts for
  /// disjunctive facets.
  Map<String, List<Facet>> disjunctiveFacets;

  /// A mapping of each facet name to the corresponding facet counts for
  /// hierarchical facets.
  Map<String, List<Facet>> hierarchicalFacets;

  /// The ID of the feed, when this response is part of a multifeed composition.
  String? get feedID => raw['feedID'] as String?;

  /// Index name used for the composition's main source query.
  String? get index => raw['index'] as String?;

  /// An url-encoded string of all query parameters.
  String? get params => raw['params'] as String?;

  /// Identifies the query uniquely.
  String? get queryID => raw['queryID'] as String?;

  /// An echo of the query text.
  String get query => raw['query'] as String? ?? '';

  /// The maximum number of hits returned per page.
  int get hitsPerPage => raw['hitsPerPage'] as int? ?? 0;

  /// The number of hits matched by the query.
  int get nbHits => raw['nbHits'] as int? ?? 0;

  /// The number of returned pages.
  int get nbPages => raw['nbPages'] as int? ?? 0;

  /// Index of the current page (zero-based).
  int get page => raw['page'] as int? ?? 0;

  /// A mapping of each facet name to the corresponding facet counts.
  Map<String, List<Facet>> get facets =>
      Facet.fromMap(raw['facets'] as Map<String, dynamic>? ?? {});

  /// Statistics for numerical facets.
  Map<String, Map<String, num>> get facetsStats =>
      (raw['facets_stats'] as Map<String, dynamic>?)?.map(
        (key, value) =>
            MapEntry(key, Map<String, num>.from(value as Map? ?? {})),
      ) ??
      {};

  /// Time the server took to process the request, in milliseconds.
  int get processingTimeMS => raw['processingTimeMS'] as int? ?? 0;

  /// An object with custom data.
  Object userData() => raw['userData'] as Object? ?? {};

  /// Defines how you want to render results in the search interface.
  algolia.RenderingContent? get renderingContent =>
      raw['renderingContent'] != null
          ? algolia.RenderingContent.fromJson(
              raw['renderingContent'] as Map<String, dynamic>)
          : null;

  static List<Hit> _hitsFromList(List<dynamic>? data) {
    if (data == null) return const [];
    return data
        .map((hit) => Hit(Map<String, dynamic>.from(hit as Map)))
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompositionResponse &&
          runtimeType == other.runtimeType &&
          raw == other.raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => 'CompositionResponse{raw: $raw}';
}
