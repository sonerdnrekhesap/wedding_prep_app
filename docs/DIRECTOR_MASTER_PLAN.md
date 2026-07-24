# Director Master Plan

Date: 24 July 2026
Project: `Hazirlik Takibi`
Repo: `wedding_prep_app`
Director owner: Codex

## North Star

Make Hazirlik Takibi a calm, offline-first wedding and ceyiz planning app that helps Turkish couples answer one question every day:

> Bugun ne yapmaliyim?

The app should feel useful before asking for money, then monetize through ad-free planning, professional exports, deeper planning insight, and optional premium storage/workflow features.

## Current State

Already completed:

- Flutter app foundation.
- Android and iOS platform folders.
- Android package id and iOS bundle id: `com.sonerdnrekhesap.hazirliktakibi`.
- App icon and branded splash direction.
- Animated Flutter launch splash.
- Core checklist, budget, guest, weekly plan and summary surfaces.
- Storage corruption recovery and model parse hardening.
- AdMob Android/iOS apps and banner/interstitial/rewarded unit IDs.
- `in_app_purchase` purchase skeleton.
- Premium paywall strategy and product IDs.
- GitHub PR flow.
- Automated checks: `flutter analyze`, `flutter test`, `flutter build web`, `flutter build appbundle`.

Known external blockers:

- Apple Developer / App Store Connect setup.
- Google Play Console app listing and release track.
- Store IAP products must be created outside the codebase.
- iOS signing and TestFlight require macOS/Xcode.
- AdMob store linking requires live/draft store records.

## Market Lessons

Competitor signals:

- The Knot: personalized checklist, guest/RSVP, vendors, budget, shared account.
- WeddingWire: checklist, vendor manager, website, budget, seating chart, guest list.
- Zola: RSVP/contact collection, budget, seating, export, registry, high-quality onboarding.

Local positioning:

- Do not copy registry/vendor marketplace first.
- Lead with ceyiz, dugun, bohca, kina/nisan and balayi preparation.
- Win trust with offline reliability, clear weekly actions, guest/budget visibility and family-shareable exports.

## KPI Model

Director score is tracked in `docs/KPI_DASHBOARD.md`.

Top metrics:

- Activation: user completes onboarding and sees personalized home.
- Planning clarity: user has at least 3 weekly actions or a clear "all calm" state.
- Data depth: user has checklist progress, budget target, and guest state.
- Monetization readiness: premium products, paywall, purchase restore and ad-free entitlement.
- Release readiness: analyze/test/build/store checklist.
- UX polish: splash, empty states, screenshots, no obvious overflow.

## Sprint 1 - Activation And First Value

Goal: first session must feel guided and personal.

Scope:

- Fix user-facing Turkish copy quality on onboarding, home, splash, settings and paywall.
- Improve onboarding with preparation type and priority intent.
- Home dashboard focuses on "Bu hafta / Bugun" actions before raw stats.
- Add one-tap "today's next action" card on home.
- Add better empty states for checklist, guests and budget.
- Prepare screenshot-friendly first-run demo state.

KPIs:

- Onboarding completion path has no dead end.
- Home top section shows one primary next action.
- First-action tap rate becomes measurable in controller events when analytics exists.
- Widget tests cover first launch.
- UX score >= 75/100.

Sprint 1 backlog:

1. Turkish trust pass: replace visible `Dugun`, `butce`, `Hazirlik`, debug/paywall wording with polished Turkish text.
2. Outcome-led onboarding: "Planimi olustur" -> "Haftalik plani gor" -> "Bugunun listesini ac".
3. Personalized setup preview: show countdown and mini weekly plan while date/budget are entered.
4. Home first action: put one clear recommendation above dashboard stats.
5. Risk hierarchy: surface urgent missing item and budget overrun before general progress.

## Sprint 2 - Premium Value MVP

Goal: premium should be anchored in working value, not only promises.

Scope:

- Checklist export beyond guest CSV.
- Premium report card export draft.
- Budget deep analysis: overspend, missing-estimate, category risk.
- Paywall CTA uses real store state when products exist.
- Keep debug mock isolated from release.

KPIs:

- At least 2 premium benefits are real working flows.
- Purchase restore path covered by tests where possible.
- Monetization readiness score >= 70/100.

Sprint 2 backlog:

1. Free vs Premium comparison paywall with real implemented claims only.
2. Checklist PDF/CSV export pack.
3. Budget advisor: category allocation, overspend alert and riskiest five items.
4. Store product state: real price when products load, graceful unavailable state when not.
5. Restore purchase flow QA.

## Sprint 3 - Guest, RSVP And Family Sharing

Goal: compete with RSVP/guest strengths without needing a backend first.

Scope:

- Guest grouping/household tags.
- RSVP status summary and quick filters.
- Shareable invitation/RSVP text template.
- CSV import/export hardening.
- Seating/table plan MVP if scope permits.

KPIs:

- Guest workflows complete in <= 3 taps for common status changes.
- Export/import tests cover Turkish characters and commas.
- Guest module score >= 80/100.

Sprint 3 backlog:

1. Family/group and plus-one model.
2. RSVP quick status, side filters and last-reminder date.
3. WhatsApp message template flow with platform-safe deep links.
4. CSV/Excel import and export hardening for Turkish characters.
5. Table plan lite: table number, capacity and guest assignment.

## Sprint 4 - Vendor And Timeline Layer

Goal: expand from checklist app into wedding operations hub.

Scope:

- Vendor/tedarikci tracker: name, category, phone, deposit, due date, notes.
- Wedding day timeline.
- Payment reminders model.
- Budget links to vendors and checklist items.

KPIs:

- Vendor MVP supports CRUD and budget visibility.
- Timeline has at least ceremony/reception/custom entries.
- Release risk remains <= medium.

Sprint 4 backlog:

1. Vendor tracker for venue, hair, photo, dress, organization and custom categories.
2. Deposit, remaining payment and due date tracking.
3. Receipt/contract photo archive with free quota and premium unlimited positioning.
4. Wedding day timeline with ceremony, reception and custom entries.
5. Budget links from vendors/payments to dashboard risk.

## Sprint 5 - Store Launch Package

Goal: submit-ready store package.

Scope:

- Privacy policy URL.
- Data Safety and App Privacy answers.
- Store descriptions and keywords.
- Screenshots and feature graphic.
- Android release signing.
- iOS signing/TestFlight.
- AdMob store linking.

KPIs:

- Store checklist score >= 90/100.
- Release AAB tested on real Android device.
- iOS TestFlight candidate produced.

Sprint 5 backlog:

1. Store metadata: title, short description, long description, keywords.
2. App Privacy/Data Safety answers.
3. Screenshot set for onboarding, home, checklist, guest/RSVP and premium value.
4. Android closed test release and AAB upload.
5. iOS TestFlight candidate on macOS/Xcode.

## AI Team

Active lead roles:

- Product/Rakip Lead: competitor-backed backlog and KPI prioritization.
- UX/Conversion Lead: onboarding, paywall, home, screenshot quality.
- Tech/QA Lead: stability, test gaps, release gates and risk scoring.
- Director: integrates outputs, assigns code work, verifies, commits and pushes.

Operating rule:

- Agents may explore and propose in parallel.
- Coding agents receive disjoint ownership to avoid merge conflict.
- Director owns final integration and release gates.

## Decision Defaults

Unless blocked:

- iOS and Android both stay configured.
- First monetization product should be `premium_lifetime` non-consumable.
- `premium_monthly` and `premium_6months` stay planned until subscription expiry validation is solved.
- Free tier remains useful enough to earn trust.
- Ads must not interrupt onboarding or first useful action.
