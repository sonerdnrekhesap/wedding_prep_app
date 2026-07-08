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
  return const [
    Guest(
      id: 'demo-guest-1',
      name: 'Ayşe Yılmaz',
      phone: '05xx xxx xx xx',
      side: GuestSide.bride,
      personCount: 2,
      status: GuestStatus.coming,
      note: 'Gelin tarafı yakın aile.',
    ),
    Guest(
      id: 'demo-guest-2',
      name: 'Mehmet Demir',
      phone: '05xx xxx xx xx',
      side: GuestSide.groom,
      personCount: 3,
      status: GuestStatus.coming,
      note: 'Damat tarafı aile.',
    ),
    Guest(
      id: 'demo-guest-3',
      name: 'Zeynep Kaya',
      side: GuestSide.common,
      personCount: 2,
      status: GuestStatus.unsure,
      note: 'Şehir dışından gelecek.',
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
      priority: _priorityFor(title),
      estimatedPrice: _estimateFor(title),
      createdAt: now,
      updatedAt: now,
    );
  }

  List<PrepItem> itemsFor(
    MainCategory category,
    String subCategory,
    List<String> titles,
  ) {
    return titles.map((title) => item(title, category, subCategory)).toList();
  }

  final items = [
    ...itemsFor(MainCategory.ceyiz, 'Bardaklar', [
      'Günlük su bardağı',
      'Misafir su bardağı',
      'Günlük çay bardağı',
      'Misafir çay bardağı',
      'Türk kahvesi fincan takımı',
      'Günlük kupa',
      'Meşrubat bardağı',
      'Limonata bardağı',
      'Sürahi',
      'Misafir sürahi',
      'Bardak altlığı',
      'Kadeh seti',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Yemek Takımları', [
      'Günlük yemek takımı',
      'Misafir yemek takımı',
      'Kahvaltı takımı',
      'Günlük servis tabağı',
      'Misafir servis tabağı',
      'Pasta takımı',
      'Çorba kasesi',
      'Salata kasesi',
      'Kayık tabak',
      'Sunum tabağı',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Çatal Kaşık Bıçak', [
      'Günlük çatal kaşık bıçak seti',
      'Misafir çatal kaşık bıçak seti',
      'Bıçak seti',
      'Tatlı kaşığı',
      'Çay kaşığı',
      'Servis kaşığı',
      'Kepçe seti',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Pişirme Ürünleri', [
      'Tencere seti',
      'Tava seti',
      'Düdüklü tencere',
      'Çaydanlık',
      'Cezve',
      'Kek kalıbı',
      'Borcam seti',
      'Fırın kabı',
      'Kesme tahtası',
      'Rende',
      'Süzgeç',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Saklama ve Düzen', [
      'Saklama kabı seti',
      'Baharatlık',
      'Kavanoz seti',
      'Ekmek kutusu',
      'Buzdolabı düzenleyici',
      'Çekmece düzenleyici',
      'Erzak kabı',
      'Yağdanlık',
      'Sirkelik',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Sunum Ürünleri', [
      'Servis tabağı',
      'Tepsi',
      'Çerezlik',
      'Sosluk',
      'Şekerlik',
      'Lokumluk',
      'Sunum kasesi',
      'Salata servis seti',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Mutfak Tekstili', [
      'Mutfak havlusu',
      'Masa örtüsü',
      'Amerikan servis',
      'Runner',
      'Önlük',
      'Fırın eldiveni',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Temizlik ve Tezgah', [
      'Bulaşıklık',
      'Sabunluk',
      'Süngerlik',
      'Çöp kovası',
      'Lavabo süzgeci',
      'Kesme tahtası standı',
      'Tezgah düzenleyici',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Beyaz Eşya / Elektronik', [
      'Buzdolabı',
      'Çamaşır makinesi',
      'Bulaşık makinesi',
      'Ocak',
      'Fırın',
      'Davlumbaz',
      'Elektrikli süpürge',
      'Ütü',
      'Ütü masası',
      'Televizyon',
      'Mikrodalga fırın',
      'Airfryer',
      'Kahve makinesi',
      'Tost makinesi',
      'Blender seti',
      'Robot süpürge',
      'Kurutma makinesi',
      'Su sebili',
      'Saç kurutma makinesi',
      'Tartı',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Yatak Odası', [
      'Yatak',
      'Baza',
      'Başlık',
      'Gardırop',
      'Komodin',
      'Şifonyer',
      'Nevresim takımı',
      'Yorgan',
      'Yastık',
      'Pike',
      'Battaniye',
      'Alez',
      'Perde',
      'Halı',
      'Avize',
      'Makyaj masası',
      'Askı',
      'Hurç',
      'Yatak örtüsü',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Banyo', [
      'Havlu seti',
      'Bornoz takımı',
      'Banyo paspası',
      'Çamaşır sepeti',
      'Diş fırçalık',
      'Sabunluk',
      'Duş perdesi',
      'Banyo dolabı',
      'Temizlik kovası',
      'Banyo rafı',
      'Tuvalet fırçası',
      'Sıvı sabunluk',
      'Kirli sepeti',
    ]),
    ...itemsFor(MainCategory.ceyiz, 'Salon / Oturma Odası', [
      'Koltuk takımı',
      'TV ünitesi',
      'Orta sehpa',
      'Yan sehpa',
      'Halı',
      'Perde',
      'Avize',
      'Yemek masası',
      'Sandalye',
      'Konsol',
      'Vitrin',
      'Ayna',
      'Dekoratif ürünler',
      'Kırlent',
      'Abajur',
      'Kitaplık',
    ]),
    ...itemsFor(MainCategory.bohca, 'Bohça', [
      'Gelin bohçası',
      'Damat bohçası',
      'Pijama takımı',
      'Terlik',
      'Havlu',
      'Parfüm',
      'İç giyim',
      'Cilt bakım ürünleri',
      'Traş seti',
      'Takı kutusu',
      'Çanta',
      'Ayakkabı',
    ]),
    ...itemsFor(MainCategory.soz, 'Söz', [
      'Söz yüzükleri',
      'Söz tepsisi',
      'Söz çikolatası',
      'Çiçek',
      'Kıyafet',
      'Kuaför',
      'Makyaj',
      'Fotoğraf',
      'Aile ikramları',
      'Ev süslemesi',
    ]),
    ...itemsFor(MainCategory.nisan, 'Nişan', [
      'Nişan mekanı',
      'Nişan elbisesi',
      'Damat kıyafeti',
      'Nişan pastası',
      'Organizasyon',
      'Fotoğrafçı',
      'Davetli listesi',
      'İkramlar',
      'Masa süsleme',
      'Takı kurdelesi',
      'Kuaför',
      'Makyaj',
    ]),
    ...itemsFor(MainCategory.kina, 'Kına', [
      'Kına mekanı',
      'Bindallı',
      'Kına elbisesi',
      'Kına tepsisi',
      'Kına malzemeleri',
      'Organizasyon',
      'Müzik',
      'Fotoğrafçı',
      'Nedime aksesuarları',
      'İkramlar',
      'Kuaför',
      'Makyaj',
    ]),
    ...itemsFor(MainCategory.dugun, 'Düğün', [
      'Düğün salonu',
      'Nikah tarihi',
      'Gelinlik',
      'Damatlık',
      'Gelin ayakkabısı',
      'Damat ayakkabısı',
      'Fotoğrafçı',
      'Video çekimi',
      'Davetiye',
      'Kuaför',
      'Makyaj',
      'Gelin arabası',
      'Çiçek',
      'Pasta',
      'Müzik / DJ',
      'Organizasyon',
      'Takı kurdelesi',
      'Nikah şekeri',
      'Düğün dansı',
      'Oturma planı',
    ]),
    ...itemsFor(MainCategory.balayi, 'Balayı', [
      'Pasaport',
      'Vize',
      'Kimlik / ehliyet',
      'Uçak bileti',
      'Otel rezervasyonu',
      'Seyahat sigortası',
      'Valiz',
      'Tatil kıyafetleri',
      'Mayo / bikini',
      'Şarj aleti',
      'Powerbank',
      'İlaçlar',
      'Güneş kremi',
      'Nakit para',
      'Kredi kartı',
    ]),
  ];

  return _withDemoProgress(items);
}

