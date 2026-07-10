import '../models/item_model.dart';

enum ItemFilter {
  all,
  missing,
  completed,
  purchased,
  notPurchased,
  highPriority,
  dueSoon,
  overBudget,
  hasPhoto,
  hasNote,
  hasPayment,
  mustHave,
  necessary,
  later,
  luxury,
}

enum ItemSort {
  recommended,
  priority,
  dueDate,
  newest,
  oldest,
  estimatedPrice,
  actualPrice,
  alphabetical,
}

class ItemQueryService {
  const ItemQueryService();

  List<PrepItem> query({
    required List<PrepItem> items,
    required MainCategory category,
    String? subCategory,
    ItemFilter filter = ItemFilter.all,
    ItemSort sort = ItemSort.recommended,
    String searchQuery = '',
    DateTime? now,
  }) {
    final filtered = items
        .where((item) => item.mainCategory == category)
        .where((item) => subCategory == null || item.subCategory == subCategory)
        .where((item) => matchesFilter(item, filter, now: now))
        .where((item) => matchesSearch(item, searchQuery))
        .toList();
    return sortItems(filtered, sort);
  }

  bool matchesFilter(
    PrepItem item,
    ItemFilter filter, {
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    return switch (filter) {
      ItemFilter.all => true,
      ItemFilter.missing => !item.isCompleted,
      ItemFilter.completed => item.isCompleted,
      ItemFilter.purchased => item.actualPrice > 0,
      ItemFilter.notPurchased => item.actualPrice <= 0,
      ItemFilter.highPriority =>
        item.priority == ItemPriority.mustHave ||
            item.priority == ItemPriority.necessary,
      ItemFilter.dueSoon =>
        item.dueDate != null &&
            !item.dueDate!.isBefore(_dateOnly(current)) &&
            item.dueDate!.difference(current).inDays <= 14,
      ItemFilter.overBudget =>
        item.actualPrice > 0 &&
            item.estimatedPrice > 0 &&
            item.actualPrice > item.estimatedPrice,
      ItemFilter.hasPhoto =>
        item.inspirationImagePath != null ||
            item.productImagePath != null ||
            item.receiptImagePath != null,
      ItemFilter.hasNote => item.note.trim().isNotEmpty,
      ItemFilter.hasPayment =>
        item.contractTotal > 0 ||
            item.depositPaid > 0 ||
            item.totalPaid > 0 ||
            item.paymentDeadline != null,
      ItemFilter.mustHave => item.priority == ItemPriority.mustHave,
      ItemFilter.necessary => item.priority == ItemPriority.necessary,
      ItemFilter.later => item.priority == ItemPriority.later,
      ItemFilter.luxury => item.priority == ItemPriority.luxury,
    };
  }

  bool matchesSearch(PrepItem item, String searchQuery) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    return item.title.toLowerCase().contains(query) ||
        item.subCategory.toLowerCase().contains(query) ||
        item.shopName.toLowerCase().contains(query) ||
        item.vendorName.toLowerCase().contains(query) ||
        item.note.toLowerCase().contains(query) ||
        item.mainCategory.label.toLowerCase().contains(query);
  }

  List<PrepItem> sortItems(List<PrepItem> items, ItemSort sort) {
    final sorted = [...items];
    sorted.sort((a, b) {
      return switch (sort) {
        ItemSort.recommended => _recommendedCompare(a, b),
        ItemSort.priority =>
          a.priority.sortOrder.compareTo(b.priority.sortOrder),
        ItemSort.dueDate => _dateCompare(a.dueDate, b.dueDate),
        ItemSort.newest => b.createdAt.compareTo(a.createdAt),
        ItemSort.oldest => a.createdAt.compareTo(b.createdAt),
        ItemSort.estimatedPrice =>
          b.estimatedPrice.compareTo(a.estimatedPrice),
        ItemSort.actualPrice => b.actualPrice.compareTo(a.actualPrice),
        ItemSort.alphabetical => a.title.compareTo(b.title),
      };
    });
    return sorted;
  }

  int _recommendedCompare(PrepItem a, PrepItem b) {
    final completed = a.isCompleted == b.isCompleted
        ? 0
        : a.isCompleted
            ? 1
            : -1;
    if (completed != 0) return completed;
    final priority = a.priority.sortOrder.compareTo(b.priority.sortOrder);
    if (priority != 0) return priority;
    return _dateCompare(a.dueDate, b.dueDate);
  }

  int _dateCompare(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}

extension ItemFilterText on ItemFilter {
  String get label => switch (this) {
        ItemFilter.all => 'Tümü',
        ItemFilter.missing => 'Eksik',
        ItemFilter.completed => 'Tamamlandı',
        ItemFilter.purchased => 'Satın alındı',
        ItemFilter.notPurchased => 'Satın alınmadı',
        ItemFilter.highPriority => 'Yüksek öncelik',
        ItemFilter.dueSoon => 'Yakın tarih',
        ItemFilter.overBudget => 'Bütçeyi aşan',
        ItemFilter.hasPhoto => 'Fotoğraflı',
        ItemFilter.hasNote => 'Notlu',
        ItemFilter.hasPayment => 'Ödemeli',
        ItemFilter.mustHave => 'Olmazsa Olmaz',
        ItemFilter.necessary => 'Gerekli',
        ItemFilter.later => 'Sonra',
        ItemFilter.luxury => 'Lüks',
      };
}

extension ItemSortText on ItemSort {
  String get label => switch (this) {
        ItemSort.recommended => 'Önerilen',
        ItemSort.priority => 'Öncelik',
        ItemSort.dueDate => 'Tarih',
        ItemSort.newest => 'Yeni',
        ItemSort.oldest => 'Eski',
        ItemSort.estimatedPrice => 'Tahmini fiyat',
        ItemSort.actualPrice => 'Gerçek fiyat',
        ItemSort.alphabetical => 'A-Z',
      };
}
