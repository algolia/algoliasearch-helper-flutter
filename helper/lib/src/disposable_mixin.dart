import 'disposable.dart';

/// Mixin to abstract away `isDisposed` logic.
mixin DisposableMixin implements Disposable {
  @override
  bool isDisposed = false;

  @override
  void dispose() {
    if (!isDisposed) {
      doDispose();
      isDisposed = true;
    }
  }

  void doDispose();
}
