import 'composition_state.dart';

/// Represents a search for facet values operation state on a composition, and
/// an abstraction over composition facet search queries.
///
/// ## Example
///
/// ```dart
/// final facetSearchState = CompositionFacetSearchState(
///   compositionID: 'MY_COMPOSITION_ID',
///   facet: 'brand',
///   facetQuery: 'samsung',
///   state: const CompositionState(compositionID: 'MY_COMPOSITION_ID'),
/// );
/// ```
final class CompositionFacetSearchState {
  /// Creates [CompositionFacetSearchState] instance.
  const CompositionFacetSearchState({
    required this.compositionID,
    required this.facet,
    required this.state,
    this.facetQuery = '',
  });

  /// Unique Composition ObjectID to search facet values in.
  final String compositionID;

  /// Facet name to search for.
  final String facet;

  /// Text to search inside the facet's values.
  final String facetQuery;

  /// Composition search operation state.
  final CompositionState state;

  /// Make a copy of the composition facet search state.
  CompositionFacetSearchState copyWith({
    String? compositionID,
    String? facet,
    String? facetQuery,
    CompositionState? state,
  }) =>
      CompositionFacetSearchState(
        compositionID: compositionID ?? this.compositionID,
        facet: facet ?? this.facet,
        facetQuery: facetQuery ?? this.facetQuery,
        state: state ?? this.state,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompositionFacetSearchState &&
          runtimeType == other.runtimeType &&
          compositionID == other.compositionID &&
          facet == other.facet &&
          facetQuery == other.facetQuery &&
          state == other.state;

  @override
  int get hashCode =>
      compositionID.hashCode ^
      facet.hashCode ^
      facetQuery.hashCode ^
      state.hashCode;

  @override
  String toString() => 'CompositionFacetSearchState{'
      'compositionID: $compositionID, '
      'facet: $facet, '
      'facetQuery: $facetQuery, '
      'state: $state}';
}
