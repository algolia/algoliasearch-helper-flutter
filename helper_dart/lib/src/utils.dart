import 'package:collection/collection.dart';

/// Extensions over Object class.
extension ObjectExt<T> on T {
  /// Calls the specified function [action] with `this` as its argument and
  /// returns its result.
  R let<R>(R Function(T it) action) => action(this);

  /// Calls the specified function [action] with `this` value as its receiver
  /// and returns `this` value.
  T apply(Function(T it) action) {
    action(this);
    return this;
  }
}

/// Extension over [Map]
extension MapExt<K, E> on Map<K, E> {
  /// Convert [Map] entries into a list.
  List<T> toList<T>(T Function(K key, E value) builder) =>
      entries.map((e) => builder(e.key, e.value)).toList();

  /// Get unmodifiable copy of this Map.
  Map<K, E> unmodifiable() => Map<K, E>.unmodifiable(this);
}

/// Extension over [List]
extension ListExt<T> on List<T> {
  /// Get unmodifiable copy of this list.
  List<T> unmodifiable() => List<T>.unmodifiable(this);
}

/// Extension over [Set]
extension SetExt<T> on Set<T> {
  /// Get unmodifiable copy of this set.
  Set<T> unmodifiable() => Set<T>.unmodifiable(this);
}

final setEq = const SetEquality().equals;
final listEq = const ListEquality().equals;
