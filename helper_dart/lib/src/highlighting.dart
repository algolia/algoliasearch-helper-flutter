import 'model/search_response.dart';

/// Extension over [Hit].
extension Highlightable on Hit {
  /// Get [HighlightedString] of an attribute from a [Hit].
  /// - [preTag] and [postTag] indicate the highlighted substrings
  /// (default values: <em> and </em> accordingly)
  /// - [inverted] flag inverts the highlighted and non-highlighted substrings
  /// if set
  ///
  /// ## Example
  ///
  /// ```dart
  /// var highlightedString = hit.getHighlightedString('title');
  /// ```
  HighlightedString getHighlightedString(
    String attribute, {
    String preTag = '<em>',
    String postTag = '</em>',
    bool inverted = false,
  }) {
    final highlightResult = this['_highlightResult'] as Map<String, dynamic>;
    final highlightAttr = highlightResult[attribute] as Map<String, dynamic>;
    final highlighted = highlightAttr['value'] as String;
    return HighlightedString.of(
      highlighted,
      preTag: preTag,
      postTag: postTag,
      inverted: inverted,
    );
  }
}

/// Highlighted string as a list of [tokens].
///
/// ## Example
///
/// ```dart
/// const string = 'This <em>John</em> Doe looks like <em>John</em>athan.';
/// final highlighted = HighlightedString.of(string);
/// ```
///
/// `highlighted` should contain the following [tokens] :
///
/// ```
/// tokens: [
///    HighlightToken{content: 'This' , highlighted: false},
///    HighlightToken{content: 'John', highlighted: true},
///    HighlightToken{content:  'Doe looks like' , highlighted: false},
///    HighlightToken{content: 'John', highlighted: true},
///    HighlightToken{content: 'athan.', highlighted: false},
/// ]
/// ```
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

  /// List of highlightable tokens.
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

  final re = RegExp('${RegExp.escape(preTag)}(.*?)${RegExp.escape(postTag)}');
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
/// [isHighlighted] returning `true` indicates that [content] is highlighted.
class HighlightableToken {
  HighlightableToken._(this.content, this.isHighlighted);

  /// Token string.
  final String content;

  /// Returns `true` if this token is highlighted, `false` otherwise.
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
