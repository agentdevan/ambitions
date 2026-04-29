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

## M01 Core Surface Integration QA Addendum

M01 upgrades this baseline from the Phase A daily-loop alpha into a post-D26 scenario catalog for the aligned app. The code-backed catalog lives in `Native/Ambitions/Support/CoreSurfaceIntegrationScenarios.swift`, with focused coverage in `Native/AmbitionsTests/App/CoreSurfaceIntegrationScenarioTests.swift`.

The catalog is not release readiness. It is the first maturity-layer proof that the five-tab app can be reviewed as one coherent daily life system before export/import, data-safety, external-platform, path, memory, review, portfolio, recovery, performance, accessibility-claims, and RC-lock batches deepen the evidence.

## R05 Release Gate Addendum

R01-R05 now complete the release-gate evidence layer for planning purposes, but they do not turn the daily-loop baseline into App Store or TestFlight proof. The final repo posture is `Candidate prepared; human approval required`; physical-device smoke, manual accessibility review, signed archive/App Store Connect validation, rendered external-surface checks, current store assets, live support/privacy URLs, and explicit human approval remain required before release claims change.

Validation evidence after M01 closeout: `xcodegen generate`; focused M01/activation/daily-loop tests (`21` tests, `0` failures); adjacent shell/screen/Today/Capture/Goals/Goal Detail/Plan/You/reviews/receipts/accessibility regression lane (`138` tests, `0` failures); native simulator build on `iPhone 17`; full `AmbitionsTests` (`690` tests, `0` failures); and diff whitespace checks.

Active limitations after M01: this remains simulator/unit/docs evidence plus a manual checklist. It does not prove export/import, migration/no-lost-data recovery, rendered widgets, Live Activity lifecycle delivery, real Shortcuts/Siri behavior, notification delivery, public accessibility claims, TestFlight readiness, App Store readiness, or final RC lock.

### M01 Scenario Fixtures

| Scenario | Primary surfaces | Golden Launch Loop coverage | Manual evidence |
| --- | --- | --- | --- |
| Create a meaningful goal | Goals, Goal Detail, Today, Plan | Plan / doable path, Today / next action, Proof / receipt, Trust / privacy | Goal exists; next step visible; contained Steps language; no Tasks tab. |
| Capture a loose thought and place it | Capture, Goals, Plan, Today | Capture, Place / routing, Proof / receipt, Trust / privacy | Capture saved; Suggested place or Needs a Place; route receipt; correction available. |
| Recover from a missed day | Today, Plan, Reviews, You | Today / next action, Recovery, Proof / receipt, Trust / privacy | Recovery copy is non-shaming; no silent calendar write; review/receipt context visible. |
| Resolve an overloaded week | Plan, Today, Goals, You | Plan / doable path, Recovery, Proof / receipt, Trust / privacy | Too much planned state; confirmation boundary; no silent external write. |
| Review proof and receipts | Goal Detail, Reviews, You | Proof / receipt, Trust / privacy | Proof visible; receipt summary; privacy-safe wording. |
| Inspect What Ambitions Knows | You, Reviews | Trust / privacy | Source labels; freshness labels; used-for copy; safe blocked controls. |
| Use denied-calendar fallback | Plan, Today, You | Plan / doable path, Today / next action, Recovery, Trust / privacy | Manual fallback; Plan-owned permission boundary; no connected-calendar claim. |
| Start with a One-Step Goal | Capture, Today, Goals | Capture, Place / routing, Today / next action, Proof / receipt | Task is standalone; Steps remain contained; no Tasks tab. |
| Park, defer, or drop noncritical work | Today, Plan, Goals, Reviews | Today / next action, Recovery, Proof / receipt | Park/defer/drop available where supported; non-shaming copy; change remains explainable. |
| Return after a week away | Today, Plan, Goals, Reviews, You | Today / next action, Recovery, Proof / receipt, Trust / privacy | One re-entry move; stale context visible; review need visible. |

### M01 Blocker Classification

| Blocker | Owner batch | Severity | Evidence needed |
| --- | --- | --- | --- |
| Export/import disaster drill is still unproven | M02 | Blocking | Portable export/import scenario, safe failure state, and restore proof. |
| No-lost-data and migration hardening needs dedicated proof | M03 | Blocking | Offline, migration, corrupt/partial data, and receipt integrity tests. |
| External surfaces still need real-device platform verification | R04-R05 / human-device gate | High | M04 added a code-backed verification checklist plus simulator/unit proof for stale/private/failure contracts, and R03 added a release-readiness report that keeps rendered widget, Live Activity lifecycle, notification delivery, Shortcuts/Siri, and installed-device shared-container I/O blocked until physical-device proof exists. |
| Path editing and confirmed roadmap mutation remain maturity work | M10-M12 | Medium | M07 added Goal Detail Path Builder UI with phases, dependencies, fork prompts, proof checks, Today/Plan handoff copy, accessible list fallback, and a compact performance budget, but it does not add broad path editing, automatic roadmap changes, persistence/export/sync changes, or real-device/manual UI proof. |
| Memory correction and narrative memory execution controls need deeper confirmation boundaries | M10-M12/R-gates | Medium | M08 added reviewable narrative memory and conservative pattern signals with source/freshness/use labels and safe-vs-blocked controls, but broad destructive deletion, global pause/forget preferences, real-device/manual UI proof, and rendered accessibility proof remain unclaimed. |
| Reviews and Life OS Receipt need scenario maturity beyond service/UI projection | M10-M12/R-gates | Medium | M09 added weekly/monthly/recovery cadence summaries, progress receipt lines, and safe planning handoffs; broader scenario/manual proof, archive/search depth, and rendered accessibility proof remain unclaimed. |
| Portfolio and recovery maturity need broad scenario proof | M10-M11 | Medium | Goal Weather/scope checks, waiting/commitment behavior, Save-the-Day maturity, and undo/receipt proof. |
| Cross-surface continuity and mature performance need device proof | R04-R05 / human-device gate | High | M12 added continuity handoff proof and mature performance checks; R02 added a code-backed performance/responsiveness evidence report with simulator/source proof; R03 added device-readiness classification while keeping real-device responsiveness, cold-start timing, memory pressure, touch latency, large-data scrolling, and rendered external-platform performance unclaimed. |
| Public accessibility claims remain locked | R05 / human accessibility gate | Blocking | R01 added a claims lock over internal evidence and R04 kept public copy blocked; manual VoiceOver, Dynamic Type, Reduce Motion, contrast, motor, and external-surface accessibility review are still needed before any public accessibility claim can promote. |
| Device QA, App Store materials, and RC lock need human/device gates | R05 / human-device gate | Blocking | R03 records simulator/source device-readiness evidence but does not prove physical-device QA or TestFlight upload readiness; R04 prepares a code-backed external-truth packet for privacy/demo/materials while keeping screenshots, live URLs, signed archive/App Store Connect validation, and explicit human approval gated. |