ItemPriority _priorityFor(String title) {
  final text = title.toLowerCase();
  if (_containsAny(text, [
    'buzdolabı',
    'çamaşır makinesi',
    'yatak',
    'yorgan',
    'yastık',
    'nevresim',
    'günlük yemek',
    'günlük çatal',
    'günlük su bardağı',
    'günlük çay bardağı',
    'tencere seti',
    'tava seti',
    'havlu seti',
    'temizlik kovası',
    'ocak',
  ])) {
    return ItemPriority.mustHave;
  }
  if (_containsAny(text, [
    'televizyon',
    'büyük tv',
    'bulaşık makinesi',
    'elektrikli süpürge',
    'ütü',
    'ütü masası',
    'perde',
    'halı',
    'banyo paspası',
    'gardırop',
    'koltuk takımı',
    'yemek masası',
    'sandalye',
    'avize',
    'komodin',
    'banyo dolabı',
  ])) {
    return ItemPriority.necessary;
  }
  if (_containsAny(text, [
    'robot süpürge',
    'kurutma makinesi',
    'su sebili',
    'vitrin',
    'ikinci televizyon',
    'dekoratif koleksiyon',
  ])) {
    return ItemPriority.luxury;
  }
  if (_containsAny(text, [
    'airfryer',
    'kahve makinesi',
    'tost makinesi',
    'mikrodalga',
    'misafir',
    'pasta takımı',
    'dekoratif',
    'kırlent',
    'abajur',
    'sunum',
  ])) {
    return ItemPriority.later;
  }
  return ItemPriority.necessary;
}

