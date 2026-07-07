import 'package:flutter/material.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/formatters.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/item_tile.dart';

enum ItemFilter { all, missing, completed, mustHave, necessary, later, luxury }

extension ItemFilterText on ItemFilter {
  String get label => switch (this) {
        ItemFilter.all => 'Tümü',
        ItemFilter.missing => 'Alınmadı',
        ItemFilter.completed => 'Alındı',
        ItemFilter.mustHave => 'Olmazsa Olmaz',
        ItemFilter.necessary => 'Gerekli',
        ItemFilter.later => 'Sonra Alınabilir',
        ItemFilter.luxury => 'Lüks',
      };
}

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key, required this.category});

  final MainCategory category;

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  ItemFilter filter = ItemFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).ads.maybeShowCategoryInterstitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final items = controller.items
        .where((item) => item.mainCategory == widget.category)
        .where(_matchesFilter)
        .toList()
      ..sort((a, b) {
        final priority = a.priority.sortOrder.compareTo(b.priority.sortOrder);
        if (priority != 0) return priority;
        return a.title.compareTo(b.title);
      });

    final subCategories = controller.items
        .where((item) => item.mainCategory == widget.category)
        .map((item) => item.subCategory)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.label)),
      bottomNavigationBar: const AdBannerWidget(),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              children: [
                for (final option in ItemFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(option.label),
                      selected: filter == option,
                      onSelected: (_) => setState(() => filter = option),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.category == MainCategory.ceyiz)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subCategories.join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF6F6470)),
                ),
              ),
            ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Bu filtrede ürün yok'))
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ItemTile(
                        item: item,
                        onTap: () => _showDetail(item),
                        onCheckboxChanged: (_) => _toggleItem(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _matchesFilter(PrepItem item) => switch (filter) {
        ItemFilter.all => true,
        ItemFilter.missing => !item.isCompleted,
        ItemFilter.completed => item.isCompleted,
        ItemFilter.mustHave => item.priority == ItemPriority.mustHave,
        ItemFilter.necessary => item.priority == ItemPriority.necessary,
        ItemFilter.later => item.priority == ItemPriority.later,
        ItemFilter.luxury => item.priority == ItemPriority.luxury,
      };

  Future<void> _toggleItem(PrepItem item) async {
    final controller = AppScope.of(context);
    if (item.isCompleted) {
      await controller.uncompleteItem(item);
      return;
    }
    final price = await showModalBottomSheet<double?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PriceSheet(item: item),
    );
    if (!mounted) return;
    await controller.completeItem(item, actualPrice: price);
  }

  Future<void> _showDetail(PrepItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ItemDetailSheet(item: item),
    );
  }
}

class _PriceSheet extends StatefulWidget {
  const _PriceSheet({required this.item});

  final PrepItem item;

  @override
  State<_PriceSheet> createState() => _PriceSheetState();
}

class _PriceSheetState extends State<_PriceSheet> {
  final priceController = TextEditingController();

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ne kadara aldın?',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(widget.item.title),
          const SizedBox(height: 16),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Tutar'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Boş bırak'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(context, parseMoney(priceController.text)),
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemDetailSheet extends StatefulWidget {
  const _ItemDetailSheet({required this.item});

  final PrepItem item;

  @override
  State<_ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<_ItemDetailSheet> {
  late bool completed;
  late ItemPriority priority;
  late final TextEditingController estimatedController;
  late final TextEditingController actualController;
  late final TextEditingController shopController;
  late final TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    completed = widget.item.isCompleted;
    priority = widget.item.priority;
    estimatedController = TextEditingController(
        text: widget.item.estimatedPrice.toStringAsFixed(0));
    actualController =
        TextEditingController(text: widget.item.actualPrice.toStringAsFixed(0));
    shopController = TextEditingController(text: widget.item.shopName);
    noteController = TextEditingController(text: widget.item.note);
  }

  @override
  void dispose() {
    estimatedController.dispose();
    actualController.dispose();
    shopController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              value: completed,
              onChanged: (value) => setState(() => completed = value),
              title: const Text('Alındı mı?'),
              contentPadding: EdgeInsets.zero,
            ),
            DropdownButtonFormField<ItemPriority>(
              initialValue: priority,
              decoration: const InputDecoration(labelText: 'Öncelik'),
              items: [
                for (final option in ItemPriority.values)
                  DropdownMenuItem(value: option, child: Text(option.label)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => priority = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: estimatedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tahmini fiyat'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: actualController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Gerçek fiyat'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: shopController,
              decoration: const InputDecoration(labelText: 'Nereden alındı?'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Not'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final controller = AppScope.of(context);
    await controller.updateItem(widget.item.copyWith(
      priority: priority,
      isCompleted: completed,
      estimatedPrice: parseMoney(estimatedController.text),
      actualPrice: parseMoney(actualController.text),
      shopName: shopController.text.trim(),
      note: noteController.text.trim(),
      completedDate:
          completed ? widget.item.completedDate ?? DateTime.now() : null,
      clearCompletedDate: !completed,
    ));
    if (mounted) Navigator.pop(context);
  }
}
