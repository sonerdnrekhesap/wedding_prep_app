import '../models/app_settings_model.dart';
import '../models/guest_model.dart';
import '../models/item_model.dart';

class CategoryStats {
  const CategoryStats({
    required this.total,
    required this.completed,
    required this.spent,
    required this.estimatedRemaining,
    required this.score,
  });

  final int total;
  final int completed;
  final double spent;
  final double estimatedRemaining;
  final double score;

  int get missing => total - completed;
  double get progress => total == 0 ? 0 : completed / total;
}

class GuestStats {
  const GuestStats({
    required this.totalPeople,
    required this.comingPeople,
    required this.notComingPeople,
    required this.unsurePeople,
    required this.bridePeople,
    required this.groomPeople,
  });

  final int totalPeople;
  final int comingPeople;
  final int notComingPeople;
  final int unsurePeople;
  final int bridePeople;
  final int groomPeople;
}

class CalculationService {
  int? daysUntilWedding(AppSettings settings) {
    final date = settings.weddingDate;
    if (date == null) return null;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(start).inDays;
  }

  int completedItems(List<PrepItem> items) =>
      items.where((item) => item.isCompleted).length;

  int missingItems(List<PrepItem> items) =>
      items.length - completedItems(items);

  double totalSpent(List<PrepItem> items) =>
      items.fold(0, (sum, item) => sum + item.actualPrice);

  double totalEstimated(List<PrepItem> items) =>
      items.fold(0, (sum, item) => sum + item.estimatedPrice);

  double remainingBudget(AppSettings settings, List<PrepItem> items) =>
      settings.targetBudget - totalSpent(items);

  double budgetUsagePercent(AppSettings settings, List<PrepItem> items) {
    if (settings.targetBudget <= 0) return 0;
    return (totalSpent(items) / settings.targetBudget).clamp(0, 1).toDouble();
  }

  double weightedPreparationScore(List<PrepItem> items) {
    final total = items.fold<double>(
      0,
      (sum, item) => sum + item.priority.weight,
    );
    if (total == 0) return 0;
    final completed = items.where((item) => item.isCompleted).fold<double>(
          0,
          (sum, item) => sum + item.priority.weight,
        );
    return completed / total * 100;
  }

  String scoreMessage(double score) {
    if (score < 25) return 'Başlangıç aşamasındasın, sırayla ilerleyelim';
    if (score < 50) return 'Plan netleşiyor, sırayla gidelim';
    if (score < 75) return 'İyi gidiyorsun, kritiklere odaklanalım';
    if (score < 90) return 'Neredeyse hazır, eksikleri kapatıyoruz';
    return 'Harika, hazırlık büyük ölçüde tamam';
  }

  Map<MainCategory, CategoryStats> categoryStats(List<PrepItem> items) {
    return {
      for (final category in MainCategory.values)
        category: _statsFor(items
            .where((item) => item.mainCategory == category)
            .toList(growable: false)),
    };
  }

  CategoryStats _statsFor(List<PrepItem> items) {
    final score = weightedPreparationScore(items);
    final spent = totalSpent(items);
    final estimatedRemaining = items
        .where((item) => !item.isCompleted)
        .fold<double>(0, (sum, item) => sum + item.estimatedPrice);
    return CategoryStats(
      total: items.length,
      completed: completedItems(items),
      spent: spent,
      estimatedRemaining: estimatedRemaining,
      score: score,
    );
  }

  List<PrepItem> topExpensiveItems(List<PrepItem> items, {int limit = 5}) {
    final sorted = [...items.where((item) => item.actualPrice > 0)]
      ..sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
    return sorted.take(limit).toList();
  }

  List<PrepItem> missingHighEstimateItems(List<PrepItem> items,
      {int limit = 5}) {
    final sorted = [...items.where((item) => !item.isCompleted)]
      ..sort((a, b) => b.estimatedPrice.compareTo(a.estimatedPrice));
    return sorted.take(limit).toList();
  }

