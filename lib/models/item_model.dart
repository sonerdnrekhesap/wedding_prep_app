enum MainCategory {
  ceyiz,
  bohca,
  soz,
  nisan,
  kina,
  dugun,
  balayi,
}

enum ItemPriority {
  mustHave,
  necessary,
  later,
  luxury,
}

extension MainCategoryText on MainCategory {
  String get label => switch (this) {
        MainCategory.ceyiz => 'Ceyiz',
        MainCategory.bohca => 'Bohca',
        MainCategory.soz => 'Soz',
        MainCategory.nisan => 'Nisan',
        MainCategory.kina => 'Kina',
        MainCategory.dugun => 'Dugun',
        MainCategory.balayi => 'Balayi',
      };
}

extension ItemPriorityText on ItemPriority {
  String get label => switch (this) {
        ItemPriority.mustHave => 'Olmazsa Olmaz',
        ItemPriority.necessary => 'Gerekli',
        ItemPriority.later => 'Sonra Alinabilir',
        ItemPriority.luxury => 'Luks',
      };

  double get weight => switch (this) {
        ItemPriority.mustHave => 5,
        ItemPriority.necessary => 3,
        ItemPriority.later => 1,
        ItemPriority.luxury => 0.5,
      };

  int get sortOrder => switch (this) {
        ItemPriority.mustHave => 0,
        ItemPriority.necessary => 1,
        ItemPriority.later => 2,
        ItemPriority.luxury => 3,
      };
}

