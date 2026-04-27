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
            Icon(Icons.code, size: 48, color: t.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('在编辑Tab中拼接正则表达式', style: TextStyle(color: t.textSecondary, fontSize: 14)),
            const SizedBox(height: 4),
            Text('这里将显示逐条解释', style: TextStyle(color: t.textSecondary.withValues(alpha: 0.6), fontSize: 12)),
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
            Icon(Icons.error_outline, size: 48, color: t.errorColor.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('正则语法有误', style: TextStyle(color: t.errorColor, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('位置${error.position}: ${error.message}', style: TextStyle(color: t.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    final explanation = RegexExplainer.explainDetailed(regex);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.editorBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.accentColor.withValues(alpha: 0.3)),
            boxShadow: [BoxShadow(color: t.neonGlow.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Text(
            regex,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
              color: t.accentColor,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.surfaceColorLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.translate, color: t.accentColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  RegexExplainer.explain(regex),
                  style: TextStyle(color: t.textPrimary, fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('逐条对照', style: TextStyle(color: t.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...explanation.map((item) => _ExplanationCard(
          token: item.token,
          meaning: item.meaning,
          themeData: t,
        )),
      ],
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final String token;
  final String meaning;
  final AppThemeData themeData;

  const _ExplanationCard({
    required this.token,
    required this.meaning,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeData;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.chipBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: t.chipBorder.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 60, maxWidth: 120),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: t.editorBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: t.accentColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              token,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: t.accentColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.arrow_forward, color: t.textSecondary.withValues(alpha: 0.4), size: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              meaning,
              style: TextStyle(color: t.textPrimary, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
