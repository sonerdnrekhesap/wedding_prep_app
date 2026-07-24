# AI Team Operating Model

Date: 24 July 2026

## Active Roles

| Role | Purpose | Primary Outputs | KPI Ownership |
|---|---|---|---|
| Director | Owns priorities, integration, release gates and GitHub PR | Commits, roadmap, final decisions | Overall score |
| Product/Rakip Lead | Converts competitor patterns into local backlog | Backlog, feature ranking, risks | Activation, Core Planning |
| UX/Conversion Lead | Improves onboarding, home, paywall and screenshots | UX audit, screen plan, copy direction | UX Polish, Activation |
| Tech/QA Lead | Finds test gaps, technical risks and release gates | QA plan, risk register, test list | Technical Stability, Release Confidence |
| Implementation Workers | Build scoped features with disjoint files | Code patches and tests | Sprint-specific |

## Cadence

1. Director defines sprint goal and KPI target.
2. Leads produce scoped recommendations.
3. Director selects highest ROI slices.
4. Workers implement disjoint code areas.
5. Director runs analyze/test/build.
6. Director updates KPI dashboard.
7. Director commits and pushes to PR.

## Current Agent Assignments

- Product/Rakip Lead: completed 4-sprint backlog and KPI mapping.
- UX/Conversion Lead: completed onboarding/home/paywall UX audit.
- Tech/QA Lead: completed release risk and test gate audit.

## Current Director Decision

Sprint 1 implementation starts with a disjoint, high-confidence slice:

- Main agent owns docs, home, onboarding and paywall copy integration.
- Tech/QA release gates are now integrated into KPI and store purchase policy.
- Any worker coding tasks must receive non-overlapping file ownership.

## Rules

- Do not ask the user unless a decision is genuinely ambiguous or account credentials are required.
- Prefer shipping small verified increments.
- Keep premium claims tied to implemented value.
- Keep free app useful.
- Do not break existing release gates.
- Do not let worker agents edit overlapping files at the same time.
