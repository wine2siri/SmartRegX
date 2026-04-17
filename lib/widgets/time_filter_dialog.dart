import 'package:flutter/material.dart';

class TimeFilterDialog extends StatefulWidget {
  final int currentDays;

  const TimeFilterDialog({super.key, required this.currentDays});

  @override
  State<TimeFilterDialog> createState() => _TimeFilterDialogState();
}

class _TimeFilterDialogState extends State<TimeFilterDialog> {
  late int _selectedDays;

  final _presets = [
    (0, '全部时间'),
    (1, '最近1天'),
    (7, '最近7天'),
    (30, '最近30天'),
    (90, '最近90天'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.currentDays;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('筛选时间周期'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _presets.map((p) {
          return RadioListTile<int>(
            title: Text(p.$2),
            value: p.$1,
            groupValue: _selectedDays,
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedDays = v);
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedDays),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
