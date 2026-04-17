import 'package:flutter/material.dart';
import '../services/regex_validator.dart';

class RegexEditor extends StatefulWidget {
  final String regex;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const RegexEditor({
    super.key,
    required this.regex,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<RegexEditor> createState() => _RegexEditorState();
}

class _RegexEditorState extends State<RegexEditor> {
  late TextEditingController _controller;
  RegexError? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.regex);
  }

  @override
  void didUpdateWidget(RegexEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.regex != _controller.text) {
      _controller.text = widget.regex;
      _error = RegexValidator.validate(widget.regex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _error = RegexValidator.validate(value);
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: _error != null
                ? Border.all(color: theme.colorScheme.error, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _controller,
                        onChanged: _onChanged,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '点击下方标签拼接正则表达式...',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                  ),
                  if (widget.regex.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _error = null);
                        widget.onClear();
                      },
                    ),
                ],
              ),
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          size: 16, color: theme.colorScheme.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '位置${_error!.position}: ${_error!.message}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
