class AnalysisResult {
  final String regex;
  final String explanation;
  final String? replacement;
  final List<String> examples;
  final List<bool> matches;

  AnalysisResult({
    required this.regex,
    required this.explanation,
    this.replacement,
    required this.examples,
    required this.matches,
  });
}

class RegexAnalyzer {
  static AnalysisResult? analyzePattern(List<String> examples) {
    if (examples.length < 2) return null;
    examples = examples.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (examples.length < 2) return null;

    final regex = _inferRegex(examples);
    if (regex.isEmpty) return null;

    final matches = examples.map((e) => RegExp(regex).hasMatch(e)).toList();
    final explanation = _explainInference(regex, examples);

    return AnalysisResult(
      regex: regex,
      explanation: explanation,
      examples: examples,
      matches: matches,
    );
  }

  static AnalysisResult? analyzeReplacement(List<String> sources, List<String> targets) {
    if (sources.length < 2 || targets.length < 2) return null;
    sources = sources.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    targets = targets.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (sources.length < 2 || targets.length < 2) return null;

    final minLen = sources.length < targets.length ? sources.length : targets.length;
    sources = sources.sublist(0, minLen);
    targets = targets.sublist(0, minLen);

    final result = _inferReplacement(sources, targets);
    if (result == null) return null;

    final matches = sources.map((e) => RegExp(result.regex).hasMatch(e)).toList();
    final allExamples = <String>[];
    for (var i = 0; i < minLen; i++) {
      allExamples.add('${sources[i]} → ${targets[i]}');
    }

    return AnalysisResult(
      regex: result.regex,
      explanation: result.explanation,
      replacement: result.replacement,
      examples: allExamples,
      matches: matches,
    );
  }

  static String _inferRegex(List<String> examples) {
    final patterns = examples.map(_analyzeSingle).toList();
    return _mergePatterns(patterns, examples);
  }

  static String _analyzeSingle(String s) {
    final buf = StringBuffer();
    var i = 0;
    while (i < s.length) {
      final ch = s[i];
      if (_isDigit(ch)) {
        var count = 0;
        while (i < s.length && _isDigit(s[i])) { count++; i++; }
        buf.write('\\d{$count}');
      } else if (_isLetter(ch)) {
        final isUpper = ch.toUpperCase() == ch && ch.toLowerCase() != ch;
        var count = 0;
        if (isUpper) {
          while (i < s.length && _isUpperLetter(s[i])) { count++; i++; }
          buf.write('[A-Z]{$count}');
        } else {
          while (i < s.length && _isLowerLetter(s[i])) { count++; i++; }
          buf.write('[a-z]{$count}');
        }
      } else if (_isChinese(ch)) {
        var count = 0;
        while (i < s.length && _isChinese(s[i])) { count++; i++; }
        buf.write('[\\u4e00-\\u9fa5]{$count}');
      } else {
        buf.write(RegExp.escape(ch));
        i++;
      }
    }
    return buf.toString();
  }

  static String _mergePatterns(List<String> patterns, List<String> examples) {
    if (patterns.isEmpty) return '';
    if (patterns.length == 1) return patterns.first;

    final tokens = patterns.map(_tokenizePattern).toList();
    final minLen = tokens.map((t) => t.length).reduce((a, b) => a < b ? a : b);
    if (minLen == 0) return patterns.first;

    final merged = <String>[];
    for (var i = 0; i < minLen; i++) {
      final colTokens = tokens.map((t) => t[i]).toList();
      merged.add(_mergeColumn(colTokens, examples, i));
    }

    var result = merged.join();
    if (_allMatch(result, examples)) return result;

    result = _tryGeneralize(result, examples);
    return result;
  }

  static List<String> _tokenizePattern(String pattern) {
    final tokens = <String>[];
    var i = 0;
    while (i < pattern.length) {
      if (pattern[i] == '\\') {
        var end = i + 1;
        if (end < pattern.length && 'dDwWsS'.contains(pattern[end])) {
          end++;
          if (end < pattern.length && pattern[end] == '{') {
            final braceEnd = pattern.indexOf('}', end);
            if (braceEnd != -1) end = braceEnd + 1;
          }
          tokens.add(pattern.substring(i, end));
          i = end;
        } else if (end < pattern.length && pattern[end] == 'u') {
          final bracketEnd = pattern.indexOf(']', end);
          if (bracketEnd != -1) {
            var afterBracket = bracketEnd + 1;
            if (afterBracket < pattern.length && pattern[afterBracket] == '{') {
              final braceEnd = pattern.indexOf('}', afterBracket);
              if (braceEnd != -1) afterBracket = braceEnd + 1;
            }
            tokens.add(pattern.substring(i, afterBracket));
            i = afterBracket;
          } else {
            tokens.add(pattern.substring(i));
            i = pattern.length;
          }
        } else {
          tokens.add(pattern.substring(i, i + 2));
          i += 2;
        }
      } else if (pattern[i] == '[') {
        final end = pattern.indexOf(']', i);
        if (end != -1) {
          var after = end + 1;
          if (after < pattern.length && pattern[after] == '{') {
            final braceEnd = pattern.indexOf('}', after);
            if (braceEnd != -1) after = braceEnd + 1;
          }
          tokens.add(pattern.substring(i, after));
          i = after;
        } else {
          tokens.add(pattern.substring(i));
          i = pattern.length;
        }
      } else {
        tokens.add(pattern[i]);
        i++;
      }
    }
    return tokens;
  }

