import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';

abstract class MultiSearchService {
  /// Send a list of search request [MultiSearchState] and asynchronously get a
  /// list of corresponding [MultiSearchResponse].
  Future<List<MultiSearchResponse>> search(
    List<MultiSearchState> states,
  );
}
