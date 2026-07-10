import 'dart:convert';

import '../models/app_settings_model.dart';
import '../models/guest_model.dart';
import '../models/item_model.dart';
import '../models/lead_request_model.dart';
import 'formatters.dart';

class ExportService {
  String buildJsonBackup({
    required AppSettings settings,
    required List<PrepItem> items,
    required List<Guest> guests,
    required List<LeadRequest> leads,
  }) {
    return const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'guests': guests.map((guest) => guest.toJson()).toList(),
      'leads': leads.map((lead) => lead.toJson()).toList(),
    });
  }

  BackupData parseJsonBackup(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Yedek dosyası geçerli değil.');
    }
    if (decoded['schemaVersion'] != 1) {
      throw const FormatException('Desteklenmeyen yedek sürümü.');
    }
    return BackupData(
      settings: AppSettings.fromJson(_map(decoded['settings'])),
      items: _list(decoded['items']).map((item) => PrepItem.fromJson(item)),
      guests: _list(decoded['guests']).map((guest) => Guest.fromJson(guest)),
      leads: _list(decoded['leads']).map((lead) => LeadRequest.fromJson(lead)),
    );
  }

  String buildGuestCsv(List<Guest> guests) {
    final rows = [
      ['Ad', 'Telefon', 'Taraf', 'Kişi', 'Durum', 'Not'],
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
    final buffer = StringBuffer('Hazırlık listesi\n\n');
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
    return 'Harcama özeti\nToplam harcama: ${money(spent)}\nTahmini ihtiyaç: ${money(estimated)}';
  }

  String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const FormatException('Yedek alanı geçerli değil.');
  }

  List<Map<String, dynamic>> _list(Object? value) {
    if (value is! List) return const [];
    return value.map(_map).toList();
  }
}

class BackupData {
  const BackupData({
    required this.settings,
    required Iterable<PrepItem> items,
    required Iterable<Guest> guests,
    required Iterable<LeadRequest> leads,
  })  : items = items,
        guests = guests,
        leads = leads;

  final AppSettings settings;
  final Iterable<PrepItem> items;
  final Iterable<Guest> guests;
  final Iterable<LeadRequest> leads;
}
