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
            'HazÃ„Â±rlÃ„Â±Ã„Å¸Ã„Â± daha sakin yÃƒÂ¶net',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Temel checklist, ÃƒÂ¶ncelik listesi, davetli takibi ve hazÃ„Â±rlÃ„Â±k kartÃ„Â± paylaÃ…Å¸Ã„Â±mÃ„Â± ÃƒÂ¼cretsiz kalÃ„Â±r. Premium; PDF/Excel, detaylÃ„Â± harcama analizi, fatura/garanti fotoÃ„Å¸raf arÃ…Å¸ivi, sÃ„Â±nÃ„Â±rsÃ„Â±z fotoÃ„Å¸raf, partnerle ortak liste, reklamsÃ„Â±z kullanÃ„Â±m, premium temalar ve watermark kaldÃ„Â±rma iÃƒÂ§in hazÃ„Â±rlanÃ„Â±r.',
            style: TextStyle(color: Color(0xFF6F6470)),
          ),
          const SizedBox(height: 18),
          const _Benefit(icon: Icons.block, text: 'ReklamsÃ„Â±z kullanÃ„Â±m'),
          const _Benefit(icon: Icons.insights, text: 'DetaylÃ„Â± raporlar'),
          const _Benefit(
            icon: Icons.ios_share,
            text: 'PDF/Excel dÃ„Â±Ã…Å¸a aktarma altyapÃ„Â±sÃ„Â±',
          ),
          const _Benefit(
            icon: Icons.auto_awesome,
            text: 'Premium ÃƒÂ¶zet kartlarÃ„Â±',
          ),
          const _Benefit(
            icon: Icons.sync_alt,
            text: 'Partner senkronizasyonu altyapÃ„Â±sÃ„Â±',
          ),
          const _Benefit(
              icon: Icons.receipt_long_outlined,
              text: 'Fatura / garanti arÃ…Å¸ivi'),
          const _Benefit(
            icon: Icons.palette_outlined,
            text: 'Premium temalar ve watermark kaldÃ„Â±rma',
          ),
          const _Benefit(
            icon: Icons.photo_library_outlined,
            text:
                'SÃ„Â±nÃ„Â±rsÃ„Â±z fotoÃ„Å¸raf arÃ…Å¸ivi hazÃ„Â±rlÃ„Â±Ã„Å¸Ã„Â±',
          ),
          const SizedBox(height: 18),
          if (kReleaseMode) ...[
            const Card(
              child: ListTile(
                leading: Icon(Icons.lock_clock_outlined),
                title: Text('Premium yakinda'),
                subtitle: Text(
                  'Gercek satin alma baglanana kadar premium satisi kapali tutulur.',
                ),
              ),
            ),
          ] else ...[
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
          ],
          if (!kReleaseMode)
            OutlinedButton.icon(
              onPressed: () async {
                await controller.restorePurchases();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Satin almalar kontrol edildi.')),
                  );
                }
              },
              icon: const Icon(Icons.restore),
              label: const Text('Satin almalari geri yukle'),
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
