import 'package:algolia_helper_dart/algolia.dart';
import 'package:flutter/widgets.dart';

extension HighlightingExt on HighlightedString {
  /// Converts [HighlightedString] to [TextSpan] list.
  TextSpan toTextSpan([
    TextStyle regularTextStyle = const TextStyle(fontWeight: FontWeight.normal),
    TextStyle highlightedTextStyle =
        const TextStyle(fontWeight: FontWeight.bold),
  ]) =>
      TextSpan(
        children: tokens
            .map(
              (token) => TextSpan(
                text: token.content,
                style: token.isHighlighted
                    ? highlightedTextStyle
                    : regularTextStyle,
              ),
            )
            .toList(),
      );
}
