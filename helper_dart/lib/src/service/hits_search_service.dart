import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';

/// A contract search Service handling search requests and responses.
abstract class HitsSearchService {
  /// Send a search request [state] and asynchronously get a [SearchResponse].
  Future<SearchResponse> search(SearchState state);
}