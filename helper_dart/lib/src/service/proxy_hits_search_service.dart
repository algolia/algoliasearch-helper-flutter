import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import '../searcher/multi_searcher.dart';
import 'hits_search_service.dart';

class ProxyHitsSearchService extends MultiSearcherDelegate
    implements HitsSearchService {
  @override
  Future<SearchResponse> search(SearchState state) {
    updateState(state);
    return response.map((response) => response as SearchResponse).first;
  }
}
