import 'dart:convert';

enum TagCategory {
  placeholder('占位符', '🔤'),
  charset('字符集', '📦'),
  quantifier('次数', '🔢'),
  boundary('边界', '📍'),
  group('分组', '📂'),
  assertion('断言', '👀'),
  escape('转义符', '🔄'),
  common('常用模式', '⭐');

  final String label;
  final String icon;
  const TagCategory(this.label, this.icon);
}

class RegexTag {
  final String id;
  final String label;
  final String pattern;
  final TagCategory category;
  final String description;
  int useCount;
  DateTime lastUsedAt;
  int? customOrder;

  RegexTag({
    required this.id,
    required this.label,
    required this.pattern,
    required this.category,
    this.description = '',
    this.useCount = 0,
    DateTime? lastUsedAt,
    this.customOrder,
  }) : lastUsedAt = lastUsedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'pattern': pattern,
        'category': category.name,
        'description': description,
        'useCount': useCount,
        'lastUsedAt': lastUsedAt.toIso8601String(),
        'customOrder': customOrder,
      };

  factory RegexTag.fromJson(Map<String, dynamic> json) => RegexTag(
        id: json['id'] as String,
        label: json['label'] as String,
        pattern: json['pattern'] as String,
        category: TagCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => TagCategory.placeholder,
        ),
        description: json['description'] as String? ?? '',
        useCount: json['useCount'] as int? ?? 0,
        lastUsedAt: json['lastUsedAt'] != null
            ? DateTime.parse(json['lastUsedAt'] as String)
            : DateTime.fromMillisecondsSinceEpoch(0),
        customOrder: json['customOrder'] as int?,
      );

  static String encodeList(List<RegexTag> tags) =>
      jsonEncode(tags.map((t) => t.toJson()).toList());

  static List<RegexTag> decodeList(String str) {
    final List<dynamic> list = jsonDecode(str);
    return list
        .map((e) => RegexTag.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  RegexTag copyWith({
    String? id,
    String? label,
    String? pattern,
    TagCategory? category,
    String? description,
    int? useCount,
    DateTime? lastUsedAt,
    int? customOrder,
  }) =>
      RegexTag(
        id: id ?? this.id,
        label: label ?? this.label,
        pattern: pattern ?? this.pattern,
        category: category ?? this.category,
        description: description ?? this.description,
        useCount: useCount ?? this.useCount,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
        customOrder: customOrder ?? this.customOrder,
      );
}

class RegexHistory {
  final String id;
  String regex;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  RegexHistory({
    required this.id,
    required this.regex,
    this.name = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'regex': regex,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory RegexHistory.fromJson(Map<String, dynamic> json) => RegexHistory(
        id: json['id'] as String,
        regex: json['regex'] as String,
        name: json['name'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );

  static String encodeList(List<RegexHistory> list) =>
      jsonEncode(list.map((h) => h.toJson()).toList());

  static List<RegexHistory> decodeList(String str) {
    final List<dynamic> list = jsonDecode(str);
    return list
        .map((e) => RegexHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  RegexHistory copyWith({
    String? id,
    String? regex,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      RegexHistory(
        id: id ?? this.id,
        regex: regex ?? this.regex,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
