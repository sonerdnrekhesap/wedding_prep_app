import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';

class AppLaunchSplash extends StatelessWidget {
  const AppLaunchSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.roseDeep,
              AppColors.rose,
              AppColors.gold,
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              left: -54,
              top: 80,
              child: _GlowCircle(size: 160, opacity: 0.16),
            ),
            const Positioned(
              right: -42,
              bottom: 120,
              child: _GlowCircle(size: 190, opacity: 0.14),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _BrandMark().animate().fadeIn(duration: 360.ms).scale(
                        begin: const Offset(0.88, 0.88),
                        end: const Offset(1, 1),
                        duration: 520.ms,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 22),
                  Text(
                    'Hazırlık Takibi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                  )
                      .animate()
                      .fadeIn(duration: 420.ms)
                      .slideY(begin: 0.18, end: 0),
                  const SizedBox(height: 8),
                  const Text(
                    'Düğün, bütçe ve davetliler tek sakin planda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 140.ms, duration: 420.ms)
                      .slideY(begin: 0.18, end: 0),
                  const SizedBox(height: 28),
                  const _LoadingBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 16,
            child: Icon(Icons.favorite, color: AppColors.roseDeep, size: 26),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 22,
            child: Column(
              children: [
                _CheckLine(width: 30),
                SizedBox(height: 7),
                _CheckLine(width: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: AppColors.mint, size: 13),
        const SizedBox(width: 5),
        Container(
          width: width,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.goldSoft,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(999),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: 0.72,
          child: Container(color: Colors.white),
        ).animate().slideX(begin: -1.1, end: 0, duration: 650.ms),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