  static String _mergeColumn(List<String> colTokens, List<String> examples, int colIndex) {
    final unique = colTokens.toSet().toList();
    if (unique.length == 1) return unique.first;

    if (colTokens.every((t) => t.startsWith('\\d'))) {
      final counts = colTokens.map(_extractCount).where((c) => c > 0).toList();
      if (counts.isNotEmpty) {
        final min = counts.reduce((a, b) => a < b ? a : b);
        final max = counts.reduce((a, b) => a > b ? a : b);
        if (min == max) return '\\d{$min}';
        return '\\d{$min,$max}';
      }
      return '\\d+';
    }

    if (colTokens.every((t) => t.startsWith('[a-z]'))) {
      final counts = colTokens.map(_extractCount).where((c) => c > 0).toList();
      if (counts.isNotEmpty) {
        final min = counts.reduce((a, b) => a < b ? a : b);
        final max = counts.reduce((a, b) => a > b ? a : b);
        if (min == max) return '[a-z]{$min}';
        return '[a-z]{$min,$max}';
      }
      return '[a-z]+';
    }

    if (colTokens.every((t) => t.startsWith('[A-Z]'))) {
      final counts = colTokens.map(_extractCount).where((c) => c > 0).toList();
      if (counts.isNotEmpty) {
        final min = counts.reduce((a, b) => a < b ? a : b);
        final max = counts.reduce((a, b) => a > b ? a : b);
        if (min == max) return '[A-Z]{$min}';
        return '[A-Z]{$min,$max}';
      }
      return '[A-Z]+';
    }

    if (colTokens.every((t) => t.contains('u4e00'))) {
      final counts = colTokens.map(_extractCount).where((c) => c > 0).toList();
      if (counts.isNotEmpty) {
        final min = counts.reduce((a, b) => a < b ? a : b);
        final max = counts.reduce((a, b) => a > b ? a : b);
        if (min == max) return '[\\u4e00-\\u9fa5]{$min}';
        return '[\\u4e00-\\u9fa5]{$min,$max}';
      }
      return '[\\u4e00-\\u9fa5]+';
    }

    if (colTokens.every((t) => t.startsWith('['))) {
      return '[a-zA-Z0-9]+';
    }

    if (colTokens.length > 1) {
      final escaped = unique.map((u) => u.length == 1 ? RegExp.escape(u) : u);
      return '(${escaped.join('|')})';
    }

    return unique.first;
  }

  static int _extractCount(String token) {
    final m = RegExp(r'\{(\d+)(?:,(\d*))?\}').firstMatch(token);
    if (m != null) {
      return int.tryParse(m.group(1) ?? '0') ?? 0;
    }
    if (token.endsWith('+')) return 1;
    if (token.endsWith('*')) return 0;
    if (token.endsWith('?')) return 0;
    return 1;
  }

  static bool _allMatch(String regex, List<String> examples) {
    try {
      final re = RegExp(regex);
      return examples.every((e) => re.hasMatch(e));
    } catch (_) {
      return false;
    }
  }

  static String _tryGeneralize(String regex, List<String> examples) {
    var result = regex;
    result = result.replaceAllMapped(
      RegExp(r'\\d\{(\d+),(\d+)\}'),
      (m) {
        final min = int.tryParse(m.group(1) ?? '1') ?? 1;
        return min <= 1 ? '\\d+' : '\\d{$min,}';
      },
    );
    if (_allMatch(result, examples)) return result;

    result = result.replaceAllMapped(
      RegExp(r'\[a-z\]\{(\d+),(\d+)\}'),
      (m) => '[a-z]+',
    );
    if (_allMatch(result, examples)) return result;

    result = result.replaceAllMapped(
      RegExp(r'\[A-Z\]\{(\d+),(\d+)\}'),
      (m) => '[A-Z]+',
    );
    if (_allMatch(result, examples)) return result;

    return regex;
  }

