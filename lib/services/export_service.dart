import '../models/guest_model.dart';
import '../models/item_model.dart';
import 'formatters.dart';

class ExportService {
  static const _excelBom = '\uFEFF';

  String buildGuestCsv(List<Guest> guests) {
    final rows = [
      ['Ad', 'Telefon', 'Taraf', 'Kisi', 'Durum', 'Not'],
      for (final guest in guests)
        [
          guest.name,
          guest.phone,
          guest.side.label,
          guest.personCount.toString(),
          guest.status.label,
          guest.note,
        ],
    ];
    return rows.map((row) => row.map(_csvCell).join(',')).join('\n');
  }

  String buildChecklistCsv(List<PrepItem> items) {
    final rows = [
      [
        'Kategori',
        'Alt Kategori',
        'Urun',
        'Durum',
        'Oncelik',
        'Adet',
        'Tahmini Fiyat',
        'Gercek Harcama',
        'Magaza',
        'Marka/Model',
        'Not',
        'Tamamlanma Tarihi',
      ],
      for (final item in items)
        [
          item.mainCategory.label,
          item.subCategory,
          item.title,
          item.isCompleted ? 'Tamam' : 'Eksik',
          item.priority.label,
          item.quantity.toString(),
          item.estimatedPrice.toStringAsFixed(2),
          item.actualPrice.toStringAsFixed(2),
          item.shopName,
          item.brandModel ?? '',
          item.note,
          _dateCell(item.completedDate),
        ],
    ];
    return _excelBom +
        rows.map((row) => row.map(_csvCell).join(',')).join('\n');
  }

  String buildBudgetCsv(List<PrepItem> items) {
    final rows = [
      [
        'Kategori',
        'Toplam Urun',
        'Tamamlanan',
        'Eksik',
        'Toplam Harcama',
        'Eksik Tahmini',
      ],
      for (final category in MainCategory.values)
        _budgetRow(
            category,
            items
                .where((item) => item.mainCategory == category)
                .toList(growable: false)),
    ];
    return _excelBom +
        rows.map((row) => row.map(_csvCell).join(',')).join('\n');
  }

  String buildPrepListText(List<PrepItem> items) {
    final buffer = StringBuffer('Hazirlik listesi\n\n');
    for (final category in MainCategory.values) {
      final categoryItems =
          items.where((item) => item.mainCategory == category).toList();
      if (categoryItems.isEmpty) continue;
      buffer.writeln(category.label);
      for (final item in categoryItems) {
        final status = item.isCompleted ? 'Tamam' : 'Eksik';
        buffer
            .writeln('- [$status] ${item.title} - ${money(item.actualPrice)}');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  String buildBudgetSummaryText(List<PrepItem> items) {
    final spent = items.fold<double>(0, (sum, item) => sum + item.actualPrice);
    final estimated =
        items.fold<double>(0, (sum, item) => sum + item.estimatedPrice);
    return 'Harcama ozeti\n'
        'Toplam harcama: ${money(spent)}\n'
        'Tahmini ihtiyac: ${money(estimated)}';
  }

  String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  List<String> _budgetRow(MainCategory category, List<PrepItem> items) {
    final completed = items.where((item) => item.isCompleted).length;
    final spent = items.fold<double>(0, (sum, item) => sum + item.actualPrice);
    final missingEstimate = items
        .where((item) => !item.isCompleted)
        .fold<double>(0, (sum, item) => sum + item.estimatedPrice);
    return [
      category.label,
      items.length.toString(),
      completed.toString(),
      (items.length - completed).toString(),
      spent.toStringAsFixed(2),
      missingEstimate.toStringAsFixed(2),
    ];
  }

  String _dateCell(DateTime? date) {
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
