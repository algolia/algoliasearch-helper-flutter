import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () {
    const string = 'This <em>John</em> Doe looks like <em>John</em>athan.';
    final highlighted = HighlightedString.of(string);
    const regularStyle =
        TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF421133));
    const highlightedStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF42A5F5));
    final span = highlighted.toTextSpan(
      regularTextStyle: regularStyle,
      highlightedTextStyle: highlightedStyle,
    );
    expect(span.children?.length, 5);
    span.children?.asMap().forEach((index, value) {
      switch (index) {
        case 0:
          expect(value.toPlainText(), 'This ');
          expect(value.style, regularStyle);
          break;
        case 1:
          expect(value.toPlainText(), 'John');
          expect(value.style, highlightedStyle);
          break;
        case 2:
          expect(value.toPlainText(), ' Doe looks like ');
          expect(value.style, regularStyle);
          break;
        case 3:
          expect(value.toPlainText(), 'John');
          expect(value.style, highlightedStyle);
          break;
        case 4:
          expect(value.toPlainText(), 'athan.');
          expect(value.style, regularStyle);
          break;
        default:
          break;
      }
    });
  });
}
