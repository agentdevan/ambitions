# Global Optimized Implementation Order
<!-- markdownlint-disable MD013 -->

Status: Active global order overlay for remaining implementation selection.
Date: 2026-05-05

## Purpose

This document updates the remaining global batch order so Codex selects prompts in the best implementation order regardless of original train grouping. It is an execution map, not execution approval.

The legacy `GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md` preserves historical global numbering and completed batch evidence. This optimized order governs remaining batch selection when it conflicts with train-block order, while preserving canonical batch IDs and hard dependencies.

## Current Baseline

As of this order update:

- Ambitions 4.0 remains an active post-3.0 execution program, not a shipped product version.
- Top-level surfaces remain `Today / Goals / Capture / Plan / You`.
- Product Depth is complete through PD18 Green.
- CQS is inserted after PD17 and before PD18 so remaining batches use the
  upgraded repair/reviewer/script gates.
- Found Life Layer source truth is active. FL01 is complete Green with an
  accepted Yellow order-reconciliation note after the remote Found Life source
  arrived after FCP17 had already landed. FL02 is complete Green as docs-only
  Life Inventory object model; FL03 is complete Green as docs-only Commitment
  Memory / Open Loop Registry contract; FL04 is complete Green as docs-only
  Searchable Life Recall contract; FL05 is complete Green as docs-only Option
  Value / Pivot Preservation contract; FL06 is complete Green as docs-only
  Weekly Life Sweep ritual source truth.
- FCP source-truth docs exist, and FCP17 has completed as the first bounded FCP
  implementation batch. Further FCP implementation now depends on completed
  FL01-FL06 source truth.
- AOS01-AOS30 remain queued.
- LDI01-LDI22 remain queued and are inserted by dependency, not train silo.
- CS02C-CS06C and CS09C remain deferred/blocked until a named compatibility proof target exists; they are not part of the happy-path optimized order.

## Selection Rule

Codex must select the next eligible remaining batch from this optimized order after all of the following pass:

1. Exact approval phrase or global preauthorization exists.
2. The batch's source-truth stack is read.
3. Hard dependencies are Green or accepted Yellow.
4. No Red condition exists.
5. File-boundary and validation gates are known.

If this file and a train manifest conflict, use the stricter dependency, stricter gate, or safer order. If the conflict affects safety, stop and write a reconciliation report.

## Approval Phrase Update

The global approval phrase `Run Global Batch Sequence Until Blocked` may attempt the next eligible batch from this optimized order only if the user's prompt explicitly preauthorizes cross-train sequencing.

Train-specific approval remains valid for a single train only:

- `Start Product Depth Train`
- `Start Flagship Completion Train`
- `Start AOS Train`
- LDI starts by global optimized order after required prerequisites or by explicit user decision for an individual earlier dependency split.

## Optimized Remaining Order

