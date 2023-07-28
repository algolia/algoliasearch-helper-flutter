import '../disposable.dart';
import '../model/multi_search_response.dart';

abstract class MultiSearchResponseReceiver implements Disposable {
  void updateMultiResponse(MultiSearchResponse response);
}
