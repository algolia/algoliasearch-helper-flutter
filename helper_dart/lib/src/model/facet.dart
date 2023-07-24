import '../extensions.dart';

/// A value of a given facet, together with its number of occurrences.
/// Useful when an ordered list of facet values has to be presented to the user.
class Facet {
  /// Creates [Facet] instance.
  const Facet(this.value, this.count, [this.highlighted]);

  /// Creates Map of attributes and [Facet] lists from [json].
  static Map<String, List<Facet>> fromMap(Map<String, dynamic> json) =>
      json.map((key, value) {
        final facetsMap = Map<String, int>.from(value as Map? ?? {});
        final facetsList = facetsMap.toList(Facet.new);
        return MapEntry(key, facetsList);
      });

  static List<Facet> fromList(List<Map<String, dynamic>> json) => json
      .map(
        (rawFacet) => Facet(
          rawFacet['value'] as String,
          rawFacet['count'] as int,
          rawFacet['highlighted'] as String?,
        ),
      )
      .toList();

  /// Name of the facet. Is equal to the value associated to an attribute.
  final String value;

  /// Number of times this [value] occurs for a given attribute.
  final int count;

  /// Highlighted value.
  final String? highlighted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Facet &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          count == other.count &&
          highlighted == other.highlighted;

  @override
  int get hashCode => value.hashCode ^ count.hashCode ^ highlighted.hashCode;

  @override
  String toString() =>
      'Facet{value: $value, count: $count, highlighted: $highlighted}';
}
