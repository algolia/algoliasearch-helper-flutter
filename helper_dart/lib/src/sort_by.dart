import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'disposable.dart';
import 'disposable_mixin.dart';
import 'hits_searcher.dart';

/// Presents a list of available replica or virtual indices defining the sort
/// order.
abstract class SortBy implements Disposable {

  /// Creates [SortBy] instance.
  factory SortBy({
    required HitsSearcher searcher,
    required List<String> indexes,
    int? selected,
  }) =>
      _SortBy(searcher, indexes, selected);

  /// List of sorting indexes.
  List<String> get indexes;

  /// Stream of index selection events
  Stream<String> get selections;

  /// Selects an index from [indexes] by it's list index.
  void selected(int selected);

  /// Current selected index.
  String snapshot();
}

/// Default implementation of [SortBy].
class _SortBy with DisposableMixin implements SortBy {
  _SortBy(this._searcher, this._indexes, int? selected)
      : _selections = selected == null
            ? BehaviorSubject()
            : BehaviorSubject.seeded(_indexes[selected]) {
    _subscription = _selections.listen(
      (indexName) =>
          _searcher.applyState((state) => state.copyWith(indexName: indexName)),
    );
  }

  final HitsSearcher _searcher;
  final List<String> _indexes;
  final BehaviorSubject<String> _selections;
  late final StreamSubscription _subscription;

  @override
  List<String> get indexes => _indexes;

  @override
  late Stream<String> selections = _selections.stream;

  @override
  void selected(int selected) {
    final indexName = _indexes[selected];
    _selections.add(indexName);
  }

  @override
  String snapshot() => _selections.value;

  @override
  void doDispose() {
    _subscription.cancel();
    _selections.close();
  }
}
