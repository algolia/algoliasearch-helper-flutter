import 'search_response.dart';

/// Extension over [Hit].
extension Highlightable on Hit {
  /// Get [HighlightedString] of an attribute
  HighlightedString getHightlightedString(
    String attribute, [
    String preTag = '<em>',
    String postTag = '</em>',
    bool inverted = false,
  ]) {
    final highlightResult = json['_highlightResult'] as Map<String, dynamic>;
    final highlighted = highlightResult[attribute] as String;
    return HighlightedString.of(
      highlighted,
      preTag: preTag,
      postTag: postTag,
      inverted: inverted,
    );
  }
}

/// Highlighted string as a list of tokens.
class HighlightedString {
  /// Creates [HighlightedString] instance.
  HighlightedString._(
    this.original,
    this.tokens,
  );

  /// Creates [HighlightedString] instance.
  factory HighlightedString.of(
    String string, {
    String preTag = '<em>',
    String postTag = '</em>',
    bool inverted = false,
  }) =>
      _highlightTokenizer(string, preTag, postTag, inverted);

  /// Original highlighted string.
  final String original;

  /// List of highlight tokens.
  final Iterable<HighlightToken> tokens;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighlightedString &&
          runtimeType == other.runtimeType &&
          original == other.original &&
          tokens == other.tokens;

  @override
  int get hashCode => original.hashCode ^ tokens.hashCode;

  @override
  String toString() =>
      'HighlightedString{original: $original, tokens: $tokens}';
}

/// Creates a [HighlightedString] from a highlighted string.
HighlightedString _highlightTokenizer(
  String string,
  String preTag,
  String postTag,
  bool inverted,
) {
  final tokens = <HighlightToken>[];

  final re = RegExp('$preTag(\\w+)$postTag');
  final matches = re.allMatches(string).toList();

  void append(String string, bool isHighlighted) {
    tokens.add(HighlightToken._(string, isHighlighted));
  }

  var prev = 0;
  for (final match in matches) {
    if (prev != match.start) {
      append(string.substring(prev, match.start), inverted);
    }
    append(match.group(1)!, !inverted);
    prev = match.end;
  }
  if (prev != string.length) {
    append(string.substring(prev), inverted);
  }

  return HighlightedString._(string, tokens);
}

/// Highlight string token.
class HighlightToken {
  /// Creates [HighlightToken] instance.
  HighlightToken._(this.content, this.highlighted);

  /// Token string.
  final String content;

  /// Returns `true` if this token is highlighted, `false` otherwise.
  final bool highlighted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighlightToken &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          highlighted == other.highlighted;

  @override
  int get hashCode => content.hashCode ^ highlighted.hashCode;

  @override
  String toString() =>
      'HighlightToken{content: $content, highlighted: $highlighted}';
}