  List<PrepItem> missingMustHaveItems(List<PrepItem> items) => items
      .where(
          (item) => !item.isCompleted && item.priority == ItemPriority.mustHave)
      .toList();

  List<PrepItem> nextActionItems(List<PrepItem> items, {int limit = 4}) {
    final sorted = [...items.where((item) => !item.isCompleted)]..sort((a, b) {
        final priority = a.priority.sortOrder.compareTo(b.priority.sortOrder);
        if (priority != 0) return priority;
        return b.estimatedPrice.compareTo(a.estimatedPrice);
      });
    return sorted.take(limit).toList();
  }

  List<PrepItem> dueSoonItems(List<PrepItem> items, {int withinDays = 7}) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day)
        .add(Duration(days: withinDays + 1));
    final sorted = [
      ...items.where((item) =>
          !item.isCompleted &&
          item.dueDate != null &&
          item.dueDate!.isBefore(end))
    ]..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return sorted;
  }

  List<PrepItem> upcomingPayments(List<PrepItem> items, {int withinDays = 30}) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day)
        .add(Duration(days: withinDays + 1));
    final sorted = [
      ...items.where((item) =>
          item.paymentDeadline != null &&
          item.paymentDeadline!.isBefore(end) &&
          remainingPaymentFor(item) > 0)
    ]..sort((a, b) => a.paymentDeadline!.compareTo(b.paymentDeadline!));
    return sorted;
  }

  double remainingPaymentFor(PrepItem item) {
    final contract = item.contractTotal > 0 ? item.contractTotal : item.actualPrice;
    if (contract <= 0) return 0;
    final paid = item.totalPaid > 0 ? item.totalPaid : item.depositPaid;
    final remaining = contract - paid;
    return remaining < 0 ? 0 : remaining;
  }

  List<String> milestones(
    AppSettings settings,
    List<PrepItem> items,
    List<Guest> guests,
  ) {
    final completed = completedItems(items);
    final score = weightedPreparationScore(items);
    final guestStatsValue = guestStats(guests);
    final days = daysUntilWedding(settings);
    return [
      if (completed >= 10) 'İlk 10 görev tamamlandı',
      if (score >= 50) 'Hazırlığın yarısı tamamlandı',
      if (totalSpent(items) > 0) 'İlk bütçe kaydı girildi',
      if (guests.isNotEmpty && guestStatsValue.unsurePeople == 0)
        'Davetli listesi netleşti',
      if (days != null && days <= 100) 'Düğüne 100 günden az kaldı',
      if (days != null && days <= 30) 'Son 30 güne girildi',
    ];
  }

  MainCategory? topSpentCategory(List<PrepItem> items) {
    final stats = categoryStats(items);
    final entries = stats.entries.toList()
      ..sort((a, b) => b.value.spent.compareTo(a.value.spent));
    return entries.isEmpty || entries.first.value.spent == 0
        ? null
        : entries.first.key;
  }

  MainCategory? mostMissingCategory(List<PrepItem> items) {
    final stats = categoryStats(items);
    final entries = stats.entries
        .where((entry) => entry.value.total > 0)
        .toList()
      ..sort((a, b) => b.value.missing.compareTo(a.value.missing));
    return entries.isEmpty ? null : entries.first.key;
  }

  GuestStats guestStats(List<Guest> guests) {
    int sum(Iterable<Guest> source) =>
        source.fold(0, (total, guest) => total + guest.personCount);
    return GuestStats(
      totalPeople: sum(guests),
      comingPeople:
          sum(guests.where((guest) => guest.status == GuestStatus.coming)),
      notComingPeople:
          sum(guests.where((guest) => guest.status == GuestStatus.notComing)),
      unsurePeople:
          sum(guests.where((guest) => guest.status == GuestStatus.uncertain)),
      bridePeople: sum(guests.where((guest) => guest.side == GuestSide.bride)),
      groomPeople: sum(guests.where((guest) => guest.side == GuestSide.groom)),
    );
  }
}
