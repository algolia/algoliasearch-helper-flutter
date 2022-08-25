import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () {
    const string = 'This <em>John</em> Doe looks like <em>John</em>athan.';
    final highlighted = HighlightedString.of(string);
    final spans = highlighted.toTextSpans();
    expect(spans.length, 5);
  });
}
