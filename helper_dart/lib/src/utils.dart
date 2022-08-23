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

/// Extension over [Map]
extension MapNullableExt<K, E> on Map<K, E>? {
  static const _mapEquality = MapEquality();

  /// Uses [ListEquality] to calculate equality.
  bool equals(Map? other) => _mapEquality.equals(this, other);

  /// Uses [ListEquality] to calculate hashcode.
  int hashing() => _mapEquality.hash(this);
}

/// Extension over [List]
extension ListExt<T> on List<T> {
  /// Get unmodifiable copy of this list.
  List<T> unmodifiable() => List<T>.unmodifiable(this);
}

/// Extension over [List]
extension ListNullableExt<T> on List<T>? {
  static const _listEquality = ListEquality();

  /// Uses [ListEquality] to calculate equality.
  bool equals(List? other) => _listEquality.equals(this, other);

  /// Uses [ListEquality] to calculate hashcode.
  int hashing() => _listEquality.hash(this);
}

/// Extension over [Set]
extension SetExt<T> on Set<T> {
  /// Get unmodifiable copy of this set.
  Set<T> unmodifiable() => Set<T>.unmodifiable(this);
}

/// Extension over [Set]
extension SetNullabkeExt<T> on Set<T>? {
  static const _setEquality = SetEquality();

  /// Uses [SetEquality] to calculate equality.
  bool equals(Set? other) => _setEquality.equals(this, other);

  /// Uses [SetEquality] to calculate hashcode.
  int hashing() => _setEquality.hash(this);
}

extension IterableExt<T> on Iterable<T> {
  /// Creates a string from all the elements separated using [separator] and
  /// using the given [prefix] and [postfix] if supplied.
  ///
  /// If the collection could be huge, you can specify a non-negative value of
  /// [limit], in which case only the first [limit] elements will be appended,
  /// followed by the [truncated] string (which defaults to "...").
  String joinToString({
    String separator = ', ',
    String prefix = '',
    String postfix = '',
    int limit = -1,
    String truncated = '...',
    String Function(T element)? transform,
  }) {
    final buffer = StringBuffer(prefix);
    var count = 0;
    for (final element in this) {
      if (++count > 1) buffer.write(separator);
      if (limit < 0 || count <= limit) {
        final string =
            transform != null ? transform(element) : element.toString();
        buffer.write(string);
      } else {
        break;
      }
    }
    if (limit >= 0 && count > limit) buffer.write(truncated);
    buffer.write(postfix);
    return buffer.toString();
  }
}
