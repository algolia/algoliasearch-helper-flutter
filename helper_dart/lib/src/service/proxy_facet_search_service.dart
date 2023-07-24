import 'package:rxdart/rxdart.dart';

import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import 'facet_search_service.dart';
import 'proxy_multi_search_service.dart';

class ProxyFacetSearchService
    implements FacetSearchService, ProxyMultiSearchService {
  final _stateStream = BehaviorSubject<FacetSearchState>();
  final _responseStream = BehaviorSubject<FacetSearchResponse>();

  Stream<FacetSearchState> get state => _stateStream.stream;

  Stream<FacetSearchResponse> get response => _responseStream.stream;

  void updateState(FacetSearchState state) {
    _stateStream.add(state);
  }

  void updateResponse(FacetSearchResponse response) {
    _responseStream.add(response);
  }

  @override
  void updateMultiResponse(MultiSearchResponse response) {
    switch (response) {
      case FacetSearchResponse():
        updateResponse(response);
      default:
        break;
    }
  }

  @override
  Future<FacetSearchResponse> search(FacetSearchState state) {
    _stateStream.add(state);
    updateState(state);
    return response.first;
  }

  @override
  void dispose() {
    _stateStream.close();
    _responseStream.close();
  }
}
