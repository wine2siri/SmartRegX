import 'package:flutter/material.dart';
import '../services/regex_explainer.dart';
import '../services/regex_validator.dart';
import '../theme/app_themes.dart';

class ExplanationView extends StatelessWidget {
  final String regex;
  final AppThemeData themeData;

  const ExplanationView({super.key, required this.regex, required this.themeData});

  @override
  Widget build(BuildContext context) {
    final t = themeData;

    if (regex.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_fix_high, color: t.textSecondary.withOpacity(0.3), size: 48),
            const SizedBox(height: 12),
            Text('输入正则后查看解释', style: TextStyle(color: t.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    final error = RegexValidator.validate(regex);
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: t.errorColor.withOpacity(0.5), size: 48),
            const SizedBox(height: 12),
            Text('正则语法有误，无法解释', style: TextStyle(color: t.errorColor, fontSize: 14)),
          ],
        ),
      );
    }

    final brief = RegexExplainer.explain(regex);
    final details = RegexExplainer.explainDetailed(regex);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: t.insetBox(radius: 12, color: t.editorBg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  regex,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 18,
                    color: t.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [t.accentColor.withOpacity(0.3), Colors.transparent],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  brief,
                  style: TextStyle(color: t.textPrimary, fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: t.raisedBox(radius: 8),
            child: Text(
              '逐条对照',
              style: TextStyle(color: t.accentColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          ...details.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: t.flatBox(radius: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: t.insetBox(radius: 4, color: t.editorBg),
                  child: Text(
                    item.token,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: t.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.meaning,
                    style: TextStyle(color: t.textPrimary, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
