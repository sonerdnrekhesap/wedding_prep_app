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
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final budgetController = TextEditingController();
  final brideNameController = TextEditingController();
  final groomNameController = TextEditingController();

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    budgetController.dispose();
    brideNameController.dispose();
    groomNameController.dispose();
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
              'Düğün tarihi, bütçe ve çift isimlerini yazarak başlayalım.',
              style: TextStyle(color: Color(0xFF6F6470)),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dayController,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    decoration: const InputDecoration(
                      labelText: 'Gün',
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: monthController,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    decoration: const InputDecoration(
                      labelText: 'Ay',
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'Yıl',
                      counterText: '',
                    ),
                  ),
                ),
              ],
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
              controller: brideNameController,
              decoration: const InputDecoration(
                labelText: 'Gelin adı',
                prefixIcon: Icon(Icons.favorite_border),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: groomNameController,
              decoration: const InputDecoration(
                labelText: 'Damat adı',
                prefixIcon: Icon(Icons.person_outline),
              ),
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

  Future<void> _save() async {
    final weddingDate = _readDate();
    if (weddingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Düğün tarihini gün, ay, yıl olarak yaz.')),
      );
      return;
    }

    final controller = AppScope.of(context);
    await controller.saveSettings(AppSettings(
      weddingDate: weddingDate,
      targetBudget: parseMoney(budgetController.text),
      brideName: brideNameController.text.trim(),
      groomName: groomNameController.text.trim(),
      hasCompletedOnboarding: true,
    ));
  }

  DateTime? _readDate() {
    final day = int.tryParse(dayController.text.trim());
    final month = int.tryParse(monthController.text.trim());
    final year = int.tryParse(yearController.text.trim());
    if (day == null || month == null || year == null) return null;

    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month || date.year != year) {
      return null;
    }
    return date;
  }
}
