# KPI Dashboard

Date: 24 July 2026

Scores are 0-100. Update after each meaningful implementation batch.

| Area | Score | Status | Evidence | Next Move |
|---|---:|---|---|---|
| Activation | 63 | Yellow | Onboarding CTA copy improved and home now surfaces one today action | Add preparation type and live setup preview |
| Core Planning | 72 | Yellow | Checklist, budget, guest and weekly plan exist | Reframe home around next action |
| Premium Value | 52 | Yellow | Paywall claims reduced to implemented/near-term value; lifetime is the launch product | Build report/export and deeper budget analysis |
| Monetization Plumbing | 68 | Yellow | AdMob live IDs and IAP skeleton exist | Create store products, test restore, validate subscriptions |
| UX Polish | 70 | Yellow | Core onboarding/home/paywall/settings Turkish trust pass completed | Polish empty states and screenshots |
| Technical Stability | 80 | Green | Analyze/test/web build/debug APK pass; release AAB blocks missing keystore as intended | Add controller/export/purchase tests |
| Store Readiness | 43 | Red | Docs/checklists exist; external store assets missing | Privacy URL, screenshots, signing, store forms |
| Release Confidence | 62 | Yellow | Web build passes; Android release now blocks missing production keystore | Real device QA and TestFlight |

## Director Gate

Current overall score: 65/100

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
- Sprint 2 export/report premium value MVP.
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
