import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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

enum ItemFilter { all, missing, completed, purchased, notPurchased, highPriority, dueSoon, overBudget, hasPhoto, hasNote, hasPayment, mustHave, necessary, later, luxury }

enum ItemSort { recommended, priority, dueDate, newest, oldest, estimatedPrice, actualPrice, alphabetical }

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

extension ItemFilterText on ItemFilter {
  String get label => switch (this) {
        ItemFilter.all => 'Tümü',
        ItemFilter.missing => 'Eksik',
        ItemFilter.completed => 'Tamamlandı',
        ItemFilter.purchased => 'Satın alındı',
        ItemFilter.notPurchased => 'Satın alınmadı',
        ItemFilter.highPriority => 'Yüksek öncelik',
        ItemFilter.dueSoon => 'Yakın tarih',
        ItemFilter.overBudget => 'Bütçeyi aşan',
        ItemFilter.hasPhoto => 'Fotoğraflı',
        ItemFilter.hasNote => 'Notlu',
        ItemFilter.hasPayment => 'Ödemeli',
        ItemFilter.mustHave => 'Olmazsa Olmaz',
        ItemFilter.necessary => 'Gerekli',
        ItemFilter.later => 'Sonra',
        ItemFilter.luxury => 'Lüks',
      };
}

extension ItemSortText on ItemSort {
  String get label => switch (this) {
        ItemSort.recommended => 'Önerilen',
        ItemSort.priority => 'Öncelik',
        ItemSort.dueDate => 'Tarih',
        ItemSort.newest => 'Yeni',
        ItemSort.oldest => 'Eski',
        ItemSort.estimatedPrice => 'Tahmini fiyat',
        ItemSort.actualPrice => 'Gerçek fiyat',
        ItemSort.alphabetical => 'A-Z',
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
  ItemSort sort = ItemSort.recommended;
  String? selectedSubCategory;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = AppScope.of(context);
      controller.ads.maybeShowCategoryInterstitial();
      controller.rememberOpenedCategory(widget.category);
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
        .where((item) =>
            selectedSubCategory == null ||
            item.subCategory == selectedSubCategory)
        .where(_matchesFilter)
        .where(_matchesSearch)
        .toList();
    _sortItems(items);

    final subCategories = controller.items
        .where((item) => item.mainCategory == widget.category)
        .map((item) => item.subCategory)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.label),
        actions: [
          IconButton(
            tooltip: 'Filtre ve sıralama',
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemSheet,
        icon: const Icon(Icons.add),
        label: const Text('Ürün'),
      ),
      bottomNavigationBar: const AdBannerWidget(),
      body: Column(
        children: [
          _CategoryHeader(
            category: widget.category,
            total: controller.items
                .where((item) => item.mainCategory == widget.category)
                .length,
            shown: items.length,
            selectedSubCategory: selectedSubCategory,
            onChooseSubCategory: subCategories.isEmpty
                ? null
                : () => _showSubCategorySheet(subCategories),
            onClearSubCategory: selectedSubCategory == null
                ? null
                : () => setState(() => selectedSubCategory = null),
          ),
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
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Tüm alt kategoriler'),
                    selected: selectedSubCategory == null,
                    onSelected: (_) => setState(() => selectedSubCategory = null),
                  ),
                ),
                for (final subCategory in subCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        subCategory,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: selectedSubCategory == subCategory,
                      onSelected: (_) =>
                          setState(() => selectedSubCategory = subCategory),
                    ),
                  ),
              ],
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
                      return Dismissible(
                        key: ValueKey(item.id),
                        background: _SwipeBackground(
                          alignment: Alignment.centerLeft,
                          icon: item.isCompleted
                              ? Icons.undo
                              : Icons.check_circle_outline,
                          label: item.isCompleted ? 'Geri al' : 'Tamamla',
                          color: AppColors.mint,
                        ),
                        secondaryBackground: const _SwipeBackground(
                          alignment: Alignment.centerRight,
                          icon: Icons.edit_outlined,
                          label: 'Düzenle',
                          color: AppColors.gold,
                        ),
                        confirmDismiss: (direction) async {
                          HapticFeedback.selectionClick();
                          if (direction == DismissDirection.startToEnd) {
                            await _toggleItem(item);
                          } else {
                            await _showDetail(item);
                          }
                          return false;
                        },
                        child: ItemTile(
                          item: item,
                          onTap: () => _showDetail(item),
                          onCheckboxChanged: (_) => _toggleItem(item),
                          onQuickAction: (action) => _handleQuickAction(
                            item,
                            action,
                          ),
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
        ItemFilter.purchased => item.actualPrice > 0,
        ItemFilter.notPurchased => item.actualPrice <= 0,
        ItemFilter.highPriority => item.priority == ItemPriority.mustHave ||
            item.priority == ItemPriority.necessary,
        ItemFilter.dueSoon => item.dueDate != null &&
            item.dueDate!.difference(DateTime.now()).inDays <= 14,
        ItemFilter.overBudget =>
          item.actualPrice > 0 && item.estimatedPrice > 0 &&
              item.actualPrice > item.estimatedPrice,
        ItemFilter.hasPhoto =>
          item.inspirationImagePath != null ||
          item.productImagePath != null ||
          item.receiptImagePath != null,
        ItemFilter.hasNote => item.note.trim().isNotEmpty,
        ItemFilter.hasPayment =>
          item.contractTotal > 0 ||
          item.depositPaid > 0 ||
          item.totalPaid > 0 ||
          item.paymentDeadline != null,
        ItemFilter.mustHave => item.priority == ItemPriority.mustHave,
        ItemFilter.necessary => item.priority == ItemPriority.necessary,
        ItemFilter.later => item.priority == ItemPriority.later,
        ItemFilter.luxury => item.priority == ItemPriority.luxury,
      };

  bool _matchesSearch(PrepItem item) {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return item.title.toLowerCase().contains(query) ||
        item.subCategory.toLowerCase().contains(query) ||
        item.shopName.toLowerCase().contains(query) ||
        item.vendorName.toLowerCase().contains(query) ||
        item.note.toLowerCase().contains(query) ||
        item.mainCategory.label.toLowerCase().contains(query);
  }

  void _sortItems(List<PrepItem> items) {
    items.sort((a, b) {
      return switch (sort) {
        ItemSort.recommended => _recommendedCompare(a, b),
        ItemSort.priority => a.priority.sortOrder.compareTo(b.priority.sortOrder),
        ItemSort.dueDate => _dateCompare(a.dueDate, b.dueDate),
        ItemSort.newest => b.createdAt.compareTo(a.createdAt),
        ItemSort.oldest => a.createdAt.compareTo(b.createdAt),
        ItemSort.estimatedPrice => b.estimatedPrice.compareTo(a.estimatedPrice),
        ItemSort.actualPrice => b.actualPrice.compareTo(a.actualPrice),
        ItemSort.alphabetical => a.title.compareTo(b.title),
      };
    });
  }

  int _recommendedCompare(PrepItem a, PrepItem b) {
    final completed = a.isCompleted == b.isCompleted
        ? 0
        : a.isCompleted
            ? 1
            : -1;
    if (completed != 0) return completed;
    final priority = a.priority.sortOrder.compareTo(b.priority.sortOrder);
    if (priority != 0) return priority;
    return _dateCompare(a.dueDate, b.dueDate);
  }

  int _dateCompare(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
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
    await controller.updateItem(current.copyWith(
      actualPrice: price,
      purchaseDate:
          price > 0 ? current.purchaseDate ?? DateTime.now() : current.purchaseDate,
    ));
    if (price > 0) {
      controller.analytics.priceAdded(itemId: current.id, price: price);
    }
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

  Future<void> _showSubCategorySheet(List<String> subCategories) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Alt kategori seç',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.apps_outlined),
              title: const Text('Tüm alt kategoriler'),
              onTap: () => Navigator.pop(context),
            ),
            for (final subCategory in subCategories)
              ListTile(
                leading: Icon(
                  selectedSubCategory == subCategory
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                ),
                title: Text(subCategory),
                onTap: () => Navigator.pop(context, subCategory),
              ),
          ],
        ),
      ),
    );
    setState(() => selectedSubCategory = selected);
  }

  Future<void> _showFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                'Filtre ve sıralama',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              const Text('Filtre',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in ItemFilter.values)
                    FilterChip(
                      label: Text(option.label),
                      selected: filter == option,
                      onSelected: (_) {
                        setSheetState(() => filter = option);
                        setState(() => filter = option);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Sıralama',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in ItemSort.values)
                    ChoiceChip(
                      label: Text(option.label),
                      selected: sort == option,
                      onSelected: (_) {
                        setSheetState(() => sort = option);
                        setState(() => sort = option);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Uygula'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.category,
    required this.total,
    required this.shown,
    required this.selectedSubCategory,
    required this.onChooseSubCategory,
    required this.onClearSubCategory,
  });

  final MainCategory category;
  final int total;
  final int shown;
  final String? selectedSubCategory;
  final VoidCallback? onChooseSubCategory;
  final VoidCallback? onClearSubCategory;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.mintSoft,
              foregroundColor: AppColors.ink,
              child: Text(category.label.substring(0, 1)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedSubCategory ?? category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$shown/$total kalem gösteriliyor',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Alt kategori değiştir',
              onPressed: onChooseSubCategory,
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
            if (selectedSubCategory != null)
              IconButton(
                tooltip: 'Alt kategori filtresini temizle',
                onPressed: onClearSubCategory,
                icon: const Icon(Icons.close),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.icon,
    required this.label,
    required this.color,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      color: color.withValues(alpha: 0.14),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: isLeft ? TextDirection.ltr : TextDirection.rtl,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
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
  late bool giftListed;
  late ItemPriority priority;
  late String? inspirationImagePath;
  late String? inspirationThumbPath;
  late String? productImagePath;
  late String? productThumbPath;
  late String? receiptImagePath;
  late String? receiptThumbPath;
  late DateTime? purchaseDate;
  late DateTime? dueDate;
  late DateTime? warrantyEndDate;
  late DateTime? paymentDeadline;
  late final TextEditingController estimatedController;
  late final TextEditingController actualController;
  late final TextEditingController quantityController;
  late final TextEditingController brandModelController;
  late final TextEditingController shopController;
  late final TextEditingController vendorController;
  late final TextEditingController contractTotalController;
  late final TextEditingController depositPaidController;
  late final TextEditingController totalPaidController;
  late final TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    completed = widget.item.isCompleted;
    giftListed = widget.item.isGiftListed;
    priority = widget.item.priority;
    inspirationImagePath = widget.item.inspirationImagePath;
    inspirationThumbPath = widget.item.inspirationThumbPath;
    productImagePath = widget.item.productImagePath;
    productThumbPath = widget.item.productThumbPath;
    receiptImagePath = widget.item.receiptImagePath;
    receiptThumbPath = widget.item.receiptThumbPath;
    purchaseDate = widget.item.purchaseDate;
    dueDate = widget.item.dueDate;
    warrantyEndDate = widget.item.warrantyEndDate;
    paymentDeadline = widget.item.paymentDeadline;
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
    vendorController = TextEditingController(text: widget.item.vendorName);
    contractTotalController = TextEditingController(
      text: _moneyText(widget.item.contractTotal),
    );
    depositPaidController = TextEditingController(
      text: _moneyText(widget.item.depositPaid),
    );
    totalPaidController = TextEditingController(
      text: _moneyText(widget.item.totalPaid),
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
    vendorController.dispose();
    contractTotalController.dispose();
    depositPaidController.dispose();
    totalPaidController.dispose();
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
              _DatePickerTile(
                title: 'Satın alma tarihi',
                value: purchaseDate,
                icon: Icons.event_available_outlined,
                onPick: () => _pickDate(
                  current: purchaseDate,
                  onSelected: (date) => setState(() => purchaseDate = date),
                ),
                onClear: purchaseDate == null
                    ? null
                    : () => setState(() => purchaseDate = null),
              ),
              const SizedBox(height: 10),
              _DatePickerTile(
                title: 'Garanti bitiş tarihi',
                value: warrantyEndDate,
                icon: Icons.verified_user_outlined,
                onPick: () => _pickDate(
                  current: warrantyEndDate,
                  onSelected: (date) => setState(() => warrantyEndDate = date),
                ),
                onClear: warrantyEndDate == null
                    ? null
                    : () => setState(() => warrantyEndDate = null),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: widget.item.affiliateUrl.isEmpty
                        ? null
                        : () => _openAffiliate(widget.item.affiliateUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(widget.item.affiliateUrl.isEmpty
                        ? 'Fiyat linki yakında'
                        : 'Fiyatlara Bak'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final next = !giftListed;
                      setState(() => giftListed = next);
                      await AppScope.of(context).updateItem(
                        widget.item.copyWith(isGiftListed: next),
                      );
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    icon: Icon(giftListed
                        ? Icons.card_giftcard
                        : Icons.card_giftcard_outlined),
                    label: Text(giftListed
                        ? 'Hediye listesinden çıkar'
                        : 'Hediye listeme ekle'),
                  ),
                ],
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
                    value: priority,
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
                  _DatePickerTile(
                    title: 'Son hedef tarihi',
                    value: dueDate,
                    icon: Icons.event_note_outlined,
                    onPick: () => _pickDate(
                      current: dueDate,
                      onSelected: (date) => setState(() => dueDate = date),
                    ),
                    onClear: dueDate == null
                        ? null
                        : () => setState(() => dueDate = null),
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
                title: 'Ödeme ve Kapora',
                icon: Icons.payments_outlined,
                children: [
                  TextField(
                    controller: vendorController,
                    decoration: const InputDecoration(
                      labelText: 'Tedarikçi / satıcı',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contractTotalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sözleşme toplamı',
                      suffixText: 'TL',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: depositPaidController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ödenen kapora',
                      suffixText: 'TL',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalPaidController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Toplam ödenen',
                      suffixText: 'TL',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DatePickerTile(
                    title: 'Ödeme son tarihi',
                    value: paymentDeadline,
                    icon: Icons.event_busy_outlined,
                    onPick: () => _pickDate(
                      current: paymentDeadline,
                      onSelected: (date) =>
                          setState(() => paymentDeadline = date),
                    ),
                    onClear: paymentDeadline == null
                        ? null
                        : () => setState(() => paymentDeadline = null),
                  ),
                ],
              ),
              _SectionTile(
                title: 'Garanti & Fiş Arşivi',
                icon: Icons.receipt_long_outlined,
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
                    title: 'Fiş / garanti belgesi',
                    description:
                        'Fatura, garanti veya servis evrakını burada sakla.',
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

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 15),
    );
    if (picked != null) onSelected(picked);
  }

  Future<void> _openAffiliate(String url) async {
    AppScope.of(context).analytics.affiliateClicked(
          source: 'item_detail:${widget.item.title}',
          url: url,
        );
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
    final actualPrice = parseMoney(actualController.text);
    final effectivePurchaseDate =
        completed && actualPrice > 0 ? purchaseDate ?? DateTime.now() : purchaseDate;
    await controller.updateItem(widget.item.copyWith(
      priority: priority,
      isCompleted: completed,
      estimatedPrice: parseMoney(estimatedController.text),
      actualPrice: actualPrice,
      isGiftListed: giftListed,
      quantity: quantity == null || quantity < 1 ? 1 : quantity,
      brandModel: brandModelController.text.trim(),
      shopName: shopController.text.trim(),
      vendorName: vendorController.text.trim(),
      note: noteController.text.trim(),
      purchaseDate: effectivePurchaseDate,
      dueDate: dueDate,
      warrantyEndDate: warrantyEndDate,
      contractTotal: parseMoney(contractTotalController.text),
      depositPaid: parseMoney(depositPaidController.text),
      totalPaid: parseMoney(totalPaidController.text),
      paymentDeadline: paymentDeadline,
      clearPurchaseDate: effectivePurchaseDate == null,
      clearDueDate: dueDate == null,
      clearWarrantyEndDate: warrantyEndDate == null,
      clearPaymentDeadline: paymentDeadline == null,
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

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onPick,
    required this.onClear,
  });

  final String title;
  final DateTime? value;
  final IconData icon;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rose.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.rose),
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
                  value == null
                      ? 'Tarih seçilmedi'
                      : '${value!.day}.${value!.month}.${value!.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onPick, child: const Text('Seç')),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              tooltip: 'Temizle',
            ),
        ],
      ),
    );
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
  ItemPriority priority = ItemPriority.necessary;
  final selectedSuggestions = <String>{};
  bool showMore = false;

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
    final existingTitles = AppScope.of(context)
        .items
        .where((item) => item.mainCategory == widget.category)
        .map((item) => item.title.toLowerCase())
        .toSet();
    final suggestions = _suggestionsFor(widget.category)
        .where((title) => !existingTitles.contains(title.toLowerCase()))
        .toList();
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
              'Hızlı ekle',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            if (suggestions.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Önerilenlerden ekle',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final suggestion in suggestions.take(10))
                    FilterChip(
                      label: Text(suggestion),
                      selected: selectedSuggestions.contains(suggestion),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedSuggestions.add(suggestion);
                          } else {
                            selectedSuggestions.remove(suggestion);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: suggestions.isEmpty
                        ? null
                        : () => setState(() {
                              selectedSuggestions
                                ..clear()
                                ..addAll(suggestions.take(10));
                            }),
                    icon: const Icon(Icons.playlist_add_check),
                    label: const Text('Tümünü seç'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: selectedSuggestions.isEmpty
                        ? null
                        : _saveSuggestions,
                    child: Text('${selectedSuggestions.length} ekle'),
                  ),
                ],
              ),
              const Divider(height: 28),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tek ürün ekle',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 8),
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
            TextButton.icon(
              onPressed: () => setState(() => showMore = !showMore),
              icon: Icon(showMore
                  ? Icons.expand_less
                  : Icons.expand_more),
              label: Text(showMore ? 'Detayları gizle' : 'Daha fazla detay'),
            ),
            if (showMore) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<ItemPriority>(
                value: priority,
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
            ],
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

  Future<void> _saveSuggestions() async {
    final controller = AppScope.of(context);
    for (final title in selectedSuggestions) {
      await controller.addCustomItem(
        title: title,
        category: widget.category,
        subCategory: _defaultSubCategoryFor(widget.category),
        priority: ItemPriority.necessary,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  List<String> _suggestionsFor(MainCategory category) {
    return switch (category) {
      MainCategory.ceyiz => [
          'Yedek nevresim takımı',
          'Mutfak düzenleyici',
          'Misafir havlusu',
          'Kiler saklama kutuları',
        ],
      MainCategory.bohca => [
          'Bohça not kartı',
          'Hediye paketi',
          'Aile hediyesi',
        ],
      MainCategory.balayi => [
          'Yurt dışı priz adaptörü',
          'Bavul etiketi',
          'Seyahat boy bakım seti',
        ],
      _ => [
          'Tedarikçi teyidi',
          'Son ödeme kontrolü',
          'Aile bilgilendirme notu',
        ],
    };
  }

  String _defaultSubCategoryFor(MainCategory category) {
    return switch (category) {
      MainCategory.ceyiz => 'Diğer Ev İhtiyaçları',
      MainCategory.bohca => 'Sunum ve Süsleme',
      MainCategory.balayi => 'Bavul',
      _ => 'Son Kontroller',
    };
  }
}
