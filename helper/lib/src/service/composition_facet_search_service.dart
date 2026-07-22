import '../model/composition_facet_search_response.dart';
import '../model/composition_facet_search_state.dart';

/// A contract search Service handling composition facet search requests and
/// responses.
abstract class CompositionFacetSearchService {
  /// Send a composition facet search request [state] and asynchronously get a
  /// [CompositionFacetSearchResponse].
  Future<CompositionFacetSearchResponse> search(
    CompositionFacetSearchState state,
  );
}
