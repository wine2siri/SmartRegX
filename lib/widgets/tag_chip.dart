import 'package:flutter/material.dart';
import '../models/regex_tag.dart';

class TagChip extends StatelessWidget {
  final RegexTag tag;
  final double fontSize;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const TagChip({
    super.key,
    required this.tag,
    required this.fontSize,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: onLongPress,
      child: InputChip(
        label: Text(
          tag.label,
          style: TextStyle(fontSize: fontSize),
        ),
        tooltip: '${tag.label}: ${tag.pattern}',
        onPressed: onTap,
        onDeleted: onDelete,
        deleteIconColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
