/// Extensions over Object class.
extension ObjectExt<T> on T {
  /// Calls the specified function [block] with the extended object as its argument and returns its result.
  R let<R>(R Function(T it) block) => block(this);
}
