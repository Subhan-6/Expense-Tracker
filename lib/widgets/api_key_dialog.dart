import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/advisor_provider.dart';

Future<void> showApiKeyDialog(BuildContext context) {
  return showDialog(context: context, builder: (_) => const _ApiKeyDialog());
}

class _ApiKeyDialog extends StatefulWidget {
  const _ApiKeyDialog();

  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  final _controller = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Paste your API key');
      return;
    }
    await context.read<AdvisorProvider>().saveKey(key);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _remove() async {
    await context.read<AdvisorProvider>().removeKey();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasKey = context.watch<AdvisorProvider>().hasKey;
    return AlertDialog(
      title: const Text('Claude API key'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create a key at console.anthropic.com. It is stored only on this '
              'device and used only to request advice.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: hasKey ? 'New key (replaces saved key)' : 'API key',
                hintText: 'sk-ant-...',
                errorText: _error,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (hasKey)
          TextButton(onPressed: _remove, child: const Text('Remove key')),
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
