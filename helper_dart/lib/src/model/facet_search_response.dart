part of 'multi_search_response.dart';

/// Search for facet values operation response
final class FacetSearchResponse extends MultiSearchResponse {
  /// Creates [FacetSearchResponse] instance.
  FacetSearchResponse(this.raw)
      : facetHits =
            Facet.fromList(raw['facetHits'] as List<Map<String, dynamic>>);

  /// Raw search response
  final Map<String, dynamic> raw;

  /// Search for facet values hits list
  final List<Facet> facetHits;

  /// Whether the count returned for each facets is exhaustive.
  bool get exhaustiveFacetsCount => raw['exhaustiveFacetsCount'] as bool;

  /// Time the server took to process the request, in milliseconds.
  /// This does not include network time.
  int get processingTimeMS => raw['processingTimeMS'] as int? ?? 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacetSearchResponse &&
          runtimeType == other.runtimeType &&
          raw == other.raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => 'FacetSearchResponse{raw: $raw}';
}
