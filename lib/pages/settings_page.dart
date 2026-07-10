import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';
import '../services/app_controller.dart';
import '../services/export_service.dart';
import '../services/formatters.dart';
import 'paywall_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController dayController;
  late final TextEditingController monthController;
  late final TextEditingController yearController;
  late final TextEditingController budgetController;
  late final TextEditingController brideNameController;
  late final TextEditingController groomNameController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final settings = AppScope.of(context).settings;
    final weddingDate = settings.weddingDate;
    dayController = TextEditingController(
      text: weddingDate == null ? '' : weddingDate.day.toString(),
    );
    monthController = TextEditingController(
      text: weddingDate == null ? '' : weddingDate.month.toString(),
    );
    yearController = TextEditingController(
      text: weddingDate == null ? '' : weddingDate.year.toString(),
    );
    budgetController = TextEditingController(
      text: settings.targetBudget.toStringAsFixed(0),
    );
    brideNameController = TextEditingController(text: settings.brideName);
    groomNameController = TextEditingController(text: settings.groomName);
    _initialized = true;
  }

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
    final controller = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileSettingsCard(
            dayController: dayController,
            monthController: monthController,
            yearController: yearController,
            budgetController: budgetController,
            brideNameController: brideNameController,
            groomNameController: groomNameController,
            onSave: () => _saveProfile(context, controller),
          ),
          _PremiumStatusCard(controller: controller),
          _NotificationSettingsCard(controller: controller),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Kutlama animasyonları'),
              subtitle: const Text(
                'Büyük ilerlemelerde kısa ve sade başarı animasyonları gösterilir.',
              ),
              value: controller.settings.celebrationsEnabled,
              onChanged: (value) async {
                await controller.saveSettings(
                  controller.settings.copyWith(celebrationsEnabled: value),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.ios_share_outlined),
              title: const Text('Davetli listesini CSV olarak paylaş'),
              subtitle:
                  const Text('Premium dışa aktarma altyapısının ilk adımı.'),
              onTap: () async {
                if (!controller.settings.isPremium) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PaywallPage(source: 'export'),
                    ),
                  );
                  return;
                }
                final csv = ExportService().buildGuestCsv(controller.guests);
                await Share.share(csv, subject: 'Davetli listesi');
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Demo verileri yükle'),
              subtitle: const Text(
                'Mağaza öncesi sunum ve test için örnek çift, bütçe ve davetli verisi yükler.',
              ),
              onTap: () async {
                await controller.loadDemoData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo verileri yüklendi.')),
                  );
                }
              },
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.privacy_tip_outlined),
              title: Text('Gizlilik'),
              subtitle: Text(
                'Veriler ve seçtiğin fotoğraflar cihazda saklanır. Bulut yedekleme yoktur. Fotoğraf silersen uygulama içindeki dosya da silinir.',
              ),
              isThreeLine: true,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.star_border_outlined),
              title: const Text('Bizi Değerlendir'),
              subtitle: const Text(
                'Hazırlık sürecinde işine yarıyorsa kısa bir değerlendirme bırakabilirsin.',
              ),
              onTap: () async {
                final review = InAppReview.instance;
                if (await review.isAvailable()) {
                  await review.requestReview();
                } else {
                  await review.openStoreListing();
                }
              },
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Uygulama hakkında'),
              subtitle: Text(
                'Çeyiz, düğün, bütçe ve davetli hazırlıklarını offline takip eder.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined),
              title: const Text('Verileri sıfırla'),
              subtitle:
                  const Text('Tüm liste, davetli ve ayar verileri silinir.'),
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

  Future<void> _saveProfile(
    BuildContext context,
    AppController controller,
  ) async {
    final weddingDate = _readDate();
    if (weddingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Düğün tarihini gün, ay, yıl olarak yaz.'),
        ),
      );
      return;
    }

    await controller.saveSettings(
      controller.settings.copyWith(
        weddingDate: weddingDate,
        targetBudget: parseMoney(budgetController.text),
        brideName: brideNameController.text.trim(),
        groomName: groomNameController.text.trim(),
        hasCompletedOnboarding: true,
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayarlar kaydedildi')),
      );
    }
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

class _ProfileSettingsCard extends StatelessWidget {
  const _ProfileSettingsCard({
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
            const SizedBox(height: 12),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Hedef bütçe'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: brideNameController,
              decoration: const InputDecoration(labelText: 'Gelin adı'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: groomNameController,
              decoration: const InputDecoration(labelText: 'Damat adı'),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSave,
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumStatusCard extends StatelessWidget {
  const _PremiumStatusCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.workspace_premium_outlined),
        title: const Text('Premium durumu'),
        subtitle: Text(
          controller.settings.isPremium
              ? 'Premium aktif: mağaza yetkisi doğrulandı.'
              : 'Premium kapalı: gelişmiş özelliklerde paywall gösterilir.',
        ),
        value: controller.settings.isPremium,
        onChanged: (_) async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PaywallPage(source: 'settings'),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationSettingsCard extends StatelessWidget {
  const _NotificationSettingsCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final settings = controller.settings;
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Bildirimler'),
            subtitle: Text(
              controller.notifications
                  .previewMessages(settings, controller.items)
                  .join(' '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            value: settings.notificationsEnabled,
            onChanged: (value) async {
              await controller.notifications.configure(enabled: value);
              await controller.saveSettings(
                settings.copyWith(notificationsEnabled: value),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Hatırlatma saati'),
            subtitle: Slider(
              min: 8,
              max: 22,
              divisions: 14,
              label: '${settings.reminderHour}:00',
              value: settings.reminderHour.clamp(8, 22).toDouble(),
              onChanged: settings.notificationsEnabled
                  ? (value) async {
                      await controller.saveSettings(
                        settings.copyWith(reminderHour: value.round()),
                      );
                    }
                  : null,
            ),
            trailing: Text('${settings.reminderHour}:00'),
          ),
          SwitchListTile(
            title: const Text('Haftalık hazırlık özeti'),
            value: settings.weeklySummaryEnabled,
            onChanged: settings.notificationsEnabled
                ? (value) async {
                    await controller.saveSettings(
                      settings.copyWith(weeklySummaryEnabled: value),
                    );
                  }
                : null,
          ),
          SwitchListTile(
            title: const Text('Ödeme hatırlatmaları'),
            value: settings.paymentRemindersEnabled,
            onChanged: settings.notificationsEnabled
                ? (value) async {
                    await controller.saveSettings(
                      settings.copyWith(paymentRemindersEnabled: value),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
