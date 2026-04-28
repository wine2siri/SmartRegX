class DetailedItem {
  final String token;
  final String meaning;
  DetailedItem(this.token, this.meaning);
}

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

  static List<DetailedItem> explainDetailed(String pattern) {
    if (pattern.isEmpty) return [];
    try {
      final tokens = _tokenize(pattern);
      return tokens.map((t) => DetailedItem(t.value, _explainToken(t))).toList();
    } catch (_) {
      return [DetailedItem(pattern, '无法解析')];
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
        } else if (next == 'n') {
          tokens.add(_Token(_TokenType.escaped, '\\n'));
          i += 2;
        } else if (next == 't') {
          tokens.add(_Token(_TokenType.escaped, '\\t'));
          i += 2;
        } else if (next == 'r') {
          tokens.add(_Token(_TokenType.escaped, '\\r'));
          i += 2;
        } else if (int.tryParse(next) != null && int.parse(next) >= 1 && int.parse(next) <= 9) {
          tokens.add(_Token(_TokenType.backref, '\\$next'));
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
      } else if (ch == '|') {
        tokens.add(_Token(_TokenType.alternation, '|'));
        i++;
      } else if (ch == '.') {
        tokens.add(_Token(_TokenType.dot, '.'));
        i++;
      } else if ('*+?'.contains(ch)) {
        tokens.add(_Token(_TokenType.quantifier, ch.toString()));
        i++;
      } else if (ch == '{') {
        final end = pattern.indexOf('}', i);
        if (end != -1) {
          tokens.add(_Token(_TokenType.quantifier, pattern.substring(i, end + 1)));
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
      if (i < pattern.length) {
        if (pattern[i] == '<' && i + 1 < pattern.length && pattern[i + 1] == '=') {
          i += 2;
        } else if (pattern[i] == '<' && i + 1 < pattern.length && pattern[i + 1] == '!') {
          i += 2;
        } else if (pattern[i] == 'P' && i + 1 < pattern.length && pattern[i + 1] == '<') {
          i += 2;
          while (i < pattern.length && pattern[i] != '>') { i++; }
          if (i < pattern.length) i++;
        } else if (':!=<>'.contains(pattern[i])) {
          i++;
        }
      }
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
        if (token.value == '^') return '从开头匹配';
        if (token.value == r'$') return '到结尾为止';
        return token.value;
      case _TokenType.shorthand:
        return _explainShorthand(token.value);
      case _TokenType.escaped:
        if (token.value == '\\n') return '换行';
        if (token.value == '\\t') return 'Tab缩进';
        if (token.value == '\\r') return '回车';
        final ch = token.value.length > 1 ? token.value[1] : token.value;
        return '普通字符$ch';
      case _TokenType.charClass:
        return _explainCharClass(token.value);
      case _TokenType.group:
        return _explainGroup(token.value);
      case _TokenType.alternation:
        return '或者';
      case _TokenType.dot:
        return '任意一个字符（除换行外）';
      case _TokenType.quantifier:
        return _explainQuantifier(token.value);
      case _TokenType.literal:
        return '普通字符"${token.value}"';
      case _TokenType.backref:
        return '和第${token.value[1]}个括号里匹配到的一样的内容';
    }
  }

  static String _explainShorthand(String value) {
    const map = {
      '\\d': '一个数字（0-9）',
      '\\D': '一个非数字字符',
      '\\w': '一个字母、数字或下划线',
      '\\W': '一个非字母数字下划线的字符',
      '\\s': '一个空白（空格、Tab、换行等）',
      '\\S': '一个非空白字符',
      '\\b': '单词的边界位置',
      '\\B': '不是单词边界的位置',
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

    String result;

    if (inner == r'\u4e00-\u9fa5' || inner == 'u4e00-u9fa5') {
      result = '一个中文字';
    } else if (inner == 'a-zA-Z') {
      result = '一个英文字母（大小写都行）';
    } else if (inner == 'a-z') {
      result = '一个小写英文字母';
    } else if (inner == 'A-Z') {
      result = '一个大写英文字母';
    } else if (inner == '0-9') {
      result = '一个数字';
    } else if (inner == 'a-zA-Z0-9') {
      result = '一个字母或数字';
    } else if (inner == 'a-zA-Z0-9_-') {
      result = '一个字母、数字、下划线或横线';
    } else if (inner.contains('-') && !inner.startsWith('-')) {
      final parts = inner.split('-');
      if (parts.length == 2) {
        result = '${parts[0]}到${parts[1]}之间的一个字符';
      } else {
        result = '[$inner]里的任意一个';
      }
    } else if (inner.length == 1) {
      result = '字符"$inner"';
    } else {
      result = '[$inner]里的任意一个';
    }

    if (negated) {
      result = '不是$result';
    }
    return result;
  }

  static String _explainGroup(String value) {
    if (value.startsWith('(?:')) {
      final inner = value.substring(3, value.length - 1);
      return '（${explain(inner)}），但不记录匹配结果';
    }
    if (value.startsWith('(?=')) {
      final inner = value.substring(3, value.length - 1);
      return '后面必须跟着"${explain(inner)}"，但不消耗字符';
    }
    if (value.startsWith('(?!')) {
      final inner = value.substring(3, value.length - 1);
      return '后面不能跟着"${explain(inner)}"';
    }
    if (value.startsWith('(?<=')) {
      final inner = value.substring(4, value.length - 1);
      return '前面必须是"${explain(inner)}"';
    }
    if (value.startsWith('(?<!')) {
      final inner = value.substring(4, value.length - 1);
      return '前面不能是"${explain(inner)}"';
    }
    if (value.startsWith('(?P<')) {
      final nameEnd = value.indexOf('>');
      if (nameEnd != -1) {
        final name = value.substring(4, nameEnd);
        final inner = value.substring(nameEnd + 1, value.length - 1);
        return '取名叫"$name"的分组，里面是${explain(inner)}';
      }
    }
    final inner = value.substring(1, value.length - 1);
    return '（${explain(inner)}）';
  }

  static String _explainQuantifier(String value) {
    if (value == '*') return '可以没有，也可以有很多个';
    if (value == '+') return '至少出现1次，可以更多';
    if (value == '?') return '可有可无（最多1次）';
    final m = RegExp(r'^\{(\d+)(,(\d*)?)?\}$').firstMatch(value);
    if (m != null) {
      final min = m.group(1)!;
      final hasComma = m.group(2) != null;
      final max = m.group(3);
      if (!hasComma) return '恰好出现$min次';
      if (max == null || max.isEmpty) return '至少$min次，上不封顶';
      return '出现$min到$max次';
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
  backref,
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
