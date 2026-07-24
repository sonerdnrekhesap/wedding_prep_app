import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum MonetizationEvent {
  paywallView,
  premiumGateView,
  premiumCtaTap,
  restoreTap,
  rewardedAttempt,
  rewardedSuccess,
  rewardedUnavailable,
  featureUnlocked,
}

class MonetizationSnapshot {
  const MonetizationSnapshot({required this.counts});

  const MonetizationSnapshot.empty() : counts = const {};

  final Map<MonetizationEvent, int> counts;

  int count(MonetizationEvent event) => counts[event] ?? 0;

  MonetizationSnapshot increment(MonetizationEvent event) {
    return MonetizationSnapshot(
      counts: {
        ...counts,
        event: count(event) + 1,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      for (final event in MonetizationEvent.values) event.name: count(event),
    };
  }

  factory MonetizationSnapshot.fromJson(Map<String, dynamic> json) {
    return MonetizationSnapshot(
      counts: {
        for (final event in MonetizationEvent.values)
          event: (json[event.name] as num?)?.toInt() ?? 0,
      },
    );
  }
}

class MonetizationMetricsService {
  const MonetizationMetricsService();

  static const key = 'monetization_metrics';

  Future<MonetizationSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return const MonetizationSnapshot.empty();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const MonetizationSnapshot.empty();
      }
      return MonetizationSnapshot.fromJson(decoded);
    } catch (_) {
      return const MonetizationSnapshot.empty();
    }
  }

  Future<MonetizationSnapshot> record(MonetizationEvent event) async {
    final next = (await load()).increment(event);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(next.toJson()));
    return next;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
