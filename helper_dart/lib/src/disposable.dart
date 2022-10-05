import 'disposable_mixin.dart';
import 'facet_list.dart';
import 'filter_state.dart';
import 'hits_searcher.dart';

/// Represents an object able to release it's resources.
abstract class Disposable {
  /// Whether this [Disposable] has already released its resources.
  bool get isDisposed;

  /// Releases this [Disposable] resources.
  void dispose();
}

/// Acts as a container for multiple disposables that can be canceled at once.
///
/// Can be cleared or disposed. When disposed, cannot be used again.
///
/// ## Build composite disposable
///
/// Create a `CompositeDisposable` and add `Disposable` components
/// (e.g [HitsSearcher], [FilterState], [FacetList]) to it:
///
/// ```dart
/// final composite = CompositeDisposable()
///     ..add(searcher)
///     ..add(filterState)
///     ..add(facetList);
/// ```
///
/// Remove previously added `Disposable`:
///
/// ```dart
/// composite.remove(facetList);
/// ```
///
/// ## Cancel and clear
///
/// Cancel and remove all [Disposable]s added to the composite, and keep
/// the composite reusable:
///
/// ```dart
/// composite.clear();
/// ```
///
/// ## Dispose
///
/// Releases the resources of all [Disposable]s added to the composite:
///
/// ```dart
/// composite.dispose()
/// ```
abstract class CompositeDisposable implements Disposable {
  /// Creates [CompositeDisposable] instance.
  factory CompositeDisposable() => _CompositeDisposable();

  /// Returns the total amount of currently added [Disposable]s
  int get length;

  /// Checks if there currently are no [Disposable]s added
  bool get isEmpty;

  /// Adds [disposable] to this composite.
  /// Throws an exception if this composite was disposed
  Disposable add(Disposable disposable);

  /// Remove [disposable] from this composite and cancel it if it has been
  /// removed.
  void remove(Disposable disposable, {bool shouldDispose = true});

  /// Cancels all disposables added to this composite.
  /// Clears disposables collection.
  /// This composite can be reused after calling this method.
  void clear();
}

/// Default implementation of [CompositeDisposable].
class _CompositeDisposable with DisposableMixin implements CompositeDisposable {
  /// List of [Disposable]s.
  final List<Disposable> _disposables = [];

  @override
  int get length => _disposables.length;

  @override
  bool get isEmpty => _disposables.isEmpty;

  @override
  Disposable add(Disposable disposable) {
    if (isDisposed) {
      throw StateError(
          'This $runtimeType was disposed, consider checking `isDisposed` or'
          ' try to use new instance instead');
    }
    _disposables.add(disposable);
    return disposable;
  }

  @override
  void remove(
    Disposable disposable, {
    bool shouldDispose = true,
  }) =>
      _disposables.remove(disposable) && shouldDispose
          ? disposable.dispose()
          : null;

  @override
  void clear() {
    doDispose();
    _disposables.clear();
  }

  @override
  void doDispose() {
    for (final disposable in _disposables) {
      if (!disposable.isDisposed) disposable.dispose();
    }
  }
}
