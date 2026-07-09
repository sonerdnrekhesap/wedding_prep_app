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
        MainCategory.ceyiz => 'Çeyiz',
        MainCategory.bohca => 'Bohça',
        MainCategory.soz => 'Söz',
        MainCategory.nisan => 'Nişan',
        MainCategory.kina => 'Kına',
        MainCategory.dugun => 'Düğün',
        MainCategory.balayi => 'Balayı',
      };
}

extension ItemPriorityText on ItemPriority {
  String get label => switch (this) {
        ItemPriority.mustHave => 'Olmazsa Olmaz',
        ItemPriority.necessary => 'Gerekli',
        ItemPriority.later => 'Sonra Alınabilir',
        ItemPriority.luxury => 'Lüks',
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
    this.affiliateUrl = '',
    this.isGiftListed = false,
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
  final String affiliateUrl;
  final bool isGiftListed;
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
    String? affiliateUrl,
    bool? isGiftListed,
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
      affiliateUrl: affiliateUrl ?? this.affiliateUrl,
      isGiftListed: isGiftListed ?? this.isGiftListed,
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
        'affiliateUrl': affiliateUrl,
        'isGiftListed': isGiftListed,
        'quantity': quantity,
        'purchaseDate': purchaseDate?.toIso8601String(),
        'warrantyEndDate': warrantyEndDate?.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory PrepItem.fromJson(Map<String, dynamic> json) {
    return PrepItem(
      id: json['id'] as String,
      title: json['title'] as String,
      mainCategory: MainCategory.values.byName(json['mainCategory'] as String),
      subCategory: json['subCategory'] as String,
      priority: ItemPriority.values.byName(json['priority'] as String),
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble() ?? 0,
      actualPrice: (json['actualPrice'] as num?)?.toDouble() ?? 0,
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
      affiliateUrl: json['affiliateUrl'] as String? ?? '',
      isGiftListed: json['isGiftListed'] as bool? ?? false,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      purchaseDate: json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
      warrantyEndDate: json['warrantyEndDate'] == null
          ? null
          : DateTime.parse(json['warrantyEndDate'] as String),
      completedDate: json['completedDate'] == null
          ? null
          : DateTime.parse(json['completedDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
