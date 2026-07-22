import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../main.dart';
import '../services/premium_service.dart';
import '../theme/app_colors.dart';

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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _PaywallHero(source: source),
          const SizedBox(height: 16),
          Text(
            'Ucretsiz kalanlar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          for (final text in PremiumCatalog.freeKeeps)
            _Benefit(icon: Icons.check_circle_outline, text: text),
          const SizedBox(height: 14),
          Text(
            'Premium ile acilan deger',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          for (final text in PremiumCatalog.premiumBenefits)
            _Benefit(icon: Icons.auto_awesome, text: text),
          const SizedBox(height: 18),
          for (final product in PremiumProduct.values) ...[
            _PlanCard(
              product: product,
              enabled: !kReleaseMode,
              isActive: controller.settings.isPremium && !kReleaseMode,
              onTap: () async {
                if (kReleaseMode) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Satin alma altyapisi store onayi sonrasi acilacak.',
                      ),
                    ),
                  );
                  return;
                }
                await controller.purchaseMockPremium(product);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          const _TrustStrip(isRelease: kReleaseMode),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: kReleaseMode
                ? null
                : () async {
                    await controller.restorePurchases();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Satin almalar kontrol edildi.'),
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.restore),
            label: const Text('Satin almalari geri yukle'),
          ),
        ]
            .animate(interval: 45.ms)
            .fadeIn(duration: 260.ms)
            .slideY(begin: 0.05, end: 0),
      ),
    );
  }
}

class _PaywallHero extends StatelessWidget {
  const _PaywallHero({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, AppColors.roseDeep],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.workspace_premium, color: AppColors.gold),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hazirlik Takibi Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            PremiumCatalog.heroPromise,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(label: 'Reklamsiz'),
              _HeroChip(label: 'Akilli plan'),
              _HeroChip(label: 'Export'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.product,
    required this.enabled,
    required this.isActive,
    required this.onTap,
  });

  final PremiumProduct product;
  final bool enabled;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final recommended = product.isRecommended;
    final borderColor = recommended ? AppColors.gold : AppColors.line;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: recommended ? 1.5 : 1),
          boxShadow: recommended
              ? const [
                  BoxShadow(
                    color: Color(0x1FD6A84F),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _Badge(
                  label: isActive ? 'Aktif' : product.badge,
                  filled: recommended || isActive,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(product.pitch, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.priceLabel,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    product.cadenceLabel,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onTap,
                icon: Icon(enabled ? Icons.lock_open : Icons.lock_clock),
                label: Text(
                  enabled ? 'Debug satin al' : 'Store onayi sonrasi acilacak',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? AppColors.goldSoft : AppColors.mintSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip({required this.isRelease});

  final bool isRelease;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.verified_user_outlined, color: AppColors.mint),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isRelease
                    ? 'Gercek satin alma, App Store ve Play Store urunleri baglandiktan sonra acilacak.'
                    : 'Debug modda satin alma mock calisir; release modda sahte satis yapilmaz.',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
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
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, color: AppColors.roseDeep, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
