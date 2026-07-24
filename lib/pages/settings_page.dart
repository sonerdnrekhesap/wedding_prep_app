import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/app_settings_model.dart';
import '../models/guest_model.dart';
import '../models/item_model.dart';
import '../services/export_service.dart';
import '../services/formatters.dart';
import '../services/notification_service.dart';
import '../services/share_file_service.dart';
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
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Premium plan'),
              subtitle: Text(
                controller.settings.isPremium
                    ? 'Premium aktif: reklamlar kapalı ve premium kilitler açık.'
                    : 'Reklamsız kullanım, akıllı plan ve premium özetleri incele.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PaywallPage(source: 'settings'),
                ),
              ),
            ),
          ),
          if (!kReleaseMode)
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
              subtitle: const Text(
                'Davetli listesini Excel uyumlu CSV dosyası olarak dışa aktar.',
              ),
              onTap: () => _shareGuestCsv(controller.guests),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: const Text('Hazırlık listesini CSV olarak paylaş'),
              subtitle: const Text(
                'Kategori, öncelik, fiyat, mağaza ve not alanlarıyla dışa aktar.',
              ),
              trailing: controller.settings.isPremium
                  ? null
                  : const Icon(Icons.workspace_premium_outlined),
              onTap: () => _runPremiumOrRewarded(
                source: 'export',
                onUnlocked: () => _shareChecklistCsv(controller.items),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Bütçe özetini CSV olarak paylaş'),
              subtitle: const Text(
                'Kategori bazlı harcama, eksik ve tahmini ihtiyaç özetini çıkar.',
              ),
              trailing: controller.settings.isPremium
                  ? null
                  : const Icon(Icons.workspace_premium_outlined),
              onTap: () => _runPremiumOrRewarded(
                source: 'budget_export',
                onUnlocked: () => _shareBudgetCsv(controller.items),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Hazırlık raporunu paylaş'),
              subtitle: const Text(
                'Skor, bütçe advisor, davetli özeti ve sıradaki öncelikleri tek dosyada çıkar.',
              ),
              trailing: controller.settings.isPremium
                  ? null
                  : const Icon(Icons.workspace_premium_outlined),
              onTap: () => _runPremiumOrRewarded(
                source: 'report',
                onUnlocked: () => _sharePlanningReport(
                  controller.settings,
                  controller.items,
                  controller.guests,
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Örnek planı yükle'),
              subtitle: const Text(
                'Sunum ve hızlı deneme için örnek çift, bütçe ve davetli verisi ekler.',
              ),
              onTap: () async {
                await controller.loadDemoData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Örnek plan yüklendi.')),
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

  Future<void> _shareGuestCsv(List<Guest> guests) async {
    try {
      final csv = ExportService().buildGuestCsv(guests);
      await const ShareFileService().shareTextFile(
        fileName: 'davetli-listesi.csv',
        content: csv,
        subject: 'Davetli listesi',
        mimeType: 'text/csv',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Davetli listesi paylaşılamadı.')),
      );
    }
  }

  Future<void> _runPremiumOrRewarded({
    required String source,
    required Future<void> Function() onUnlocked,
  }) async {
    final controller = AppScope.of(context);
    if (controller.settings.isPremium) {
      await onUnlocked();
      return;
    }

    final choice = await showModalBottomSheet<_UnlockChoice>(
      context: context,
      builder: (context) => _PremiumOrRewardedSheet(
        canOfferRewarded: controller.ads.canOfferRewardedUnlock,
      ),
    );
    if (!mounted || choice == null) return;

    if (choice == _UnlockChoice.premium) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PaywallPage(source: source)),
      );
      return;
    }

    final rewarded = await controller.ads.showRewardedForFeature();
    if (!mounted) return;
    if (rewarded) {
      await onUnlocked();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reklam hazır değil. Premium ile sınırsız açabilirsin.'),
      ),
    );
  }

  Future<void> _shareChecklistCsv(List<PrepItem> items) async {
    try {
      final csv = ExportService().buildChecklistCsv(items);
      await const ShareFileService().shareTextFile(
        fileName: 'hazirlik-listesi.csv',
        content: csv,
        subject: 'Hazırlık listesi',
        mimeType: 'text/csv',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hazırlık listesi paylaşılamadı.')),
      );
    }
  }

  Future<void> _shareBudgetCsv(List<PrepItem> items) async {
    try {
      final csv = ExportService().buildBudgetCsv(items);
      await const ShareFileService().shareTextFile(
        fileName: 'butce-ozeti.csv',
        content: csv,
        subject: 'Bütçe özeti',
        mimeType: 'text/csv',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bütçe özeti paylaşılamadı.')),
      );
    }
  }

  Future<void> _sharePlanningReport(
    AppSettings settings,
    List<PrepItem> items,
    List<Guest> guests,
  ) async {
    try {
      final report = ExportService().buildPlanningReportText(
        settings,
        items,
        guests,
      );
      await const ShareFileService().shareTextFile(
        fileName: 'hazirlik-raporu.txt',
        content: report,
        subject: 'Hazırlık raporu',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hazırlık raporu paylaşılamadı.')),
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

enum _UnlockChoice { premium, rewarded }

class _PremiumOrRewardedSheet extends StatelessWidget {
  const _PremiumOrRewardedSheet({required this.canOfferRewarded});

  final bool canOfferRewarded;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Premium export',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sınırsız export ve reklamsız kullanım Premium ile açılır. Reklam uygunsa bu dosya için tek seferlik paylaşım da açabilirsin.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context, _UnlockChoice.premium),
                icon: const Icon(Icons.workspace_premium_outlined),
                label: const Text('Premium al'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: canOfferRewarded
                    ? () => Navigator.pop(context, _UnlockChoice.rewarded)
                    : null,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Reklam izle, bir kez paylaş'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
