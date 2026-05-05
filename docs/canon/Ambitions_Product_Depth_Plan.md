# Ambitions Product Depth Plan
<!-- markdownlint-disable MD013 -->

Status: Active Product Depth canon in the Ambitions 4.0 Execution Program; PD01 accepted Yellow; PD02 accepted Yellow as bounded Today Step Detail implementation; PD03 accepted Yellow as bounded Today Step Session implementation; PD04 accepted Yellow as bounded Today recovery/closure implementation; PD05 Green as bounded Goals Mission Control Detail Architecture implementation; PD06 Green as bounded Goal Lifecycle and Path Visualization implementation; PD07 accepted Yellow as bounded Goal Proof and Decision History implementation; PD08 accepted Yellow as bounded Goal Alternate Path and Tradeoff implementation; PD09 accepted Yellow as bounded Capture Placement Review implementation; PD10 accepted Yellow as bounded Capture Correction Review implementation; PD11 accepted Yellow as bounded Grow Into Goal Flow implementation
Date: 2026-05-02

## Purpose

Product Depth is the future Ambitions lane for making the existing product surfaces deeper, more trustworthy, and more useful without widening the app. It turns secondary information, proof, review, recovery, setup, and continuity into owned drill-downs behind the existing five top-level surfaces.

This plan is not broad implementation approval. PD01 started only after the
required approval phrase was provided. PD01 creates canon, inventory,
ownership, and dependency truth. PD02 starts Product Depth implementation only
inside the named Today Step Detail boundary. Neither batch starts REC02,
restarts PXOS, restarts ME/CS/AOS, resumes the global train, or creates release
work.

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
- `docs/canon/Ambitions_Product_Depth_Canon_Inventory_And_Ownership_Map.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Final_File_Boundary_Approval.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`

## Train Definition

Train name: `PD01-PD18 Product Depth Train`

Status: Active after approval phrase; PD01 is accepted Yellow as the
docs/planning source-truth batch. PD02 is accepted Yellow as bounded Today Step
Detail implementation. PD03 and PD04 are accepted Yellow as bounded Today depth
implementation. PD05 is Green as bounded Goals Mission Control detail
architecture implementation. PD06 is Green as bounded Goals lifecycle/path
visualization implementation. PD07 is accepted Yellow as bounded Goals proof
and decision history implementation. PD08 is accepted Yellow as bounded Goals
alternate path/tradeoff implementation. PD09 is accepted Yellow as bounded
Capture placement review implementation. PD10 is accepted Yellow as bounded
Capture correction review implementation. Later Product Depth implementation
remains blocked until each individual PD implementation batch runs, validates,
commits, and closes.

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

## PD01 Canon And Ownership Map

PD01 created
`docs/canon/Ambitions_Product_Depth_Canon_Inventory_And_Ownership_Map.md` as
the formal Product Depth source-truth map.

That map defines:

- Product Depth definition.
- Product Experience Pack alignment.
- drill-down inventory by surface.
- feature-depth candidate ownership.
- implementation dependency map.
- blocked/unblocked status.
- conflict register.
- Product Depth acceptance rules.

The map preserves documented Yellow conflicts and caveats: accent
taxonomy/default mismatch, MissionControlTimeSpine order mismatch/unknown,
user-facing copy-boundary remediation, Step Session depth unknown, Month
LifeShape calendar-clone risk, You / Privacy / Receipts copy-density risk, and
Candidate item status.

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

PD01 may run after the required approval phrase and prerequisite gates. PD01
closed accepted Yellow with docs-only evidence. PD02 closed accepted Yellow as
bounded Today implementation evidence after focused Today tests and local
build validation. PD03 closed accepted Yellow as bounded Today Step Session
implementation evidence after focused Today tests and local build validation.
PD04 closed accepted Yellow as bounded Today recovery/closure implementation
evidence after focused Today tests and local build validation. PD05 closed
Green as bounded Goals Mission Control detail architecture implementation
after focused Goal Detail tests and local build validation. PD06 closed Green
as bounded Goals lifecycle/path visualization implementation after focused Goal
Detail tests and local build validation. PD07 closed accepted Yellow as bounded
Goal proof and decision history implementation after focused Goal Detail tests
and local build validation. PD08 closed accepted Yellow as bounded Goal
alternate path/tradeoff implementation after focused Goal Detail tests and
local build validation.

PD11 closed accepted Yellow as bounded Capture/Goals implementation evidence
after focused Capture/Create Goal/Goal Creation tests and local build
validation. Create Goal now includes a presentation-derived goal seed review
for why this might be a goal, starting position, first milestone, first
recommended step, proof/source seed, and confirmation before promotion without
automatic goal creation, route/raw-value changes, persistence/schema changes,
or AOS runtime changes.

PD12-PD18 remain blocked until their named PXOS, ME, CS, AOS-if-needed, REC,
validation, and predecessor gates are Green or accepted Yellow.

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


## Signature Interface Dependencies

Product Depth now depends on the queued SI train where relevant. PD02-PD04 depend on SI04/SI05/SI10/SI12/SI13/SI17. PD05-PD08 depend on SI06/SI07/SI10/SI12/SI14/SI17. PD09-PD11 depend on SI09/SI12/SI13/SI17. PD12-PD14 depend on SI08/SI12/SI13/SI17. PD15-PD16 depend on SI03/SI10/SI11/SI13/SI14. PD17 depends on SI03/SI10/SI12/SI17. PD18 depends on SI18.

SI01-SI18 are complete as accepted-Yellow Signature Interface evidence. These
dependencies do not prove Product Depth implementation. They prevent depth work
from using generic UI where Ambitions-native primitives should exist.
