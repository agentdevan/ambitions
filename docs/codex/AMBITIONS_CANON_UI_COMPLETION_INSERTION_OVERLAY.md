# AmbitionsCanon UI Completion Insertion Overlay

Status: Active global-batch-train overlay
Date: 2026-05-08
Owner: AmbitionsCanon / Global Batch Train

## Purpose

This overlay tells the live global batch train to finish the full AmbitionsCanon product UI implementation at the earliest safe insertion point, then resume and continue the normal global batch train until all eligible batches are complete or an unrecoverable Red stops execution.

This file does not mark UI work complete by itself. It adds an active insertion rule for Codex/global-train execution.

## Source Truth Priority

For product, visual, IA, shell, chrome, trust, accessibility, QA, token/material, and Signature Object work:

1. `docs/AmbitionsCanon/Ambitions_Design_System.md`
2. `docs/AmbitionsCanon/00_Canon_Index_10_10_Maturity_Gate.md`
3. `docs/AmbitionsCanon/01_Product_Canon.md`
4. `docs/AmbitionsCanon/02_Continuity_Layer_Chrome.md`
5. `docs/AmbitionsCanon/03_Signature_Object_Specs.md`
6. `docs/AmbitionsCanon/04_Trust_Privacy_Automation.md`
7. `docs/AmbitionsCanon/05_Accessibility_Motion_Performance.md`
8. `docs/AmbitionsCanon/06_QA_Preview_Visual_Drift.md`
9. `docs/AmbitionsCanon/07_Native_Shell_Tokens_Materials.md`
10. `docs/AmbitionsCanon/08_Implementation_Codex_Repo_Integration.md`
11. Repo registry/run-state evidence for implementation status only
12. Existing repo convenience

Older 3.0, PXOS, SI, FCP, PFC, AOS, LDI, handoff, audit, and train docs do not override AmbitionsCanon where conflicts exist.

## Required Live Train Rule

At the next safe batch boundary, before selecting unrelated future work, insert:

`ACUI01-ACUI10 — AmbitionsCanon Product UI Completion Lane`

Earliest safe boundary means:

1. current active batch is Green or safely parked Yellow,
2. registry/run-state/report updates are written,
3. failures caused by the active batch are repaired or parked with evidence,
4. no Red is active,
5. no broad migration/persistence/routing prerequisite blocks ACUI.

Do not interrupt an active batch mid-edit unless continuing would violate AmbitionsCanon.

If the train is already inside a dependency chain, close only the minimum dependency batches required to reach a safe ACUI insertion boundary, then run ACUI.

## ACUI Batch Order

### ACUI01 — Canon Implementation Boundary Reconciliation

Produce `docs/handoff/ACUI01_AmbitionsCanon_UI_Implementation_Boundary_Report.md` with current owner files, already-proven UI evidence, missing UI evidence, and exact ACUI boundaries.

### ACUI02 — Token And Material Canon Bridge

Safely evolve theme/design-system aliases into usable AmbitionsCanon semantic tokens and materials while preserving persistence/default compatibility. Exact values remain candidate until visual QA.

### ACUI03 — Shell, Continuity Dock, Context Crown, Meridian Edge

Align shell and tab chrome with AmbitionsShell, Continuity Dock, Context Crown, and Meridian Edge. Preserve exactly Today, Goals, Capture, Plan, You. No sixth tab, no Capture plus tab, no red badge/count system.

### ACUI04 — Trust Seam, Receipt Surface, Quiet Reflow Foundation

Align trust/receipt/proof/reflow primitives with Trust Seam, Receipt Surface, and Quiet Reflow. Source/control/receipt paths must be inspectable. No chatbot drawer or notification feed. Launch automation remains capped at Manual, Suggest, Preview Reflow.

### ACUI05 — Today Reality Meridian And Start Here Surface

Complete Today as Reality Meridian plus Start Here Surface. Start Here must emerge from active Meridian state. Preserve Start here, Recommended step, Start now, Open step, Adjust plan, Why this?, Still counts. Avoid task-list dominance and detached cards.

### ACUI06 — Capture Atmosphere Composer

Complete Capture as Atmosphere Composer: composer-first, bottom-oriented, keyboard-native, route reveal only after input, routes Needs a Place / Ready to Place / Grow into Goal. No feed, inbox, chatbot, or category-board default.

### ACUI07 — You User System Profile, Automation & Trust, Privacy Controls

Complete Profile-to-You mapping as User System Profile. Preserve iOS Settings-like grouped navigation. Expose Planning Setup, Schedule & Availability, Planning Defaults, Vacation / Away Time, Automation & Trust, Privacy, Receipts/History. No social profile, family layer, search-first UI, or admin console drift.

### ACUI08 — Plan LifeShape Field

Complete Plan as LifeShape Field. Default to Week where canon requires. Show open time, goal time, protected time, pressure, and reflow preview. Avoid calendar clone, analytics dashboard, red-alert pressure, and silent rearrangement.

### ACUI09 — Goals Constellation Atlas And Orbital Lens

Complete Goals as Constellation Atlas plus Orbital Lens. Support equal-weight life areas by default. User-owned reorder/pin/hide/rename where architecture supports it. Mission Control remains inside Goal Detail only. Avoid KPI dashboard, ranked life score, habit-ring primary model, and astrology drift.

### ACUI10 — Accessibility, Reduce Motion, Preview Fixture, Visual QA Hardening

Complete object-level accessibility summaries and controls, Reduce Motion equivalents, required preview fixture matrix where feasible, and visual QA/validation reports. Do not claim public accessibility, device, performance, release, TestFlight, or App Store readiness without proof.

## Required ACUI Reporting

Each ACUI batch must report:

- Status: Green / Yellow / Red
- files inspected
- files changed
- files intentionally not changed
- validation commands run
- validation not run
- accessibility notes
- Reduce Motion notes
- trust/source/receipt notes
- top-level IA safety
- known limitations

Create or update final ACUI report:

`docs/handoff/ACUI_AmbitionsCanon_Product_UI_Completion_Report.md`

## Resume Global Batch Train After ACUI

After ACUI01-ACUI10 complete, or safe Yellow items are parked with owners and no-claim boundaries, resume the normal global batch train from repo evidence.

Continue automatically until all eligible batches complete or an unrecoverable Red stops execution.

Do not restart completed batches. Do not duplicate work already proven by registry, run-state, commit, or audit evidence. Do not skip gates.

## Hard Reds

Stop if any occur:

1. Mission Control becomes top-level.
2. A sixth top-level tab is added.
3. Capture becomes feed, inbox, chatbot, category board, or plus-tab UI.
4. Today becomes generic task list or calendar timeline.
5. Plan becomes calendar clone.
6. Goals becomes KPI dashboard, habit tracker, astrology, or ranked life score.
7. You becomes social profile, family hub, or admin console.
8. Continuity signals appear outside Context Crown, Meridian Edge, Continuity Dock, or Trust Seam.
9. Trust becomes chatbot/AI coach.
10. Automation exceeds Manual / Suggest / Preview Reflow without later explicit canon and proof.
11. Primary object depends on visual-only meaning.
12. Reduced Motion removes essential meaning.
13. Exact token values are claimed final without visual QA.
14. Release, public accessibility, physical-device, TestFlight, App Store, legal/privacy, or production readiness is claimed without matching evidence.
