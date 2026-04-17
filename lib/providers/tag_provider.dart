import 'package:flutter/foundation.dart';
import '../models/regex_tag.dart';
import '../services/storage_service.dart';

class TagProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<RegexTag> _tags = [];
  int _timeFilterDays = 0;
  bool _isLoading = true;

  List<RegexTag> get tags => _sortedTags();
  int get timeFilterDays => _timeFilterDays;
  bool get isLoading => _isLoading;

  List<RegexTag> _sortedTags() {
    final filtered = _filteredByTime();
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
    final maxCount = _tags
        .map((t) => t.useCount)
        .reduce((a, b) => a > b ? a : b);
    if (maxCount == 0) return 14.0;
    final ratio = tag.useCount / maxCount;
    return 12.0 + ratio * 10.0;
  }

  Future<void> loadTags() async {
    _isLoading = true;
    notifyListeners();
    _tags = await _storage.loadTags();
    _timeFilterDays = await _storage.loadTimeFilterDays();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    await _storage.saveTags(_tags);
    notifyListeners();
  }

  Future<void> addTag(String label, String pattern) async {
    final tag = RegexTag(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      pattern: pattern,
    );
    _tags.add(tag);
    await _save();
  }

  Future<void> removeTag(String id) async {
    _tags.removeWhere((t) => t.id == id);
    await _save();
  }

  Future<void> updateTag(String id, {String? label, String? pattern}) async {
    final idx = _tags.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tags[idx] = _tags[idx].copyWith(
      label: label,
      pattern: pattern,
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
}
