# Global Future Batch Dependency Graph

<!-- markdownlint-disable MD013 -->

Status: Global planning and Codex OS control; no future train started
Date: 2026-05-02

## Phase Map

| Phase | Global order | Purpose | Required result |
| --- | --- | --- | --- |
| 0 Release evidence truth | 001-005 | Close REC02-REC06 evidence, human proof plan, claim guard, review packet, and closure handoff. | Release claims remain evidence-bound. |
| 1 PXOS surface canon | 006-015 | Define PXOS parent, five surfaces, closure, trust, copy, and visual system. | Future user-facing work has source truth. |
| 2 PXOS readiness canon | 016-025 | Define onboarding, accessibility, degraded states, Product Depth, continuity, intelligence expression, messaging, reorder, handoff, roadmap. | PXOS can gate implementation without claiming implementation. |
| 3 Maintainability prerequisites | 026-037 | Map large files, set extraction standards, run architecture gate, extract owners, rebaseline tests, repair, handoff. | Large UI work has maintainable owners. |
| 4 Compatibility prerequisites | 038-047 | Map seams, prove external/import/export/persistence compatibility, retire safe seams, repair, handoff. | Renames/removals do not break routes or data. |
| 5 AOS internal foundations | 048-070 | Build AmbitionsOS contracts and kernels without user-facing exposure. | Internal intelligence has typed, private, source-grounded contracts. |
| 6 AOS expression and QA | 071-077 | Integrate only after PXOS/ME/CS, build fixtures, QA, claim truth, handoff, repair/roadmap. | User-facing intelligence waits for proof and gates. |
| 7 Product Depth | Blocked lane | Deepen existing surfaces only after PXOS plus relevant ME/CS gates. | No widening, no new top-level surfaces. |
| 8 Release readiness evidence | Future human-led lane | Actual release readiness proof after implementation evidence and human/platform proof. | No public readiness claim without evidence. |

## Hard Dependencies

- REC02 depends on REC01 Green or accepted Yellow and the approval phrase `Continue Release Evidence Closure`.
- PX01 depends on explicit approval phrase `Start PXOS Future-Canon Train`.
- PX02-PX20 depend on PX01.
- PX14 depends on PX02-PX13.
- PX18 depends on PX01-PX17 and recurs before major implementation lanes.
- ME01 depends on explicit approval phrase `Start ME Train`.
- ME02-ME07 depend on ME01, ME08 standards where relevant, ME10 architecture gate, and behavior-preservation tests.
- CS01 depends on explicit approval phrase `Start CS Train`.
- CS02-CS06 depend on CS01 and the relevant CS07/CS08 compatibility proof where route/raw/external/import/export/persistence risk exists.
- AOS01 depends on explicit approval phrase `Start AOS Train`.
- AOS02-AOS23 depend on AOS01 and the kernel dependencies named in the AOS train manifest.
- AOS24 depends on AOS18-AOS23, PXOS expression gates, ME maintainability gates, and CS compatibility gates.
- Product Depth depends on PX14, PX18, affected ME gates, affected CS gates, and explicit formalization.

## Soft Dependencies

- REC should precede PX17 and any public product messaging.
- PX09 should precede most copy-bearing future implementation.
- PX10 and PX12 should precede major UI implementation.
- ME01/ME10 should precede any large SwiftUI/product-surface expansion.
- CS01 should precede any user-facing terminology work that tempts internal seam deletion.
- AOS16/AOS17 should precede runtime-heavy or sensitive projection work.
- AOS18 should precede broad AOS behavior implementation.

## Blockers

- Unresolved Red in any current batch.
- Missing approval phrase for the selected train or global mode.
- Forbidden file touch in docs/protocol-only work.
- Weak or Missing validation for an implementation batch.
- Human-proof requirement that Codex cannot perform.
- Global order and train manifest disagreement that affects safety.
- PXOS or AmbitionsOS described as implemented without evidence.
- REC02, PXOS, ME, CS, AOS, or Product Depth started by implication.
- Top-level surface composition rule weakened or bypassed.

