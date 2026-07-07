import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const bannerTestUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const interstitialTestUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const rewardedTestUnitId = 'ca-app-pub-3940256099942544/5224354917';

  int _categoryOpenCount = 0;
  InterstitialAd? _interstitialAd;

  Future<void> initialize() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
    _loadInterstitial();
  }

  void _loadInterstitial() {
    if (kIsWeb) return;
    InterstitialAd.load(
      adUnitId: interstitialTestUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void maybeShowCategoryInterstitial() {
    if (kIsWeb) return;
    _categoryOpenCount += 1;
    if (_categoryOpenCount % 3 != 0) return;
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
    _interstitialAd = null;
  }
}
