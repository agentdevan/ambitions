# Ambitions 2.0 Daily Loop QA Baseline

Adoption date: 2026-04-26

## Purpose

Batch 76 records the Phase A daily-loop alpha baseline after Today 2.0, global shell chrome, and Activation Contract work.

This is a QA, performance, accessibility, and stability baseline. It does not introduce Life Graph, Proof / Resource Graph, Commitments / Waiting, Action Closure foundation, Safe Automation, Goals 2.0, Plan 2.0, You 2.0, Reviews, sync/export/import, widgets, App Intents, Path Builder, or RC maturity passes.

## Scenario Baseline

- First meaningful goal: a new user can start from one specific goal, and activation copy does not require a full life setup.
- Capture-first path: Capture remains the singular intake and routes messy life through the canonical Capture surface.
- Empty Today: Today points to one real action, either create a first goal or capture first, without becoming a blank dashboard.
- Daily Operating Contract: Today remains one dominant hero with limited support panels, a protected move, one best next move, one not-today item, one fallback, and a why-this-matters explanation.
- Save the Day: recovery remains non-punitive and route-only; it must not silently reschedule work.
- Calendar denied or restricted: Today does not request Calendar access or write calendar blocks. Calendar-aware planning remains Plan-owned.
- Returning low-data user: activation and degraded-state copy route back to Today, Capture, Goals, Plan, or You using existing local data only.
- Shell IA: top-level tabs remain Today, Goals, Capture, Plan, You. Capture remains singular.
- Trust copy: first-run and empty-state copy must not claim live sync, finished export/import, widgets, external surfaces, or unverified accessibility facts.
- Activation copy: user-facing copy must avoid internal engine names such as Life Graph, Action Closure, Believability Kernel, and Trust Ledger.

## Performance Baseline

This baseline is guidance, not a measured performance claim.

- Today top-level should avoid expensive repeated projections inside SwiftUI body work; service/view-state projection should stay value-model based.
- Global shell chrome should use lightweight tokenized primitives from the design system rather than one-off heavy styling.
- Activation and empty-state logic should remain static or value-model based.
- Empty-state copy must not require full repository scans.
- Batch 76 must not add network calls.
- Batch 76 must not add persistence migrations.
- Batch 76 must not add excessive blur stacking, scroll-tied animation, widgets, external snapshots, or App Intent work.
- Preview and test fixtures should stay deterministic and local.

## Accessibility Baseline

This baseline records current QA expectations without claiming release-level verification.

- Shell, header, Today, Capture, Plan, and activation copy should remain readable under Dynamic Type and avoid text clipping.
- Core shell controls and Today contract actions should expose accessibility labels or identifiers.
- Capture empty-state primary action should remain reachable by accessibility automation.
- Mode Lens is presentation-only and must not be announced as alternate navigation or a hidden tab system.
- Color must not be the only state indicator; semantic state should use text and icon support.
- Touch targets for shell and contract controls should remain practical for repeated daily use.

## Batch 76 Validation Notes

Batch 76 tests protect representative Phase A behavior:

- activation and trust copy stays truthful to current implementation
- empty and return paths route to one useful local action
- Today preserves one hero plus limited support panels
- Save the Day stays non-punitive and route-only
- Today calendar actions defer to Plan-owned calendar access

Manual QA that remains useful before Batch 77:

- run a fresh-install onboarding pass at large Dynamic Type
- inspect VoiceOver order for Today hero, Save the Day, shell command, Capture empty state, and Plan calendar-aware action
- inspect dark and light shell chrome for contrast and semantic state text
- confirm no sync/export/widget/App Intent copy appears in first-run or empty states
