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

  // Release öncesi gerçek AdMob ID'leri burada test ID'leriyle değiştirilecek.
  static const production = test;

  static const active = test;
}