| Optimized | Batch / Prompt | Train | Type | Why this position | Required dependency/gate | Continuation |
| ---: | --- | --- | --- | --- | --- | --- |
| 001 | FCP Registry / Context Reconciliation | FCP / Governance | Docs | Makes FCP discoverable without corrupting large registry/run-state files. | FCP source-truth files exist. No production Swift. | May continue on Green. |
| 002 | FCP01 Flagship Completion Source Truth Lock | FCP | Docs | Completed Green on 2026-05-05 as docs-only source-truth lock. | Reconciliation Green or accepted Yellow. | Complete; next FCP02. |
| 003 | FCP02 Object Vocabulary And Anatomy Lock | FCP | Docs | Completed Green on 2026-05-05 as docs-only vocabulary/anatomy lock. | FCP01. | Complete; next FCP03. |
| 004 | FCP03 Ownership / File Boundary / Dependency Map | FCP | Docs | Completed Green on 2026-05-05 as docs-only ownership/file-boundary/dependency map. | FCP02. | Complete; next FCP04. |
| 005 | FCP04 Preview Fixture And QA Matrix Expansion | FCP | Docs / Fixture planning | Completed Green on 2026-05-05 as docs-only preview/QA matrix expansion. | FCP03. | Complete; next PD16 by full-stack order. |
| 006 | PD15 You Trust History And Receipts Center | PD | Implementation | Completed Green as You trust/receipt depth before Personal System Center and Receipt Drawer integration. | PD14 Green; PD train gates. | Completed. |
| 007 | PD16 Schedule Availability And Planning Defaults Depth | PD | Implementation | Completed Green as You/Profile planning-defaults depth before Start Here time-fit and Availability Center. | PD15 Green/accepted Yellow. | Complete. |
| 008 | PD17 Cross-Surface Proof And Review Integration | PD | Implementation | Completed Green on 2026-05-05 as bounded proof/review bridge before FCP proof spine and final mesh. | PD16 Green/accepted Yellow. | Complete; next CQS insertion by user directive. |
| 009 | CQS01-CQS24 Codex Quality System | CQS / Codex OS | Docs / Scripts / Skills | Completed Green on 2026-05-05 as mature repair cycle, reviewer skill, advisory quality scan, and hard-Red-only stopping layer before remaining implementation trains. | PD17 Green; no production Swift unless explicitly scoped by a later batch. | Complete; next PD18. |
| 010 | PD18 Product Depth Handoff And Next-Lane Readiness | PD | Handoff | Completed Green on 2026-05-05 as docs-only Product Depth closeout with upgraded Codex OS quality layer available. | PD17 Green/accepted Yellow; CQS Green/accepted Yellow if inserted. | Complete; full-stack order selects PFC01 next before FCP implementation. |