## Cross-Train Dependencies

| Cross-check | Applies before | Blocks when |
| --- | --- | --- |
| REC Release Claim Gate | PX17, AOS27, release messaging, handoff docs | Claim outruns evidence or human proof is missing. |
| PXOS Product Experience Gate | Any user-facing UI/copy/interaction/recovery/trust work | Surface owner, hierarchy, copy, visual, accessibility, or top-level composition is undefined. |
| Top-Level Surface Composition Gate | Any Today/Goals/Capture/Plan/You top-level UI work | Proposed surface is a vertical stack of generic cards or detail archive. |
| ME Maintainability Gate | Large UI/product expansion in affected files | Owner file is too large/tangled or lacks behavior-preservation tests. |
| CS Compatibility Gate | Renames, removals, routes, raw values, widgets, App Intents, import/export, persistence | Replacement map or compatibility proof is missing. |
| AOS Runtime/Intelligence Gate | Recommendation/source-truth/runtime/intelligence work | Typed contracts, privacy projection, fallback, or source truth is missing. |
| Product Depth Gate | Drill-down/detail work beyond current canon | PXOS, ME, or CS prerequisites are unresolved. |

## Gates That Must Recur

- Source Truth Gate.
- Scope Boundary Gate.
- Product Decision Lock Gate.
- Product Drift Gate.
- Validation Evidence Gate.
- Validation Strength Gate.
- File Size / Diff Size Gate for code batches.
- Release Claim Gate.
- Human Proof Gate.
- Handoff and Rollback Gate.
- PX18 implementation-readiness reorder before major post-PXOS implementation.
- ME10 architecture scan before large SwiftUI or service expansion.
- AOS16 performance and AOS17 privacy gates before runtime-heavy or sensitive work.

## Parallel-Safe Lanes

Parallel work is disabled by default. It is allowed only after explicit approval, disjoint write sets, Green prerequisites, and one commit per batch.

- PX02-PX08 are conceptually parallel-safe after PX01 because they are surface-canon docs, but serial is preferred unless a user explicitly authorizes parallel work.
- ME02, ME03, ME05, and ME06 may be parallel-safe after ME01/ME08/ME10 if owner files are disjoint and tests are independent.
- AOS10, AOS12, and AOS13 may be parallel-safe after AOS04 if contracts and write sets are disjoint.
- AOS22 may be parallel-safe after AOS02/AOS12/AOS13 if it does not touch the same owner files as active work.

## Serial-Only Lanes

- REC02-REC06.
- PX01, PX14, PX16-PX20.
- ME01, ME09, ME11, ME12.
- CS01-CS10 unless a future CS proof explicitly permits disjoint parallelism.
- AOS01-AOS09, AOS11, AOS14-AOS21, AOS23-AOS30.
- Product Depth until formalized.
- Any human-proof, release-claim, route/persistence, top-level UI, or runtime/intelligence exposure batch.

## Human-Proof Stops

Human proof stops apply to physical devices, App Store Connect, signed archives, TestFlight, external platform rendering, public accessibility conformance, manual UX approval, legal/privacy signoff, and production release decisions. Codex must stop and produce an operator checklist instead of simulating these proofs.

## Validation-Strength Dependencies

- Docs/protocol batches: Adequate validation can pass with `git diff --check`, doc/status scans, changed-file boundary checks, and advisory doc QA.
- Evidence batches: Adequate validation requires claim scans, evidence ledger/log checks, and human-proof boundary review.
- Code implementation/extraction/compatibility/AOS runtime batches: Strong validation is expected. Weak or Missing validation is normally Red.
- UI batches: Strong validation includes focused tests, build where tooling supports it, UI/accessibility/copy/visual evidence, and no top-level composition violation.
