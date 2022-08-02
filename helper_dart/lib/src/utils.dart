/// Extensions over Object class.
extension ObjectExt<T> on T {
  /// Calls the specified function [action] with `this` as its argument and returns its result.
  R let<R>(R Function(T it) action) => action(this);

  /// Calls the specified function [action] with `this` value as its receiver and returns `this` value.
  T apply(Function(T it) action) {
    action(this);
    return this;
  }
}
