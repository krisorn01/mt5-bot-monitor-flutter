import 'package:flutter/material.dart';

import '../repository.dart';
import '../theme.dart';
import '../widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _url = TextEditingController();
  bool _init = false;
  bool _saving = false;
  double _seconds = 5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      final repo = RepositoryScope.of(context);
      _url.text = repo.api.baseUrl;
      _seconds = repo.refreshSeconds.toDouble();
      _init = true;
    }
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final repo = RepositoryScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repo.savePrefs(baseUrl: _url.text, seconds: _seconds.round());
      await repo.refresh();
      messenger.showSnackBar(const SnackBar(content: Text('Settings saved')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionTitle('Bridge API base URL'),
            TextField(
              controller: _url,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                hintText: 'http://127.0.0.1:5581',
              ),
            ),
            const SizedBox(height: 16),
            SectionTitle('Refresh interval: ${_seconds.round()} s'),
            Slider(
              value: _seconds,
              min: 3,
              max: 30,
              divisions: 27,
              label: '${_seconds.round()} s',
              onChanged: (v) => setState(() => _seconds = v),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save'),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        const AppCard(
          child: Text(
            'Flutter client for the Python↔MT5 bridge · demo data',
            style: TextStyle(color: kMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
