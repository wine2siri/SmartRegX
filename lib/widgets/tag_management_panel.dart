import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/regex_tag.dart';
import '../providers/tag_provider.dart';
import 'tag_chip.dart';
import 'tag_edit_dialog.dart';
import 'time_filter_dialog.dart';

class TagManagementPanel extends StatefulWidget {
  final ValueChanged<RegexTag> onTagTap;

  const TagManagementPanel({super.key, required this.onTagTap});

  @override
  State<TagManagementPanel> createState() => _TagManagementPanelState();
}

class _TagManagementPanelState extends State<TagManagementPanel> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TagProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final tags = provider.tags;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(provider),
            const SizedBox(height: 8),
            _buildTagGrid(provider, tags),
          ],
        );
      },
    );
  }

  Widget _buildHeader(TagProvider provider) {
    return Row(
      children: [
        Text(
          '标签库',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.filter_list, size: 20),
          tooltip: '时间筛选',
          onPressed: () => _showTimeFilter(provider),
        ),
        IconButton(
          icon: const Icon(Icons.sort, size: 20),
          tooltip: '重置排序',
          onPressed: () => provider.clearCustomOrders(),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 20),
          tooltip: '添加标签',
          onPressed: () => _addTag(provider),
        ),
      ],
    );
  }

  Widget _buildTagGrid(TagProvider provider, List<RegexTag> tags) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(tags.length, (index) {
        final tag = tags[index];
        final fontSize = provider.tagFontSize(tag);
        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            child: Chip(
              label: Text(tag.label, style: TextStyle(fontSize: fontSize)),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: TagChip(
              tag: tag,
              fontSize: fontSize,
              onTap: () => widget.onTagTap(tag),
              onLongPress: () {},
              onDelete: () => provider.removeTag(tag.id),
            ),
          ),
          onDragStarted: () {},
          onDragEnd: (_) {},
          child: DragTarget<int>(
            onWillAcceptWithDetails: (details) {
              return details.data != index;
            },
            onAcceptWithDetails: (details) {
              provider.reorderTags(details.data, index);
            },
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: isHovering
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      )
                    : null,
                child: TagChip(
                  tag: tag,
                  fontSize: fontSize,
                  onTap: () {
                    widget.onTagTap(tag);
                    provider.recordUsage(tag.id);
                  },
                  onLongPress: () => _editTag(provider, tag),
                  onDelete: () => provider.removeTag(tag.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Future<void> _addTag(TagProvider provider) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const TagEditDialog(),
    );
    if (result != null) {
      await provider.addTag(result.$1, result.$2);
    }
  }

  Future<void> _editTag(TagProvider provider, RegexTag tag) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => TagEditDialog(
        initialLabel: tag.label,
        initialPattern: tag.pattern,
      ),
    );
    if (result != null) {
      await provider.updateTag(tag.id, label: result.$1, pattern: result.$2);
    }
  }

  Future<void> _showTimeFilter(TagProvider provider) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => TimeFilterDialog(currentDays: provider.timeFilterDays),
    );
    if (result != null) {
      await provider.setTimeFilterDays(result);
    }
  }
}