Full-stack insertion after optimized row 010: PFC01 is complete / Green as
repo/build inventory. PFC02 is complete / Green as architecture boundary map.
PFC03 is complete / Green as dead-code, prompt-artifact, and naming-smell audit.
PFC04 is complete / Green as dependency and supply-chain policy ledger. PFC05
is complete / Green as local CI parity wrapper and toolchain runbook update.
PFC06 is complete / Green as schema and persistence source truth. PFC07 is
complete / Green as focused migration/backward-compatibility proof. PFC08 is
complete / Green as corruption recovery / backup / restore planning evidence.
PFC09 is complete / Green as a local-only/no-launch-sync strategy decision
record. PFC10 is complete / Green as a docs-only future CloudKit
schema/zone/conflict contract and PFC11 test plan. PFC11 is complete / Green as
explicit local-only sync closure and safe deferral under current local-only
truth. PFC14 is complete / Green as bounded WidgetKit projection hardening and
focused-test evidence. PFC16 is complete / Green as bounded ActivityKit source
hardening and focused-test evidence; PFC18 is the next eligible remaining PFC
implementation batch in the live global order.
PFC12 is complete / Green as app-group/shared-storage boundary evidence. It
documented the existing app/widget/share extension entitlement match,
privacy-safe shared snapshot and external creation queue boundaries, and focused
test proof. PFC13 is complete / Green as WidgetKit object map and privacy
matrix strategy. FVQ01, FVQ02, and FVQ03 are complete / Accepted Yellow as
rendered visual evidence. FVQ04 is complete / Green as the recurring
UI-batch rendered proof protocol. MEG01 is complete / Green as the
advanced-rendering eligibility gate. FVQ05 is complete / Green as the final
visual proof packet integration hook. PFC15 is complete / Green as Live
Activities / ActivityKit strategy. PFC17 is complete / Green as App Intents /
Shortcuts / Spotlight strategy. PFC19 is complete / Green as Notifications /
Focus / Calendar / Reminders integration strategy, so the next global batch is
PFC21. PFC21 is complete / Accepted Yellow as StoreKit / monetization strategy.
PFC24 is complete / Green as Privacy Data Map And App Privacy Labels evidence.
PFC25 is complete / Green as Privacy Manifest / Required-Reason API Audit
evidence. PFC26 is complete / Green as Terms / Privacy Policy / Legal Review
Packet evidence. PFC27 is complete / Green as Safety / Professional Boundary /
Crisis Policy evidence. PFC28 is complete / Green as Security Threat Model And
Secrets Audit evidence. PFC29 is complete / Green as Logging / Analytics /
Observability Policy evidence. PFC30 is complete / Green as Performance Budget
And Instruments Plan evidence, so the next global batch is FCP22.
Found Life
FL01 is complete / Green as product-soul source truth
with accepted Yellow order reconciliation because FCP17 landed before the
remote Found Life insertion. FL02 is complete / Green as docs-only Life
Inventory object model. FL03 is complete / Green as docs-only Commitment Memory
/ Open Loop Registry contract. FL04 is complete / Green as docs-only
Searchable Life Recall contract. FL05 is complete / Green as docs-only Option
Value / Pivot Preservation contract. FL06 is complete / Green as docs-only
Weekly Life Sweep ritual contract. The full-stack order now selects FCP06
Receipt Drawer / Trust Layer before any further FCP implementation.
| 011 | FCP17 Schedule / Availability / Defaults Center | FCP | Implementation | Completed Green on 2026-05-05 as bounded You-owned Availability Center with hard context, protected pockets, defaults, automation trust, durations, and away behavior. | PD16; FCP01-FCP04. | Complete; next FCP06. |
| 011A | FL01 Founder Backstory / Product Soul Lock | FL | Docs / Canon | Completed Green on 2026-05-05 as Found Life product-soul lock, with accepted Yellow order reconciliation because FCP17 had already landed. | PFC12; Found Life canon. | Complete; next FL02. |
| 011B | FL02 Life Inventory Object Model | FL | Docs / Domain contract | Completed Green on 2026-05-05 as life-thread ownership, privacy class, freshness, and surface mapping source truth before further FCP/AOS/LDI work. | FL01. | Complete; next FL03. |
| 011C | FL03 Commitment Memory / Open Loop Registry | FL | Docs / Domain contract | Completed Green on 2026-05-05 as promise/open-loop states before recall, receipts, and Start Here use them. | FL02. | Complete; next FL04. |
| 011D | FL04 Searchable Life Recall Contract | FL | Docs / Trust contract | Completed Green on 2026-05-05 as source/freshness/privacy/review rules before memory or recall behavior is exposed. | FL02-FL03. | Complete; next FL05. |
| 011E | FL05 Option Value / Pivot Preservation Model | FL | Docs / Intelligence contract | Completed Green on 2026-05-05 as proof transfer and path uncertainty before Goals/AOS/LDI path work. | FL02-FL04. | Complete; next FL06. |
| 011F | FL06 Weekly Life Sweep Ritual | FL | Docs / Ritual contract | Completed Green on 2026-05-05 as the non-shaming weekly continuity ritual before future Start Here/Reality Rail/AOS use. | FL01-FL05. | Complete; next FCP06 by full-stack order. |
| 012 | FCP06 Receipt Drawer / Trust Layer | FCP | Implementation | Completed Green on 2026-05-05 as shared ReceiptDrawer / SourceFold trust foundation before Start Here/Rail/Plan/Goal integrations mature. | FCP01-FCP04; PD15/PD17 preferred. | Complete; next FCP05. |
| 013 | FCP05 Start Here Surface | FCP | Implementation | Completed Green on 2026-05-05 as Today-owned Start Here decision surface with Context Edge, Time Fit Proof, Goal Thread, source quality, because line, primary/secondary actions, and Receipt Drawer seam. | FCP01-FCP04; PD02-PD04; FCP06/FCP17 preferred. | Complete; next FCP07. |
| 014 | FCP07 Reality Rail Continuity | FCP | Implementation | Completed Green on 2026-05-05 as Today-owned continuity spine connecting Start Here, Now/Next/Later, closure, proof, and pressure without hidden mutation. | FCP05/FCP06. | Complete; next FCP13A. |
| 015 | FCP13A Action Closure Diamond | FCP split | Implementation | Completed Green on 2026-05-05 as Today-owned closure / decision object with Outcome, Consequence, Proof, Recovery, accessibility, Dynamic Type, and Reduce Motion equivalents. | FCP05-FCP07; PD04; FCP06. | Complete; next FCP08. |
| 016 | FCP08 Ambition Meridian Shell | FCP | Implementation | Completed Green on 2026-05-05 as default Meridian shell presentation with native rollback, five destinations, receipt overlay zone contract, and focused shell proof. | FCP05-FCP07 preferred; SI03/SI17. | Complete; next FCP09. |
| 017 | FCP09 Motion / Haptics / Reduced Motion Proof | FCP | Implementation | Completed Green on 2026-05-05 as shared object-motion policy evidence for Start Here, Reality Rail, Receipt Drawer, Source Fold, MissionControlTimeSpine, Action Closure Diamond, LifeShape, and Capture with non-motion cues, Reduce Motion equivalents, bounded user-initiated haptic policy, preview evidence, and focused tests. | FCP05-FCP08; SI12; DAV10. | Complete; PFC13, FVQ01-FVQ05, MEG01, PFC15, PFC17, PFC19, PFC21, PFC24, PFC25, PFC26, PFC27, PFC28, PFC29, and PFC30 are also complete; global order next selects FCP22. |
| 018 | FCP22 Personal System Center Refactor | FCP | Implementation | Completed Green on 2026-05-05 as bounded You root Personal System Center implementation evidence with Planning Setup first, Trust / Memory / Receipts prominent, and Personal Defaults separated. | PD15-PD16; FCP06/FCP17; ME06. | Complete; next FCP23. |
| 019 | FCP23 Memory Lens / External Brain Visual Layer | FCP | Implementation | Completed Green on 2026-05-05 as bounded You-owned Memory Lens implementation evidence with source age, why-remembered text, privacy shutter posture, review state, correction posture, and rejection/deletion boundaries. | FCP22; EB memory/trust evidence. | Complete; next FCP24. |
| 020 | FCP24 Appearance Studio | FCP | Implementation | Completed Green on 2026-05-05 as bounded You-owned Appearance Studio object-preview evidence for Start Here, Reality Rail, LifeShape, and Receipt Drawer. | FCP05/FCP07/FCP22. | Complete; next FCP18. |
| 021 | FCP18 Capture Placement Shelf | FCP | Implementation | Completed Green on 2026-05-06 as bounded Capture Placement Shelf evidence with destination, consequence, privacy, local source, correction posture, and receipt seam visible before saving. | FCP06; PD09. | Complete; next FCP19. |
| 022 | FCP19 Placement Resolver / Correction Fold | FCP | Implementation | Completed Green on 2026-05-06 as bounded draft Resolver Fold evidence with what Ambitions thinks, why, user-owned correction choices, and a local correction-receipt seam before saving. | FCP18; PD10. | Complete; next FCP20. |
| 023 | FCP20 Grow Into Goal Seed Incubator | FCP | Implementation | Completed Green on 2026-05-06 as bounded Goal Seed Incubator evidence across Capture and Create Goal review surfaces with explicit promotion confirmation. | FCP18-FCP19; PD11. | Complete; next FCP21. |
| 024 | FCP21 Voice / Motor Capture Accessibility | FCP | Implementation | Completed Green on 2026-05-06 as bounded Capture composer input-alternatives evidence with honest voice-unavailable status, keyboard/system-dictation fallback wording, motor-safe button/menu alternatives, and review-before-save copy. | FCP18-FCP20; EB29/EB30 evidence. | Complete; next FCP14. |
| 025 | FCP14 LifeShape Contour Map | FCP | Implementation | Completed Green on 2026-05-06 as bounded Plan LifeShape Contour Map implementation evidence with capacity contours, protected pockets, pressure fields, recovery pockets, milestone ridges, and commitment-load contours. | PD14; FCP17. | Complete; next FCP15. |
| 026 | FCP15 Reflow Decision Fold | FCP | Implementation | Completed Green on 2026-05-06 as bounded Plan Reflow Decision Fold evidence with before/after shape preview, receipt preview, affected steps, capacity impact, protected-time impact, and accept/edit/decline controls. | FCP14; PD12. | Complete; next FCP16. |
| 027 | FCP16 Pressure Field / Recovery Loop | FCP | Implementation | Completed Green on 2026-05-06 as bounded Plan / Today shared pressure and recovery object-language evidence with Pressure Field, Recovery Loop, Smaller Step Anchor, and Recovery Receipt Preview labels. | FCP13A; FCP14-FCP15; PD13. | Complete; next FCP10. |
| 028 | FCP10 MissionControlTimeSpine | FCP | Implementation | Completed Green on 2026-05-06 as bounded Goal Detail MissionControlTimeSpine evidence that replaces the primary Mission Control grid with an inspectable spine. | FCP06; PD05-PD08. | Complete; next FCP11. |
| 029 | FCP11 LifePath Thread | FCP | Implementation | Completed Green on 2026-05-06 as bounded Goal Detail LifePathThread evidence with proof beads, risk pinch, AlternateRouteFold, GoalPathSourceFold, private redaction, and accessible path order. | FCP10; PD06-PD08. | Complete; next FCP12. |
| 030 | FCP12 Proof Spine / Evidence Ledger | FCP | Implementation | Completed Green on 2026-05-06 as bounded shared ProofSpine / Goal Detail proof integration evidence with source, freshness, privacy, correction, and stale-review boundaries. | FCP06/FCP10/FCP11; PD07/PD17. | Complete; next FCP13B. |
| 031 | FCP13B Goal Alternate Path / Decision History Polish | FCP split | Implementation | Completed Green on 2026-05-06 as bounded Goal Detail Decision Spine evidence with alternate-path and decision-history branches, review/consequence/no-mutation labels, and no automated reroute. | FCP11-FCP12; PD08. | Complete; next FCP25. |
| 032 | FCP25 Loading / Empty / Degraded State Objectization | FCP | Implementation | Completed Green on 2026-05-06 as bounded shared/top-level object-state evidence with a Flagship Object State Matrix and object-specific loading/unavailable states across Today, Goals, Goal Detail, Capture, Plan, and You. | FCP05/FCP10/FCP14/FCP18/FCP22. | Complete; next FCP26. |
| 033 | FCP26 Iconography / Status Grammar Hardening | FCP | Implementation | Completed Green on 2026-05-06 as bounded shared/status-grammar evidence with SI14 placement metadata, shape cues, degraded-card wiring, and focused non-color/status-placement proof. | FCP25; SI14. | Complete; PFC10/PFC11/PFC14/PFC16 are also complete; next PFC18 per live global order. |
| 034 | AOS01 AmbitionsOS Canon And Runtime Contract | AOS | Docs / Contract | Runtime work starts after flagship object slots and product depth exist. | Start AOS Train or global preauthorization. | May continue on Green. |
| 035 | AOS02 Life Graph Event Log Foundation | AOS | Contract/Foundation | Foundation for graph-backed memory/proof. | AOS01. | Single-batch preferred. |
| 036 | AOS03 Graph Delta Review Projection Store | AOS | Contract/Foundation | Projection review precedes control plane and kernels. | AOS02. | Single-batch. |
| 037 | AOS04 Control Plane Work Classifier | AOS | Contract/Foundation | Work classifier gates all kernel behavior. | AOS01-AOS03. | Single-batch. |
| 038 | AOS12 Proof Trust Closure Receipts | AOS | Kernel | Proof/trust/closure kernel should precede recommendation and reflow runtime. | AOS02-AOS04. | Single-batch. |
| 039 | AOS13 Source Truth Claim State Machine | AOS | Kernel | Source truth gates recommendation, proof, and memory. | AOS02-AOS04. | Single-batch. |
| 040 | AOS10 Commitment Time Kernel | AOS | Kernel | Real capacity/time kernel should precede reflow and recommendation runtime. | AOS02-AOS04. | Single-batch. |
| 041 | AOS05 Starting Position Kernel | AOS | Kernel | Starting position feeds goal compiler and recommendation. | AOS02-AOS04. | Single-batch. |
| 042 | AOS06 Goal Path Kernel Goal Compiler | AOS | Kernel | Goal compiler follows starting position. | AOS05. | Single-batch. |
| 043 | AOS07 Local Goal Packs Requirement Slots | AOS | Kernel | Requirement slots follow compiler. | AOS06. | Single-batch. |
| 044 | AOS08 Alternate Path Kernel Path Portfolio | AOS | Kernel | Alternate path runtime follows goal path slots. | AOS05-AOS07. | Single-batch. |
| 045 | AOS09 Option Value North Star | AOS | Kernel | North Star/option value follows alternate paths. | AOS08. | Single-batch. |
| 046 | AOS11 Reality Drift Bounded Reflow | AOS | Kernel | Reflow runtime follows commitment time and proof/receipt contracts. | AOS10/AOS12. | Single-batch. |
| 047 | AOS14 Recommendation Start Here Kernel | AOS | Kernel | Start Here recommendation follows source/proof/control contracts and flagship UI. | AOS04/AOS12/AOS13; FCP05. | Single-batch. |
| 048 | AOS15 Local Language Kernel Planning | AOS | Kernel | Language planning waits for recommendation/source/fallback boundaries. | AOS04/AOS13/AOS14. | Single-batch. |
| 049 | AOS16 Performance Energy Kernel | AOS | Kernel/QA | Performance budgets must precede runtime-heavy exposure. | Before runtime-heavy implementation. | Single-batch. |
| 050 | AOS17 Privacy Safety Kernel | AOS | Kernel/QA | Privacy contracts must precede sensitive projections. | Before sensitive projection. | Single-batch. |
| 051 | AOS18 Evaluation Golden Scenarios | AOS | Evaluation | Golden scenarios follow kernel contracts. | AOS01-AOS17. | Single-batch. |
| 052 | AOS19 Experience Kernel Celestial Cognitive Load | AOS | Experience contract | Experience language follows evaluation. | AOS18. | Single-batch. |
| 053 | AOS20 Adaptation Kernel Local Personalization | AOS | Kernel | Local calibration follows recommendation and evaluation. | AOS14/AOS18. | Single-batch. |
| 054 | AOS21 Interoperability Kernel App Intents EventKit Planning | AOS | Planning | External interop waits for privacy/performance gates. | AOS16/AOS17. | Single-batch. |
| 055 | AOS22 Longevity Kernel Archive Aging | AOS | Kernel | Archive aging follows graph/proof/source. | AOS02/AOS12/AOS13. | Single-batch. |
| 056 | AOS23 Governance Kernel Registry | AOS | Governance | Registry follows all kernel contracts. | AOS01-AOS22. | Single-batch. |
| 057 | LDI01 Living Dream Architecture Source Truth | LDI | Docs/Contract | LDI begins after AOS governance contracts, before AOS UI integration. | AOS23 or explicit dependency review. | Single-batch. |
| 058 | LDI02 Capture Handling Ladder | LDI | Contract | Dream handling begins with capture ladder. | LDI01. | Single-batch. |
| 059 | LDI03 Dream Safety Legality Feasibility Triage | LDI | Safety | Safety triage must precede path/runtime work. | LDI02. | Single-batch. |
| 060 | LDI04 North Star Extraction | LDI | Contract | Meaning extraction follows safety. | LDI03. | Single-batch. |
| 061 | LDI05 Source Claim Graph | LDI | Contract | Source graph gates requirements and packs. | LDI04. | Single-batch. |
| 062 | LDI06 Pack Registry And Pack Compiler | LDI | Contract | Pack registry follows source graph. | LDI05. | Single-batch. |
| 063 | LDI07 Pack Supply Chain Security | LDI | Security | Pack security must precede pack usage. | LDI06. | Single-batch. |
| 064 | LDI08 Requirement Graph Runtime | LDI | Runtime | Requirement graph follows safe source/pack contracts. | LDI05-LDI07. | Single-batch. |
| 065 | LDI09 Eligibility And Deadline Runtime | LDI | Runtime | Eligibility follows requirement graph. | LDI08. | Single-batch. |
| 066 | LDI10 Starting Position And Privacy Intake | LDI | Runtime | Intake follows safety/source/eligibility. | LDI09. | Single-batch. |
| 067 | LDI11 Path Portfolio Runtime | LDI | Runtime | Path portfolio follows intake. | LDI10. | Single-batch. |
| 068 | LDI12 Capacity And Commitment-Time Bridge | LDI | Runtime | Capacity bridge follows path portfolio and AOS time kernel. | LDI11; AOS10. | Single-batch. |
| 069 | LDI13 Today Bridge And Action Closure | LDI | Runtime | Today bridge follows capacity and FCP closure/Start Here. | LDI12; FCP05/FCP13A. | Single-batch. |
| 070 | LDI14 Trust Review And Dream Handling Receipts | LDI | Trust | Trust receipts follow Today bridge and AOS proof kernel. | LDI13; AOS12. | Single-batch. |
| 071 | LDI15 Living Plan Recompiler | LDI | Runtime | Recompiler follows receipts and mutation-safe context. | LDI14. | Single-batch. |
| 072 | LDI16 Mutation Permissions And Impact Levels | LDI | Safety | Mutation permission gate must precede any living plan mutation. | LDI15. | Single-batch. |
| 073 | LDI20 Freshness Broker | LDI | Source ops | Freshness broker follows source graph and before source-driven UI claims. | LDI05/LDI16. | Single-batch. |
| 074 | LDI21 Red-Team Evaluation Suite | LDI | Evaluation | Abuse resistance before UI integration/claim truth. | LDI16/LDI20. | Single-batch. |
| 075 | LDI17 Continuity Sync | LDI | Continuity | Sync waits until local mutation permissions and red-team baseline exist. | LDI16/LDI21; explicit entitlement boundary. | Single-batch. |
| 076 | LDI18 Archive And Schema Migration | LDI | Persistence planning | Archive/migration follows continuity and mutation model. | LDI17. | Single-batch. |
| 077 | LDI19 Multi-Device Merge Ledger | LDI | Continuity | Merge ledger follows continuity/archive. | LDI17-LDI18. | Single-batch. |
| 078 | LDI22 Governance And Maintenance Console | LDI | Governance | Governance console follows runtime/source/safety/sync surfaces. | LDI01-LDI21. | Single-batch. |
| 079 | AOS24 AmbitionsOS UI Integration | AOS | UI integration | UI integration waits for AOS kernels and LDI safety/runtime gates where relevant. | AOS18-AOS23; LDI01-LDI22 where exposed. | Single-batch. |
| 080 | AOS25 AmbitionsOS Test Fixture Library | AOS | Fixtures | Fixtures follow UI integration. | AOS18/AOS24. | Single-batch. |
| 081 | FCP27 Cross-Surface Proof / Review Mesh | FCP | Integration | Final mesh should integrate PD, FCP, AOS, and LDI proof/review truths. | PD17; FCP06/FCP12/FCP15/FCP19/FCP22; AOS24/AOS25 preferred. | Single-batch. |
| 082 | AOS26 AmbitionsOS Privacy Performance QA | AOS | QA | QA follows UI integration and final proof mesh. | AOS16/AOS17/AOS18/AOS25/FCP27. | Single-batch. |
| 083 | FCP28 Full App 10/10 Audit | FCP | Audit | Full app audit follows UI, proof mesh, and AOS QA. | FCP01-FCP27; AOS26. | Stop on Red. |
| 084 | FCP29 Human Visual / Accessibility / Device Proof Packet | FCP | Human proof packet | Human/device proof packet follows full audit. | FCP28. | Human-proof stop. |
| 085 | AOS27 AmbitionsOS App Store Claim Truth | AOS | Claim truth | Claim truth follows QA and human-proof packet boundaries. | AOS26/FCP29. | Human-proof stop. |
| 086 | AOS28 AmbitionsOS Handoff | AOS | Handoff | AOS handoff follows claim truth. | AOS27. | Single-batch. |
| 087 | FCP30 Flagship Completion Handoff | FCP | Handoff | Flagship handoff follows AOS handoff and proof packet. | FCP29/AOS28. | Closeout. |
| 088 | AOS29 AmbitionsOS Repair Train | AOS | Conditional repair | Runs only if AOS/FCP/LDI Yellows or Reds require repair. | Classified failures. | Conditional only. |
| 089 | AOS30 AmbitionsOS Beyond Roadmap | AOS | Roadmap | Final roadmap follows handoffs or explicit user decision. | AOS28/FCP30 or user decision. | Closeout. |
| 090 | CS02C-CS06C / CS09C Deferred Compatibility Retirements | CS | Conditional repair | Only run if a named owner and proof target exists; never happy-path. | Named compatibility target. | Conditional only. |

