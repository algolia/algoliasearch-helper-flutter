import 'disposable.dart';
import 'model/multi_search_state.dart';

abstract class MultiSearchStateProvider extends Disposable {
  Stream<MultiSearchState> get multiSearchState;
}