  static _ReplacementResult? _inferReplacement(List<String> sources, List<String> targets) {
    final sourcePattern = _inferRegex(sources);
    if (sourcePattern.isEmpty) return null;

    final groups = <int, String>{};
    for (var i = 0; i < sources.length && i < targets.length; i++) {
      final source = sources[i];
      final target = targets[i];
      _findGroups(source, target, i + 1, groups);
    }

    if (groups.isEmpty) {
      final allSame = targets.toSet().length == 1;
      if (allSame) {
        return _ReplacementResult(
          regex: sourcePattern,
          replacement: targets.first,
          explanation: '将匹配到的内容全部替换为"${targets.first}"',
        );
      }
      return null;
    }

    final replacementBuf = StringBuffer();
    final sortedKeys = groups.keys.toList()..sort();
    var lastPos = 0;
    for (final key in sortedKeys) {
      final val = groups[key]!;
      if (key > lastPos + 1) {
        replacementBuf.write(targets.first.substring(lastPos, lastPos + (key - lastPos - 1)));
      }
      replacementBuf.write('\$$key');
      lastPos = key;
    }

    return _ReplacementResult(
      regex: sourcePattern,
      replacement: replacementBuf.toString(),
      explanation: _explainReplacement(groups, sources, targets),
    );
  }

  static void _findGroups(String source, String target, int baseIndex, Map<int, String> groups) {
    if (target.contains(source)) {
      groups[1] = source;
      return;
    }

    var commonParts = <String>[];
    var s = source;
    var t = target;

    for (var len = s.length; len >= 1; len--) {
      for (var start = 0; start <= s.length - len; start++) {
        final part = s.substring(start, start + len);
        if (t.contains(part) && !commonParts.contains(part)) {
          commonParts.add(part);
        }
      }
    }

    commonParts.sort((a, b) => b.length.compareTo(a.length));
    final used = <String>[];
    for (final part in commonParts) {
      if (used.any((u) => u.contains(part) || part.contains(u))) continue;
      used.add(part);
    }

    if (used.isEmpty) return;

    var groupIdx = 1;
    for (final part in used) {
      groups[baseIndex * 10 + groupIdx] = part;
      groupIdx++;
    }
  }

  static String _explainReplacement(Map<int, String> groups, List<String> sources, List<String> targets) {
    if (sources.length >= 2) {
      final s0 = sources[0];
      final t0 = targets[0];
      final s1 = sources[1];
      final t1 = targets[1];

      var removed = <String>[];
      var added = <String>[];

      for (var i = 0; i < s0.length; i++) {
        if (!t0.contains(s0[i])) removed.add(s0[i]);
      }
      for (var i = 0; i < t0.length; i++) {
        if (!s0.contains(t0[i])) added.add(t0[i]);
      }

      if (removed.isNotEmpty || added.isNotEmpty) {
        final parts = <String>[];
        if (removed.isNotEmpty) parts.add('删除"${removed.join()}"');
        if (added.isNotEmpty) parts.add('添加"${added.join()}"');
        return '将匹配内容中的${parts.join("并")}';
      }
    }

    return '根据样例推导的替换规则';
  }

  static String _explainInference(String regex, List<String> examples) {
    final parts = <String>[];

    if (regex.contains('\\d')) {
      final digitMatch = RegExp(r'\\d\{?(\d*)(?:,(\d*))?\}?').firstMatch(regex);
      if (digitMatch != null) {
        parts.add('包含数字部分');
      }
    }
    if (regex.contains('[a-z]') || regex.contains('[A-Z]')) {
      parts.add('包含字母部分');
    }
    if (regex.contains('\\u4e00')) {
      parts.add('包含中文部分');
    }

    final separators = <String>[];
    final sepPattern = RegExp(r'(?<=\])([^\\\[({]+)');
    for (final m in sepPattern.allMatches(regex)) {
      final sep = m.group(1);
      if (sep != null && sep.isNotEmpty && !separators.contains(sep)) {
        separators.add(sep);
      }
    }
    if (separators.isNotEmpty) {
      parts.add('用"${separators.join('、')}"分隔');
    }

    if (parts.isEmpty) return '根据${examples.length}个样例推导出的正则表达式';
    return '根据${examples.length}个样例推导：${parts.join("，")}';
  }

  static bool _isDigit(String ch) => ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
  static bool _isUpperLetter(String ch) => ch.codeUnitAt(0) >= 65 && ch.codeUnitAt(0) <= 90;
  static bool _isLowerLetter(String ch) => ch.codeUnitAt(0) >= 97 && ch.codeUnitAt(0) <= 122;
  static bool _isLetter(String ch) => _isUpperLetter(ch) || _isLowerLetter(ch);
  static bool _isChinese(String ch) => ch.codeUnitAt(0) >= 0x4e00 && ch.codeUnitAt(0) <= 0x9fa5;
}

class _ReplacementResult {
  final String regex;
  final String replacement;
  final String explanation;

  _ReplacementResult({
    required this.regex,
    required this.replacement,
    required this.explanation,
  });
}
