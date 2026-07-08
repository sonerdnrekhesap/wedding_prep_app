import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    required this.names,
    required this.message,
    required this.score,
  });

  final String names;
  final String message;
  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        borderRadius: AppRadius.card,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
        boxShadow: AppShadows.soft,
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.all(AppRadius.md),
                ),
                child: const Icon(Icons.favorite, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  names.isEmpty ? 'Hazırlık Takibi' : names,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ).animate().fadeIn(duration: 350.ms).scale(
                begin: const Offset(0.96, 0.96),
                end: const Offset(1, 1),
                duration: 350.ms,
              ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedProgressBar(
            value: score,
            color: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.24),
          ),
        ],
      ),
    );
  }
}

class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.trailing,
    this.icon = Icons.trending_up,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String? trailing;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return _CardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBubble(icon: icon),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                trailing ?? '%$percent',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedProgressBar(value: progress),
        ],
      ),
    );
  }
}

class BudgetSummaryCard extends StatelessWidget {
  const BudgetSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.tint = AppColors.rose,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBubble(icon: icon, tint: tint),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class CategoryProgressCard extends StatelessWidget {
  const CategoryProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final double progress;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ProgressSummaryCard(
      title: title,
      subtitle: subtitle,
      progress: progress,
      icon: icon,
      onTap: onTap,
    );
  }
}

class PriorityActionCard extends StatelessWidget {
  const PriorityActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      onTap: onTap,
      child: Row(
        children: [
          _IconBubble(icon: icon, tint: AppColors.gold),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}

class PremiumLockedCard extends StatelessWidget {
  const PremiumLockedCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        borderRadius: AppRadius.card,
        gradient: LinearGradient(colors: AppColors.premiumGradient),
        boxShadow: AppShadows.premium,
      ),
      child: Row(
        children: [
          const _IconBubble(icon: Icons.lock_outline, tint: AppColors.gold),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onTap,
            child: const Text('Aç'),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 1800.ms,
          color: Colors.white.withValues(alpha: 0.35),
        );
  }
}

class WrappedStoryCard extends StatelessWidget {
  const WrappedStoryCard({
    super.key,
    required this.index,
    required this.total,
    required this.title,
    required this.value,
    required this.icon,
    required this.locked,
  });

  final int index;
  final int total;
  final String title;
  final String value;
  final IconData icon;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: locked
              ? AppColors.premiumGradient
              : const [AppColors.rose, AppColors.mint],
        ),
        boxShadow: locked ? AppShadows.premium : AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBubble(
                icon: locked ? Icons.lock_outline : icon,
                tint: locked ? AppColors.gold : Colors.white,
                filled: !locked,
              ),
              const Spacer(),
              Text(
                '${index + 1}/$total',
                style: TextStyle(
                  color: locked ? AppColors.ink : Colors.white70,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: locked ? AppColors.ink : Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: locked ? AppColors.muted : Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconBubble(icon: icon, tint: AppColors.mint),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class SafeLottiePlaceholder extends StatelessWidget {
  const SafeLottiePlaceholder({
    super.key,
    this.assetPath,
    required this.icon,
    this.size = 120,
  });

  final String? assetPath;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = assetPath;
    if (asset != null && asset.isNotEmpty) {
      return Lottie.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.blush,
        borderRadius: AppRadius.card,
      ),
      child: Icon(icon, color: AppColors.rose, size: size * 0.42),
    );
  }
}

class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.rose,
    this.backgroundColor = AppColors.blush,
  });

  final double value;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: 550.ms,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: const BorderRadius.all(AppRadius.pill),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: 9,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      },
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    this.tint = AppColors.rose,
    this.filled = false,
  });

  final IconData icon;
  final Color tint;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: filled
            ? Colors.white.withValues(alpha: 0.2)
            : tint.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.all(AppRadius.md),
      ),
      child: Icon(icon, color: tint, size: 22),
    );
  }
}
