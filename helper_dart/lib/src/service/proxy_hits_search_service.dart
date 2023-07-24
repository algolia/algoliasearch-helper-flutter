import 'package:rxdart/rxdart.dart';

import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import 'hits_search_service.dart';
import 'proxy_multi_search_service.dart';

class ProxyHitsSearchService
    implements HitsSearchService, ProxyMultiSearchService {
  final _stateStream = BehaviorSubject<SearchState>();
  final _responseStream = BehaviorSubject<SearchResponse>();

  Stream<SearchState> get state => _stateStream.stream;

  Stream<SearchResponse> get response => _responseStream.stream;

  void updateState(SearchState state) {
    _stateStream.add(state);
  }

  void updateResponse(SearchResponse response) {
    _responseStream.add(response);
  }

  @override
  void updateMultiResponse(MultiSearchResponse response) {
    switch (response) {
      case SearchResponse():
        updateResponse(response);
      default:
        break;
    }
  }

  @override
  Future<SearchResponse> search(SearchState state) {
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
