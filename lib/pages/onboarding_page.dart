import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../main.dart';
import '../models/app_settings_model.dart';
import '../services/formatters.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/visual_cards.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final pageController = PageController();
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final budgetController = TextEditingController();
  final brideNameController = TextEditingController();
  final groomNameController = TextEditingController();
  int page = 0;

  @override
  void dispose() {
    pageController.dispose();
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
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (value) => setState(() => page = value),
                children: [
                  const _IntroPage(
                    icon: Icons.event_available_outlined,
                    title: 'Düğüne kalan günü takip et',
                    message:
                        'Tarih yaklaştıkça ne durumda olduğunu tek bakışta gör.',
                  ),
                  const _IntroPage(
                    icon: Icons.checklist_rtl,
                    title: 'Çeyiz ve düğün eksiklerini tamamla',
                    message:
                        'Çeyiz, bohça, söz, nişan, kına, düğün ve balayı listeleri düzenli kalsın.',
                  ),
                  _SetupPage(
                    dayController: dayController,
                    monthController: monthController,
                    yearController: yearController,
                    budgetController: budgetController,
                    brideNameController: brideNameController,
                    groomNameController: groomNameController,
                    onSave: _save,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i += 1)
                    AnimatedContainer(
                      duration: 250.ms,
                      width: page == i ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: page == i ? AppColors.rose : AppColors.blush,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  const Spacer(),
                  if (page < 2)
                    FilledButton(
                      onPressed: () => pageController.nextPage(
                        duration: 320.ms,
                        curve: Curves.easeOutCubic,
                      ),
                      child: const Text('Devam'),
                    ),
                ],
              ),
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
          content: Text('Düğün tarihini gün, ay, yıl olarak yaz.'),
        ),
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

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SafeLottiePlaceholder(icon: icon),
          const SizedBox(height: AppSpacing.xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.05, end: 0),
    );
  }
}

class _SetupPage extends StatelessWidget {
  const _SetupPage({
    required this.dayController,
    required this.monthController,
    required this.yearController,
    required this.budgetController,
    required this.brideNameController,
    required this.groomNameController,
    required this.onSave,
  });

  final TextEditingController dayController;
  final TextEditingController monthController;
  final TextEditingController yearController;
  final TextEditingController budgetController;
  final TextEditingController brideNameController;
  final TextEditingController groomNameController;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SafeLottiePlaceholder(icon: Icons.favorite_border, size: 96),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Bilgileri yaz, hazırlığa başlayalım',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: dayController,
                keyboardType: TextInputType.number,
                maxLength: 2,
                decoration:
                    const InputDecoration(labelText: 'Gün', counterText: ''),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: monthController,
                keyboardType: TextInputType.number,
                maxLength: 2,
                decoration:
                    const InputDecoration(labelText: 'Ay', counterText: ''),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration:
                    const InputDecoration(labelText: 'Yıl', counterText: ''),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Toplam hedef bütçe',
            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: brideNameController,
          decoration: const InputDecoration(
            labelText: 'Gelin adı',
            prefixIcon: Icon(Icons.favorite_border),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: groomNameController,
          decoration: const InputDecoration(
            labelText: 'Damat adı',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          onPressed: onSave,
          icon: const Icon(Icons.check),
          label: const Text('Kaydet ve başla'),
        ),
      ].animate(interval: 55.ms).fadeIn(duration: 320.ms).slideY(begin: 0.06),
    );
  }
}
