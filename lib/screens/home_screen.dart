import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/regex_tag.dart';
import '../providers/tag_provider.dart';
import '../theme/app_themes.dart';
import '../widgets/category_bar.dart';
import '../widgets/regex_editor_bar.dart';
import '../widgets/tag_grid.dart';
import '../widgets/explanation_view.dart';
import '../widgets/history_panel.dart';
import '../widgets/analysis_panel.dart';

class HomeScreen extends StatefulWidget {
  final AppThemeData themeData;

  const HomeScreen({super.key, required this.themeData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _regex = '';
  late TabController _tabController;
  final GlobalKey<_AnalysisPanelWrapperState> _analysisKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTagTap(RegexTag tag) {
    if (_tabController.index == 3) {
      _analysisKey.currentState?.insertToSource(tag.pattern);
    } else {
      setState(() => _regex += tag.pattern);
    }
    final provider = context.read<TagProvider>();
    provider.recordUsage(tag.id);
  }

  void _onRegexChanged(String value) {
    setState(() => _regex = value);
  }

  void _onClear() {
    setState(() => _regex = '');
  }

  void _onBackspace() {
    if (_regex.isEmpty) return;
    setState(() => _regex = _regex.substring(0, _regex.length - 1));
  }

  void _onSave() {
    if (_regex.isEmpty) return;
    context.read<TagProvider>().addHistory(_regex);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已保存到历史记录', style: TextStyle(color: widget.themeData.textPrimary)),
        backgroundColor: widget.themeData.surfaceColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _loadFromHistory(String regex) {
    setState(() => _regex = regex);
    _tabController.animateTo(0);
  }

  void _applyRegexFromAnalysis(String regex) {
    setState(() => _regex = regex);
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.themeData;
    final provider = context.watch<TagProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: t.surfaceColor.withOpacity(0.85),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.accentColor,
                boxShadow: [BoxShadow(color: t.neonGlow.withOpacity(0.6), blurRadius: 8)],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '小白正则',
              style: TextStyle(
                color: t.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          _buildThemeSwitcher(t, provider),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(42),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(3),
            decoration: t.insetBox(radius: 10),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: t.accentColor,
              unselectedLabelColor: t.textSecondary,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              indicator: BoxDecoration(
                color: t.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: t.neonGlow.withOpacity(0.1), blurRadius: 4),
                ],
              ),
              tabs: const [
                Tab(text: '编辑'),
                Tab(text: '解释'),
                Tab(text: '历史'),
                Tab(text: '分析'),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: t.background),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEditorTab(t, provider),
                    ExplanationView(regex: _regex, themeData: t),
                    HistoryPanel(themeData: t, onLoad: _loadFromHistory),
                    _AnalysisPanelWrapper(
                      key: _analysisKey,
                      themeData: t,
                      onApplyRegex: _applyRegexFromAnalysis,
                    ),
                  ],
                ),
              ),
              if (_tabController.index != 3)
                RegexEditorBar(
                  regex: _regex,
                  themeData: t,
                  onBackspace: _onBackspace,
                  onClear: _onClear,
                  onSave: _onSave,
                  onChanged: _onRegexChanged,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorTab(AppThemeData t, TagProvider provider) {
    return Column(
      children: [
        CategoryBar(themeData: t),
        Expanded(
          child: TagGrid(
            themeData: t,
            onTagTap: _onTagTap,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSwitcher(AppThemeData t, TagProvider provider) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.palette_outlined, color: t.textSecondary, size: 20),
      color: t.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => provider.setTheme(value),
      itemBuilder: (_) => AppThemes.themes.entries.map((e) => PopupMenuItem(
        value: e.key,
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: e.value.accentColor,
                boxShadow: [BoxShadow(color: e.value.neonGlow.withOpacity(0.4), blurRadius: 4)],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              e.value.name,
              style: TextStyle(
                color: provider.theme == e.key ? t.accentColor : t.textPrimary,
                fontWeight: provider.theme == e.key ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _AnalysisPanelWrapper extends StatefulWidget {
  final AppThemeData themeData;
  final ValueChanged<String> onApplyRegex;

  const _AnalysisPanelWrapper({super.key, required this.themeData, required this.onApplyRegex});

  @override
  State<_AnalysisPanelWrapper> createState() => _AnalysisPanelWrapperState();
}

class _AnalysisPanelWrapperState extends State<_AnalysisPanelWrapper> {
  final _sourceController = TextEditingController();

  void insertToSource(String text) {
    final current = _sourceController.text;
    if (current.isNotEmpty && !current.endsWith('\n')) {
      _sourceController.text = '$current\n$text';
    } else {
      _sourceController.text = '$current$text';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnalysisPanel(
      themeData: widget.themeData,
      onApplyRegex: widget.onApplyRegex,
    );
  }
}
