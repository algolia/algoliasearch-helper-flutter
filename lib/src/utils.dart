/// Extensions over Object class.
extension ObjectExt<T> on T {
  /// Calls the specified function [block] with `this` as its argument and returns its result.
  R let<R>(R Function(T it) block) => block(this);

  /// Calls the specified function [block] with `this` value as its receiver and returns `this` value.
  T apply(Function(T it) block) {
    block(this);
    return this;
  }
}
