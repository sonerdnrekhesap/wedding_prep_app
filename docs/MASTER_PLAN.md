# Wedding Prep App Master Plan

> Director source of truth: `docs/DIRECTOR_MASTER_PLAN.md`, `docs/SPRINT_BACKLOG.md` and `docs/KPI_DASHBOARD.md`.
> The older sections below are historical notes from the first release-readiness pass and may mention gaps that are now closed.

Tarih: 22 Temmuz 2026
Proje: `C:\Users\soner\Documents\Codex\2026-07-07\bir-p\wedding_prep_app`

## Kisa Durum

Uygulama iyi bir Flutter MVP iskeletine sahip: onboarding, checklist, butce, davetli, oncelik, ozet, local kayit, reklam ve premium iskeleti var. Kod `flutter analyze`, `flutter test` ve `flutter build web` kontrollerinden gecti.

Yayina hazir degil. En buyuk engeller: Android/iOS platform klasorleri yok, premium mock durumda, AdMob test ayarinda, storage migration/bozuk veri korumasi zayif, test kapsami cok dar, privacy/store materyalleri eksik.

## 22 Temmuz 2026 Ilerleme Notu

Ek AdMob tamamlama notu:

- AdMob hesabinda iOS oncelikli olacak sekilde `Hazirlik Takibi` iOS uygulamasi olusturuldu.
- iOS App ID `Info.plist` dosyasina islendi.
- iOS banner, interstitial ve rewarded reklam birimleri olusturuldu.
- Android AdMob uygulamasi ve banner/interstitial/rewarded reklam birimleri de olusturuldu.
- Android App ID `AndroidManifest.xml` dosyasina islendi.
- Platform bazli release reklam unit ID'leri `--dart-define` ile secilecek hale getirildi.
- AdMob ID listesi `docs/ADMOB_RELEASE_IDS.md` dosyasina eklendi.
- Son `flutter analyze` temiz; `flutter test` 10 testle temiz; Android AAB gercek Android AdMob unit ID'leriyle uretildi.

Ek urun/premium notu:

- Rakip urun desenleri `docs/COMPETITOR_PRODUCT_NOTES.md` dosyasina eklendi.
- Flutter acilis animasyonu eklendi.
- Android ve iOS native launch ekranlari marka rengi ve merkez marka isaretiyle guncellendi.
- Premium katalogu urun ID, fiyat etiketi, onerilen paket ve fayda listesi tasiyacak sekilde guclendirildi.
- Paywall ekrani free value, premium value, plan kartlari ve store-onayi guven metniyle yeniden tasarlandi.
- `in_app_purchase` tabanli satin alma iskeleti eklendi.
- Store urun kurulum notlari `docs/STORE_PURCHASE_SETUP.md` dosyasina eklendi.

Tamamlananlar:

- Android ve iOS platform klasorleri olusturuldu.
- Android package id ve iOS bundle id release adayina cekildi: `com.sonerdnrekhesap.hazirliktakibi`.
- Android/iOS uygulama adi `Hazirlik Takibi` olarak ayarlandi.
- Android fotoğraf izinleri ve AdMob app id placeholder'i eklendi.
- iOS fotoğraf/kamera izin metinleri ve AdMob app id placeholder'i eklendi.
- Bozuk SharedPreferences verisi icin recovery ve quarantine akisi eklendi.
- Item/guest/settings model parse islemleri eksik/bozuk/tarihi hatali veriye karsi guclendirildi.
- Para parse islemi negatif/gecersiz degerleri sifirlayacak sekilde sikilastirildi.
- Mock premium satin alma UI'i release build'de gizlendi.
- Storage/model/para parse icin unit testler eklendi.
- `flutter analyze` temiz.
- `flutter test` temiz: 7 test gecti.
- Android release appbundle uretildi: `build\app\outputs\bundle\release\app-release.aab`.

Halen kritik kalanlar:

- Gercek AdMob production id'leri girilmeli; su an test app id/unit id placeholder kullaniliyor.
- Release signing debug key yerine production upload key ile yapilmali.
- App icon/splash halen Flutter template.
- Privacy policy, Data Safety ve store screenshot seti hazirlanmali.
- iOS build Windows ortaminda dogrulanamaz; macOS/Xcode ortaminda ayrica calistirilmali.

