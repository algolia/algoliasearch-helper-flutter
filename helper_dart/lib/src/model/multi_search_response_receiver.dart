import '../disposable.dart';
import 'multi_search_response.dart';

abstract class MultiSearchResponseReceiver implements Disposable {
  void updateMultiResponse(MultiSearchResponse response);
}
