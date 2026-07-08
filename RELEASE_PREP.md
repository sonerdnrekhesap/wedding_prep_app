# Yayın Hazırlığı Notları

## Platform

Bu ortamda `flutter create --platforms=android,ios .` komutu çıktı vermeden zaman aşımına düştü. Başka makinede tekrar çalıştırılmalı.

Önerilen komutlar:

```bash
flutter create --platforms=android,ios .
flutter pub get
flutter analyze
flutter test
flutter build appbundle
flutter build ios --no-codesign
```

## Package Name / Bundle ID

Öneri:

- Android applicationId: `com.sonerdnrekhesap.hazirliktakibi`
- iOS bundleId: `com.sonerdnrekhesap.hazirliktakibi`
- App adı: `Hazırlık Takibi`

Android dosyaları oluşunca kontrol edilecek yer:

- `android/app/build.gradle`
- `android/app/src/main/AndroidManifest.xml`

iOS dosyaları oluşunca kontrol edilecek yer:

- `ios/Runner.xcodeproj/project.pbxproj`
- `ios/Runner/Info.plist`

## Monetization

Mock premium sistemi eklendi. Product ID önerileri:

- `premium_monthly`
- `premium_6months`
- `premium_lifetime`

Production entegrasyonu için `PremiumService` RevenueCat veya `in_app_purchase` ile değiştirilebilir.

Premium gate prensibi:

- Core checklist, ürün tikleme, temel bütçe, kalan gün ve genel hazırlık skoru ücretsiz kalır.
- Kullanıcı değer görmeden paywall gösterilmez.
- Akıllı plan, detaylı analiz, dışa aktarma, premium özet kartları, partner senkronizasyonu ve reklamsız kullanım premiumdur.
- Premium olmayan kullanıcı desteklenen premium özellikleri rewarded ad ile tek seferlik deneyebilir.
- Premium kullanıcıya hiçbir reklam gösterilmez.

## Reklam

AdMob test ID'leri `AdConfig` içinde korunuyor. Gerçek ID'ler release öncesi `AdConfig.production` alanına girilmeli.

Premium kullanıcıya reklam gösterilmez.
