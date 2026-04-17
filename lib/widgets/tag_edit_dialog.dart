import 'package:flutter/material.dart';

class TagEditDialog extends StatefulWidget {
  final String? initialLabel;
  final String? initialPattern;

  const TagEditDialog({
    super.key,
    this.initialLabel,
    this.initialPattern,
  });

  @override
  State<TagEditDialog> createState() => _TagEditDialogState();
}

class _TagEditDialogState extends State<TagEditDialog> {
  late TextEditingController _labelCtrl;
  late TextEditingController _patternCtrl;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.initialLabel ?? '');
    _patternCtrl = TextEditingController(text: widget.initialPattern ?? '');
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _patternCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialLabel != null;
    return AlertDialog(
      title: Text(isEdit ? '编辑标签' : '添加标签'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _labelCtrl,
            decoration: const InputDecoration(
              labelText: '中文标签名',
              hintText: '例如：手机号',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _patternCtrl,
            decoration: const InputDecoration(
              labelText: '正则表达式',
              hintText: '例如：1[3-9]\\d{9}',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final label = _labelCtrl.text.trim();
            final pattern = _patternCtrl.text.trim();
            if (label.isNotEmpty && pattern.isNotEmpty) {
              Navigator.pop(context, (label, pattern));
            }
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
