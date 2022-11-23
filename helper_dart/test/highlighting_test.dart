import 'package:algolia_helper/algolia_helper.dart';
import 'package:test/test.dart';

void main() {
  test('Highlight tokens generation', () {
    const string = 'This <em>John</em> Doe looks like <em>John</em>athan.';
    final highlighted = HighlightedString.of(string);
    expect(highlighted.tokens.length, 5);
  });

  test('Highlight tokens generation with apostrophe', () {
    const string = "<em>John's</em> looks like <em>Jones</em>";
    final highlighted = HighlightedString.of(string);
    expect(highlighted.tokens.length, 3);
  });
}
