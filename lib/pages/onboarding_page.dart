import 'package:flutter/material.dart';

import '../main.dart';
import '../models/app_settings_model.dart';
import '../services/formatters.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  DateTime? weddingDate;
  final budgetController = TextEditingController();
  final namesController = TextEditingController();
  PreparationType type = PreparationType.full;

  @override
  void dispose() {
    budgetController.dispose();
    namesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 20),
            Text(
              'Hazırlıklarını sakin ve net takip et',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Düğün tarihi, bütçe ve hazırlık kapsamını seçerek başlayalım.',
              style: TextStyle(color: Color(0xFF6F6470)),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event_outlined),
              label: Text(
                weddingDate == null
                    ? 'Düğün tarihi seç'
                    : '${weddingDate!.day}.${weddingDate!.month}.${weddingDate!.year}',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Toplam hedef bütçe',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: namesController,
              decoration: const InputDecoration(
                labelText: 'Çift isimleri (isteğe bağlı)',
                prefixIcon: Icon(Icons.favorite_border),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Hazırlık tipi',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<PreparationType>(
              segments: [
                for (final option in PreparationType.values)
                  ButtonSegment(value: option, label: Text(option.label)),
              ],
              selected: {type},
              onSelectionChanged: (selected) {
                setState(() => type = selected.first);
              },
              showSelectedIcon: false,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Kaydet ve başla'),
            ),
          ],
        ),
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

  Future<void> _save() async {
    final controller = AppScope.of(context);
    await controller.saveSettings(AppSettings(
      weddingDate: weddingDate,
      targetBudget: parseMoney(budgetController.text),
      coupleNames: namesController.text.trim(),
      preparationType: type,
      hasCompletedOnboarding: true,
    ));
  }
}
