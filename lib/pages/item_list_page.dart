import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/formatters.dart';
import '../services/photo_storage_models.dart';
import '../theme/app_colors.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/item_photo_preview.dart';
import '../widgets/item_tile.dart';
import '../widgets/visual_cards.dart';
import 'paywall_page.dart';

enum ItemFilter { all, missing, completed, mustHave, necessary, later, luxury }

Iterable<String?> _pathsFor(PrepItem item, ItemPhotoType type) =>
    switch (type) {
      ItemPhotoType.inspiration => [
          item.inspirationImagePath,
          item.inspirationThumbPath,
        ],
      ItemPhotoType.product => [
          item.productImagePath,
          item.productThumbPath,
        ],
      ItemPhotoType.receipt => [
          item.receiptImagePath,
          item.receiptThumbPath,
        ],
    };

PrepItem _withPhoto(
  PrepItem item,
  ItemPhotoType type,
  String? imagePath,
  String? thumbPath,
) {
  return switch (type) {
    ItemPhotoType.inspiration => item.copyWith(
        inspirationImagePath: imagePath,
        inspirationThumbPath: thumbPath,
        clearInspirationImage: imagePath == null,
      ),
    ItemPhotoType.product => item.copyWith(
        productImagePath: imagePath,
        productThumbPath: thumbPath,
        clearProductImage: imagePath == null,
      ),
    ItemPhotoType.receipt => item.copyWith(
        receiptImagePath: imagePath,
        receiptThumbPath: thumbPath,
        clearReceiptImage: imagePath == null,
      ),
  };
}

