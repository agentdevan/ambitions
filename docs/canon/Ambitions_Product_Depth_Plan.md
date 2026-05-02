# Ambitions Product Depth Plan
<!-- markdownlint-disable MD013 -->

Status: Future canon; Product Depth train not started
Date: 2026-05-02

## Purpose

Product Depth is the future Ambitions lane for making the existing product surfaces deeper, more trustworthy, and more useful without widening the app. It turns secondary information, proof, review, recovery, setup, and continuity into owned drill-downs behind the existing five top-level surfaces.

This plan is not implementation approval. It does not start Product Depth, REC02, PXOS, ME, CS, AOS, or release work.

## Governing Rule

Product Depth deepens these surfaces only:

- Today
- Goals
- Capture
- Plan
- You

Product Depth must not add new top-level destinations, generic dashboards, stacked-card top-level screens, habit tracker modes, calendar clones, chatbot-first AI surfaces, inbox/notes modes, or enterprise project-management systems.

Top-level surfaces remain visual orientation surfaces. Detail belongs behind drill-downs, sheets, owned lanes, receipt views, review surfaces, setup flows, or proof/history surfaces.

## Source Truth

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/PXOS_Product_Depth_And_Drilldown_Rules.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`

## Train Definition

Train name: `PD01-PD18 Product Depth Train`

Status: Future/not started.

Required approval phrase: `Start Product Depth Train`.

Purpose: deepen Ambitions' existing surfaces through drill-downs, detail flows, proof, recovery, review, setup, and cross-surface continuity without adding top-level sprawl.

## Depth Inventory By Surface

| Surface | Allowed depth | Must not become |
| --- | --- | --- |
| Today | Step Detail, Step Session, closure/recovery, Still Counts, proof preview, source labels | Task list, timer-first focus app, productivity dashboard |
| Goals | Mission Control lanes, lifecycle/path visualization, proof and decision history, alternate path tradeoffs | Kanban board, OKR dashboard, habit tracker |
| Capture | Needs a Place, Ready to Place, placement review, correction loops, Grow into Goal | Inbox/feed, notes app, automatic goal factory |
| Plan | Reflow decisions, pressure recovery, Life Shape drill-downs, capacity/protected-time explanation | Calendar clone, dense event grid, shame loop |
| You | Trust history, receipts center, source review, schedule/defaults, automation history | Vanity analytics dashboard, account/settings sprawl |
| Cross-surface | Proof/review links across Capture, Today, Goals, Plan, and You | New review tab, generic activity feed |

## Top-Level Vs Drill-Down Matrix

| Question | Top-level allowed? | Drill-down required? |
| --- | --- | --- |
| Is this needed for immediate orientation or one primary action? | Yes | No |
| Is this proof/history/source detail? | No | Yes |
| Is this setup, preference, or privacy configuration? | No | Yes |
| Is this a receipt, decision log, or review trail? | No | Yes |
| Would showing it create a vertical stack of generic cards? | No | Yes |
| Would it require a new tab or product mode? | No | Block |

## Implementation Dependency Map

- PXOS: PX14 and PX18 must be Green before PD formalization is executable for implementation. Surface-specific PX gates apply to every PD batch.
- ME: Today, Goals, Capture, Plan, and You owner files must pass relevant maintainability gates before large UI expansion.
- CS: route, raw-value, deep-link, widget, App Intent, import/export, and persistence seams must pass compatibility gates before retirement or navigation changes.
- AOS: runtime, recommendation, proof, source-truth, alternate-path, adaptation, reality-drift, or commitment-time logic is a blocker unless the relevant AOS gates are Green.
- REC: release/platform claims remain blocked unless evidence exists.

## Batch Map

| Batch | Name | Type | Primary surface |
| --- | --- | --- | --- |
| PD01 | Product Depth Canon, Inventory, and Ownership Map | Docs/planning | Cross-surface |
| PD02 | Today Step Detail Depth | Implementation | Today |
| PD03 | Today Step Session Depth | Implementation | Today |
| PD04 | Today Recovery and Closure Depth | Implementation | Today / Recovery |
| PD05 | Goals Mission Control Detail Architecture | Implementation | Goals |
| PD06 | Goal Lifecycle and Path Visualization | Implementation | Goals |
| PD07 | Goal Proof and Decision History Depth | Implementation | Goals / Proof |
| PD08 | Goal Alternate Path and Tradeoff Depth | Implementation | Goals |
| PD09 | Capture Placement Review | Implementation | Capture |
| PD10 | Capture Correction and Confidence Loops | Implementation | Capture |
| PD11 | Grow Into Goal Flow | Implementation | Capture / Goals |
| PD12 | Plan Reflow Decision Depth | Implementation | Plan |
| PD13 | Plan Recovery and Pressure Review | Implementation | Plan |
| PD14 | Life Shape Drill-Downs | Implementation | Plan |
| PD15 | You Trust History and Receipts Center | Implementation | You |
| PD16 | Schedule, Availability, and Planning Defaults Depth | Implementation | You |
| PD17 | Cross-Surface Proof and Review Integration | Mixed implementation | Cross-surface |
| PD18 | Product Depth Handoff and Next-Lane Readiness | Docs/handoff | Cross-surface |

## Blocked And Unblocked Status

All PD batches are future/not started. PD01 may be selected only after the required approval phrase and prerequisite gates. PD02-PD18 remain blocked until their named PXOS, ME, CS, AOS, REC, validation, and predecessor gates are Green or accepted Yellow.

## Anti-Sprawl Tests

Every PD batch must prove:

- no new top-level tab;
- no generic dashboard or card-stack top-level surface;
- no chatbot-first AI surface;
- no calendar clone;
- no habit tracker mode;
- no notes/inbox mode;
- no enterprise project-management mode;
- detail belongs to an existing top-level surface or cross-surface proof/review path.

## What This Plan Does Not Prove

This plan does not prove implementation, release readiness, TestFlight readiness, App Store readiness, physical-device proof, public accessibility conformance, signed archive validation, App Store Connect validation, external-platform rendering, PXOS implementation, or AmbitionsOS implementation.
