import '../models/app_settings_model.dart';
import '../models/guest_model.dart';
import '../models/item_model.dart';
import 'formatters.dart';

enum WeeklyPlanActionType {
  completeItem,
  reviewBudget,
  addGuests,
  confirmGuests,
  updateWeddingDate,
  reviewPhotos,
}

class WeeklyPlanAction {
  const WeeklyPlanAction({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.urgency,
    this.item,
  });

  final WeeklyPlanActionType type;
  final String title;
  final String subtitle;
  final int urgency;
  final PrepItem? item;
}

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

enum BudgetAdviceLevel {
  calm,
  setup,
  watch,
  danger,
}

class BudgetAdvice {
  const BudgetAdvice({
    required this.level,
    required this.title,
    required this.message,
    required this.actionLabel,
  });

  final BudgetAdviceLevel level;
  final String title;
  final String message;
  final String actionLabel;
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
    return (totalSpent(items) / settings.targetBudget).clamp(0, 1);
  }

  BudgetAdvice budgetAdvice(AppSettings settings, List<PrepItem> items) {
    final spent = totalSpent(items);
    final remaining = remainingBudget(settings, items);
    final highMissing = missingHighEstimateItems(items, limit: 1)
        .where((item) => item.estimatedPrice > 0)
        .toList(growable: false);

    if (settings.targetBudget <= 0) {
      return const BudgetAdvice(
        level: BudgetAdviceLevel.setup,
        title: 'Hedef bütçe eksik',
        message:
            'Bütçe riskini takip etmek için önce toplam üst limitini ekle.',
        actionLabel: 'Hedef bütçe ekle',
      );
    }

    if (remaining < 0) {
      return BudgetAdvice(
        level: BudgetAdviceLevel.danger,
        title: 'Bütçe aşıldı',
        message:
            '${money(spent)} harcandı. En pahalı kalemleri ve lüks öncelikleri kontrol et.',
        actionLabel: 'Aşımı azalt',
      );
    }

    final usage = budgetUsagePercent(settings, items);
    if (usage >= 0.85) {
      return BudgetAdvice(
        level: BudgetAdviceLevel.watch,
        title: 'Bütçe sınırına yaklaştın',
        message:
            '${money(remaining)} kaldı. Yeni alışverişten önce eksik tahminleri gözden geçir.',
        actionLabel: 'Riskli kalemlere bak',
      );
    }

    if (highMissing.isNotEmpty &&
        highMissing.first.estimatedPrice > remaining) {
      return BudgetAdvice(
        level: BudgetAdviceLevel.watch,
        title: 'Sıradaki büyük kalem bütçeyi zorlayabilir',
        message:
            '${highMissing.first.title} için ${money(highMissing.first.estimatedPrice)} tahmin var; kalan bütçe ${money(remaining)}.',
        actionLabel: 'Önceliği yeniden sırala',
      );
    }

    return BudgetAdvice(
      level: BudgetAdviceLevel.calm,
      title: 'Bütçe dengede',
      message:
          '${money(remaining)} alan kaldı. Büyük alımları yine de sırayla kapat.',
      actionLabel: 'Planı koru',
    );
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
    if (score < 25) return 'Panik yok, birlikte toparliyoruz';
    if (score < 50) return 'Plan netlesiyor, sirayla gidelim';
    if (score < 75) return 'Iyi gidiyorsun, kritiklere odaklanalim';
    if (score < 90) return 'Neredeyse hazir, eksikleri kapatiyoruz';
    return 'Harika, hazirlik buyuk olcude tamam';
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

  List<WeeklyPlanAction> weeklyPlanActions(
    AppSettings settings,
    List<PrepItem> items,
    List<Guest> guests, {
    int limit = 6,
  }) {
    final days = daysUntilWedding(settings);
    final actions = <WeeklyPlanAction>[];
    final missingCritical = missingMustHaveItems(items);
    final missingHighEstimate = missingHighEstimateItems(items, limit: 2);
    final dueSoon = dueSoonItems(items, limit: 3);
    final guestSummary = guestStats(guests);
    final budgetUsage = budgetUsagePercent(settings, items);
    final spent = totalSpent(items);
    final remaining = remainingBudget(settings, items);

    if (days == null) {
      actions.add(const WeeklyPlanAction(
        type: WeeklyPlanActionType.updateWeddingDate,
        title: 'Dugun tarihini netlestir',
        subtitle: 'Tarihe gore haftalik plan ve oncelikler daha akilli olur.',
        urgency: 100,
      ));
    } else if (days <= 30 && missingCritical.isNotEmpty) {
      actions.add(WeeklyPlanAction(
        type: WeeklyPlanActionType.completeItem,
        title: 'Son 30 gun kritiklerini kapat',
        subtitle: '${missingCritical.length} olmazsa olmaz kalem bekliyor.',
        urgency: 96,
        item: missingCritical.first,
      ));
    }

    for (final item in dueSoon) {
      actions.add(WeeklyPlanAction(
        type: WeeklyPlanActionType.completeItem,
        title: item.title,
        subtitle: _dueDateSubtitle(item.purchaseDate),
        urgency: _isOverdue(item.purchaseDate) ? 94 : 84,
        item: item,
      ));
    }

    for (final item in missingCritical.take(3)) {
      actions.add(WeeklyPlanAction(
        type: WeeklyPlanActionType.completeItem,
        title: item.title,
        subtitle: '${item.mainCategory.label} / ${item.subCategory}',
        urgency: 90 - item.priority.sortOrder,
        item: item,
      ));
    }

    for (final item in missingHighEstimate) {
      if (missingCritical.any((critical) => critical.id == item.id)) continue;
      actions.add(WeeklyPlanAction(
        type: WeeklyPlanActionType.completeItem,
        title: item.title,
        subtitle: 'Fiyat yuksek olabilir: ${item.subCategory}',
        urgency: 72,
        item: item,
      ));
    }

    if (settings.targetBudget <= 0) {
      actions.add(const WeeklyPlanAction(
        type: WeeklyPlanActionType.reviewBudget,
        title: 'Hedef butce ekle',
        subtitle: 'Harcamalari anlamli takip etmek icin bir ust limit belirle.',
        urgency: 74,
      ));
    } else if (budgetUsage >= 0.85 || remaining < 0) {
      actions.add(WeeklyPlanAction(
        type: WeeklyPlanActionType.reviewBudget,
        title: remaining < 0
            ? 'Butce asimini kontrol et'
            : 'Butce sinirina yaklastin',
        subtitle: 'Su ana kadar ${money(spent)} harcandi.',
        urgency: 82,
      ));
    }

    if (guests.isEmpty) {
      actions.add(const WeeklyPlanAction(
        type: WeeklyPlanActionType.addGuests,
        title: 'Ilk davetli listesini olustur',
        subtitle: 'Kisi sayisi butce ve masa planini dogrudan etkiler.',
        urgency: 70,
      ));
    } else if (guestSummary.unsurePeople > 0) {
      actions.add(WeeklyPlanAction(
        type: WeeklyPlanActionType.confirmGuests,
        title: 'Belirsiz davetlileri netlestir',
        subtitle: '${guestSummary.unsurePeople} kisi icin cevap bekleniyor.',
        urgency: days != null && days < 45 ? 86 : 64,
      ));
    }

    actions.sort((a, b) => b.urgency.compareTo(a.urgency));

    final seen = <String>{};
    return [
      for (final action in actions)
        if (seen.add('${action.type.name}:${action.item?.id ?? action.title}'))
          action,
    ].take(limit).toList();
  }

  MainCategory? topSpentCategory(List<PrepItem> items) {
    final stats = categoryStats(items);
    final entries = stats.entries.toList()
      ..sort((a, b) => b.value.spent.compareTo(a.value.spent));
    return entries.isEmpty || entries.first.value.spent == 0
        ? null
        : entries.first.key;
  }

  List<PrepItem> dueSoonItems(List<PrepItem> items, {int limit = 5}) {
    final today = _dateOnly(DateTime.now());
    final nextWeek = today.add(const Duration(days: 7));
    final sorted = [
      ...items.where((item) {
        final due = item.purchaseDate;
        if (item.isCompleted || due == null) return false;
        final date = _dateOnly(due);
        return !date.isAfter(nextWeek);
      }),
    ]..sort((a, b) => a.purchaseDate!.compareTo(b.purchaseDate!));
    return sorted.take(limit).toList();
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

  bool _isOverdue(DateTime? date) {
    if (date == null) return false;
    return _dateOnly(date).isBefore(_dateOnly(DateTime.now()));
  }

  String _dueDateSubtitle(DateTime? date) {
    if (date == null) return 'Hedef alış tarihi yaklaşıyor.';
    if (_isOverdue(date)) return 'Hedef tarih geçti; bu kalemi öne al.';
    return 'Hedef alış tarihi: ${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
