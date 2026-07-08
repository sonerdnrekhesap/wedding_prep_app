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
            'Temel checklist ücretsiz kalır. Premium; detaylı analiz, PDF/Excel, reklamsız kullanım, premium özet kartları, partner senkronizasyonu ve akıllı plan için hazırlanır. Satın alma şu an mock modda çalışır.',
            style: TextStyle(color: Color(0xFF6F6470)),
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
          const _Benefit(icon: Icons.route_outlined, text: 'Akıllı plan'),
          const _Benefit(
            icon: Icons.palette_outlined,
            text: 'Premium temalar için hazırlık',
          ),
          const SizedBox(height: 18),
          for (final product in PremiumProduct.values) ...[
            Card(
              child: ListTile(
                title: Text(product.label),
                subtitle: Text(product.id),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await controller.purchaseMockPremium(product);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
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
