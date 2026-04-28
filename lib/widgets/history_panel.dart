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
    final t = themeData;
    final provider = context.watch<TagProvider>();
    final history = provider.history;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, color: t.textSecondary.withOpacity(0.3), size: 48),
            const SizedBox(height: 12),
            Text('暂无历史记录', style: TextStyle(color: t.textSecondary, fontSize: 14)),
            const SizedBox(height: 4),
            Text('保存正则后会自动记录', style: TextStyle(color: t.textSecondary.withOpacity(0.6), fontSize: 12)),
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

  const _HistoryCard({
    required this.item,
    required this.themeData,
    required this.onLoad,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeData;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: t.raisedBox(radius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onDoubleTap: () {
                    final controller = TextEditingController(text: item.name);
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: t.surfaceColor,
                        title: Text('重命名', style: TextStyle(color: t.textPrimary)),
                        content: TextField(
                          controller: controller,
                          style: TextStyle(color: t.accentColor),
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: '输入名称',
                            hintStyle: TextStyle(color: t.textSecondary),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: t.accentColorDim)),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('取消', style: TextStyle(color: t.textSecondary)),
                          ),
                          TextButton(
                            onPressed: () {
                              onRename(controller.text);
                              Navigator.pop(ctx);
                            },
                            child: Text('确定', style: TextStyle(color: t.accentColor)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    item.name.isEmpty ? '未命名' : item.name,
                    style: TextStyle(
                      color: item.name.isEmpty ? t.textSecondary : t.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Text(
                _formatTime(item.updatedAt),
                style: TextStyle(color: t.textSecondary.withOpacity(0.6), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: t.insetBox(radius: 8, color: t.editorBg),
            child: Text(
              item.regex,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: t.accentColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _SmallButton(
                icon: Icons.play_arrow,
                label: '加载',
                themeData: t,
                onTap: onLoad,
              ),
              const SizedBox(width: 4),
              _SmallButton(
                icon: Icons.copy,
                label: '复制',
                themeData: t,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: item.regex));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已复制', style: TextStyle(color: t.textPrimary)),
                      backgroundColor: t.surfaceColor,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              _SmallButton(
                icon: Icons.delete_outline,
                label: '删除',
                themeData: t,
                onTap: onDelete,
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppThemeData themeData;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SmallButton({
    required this.icon,
    required this.label,
    required this.themeData,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeData;
    final color = isDestructive ? t.errorColor.withOpacity(0.7) : t.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: t.raisedButton(radius: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 2),
            Text(label, style: TextStyle(color: color, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