DateTime? _parseDateInput(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  final parts = text.split(RegExp(r'[./-]'));
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  final date = DateTime(year, month, day);
  if (date.day != day || date.month != month || date.year != year) {
    return null;
  }
  return date;
}

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
                        onQuickAction: (action) => _handleQuickAction(
                          item,
                          action,
                        ),
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

  Future<void> _handleQuickAction(
    PrepItem item,
    ItemQuickAction action,
  ) async {
    switch (action) {
      case ItemQuickAction.price:
        await _showQuickPriceSheet(item);
      case ItemQuickAction.inspirationPhoto:
        await _pickAndSaveQuickPhoto(item, ItemPhotoType.inspiration);
      case ItemQuickAction.productPhoto:
        await _pickAndSaveQuickPhoto(item, ItemPhotoType.product);
      case ItemQuickAction.receiptPhoto:
        await _pickAndSaveQuickPhoto(item, ItemPhotoType.receipt);
      case ItemQuickAction.note:
        await _showDetail(item);
      case ItemQuickAction.delete:
        await _confirmDelete(item);
    }
  }

  Future<void> _pickAndSaveQuickPhoto(
    PrepItem item,
    ItemPhotoType type,
  ) async {
    final controller = AppScope.of(context);
    if (!controller.premium
        .canAddPhoto(controller.settings, controller.items)) {
      if (!mounted) return;
      await _openPhotoPaywall();
      return;
    }

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );
    if (image == null) return;

    final current = controller.items.firstWhere(
      (current) => current.id == item.id,
      orElse: () => item,
    );
    final oldPaths = _pathsFor(current, type);
    final stored = await controller.photoStorage.saveItemPhoto(
      itemId: item.id,
      type: type,
      source: image,
    );
    await controller.photoStorage.deletePhotoPaths(oldPaths);
    await controller.updateItem(
      _withPhoto(current, type, stored.imagePath, stored.thumbPath),
    );
  }

  Future<void> _confirmDelete(PrepItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürün silinsin mi?'),
        content: Text('${item.title} ve bağlı fotoğrafları silinir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await AppScope.of(context).deleteItem(item);
    }
  }

  Future<void> _openPhotoPaywall() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PaywallPage(source: 'photo_archive'),
      ),
    );
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
  late String? inspirationThumbPath;
  late String? productImagePath;
  late String? productThumbPath;
  late String? receiptImagePath;
  late String? receiptThumbPath;
  late final TextEditingController estimatedController;
  late final TextEditingController actualController;
  late final TextEditingController quantityController;
  late final TextEditingController brandModelController;
  late final TextEditingController shopController;
  late final TextEditingController targetDateController;
  late final TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    completed = widget.item.isCompleted;
    priority = widget.item.priority;
    inspirationImagePath = widget.item.inspirationImagePath;
    inspirationThumbPath = widget.item.inspirationThumbPath;
    productImagePath = widget.item.productImagePath;
    productThumbPath = widget.item.productThumbPath;
    receiptImagePath = widget.item.receiptImagePath;
    receiptThumbPath = widget.item.receiptThumbPath;
    estimatedController = TextEditingController(
      text: _moneyText(widget.item.estimatedPrice),
    );
    actualController = TextEditingController(
      text: _moneyText(widget.item.actualPrice),
    );
    quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    brandModelController = TextEditingController(
      text: widget.item.brandModel ?? '',
    );
    shopController = TextEditingController(text: widget.item.shopName);
    targetDateController = TextEditingController(
      text: _dateText(widget.item.purchaseDate),
    );
    noteController = TextEditingController(text: widget.item.note);
  }

  @override
  void dispose() {
    estimatedController.dispose();
    actualController.dispose();
    quantityController.dispose();
    brandModelController.dispose();
    shopController.dispose();
    targetDateController.dispose();
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: targetDateController,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: 'Hedef alış tarihi',
                      hintText: 'GG.AA.YYYY',
                      prefixIcon: Icon(Icons.event_available_outlined),
                    ),
                  ),
                ],
              ),
              _SectionTile(
                title: 'Fotoğraflar',
                icon: Icons.photo_library_outlined,
                children: [
                  _ImagePathTile(
                    title: 'İlham Fotoğrafı',
                    description: 'Almak istediğin ürünün görselini sakla.',
                    path: inspirationImagePath,
                    thumbPath: inspirationThumbPath,
                    icon: Icons.lightbulb_outline,
                    onPick: () => _pickImage(ItemPhotoType.inspiration),
                    onView: inspirationImagePath == null
                        ? null
                        : () => _viewPhoto(
                              'İlham Fotoğrafı',
                              inspirationImagePath!,
                            ),
                    onRemove: inspirationImagePath == null
                        ? null
                        : () => _removePhoto(ItemPhotoType.inspiration),
                  ),
                  _ImagePathTile(
                    title: 'Ürün Fotoğrafı',
                    description: 'Aldığın ürünü kaydet.',
                    path: productImagePath,
                    thumbPath: productThumbPath,
                    icon: Icons.photo_outlined,
                    onPick: () => _pickImage(ItemPhotoType.product),
                    onView: productImagePath == null
                        ? null
                        : () => _viewPhoto('Ürün Fotoğrafı', productImagePath!),
                    onRemove: productImagePath == null
                        ? null
                        : () => _removePhoto(ItemPhotoType.product),
                  ),
                  _ImagePathTile(
                    title: 'Fiş / garanti',
                    description: 'Faturanı veya garanti belgeni sakla.',
                    path: receiptImagePath,
                    thumbPath: receiptThumbPath,
                    icon: Icons.receipt_long_outlined,
                    onPick: () => _pickImage(ItemPhotoType.receipt),
                    onView: receiptImagePath == null
                        ? null
                        : () => _viewPhoto('Fiş / Garanti', receiptImagePath!),
                    onRemove: receiptImagePath == null
                        ? null
                        : () => _removePhoto(ItemPhotoType.receipt),
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

  String _dateText(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _pickImage(ItemPhotoType type) async {
    final controller = AppScope.of(context);
    final replacingExisting = _pathsFor(widget.item, type)
        .whereType<String>()
        .any((path) => path.isNotEmpty);
    if (!replacingExisting &&
        !controller.premium
            .canAddPhoto(controller.settings, controller.items)) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PaywallPage(source: 'photo_archive'),
        ),
      );
      return;
    }

    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
      );
      if (image == null) return;

      final stored = await controller.photoStorage.saveItemPhoto(
        itemId: widget.item.id,
        type: type,
        source: image,
      );
      await controller.photoStorage
          .deletePhotoPaths(_pathsFor(widget.item, type));
      setState(() {
        _setLocalPhoto(type, stored.imagePath, stored.thumbPath);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf seçilemedi')),
      );
    }
  }

  Future<void> _removePhoto(ItemPhotoType type) async {
    final paths = _localPathsFor(type);
    await AppScope.of(context).photoStorage.deletePhotoPaths(paths);
    setState(() => _setLocalPhoto(type, null, null));
  }

  void _viewPhoto(String title, String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenPhotoPage(title: title, path: path),
      ),
    );
  }

  Iterable<String?> _localPathsFor(ItemPhotoType type) => switch (type) {
        ItemPhotoType.inspiration => [
            inspirationImagePath,
            inspirationThumbPath,
          ],
        ItemPhotoType.product => [
            productImagePath,
            productThumbPath,
          ],
        ItemPhotoType.receipt => [
            receiptImagePath,
            receiptThumbPath,
          ],
      };

  void _setLocalPhoto(
      ItemPhotoType type, String? imagePath, String? thumbPath) {
    switch (type) {
      case ItemPhotoType.inspiration:
        inspirationImagePath = imagePath;
        inspirationThumbPath = thumbPath;
      case ItemPhotoType.product:
        productImagePath = imagePath;
        productThumbPath = thumbPath;
      case ItemPhotoType.receipt:
        receiptImagePath = imagePath;
        receiptThumbPath = thumbPath;
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
      purchaseDate: _parseDateInput(targetDateController.text),
      clearPurchaseDate: targetDateController.text.trim().isEmpty,
      note: noteController.text.trim(),
      inspirationImagePath: inspirationImagePath,
      inspirationThumbPath: inspirationThumbPath,
      productImagePath: productImagePath,
      productThumbPath: productThumbPath,
      receiptImagePath: receiptImagePath,
      receiptThumbPath: receiptThumbPath,
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
    required this.description,
    required this.path,
    required this.thumbPath,
    required this.icon,
    required this.onPick,
    required this.onView,
    required this.onRemove,
  });

  final String title;
  final String description;
  final String? path;
  final String? thumbPath;
  final IconData icon;
  final VoidCallback onPick;
  final VoidCallback? onView;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = path != null && path!.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rose.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemPhotoPreview(
            path: thumbPath ?? path,
            icon: icon,
            size: 68,
            onTap: onView,
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
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onPick,
                      icon: Icon(
                        hasImage
                            ? Icons.change_circle_outlined
                            : Icons.add_photo_alternate_outlined,
                        size: 18,
                      ),
                      label: Text(hasImage ? 'Değiştir' : 'Ekle'),
                    ),
                    OutlinedButton.icon(
                      onPressed: hasImage ? onView : null,
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Gör'),
                    ),
                    OutlinedButton.icon(
                      onPressed: hasImage ? onRemove : null,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Sil'),
                    ),
                  ],
                ),
              ],
            ),
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
  final targetDateController = TextEditingController();
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
    targetDateController.dispose();
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
            const SizedBox(height: 12),
            TextField(
              controller: targetDateController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Hedef alış tarihi',
                hintText: 'GG.AA.YYYY',
              ),
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
      targetPurchaseDate: _parseDateInput(targetDateController.text),
    );
    if (mounted) Navigator.pop(context);
  }
}
