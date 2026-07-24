import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_prep_app/models/app_settings_model.dart';
import 'package:wedding_prep_app/models/guest_model.dart';
import 'package:wedding_prep_app/models/item_model.dart';
import 'package:wedding_prep_app/services/pdf_report_service.dart';

void main() {
  test('buildPlanningReportPdf creates a valid PDF report payload', () {
    final bytes = const PdfReportService().buildPlanningReportPdf(
      AppSettings(
        weddingDate: DateTime(2026, 8, 30),
        targetBudget: 1000,
        brideName: 'Ayse',
        groomName: 'Can',
      ),
      [
        PrepItem(
          id: 'item-1',
          title: 'Salon kapora',
          mainCategory: MainCategory.dugun,
          subCategory: 'Mekan',
          priority: ItemPriority.mustHave,
          estimatedPrice: 900,
          actualPrice: 200,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ],
      [
        Guest(
          id: 'guest-1',
          name: 'Deniz',
          side: GuestSide.bride,
          status: GuestStatus.coming,
          guestCount: 2,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ],
    );
    final pdf = ascii.decode(bytes);

    expect(pdf, startsWith('%PDF-1.4'));
    expect(pdf, contains('Hazirlik Takibi Premium Rapor'));
    expect(pdf, contains('Salon kapora'));
    expect(pdf, contains('startxref'));
    expect(pdf, endsWith('%%EOF'));
  });
}
