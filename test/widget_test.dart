import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_prep_app/main.dart';

void main() {
  testWidgets('builds the wedding prep app', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const WeddingPrepApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
