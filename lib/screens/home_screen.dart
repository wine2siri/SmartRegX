import 'package:flutter/material.dart';
import '../models/regex_tag.dart';
import '../widgets/regex_editor.dart';
import '../widgets/regex_result_panel.dart';
import '../widgets/tag_management_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _regex = '';

  void _onTagTap(RegexTag tag) {
    setState(() {
      _regex += tag.pattern;
    });
  }

  void _onRegexChanged(String value) {
    setState(() {
      _regex = value;
    });
  }

  void _onClear() {
    setState(() {
      _regex = '';
    });
  }

  bool get _isWideScreen {
    return MediaQuery.of(context).size.width > 700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小白正则'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isWideScreen ? _buildWideLayout() : _buildNarrowLayout(),
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RegexEditor(
            regex: _regex,
            onChanged: _onRegexChanged,
            onClear: _onClear,
          ),
          const SizedBox(height: 12),
          RegexResultPanel(regex: _regex),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: TagManagementPanel(onTagTap: _onTagTap),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RegexEditor(
                  regex: _regex,
                  onChanged: _onRegexChanged,
                  onClear: _onClear,
                ),
                const SizedBox(height: 16),
                RegexResultPanel(regex: _regex),
              ],
            ),
          ),
          const SizedBox(width: 24),
          const VerticalDivider(width: 1),
          const SizedBox(width: 24),
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: TagManagementPanel(onTagTap: _onTagTap),
            ),
          ),
        ],
      ),
    );
  }
}
