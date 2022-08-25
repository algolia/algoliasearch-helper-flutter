import 'package:algolia_helper/algolia_helper.dart';
import 'package:flutter/widgets.dart';

/// Extension over [HighlightedString].
extension HighlightingExt on HighlightedString {
  /// Converts [HighlightedString] to [TextSpan] list.
  List<TextSpan> toTextSpans([
    TextStyle regularTextStyle = const TextStyle(fontWeight: FontWeight.normal),
    TextStyle highlightedTextStyle =
        const TextStyle(fontWeight: FontWeight.bold),
  ]) =>
      tokens
          .map(
            (token) => TextSpan(
              text: token.content,
              style:
                  token.highlighted ? highlightedTextStyle : regularTextStyle,
            ),
          )
          .toList();
}
