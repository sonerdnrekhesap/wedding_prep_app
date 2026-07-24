# Store Purchase Setup

Date: 22 July 2026

The app now includes an `in_app_purchase` based purchase skeleton.

## Product IDs

Create these products with the exact IDs in App Store Connect and Google Play Console when their release gates are ready:

- `premium_lifetime` - launch-ready non-consumable
- `premium_monthly` - draft only until subscription validation is ready
- `premium_6months` - draft only until entitlement expiry validation is ready

Current code queries only launch-ready product IDs:

- `premium_lifetime`

## Recommended Launch Strategy

Safest first release:

- Enable `premium_lifetime` as a non-consumable product.
- Keep `premium_monthly` and `premium_6months` drafted until subscription validation is completed.

Reason:

- A lifetime non-consumable can be restored locally through the store purchase stream.
- Monthly and 6-month premium need reliable entitlement expiry handling.
- For subscriptions, use store receipt/server validation or RevenueCat before enabling real sales.

## Current Code Behavior

- Queries store products on app startup.
- Shows store prices on the paywall when products are available.
- Starts purchase through `InAppPurchase.buyNonConsumable`.
- Listens to purchased/restored events.
- Completes pending purchases.
- Activates the local premium flag after a purchased/restored event.
- Disables ads when premium is active.
- Keeps debug mock purchase available outside release builds.
- Does not expose subscription product IDs to the store layer yet.

## Store Metadata Draft

### premium_monthly

- Type: Subscription after validation is ready
- Display name: Aylık Premium
- Positioning: flexible access for short planning windows

### premium_6months

- Type: Subscription or non-renewing entitlement after validation is ready
- Display name: 6 Aylık Hazırlık Paketi
- Positioning: recommended planning-period offer

### premium_lifetime

- Type: Non-consumable
- Display name: Ömür Boyu Premium
- Positioning: simplest first monetization product

## Before Enabling Real Sales

- Create products in both stores.
- Add localized Turkish descriptions.
- Test purchases with sandbox/test accounts.
- Verify restore purchase flow on iOS.
- Verify pending/canceled purchase states on Android.
- Decide whether subscriptions use backend receipt validation or RevenueCat.
