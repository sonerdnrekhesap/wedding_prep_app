import 'package:flutter/foundation.dart';

class AnalyticsService {
  const AnalyticsService();

  void itemCompleted({required String itemId}) =>
      _log('item_completed', {'item_id': itemId});

  void priceAdded({required String itemId, required double price}) =>
      _log('price_added', {'item_id': itemId, 'price': price});

  void affiliateClicked({required String source, required String url}) =>
      _log('affiliate_clicked', {'source': source, 'url': url});

  void giftListShared({required int itemCount}) =>
      _log('gift_list_shared', {'item_count': itemCount});

  void rewardedAdStarted({required String placement}) =>
      _log('rewarded_ad_started', {'placement': placement});

  void rewardedAdCompleted({required String placement}) =>
      _log('rewarded_ad_completed', {'placement': placement});

  void proClicked({required String source}) =>
      _log('pro_clicked', {'source': source});

  void leadSubmitted({required String category}) =>
      _log('lead_submitted', {'category': category});

  void budgetPackageOpened({required String packageType}) =>
      _log('budget_package_opened', {'package_type': packageType});

  void wrappedShared({required bool visual}) =>
      _log('wrapped_shared', {'visual': visual});

  void _log(String name, Map<String, Object?> params) {
    debugPrint('[analytics] $name $params');
  }
}
