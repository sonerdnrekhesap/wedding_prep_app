# Monetization Strategy

Date: 24 July 2026

## Goal

Make free users valuable through respectful ads, while giving serious planners clear reasons to buy Premium.

## Launch Model

1. Free + ads
   - Banner ads on planning screens.
   - Interstitial ads only after repeated category browsing, with cooldown.
   - Rewarded ads for one-time premium export/report unlocks.

2. Premium lifetime
   - First paid product: `premium_lifetime`.
   - Removes ads.
   - Unlocks unlimited checklist CSV export.
   - Unlocks unlimited budget CSV export.
   - Unlocks unlimited preparation report export.
   - Keeps photo/archive expansion as premium value.

3. Deferred subscriptions
   - `premium_monthly` and `premium_6months` stay disabled until entitlement expiry validation exists.

## Why This Is Rational

- Free users are not blocked from basic planning, so retention can grow.
- High-intent moments are monetized: export, report, budget summary and photo archive.
- Users who will not pay can still generate rewarded ad revenue.
- Users who dislike ads have a clear lifetime upgrade.
- Ads do not interrupt onboarding or the first useful action.

## Current Code Gates

- `AdService.canOfferRewardedUnlock` prevents showing rewarded unlock when web/AdMob config cannot serve it.
- Premium users dispose ad objects and skip ad display.
- Store product query exposes only launch-ready product IDs.
- Debug purchase is not presented in release paywall copy.

## Next Monetization Improvements

- Add event counters for paywall view, rewarded attempt, rewarded success and export conversion.
- Add export/report preview before purchase.
- Add lifetime price A/B copy variants in store screenshots.
- Add purchase/restore sandbox QA proof before release.
