import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';
import '../services/export_service.dart';
import '../services/formatters.dart';
import '../services/notification_service.dart';
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
          Card(
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
                      onPressed: () async {
                        final weddingDate = _readDate();
                        if (weddingDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Düğün tarihini gün, ay, yıl olarak yaz.',
                              ),
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
                      },
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Premium mock modu'),
              subtitle: Text(
                controller.settings.isPremium
                    ? 'Premium açık: reklam ve paywall kısıtları kapalı.'
                    : 'Premium kapalı: gelişmiş özelliklerde paywall gösterilir.',
              ),
              value: controller.settings.isPremium,
              onChanged: (value) async {
                if (value) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PaywallPage(source: 'settings'),
                    ),
                  );
                } else {
                  await controller.saveSettings(
                    controller.settings.copyWith(isPremium: false),
                  );
                }
              },
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text('Bildirimler'),
              subtitle: Text(
                const NotificationService()
                    .previewMessages(controller.settings, controller.items)
                    .join(' '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              value: controller.settings.notificationsEnabled,
              onChanged: (value) async {
                await const NotificationService().configure(enabled: value);
                await controller.saveSettings(
                  controller.settings.copyWith(notificationsEnabled: value),
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
              subtitle: Text('Veriler cihazda saklanır.'),
              isThreeLine: false,
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
