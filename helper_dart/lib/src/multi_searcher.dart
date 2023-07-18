import 'package:rxdart/rxdart.dart';

import '../algolia_helper.dart';
import 'search_request.dart';
import 'service/multi_search_service.dart';

abstract class SearchService {
  Future<List<SearchResponse>> performSearch(List<SearchState> requests);
}

class MultiSearcher implements Disposable {
  List<HitsSearcher> searchers;
  final SearchService _service;

  Stream<List<SearchResponse>> results;

  MultiSearcher(this.searchers, this._service)
      : results = Rx.combineLatest(
          searchers.map((e) => e.state),
          (states) => states.cast<SearchState>(),
        ).asyncMap(_service.performSearch);

  @override
  void dispose() {}

  @override
  bool get isDisposed => throw UnimplementedError();
}
