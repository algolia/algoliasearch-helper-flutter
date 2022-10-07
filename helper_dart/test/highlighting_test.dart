import 'package:algolia_helper/algolia_helper.dart';
import 'package:test/test.dart';

void main() {
  test('Highlight tokens generation', () {
    const string = 'This <em>John</em> Doe looks like <em>John</em>athan.';
    final highlighted = HighlightedString.of(string);
    print(highlighted);
    expect(highlighted.tokens.length, 5);
  });
}
