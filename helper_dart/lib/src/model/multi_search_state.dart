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

// class HitsSearchStateWrapper extends MultiSearchState {
//   SearchState state;
//
//   HitsSearchStateWrapper(this.state);
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is HitsSearchStateWrapper && state == other.state;
//
//   @override
//   int get hashCode => state.hashCode;
// }
//
// extension SearchStateMultiSearchWrapExt on SearchState {
//   HitsSearchStateWrapper wrapForMultiSearch() => HitsSearchStateWrapper(this);
// }
//
// class FacetSearchStateWrapper extends MultiSearchState {
//   FacetSearchState state;
//
//   FacetSearchStateWrapper(this.state);
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is FacetSearchStateWrapper && state == other.state;
//
//   @override
//   int get hashCode => state.hashCode;
// }
//
// extension FacetSearchStateMultiSearchWrapExt on FacetSearchState {
//   FacetSearchStateWrapper wrapForMultiSearch() => FacetSearchStateWrapper(this);
// }
