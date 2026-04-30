import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/regex_analyzer.dart';
import '../theme/app_themes.dart';

enum AnalysisMode { pattern, replacement }

class AnalysisPanel extends StatefulWidget {
  final AppThemeData themeData;
  final ValueChanged<String> onApplyRegex;

  const AnalysisPanel({
    super.key,
    required this.themeData,
    required this.onApplyRegex,
  });

  @override
  State<AnalysisPanel> createState() => _AnalysisPanelState();
}

class _AnalysisPanelState extends State<AnalysisPanel> {
  AnalysisMode _mode = AnalysisMode.pattern;
  final _sourceController = TextEditingController();
  final _targetController = TextEditingController();
  AnalysisResult? _result;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _analyze() {
    final sourceText = _sourceController.text.trim();
    if (sourceText.isEmpty) return;

    final sources = sourceText.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    setState(() => _isAnalyzing = true);

    Future.delayed(const Duration(milliseconds: 100), () {
      AnalysisResult? result;
      if (_mode == AnalysisMode.pattern) {
        result = RegexAnalyzer.analyzePattern(sources);
      } else {
        final targetText = _targetController.text.trim();
        final targets = targetText.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        result = RegexAnalyzer.analyzeReplacement(sources, targets);
      }

      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    });
  }

  void _insertToSource(String text) {
    final current = _sourceController.text;
    if (current.isNotEmpty && !current.endsWith('\n')) {
      _sourceController.text = '$current\n$text';
    } else {
      _sourceController.text = '$current$text';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.themeData;

    return Column(
      children: [
        _buildModeSwitcher(t),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSourceInput(t),
                if (_mode == AnalysisMode.replacement) ...[
                  const SizedBox(height: 8),
                  _buildTargetInput(t),
                ],
                const SizedBox(height: 8),
                _buildAnalyzeButton(t),
                if (_isAnalyzing)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator(color: t.accentColor, strokeWidth: 2)),
                  ),
                if (_result != null && !_isAnalyzing) ...[
                  const SizedBox(height: 12),
                  _buildResult(t),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSwitcher(AppThemeData t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(3),
      decoration: t.insetBox(radius: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _mode = AnalysisMode.pattern;
                _result = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: _mode == AnalysisMode.pattern ? t.accentColor.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: _mode == AnalysisMode.pattern ? Border.all(color: t.accentColor.withOpacity(0.4), width: 1) : null,
                ),
                child: Center(
                  child: Text(
                    '模式推导',
                    style: TextStyle(
                      color: _mode == AnalysisMode.pattern ? t.accentColor : t.textSecondary,
                      fontSize: 13,
                      fontWeight: _mode == AnalysisMode.pattern ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _mode = AnalysisMode.replacement;
                _result = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: _mode == AnalysisMode.replacement ? t.accentColor.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: _mode == AnalysisMode.replacement ? Border.all(color: t.accentColor.withOpacity(0.4), width: 1) : null,
                ),
                child: Center(
                  child: Text(
                    '替换推导',
                    style: TextStyle(
                      color: _mode == AnalysisMode.replacement ? t.accentColor : t.textSecondary,
                      fontSize: 13,
                      fontWeight: _mode == AnalysisMode.replacement ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceInput(AppThemeData t) {
    final hint = _mode == AnalysisMode.pattern
        ? '粘贴样例，一行一个\n例如：\n13800138000\n15912345678\n18600001111'
        : '粘贴原始内容，一行一个\n例如：\nhello world\nfoo bar\ntest case';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: t.raisedBox(radius: 6),
              child: Text(
                _mode == AnalysisMode.pattern ? '样例输入' : '原始内容',
                style: TextStyle(color: t.accentColor, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '至少2行',
              style: TextStyle(color: t.textSecondary.withOpacity(0.7), fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          constraints: const BoxConstraints(minHeight: 100, maxHeight: 160),
          child: TextField(
            controller: _sourceController,
            maxLines: null,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: t.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: t.textSecondary.withOpacity(0.4), fontSize: 12),
              filled: true,
              fillColor: t.editorBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetInput(AppThemeData t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: t.raisedBox(radius: 6),
              child: Text(
                '目标内容',
                style: TextStyle(color: t.accentColor, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '至少2行，与原始一一对应',
              style: TextStyle(color: t.textSecondary.withOpacity(0.7), fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          constraints: const BoxConstraints(minHeight: 80, maxHeight: 120),
          child: TextField(
            controller: _targetController,
            maxLines: null,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: t.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '粘贴目标内容，一行一个\n例如：\nHELLO WORLD\nFOO BAR\nTEST CASE',
              hintStyle: TextStyle(color: t.textSecondary.withOpacity(0.4), fontSize: 12),
              filled: true,
              fillColor: t.editorBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton(AppThemeData t) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _analyze,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: t.accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: t.accentColor.withOpacity(0.4), width: 1),
            boxShadow: [BoxShadow(color: t.neonGlow.withOpacity(0.1), blurRadius: 8)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_fix_high, color: t.accentColor, size: 18),
              const SizedBox(width: 6),
              Text(
                '分析推导',
                style: TextStyle(
                  color: t.accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(AppThemeData t) {
    final result = _result!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: t.raisedBox(radius: 8),
          child: Text(
            '分析结果',
            style: TextStyle(color: t.accentColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: t.insetBox(radius: 12, color: t.editorBg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '正则表达式',
                    style: TextStyle(color: t.textSecondary, fontSize: 11),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: result.regex));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('已复制正则', style: TextStyle(color: t.textPrimary)),
                          backgroundColor: t.surfaceColor,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Icon(Icons.copy, color: t.textSecondary, size: 14),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => widget.onApplyRegex(result.regex),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: t.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: t.accentColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        '应用',
                        style: TextStyle(color: t.accentColor, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SelectableText(
                result.regex,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  color: t.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (result.replacement != null) ...[
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
                  '替换表达式',
                  style: TextStyle(color: t.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  result.replacement!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    color: t.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
                result.explanation,
                style: TextStyle(color: t.textPrimary, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: t.raisedBox(radius: 8),
          child: Text(
            '样例验证',
            style: TextStyle(color: t.accentColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),
        ...List.generate(result.examples.length, (i) {
          final example = result.examples[i];
          final matched = result.matches[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: t.flatBox(radius: 6),
            child: Row(
              children: [
                Icon(
                  matched ? Icons.check_circle : Icons.cancel,
                  color: matched ? t.successColor : t.errorColor,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SelectableText(
                    example,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: t.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
