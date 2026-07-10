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
    this.dueDate,
    this.warrantyEndDate,
    this.vendorName = '',
    this.contractTotal = 0,
    this.depositPaid = 0,
    this.totalPaid = 0,
    this.paymentDeadline,
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
  final DateTime? dueDate;
  final DateTime? warrantyEndDate;
  final String vendorName;
  final double contractTotal;
  final double depositPaid;
  final double totalPaid;
  final DateTime? paymentDeadline;
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
    DateTime? dueDate,
    DateTime? warrantyEndDate,
    String? vendorName,
    double? contractTotal,
    double? depositPaid,
    double? totalPaid,
    DateTime? paymentDeadline,
    DateTime? completedDate,
    bool clearCompletedDate = false,
    bool clearInspirationImage = false,
    bool clearProductImage = false,
    bool clearReceiptImage = false,
    bool clearPurchaseDate = false,
    bool clearDueDate = false,
    bool clearWarrantyEndDate = false,
    bool clearPaymentDeadline = false,
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
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      warrantyEndDate: clearWarrantyEndDate
          ? null
          : (warrantyEndDate ?? this.warrantyEndDate),
      vendorName: vendorName ?? this.vendorName,
      contractTotal: contractTotal ?? this.contractTotal,
      depositPaid: depositPaid ?? this.depositPaid,
      totalPaid: totalPaid ?? this.totalPaid,
      paymentDeadline: clearPaymentDeadline
          ? null
          : (paymentDeadline ?? this.paymentDeadline),
      completedDate:
          clearCompletedDate ? null : (completedDate ?? this.completedDate),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  PrepItem sanitized() {
    final safeCreatedAt = createdAt;
    final safePurchaseDate = purchaseDate != null &&
            purchaseDate!.isBefore(DateTime(safeCreatedAt.year,
                safeCreatedAt.month, safeCreatedAt.day))
        ? null
        : purchaseDate;
    final safeWarrantyEndDate =
        warrantyEndDate != null && safePurchaseDate != null &&
                warrantyEndDate!.isBefore(safePurchaseDate)
            ? null
            : warrantyEndDate;
    return PrepItem(
      id: id.trim(),
      title: title.trim(),
      mainCategory: mainCategory,
      subCategory: subCategory.trim(),
      priority: priority,
      estimatedPrice: estimatedPrice < 0 ? 0 : estimatedPrice,
      actualPrice: actualPrice < 0 ? 0 : actualPrice,
      isCompleted: isCompleted,
      note: note.trim(),
      shopName: shopName.trim(),
      inspirationImagePath: inspirationImagePath,
      inspirationThumbPath: inspirationThumbPath,
      productImagePath: productImagePath,
      productThumbPath: productThumbPath,
      receiptImagePath: receiptImagePath,
      receiptThumbPath: receiptThumbPath,
      brandModel: brandModel?.trim(),
      affiliateUrl: affiliateUrl.trim(),
      isGiftListed: isGiftListed,
      quantity: quantity < 1 ? 1 : quantity,
      purchaseDate: safePurchaseDate,
      dueDate: dueDate,
      warrantyEndDate: safeWarrantyEndDate,
      vendorName: vendorName.trim(),
      contractTotal: contractTotal < 0 ? 0 : contractTotal,
      depositPaid: depositPaid < 0 ? 0 : depositPaid,
      totalPaid: totalPaid < 0 ? 0 : totalPaid,
      paymentDeadline: paymentDeadline,
      completedDate: completedDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
        'dueDate': dueDate?.toIso8601String(),
        'warrantyEndDate': warrantyEndDate?.toIso8601String(),
        'vendorName': vendorName,
        'contractTotal': contractTotal,
        'depositPaid': depositPaid,
        'totalPaid': totalPaid,
        'paymentDeadline': paymentDeadline?.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory PrepItem.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return PrepItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      mainCategory: _parseMainCategory(json['mainCategory'] as String?),
      subCategory: json['subCategory'] as String? ?? '',
      priority: _parsePriority(json['priority'] as String?),
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
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      warrantyEndDate: json['warrantyEndDate'] == null
          ? null
          : DateTime.parse(json['warrantyEndDate'] as String),
      vendorName: json['vendorName'] as String? ?? '',
      contractTotal: (json['contractTotal'] as num?)?.toDouble() ?? 0,
      depositPaid: (json['depositPaid'] as num?)?.toDouble() ?? 0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
      paymentDeadline: json['paymentDeadline'] == null
          ? null
          : DateTime.parse(json['paymentDeadline'] as String),
      completedDate: json['completedDate'] == null
          ? null
          : DateTime.parse(json['completedDate'] as String),
      createdAt: json['createdAt'] == null
          ? now
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? now
          : DateTime.parse(json['updatedAt'] as String),
    ).sanitized();
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
