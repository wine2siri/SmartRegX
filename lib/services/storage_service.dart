import 'package:shared_preferences/shared_preferences.dart';
import '../models/regex_tag.dart';

class StorageService {
  static const _tagsKey = 'regex_tags_v2';
  static const _timeFilterKey = 'time_filter_days';
  static const _historyKey = 'regex_history';
  static const _themeKey = 'app_theme';

  Future<List<RegexTag>> loadTags() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_tagsKey);
    if (str == null || str.isEmpty) return _defaultTags();
    try {
      final tags = RegexTag.decodeList(str);
      return tags.isEmpty ? _defaultTags() : tags;
    } catch (_) {
      return _defaultTags();
    }
  }

  Future<void> saveTags(List<RegexTag> tags) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tagsKey, RegexTag.encodeList(tags));
  }

  Future<int> loadTimeFilterDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_timeFilterKey) ?? 0;
  }

  Future<void> saveTimeFilterDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeFilterKey, days);
  }

  Future<List<RegexHistory>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_historyKey);
    if (str == null || str.isEmpty) return [];
    try {
      return RegexHistory.decodeList(str);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(List<RegexHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, RegexHistory.encodeList(history));
  }

  Future<String> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'midnight';
  }

  Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  List<RegexTag> _defaultTags() => [
        RegexTag(id: 'p1', label: '任意字符', pattern: '.', category: TagCategory.placeholder, description: '匹配除换行符外的任意单个字符'),
        RegexTag(id: 'p2', label: '任意数字', pattern: '\\d', category: TagCategory.placeholder, description: '匹配0-9的数字'),
        RegexTag(id: 'p3', label: '非数字', pattern: '\\D', category: TagCategory.placeholder, description: '匹配非数字字符'),
        RegexTag(id: 'p4', label: '任意字母数字下划线', pattern: '\\w', category: TagCategory.placeholder, description: '匹配a-zA-Z0-9_'),
        RegexTag(id: 'p5', label: '非字母数字下划线', pattern: '\\W', category: TagCategory.placeholder, description: '匹配非单词字符'),
        RegexTag(id: 'p6', label: '空白符', pattern: '\\s', category: TagCategory.placeholder, description: '匹配空格、制表符、换行等'),
        RegexTag(id: 'p7', label: '非空白符', pattern: '\\S', category: TagCategory.placeholder, description: '匹配非空白字符'),
        RegexTag(id: 'p8', label: '任意字母', pattern: '[a-zA-Z]', category: TagCategory.placeholder, description: '匹配大小写英文字母'),
        RegexTag(id: 'p9', label: '小写字母', pattern: '[a-z]', category: TagCategory.placeholder, description: '匹配a-z小写字母'),
        RegexTag(id: 'p10', label: '大写字母', pattern: '[A-Z]', category: TagCategory.placeholder, description: '匹配A-Z大写字母'),
        RegexTag(id: 'p11', label: '中文字符', pattern: '[\\u4e00-\\u9fa5]', category: TagCategory.placeholder, description: '匹配中文汉字'),

        RegexTag(id: 'c1', label: '内容', pattern: '[]', category: TagCategory.charset, description: '匹配方括号中列出的任意一个字符'),
        RegexTag(id: 'c2', label: '排除内容', pattern: '[^]', category: TagCategory.charset, description: '匹配不在方括号中的任意字符'),
        RegexTag(id: 'c3', label: '范围', pattern: '-', category: TagCategory.charset, description: '在字符集中表示范围，如a-z'),
        RegexTag(id: 'c4', label: '十六进制', pattern: '\\x', category: TagCategory.charset, description: '匹配十六进制字符，如\\x41匹配A'),
        RegexTag(id: 'c5', label: 'Unicode', pattern: '\\u', category: TagCategory.charset, description: '匹配Unicode字符，如\\u4e00'),

        RegexTag(id: 'q1', label: '0次或多次', pattern: '*', category: TagCategory.quantifier, description: '前面的内容可以出现0次或多次'),
        RegexTag(id: 'q2', label: '1次或多次', pattern: '+', category: TagCategory.quantifier, description: '前面的内容至少出现1次'),
        RegexTag(id: 'q3', label: '0次或1次', pattern: '?', category: TagCategory.quantifier, description: '前面的内容出现0次或1次(可有可无)'),
        RegexTag(id: 'q4', label: '恰好n次', pattern: '{n}', category: TagCategory.quantifier, description: '前面的内容恰好出现n次'),
        RegexTag(id: 'q5', label: '至少n次', pattern: '{n,}', category: TagCategory.quantifier, description: '前面的内容至少出现n次'),
        RegexTag(id: 'q6', label: 'n到m次', pattern: '{n,m}', category: TagCategory.quantifier, description: '前面的内容出现n到m次'),
        RegexTag(id: 'q7', label: '尽可能少匹配', pattern: '?', category: TagCategory.quantifier, description: '加在量词后使匹配变为非贪婪模式'),

        RegexTag(id: 'b1', label: '开头', pattern: '^', category: TagCategory.boundary, description: '匹配字符串的开头位置'),
        RegexTag(id: 'b2', label: '结尾', pattern: r'$', category: TagCategory.boundary, description: '匹配字符串的结尾位置'),
        RegexTag(id: 'b3', label: '单词边界', pattern: '\\b', category: TagCategory.boundary, description: '匹配单词的开始或结束位置'),
        RegexTag(id: 'b4', label: '非单词边界', pattern: '\\B', category: TagCategory.boundary, description: '匹配非单词边界位置'),

        RegexTag(id: 'g1', label: '分组', pattern: '()', category: TagCategory.group, description: '将内容分组，可捕获匹配内容'),
        RegexTag(id: 'g2', label: '非捕获分组', pattern: '(?:)', category: TagCategory.group, description: '分组但不捕获匹配内容'),
        RegexTag(id: 'g3', label: '或', pattern: '|', category: TagCategory.group, description: '匹配左边或右边的表达式'),
        RegexTag(id: 'g4', label: '引用分组', pattern: '\\1', category: TagCategory.group, description: '引用第1个分组匹配的内容'),
        RegexTag(id: 'g5', label: '命名分组', pattern: '(?P<name>)', category: TagCategory.group, description: '给分组命名，方便引用'),
        RegexTag(id: 'g6', label: '引用命名分组', pattern: '(?P=name)', category: TagCategory.group, description: '引用指定名称的分组'),

        RegexTag(id: 'a1', label: '前面有', pattern: '(?=)', category: TagCategory.assertion, description: '正向前瞻：后面必须跟着某内容'),
        RegexTag(id: 'a2', label: '前面没有', pattern: '(?!)', category: TagCategory.assertion, description: '负向前瞻：后面不能跟着某内容'),
        RegexTag(id: 'a3', label: '后面有', pattern: '(?<=)', category: TagCategory.assertion, description: '正向后顾：前面必须是某内容'),
        RegexTag(id: 'a4', label: '后面没有', pattern: '(?<!)', category: TagCategory.assertion, description: '负向后顾：前面不能是某内容'),

        RegexTag(id: 'e1', label: '转义', pattern: '\\', category: TagCategory.escape, description: '转义特殊字符使其变为普通字符'),
        RegexTag(id: 'e2', label: '点号', pattern: '\\.', category: TagCategory.escape, description: '匹配实际的点号字符'),
        RegexTag(id: 'e3', label: '斜杠', pattern: '/', category: TagCategory.escape, description: '匹配斜杠字符'),
        RegexTag(id: 'e4', label: '横线', pattern: '-', category: TagCategory.escape, description: '匹配横线字符'),
        RegexTag(id: 'e5', label: '左括号', pattern: '\\(', category: TagCategory.escape, description: '匹配实际的左括号'),
        RegexTag(id: 'e6', label: '右括号', pattern: '\\)', category: TagCategory.escape, description: '匹配实际的右括号'),
        RegexTag(id: 'e7', label: '左方括号', pattern: '\\[', category: TagCategory.escape, description: '匹配实际的左方括号'),
        RegexTag(id: 'e8', label: '右方括号', pattern: '\\]', category: TagCategory.escape, description: '匹配实际的右方括号'),
        RegexTag(id: 'e9', label: '花括号', pattern: '\\{\\}', category: TagCategory.escape, description: '匹配实际的花括号'),
        RegexTag(id: 'e10', label: '星号', pattern: '\\*', category: TagCategory.escape, description: '匹配实际的星号'),
        RegexTag(id: 'e11', label: '加号', pattern: '\\+', category: TagCategory.escape, description: '匹配实际的加号'),
        RegexTag(id: 'e12', label: '问号', pattern: '\\?', category: TagCategory.escape, description: '匹配实际的问号'),
        RegexTag(id: 'e13', label: '竖线', pattern: '\\|', category: TagCategory.escape, description: '匹配实际的竖线'),
        RegexTag(id: 'e14', label: '脱字符', pattern: '\\^', category: TagCategory.escape, description: '匹配实际的脱字符'),
        RegexTag(id: 'e15', label: '美元符', pattern: r'\$', category: TagCategory.escape, description: '匹配实际的美元符'),
        RegexTag(id: 'e16', label: '换行', pattern: '\\n', category: TagCategory.escape, description: '匹配换行符'),
        RegexTag(id: 'e17', label: '制表符', pattern: '\\t', category: TagCategory.escape, description: '匹配制表符'),
        RegexTag(id: 'e18', label: '回车', pattern: '\\r', category: TagCategory.escape, description: '匹配回车符'),

        RegexTag(id: 'm1', label: '邮箱', pattern: '[\\w.-]+@[\\w.-]+\\.\\w+', category: TagCategory.common, description: '匹配常见邮箱格式'),
        RegexTag(id: 'm2', label: '手机号', pattern: '1[3-9]\\d{9}', category: TagCategory.common, description: '匹配中国大陆手机号'),
        RegexTag(id: 'm3', label: '身份证号', pattern: '\\d{17}[\\dXx]', category: TagCategory.common, description: '匹配18位身份证号'),
        RegexTag(id: 'm4', label: 'IP地址', pattern: '\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}', category: TagCategory.common, description: '匹配IPv4地址'),
        RegexTag(id: 'm5', label: '日期', pattern: '\\d{4}-\\d{2}-\\d{2}', category: TagCategory.common, description: '匹配YYYY-MM-DD格式日期'),
        RegexTag(id: 'm6', label: '时间', pattern: '\\d{2}:\\d{2}:\\d{2}', category: TagCategory.common, description: '匹配HH:MM:SS格式时间'),
        RegexTag(id: 'm7', label: 'URL', pattern: 'https?://[\\w./%-]+', category: TagCategory.common, description: '匹配HTTP/HTTPS网址'),
        RegexTag(id: 'm8', label: '中文名', pattern: '[\\u4e00-\\u9fa5]{2,4}', category: TagCategory.common, description: '匹配2-4个中文字符的姓名'),
      ];
}
