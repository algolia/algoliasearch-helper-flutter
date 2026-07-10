import 'facet.dart';

/// Search for facet values operation response for a composition.
class CompositionFacetSearchResponse {
  /// Creates [CompositionFacetSearchResponse] instance.
  CompositionFacetSearchResponse(this.raw)
      : facetHits = Facet.fromList(
          List<Map<String, dynamic>>.from(
            (raw['facetHits'] as List<dynamic>? ?? []).map(
              (e) => Map<String, dynamic>.from(e as Map),
            ),
          ),
        );

  /// Raw facet search response
  final Map<String, dynamic> raw;

  /// Search for facet values hits list
  final List<Facet> facetHits;

  /// Whether the count returned for each facets is exhaustive.
  bool get exhaustiveFacetsCount => raw['exhaustiveFacetsCount'] as bool? ?? false;

  /// Time the server took to process the request, in milliseconds.
  int get processingTimeMS => raw['processingTimeMS'] as int? ?? 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompositionFacetSearchResponse &&
          runtimeType == other.runtimeType &&
          raw == other.raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => 'CompositionFacetSearchResponse{raw: $raw}';
}
