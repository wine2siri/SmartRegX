class RegexError {
  final int position;
  final String message;

  RegexError({required this.position, required this.message});
}

class RegexValidator {
  static RegexError? validate(String pattern) {
    if (pattern.isEmpty) return null;
    try {
      RegExp(pattern);
      return null;
    } on FormatException catch (e) {
      return RegexError(
        position: e.offset ?? 0,
        message: _translateError(e.message),
      );
    }
  }

  static String _translateError(String msg) {
    if (msg.contains('nothing to repeat')) {
      return '量词前面没有可重复的表达式';
    }
    if (msg.contains('unmatched')) {
      return '括号不匹配';
    }
    if (msg.contains('bad character range')) {
      return '字符范围无效';
    }
    if (msg.contains('unterminated')) {
      return '表达式未闭合';
    }
    if (msg.contains('invalid escape')) {
      return '无效的转义字符';
    }
    if (msg.contains('Range out of order')) {
      return '字符范围顺序错误';
    }
    return '正则表达式语法错误';
  }
}
