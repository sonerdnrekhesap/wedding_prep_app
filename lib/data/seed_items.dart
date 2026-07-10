import '../models/app_settings_model.dart';
import '../models/guest_model.dart';
import '../models/item_model.dart';

AppSettings buildDemoSettings() {
  return AppSettings(
    weddingDate: DateTime(2026, 9, 12),
    targetBudget: 650000,
    brideName: 'Elif',
    groomName: 'Mert',
    hasCompletedOnboarding: true,
  );
}

List<Guest> buildDemoGuests() {
  final now = DateTime.now();
  return [
    Guest(
      id: 'demo-guest-1',
      name: 'Ayse Yilmaz',
      phone: '05xx xxx xx xx',
      side: GuestSide.bride,
      guestCount: 2,
      status: GuestStatus.coming,
      note: 'Gelin tarafi yakin aile.',
      createdAt: now,
      updatedAt: now,
    ),
    Guest(
      id: 'demo-guest-2',
      name: 'Mehmet Demir',
      phone: '05xx xxx xx xx',
      side: GuestSide.groom,
      guestCount: 3,
      status: GuestStatus.coming,
      note: 'Damat tarafi aile.',
      createdAt: now,
      updatedAt: now,
    ),
    Guest(
      id: 'demo-guest-3',
      name: 'Zeynep Kaya',
      side: GuestSide.common,
      guestCount: 2,
      status: GuestStatus.uncertain,
      note: 'Sehir disindan gelecek.',
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

List<PrepItem> buildSeedItems() {
  final now = DateTime.now();
  var index = 0;

  PrepItem item(String title, MainCategory category, String subCategory) {
    index += 1;
    return PrepItem(
      id: 'seed-$index',
      title: title,
      mainCategory: category,
      subCategory: subCategory,
      priority: _priorityFor(title, subCategory),
      estimatedPrice: _estimateFor(title),
      dueDate: _dueDateFor(category, subCategory),
      createdAt: now,
      updatedAt: now,
    );
  }

  Iterable<PrepItem> itemsFor(
    MainCategory category,
    String subCategory,
    List<String> titles,
  ) {
    return titles.map((title) => item(title, category, subCategory));
  }

  final items = <PrepItem>[
    ...itemsFor(MainCategory.ceyiz, 'Olmazsa Olmazlar', [
      'Buzdolabi',
      'Bulasik makinesi',
      'Camasir makinesi',
      'Firin',
      'Ocak',
      'Elektrikli supurge',
      'Utu',
      'Utu masasi',
      'Yatak',
      'Yorgan',
      'Yastik',
      'Günlük yemek takımı',
      'Catal kasik bicak seti',
      'Tencere seti',
      'Tava seti',
      'Havlu setleri',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Mutfak', [
      'Mikrodalga',
      'Tost makinesi',
      'Kahve makinesi',
      'Cay makinesi',
      'Blender',
      'Mikser',
      'Su isiticisi',
      'Bicak seti',
      'Kesme tahtasi',
      'Saklama kaplari',
      'Baharatlik',
      'Cop kovasi',
      'Mutfak masasi',
      'Sandalyeler',
      'Mutfak halisi',
      'Mutfak perdesi',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Elektronik Ev Esyalari', [
      'Kurutma makinesi',
      'Davlumbaz',
      'Robot supurge',
      'Airfryer',
      'Televizyon',
      'Sac kurutma makinesi',
      'Tarti',
      'Su sebili',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Yatak Odasi', [
      'Baza',
      'Baslik',
      'Nevresim takimi',
      'Pike takimi',
      'Battaniye',
      'Gardirob',
      'Komodin',
      'Sifonyer',
      'Perde',
      'Hali',
      'Aydinlatma',
      'Camasir sepeti',
      'Yatak ortusu',
      'Askilar',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Banyo', [
      'Bornoz seti',
      'Banyo paspasi',
      'Dus perdesi',
      'Sabunluk',
      'Dis fircalik',
      'Kirli sepeti',
      'Duzenleyiciler',
      'Temizlik malzemeleri',
      'Banyo dolabi',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Salon / Oturma Odasi', [
      'Koltuk',
      'Yemek masasi',
      'Sandalye',
      'TV unitesi',
      'Sehpa',
      'Hali',
      'Perde',
      'Aydinlatma',
      'Misafir tekstili',
      'Konsol',
      'Ayna',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Hol / Antre', [
      'Portmanto',
      'Ayakkabilik',
      'Antre aynasi',
      'Yolluk',
      'Anahtarlik',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Temizlik', [
      'Temizlik kovasi',
      'Mop seti',
      'Cam silme aparati',
      'Deterjan stoklari',
      'Camasir kurutmalik',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Sofra Urunleri', [
      'Misafir yemek takimi',
      'Kahvalti takimi',
      'Bardak setleri',
      'Servis tabaklari',
      'Tepsi',
      'Masa ortusu',
      'Runner',
      'Cerezlik',
      'Sosluk',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Tekstil', [
      'Yedek nevresim',
      'Yedek pike',
      'Mutfak havlusu',
      'Misafir havlusu',
      'Koltuk sali',
      'Yatak alezi',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Dekorasyon', [
      'Dekoratif tablo',
      'Vazo',
      'Kirlent',
      'Abajur',
      'Duvar saati',
      'Cerceveler',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Diger Ev Ihtiyaclari', [
      'Alet cantasi',
      'Ilk yardim kutusu',
      'Uzatma kablosu',
      'Yedek ampul',
      'Dikis kutusu',
    ]),
    ...itemsFor(MainCategory.bohca, 'Gelin Bohcasi', [
      'Pijama',
      'Gecelik',
      'Terlik',
      'Ic giyim',
      'Havlu',
      'Bornoz',
      'Parfum',
      'Kisisel bakim urunleri',
    ]),
    ...itemsFor(MainCategory.bohca, 'Damat Bohcasi', [
      'Gomlek',
      'Kemer',
      'Cuzdan',
      'Tiras seti',
      'Saat',
      'Corap',
      'Pijama takimi',
      'Parfum',
    ]),
    ...itemsFor(MainCategory.bohca, 'Aile Bohcalari', [
      'Anne bohca hediyesi',
      'Baba bohca hediyesi',
      'Kardes bohca hediyesi',
      'Aile havlu seti',
    ]),
    ...itemsFor(MainCategory.bohca, 'Sunum ve Susleme', [
      'Bohca kutusu',
      'Susleme kurdelesi',
      'Cikolata sunumu',
      'Cicek aranjmani',
    ]),
    ...eventItems(MainCategory.soz),
    ...eventItems(MainCategory.nisan),
    ...eventItems(MainCategory.kina),
    ...eventItems(MainCategory.dugun),
    ...itemsFor(MainCategory.balayi, 'Pasaport', [
      'Pasaport kontrolu',
      'Pasaport yenileme randevusu',
    ]),
    ...itemsFor(MainCategory.balayi, 'Vize', [
      'Vize basvurusu',
      'Vize evraklari',
    ]),
    ...itemsFor(MainCategory.balayi, 'Kimlik ve Ehliyet', [
      'Kimlik kontrolu',
      'Ehliyet kontrolu',
      'Fotokopi dosyasi',
    ]),
    ...itemsFor(MainCategory.balayi, 'Ucak / Tren / Otobus', [
      'Ulasim bileti',
      'Bilet saat kontrolu',
    ]),
    ...itemsFor(MainCategory.balayi, 'Otel', [
      'Otel rezervasyonu',
      'Otel odeme kontrolu',
    ]),
    ...itemsFor(MainCategory.balayi, 'Transfer', [
      'Havalimani transferi',
      'Sehir ici transfer planı',
    ]),
    ...itemsFor(MainCategory.balayi, 'Seyahat Sigortasi', [
      'Seyahat sigortasi',
      'Sigorta police ciktilari',
    ]),
    ...itemsFor(MainCategory.balayi, 'Bavul', [
      'Bavul listesi',
      'Sarj cihazi',
      'Adaptor',
      'Tatil kiyafetleri',
      'Ilaclar',
      'Gunes kremi',
    ]),
    ...itemsFor(MainCategory.balayi, 'Para ve Kartlar', [
      'Doviz',
      'Kart limiti kontrolu',
      'Nakit para',
    ]),
    ...itemsFor(MainCategory.balayi, 'Rezervasyon Belgeleri', [
      'Rezervasyon ciktilari',
      'Acil durum numaralari',
    ]),
    ...itemsFor(MainCategory.balayi, 'Aktivite Plani', [
      'Aktivite rezervasyonlari',
      'Restoran notlari',
      'Gunluk gezi plani',
    ]),
  ];

  return _withDemoProgress(items);
}

Iterable<PrepItem> eventItems(MainCategory category) sync* {
  final map = <String, List<String>>{
    'Mekan': [
      _eventName(category, 'mekan rezervasyonu'),
      'Mekan odeme plani',
      'Mekan sozlesmesi',
    ],
    'Kiyafet': [
      category == MainCategory.dugun ? 'Gelinlik' : 'Kiyafet secimi',
      category == MainCategory.dugun ? 'Damatlik' : 'Ayakkabi',
      'Terzi provasi',
    ],
    'Taki': [
      'Alyans',
      'Taki kurdelesi',
      'Taki kutusu',
    ],
    'Organizasyon': [
      'Organizasyon firmasi',
      'Masa susleme',
      'Cicek ve dekor',
    ],
    'Fotograf / Video': [
      'Fotografci',
      'Video cekimi',
      'Dis cekim planı',
    ],
    'Davetli': [
      'Davetli listesi',
      'Oturma plani',
      'Konaklama ihtiyaci',
    ],
    'Ikram': [
      'Menu secimi',
      'Pasta',
      'Cikolata / ikramlik',
    ],
    'Muzik': [
      'Muzik / DJ',
      'Ilk dans muzigi',
      'Ses sistemi kontrolu',
    ],
    'Ulasim': [
      'Gelin arabasi',
      'Misafir ulasim plani',
      'Otopark bilgisi',
    ],
    'Odeme ve Kaporalar': [
      'Kapora odemesi',
      'Ara odeme takibi',
      'Son odeme',
    ],
    'Resmi Islemler': [
      'Nikah tarihi',
      'Nikah evraklari',
      'Saglik raporu',
    ],
    'Son Kontroller': [
      'Acil durum cantasi',
      'Son prova',
      'Tedarikci teyitleri',
    ],
  };
  final now = DateTime.now();
  var localIndex = 0;
  for (final entry in map.entries) {
    for (final title in entry.value) {
      localIndex += 1;
      yield PrepItem(
        id: 'seed-${category.name}-$localIndex',
        title: title,
        mainCategory: category,
        subCategory: entry.key,
        priority: _priorityFor(title, entry.key),
        estimatedPrice: _estimateFor(title),
        dueDate: _dueDateFor(category, entry.key),
        paymentDeadline:
            entry.key == 'Odeme ve Kaporalar' ? _dueDateFor(category, entry.key) : null,
        createdAt: now,
        updatedAt: now,
      );
    }
  }
}

String _eventName(MainCategory category, String suffix) {
  return switch (category) {
    MainCategory.soz => 'Soz $suffix',
    MainCategory.nisan => 'Nisan $suffix',
    MainCategory.kina => 'Kina $suffix',
    MainCategory.dugun => 'Dugun $suffix',
    _ => suffix,
  };
}

ItemPriority _priorityFor(String title, String subCategory) {
  final text = '$title $subCategory'.toLowerCase();
  if (_containsAny(text, [
    'olmazsa',
    'buzdolabi',
    'camasir makinesi',
    'bulasik makinesi',
    'yatak',
    'mekan',
    'nikah',
    'pasaport',
    'vize',
    'son odeme',
    'kapora',
    'alyans',
  ])) {
    return ItemPriority.mustHave;
  }
  if (_containsAny(text, [
    'dekorasyon',
    'aktivite',
    'abajur',
    'vazo',
    'robot',
    'airfryer',
  ])) {
    return ItemPriority.later;
  }
  if (_containsAny(text, ['su sebili', 'ikinci', 'ekstra'])) {
    return ItemPriority.luxury;
  }
  return ItemPriority.necessary;
}

bool _containsAny(String text, List<String> needles) {
  return needles.any(text.contains);
}

double _estimateFor(String title) {
  const estimates = <String, double>{
    'Buzdolabi': 42000,
    'Camasir makinesi': 26000,
    'Bulasik makinesi': 24000,
    'Kurutma makinesi': 28000,
    'Firin': 18000,
    'Ocak': 12000,
    'Davlumbaz': 9000,
    'Elektrikli supurge': 13000,
    'Robot supurge': 22000,
    'Televizyon': 25000,
    'Yatak': 22000,
    'Koltuk': 68000,
    'Yemek masasi': 32000,
    'Gelinlik': 55000,
    'Damatlik': 22000,
    'Fotografci': 32000,
    'Video cekimi': 18000,
    'Muzik / DJ': 28000,
    'Organizasyon firmasi': 45000,
    'Alyans': 38000,
    'Otel rezervasyonu': 50000,
    'Ulasim bileti': 24000,
  };
  return estimates[title] ?? 0;
}

DateTime? _dueDateFor(MainCategory category, String subCategory) {
  final now = DateTime.now();
  return switch (category) {
    MainCategory.dugun when subCategory == 'Mekan' =>
      now.add(const Duration(days: 30)),
    MainCategory.dugun when subCategory == 'Odeme ve Kaporalar' =>
      now.add(const Duration(days: 14)),
    MainCategory.balayi when subCategory == 'Pasaport' =>
      now.add(const Duration(days: 21)),
    MainCategory.balayi when subCategory == 'Vize' =>
      now.add(const Duration(days: 28)),
    _ => null,
  };
}

List<PrepItem> _withDemoProgress(List<PrepItem> items) {
  final completedItems = <String, ({double actualPrice, String shopName})>{
    'Tencere seti': (actualPrice: 6200, shopName: 'Karaca'),
    'Tava seti': (actualPrice: 3400, shopName: 'Emsan'),
    'Kahvalti takimi': (actualPrice: 5200, shopName: 'English Home'),
    'Nevresim takimi': (actualPrice: 2600, shopName: 'Madame Coco'),
    'Havlu setleri': (actualPrice: 2400, shopName: 'Ozdilek'),
    'Bornoz seti': (actualPrice: 4200, shopName: 'Ozdilek'),
    'Alyans': (actualPrice: 18500, shopName: 'Kuyumcu'),
    'Davetli listesi': (actualPrice: 0, shopName: ''),
    'Dugun mekan rezervasyonu': (actualPrice: 95000, shopName: 'Salon kapora'),
    'Fotografci': (actualPrice: 18000, shopName: 'Foto studyo kapora'),
    'Gelinlik': (actualPrice: 38000, shopName: 'Moda evi kapora'),
  };

  return [
    for (final item in items)
      item.copyWith(
        actualPrice:
            completedItems[item.title]?.actualPrice ?? item.actualPrice,
        shopName: completedItems[item.title]?.shopName ?? item.shopName,
        vendorName: completedItems[item.title]?.shopName ?? item.vendorName,
        isCompleted: completedItems.containsKey(item.title),
        completedDate: completedItems.containsKey(item.title)
            ? DateTime(2026, 7, 1)
            : item.completedDate,
      ),
  ];
}
