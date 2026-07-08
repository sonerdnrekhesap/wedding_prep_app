import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/formatters.dart';
import '../theme/app_colors.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/item_tile.dart';
import '../widgets/visual_cards.dart';

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
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).ads.maybeShowCategoryInterstitial();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final items = controller.items
        .where((item) => item.mainCategory == widget.category)
        .where(_matchesFilter)
        .where(_matchesSearch)
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemSheet,
        icon: const Icon(Icons.add),
        label: const Text('Ürün'),
      ),
      bottomNavigationBar: const AdBannerWidget(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Ürün ara',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
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
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: EmptyStateCard(
                        icon: Icons.inventory_2_outlined,
                        title: 'Bu listede ürün yok',
                        message:
                            'Filtreyi değiştirebilir veya kendi ürününü ekleyebilirsin.',
                      ),
                    ),
                  )
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

  bool _matchesSearch(PrepItem item) {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return item.title.toLowerCase().contains(query) ||
        item.subCategory.toLowerCase().contains(query);
  }

  Future<void> _toggleItem(PrepItem item) async {
    final controller = AppScope.of(context);
    if (item.isCompleted) {
      await controller.uncompleteItem(item);
      return;
    }

    await controller.completeItem(item);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Expanded(child: Text('Alındı olarak işaretlendi')),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _showQuickPriceSheet(item);
              },
              child: const Text('Tutar ekle'),
            ),
            TextButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                await controller.uncompleteItem(item);
              },
              child: const Text('Geri al'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuickPriceSheet(PrepItem item) async {
    final controller = AppScope.of(context);
    final current = controller.items.firstWhere(
      (current) => current.id == item.id,
      orElse: () => item,
    );
    final price = await showModalBottomSheet<double?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PriceSheet(item: current),
    );
    if (!mounted || price == null) return;
    await controller.updateItem(current.copyWith(actualPrice: price));
  }

  Future<void> _showDetail(PrepItem item) async {
    final controller = AppScope.of(context);
    final current = controller.items.firstWhere(
      (current) => current.id == item.id,
      orElse: () => item,
    );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ItemDetailSheet(item: current),
    );
  }

  Future<void> _showAddItemSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddItemSheet(category: widget.category),
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
            'Kaç TL’ye aldın?',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            widget.item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: priceController,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tutar',
              suffixText: 'TL',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Boş geç'),
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
  final picker = ImagePicker();
  late bool completed;
  late ItemPriority priority;
  late String? inspirationImagePath;
  late String? productImagePath;
  late String? receiptImagePath;
  late final TextEditingController estimatedController;
  late final TextEditingController actualController;
  late final TextEditingController quantityController;
  late final TextEditingController brandModelController;
  late final TextEditingController shopController;
  late final TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    completed = widget.item.isCompleted;
    priority = widget.item.priority;
    inspirationImagePath = widget.item.inspirationImagePath;
    productImagePath = widget.item.productImagePath;
    receiptImagePath = widget.item.receiptImagePath;
    estimatedController = TextEditingController(
      text: _moneyText(widget.item.estimatedPrice),
    );
    actualController = TextEditingController(
      text: _moneyText(widget.item.actualPrice),
    );
    quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    brandModelController = TextEditingController(text: widget.item.brandModel);
    shopController = TextEditingController(text: widget.item.shopName);
    noteController = TextEditingController(text: widget.item.note);
  }

  @override
  void dispose() {
    estimatedController.dispose();
    actualController.dispose();
    quantityController.dispose();
    brandModelController.dispose();
    shopController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.94,
      minChildSize: 0.45,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.rose.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.subCategory,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                value: completed,
                onChanged: (value) => setState(() => completed = value),
                title: const Text('Alındı'),
                subtitle:
                    const Text('Liste tikini buradan da değiştirebilirsin.'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: actualController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Gerçek fiyat',
                  suffixText: 'TL',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Kaydet'),
                ),
              ),
              const SizedBox(height: 10),
              _SectionTile(
                title: 'Planlama',
                icon: Icons.tune,
                children: [
                  DropdownButtonFormField<ItemPriority>(
                    initialValue: priority,
                    decoration: const InputDecoration(labelText: 'Öncelik'),
                    items: [
                      for (final option in ItemPriority.values)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => priority = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: estimatedController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tahmini fiyat',
                      suffixText: 'TL',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Adet'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: brandModelController,
                    decoration: const InputDecoration(
                      labelText: 'Marka / model',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: shopController,
                    decoration: const InputDecoration(
                      labelText: 'Mağaza / nereden alındı?',
                    ),
                  ),
                ],
              ),
              _SectionTile(
                title: 'Fotoğraflar',
                icon: Icons.photo_library_outlined,
                children: [
                  _ImagePathTile(
                    title: 'İlham görseli',
                    subtitle: inspirationImagePath,
                    icon: Icons.lightbulb_outline,
                    onPick: () => _pickImage((path) {
                      setState(() => inspirationImagePath = path);
                    }),
                    onRemove: inspirationImagePath == null
                        ? null
                        : () => setState(() => inspirationImagePath = null),
                  ),
                  _ImagePathTile(
                    title: 'Ürün fotoğrafı',
                    subtitle: productImagePath,
                    icon: Icons.photo_outlined,
                    onPick: () => _pickImage((path) {
                      setState(() => productImagePath = path);
                    }),
                    onRemove: productImagePath == null
                        ? null
                        : () => setState(() => productImagePath = null),
                  ),
                  _ImagePathTile(
                    title: 'Fiş / garanti',
                    subtitle: receiptImagePath,
                    icon: Icons.receipt_long_outlined,
                    onPick: () => _pickImage((path) {
                      setState(() => receiptImagePath = path);
                    }),
                    onRemove: receiptImagePath == null
                        ? null
                        : () => setState(() => receiptImagePath = null),
                  ),
                ],
              ),
              _SectionTile(
                title: 'Notlar',
                icon: Icons.notes_outlined,
                children: [
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Not'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Ürünü sil'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _moneyText(double value) => value == 0 ? '' : value.toStringAsFixed(0);

  Future<void> _pickImage(ValueChanged<String> onPicked) async {
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) onPicked(image.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf seçilemedi')),
      );
    }
  }

  Future<void> _save() async {
    final controller = AppScope.of(context);
    final quantity = int.tryParse(quantityController.text.trim());
    await controller.updateItem(widget.item.copyWith(
      priority: priority,
      isCompleted: completed,
      estimatedPrice: parseMoney(estimatedController.text),
      actualPrice: parseMoney(actualController.text),
      quantity: quantity == null || quantity < 1 ? 1 : quantity,
      brandModel: brandModelController.text.trim(),
      shopName: shopController.text.trim(),
      note: noteController.text.trim(),
      inspirationImagePath: inspirationImagePath,
      productImagePath: productImagePath,
      receiptImagePath: receiptImagePath,
      clearInspirationImage: inspirationImagePath == null,
      clearProductImage: productImagePath == null,
      clearReceiptImage: receiptImagePath == null,
      completedDate:
          completed ? widget.item.completedDate ?? DateTime.now() : null,
      clearCompletedDate: !completed,
    ));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final controller = AppScope.of(context);
    await controller.deleteItem(widget.item);
    if (mounted) Navigator.pop(context);
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 14),
        leading: Icon(icon, color: AppColors.rose),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        children: children,
      ),
    );
  }
}

