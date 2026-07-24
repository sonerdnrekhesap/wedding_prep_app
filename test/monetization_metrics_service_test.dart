import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_prep_app/services/monetization_metrics_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('records monetization events cumulatively', () async {
    const service = MonetizationMetricsService();

    await service.record(MonetizationEvent.paywallView);
    final snapshot = await service.record(MonetizationEvent.rewardedSuccess);

    expect(snapshot.count(MonetizationEvent.paywallView), 1);
    expect(snapshot.count(MonetizationEvent.rewardedSuccess), 1);
    expect(snapshot.count(MonetizationEvent.rewardedAttempt), 0);
  });

  test('loads empty snapshot when stored metrics are corrupt', () async {
    SharedPreferences.setMockInitialValues({
      MonetizationMetricsService.key: 'not-json',
    });

    final snapshot = await const MonetizationMetricsService().load();

    expect(snapshot.count(MonetizationEvent.paywallView), 0);
    expect(snapshot.count(MonetizationEvent.premiumGateView), 0);
  });

  test('reset removes stored monetization counters', () async {
    const service = MonetizationMetricsService();

    await service.record(MonetizationEvent.premiumGateView);
    await service.reset();

    final snapshot = await service.load();
    expect(snapshot.count(MonetizationEvent.premiumGateView), 0);
  });
}
