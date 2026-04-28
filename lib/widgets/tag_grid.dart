import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/regex_tag.dart';
import '../providers/tag_provider.dart';
import '../theme/app_themes.dart';
import '../services/regex_validator.dart';

class TagGrid extends StatelessWidget {
  final AppThemeData themeData;
  final ValueChanged<RegexTag> onTagTap;

  const TagGrid({super.key, required this.themeData, required this.onTagTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TagProvider>();
    final t = themeData;
    final tags = provider.tags;

    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: t.accentColor, strokeWidth: 2),
      );
    }

    if (tags.isEmpty) {
      return Center(
        child: Text('暂无标签', style: TextStyle(color: t.textSecondary)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: tags.map((tag) => _TagCard(
          tag: tag,
          themeData: t,
          onTap: () => onTagTap(tag),
          onLongPress: () => _showTagDetail(context, tag, t),
        )).toList(),
      ),
    );
  }

  void _showTagDetail(BuildContext context, RegexTag tag, AppThemeData t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: t.surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: t.raisedBox(radius: 20, color: t.surfaceColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: t.raisedButton(radius: 8, active: true),
                  child: Text(tag.label, style: TextStyle(color: t.accentColor, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.copy, color: t.textSecondary, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: tag.pattern));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: t.insetBox(radius: 10, color: t.editorBg),
              child: Text(
                tag.pattern,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  color: t.accentColor,
                ),
              ),
            ),
            if (tag.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(tag.description, style: TextStyle(color: t.textSecondary, fontSize: 14, height: 1.5)),
            ],
            const SizedBox(height: 8),
            Text(
              '分类: ${tag.category.icon} ${tag.category.label}',
              style: TextStyle(color: t.textSecondary.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagCard extends StatelessWidget {
  final RegexTag tag;
  final AppThemeData themeData;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TagCard({
    required this.tag,
    required this.themeData,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeData;

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: t.flatBox(radius: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag.label,
              style: TextStyle(
                color: t.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              tag.pattern,
              style: TextStyle(
                fontFamily: 'monospace',
                color: t.accentColor.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