class _ImagePathTile extends StatelessWidget {
  const _ImagePathTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPick,
    required this.onRemove,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = subtitle != null && subtitle!.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rose.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                (hasImage ? AppColors.mint : AppColors.gold).withValues(
              alpha: 0.16,
            ),
            foregroundColor: hasImage ? AppColors.mint : AppColors.gold,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  hasImage ? 'Görsel seçildi' : 'Henüz görsel yok',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: hasImage ? 'Değiştir' : 'Seç',
            onPressed: onPick,
            icon: const Icon(Icons.add_photo_alternate_outlined),
          ),
          if (hasImage)
            IconButton(
              tooltip: 'Kaldır',
              onPressed: onRemove,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet({required this.category});

  final MainCategory category;

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final titleController = TextEditingController();
  final subCategoryController = TextEditingController();
  final priceController = TextEditingController();
  ItemPriority priority = ItemPriority.necessary;

  @override
  void initState() {
    super.initState();
    subCategoryController.text = widget.category.label;
  }

  @override
  void dispose() {
    titleController.dispose();
    subCategoryController.dispose();
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Özel ürün ekle',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Ürün adı'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subCategoryController,
              decoration: const InputDecoration(labelText: 'Alt kategori'),
            ),
            const SizedBox(height: 12),
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
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tahmini fiyat'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (titleController.text.trim().isEmpty) return;
    final controller = AppScope.of(context);
    await controller.addCustomItem(
      title: titleController.text.trim(),
      category: widget.category,
      subCategory: subCategoryController.text.trim().isEmpty
          ? widget.category.label
          : subCategoryController.text.trim(),
      priority: priority,
      estimatedPrice: parseMoney(priceController.text),
    );
    if (mounted) Navigator.pop(context);
  }
}
