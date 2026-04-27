import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/regex_tag.dart';
import '../providers/tag_provider.dart';
import '../theme/app_themes.dart';

class HistoryPanel extends StatelessWidget {
  final AppThemeData themeData;
  final ValueChanged<String> onLoad;

  const HistoryPanel({super.key, required this.themeData, required this.onLoad});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TagProvider>();
    final t = themeData;
    final history = provider.history;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 48, color: t.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('暂无历史记录', style: TextStyle(color: t.textSecondary, fontSize: 14)),
            const SizedBox(height: 4),
            Text('保存正则后会出现在这里', style: TextStyle(color: t.textSecondary.withValues(alpha: 0.6), fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return _HistoryCard(
          item: item,
          themeData: t,
          onLoad: () => onLoad(item.regex),
          onRename: (name) => provider.renameHistory(item.id, name),
          onDelete: () => provider.deleteHistory(item.id),
          onCopy: () {
            Clipboard.setData(ClipboardData(text: item.regex));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已复制', style: TextStyle(color: t.textPrimary)),
                backgroundColor: t.surfaceColor,
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final RegexHistory item;
  final AppThemeData themeData;
  final VoidCallback onLoad;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const _HistoryCard({
    required this.item,
    required this.themeData,
    required this.onLoad,
    required this.onRename,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeData;
    final timeStr = _formatTime(item.updatedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.chipBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.chipBorder.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showRenameDialog(context),
                  child: Row(
                    children: [
                      if (item.name.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: t.accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.name,
                            style: TextStyle(color: t.accentColor, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        timeStr,
                        style: TextStyle(color: t.textSecondary.withValues(alpha: 0.6), fontSize: 10),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.edit, size: 10, color: t.textSecondary.withValues(alpha: 0.4)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onLoad,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: t.editorBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: t.accentColor.withValues(alpha: 0.15)),
              ),
              child: Text(
                item.regex,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  color: t.accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _MiniButton(icon: Icons.play_arrow, label: '加载', color: t.accentColor, onTap: onLoad),
              const SizedBox(width: 8),
              _MiniButton(icon: Icons.copy, label: '复制', color: t.textSecondary, onTap: onCopy),
              const SizedBox(width: 8),
              _MiniButton(icon: Icons.delete_outline, label: '删除', color: t.errorColor.withValues(alpha: 0.7), onTap: onDelete),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${dt.month}/${dt.day}';
  }

  void _showRenameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: themeData.surfaceColor,
        title: Text('命名', style: TextStyle(color: themeData.textPrimary)),
        content: TextField(
          controller: ctrl,
          style: TextStyle(color: themeData.textPrimary),
          decoration: InputDecoration(
            hintText: '给这条正则起个名字',
            hintStyle: TextStyle(color: themeData.textSecondary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeData.chipBorder)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeData.accentColor)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: themeData.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              onRename(ctrl.text.trim());
              Navigator.pop(context);
            },
            child: Text('确定', style: TextStyle(color: themeData.accentColor)),
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MiniButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
