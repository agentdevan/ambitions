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
- Product Depth is active through PD15 Green.
- PD16-PD18 remain queued.
- FCP source-truth docs exist, but FCP implementation has not started until registry/context reconciliation and the required approval phrase.
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
| 004 | FCP03 Ownership / File Boundary / Dependency Map | FCP | Docs | Prevents broad refactors before cross-train work. | FCP02. | May continue on Green. |
| 005 | FCP04 Preview Fixture And QA Matrix Expansion | FCP | Docs / Fixture planning | Defines object state proof before implementation. | FCP03. | May continue on Green. |
| 006 | PD15 You Trust History And Receipts Center | PD | Implementation | Completed Green as You trust/receipt depth before Personal System Center and Receipt Drawer integration. | PD14 Green; PD train gates. | Completed. |
| 007 | PD16 Schedule Availability And Planning Defaults Depth | PD | Implementation | Hard context must precede Start Here time-fit and Availability Center. | PD15 Green/accepted Yellow. | Single-batch preferred. |
| 008 | PD17 Cross-Surface Proof And Review Integration | PD | Implementation | Gives proof/review bridge before FCP proof spine and final mesh. | PD16 Green/accepted Yellow. | Single-batch preferred. |
| 009 | PD18 Product Depth Handoff And Next-Lane Readiness | PD | Handoff | Closes PD before flagship refactor train. | PD17 Green/accepted Yellow. | May continue to FCP if approval covers it. |
| 010 | FCP17 Schedule / Availability / Defaults Center | FCP | Implementation | Build Availability Center before Start Here relies on time-fit proof. | PD16; FCP01-FCP04. | Single-batch. |
| 011 | FCP06 Receipt Drawer / Trust Layer | FCP | Implementation | Shared trust drawer should exist before Start Here/Rail/Plan/Goal integrations mature. | FCP01-FCP04; PD15/PD17 preferred. | Single-batch. |
| 012 | FCP05 Start Here Surface | FCP | Implementation | Start Here becomes flagship daily decision object after trust and availability foundations. | FCP01-FCP04; PD02-PD04; FCP06/FCP17 preferred. | Single-batch. |
| 013 | FCP07 Reality Rail Continuity | FCP | Implementation | Rail integrates Start Here, proof, closure, pressure. | FCP05/FCP06. | Single-batch. |
| 014 | FCP13A Action Closure Diamond | FCP split | Implementation | Closure diamond belongs immediately after Start Here/Rail/Receipt, before broad recovery/proof work. | FCP05-FCP07; PD04; FCP06. | Single-batch. |
| 015 | FCP08 Ambition Meridian Shell | FCP | Implementation | Shell chrome should wrap stable Today/trust posture before broad top-level polish. | FCP05-FCP07 preferred; SI03/SI17. | Single-batch. |
| 016 | FCP09 Motion / Haptics / Reduced Motion Proof | FCP | Implementation | Object motion should be normalized before multiple surfaces copy patterns. | FCP05-FCP08. | Single-batch. |
| 017 | FCP22 Personal System Center Refactor | FCP | Implementation | You root can now compose trust/history/defaults into one center. | PD15-PD16; FCP06/FCP17; ME06. | Single-batch. |
| 018 | FCP23 Memory Lens / External Brain Visual Layer | FCP | Implementation | Memory Lens belongs after Personal System Center trust controls. | FCP22; EB memory/trust evidence. | Single-batch. |
| 019 | FCP24 Appearance Studio | FCP | Implementation | Appearance can preview real object samples after Start Here/Rail/You exist. | FCP05/FCP07/FCP22. | Single-batch. |
| 020 | FCP18 Capture Placement Shelf | FCP | Implementation | Capture can now use shared receipt/source fold grammar. | FCP06; PD09. | Single-batch. |
| 021 | FCP19 Placement Resolver / Correction Fold | FCP | Implementation | Correction fold follows Placement Shelf. | FCP18; PD10. | Single-batch. |
| 022 | FCP20 Grow Into Goal Seed Incubator | FCP | Implementation | Goal growth follows capture resolver and goal proof boundaries. | FCP18-FCP19; PD11. | Single-batch. |
| 023 | FCP21 Voice / Motor Capture Accessibility | FCP | Implementation | Input alternatives follow final Capture composer/resolver structure. | FCP18-FCP20. | Single-batch. |
| 024 | FCP14 LifeShape Contour Map | FCP | Implementation | Plan contour should build after availability defaults and before reflow/recovery. | PD14; FCP17. | Single-batch. |
| 025 | FCP15 Reflow Decision Fold | FCP | Implementation | Reflow fold depends on LifeShape contour and PD12 semantics. | FCP14; PD12. | Single-batch. |
| 026 | FCP16 Pressure Field / Recovery Loop | FCP | Implementation | Recovery loop follows LifeShape + Reflow + Closure Diamond. | FCP13A; FCP14-FCP15; PD13. | Single-batch. |
| 027 | FCP10 MissionControlTimeSpine | FCP | Implementation | Goals spine should reuse receipt/proof grammar after shared trust foundation. | FCP06; PD05-PD08. | Single-batch. |
| 028 | FCP11 LifePath Thread | FCP | Implementation | LifePath thread follows MissionControlTimeSpine. | FCP10; PD06-PD08. | Single-batch. |
| 029 | FCP12 Proof Spine / Evidence Ledger | FCP | Implementation | Proof spine follows Goals thread/spine and shared Receipt Drawer. | FCP06/FCP10/FCP11; PD07/PD17. | Single-batch. |
| 030 | FCP13B Goal Alternate Path / Decision History Polish | FCP split | Implementation | Goal alternate-path polish follows proof spine and LifePath. | FCP11-FCP12; PD08. | Single-batch. |
| 031 | FCP25 Loading / Empty / Degraded State Objectization | FCP | Implementation | Object-specific state pass should run after major surfaces exist. | FCP05/FCP10/FCP14/FCP18/FCP22. | Single-batch. |
| 032 | FCP26 Iconography / Status Grammar Hardening | FCP | Implementation | Status grammar finalizes after object states are visible. | FCP25; SI14. | Single-batch. |
| 033 | AOS01 AmbitionsOS Canon And Runtime Contract | AOS | Docs / Contract | Runtime work starts after flagship object slots and product depth exist. | Start AOS Train or global preauthorization. | May continue on Green. |
| 034 | AOS02 Life Graph Event Log Foundation | AOS | Contract/Foundation | Foundation for graph-backed memory/proof. | AOS01. | Single-batch preferred. |
| 035 | AOS03 Graph Delta Review Projection Store | AOS | Contract/Foundation | Projection review precedes control plane and kernels. | AOS02. | Single-batch. |
| 036 | AOS04 Control Plane Work Classifier | AOS | Contract/Foundation | Work classifier gates all kernel behavior. | AOS01-AOS03. | Single-batch. |
| 037 | AOS12 Proof Trust Closure Receipts | AOS | Kernel | Proof/trust/closure kernel should precede recommendation and reflow runtime. | AOS02-AOS04. | Single-batch. |
| 038 | AOS13 Source Truth Claim State Machine | AOS | Kernel | Source truth gates recommendation, proof, and memory. | AOS02-AOS04. | Single-batch. |
| 039 | AOS10 Commitment Time Kernel | AOS | Kernel | Real capacity/time kernel should precede reflow and recommendation runtime. | AOS02-AOS04. | Single-batch. |
| 040 | AOS05 Starting Position Kernel | AOS | Kernel | Starting position feeds goal compiler and recommendation. | AOS02-AOS04. | Single-batch. |
| 041 | AOS06 Goal Path Kernel Goal Compiler | AOS | Kernel | Goal compiler follows starting position. | AOS05. | Single-batch. |
| 042 | AOS07 Local Goal Packs Requirement Slots | AOS | Kernel | Requirement slots follow compiler. | AOS06. | Single-batch. |
| 043 | AOS08 Alternate Path Kernel Path Portfolio | AOS | Kernel | Alternate path runtime follows goal path slots. | AOS05-AOS07. | Single-batch. |
| 044 | AOS09 Option Value North Star | AOS | Kernel | North Star/option value follows alternate paths. | AOS08. | Single-batch. |
| 045 | AOS11 Reality Drift Bounded Reflow | AOS | Kernel | Reflow runtime follows commitment time and proof/receipt contracts. | AOS10/AOS12. | Single-batch. |
| 046 | AOS14 Recommendation Start Here Kernel | AOS | Kernel | Start Here recommendation follows source/proof/control contracts and flagship UI. | AOS04/AOS12/AOS13; FCP05. | Single-batch. |
| 047 | AOS15 Local Language Kernel Planning | AOS | Kernel | Language planning waits for recommendation/source/fallback boundaries. | AOS04/AOS13/AOS14. | Single-batch. |
| 048 | AOS16 Performance Energy Kernel | AOS | Kernel/QA | Performance budgets must precede runtime-heavy exposure. | Before runtime-heavy implementation. | Single-batch. |
| 049 | AOS17 Privacy Safety Kernel | AOS | Kernel/QA | Privacy contracts must precede sensitive projections. | Before sensitive projection. | Single-batch. |
| 050 | AOS18 Evaluation Golden Scenarios | AOS | Evaluation | Golden scenarios follow kernel contracts. | AOS01-AOS17. | Single-batch. |
| 051 | AOS19 Experience Kernel Celestial Cognitive Load | AOS | Experience contract | Experience language follows evaluation. | AOS18. | Single-batch. |
| 052 | AOS20 Adaptation Kernel Local Personalization | AOS | Kernel | Local calibration follows recommendation and evaluation. | AOS14/AOS18. | Single-batch. |
| 053 | AOS21 Interoperability Kernel App Intents EventKit Planning | AOS | Planning | External interop waits for privacy/performance gates. | AOS16/AOS17. | Single-batch. |
| 054 | AOS22 Longevity Kernel Archive Aging | AOS | Kernel | Archive aging follows graph/proof/source. | AOS02/AOS12/AOS13. | Single-batch. |
| 055 | AOS23 Governance Kernel Registry | AOS | Governance | Registry follows all kernel contracts. | AOS01-AOS22. | Single-batch. |
| 056 | LDI01 Living Dream Architecture Source Truth | LDI | Docs/Contract | LDI begins after AOS governance contracts, before AOS UI integration. | AOS23 or explicit dependency review. | Single-batch. |
| 057 | LDI02 Capture Handling Ladder | LDI | Contract | Dream handling begins with capture ladder. | LDI01. | Single-batch. |
| 058 | LDI03 Dream Safety Legality Feasibility Triage | LDI | Safety | Safety triage must precede path/runtime work. | LDI02. | Single-batch. |
| 059 | LDI04 North Star Extraction | LDI | Contract | Meaning extraction follows safety. | LDI03. | Single-batch. |
| 060 | LDI05 Source Claim Graph | LDI | Contract | Source graph gates requirements and packs. | LDI04. | Single-batch. |
| 061 | LDI06 Pack Registry And Pack Compiler | LDI | Contract | Pack registry follows source graph. | LDI05. | Single-batch. |
| 062 | LDI07 Pack Supply Chain Security | LDI | Security | Pack security must precede pack usage. | LDI06. | Single-batch. |
| 063 | LDI08 Requirement Graph Runtime | LDI | Runtime | Requirement graph follows safe source/pack contracts. | LDI05-LDI07. | Single-batch. |
| 064 | LDI09 Eligibility And Deadline Runtime | LDI | Runtime | Eligibility follows requirement graph. | LDI08. | Single-batch. |
| 065 | LDI10 Starting Position And Privacy Intake | LDI | Runtime | Intake follows safety/source/eligibility. | LDI09. | Single-batch. |
| 066 | LDI11 Path Portfolio Runtime | LDI | Runtime | Path portfolio follows intake. | LDI10. | Single-batch. |
| 067 | LDI12 Capacity And Commitment-Time Bridge | LDI | Runtime | Capacity bridge follows path portfolio and AOS time kernel. | LDI11; AOS10. | Single-batch. |
| 068 | LDI13 Today Bridge And Action Closure | LDI | Runtime | Today bridge follows capacity and FCP closure/Start Here. | LDI12; FCP05/FCP13A. | Single-batch. |
| 069 | LDI14 Trust Review And Dream Handling Receipts | LDI | Trust | Trust receipts follow Today bridge and AOS proof kernel. | LDI13; AOS12. | Single-batch. |
| 070 | LDI15 Living Plan Recompiler | LDI | Runtime | Recompiler follows receipts and mutation-safe context. | LDI14. | Single-batch. |
| 071 | LDI16 Mutation Permissions And Impact Levels | LDI | Safety | Mutation permission gate must precede any living plan mutation. | LDI15. | Single-batch. |
| 072 | LDI20 Freshness Broker | LDI | Source ops | Freshness broker follows source graph and before source-driven UI claims. | LDI05/LDI16. | Single-batch. |
| 073 | LDI21 Red-Team Evaluation Suite | LDI | Evaluation | Abuse resistance before UI integration/claim truth. | LDI16/LDI20. | Single-batch. |
| 074 | LDI17 Continuity Sync | LDI | Continuity | Sync waits until local mutation permissions and red-team baseline exist. | LDI16/LDI21; explicit entitlement boundary. | Single-batch. |
| 075 | LDI18 Archive And Schema Migration | LDI | Persistence planning | Archive/migration follows continuity and mutation model. | LDI17. | Single-batch. |
| 076 | LDI19 Multi-Device Merge Ledger | LDI | Continuity | Merge ledger follows continuity/archive. | LDI17-LDI18. | Single-batch. |
| 077 | LDI22 Governance And Maintenance Console | LDI | Governance | Governance console follows runtime/source/safety/sync surfaces. | LDI01-LDI21. | Single-batch. |
| 078 | AOS24 AmbitionsOS UI Integration | AOS | UI integration | UI integration waits for AOS kernels and LDI safety/runtime gates where relevant. | AOS18-AOS23; LDI01-LDI22 where exposed. | Single-batch. |
| 079 | AOS25 AmbitionsOS Test Fixture Library | AOS | Fixtures | Fixtures follow UI integration. | AOS18/AOS24. | Single-batch. |
| 080 | FCP27 Cross-Surface Proof / Review Mesh | FCP | Integration | Final mesh should integrate PD, FCP, AOS, and LDI proof/review truths. | PD17; FCP06/FCP12/FCP15/FCP19/FCP22; AOS24/AOS25 preferred. | Single-batch. |
| 081 | AOS26 AmbitionsOS Privacy Performance QA | AOS | QA | QA follows UI integration and final proof mesh. | AOS16/AOS17/AOS18/AOS25/FCP27. | Single-batch. |
| 082 | FCP28 Full App 10/10 Audit | FCP | Audit | Full app audit follows UI, proof mesh, and AOS QA. | FCP01-FCP27; AOS26. | Stop on Red. |
| 083 | FCP29 Human Visual / Accessibility / Device Proof Packet | FCP | Human proof packet | Human/device proof packet follows full audit. | FCP28. | Human-proof stop. |
| 084 | AOS27 AmbitionsOS App Store Claim Truth | AOS | Claim truth | Claim truth follows QA and human-proof packet boundaries. | AOS26/FCP29. | Human-proof stop. |
| 085 | AOS28 AmbitionsOS Handoff | AOS | Handoff | AOS handoff follows claim truth. | AOS27. | Single-batch. |
| 086 | FCP30 Flagship Completion Handoff | FCP | Handoff | Flagship handoff follows AOS handoff and proof packet. | FCP29/AOS28. | Closeout. |
| 087 | AOS29 AmbitionsOS Repair Train | AOS | Conditional repair | Runs only if AOS/FCP/LDI Yellows or Reds require repair. | Classified failures. | Conditional only. |
| 088 | AOS30 AmbitionsOS Beyond Roadmap | AOS | Roadmap | Final roadmap follows handoffs or explicit user decision. | AOS28/FCP30 or user decision. | Closeout. |
| 089 | CS02C-CS06C / CS09C Deferred Compatibility Retirements | CS | Conditional repair | Only run if a named owner and proof target exists; never happy-path. | Named compatibility target. | Conditional only. |

## Split-Batch Clarification

FCP13 is split in this optimized order because the 25-object scorecard requires Action Closure Diamond and the FCP train also needs Goal Alternate Path / Decision History polish.

- FCP13A is Today-owned Action Closure Diamond.
- FCP13B is Goals-owned Goal Alternate Path / Decision History Polish.

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
