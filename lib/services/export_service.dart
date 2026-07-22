import '../models/guest_model.dart';
import '../models/item_model.dart';
import 'formatters.dart';

class ExportService {
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
}
