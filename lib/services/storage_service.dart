import 'package:shared_preferences/shared_preferences.dart';
import '../models/regex_tag.dart';

class StorageService {
  static const _tagsKey = 'regex_tags';
  static const _timeFilterKey = 'time_filter_days';

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

  List<RegexTag> _defaultTags() => [
        RegexTag(id: '1', label: '任意字符', pattern: '.'),
        RegexTag(id: '2', label: '数字', pattern: '\\d'),
        RegexTag(id: '3', label: '非数字', pattern: '\\D'),
        RegexTag(id: '4', label: '字母数字下划线', pattern: '\\w'),
        RegexTag(id: '5', label: '非字母数字下划线', pattern: '\\W'),
        RegexTag(id: '6', label: '空白符', pattern: '\\s'),
        RegexTag(id: '7', label: '非空白符', pattern: '\\S'),
        RegexTag(id: '8', label: '开头', pattern: '^'),
        RegexTag(id: '9', label: '结尾', pattern: r'$'),
        RegexTag(id: '10', label: '0次或多次', pattern: '*'),
        RegexTag(id: '11', label: '1次或多次', pattern: '+'),
        RegexTag(id: '12', label: '0次或1次', pattern: '?'),
        RegexTag(id: '13', label: '单词边界', pattern: '\\b'),
        RegexTag(id: '14', label: '非单词边界', pattern: '\\B'),
        RegexTag(id: '15', label: '分组开始', pattern: '('),
        RegexTag(id: '16', label: '分组结束', pattern: ')'),
        RegexTag(id: '17', label: '或', pattern: '|'),
        RegexTag(id: '18', label: '转义', pattern: '\\'),
        RegexTag(id: '19', label: '中文字符', pattern: '[\\u4e00-\\u9fa5]'),
        RegexTag(id: '20', label: '邮箱', pattern: '[\\w.-]+@[\\w.-]+\\.\\w+'),
        RegexTag(
            id: '21', label: '手机号', pattern: '1[3-9]\\d{9}'),
        RegexTag(id: '22', label: '量词{n}', pattern: '{n}'),
        RegexTag(id: '23', label: '量词{n,m}', pattern: '{n,m}'),
        RegexTag(id: '24', label: '量词{n,}', pattern: '{n,}'),
        RegexTag(id: '25', label: '非捕获分组', pattern: '(?:)'),
        RegexTag(id: '26', label: '正向预查', pattern: '(?=)'),
        RegexTag(id: '27', label: '负向预查', pattern: '(?!)'),
        RegexTag(id: '28', label: '字符集[]', pattern: '[]'),
        RegexTag(id: '29', label: '排除字符集[^]', pattern: '[^]'),
        RegexTag(id: '30', label: '横线', pattern: '-'),
        RegexTag(id: '31', label: '点号', pattern: '\\.'),
        RegexTag(id: '32', label: '斜杠', pattern: '/'),
      ];
}
