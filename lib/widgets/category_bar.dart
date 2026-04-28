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
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: t.raisedBox(radius: 14),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(provider, null, '全部'),
          ...TagCategory.values.map((cat) => _buildChip(provider, cat, '${cat.icon} ${cat.label}')),
        ],
      ),
    );
  }

  Widget _buildChip(TagProvider provider, TagCategory? cat, String label) {
    final t = themeData;
    final isSelected = provider.selectedCategory == cat;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      child: GestureDetector(
        onTap: () => provider.setCategory(cat),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: t.raisedButton(radius: 8, active: isSelected),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? t.accentColor : t.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