## Hedef

Ilk hedef, uygulamayi "ucretsiz offline ceyiz ve dugun hazirlik takipcisi" olarak stabil sekilde Google Play yayinina hazirlamak. Premium gelir modeli ikinci fazda gercek satin alma, reklamsiz kullanim ve export gibi somut degerlerle acilmali.

## Acil Karar

1. Ilk yayin sadece Android mi olacak, yoksa Android + iOS birlikte mi?
2. Uygulama adi kesin mi: `Hazirlik Takibi`, `Ceyizim`, veya baska ad?
3. Premium ilk yayinda kapali mi kalacak, yoksa RevenueCat/in_app_purchase ile gercek premium mu eklenecek?
4. AdMob ilk yayinda aktif olacak mi, yoksa once reklamsiz soft launch mi?

Onerilen karar: Ilk yayin Android-only, ucretsiz + AdMob, premium kapali veya sadece "yakinda" olarak gizli. Premium v1 ikinci sprintte acilsin.

## Faz 0 - Projeyi Release Zemine Alma

Sure: 0.5-1 gun
Oncelik: Kritik

Adimlar:

1. Native platformlari olustur.
   - `flutter create --platforms=android,ios .`
   - Android ve iOS klasorlerinin temiz uretildigini kontrol et.

2. Kimlikleri sabitle.
   - Android applicationId: `com.sonerdnrekhesap.hazirliktakibi`
   - iOS bundleId: `com.sonerdnrekhesap.hazirliktakibi`
   - App adi: secilen nihai marka.