class PrepItem {
  const PrepItem({
    required this.id,
    required this.title,
    required this.mainCategory,
    required this.subCategory,
    required this.priority,
    this.estimatedPrice = 0,
    this.actualPrice = 0,
    this.isCompleted = false,
    this.note = '',
    this.shopName = '',
    this.inspirationImagePath,
    this.inspirationThumbPath,
    this.productImagePath,
    this.productThumbPath,
    this.receiptImagePath,
    this.receiptThumbPath,
    this.brandModel,
    this.quantity = 1,
    this.purchaseDate,
    this.warrantyEndDate,
    this.completedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final MainCategory mainCategory;
  final String subCategory;
  final ItemPriority priority;
  final double estimatedPrice;
  final double actualPrice;
  final bool isCompleted;
  final String note;
  final String shopName;
  final String? inspirationImagePath;
  final String? inspirationThumbPath;
  final String? productImagePath;
  final String? productThumbPath;
  final String? receiptImagePath;
  final String? receiptThumbPath;
  final String? brandModel;
  final int quantity;
  final DateTime? purchaseDate;
  final DateTime? warrantyEndDate;
  final DateTime? completedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrepItem copyWith({
    String? title,
    MainCategory? mainCategory,
    String? subCategory,
    ItemPriority? priority,
    double? estimatedPrice,
    double? actualPrice,
    bool? isCompleted,
    String? note,
    String? shopName,
    String? inspirationImagePath,
    String? inspirationThumbPath,
    String? productImagePath,
    String? productThumbPath,
    String? receiptImagePath,
    String? receiptThumbPath,
    String? brandModel,
    int? quantity,
    DateTime? purchaseDate,
    DateTime? warrantyEndDate,
    DateTime? completedDate,
    bool clearCompletedDate = false,
    bool clearInspirationImage = false,
    bool clearProductImage = false,
    bool clearReceiptImage = false,
    bool clearPurchaseDate = false,
    bool clearWarrantyEndDate = false,
  }) {
    return PrepItem(
      id: id,
      title: title ?? this.title,
      mainCategory: mainCategory ?? this.mainCategory,
      subCategory: subCategory ?? this.subCategory,
      priority: priority ?? this.priority,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      actualPrice: actualPrice ?? this.actualPrice,
      isCompleted: isCompleted ?? this.isCompleted,
      note: note ?? this.note,
      shopName: shopName ?? this.shopName,
      inspirationImagePath: clearInspirationImage
          ? null
          : (inspirationImagePath ?? this.inspirationImagePath),
      inspirationThumbPath: clearInspirationImage
          ? null
          : (inspirationThumbPath ?? this.inspirationThumbPath),
      productImagePath: clearProductImage
          ? null
          : (productImagePath ?? this.productImagePath),
      productThumbPath: clearProductImage
          ? null
          : (productThumbPath ?? this.productThumbPath),
      receiptImagePath: clearReceiptImage
          ? null
          : (receiptImagePath ?? this.receiptImagePath),
      receiptThumbPath: clearReceiptImage
          ? null
          : (receiptThumbPath ?? this.receiptThumbPath),
      brandModel: brandModel ?? this.brandModel,
      quantity: quantity ?? this.quantity,
      purchaseDate:
          clearPurchaseDate ? null : (purchaseDate ?? this.purchaseDate),
      warrantyEndDate: clearWarrantyEndDate
          ? null
          : (warrantyEndDate ?? this.warrantyEndDate),
      completedDate:
          clearCompletedDate ? null : (completedDate ?? this.completedDate),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'mainCategory': mainCategory.name,
        'subCategory': subCategory,
        'priority': priority.name,
        'estimatedPrice': estimatedPrice,
        'actualPrice': actualPrice,
        'isCompleted': isCompleted,
        'note': note,
        'shopName': shopName,
        'inspirationImagePath': inspirationImagePath,
        'inspirationThumbPath': inspirationThumbPath,
        'productImagePath': productImagePath,
        'productThumbPath': productThumbPath,
        'receiptImagePath': receiptImagePath,
        'receiptThumbPath': receiptThumbPath,
        'brandModel': brandModel,
        'quantity': quantity,
        'purchaseDate': purchaseDate?.toIso8601String(),
        'warrantyEndDate': warrantyEndDate?.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory PrepItem.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return PrepItem(
      id: _stringOrDefault(json['id'], now.microsecondsSinceEpoch.toString()),
      title: _stringOrDefault(json['title'], 'Isimsiz kalem'),
      mainCategory: _parseMainCategory(json['mainCategory'] as String?),
      subCategory: _stringOrDefault(json['subCategory'], 'Genel'),
      priority: _parsePriority(json['priority'] as String?),
      estimatedPrice: _safeMoney(json['estimatedPrice']),
      actualPrice: _safeMoney(json['actualPrice']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      note: json['note'] as String? ?? '',
      shopName: json['shopName'] as String? ?? '',
      inspirationImagePath: json['inspirationImagePath'] as String?,
      inspirationThumbPath: json['inspirationThumbPath'] as String?,
      productImagePath: json['productImagePath'] as String?,
      productThumbPath: json['productThumbPath'] as String?,
      receiptImagePath: json['receiptImagePath'] as String?,
      receiptThumbPath: json['receiptThumbPath'] as String?,
      brandModel: json['brandModel'] as String?,
      quantity: _positiveInt(json['quantity']),
      purchaseDate: _parseDate(json['purchaseDate']),
      warrantyEndDate: _parseDate(json['warrantyEndDate']),
      completedDate: _parseDate(json['completedDate']),
      createdAt: _parseDate(json['createdAt']) ?? now,
      updatedAt: _parseDate(json['updatedAt']) ?? now,
    );
  }
}

MainCategory _parseMainCategory(String? value) {
  return MainCategory.values.firstWhere(
    (category) => category.name == value,
    orElse: () => MainCategory.ceyiz,
  );
}

ItemPriority _parsePriority(String? value) {
  return ItemPriority.values.firstWhere(
    (priority) => priority.name == value,
    orElse: () => ItemPriority.necessary,
  );
}

String _stringOrDefault(Object? value, String fallback) {
  if (value is! String || value.trim().isEmpty) return fallback;
  return value;
}

int _positiveInt(Object? value) {
  final parsed = value is num ? value.toInt() : null;
  if (parsed == null || parsed < 1) return 1;
  return parsed;
}

double _safeMoney(Object? value) {
  final parsed = value is num ? value.toDouble() : null;
  if (parsed == null || parsed.isNaN || parsed.isInfinite || parsed < 0) {
    return 0;
  }
  return parsed;
}

DateTime? _parseDate(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
