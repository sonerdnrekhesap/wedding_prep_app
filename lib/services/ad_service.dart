import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

class AdService {
  int _categoryOpenCount = 0;
  DateTime? _lastInterstitialAt;
  bool _isPremium = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool get canShowAds => !_isPremium;

  void setPremium(bool isPremium) {
    _isPremium = isPremium;
    if (isPremium) {
      _interstitialAd?.dispose();
      _rewardedAd?.dispose();
      _interstitialAd = null;
      _rewardedAd = null;
    }
  }

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _loadInterstitial();
      _loadRewarded();
    } catch (error, stackTrace) {
      developer.log(
        'AdMob initialization failed.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _loadInterstitial() {
    if (kIsWeb || _isPremium) return;
    try {
      InterstitialAd.load(
        adUnitId: AdConfig.active.interstitialUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitialAd = ad,
          onAdFailedToLoad: (_) => _interstitialAd = null,
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'Interstitial ad load failed.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void maybeShowCategoryInterstitial() {
    if (kIsWeb || _isPremium) return;
    _categoryOpenCount += 1;
    if (_categoryOpenCount % 3 != 0) return;
    final now = DateTime.now();
    final lastShown = _lastInterstitialAt;
    if (lastShown != null && now.difference(lastShown).inMinutes < 3) return;
    final ad = _interstitialAd;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
    _lastInterstitialAt = now;
    _interstitialAd = null;
  }

  void _loadRewarded() {
    if (kIsWeb || _isPremium) return;
    try {
      RewardedAd.load(
        adUnitId: AdConfig.active.rewardedUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) => _rewardedAd = ad,
          onAdFailedToLoad: (_) => _rewardedAd = null,
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'Rewarded ad load failed.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> showRewardedForFeature() async {
    if (kIsWeb || _isPremium) return false;
    final ad = _rewardedAd;
    if (ad == null) {
      _loadRewarded();
      return false;
    }
    var rewarded = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadRewarded();
      },
    );
    await ad.show(onUserEarnedReward: (_, __) => rewarded = true);
    _rewardedAd = null;
    return rewarded;
  }
}
