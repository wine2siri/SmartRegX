import 'package:flutter/foundation.dart';
import '../models/regex_tag.dart';
import '../services/storage_service.dart';

class TagProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<RegexTag> _tags = [];
  List<RegexHistory> _history = [];
  int _timeFilterDays = 0;
  bool _isLoading = true;
  TagCategory? _selectedCategory;
  String _theme = 'midnight';

  List<RegexTag> get tags => _sortedTags();
  List<RegexTag> get allTags => _tags;
  List<RegexHistory> get history => _history;
  int get timeFilterDays => _timeFilterDays;
  bool get isLoading => _isLoading;
  TagCategory? get selectedCategory => _selectedCategory;
  String get theme => _theme;

  List<RegexTag> tagsByCategory(TagCategory cat) =>
      _tags.where((t) => t.category == cat).toList();

  List<RegexTag> _sortedTags() {
    var filtered = _filteredByTime();
    if (_selectedCategory != null) {
      filtered = filtered.where((t) => t.category == _selectedCategory).toList();
    }
    final sorted = List<RegexTag>.from(filtered);
    sorted.sort((a, b) {
      if (a.customOrder != null && b.customOrder != null) {
        return a.customOrder!.compareTo(b.customOrder!);
      }
      if (a.customOrder != null) return -1;
      if (b.customOrder != null) return 1;
      return b.useCount.compareTo(a.useCount);
    });
    return sorted;
  }

  List<RegexTag> _filteredByTime() {
    if (_timeFilterDays <= 0) return List<RegexTag>.from(_tags);
    final cutoff = DateTime.now().subtract(Duration(days: _timeFilterDays));
    return _tags
        .where((t) => t.lastUsedAt.isAfter(cutoff) || t.useCount == 0)
        .toList();
  }

  double tagFontSize(RegexTag tag) {
    if (_tags.isEmpty) return 14.0;
    final maxCount = _tags.map((t) => t.useCount).reduce((a, b) => a > b ? a : b);
    if (maxCount == 0) return 14.0;
    final ratio = tag.useCount / maxCount;
    return 12.0 + ratio * 10.0;
  }

  Future<void> loadTags() async {
    _isLoading = true;
    notifyListeners();
    _tags = await _storage.loadTags();
    _timeFilterDays = await _storage.loadTimeFilterDays();
    _history = await _storage.loadHistory();
    _theme = await _storage.loadTheme();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    await _storage.saveTags(_tags);
    notifyListeners();
  }

  void setCategory(TagCategory? cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  Future<void> addTag(String label, String pattern, TagCategory category, {String description = ''}) async {
    final tag = RegexTag(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      pattern: pattern,
      category: category,
      description: description,
    );
    _tags.add(tag);
    await _save();
  }

  Future<void> removeTag(String id) async {
    _tags.removeWhere((t) => t.id == id);
    await _save();
  }

  Future<void> updateTag(String id, {String? label, String? pattern, TagCategory? category, String? description}) async {
    final idx = _tags.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tags[idx] = _tags[idx].copyWith(
      label: label,
      pattern: pattern,
      category: category,
      description: description,
    );
    await _save();
  }

  Future<void> recordUsage(String id) async {
    final idx = _tags.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tags[idx] = _tags[idx].copyWith(
      useCount: _tags[idx].useCount + 1,
      lastUsedAt: DateTime.now(),
    );
    await _save();
  }

  Future<void> reorderTags(int oldIndex, int newIndex) async {
    final sorted = _sortedTags();
    if (oldIndex < 0 || oldIndex >= sorted.length) return;
    if (newIndex > sorted.length) newIndex = sorted.length;
    if (oldIndex < newIndex) newIndex -= 1;
    final item = sorted.removeAt(oldIndex);
    sorted.insert(newIndex, item);
    for (var i = 0; i < sorted.length; i++) {
      final tagIdx = _tags.indexWhere((t) => t.id == sorted[i].id);
      if (tagIdx != -1) {
        _tags[tagIdx] = _tags[tagIdx].copyWith(customOrder: i);
      }
    }
    await _save();
  }

  Future<void> setTimeFilterDays(int days) async {
    _timeFilterDays = days;
    await _storage.saveTimeFilterDays(days);
    notifyListeners();
  }

  Future<void> clearCustomOrders() async {
    for (var i = 0; i < _tags.length; i++) {
      _tags[i] = _tags[i].copyWith(customOrder: null);
    }
    await _save();
  }

  Future<void> addHistory(String regex) async {
    if (regex.isEmpty) return;
    final existing = _history.indexWhere((h) => h.regex == regex);
    if (existing != -1) {
      _history[existing] = _history[existing].copyWith(updatedAt: DateTime.now());
    } else {
      _history.insert(0, RegexHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        regex: regex,
      ));
    }
    if (_history.length > 50) {
      _history = _history.sublist(0, 50);
    }
    await _storage.saveHistory(_history);
    notifyListeners();
  }

  Future<void> renameHistory(String id, String name) async {
    final idx = _history.indexWhere((h) => h.id == id);
    if (idx == -1) return;
    _history[idx] = _history[idx].copyWith(name: name);
    await _storage.saveHistory(_history);
    notifyListeners();
  }

  Future<void> deleteHistory(String id) async {
    _history.removeWhere((h) => h.id == id);
    await _storage.saveHistory(_history);
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    _theme = theme;
    await _storage.saveTheme(theme);
    notifyListeners();
  }
}
