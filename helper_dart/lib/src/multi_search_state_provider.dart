import 'model/multi_search_state.dart';

abstract class MultiSearchStateProvider {
  Stream<MultiSearchState> get multiSearchState;
}