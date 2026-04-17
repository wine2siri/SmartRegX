import 'dart:convert';

class RegexTag {
  final String id;
  final String label;
  final String pattern;
  int useCount;
  DateTime lastUsedAt;
  int? customOrder;

  RegexTag({
    required this.id,
    required this.label,
    required this.pattern,
    this.useCount = 0,
    DateTime? lastUsedAt,
    this.customOrder,
  }) : lastUsedAt = lastUsedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'pattern': pattern,
        'useCount': useCount,
        'lastUsedAt': lastUsedAt.toIso8601String(),
        'customOrder': customOrder,
      };

  factory RegexTag.fromJson(Map<String, dynamic> json) => RegexTag(
        id: json['id'] as String,
        label: json['label'] as String,
        pattern: json['pattern'] as String,
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
    int? useCount,
    DateTime? lastUsedAt,
    int? customOrder,
  }) =>
      RegexTag(
        id: id ?? this.id,
        label: label ?? this.label,
        pattern: pattern ?? this.pattern,
        useCount: useCount ?? this.useCount,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
        customOrder: customOrder ?? this.customOrder,
      );
}
