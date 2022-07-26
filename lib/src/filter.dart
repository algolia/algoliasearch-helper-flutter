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
}

class FilterTag implements Filter {
  FilterTag(this.value, [this.isNegated = false]);

  @override
  final String attribute = "_tag";
  @override
  final bool isNegated;
  final String value;
}

class FilterNumeric implements Filter {
  @override
  // TODO: implement attribute
  String get attribute => throw UnimplementedError();

  @override
  // TODO: implement isNegated
  bool get isNegated => throw UnimplementedError();
}
