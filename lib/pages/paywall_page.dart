import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../services/premium_service.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key, this.source = 'premium'});

  final String source;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hazırlığı daha sakin yönet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Temel checklist, öncelik listesi, davetli takibi ve hazırlık kartı paylaşımı ücretsiz kalır. Premium özellikler yakında gerçek mağaza satın almasıyla açılacaktır; şimdilik kullanıcıdan ödeme alınmaz.',
            style: TextStyle(color: Color(0xFF6F6470)),
          ),
          const SizedBox(height: 18),
          const _FeatureGroup(
            title: 'Ücretsiz kalanlar',
            items: [
              'Checklist ve öncelik takibi',
              'Bütçe özeti',
              'Davetli listesi',
              'Temel hazırlık özeti paylaşımı',
            ],
          ),
          const SizedBox(height: 12),
          const _FeatureGroup(
            title: 'Pro pakette planlananlar',
            items: [
              'Reklamsız kullanım',
              'PDF/Excel çıktı',
              'Detaylı harcama raporu',
              'Görsel hazırlık özeti',
              'Hediye listesi premium temaları',
              'Sınırsız fiş/garanti fotoğrafı',
              'Watermark kaldırma',
            ],
          ),
          const SizedBox(height: 18),
          const _Benefit(icon: Icons.block, text: 'Reklamsız kullanım'),
          const _Benefit(icon: Icons.insights, text: 'Detaylı raporlar'),
          const _Benefit(
            icon: Icons.ios_share,
            text: 'PDF/Excel dışa aktarma altyapısı',
          ),
          const _Benefit(
            icon: Icons.auto_awesome,
            text: 'Premium özet kartları',
          ),
          const _Benefit(
            icon: Icons.sync_alt,
            text: 'Partner senkronizasyonu altyapısı',
          ),
          const _Benefit(
              icon: Icons.receipt_long_outlined,
              text: 'Fatura / garanti arşivi'),
          const _Benefit(
            icon: Icons.palette_outlined,
            text: 'Premium temalar ve watermark kaldırma',
          ),
          const _Benefit(
            icon: Icons.photo_library_outlined,
            text: 'Sınırsız fotoğraf arşivi hazırlığı',
          ),
          const SizedBox(height: 18),
          if (kDebugMode)
            for (final product in PremiumProduct.values) ...[
              Card(
                child: ListTile(
                  title: Text('${product.label} (demo)'),
                  subtitle: const Text('Sadece debug/demo modunda açılır.'),
                  trailing: const Icon(Icons.science_outlined),
                  onTap: () async {
                    await controller.purchaseMockPremium(product);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
            ]
          else
            const Card(
              child: ListTile(
                leading: Icon(Icons.schedule_outlined),
                title: Text('Premium yakında'),
                subtitle: Text(
                  'Gerçek satın alma bağlanmadan abonelik veya ödeme butonu gösterilmez.',
                ),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await controller.restorePurchases();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Satın almalar kontrol edildi.')),
                );
              }
            },
            icon: const Icon(Icons.restore),
            label: const Text('Satın almaları geri yükle'),
          ),
        ],
      ),
    );
  }
}

class _FeatureGroup extends StatelessWidget {
  const _FeatureGroup({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 17),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE84A7A)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
