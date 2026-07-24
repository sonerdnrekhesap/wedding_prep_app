# AdMob Release IDs

AdMob account: `sonerdnrekhesap@gmail.com`

## iOS

- App ID: `ca-app-pub-8162088920909843~7618773162`
- Banner: `ca-app-pub-8162088920909843/7179789464`
- Interstitial: `ca-app-pub-8162088920909843/6932377456`
- Rewarded: `ca-app-pub-8162088920909843/8290912342`

Release build:

```bash
flutter build ios --release \
  --dart-define=ADMOB_IOS_BANNER_UNIT_ID=ca-app-pub-8162088920909843/7179789464 \
  --dart-define=ADMOB_IOS_INTERSTITIAL_UNIT_ID=ca-app-pub-8162088920909843/6932377456 \
  --dart-define=ADMOB_IOS_REWARDED_UNIT_ID=ca-app-pub-8162088920909843/8290912342
```

## Android

- App ID: `ca-app-pub-8162088920909843~8618215403`
- Banner: `ca-app-pub-8162088920909843/6127783433`
- Interstitial: `ca-app-pub-8162088920909843/9412422322`
- Rewarded: `ca-app-pub-8162088920909843/2052807053`

Release build:

```bash
flutter build appbundle \
  --dart-define=ADMOB_ANDROID_BANNER_UNIT_ID=ca-app-pub-8162088920909843/6127783433 \
  --dart-define=ADMOB_ANDROID_INTERSTITIAL_UNIT_ID=ca-app-pub-8162088920909843/9412422322 \
  --dart-define=ADMOB_ANDROID_REWARDED_UNIT_ID=ca-app-pub-8162088920909843/2052807053
```

Note: Newly created ad units can take up to an hour before live ads appear. The AdMob apps still need store linking and review after the store listings are available.
