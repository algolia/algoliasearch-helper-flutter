import '../disposable.dart';
import '../searcher/multi_searcher.dart';
import 'multi_search_response.dart';
/// A contract for receiving multi-search responses in [MultiSearcher].
///
/// Classes that implement [MultiSearchResponseReceiver] should define a method
/// to receive [MultiSearchResponse] instances. These responses are distributed
/// from the batch search to corresponding sub-searchers within the
/// [MultiSearcher] component.
abstract class MultiSearchResponseReceiver implements Disposable {
  /// Receives a [MultiSearchResponse] from batch search.
  void updateMultiResponse(MultiSearchResponse response);
}
