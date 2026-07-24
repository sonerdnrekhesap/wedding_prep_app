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

## Store Satin Alma

`in_app_purchase` iskeleti eklendi.

Urun ID'leri:

- `premium_monthly`
- `premium_6months`
- `premium_lifetime`

Detayli kurulum: `docs/STORE_PURCHASE_SETUP.md`

Ilk release icin en dusuk riskli urun `premium_lifetime` non-consumable olarak acilmali. Aylik ve 6 aylik paketler abonelik/expiry dogrulamasi tamamlanmadan canli satis icin acilmamali.
