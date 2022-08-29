import 'search_response.dart';

/// Extension over [Hit].
extension Highlightable on Hit {
  /// Get [HighlightedString] of an attribute
  /// - [preTag] and [postTag] indicate the highlighted substrings
  /// (default values: <em> and </em> accordingly)
  /// - [inverted] flag inverts the highlighted and non-highlighted substrings
  /// if set
  HighlightedString getHightlightedString(
    String attribute, [
    String preTag = _Defaults.preTag,
    String postTag = _Defaults.postTag,
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
  HighlightedString._(
    this.original,
    this.tokens,
  );

  factory HighlightedString.of(
    String string, {
    String preTag = _Defaults.preTag,
    String postTag = _Defaults.postTag,
    bool inverted = false,
  }) =>
      _highlightTokenizer(string, preTag, postTag, inverted);

  final String original;
  final Iterable<HighlightableToken> tokens;

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
  final tokens = <HighlightableToken>[];

  final re = RegExp('$preTag(\\w+)$postTag');
  final matches = re.allMatches(string).toList();

  void append(String string, bool isHighlighted) {
    tokens.add(HighlightableToken._(string, isHighlighted));
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

/// Highlightable string token.
class HighlightableToken {
  HighlightableToken._(this.content, this.isHighlighted);

  final String content;
  final bool isHighlighted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighlightableToken &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          isHighlighted == other.isHighlighted;

  @override
  int get hashCode => content.hashCode ^ isHighlighted.hashCode;

  @override
  String toString() =>
      'HighlightToken{content: $content, highlighted: $isHighlighted}';
}

class _Defaults {
  static const preTag = '<em>';
  static const postTag = '</em>';
}
