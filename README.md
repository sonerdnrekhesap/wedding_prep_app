# Hazırlık Takibi

Flutter ile geliştirilmiş offline çeyiz ve düğün hazırlık takip uygulaması.

## Özellikler

- İlk kurulum: düğün tarihi, hedef bütçe ve çift isimleri
- Ana ekran: kalan gün, hazırlık skoru, harcama ve eksik özetleri
- Çeyiz, bohça, söz, nişan, kına, düğün ve balayı listeleri
- Öncelik bazlı filtreleme ve sıralama
- Ürün detayında fiyat, mağaza, not, satın alma tarihi, garanti ve fiş arşivi
- Davetli listesi, toplu davetli ekleme ve taraf/durum özetleri
- Bütçe ekranında kategori yüzdeleri, aşım uyarıları ve yorumlar
- Akıllı eksik uyarıları
- Ürün önerileri, hediye listesi, bütçeme göre paket ve teklif alma alanları
- Modern alt kategori deneyimi, subkategori chipleri ve kategori seçici
- Gelişmiş arama, filtreleme ve sıralama
- Haftalık Plan: bu haftanın işleri, yaklaşan ödemeler ve önerilen adımlar
- Son kaldığın yerden devam etme desteği
- Kapora, toplam ödeme, ödeme son tarihi ve tedarikçi takibi
- Hazırlık milestone'ları ve sade motivasyon mekanikleri
- RevenueCat tabanlı premium mimarisi
- Hive tabanlı lokal veri saklama ve SharedPreferences'tan güvenli migration
- Local notification altyapısı
- AdMob test ID'leri ve environment tabanlı production ID hazırlığı

## Çalıştırma

Bu klasör Flutter kaynak dosyalarını içerir. Bu makinede Flutter SDK bulunmadığı için burada derleme yapılamadı.

Flutter kurulu bir ortamda:

```bash
flutter create --platforms=android,ios .
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

iOS için macOS/Xcode ortamında:

```bash
flutter build ios --no-codesign
```

`flutter create` mevcut `lib/` ve `pubspec.yaml` dosyalarını koruyarak eksik Android/iOS proje dosyalarını oluşturur.

## RevenueCat kurulumu

Gerçek satın alma için repository'ye API key yazma. Build sırasında dart define kullan:

```bash
flutter run \
  --dart-define=REVENUECAT_APPLE_API_KEY=appl_xxx \
  --dart-define=REVENUECAT_GOOGLE_API_KEY=goog_xxx \
  --dart-define=REVENUECAT_ENTITLEMENT_ID=pro
```

RevenueCat panelinde aynı ürün kimliklerini oluştur:

- `premium_monthly`
- `premium_6months`
- `premium_lifetime`

Anahtar yoksa uygulama premiumu açmaz ve kullanıcıya sahte ödeme göstermez.

## AdMob kurulumu

Debug build test ID kullanır. Release için:

```bash
flutter build apk --release \
  --dart-define=ADMOB_BANNER_ID=ca-app-pub-xxx/yyy \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-xxx/yyy \
  --dart-define=ADMOB_REWARDED_ID=ca-app-pub-xxx/yyy
```

Google UMP consent ve iOS ATT metinleri store hazırlığında ayrıca bağlanmalıdır.

## Bildirimler

Bildirimler `flutter_local_notifications` ile yerel olarak planlanır. Android 13+ bildirim izni ve iOS izinleri platform klasörleri üretildikten sonra manifest/plist tarafında kontrol edilmelidir.

## Veri migration

Eski sürümdeki SharedPreferences JSON verileri ilk açılışta Hive kutusuna taşınır. Eski değerler `backup_before_hive_*` ve güncel yedekler `backup_current_*` anahtarlarında saklanır; bozuk kayıtlar uygulamayı düşürmeden atlanır.
