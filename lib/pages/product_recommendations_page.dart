import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/affiliate_links.dart';
import '../main.dart';
import '../theme/app_colors.dart';

class ProductRecommendationsPage extends StatelessWidget {
  const ProductRecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Önerileri')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Fiyatlara bak, bütçeni ezmeden eksikleri sıraya al.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          for (final category in affiliateCategories)
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.rose,
                ),
                title: Text(
                  category.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: category.url.isEmpty
                    ? const Chip(label: Text('Yakında'))
                    : const Icon(Icons.open_in_new),
                onTap: category.url.isEmpty
                    ? null
                    : () => _open(context, category.title, category.url),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, String source, String url) async {
    AppScope.of(context).analytics.affiliateClicked(source: source, url: url);
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
