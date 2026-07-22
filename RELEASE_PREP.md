# Yayin Hazirligi Notlari

## Platform

Android ve iOS platform klasorleri olusturuldu.

Kontrol komutlari:

```bash
flutter pub get
flutter analyze
flutter test
flutter build appbundle
flutter build ios --no-codesign
```

Not: iOS release build Windows ortaminda dogrulanamaz; macOS/Xcode gerekir.

## Package Name / Bundle ID

- Android applicationId: `com.sonerdnrekhesap.hazirliktakibi`
- iOS bundleId: `com.sonerdnrekhesap.hazirliktakibi`
- App adi: `Hazirlik Takibi`

## Monetization

AdMob uygulamalari ve reklam birimleri `sonerdnrekhesap@gmail.com` hesabinda olusturuldu.
Native App ID'ler Android Manifest ve iOS Info.plist dosyalarina islendi.

Detayli ID listesi: `docs/ADMOB_RELEASE_IDS.md`

Premium mock satin alma release build'de gizlidir. Gercek premium icin RevenueCat veya `in_app_purchase` ile ayri entegrasyon gerekir.

Premium olmayan kullaniciya reklam gosterilebilir; premium kullaniciya reklam gosterilmez.
