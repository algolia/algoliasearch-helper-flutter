/// Creates a [HighlightedString] from a highlighted string.
HighlightedString highlightTokenizer(String string,
    {String preTag = "<em>",
    String postTag = "</em>",
    bool isInverted = false}) {
  List<HighlightToken> tokens = [];

  final re = RegExp("$preTag(\\w+)$postTag");
  final matches = re.allMatches(string).toList();

  void append(String string, bool isHighlighted) {
    tokens.add(HighlightToken(string, isHighlighted));
  }

  int prev = 0;
  for (final match in matches) {
    if (prev != match.start) {
      append(string.substring(prev, match.start), isInverted);
    }
    append(match.group(1)!, !isInverted);
    prev = match.end;
  }
  if (prev != string.length) {
    append(string.substring(prev), isInverted);
  }

  return HighlightedString(string, tokens);
}

/// Highlighted string as a list of tokens.
class HighlightedString {
  HighlightedString(this.original, this.tokens);

  final String original;
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
  String toString() {
    return 'HighlightedString{original: $original, tokens: $tokens}';
  }
}

/// Highlight string token.
class HighlightToken {
  HighlightToken(this.content, this.highlighted);

  final String content;
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
  String toString() {
    return 'HighlightToken{content: $content, highlighted: $highlighted}';
  }
}
