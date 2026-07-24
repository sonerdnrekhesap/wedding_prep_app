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
- Local funnel counters record paywall views, premium gate views, premium CTA taps, restore taps, rewarded attempts, rewarded successes, rewarded unavailable cases and unlocked premium features.
- Premium export gates now show a contextual preview before the user chooses Premium or rewarded ad: checklist count/missing items, budget totals, or report value depending on the locked action.

## Measurement Logic

- Paywall view count shows whether locked value is being discovered.
- Premium CTA taps show purchase intent before store-side purchase data is available.
- Rewarded attempt/success/unavailable counts show whether free users can generate ad revenue at high-intent export/report moments.
- Feature unlock count shows whether monetized gates still let users complete useful work.
- Counters are stored locally for QA and future analytics mapping; no custom backend upload exists in the current build.

## Next Monetization Improvements

- Add lifetime price A/B copy variants in store screenshots.
- Add purchase/restore sandbox QA proof before release.
