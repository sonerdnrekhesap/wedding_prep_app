class AffiliateCategory {
  const AffiliateCategory({
    required this.title,
    required this.description,
    required this.url,
  });

  final String title;
  final String description;
  final String url;
}

const affiliateCategories = [
  AffiliateCategory(
    title: 'Mutfak ürünleri',
    description: 'Tencere, yemek takımı, bardak ve küçük mutfak ihtiyaçları.',
    url: '',
  ),
  AffiliateCategory(
    title: 'Beyaz eşya',
    description: 'Buzdolabı, çamaşır makinesi, bulaşık makinesi paketleri.',
    url: '',
  ),
  AffiliateCategory(
    title: 'Ev tekstili',
    description: 'Nevresim, havlu, bornoz, perde ve halı önerileri.',
    url: '',
  ),
  AffiliateCategory(
    title: 'Bohça ürünleri',
    description: 'Gelin ve damat bohçası için pratik öneriler.',
    url: '',
  ),
  AffiliateCategory(
    title: 'Düğün hazırlığı',
    description: 'Davetiye, organizasyon, fotoğraf ve aksesuar fikirleri.',
    url: '',
  ),
  AffiliateCategory(
    title: 'Balayı ürünleri',
    description: 'Valiz, seyahat bakım ürünleri ve tatil hazırlıkları.',
    url: '',
  ),
];

String affiliateUrlForItemTitle(String title) {
  final lower = title.toLowerCase();
  if (lower.contains('buzdolabı') ||
      lower.contains('çamaşır') ||
      lower.contains('bulaşık')) {
    return '';
  }
  if (lower.contains('tencere') || lower.contains('yemek takımı')) {
    return '';
  }
  return '';
}
