import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/regex_validator.dart';
import '../theme/app_themes.dart';

class RegexEditorBar extends StatefulWidget {
  final String regex;
  final AppThemeData themeData;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onSave;
  final ValueChanged<String> onChanged;

  const RegexEditorBar({
    super.key,
    required this.regex,
    required this.themeData,
    required this.onBackspace,
    required this.onClear,
    required this.onSave,
    required this.onChanged,
  });

  @override
  State<RegexEditorBar> createState() => _RegexEditorBarState();
}

class _RegexEditorBarState extends State<RegexEditorBar> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.regex);
  }

  @override
  void didUpdateWidget(RegexEditorBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.regex != _controller.text) {
      _controller.text = widget.regex;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.themeData;
    final error = RegexValidator.validate(widget.regex);
    final isValid = error == null && widget.regex.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: t.surfaceColor.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: t.accentColor.withValues(alpha: 0.2), width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.regex.isNotEmpty && !isValid)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: t.errorColor.withValues(alpha: 0.1),
              child: Text(
                '位置${error!.position}: ${error.message}',
                style: TextStyle(color: t.errorColor, fontSize: 11),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                if (isValid)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.successColor,
                      boxShadow: [BoxShadow(color: t.successColor.withValues(alpha: 0.5), blurRadius: 4)],
                    ),
                  )
                else if (widget.regex.isNotEmpty)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.errorColor,
                      boxShadow: [BoxShadow(color: t.errorColor.withValues(alpha: 0.5), blurRadius: 4)],
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: _isEditing
                      ? TextField(
                          controller: _controller,
                          autofocus: true,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                            color: t.accentColor,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (v) {
                            widget.onChanged(v);
                          },
                          onSubmitted: (_) {
                            setState(() => _isEditing = false);
                          },
                        )
                      : GestureDetector(
                          onTap: () => setState(() => _isEditing = true),
                          child: Text(
                            widget.regex.isEmpty ? '点击标签拼接正则...' : widget.regex,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                              color: widget.regex.isEmpty ? t.textSecondary : t.accentColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.keyboard,
                  label: '输入',
                  themeData: t,
                  onTap: () => setState(() => _isEditing = true),
                ),
                _ActionButton(
                  icon: Icons.backspace_outlined,
                  label: '退格',
                  themeData: t,
                  onTap: widget.onBackspace,
                ),
                _ActionButton(
                  icon: Icons.copy_outlined,
                  label: '复制',
                  themeData: t,
                  onTap: () {
                    if (widget.regex.isEmpty) return;
                    Clipboard.setData(ClipboardData(text: widget.regex));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已复制', style: TextStyle(color: t.textPrimary)),
                        backgroundColor: t.surfaceColor,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.save_outlined,
                  label: '保存',
                  themeData: t,
                  onTap: widget.onSave,
                ),
                _ActionButton(
                  icon: Icons.delete_outline,
                  label: '清空',
                  themeData: t,
                  onTap: widget.onClear,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppThemeData themeData;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.themeData,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeData;
    final color = isDestructive ? t.errorColor.withValues(alpha: 0.8) : t.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
