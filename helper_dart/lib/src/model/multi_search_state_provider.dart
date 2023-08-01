import '../disposable.dart';
import '../searcher/multi_searcher.dart';
import 'multi_search_state.dart';
/// A contract for providing multi-search state to [MultiSearcher].
///
/// Classes that implement [MultiSearchStateProvider] should provide a [Stream]
/// of [MultiSearchState] that represents the individual states of multiple
/// searchers within the [MultiSearcher] component. [MultiSearchState] is an
/// interface that acts as a common type for [SearchState] and
/// [FacetSearchState].
abstract class MultiSearchStateProvider extends Disposable {
  /// Stream of [MultiSearchState] representing the individual states of
  /// searchers.
  Stream<MultiSearchState> get multiSearchState;
}