3. Derleme hattini dogrula.
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`
   - `flutter build appbundle`
   - `flutter build ios --no-codesign`

Kabul kriteri:

- Android app bundle uretiliyor.
- iOS no-codesign build en azindan teknik olarak geciyor.
- Analyze ve test yesil.

## Faz 1 - Kritik Stabilite ve Veri Guvenligi

Sure: 2-3 gun
Oncelik: Kritik

Adimlar:

1. `StorageService` icin korumali okuma ekle.
   - `jsonDecode` try/catch.
   - Bozuk veri durumunda app acilsin, kullaniciya reset/demo opsiyonu sunulsun.
   - Schema version ekle.

2. Model parse islemlerini geriye uyumlu yap.
   - Enum `byName` yerine fallback'li parse.
   - `DateTime.parse` icin nullable/guard.
   - Eksik alanlarda varsayilan deger.

3. Para ve adet validasyonunu sikilastir.
   - Negatif fiyat engeli.
   - Cok buyuk fiyat limiti.
   - Bos/gecersiz inputlarda temiz hata mesaji.

4. Fotoğraf akisini guvenli hale getir.
   - Image picker try/catch.
   - Async sonrasi `mounted` kontrollerini tamamla.
   - Dosya kaydetme hatalarinda kullaniciya anlasilir mesaj.

Kabul kriteri:

- Bozuk SharedPreferences verisi app'i crash ettirmiyor.
- Item/guest/settings eski veya eksik veriyle acilabiliyor.
- Temel CRUD akislari hatasiz.

## Faz 2 - MVP Urun Kalitesi

Sure: 3-5 gun
Oncelik: Yuksek

Adimlar:

1. Onboarding'i tamamla.
   - Hazirlik tipi secimi: ceyiz, dugun, nişan/kina, balayi, hepsi.
   - Gecmis dugun tarihi, bos butce, isim boslugu gibi durumlari ele al.

2. Checklist deneyimini guclendir.
   - Ozel kategori/alt kategori ekleme.
   - Tamamlanan/eksik/olmazsa olmaz filtreleri.
   - Bos durum ekranlari.
   - Arama sonucunda temiz geri bildirim.

3. Davetli akisini tamamla.
   - Hızli durum degistirme zaten var; import/export ve toplam kisi sayisi daha gorunur olmali.
   - Telefon alaninda format ve opsiyonel dogrulama.

4. Butce ekranini netlestir.
   - Hedef butce asimi uyarisi.
   - Tahmini kalan harcama.
   - Kategori bazli eksik maliyet.

5. Paylasim/export v1.
   - Davetli CSV'yi gercek dosya olarak paylas.
   - Hazirlik listesi CSV/TXT export.
   - Turkce karakterler icin UTF-8 BOM veya Excel uyumlu secenek.

Kabul kriteri:

- Kullanici ilk kurulumdan sonra hic takilmadan liste, butce ve davetli yonetebilir.
- Export gercek dosya olarak calisir.
- Uygulama vaat ettigi ucretsiz MVP degerini tek basina verir.

## Faz 3 - Reklam ve Gizlilik

Sure: 1-2 gun
Oncelik: Yuksek

Adimlar:

1. AdMob production config.
   - Android AdMob app id manifest'e ekle.
   - iOS `GADApplicationIdentifier` ekle.
   - `AdConfig.production` gercek unit id'lere baglansin.
   - Debug/release ayrimi yap.

2. Reklam yogunlugunu kontrol et.
   - Interstitial sadece kategori gecislerinde ve seyrek.
   - Premium kapaliysa bile kullanici deger gormeden reklam basmasin.
   - Banner layout kaymalarini test et.

3. Consent/privacy.
   - Privacy policy URL hazirla.
   - Google Play Data Safety formu icin veri listesi cikar.
   - iOS App Privacy bilgileri hazirla.
   - ATT gerekiyorsa `NSUserTrackingUsageDescription` ve izin akisi planla.

Kabul kriteri:

- Test reklam ID'si release'e karismiyor.
- Privacy policy ve store beyanlari uygulamadaki gercek davranisla uyumlu.

## Faz 4 - Premium v1

Sure: 4-7 gun
Oncelik: Orta, gelir hedefliyse kritik

Adimlar:

1. Mock premium'u production'dan kaldir.
   - Debug-only yap veya tamamen gizle.

2. Gercek satin alma entegre et.
   - Oneri: RevenueCat ile entitlement yonetimi.
   - Alternatif: Flutter `in_app_purchase`.
   - Restore purchases gercek calissin.

3. Premium deger paketini dar ama somut tut.
   - Reklamsiz kullanim.
   - Sinirsiz fotoğraf/fiş.
   - PDF/Excel export.
   - Premium ozet kartlari.

4. Paywall metinlerini sade tut.
   - Partner sync, bulut yedekleme, RSVP gibi hazir olmayan vaatleri kaldir.

Kabul kriteri:

- Satin alma, restore, iptal/yenileme ve entitlement durumlari test edildi.
- Store metinleri gercek premium ozelliklerle birebir uyumlu.

## Faz 5 - Bildirimler ve Akilli Plan

Sure: 3-5 gun
Oncelik: Orta

Adimlar:

1. `flutter_local_notifications` ekle.
2. Android/iOS izinlerini tamamla.
3. Hatirlatici senaryolari:
   - Dugune X gun kaldi.
   - Haftalik eksik ozeti.
   - Olmazsa olmaz eksikler.
4. Ayarlarda bildirim sikligi ve kapatma secenegi.

Kabul kriteri:

- Bildirim izni dogru zamanda istenir.
- Planlanan bildirimler emulator/cihaz uzerinde calisir.

## Faz 6 - Test ve QA Hatti

Sure: 2-4 gun
Oncelik: Kritik

Minimum test seti:

1. CalculationService unit testleri.
2. Storage migration ve bozuk veri testleri.
3. Item CRUD controller testleri.
4. Guest CRUD controller testleri.
5. Export CSV escaping testleri.
6. Premium photo limit/gate testleri.
7. Onboarding smoke ve ana navigation widget testleri.
8. Reklam premium'da gizleniyor testi.

Manuel QA senaryolari:

1. Ilk acilis ve onboarding.
2. Demo data yukleme.
3. Liste item ekleme, tamamlama, fiyat girme, silme.
4. Fotoğraf ekleme ve silme.
5. Davetli ekleme, arama, filtre, durum degistirme.
6. Butce asimi ve kategori grafigi.
7. Reset all.
8. Ucak modu/offline kullanim.
9. Android release build cihaz testi.
10. Dusuk ekran boyutu ve buyuk font testi.

Kabul kriteri:

- `flutter analyze`, `flutter test`, Android appbundle yesil.
- Kritik manuel QA listesinin tamamindan gecildi.

## Faz 7 - Store ve Lansman

Sure: 2-3 gun
Oncelik: Yuksek

Adimlar:

1. Marka paketi.
   - App icon.
   - Splash screen.
   - Feature graphic.
   - Renk ve typography son kontrol.

2. Store materyalleri.
   - Kisa aciklama.
   - Uzun aciklama.
   - 5-6 screenshot.
   - Privacy policy URL.
   - Support email.
   - Content rating.

3. Soft launch.
   - Kapali test track.
   - 10-20 test kullanici.
   - Crash/ANR takibi.
   - Store feedback toplama.

4. Public release.
   - Kademeli yayin: once %10, sonra %50, sonra %100.

Kabul kriteri:

- Store submission eksiksiz.
- Kapali testte kritik crash yok.
- Ilk public release kontrol listesi tamam.

## Teknik Borc Listesi

1. `AppController` fazla sorumluluk tasiyor; ileride repository/service ayrimi yap.
2. `SharedPreferences` kucuk MVP icin yeterli ama buyuyen veri icin SQLite/Isar/Hive degerlendir.
3. Fotoğraf thumbnail gercek degil; dosya boyutu optimizasyonu gerekli.
4. Web fotoğraf persistence zayif; native odakli release icin web iddiasi sinirlanmali.
5. Paketler guncellenebilir ama release oncesi major update zorunlu degil; once stabil build.

## Ilk 7 Gunluk Uygulama Plani

Gun 1:
- Android/iOS platformlari olustur.
- Package id, app name, build number ayarla.
- Analyze/test/build appbundle calistir.

Gun 2:
- Storage guard, model fallback, para/adet validasyonlari.
- Ilk unit testleri.

Gun 3:
- Fotoğraf akisi try/catch ve mounted kontrolleri.
- Export'u dosya paylasimina tasima.

Gun 4:
- AdMob production/debug config altyapisi.
- Privacy policy taslagi ve data safety envanteri.

Gun 5:
- UI polish: onboarding, bos durumlar, butce uyarilari, liste filtreleri.
- Manual QA turu 1.

Gun 6:
- Test kapsamini genislet.
- Android release build ve cihaz testi.

Gun 7:
- Store listing, screenshot seti, feature graphic.
- Kapali test track hazirligi.

## Nihai Yayin Kapisi

Yayina cikmadan once hepsi evet olmali:

- Android/iOS platform dosyalari var.
- Android appbundle uretiliyor.
- `flutter analyze` temiz.
- `flutter test` temiz.
- Mock premium production'da yok.
- AdMob test ID release'de yok.
- Privacy policy URL hazir.
- Data Safety/App Privacy beyanlari hazir.
- En az 5 screenshot hazir.
- Cihazda manuel QA tamam.
- Reset/export/fotoğraf/davetli/checklist akislari calisiyor.

## 22 Temmuz 2026 Ek Ilerleme

Tamamlananlar:

- Rakip analizinde one cikan "smart checklist / this week / next best action" yaklasimi MVP'ye uyarlandi.
- `WeeklyPlanAction` motoru eklendi; tarih, kritik eksikler, pahali kalemler, butce riski ve davetli belirsizligi uzerinden haftalik plan uretiyor.
- Ana ekrana `Bu haftanin plani` girisi eklendi.
- `Bu Haftanin Plani` sayfasi eklendi.
- Onboarding daha net deger vaadiyle yenilendi.
- Ana ekran, oncelik ekrani, settings ve temel etiketlerde bozuk karakterler temizlendi.
- Haftalik plan icin unit testler eklendi.
- AdMob unit id yapisi `--dart-define` destekli hale getirildi.
- Release build'de AdMob unit id'ler bos kalirsa reklam request'i atilmaz.

Production AdMob build ornegi:

```bash
flutter build appbundle \
  --dart-define=ADMOB_BANNER_UNIT_ID=... \
  --dart-define=ADMOB_INTERSTITIAL_UNIT_ID=... \
  --dart-define=ADMOB_REWARDED_UNIT_ID=...
```

Halen gerekenler:

- Native Android/iOS AdMob app id placeholder'lari gercek AdMob app id ile degistirilmeli.
- Production signing key kurulumu tamamlanmali.
- App icon ve splash template olmaktan cikarilmali.
