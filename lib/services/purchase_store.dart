import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'premium_service.dart';

enum PurchaseStoreStatus {
  idle,
  loading,
  available,
  unavailable,
  purchasePending,
  purchased,
  restored,
  failed,
}

class PurchaseStoreState {
  const PurchaseStoreState({
    required this.status,
    this.products = const {},
    this.message = '',
  });

  final PurchaseStoreStatus status;
  final Map<String, ProductDetails> products;
  final String message;

  bool get canPurchase =>
      status == PurchaseStoreStatus.available && products.isNotEmpty;

  ProductDetails? detailsFor(PremiumProduct product) => products[product.id];

  PurchaseStoreState copyWith({
    PurchaseStoreStatus? status,
    Map<String, ProductDetails>? products,
    String? message,
  }) {
    return PurchaseStoreState(
      status: status ?? this.status,
      products: products ?? this.products,
      message: message ?? this.message,
    );
  }

  static const initial = PurchaseStoreState(status: PurchaseStoreStatus.idle);
}

class PurchaseStore {
  PurchaseStore({InAppPurchase? inAppPurchase})
      : _iap = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<PurchaseStoreState> initialize({
    required void Function(PurchaseDetails purchase) onEntitlement,
    required void Function(PurchaseStoreState state) onState,
  }) async {
    if (kIsWeb) {
      return const PurchaseStoreState(
        status: PurchaseStoreStatus.unavailable,
        message: 'Web onizlemede store satin alma desteklenmez.',
      );
    }

    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      (purchases) => _handlePurchases(
        purchases,
        onEntitlement: onEntitlement,
        onState: onState,
      ),
      onError: (Object error) {
        onState(const PurchaseStoreState(
          status: PurchaseStoreStatus.failed,
          message: 'Satin alma akisi baslatilamadi.',
        ));
      },
    );

    final available = await _iap.isAvailable();
    if (!available) {
      return const PurchaseStoreState(
        status: PurchaseStoreStatus.unavailable,
        message: 'Magaza satin alma servisi bu cihazda hazir degil.',
      );
    }

    final response = await _iap.queryProductDetails(PremiumCatalog.productIds);
    final products = {
      for (final product in response.productDetails) product.id: product,
    };

    if (products.isEmpty) {
      return PurchaseStoreState(
        status: PurchaseStoreStatus.unavailable,
        message: response.error?.message ??
            'Store urunleri henuz App Store / Play Console tarafinda aktif degil.',
      );
    }

    return PurchaseStoreState(
      status: PurchaseStoreStatus.available,
      products: products,
      message: response.notFoundIDs.isEmpty
          ? ''
          : 'Eksik store urunleri: ${response.notFoundIDs.join(', ')}',
    );
  }

  Future<bool> buy(ProductDetails details) {
    final purchaseParam = PurchaseParam(productDetails: details);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restore() => _iap.restorePurchases();

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _handlePurchases(
    List<PurchaseDetails> purchases, {
    required void Function(PurchaseDetails purchase) onEntitlement,
    required void Function(PurchaseStoreState state) onState,
  }) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          onState(const PurchaseStoreState(
            status: PurchaseStoreStatus.purchasePending,
            message: 'Satin alma onayi bekleniyor.',
          ));
        case PurchaseStatus.purchased:
          onEntitlement(purchase);
          onState(const PurchaseStoreState(
            status: PurchaseStoreStatus.purchased,
            message: 'Premium aktif edildi.',
          ));
        case PurchaseStatus.restored:
          onEntitlement(purchase);
          onState(const PurchaseStoreState(
            status: PurchaseStoreStatus.restored,
            message: 'Satin almalar geri yuklendi.',
          ));
        case PurchaseStatus.error:
          onState(PurchaseStoreState(
            status: PurchaseStoreStatus.failed,
            message: purchase.error?.message ?? 'Satin alma tamamlanamadi.',
          ));
        case PurchaseStatus.canceled:
          onState(const PurchaseStoreState(
            status: PurchaseStoreStatus.available,
            message: 'Satin alma iptal edildi.',
          ));
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }
}
