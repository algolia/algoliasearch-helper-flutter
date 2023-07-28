import '../disposable.dart';
import 'multi_search_state.dart';

abstract class MultiSearchStateProvider extends Disposable {
  Stream<MultiSearchState> get multiSearchState;
}