bool _containsAny(String text, List<String> needles) {
  return needles.any(text.contains);
}

double _estimateFor(String title) {
  const estimates = <String, double>{
    'Buzdolabı': 42000,
    'Çamaşır makinesi': 26000,
    'Bulaşık makinesi': 24000,
    'Televizyon': 25000,
    'Koltuk takımı': 68000,
    'Yatak': 22000,
    'Gardırop': 36000,
    'Düğün salonu': 190000,
    'Gelinlik': 55000,
    'Damatlık': 22000,
    'Fotoğrafçı': 32000,
    'Video çekimi': 18000,
    'Müzik / DJ': 28000,
    'Organizasyon': 45000,
    'Otel rezervasyonu': 50000,
    'Uçak bileti': 24000,
  };
  return estimates[title] ?? 0;
}

List<PrepItem> _withDemoProgress(List<PrepItem> items) {
  final completedItems = <String, ({double actualPrice, String shopName})>{
    'Tencere seti': (actualPrice: 6200, shopName: 'Karaca'),
    'Tava seti': (actualPrice: 3400, shopName: 'Emsan'),
    'Kahvaltı takımı': (actualPrice: 5200, shopName: 'English Home'),
    'Günlük su bardağı': (actualPrice: 1800, shopName: 'Paşabahçe'),
    'Nevresim takımı': (actualPrice: 2600, shopName: 'Madame Coco'),
    'Havlu seti': (actualPrice: 2400, shopName: 'Özdilek'),
    'Bornoz takımı': (actualPrice: 4200, shopName: 'Özdilek'),
    'Söz yüzükleri': (actualPrice: 18500, shopName: 'Kuyumcu'),
    'Söz tepsisi': (actualPrice: 1450, shopName: 'Butik tasarım'),
    'Çiçek': (actualPrice: 1800, shopName: 'Mahalle çiçekçisi'),
    'Nişan elbisesi': (actualPrice: 12500, shopName: 'Moda evi'),
    'Davetiye': (actualPrice: 3900, shopName: 'Matbaa'),
    'Düğün salonu': (actualPrice: 95000, shopName: 'Salon kapora'),
    'Fotoğrafçı': (actualPrice: 18000, shopName: 'Foto stüdyo kapora'),
    'Gelinlik': (actualPrice: 38000, shopName: 'Moda evi kapora'),
  };

  return [
    for (final item in items)
      item.copyWith(
        actualPrice:
            completedItems[item.title]?.actualPrice ?? item.actualPrice,
        shopName: completedItems[item.title]?.shopName ?? item.shopName,
        isCompleted: completedItems.containsKey(item.title),
        completedDate: completedItems.containsKey(item.title)
            ? DateTime(2026, 7, 1)
            : item.completedDate,
      ),
  ];
}
