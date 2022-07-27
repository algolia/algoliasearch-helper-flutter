class Filter {
  Filter._(this.attribute, this.isNegated);

  final String attribute;
  final bool isNegated;
}

class FilterFacet implements Filter {
  FilterFacet(this.attribute, this.value, [this.isNegated = false, this.score]);

  @override
  final String attribute;
  @override
  final bool isNegated;
  final dynamic value;
  final int? score;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterFacet &&
          runtimeType == other.runtimeType &&
          attribute == other.attribute &&
          isNegated == other.isNegated &&
          value == other.value &&
          score == other.score;

  @override
  int get hashCode =>
      attribute.hashCode ^ isNegated.hashCode ^ value.hashCode ^ score.hashCode;

  @override
  String toString() {
    return 'FilterFacet{attribute: $attribute, isNegated: $isNegated, value: $value, score: $score}';
  }
}

class FilterTag implements Filter {
  FilterTag(this.value, [this.isNegated = false]);

  @override
  final String attribute = "_tag";
  @override
  final bool isNegated;
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterTag &&
          runtimeType == other.runtimeType &&
          attribute == other.attribute &&
          isNegated == other.isNegated &&
          value == other.value;

  @override
  int get hashCode => attribute.hashCode ^ isNegated.hashCode ^ value.hashCode;

  @override
  String toString() {
    return 'FilterTag{attribute: $attribute, isNegated: $isNegated, value: $value}';
  }
}

class FilterNumeric implements Filter {
  @override
  // TODO: implement attribute
  String get attribute => throw UnimplementedError();

  @override
  // TODO: implement isNegated
  bool get isNegated => throw UnimplementedError();
}
