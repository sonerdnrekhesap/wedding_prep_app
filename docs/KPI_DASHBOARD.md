# KPI Dashboard

Date: 24 July 2026

Scores are 0-100. Update after each meaningful implementation batch.

| Area | Score | Status | Evidence | Next Move |
|---|---:|---|---|---|
| Activation | 64 | Yellow | Onboarding CTA copy improved and home now surfaces one today action | Add preparation type and live setup preview |
| Core Planning | 82 | Green | Checklist, target dates/filter, budget advisor, guest RSVP, table assignment and weekly plan exist | Add household grouping and reminders |
| Premium Value | 71 | Yellow | Lifetime unlocks unlimited CSV/report/text PDF export, ad-free use, budget advisor and archive value; paywall has comparison table and gate previews | Polish PDF visual design and font handling |
| Monetization Plumbing | 78 | Yellow | AdMob, IAP skeleton, premium gates, rewarded export unlocks and local funnel counters exist | Create store products, test restore, validate subscriptions |
| UX Polish | 70 | Yellow | Core onboarding/home/paywall/settings Turkish trust pass completed | Polish empty states and screenshots |
| Technical Stability | 86 | Green | Analyze/test pass with export, PDF report, budget advisor, RSVP, table and target date tests | Add controller/purchase tests |
| Store Readiness | 50 | Yellow | Store metadata and privacy/data safety drafts exist; external assets still missing | Privacy URL, screenshots, signing, store forms |
| Release Confidence | 62 | Yellow | Web build passes; Android release now blocks missing production keystore | Real device QA and TestFlight |

## Director Gate

Current overall score: 76/100

Formula:

- Activation 15%
- Core Planning 15%
- Premium Value 15%
- Monetization Plumbing 10%
- UX Polish 15%
- Technical Stability 15%
- Store Readiness 10%
- Release Confidence 5%

## Weekly Target

Raise overall score from 61 to 75 by completing:

- Sprint 1 activation improvements: Turkish trust copy, home next action and onboarding outcome copy.
- Sprint 2 export/report premium value MVP: CSV export, text report export and budget advisor started; PDF rendering still pending.
- QA tests for new flows.
- Store metadata pack draft.

## Lead Findings - 24 July 2026

Product/Rakip Lead:

- Highest market-matched backlog: personalized checklist recipe, smart weekly plan, deadline/custom tasks, budget advisor, guest RSVP, table plan lite, vendor/payment tracker and export pack.
- Local differentiation: ceyiz/dugun/bohca/kina/balayi preparation instead of registry/marketplace first.

UX/Conversion Lead:

- Top three fixes: Turkish text quality, home "Bugun ne yapmaliyim?" card, paywall value reframed from feature list to planning relief.
- Release trust risk: debug/store-onayi wording must be hidden or replaced in production-facing paywall.

Tech/QA Lead:

- Release signing debug fallback was a critical blocker; Android release now requires keystore unless an explicit local-test Gradle flag is passed. Debug APK still builds normally.
- IAP subscriptions stay draft-only until receipt/expiry validation exists.
- Paywall copy must keep claims tied to working value.
- Real device Android QA and macOS/iOS TestFlight remain release gates.

Implementation update:

- Premium users can export the preparation checklist and budget summary as Excel-friendly CSV from Settings.
- ExportService now has tests for checklist and budget CSV output.
- Budget page now shows a budget advisor card for missing target, overrun, near-limit risk, next expensive missing item, or calm state.
- CalculationService now has tests for budget advisor states.
- Premium users can export a text preparation report with score, date, budget advisor, guest summary, category summary and next priorities.
- Items can carry a target purchase date from detail and custom item forms; weekly plan prioritizes due-soon unfinished items.
- Checklist now has a due-soon filter and item tiles show target purchase dates.
- Guest screen can share RSVP reminder text for all uncertain guests or a single guest; message service is tested.
- Guests can store a table/group label, show it on guest cards and export it in guest CSV.
- Turkish store metadata and privacy/data safety drafts are prepared.
- Monetization now has free ads, rewarded one-time export unlocks and lifetime premium unlimited export/ad-free positioning.
- Paywall now explains Free vs rewarded one-time use vs Premium unlimited value.
- Monetization funnel is now locally measurable: paywall views, premium gate views, premium CTA taps, restore taps, rewarded attempts, rewarded successes, rewarded unavailable cases and feature unlocks are counted on device.
- Premium export/report gates now preview the value of the locked action before the Premium or rewarded-ad choice.
- Premium users and rewarded-ad unlock users can share a PDF preparation report; the first PDF engine is dependency-free and covered by tests.

## KPI Definitions

Activation:

- User finishes onboarding.
- Home reflects wedding date, names, budget and next action.

Core Planning:

- Checklist, budget and guest states work without crashes.
- Weekly plan provides useful next steps.

Premium Value:

- Premium has real, working user value.
- Paywall claims match implemented features.

Monetization Plumbing:

- Ads respect premium.
- Store purchase products can be queried, bought and restored.

UX Polish:

- No blank startup.
- No obvious overflow.
- Store screenshots look intentional.

Technical Stability:

- `flutter analyze` clean.
- `flutter test` clean.
- Android AAB builds.

Store Readiness:

- Store listing, privacy, screenshots, signing and app review inputs complete.

Release Confidence:

- Real device Android QA.
- iOS TestFlight QA.
