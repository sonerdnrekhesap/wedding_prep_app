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

  static AdConfig get production => AdConfig(
        bannerUnitId: defaultTargetPlatform == TargetPlatform.iOS
            ? const String.fromEnvironment('ADMOB_IOS_BANNER_UNIT_ID')
            : const String.fromEnvironment('ADMOB_ANDROID_BANNER_UNIT_ID'),
        interstitialUnitId: defaultTargetPlatform == TargetPlatform.iOS
            ? const String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_UNIT_ID')
            : const String.fromEnvironment(
                'ADMOB_ANDROID_INTERSTITIAL_UNIT_ID'),
        rewardedUnitId: defaultTargetPlatform == TargetPlatform.iOS
            ? const String.fromEnvironment('ADMOB_IOS_REWARDED_UNIT_ID')
            : const String.fromEnvironment('ADMOB_ANDROID_REWARDED_UNIT_ID'),
      );

  static AdConfig get active => kReleaseMode ? production : test;

  static bool get canRequestAds {
    final config = active;
    return config.bannerUnitId.isNotEmpty &&
        config.interstitialUnitId.isNotEmpty &&
        config.rewardedUnitId.isNotEmpty;
  }
}
