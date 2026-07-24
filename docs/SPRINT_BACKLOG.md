# Sprint Backlog

Date: 24 July 2026
Owner: Director

This file converts competitor research and AI lead reports into a shipping backlog.

## Market Signals Used

- The Knot: personalized checklist, vendors, guest organization, budget, website, registry and shared planning.
- WeddingWire: checklist, vendor manager, website, budget, seating chart and guest list.
- Zola: guest list, RSVP/contact collection, budget, seating, export and high-polish onboarding.

Local product decision:

- Build a Turkish wedding and ceyiz planning assistant first.
- Do not start with marketplace/registry dependency.
- Win with calm weekly guidance, ceyiz/bohca/kina language, guest/budget clarity and exportable family-friendly planning.

## S1 - Activation And First Value

| Rank | Item | KPI | MVP Acceptance | Risk |
|---:|---|---|---|---|
| 1 | Turkish trust copy pass | Onboarding completion, screenshot quality | No visible broken Turkish/ASCII wedding terms in key screens | Scope can expand; keep to core pages first |
| 2 | Personalized onboarding recipe | First 24h 5+ checklist completions | Date, budget, guest count and prep type influence initial priorities | Seed data quality |
| 3 | Smart weekly plan v2 | Weekly plan 2+ return rate | Today/this week/next action with done/postpone | Wrong priority reduces trust |
| 4 | Deadline checklist/custom tasks | Custom task creation/completion | Deadline, category and status filters | Notification infra may be later |
| 5 | Budget advisor v1 | Price entry rate | Category allocation, remaining spend, overrun label, top 5 risky items | Default ratios are estimates |

## S2 - Guest And RSVP

| Rank | Item | KPI | MVP Acceptance | Risk |
|---:|---|---|---|---|
| 1 | Guest import/export | 20+ guest user ratio | CSV/Excel friendly import/export with Turkish characters | Permissions and Excel edge cases |
| 2 | WhatsApp RSVP flow | Unknown guest ratio drop | Message template and quick status change | Platform deep links differ |
| 3 | Family/group management | Correct headcount use | Household, children/adult count, side and notes | Guest model migration |
| 4 | Table plan lite | Export/share rate | Table number, capacity and assignment list | Visual drag-drop can wait |

## S3 - Premium Value

| Rank | Item | KPI | MVP Acceptance | Risk |
|---:|---|---|---|---|
| 1 | Free vs Premium paywall | Paywall purchase attempt | Claims match implemented features | Store product availability |
| 2 | PDF/Excel export pack | Premium conversion from export | Checklist, budget, guest and table outputs | PDF layout QA |
| 3 | Vendor/payment tracker | Vendor/payment records per user | Vendor CRUD, deposit, remaining payment, due date | Must not become marketplace |
| 4 | Photo archive v1 | Premium trial/purchase from archive | Attach photo to item/vendor/payment with free quota | Storage and permission expectations |

## S4 - Sharing And Launch

| Rank | Item | KPI | MVP Acceptance | Risk |
|---:|---|---|---|---|
| 1 | Partner/family share lite | Shared summary return rate | Read-only export/share text and responsible side fields | Live sync needs backend |
| 2 | Store screenshot package | Store readiness score | Five portrait screenshots and feature graphic | Requires visual QA |
| 3 | Real device release QA | Release confidence | Android install tested, iOS TestFlight tested | External devices/accounts |

## Current Director Pick

Start with S1 item 1 and item 3:

- Fix visible Turkish copy and release-safe premium language. Done.
- Put a single "Bugunun onerisi" action on the home screen. Done.
- Add working premium CSV export for checklist and budget summary. Done.
- Add budget advisor v1 for overrun, near-limit and next expensive missing item. Done.
- Next: PDF/report export and deadline/custom task controls.
