import 'package:flutter/material.dart';

import '../main.dart';
import '../models/app_settings_model.dart';
import '../services/formatters.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController budgetController;
  late final TextEditingController namesController;
  DateTime? weddingDate;
  PreparationType type = PreparationType.full;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final settings = AppScope.of(context).settings;
    weddingDate = settings.weddingDate;
    type = settings.preparationType;
    budgetController = TextEditingController(
      text: settings.targetBudget.toStringAsFixed(0),
    );
    namesController = TextEditingController(text: settings.coupleNames);
    _initialized = true;
  }

  @override
  void dispose() {
    budgetController.dispose();
    namesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      weddingDate == null
                          ? 'Düğün tarihi seç'
                          : '${weddingDate!.day}.${weddingDate!.month}.${weddingDate!.year}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Hedef bütçe'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: namesController,
                    decoration:
                        const InputDecoration(labelText: 'Çift isimleri'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PreparationType>(
                    value: type,
                    decoration:
                        const InputDecoration(labelText: 'Hazırlık tipi'),
                    items: [
                      for (final option in PreparationType.values)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => type = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await controller.saveSettings(
                          controller.settings.copyWith(
                            weddingDate: weddingDate,
                            targetBudget: parseMoney(budgetController.text),
                            coupleNames: namesController.text.trim(),
                            preparationType: type,
                            hasCompletedOnboarding: true,
                          ),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ayarlar kaydedildi')),
                          );
                        }
                      },
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Gizlilik'),
              subtitle: const Text('Veriler cihazda saklanır.'),
              isThreeLine: false,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Uygulama hakkında'),
              subtitle: const Text(
                'Çeyiz, düğün, bütçe ve davetli hazırlıklarını offline takip eder.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined),
              title: const Text('Verileri sıfırla'),
              subtitle: const Text('Tüm liste, davetli ve ayar verileri silinir.'),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Veriler sıfırlansın mı?'),
                    content: const Text('Bu işlem geri alınamaz.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Vazgeç'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sıfırla'),
                      ),
                    ],
                  ),
                );
                if (ok == true) await controller.resetAll();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: weddingDate ?? now.add(const Duration(days: 180)),
    );
    if (picked != null) setState(() => weddingDate = picked);
  }
}
