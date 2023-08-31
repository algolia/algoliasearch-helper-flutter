import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'highlighting_core.dart';

/// Extension over [HighlightedString].
extension HighlightingExt on HighlightedString {
  /// Converts [HighlightedString] to [TextSpan].
  /// Applies [regularTextStyle] and [highlightedTextStyle] styles to
  /// to non-highlighted and highlighted sub-spans accordingly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Text.rich(
  ///   hit.getHighlightedString('title').toTextSpan(),
  /// );
  /// ```
  TextSpan toTextSpan({
    TextStyle? style,
    TextStyle regularTextStyle = const TextStyle(fontWeight: FontWeight.normal),
    TextStyle highlightedTextStyle =
        const TextStyle(fontWeight: FontWeight.bold),
    GestureRecognizer? recognizer,
    MouseCursor? mouseCursor,
    PointerEnterEventListener? onEnter,
    PointerExitEventListener? onExit,
    String? semanticsLabel,
    Locale? locale,
    bool? spellOut,
  }) =>
      TextSpan(
        style: style,
        children: toInlineSpans(
          regularTextStyle: regularTextStyle,
          highlightedTextStyle: highlightedTextStyle,
        ),
        recognizer: recognizer,
        mouseCursor: mouseCursor,
        onEnter: onEnter,
        onExit: onExit,
        semanticsLabel: semanticsLabel,
        locale: locale,
        spellOut: spellOut,
      );

  /// Converts [HighlightedString] to list of [InlineSpan].
  /// Applies [regularTextStyle] and [highlightedTextStyle] styles to
  /// to non-highlighted and highlighted spans accordingly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Text.rich(
  ///   TextSpan(
  ///     style: DefaultTextStyle.of(context).style,
  ///     children: hit.getHighlightedString('title').toInlineSpans(),
  ///   ),
  /// );
  /// ```
  List<InlineSpan> toInlineSpans({
    TextStyle regularTextStyle = const TextStyle(fontWeight: FontWeight.normal),
    TextStyle highlightedTextStyle =
        const TextStyle(fontWeight: FontWeight.bold),
  }) =>
      tokens
          .map(
            (token) => TextSpan(
              text: token.content,
              style:
                  token.isHighlighted ? highlightedTextStyle : regularTextStyle,
            ),
          )
          .toList();
}
