import 'package:rxdart/rxdart.dart';

import '../model/multi_search_response.dart';
import '../model/multi_search_response_receiver.dart';
import '../model/multi_search_state.dart';
import 'facet_search_service.dart';

class ProxyFacetSearchService
    implements FacetSearchService, MultiSearchResponseReceiver {
  final _stateStream = BehaviorSubject<FacetSearchState>();
  final _responseStream = BehaviorSubject<FacetSearchResponse>();
  bool _isDisposed = false;

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
    _isDisposed = true;
    _stateStream.close();
    _responseStream.close();
  }

  @override
  bool get isDisposed => _isDisposed;
}
