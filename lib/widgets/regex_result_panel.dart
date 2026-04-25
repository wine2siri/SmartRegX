import 'package:flutter/material.dart';
import '../services/regex_explainer.dart';
import '../services/regex_validator.dart';

class RegexResultPanel extends StatelessWidget {
  final String regex;

  const RegexResultPanel({super.key, required this.regex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (regex.isEmpty) {
      return const SizedBox.shrink();
    }

    final error = RegexValidator.validate(regex);
    final isValid = error == null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: isValid ? Colors.green : theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                isValid ? '语法正确' : '语法错误',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isValid ? Colors.green : theme.colorScheme.error,
                ),
              ),
            ],
          ),
          if (isValid) ...[
            const SizedBox(height: 12),
            Text(
              '语义解释：',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              RegexExplainer.explain(regex),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.85),
                height: 1.5,
              ),
            ),
          ],
          if (!isValid) ...[
            const SizedBox(height: 8),
            Text(
              '位置${error.position}: ${error.message}',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
