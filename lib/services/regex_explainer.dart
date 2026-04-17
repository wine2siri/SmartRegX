class RegexExplainer {
  static String explain(String pattern) {
    if (pattern.isEmpty) return '';
    try {
      final tokens = _tokenize(pattern);
      final parts = <String>[];
      for (final token in tokens) {
        parts.add(_explainToken(token));
      }
      return parts.join('，');
    } catch (_) {
      return '无法解析该正则表达式';
    }
  }

  static List<_Token> _tokenize(String pattern) {
    final tokens = <_Token>[];
    var i = 0;
    while (i < pattern.length) {
      final ch = pattern[i];

      if (ch == '^') {
        tokens.add(_Token(_TokenType.anchor, '^'));
        i++;
      } else if (ch == r'$') {
        tokens.add(_Token(_TokenType.anchor, r'$'));
        i++;
      } else if (ch == '\\' && i + 1 < pattern.length) {
        final next = pattern[i + 1];
        if ('dDwWsSbB'.contains(next)) {
          tokens.add(_Token(_TokenType.shorthand, '\\$next'));
          i += 2;
        } else {
          tokens.add(_Token(_TokenType.escaped, '\\$next'));
          i += 2;
        }
      } else if (ch == '[') {
        final end = _findBracketEnd(pattern, i);
        tokens.add(_Token(_TokenType.charClass, pattern.substring(i, end)));
        i = end;
      } else if (ch == '(') {
        final groupInfo = _parseGroup(pattern, i);
        tokens.add(_Token(_TokenType.group, groupInfo.text));
        i = groupInfo.endIndex;
      } else if (ch == '|' ) {
        tokens.add(_Token(_TokenType.alternation, '|'));
        i++;
      } else if (ch == '.' ) {
        tokens.add(_Token(_TokenType.dot, '.'));
        i++;
      } else if ('*+?'.contains(ch)) {
        tokens.add(_Token(_TokenType.quantifier, ch.toString()));
        i++;
      } else if (ch == '{') {
        final end = pattern.indexOf('}', i);
        if (end != -1) {
          tokens.add(
              _Token(_TokenType.quantifier, pattern.substring(i, end + 1)));
          i = end + 1;
        } else {
          tokens.add(_Token(_TokenType.literal, ch));
          i++;
        }
      } else {
        tokens.add(_Token(_TokenType.literal, ch));
        i++;
      }
    }
    return tokens;
  }

  static int _findBracketEnd(String pattern, int start) {
    var i = start + 1;
    if (i < pattern.length && pattern[i] == '^') i++;
    if (i < pattern.length && pattern[i] == ']') i++;
    while (i < pattern.length && pattern[i] != ']') {
      i++;
    }
    return i + 1 > pattern.length ? pattern.length : i + 1;
  }

  static _GroupInfo _parseGroup(String pattern, int start) {
    var i = start + 1;
    if (i < pattern.length && pattern[i] == '?') {
      i++;
      if (i < pattern.length && ':!=<>'.contains(pattern[i])) i++;
    }
    var depth = 1;
    while (i < pattern.length && depth > 0) {
      if (pattern[i] == '\\' && i + 1 < pattern.length) {
        i += 2;
        continue;
      }
      if (pattern[i] == '(') depth++;
      if (pattern[i] == ')') depth--;
      i++;
    }
    return _GroupInfo(pattern.substring(start, i), i);
  }

  static String _explainToken(_Token token) {
    switch (token.type) {
      case _TokenType.anchor:
        if (token.value == '^') return '以...开头';
        if (token.value == r'$') return '以...结尾';
        return token.value;
      case _TokenType.shorthand:
        return _explainShorthand(token.value);
      case _TokenType.escaped:
        final ch = token.value.length > 1 ? token.value[1] : token.value;
        return '字符"$ch"';
      case _TokenType.charClass:
        return _explainCharClass(token.value);
      case _TokenType.group:
        return _explainGroup(token.value);
      case _TokenType.alternation:
        return '或';
      case _TokenType.dot:
        return '任意字符';
      case _TokenType.quantifier:
        return _explainQuantifier(token.value);
      case _TokenType.literal:
        return '字符"${token.value}"';
    }
  }

  static String _explainShorthand(String value) {
    const map = {
      '\\d': '数字',
      '\\D': '非数字',
      '\\w': '字母数字下划线',
      '\\W': '非字母数字下划线',
      '\\s': '空白符',
      '\\S': '非空白符',
      '\\b': '单词边界',
      '\\B': '非单词边界',
    };
    return map[value] ?? value;
  }

  static String _explainCharClass(String value) {
    if (value.length <= 2) return '字符集$value';
    var inner = value.substring(1, value.length - 1);
    var negated = false;
    if (inner.startsWith('^')) {
      negated = true;
      inner = inner.substring(1);
    }
    final buf = StringBuffer();
    if (negated) buf.write('非');

    if (inner == '\\u4e00-\\u9fa5' || inner == 'u4e00-u9fa5') {
      buf.write('中文字符');
    } else if (inner.contains('-') && !inner.startsWith('-')) {
      final parts = inner.split('-');
      if (parts.length == 2) {
        buf.write('${parts[0]}到${parts[1]}之间的字符');
      } else {
        buf.write('[$inner]中的任意一个字符');
      }
    } else if (inner.length == 1) {
      buf.write('字符"$inner"');
    } else {
      buf.write('[$inner]中的任意一个字符');
    }
    return buf.toString();
  }

  static String _explainGroup(String value) {
    if (value.startsWith('(?:')) {
      final inner = value.substring(3, value.length - 1);
      return '非捕获分组（${explain(inner)}）';
    }
    if (value.startsWith('(?=')) {
      final inner = value.substring(3, value.length - 1);
      return '正向预查（后面跟着${explain(inner)}）';
    }
    if (value.startsWith('(?!')) {
      final inner = value.substring(3, value.length - 1);
      return '负向预查（后面不跟着${explain(inner)}）';
    }
    final inner = value.substring(1, value.length - 1);
    return '分组（${explain(inner)}）';
  }

  static String _explainQuantifier(String value) {
    if (value == '*') return '出现0次或多次';
    if (value == '+') return '出现1次或多次';
    if (value == '?') return '出现0次或1次';
    final m = RegExp(r'^\{(\d+)(,(\d*)?)?\}$').firstMatch(value);
    if (m != null) {
      final min = m.group(1)!;
      final hasComma = m.group(2) != null;
      final max = m.group(3);
      if (!hasComma) return '出现$min次';
      if (max == null || max.isEmpty) return '出现至少$min次';
      return '出现${min}到$max次';
    }
    return value;
  }
}

enum _TokenType {
  anchor,
  shorthand,
  escaped,
  charClass,
  group,
  alternation,
  dot,
  quantifier,
  literal,
}

class _Token {
  final _TokenType type;
  final String value;
  _Token(this.type, this.value);
}

class _GroupInfo {
  final String text;
  final int endIndex;
  _GroupInfo(this.text, this.endIndex);
}
