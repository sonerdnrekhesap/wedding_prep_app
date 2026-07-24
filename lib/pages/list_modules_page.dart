import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../widgets/ad_banner_widget.dart';
import 'guest_list_page.dart';
import 'item_list_page.dart';

class ListModulesPage extends StatelessWidget {
  const ListModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listeler')),
      bottomNavigationBar: const AdBannerWidget(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final category in MainCategory.values)
            _ModuleTile(
              title: category.label,
              icon: _iconFor(category),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ItemListPage(category: category),
              )),
            ),
          _ModuleTile(
            title: 'Davetliler',
            icon: Icons.groups_outlined,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const GuestListPage(),
            )),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(MainCategory category) => switch (category) {
        MainCategory.ceyiz => Icons.kitchen_outlined,
        MainCategory.bohca => Icons.card_giftcard_outlined,
        MainCategory.soz => Icons.diamond_outlined,
        MainCategory.nisan => Icons.celebration_outlined,
        MainCategory.kina => Icons.local_florist_outlined,
        MainCategory.dugun => Icons.favorite_border,
        MainCategory.balayi => Icons.flight_takeoff_outlined,
      };
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFE84A7A)),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
