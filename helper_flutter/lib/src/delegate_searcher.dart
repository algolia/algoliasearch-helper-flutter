import 'package:algolia_helper/algolia_helper.dart';

/// A [HitsSearcher] that delegates all operations to a base [hitsSearcher].
class DelegateHitsSearcher implements HitsSearcher {
  const DelegateHitsSearcher(this.hitsSearcher);

  /// Searcher to which all operations are delegated to.
  final HitsSearcher hitsSearcher;

  @override
  Stream<SearchState> get state => hitsSearcher.state;

  @override
  Stream<SearchResponse> get responses => hitsSearcher.responses;

  @override
  void query(String query) => hitsSearcher.query;

  @override
  SearchState snapshot() => hitsSearcher.snapshot();

  @override
  void applyState(StateConfig config) => hitsSearcher.applyState;

  @override
  void dispose() => hitsSearcher.dispose;

  @override
  bool get isDisposed => hitsSearcher.isDisposed;
}
