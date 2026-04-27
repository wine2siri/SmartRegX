import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/regex_tag.dart';
import '../providers/tag_provider.dart';
import '../theme/app_themes.dart';

class CategoryBar extends StatelessWidget {
  final AppThemeData themeData;

  const CategoryBar({super.key, required this.themeData});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TagProvider>();
    final t = themeData;

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: t.surfaceColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.chipBorder.withValues(alpha: 0.3)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        children: [
          _buildChip(context, provider, null, '全部'),
          ...TagCategory.values.map((cat) => _buildChip(context, provider, cat, '${cat.icon} ${cat.label}')),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, TagProvider provider, TagCategory? cat, String label) {
    final t = themeData;
    final isSelected = provider.selectedCategory == cat;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: () => provider.setCategory(cat),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? t.accentColor.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? t.accentColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? t.accentColor : t.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
