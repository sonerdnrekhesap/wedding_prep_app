# Hazırlık Takibi

Flutter ile geliştirilmiş offline çeyiz ve düğün hazırlık takip uygulaması.

## Özellikler

- İlk kurulum: düğün tarihi, hedef bütçe, çift isimleri ve hazırlık tipi
- Ana ekran: kalan gün, ağırlıklı hazırlık skoru, harcama ve eksik özetleri
- Çeyiz, bohça, söz, nişan, kına, düğün ve balayı listeleri
- Öncelik bazlı filtreleme ve sıralama
- Ürün detayında tahmini fiyat, gerçek fiyat, mağaza, not ve öncelik düzenleme
- Checkbox sonrası isteğe bağlı “Ne kadara aldın?” girişi
- Davetli listesi ve taraf/durum özetleri
- Bütçe ekranında kategori bazlı grafik, en pahalı ürünler ve yüksek tahminli eksikler
- “Önce Ne Almalıyım?” ekranı
- Spotify Wrapped benzeri hazırlık özeti ve metin paylaşımı
- SharedPreferences ile local/offline veri saklama
- AdMob test ID’leri ile banner ve kategori geçişlerinde kontrollü interstitial altyapısı

## Çalıştırma

Bu klasör Flutter kaynak dosyalarını içerir. Bu makinede Flutter SDK bulunmadığı için burada derleme yapılamadı.

Flutter kurulu bir ortamda:

```bash
flutter create --platforms=android,ios .
flutter pub get
flutter analyze
flutter run
```

`flutter create` mevcut `lib/` ve `pubspec.yaml` dosyalarını koruyarak eksik Android/iOS proje dosyalarını oluşturur.
