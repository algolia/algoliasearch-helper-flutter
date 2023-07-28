import '../extensions.dart';
import '../filter_group.dart';
part 'search_state.dart';
part 'facet_search_state.dart';

sealed class MultiSearchState {
  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  const MultiSearchState();
}
