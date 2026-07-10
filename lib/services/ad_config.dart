import 'package:flutter/foundation.dart';

class AdConfig {
  const AdConfig({
    required this.bannerUnitId,
    required this.interstitialUnitId,
    required this.rewardedUnitId,
  });

  final String bannerUnitId;
  final String interstitialUnitId;
  final String rewardedUnitId;

  static const test = AdConfig(
    bannerUnitId: 'ca-app-pub-3940256099942544/6300978111',
    interstitialUnitId: 'ca-app-pub-3940256099942544/1033173712',
    rewardedUnitId: 'ca-app-pub-3940256099942544/5224354917',
  );

  static const production = AdConfig(
    bannerUnitId: String.fromEnvironment('ADMOB_BANNER_ID'),
    interstitialUnitId: String.fromEnvironment('ADMOB_INTERSTITIAL_ID'),
    rewardedUnitId: String.fromEnvironment('ADMOB_REWARDED_ID'),
  );

  static AdConfig get active {
    if (kDebugMode) return test;
    if (production.bannerUnitId.isEmpty ||
        production.interstitialUnitId.isEmpty ||
        production.rewardedUnitId.isEmpty) {
      return test;
    }
    return production;
  }
}