## Split-Batch Clarification

FCP13 is split in this optimized order because the 25-object scorecard requires Action Closure Diamond and the FCP train also needs Goal Alternate Path / Decision History polish.

- FCP13A is Today-owned Action Closure Diamond.
- FCP13B is Goals-owned Goal Alternate Path / Decision History Polish and is
  complete Green as Decision Spine evidence.

This split avoids mixing Today closure behavior with Goals alternate-path polish in one broad batch.

## Why This Order Is Better Than Train Blocks

1. FCP planning and registry reconciliation happen before more code.
2. Remaining PD depth closes the exact areas FCP depends on: You trust, Schedule/Availability, Cross-Surface Proof/Review, and handoff.
3. Availability and Receipt foundations land before Start Here, because Start Here needs real time-fit and trust seams.
4. Today flagship objects land before broad shell and motion polish.
5. You, Capture, Plan, and Goals then mature around the shared trust/object language.
6. Loading/degraded and status grammar harden after the major objects exist.
7. AOS kernels then plug into stable product objects instead of forcing UI rework.
8. LDI safety/runtime gates run before AOS UI integration exposes living-dream behavior.
9. Cross-surface proof/review mesh and full-app 10/10 audit run at the end, after runtime and UI integration are real.
10. Release/app-store/claim truth remains last and evidence-bound.

## Stop Conditions Unique To This Optimized Order

Stop if Codex tries to:

- run AOS UI integration before FCP primary objects exist
- run LDI runtime before safety/source/mutation gates
- run FCP final audit before AOS/LDI integration if those scopes were implemented
- run deferred CS retirement without named proof target
- merge FCP13A and FCP13B into one broad batch
- skip PD15-PD18 without explicit user decision and dependency review
- treat this order file as implementation evidence

## No-Claim Boundary

This optimized order does not claim any batch is complete. It does not start FCP, AOS, LDI, CS, Product Depth, AmbitionsOS, release readiness, App Store readiness, TestFlight readiness, physical-device proof, public accessibility proof, durable memory, sync/cloud, or legal/privacy signoff.
