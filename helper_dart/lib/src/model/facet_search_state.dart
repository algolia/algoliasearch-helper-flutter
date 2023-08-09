part of 'multi_search_state.dart';

/// Represents a search for facet values operation state, and an abstraction
/// over facet search queries.
/// ## Example
///
/// ```dart
/// final facetSearchState = FacetSearchState(
///   searchState: const SearchState(indexName: 'MY_INDEX_NAME'),
///   facet: 'brand',
///   facetQuery: 'samsung',
/// );
/// ```
final class FacetSearchState implements MultiSearchState {
  /// Creates [FacetSearchState] instance.
  const FacetSearchState({
    required this.facet,
    required this.searchState,
    this.facetQuery = '',
  });

  /// Facet name to search for
  final String facet;

  /// Text to search inside the facet’s values.
  final String facetQuery;

  /// Search operation state
  final SearchState searchState;

  /// Make a copy of the search state.
  FacetSearchState copyWith({
    String? facet,
    String? facetQuery,
    SearchState? searchState,
  }) =>
      FacetSearchState(
        facet: facet ?? this.facet,
        searchState: searchState ?? this.searchState,
        facetQuery: facetQuery ?? this.facetQuery,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacetSearchState &&
          runtimeType == other.runtimeType &&
          facet == other.facet &&
          facetQuery == other.facetQuery &&
          searchState == other.searchState;

  @override
  int get hashCode =>
      facet.hashCode ^
      facetQuery.hashCode ^
      searchState.hashCode;

  @override
  String toString() => 'FacetSearchState{'
      'facet: $facet, '
      'facetQuery: $facetQuery, '
      'searchState: $searchState}';
}
