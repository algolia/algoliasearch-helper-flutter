import 'package:algolia_helper_dart/algolia.dart';
import 'package:test/test.dart';

void main() {
  test('Highlight tokens generation', () {
    const string = 'This <em>John</em> Doe looks like <em>John</em>athan.';
    final highlighted = HighlightedString.of(string);

    expect(highlighted.tokens.length, 5);
  });
}
