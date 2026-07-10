import 'package:flutter/material.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/calculation_service.dart';
import '../services/formatters.dart';
import '../theme/app_colors.dart';
import '../widgets/priority_badge.dart';
import '../widgets/visual_cards.dart';
import 'item_list_page.dart';

class WeeklyPlanPage extends StatelessWidget {
  const WeeklyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final calc = CalculationService();
    final dueSoon = calc.dueSoonItems(controller.items, withinDays: 7);
    final payments = calc.upcomingPayments(controller.items, withinDays: 30);
    final next = calc.nextActionItems(controller.items, limit: 5);
    final milestones =
        calc.milestones(controller.settings, controller.items, controller.guests);

    return Scaffold(
      appBar: AppBar(title: const Text('Haftalık Plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PlanHero(
            taskCount: dueSoon.length,
            paymentCount: payments.length,
            score: calc.weightedPreparationScore(controller.items).round(),
          ),
          const SizedBox(height: 14),
          _PlanSection(
            title: 'Bu hafta tamamlanmalı',
            emptyTitle: 'Bu hafta için tarihli görev yok',
            emptyMessage:
                'Yine de önerilen adımlardan birini seçip ilerleyebilirsin.',
            children: [
              for (final item in dueSoon.take(6))
                _PlanItemTile(item: item, showDate: true),
            ],
          ),
          const SizedBox(height: 14),
          _PlanSection(
            title: 'Yaklaşan ödemeler',
            emptyTitle: 'Yaklaşan ödeme görünmüyor',
            emptyMessage:
                'Kapora ve son ödeme tarihlerini ürün detayından ekleyebilirsin.',
            children: [
              for (final item in payments.take(6))
                _PaymentTile(item: item, remaining: calc.remainingPaymentFor(item)),
            ],
          ),
          const SizedBox(height: 14),
          _PlanSection(
            title: 'Sıradaki öneriler',
            emptyTitle: 'Önerilecek eksik kalmadı',
            emptyMessage: 'Listeler iyi görünüyor. Özet ekranına bakabilirsin.',
            children: [
              for (final item in next) _PlanItemTile(item: item),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kilometre taşları',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  if (milestones.isEmpty)
                    const Text(
                      'İlk 10 görev, ilk bütçe kaydı ve kategori tamamlama gibi ilerlemeler burada görünür.',
                      style: TextStyle(color: AppColors.muted),
                    )
                  else
                    for (final milestone in milestones)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.emoji_events_outlined,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(milestone)),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanHero extends StatelessWidget {
  const _PlanHero({
    required this.taskCount,
    required this.paymentCount,
    required this.score,
  });

  final int taskCount;
  final int paymentCount;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cream,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.mintSoft,
              child: Icon(Icons.calendar_month_outlined, color: AppColors.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bu haftanın ritmi',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$taskCount görev, $paymentCount ödeme takibi. Hazırlık skoru: %$score',
                    style: const TextStyle(color: AppColors.muted),
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

class _PlanSection extends StatelessWidget {
  const _PlanSection({
    required this.title,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.children,
  });

  final String title;
  final String emptyTitle;
  final String emptyMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            if (children.isEmpty)
              EmptyStateCard(
                icon: Icons.check_circle_outline,
                title: emptyTitle,
                message: emptyMessage,
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }
}

class _PlanItemTile extends StatelessWidget {
  const _PlanItemTile({required this.item, this.showDate = false});

  final PrepItem item;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.radio_button_unchecked, color: AppColors.rose),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          PriorityBadge(priority: item.priority),
          Text(item.mainCategory.label),
          if (showDate && item.dueDate != null)
            Text('${item.dueDate!.day}.${item.dueDate!.month}'),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ItemListPage(category: item.mainCategory),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.item, required this.remaining});

  final PrepItem item;
  final double remaining;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.payments_outlined, color: AppColors.coral),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        item.vendorName.isEmpty ? item.subCategory : item.vendorName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        money(remaining),
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ItemListPage(category: item.mainCategory),
        ),
      ),
    );
  }
}
