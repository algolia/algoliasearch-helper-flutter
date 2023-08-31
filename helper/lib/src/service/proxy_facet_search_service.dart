import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import '../searcher/multi_searcher.dart';
import 'facet_search_service.dart';

class ProxyFacetSearchService extends MultiSearcherDelegate
    implements FacetSearchService {
  @override
  Future<FacetSearchResponse> search(FacetSearchState state) {
    updateState(state);
    return response.map((response) => response as FacetSearchResponse).first;
  }
}
