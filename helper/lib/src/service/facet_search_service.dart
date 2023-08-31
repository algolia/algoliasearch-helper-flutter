import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';

/// A contract search Service handling facet search requests and responses.
abstract class FacetSearchService {
  /// Send a facet search request [state] and asynchronously get
  /// a [FacetSearchResponse].
  Future<FacetSearchResponse> search(FacetSearchState state);
}
