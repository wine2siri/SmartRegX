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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小白正则'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
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
        ),
      ),
    );
  }
}
