# Android Release Signing

Release build, `android/key.properties` varsa upload key ile imzalanir.
Dosya yoksa local dogrulama icin debug signing fallback kullanilir.

`android/key.properties` ornegi:

```properties
storeFile=C:\\path\\to\\upload-keystore.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=upload
keyPassword=YOUR_KEY_PASSWORD
```

Guvenlik:

- `android/key.properties`, `*.jks` ve `*.keystore` git'e alinmaz.
- Upload key ve sifreler sadece yerel makinede veya guvenli CI secret olarak tutulur.

Production build ornegi:

```bash
flutter build appbundle \
  --dart-define=ADMOB_ANDROID_BANNER_UNIT_ID=ca-app-pub-8162088920909843/6127783433 \
  --dart-define=ADMOB_ANDROID_INTERSTITIAL_UNIT_ID=ca-app-pub-8162088920909843/9412422322 \
  --dart-define=ADMOB_ANDROID_REWARDED_UNIT_ID=ca-app-pub-8162088920909843/2052807053
```
