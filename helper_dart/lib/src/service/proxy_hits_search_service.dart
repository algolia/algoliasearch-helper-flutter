import 'package:rxdart/rxdart.dart';

import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import 'hits_search_service.dart';
import 'multi_search_response_receiver.dart';

class ProxyHitsSearchService
    implements HitsSearchService, MultiSearchResponseReceiver {
  final _stateStream = BehaviorSubject<SearchState>();
  final _responseStream = BehaviorSubject<SearchResponse>();
  bool _isDisposed = false;

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
    _isDisposed = true;
    _stateStream.close();
    _responseStream.close();
  }

  @override
  bool get isDisposed => _isDisposed;
}
