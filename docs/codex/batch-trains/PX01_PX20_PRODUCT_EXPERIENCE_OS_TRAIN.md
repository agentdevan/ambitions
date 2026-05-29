# PX01-PX20 Product Experience OS Train

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-72003197, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: PXOS future-canon train complete through PX20; PXOS implementation not started.
Train type: queued future-canon and later implementation-readiness train
Date: 2026-05-02

## Required User Approval Phrase

`Start PXOS Future-Canon Train`

Current global Ambitions 4.0 preauthorization may also start a selected PXOS
batch when the dry-run says `Execution allowed: YES`.

No approval phrase starts PXOS implementation by implication.

## What Starts The Train

Only the required phrase or global preauthorization plus a clean preflight,
current registry/context state, Green or accepted-Yellow REC closure truth, and
no unresolved Red in PXOS controls.

## What Does Not Start The Train

Creating this manifest, creating PXOS canon, updating indexes, selecting future
ordering, REC closure, F30 being complete, or mentioning PXOS in a prompt.

## Source Truth Hierarchy

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/AmbitionsOS_Index.md`
- `docs/codex/PXOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Relationship To REC, ME, CS, AOS

- REC owns release evidence and product messaging claim boundaries.
- ME owns extraction and maintainability gates before large UI expansion.
- CS owns safe retirement of compatibility seams before renames/removals.
- AmbitionsOS owns internal intelligence/runtime; PXOS owns user-facing expression.

## Batch Order

- PX01: Product Experience OS Canon And Surface Hierarchy. Owner: all. Boundary: PXOS canon and hierarchy only. Status: complete after PX01 commit.
- PX02: Today Experience Operating Surface. Owner: Today. Boundary: Today experience canon only. Status: complete after PX02 commit.
- PX03: Goals Mission Control Experience. Owner: Goals. Boundary: Goals/Mission Control experience canon only. Status: complete after PX03 commit.
- PX04: Capture Experience. Owner: Capture. Boundary: Capture experience canon only. Status: complete after PX04 commit.
- PX05: Plan Life Shape Experience. Owner: Plan. Boundary: Plan/Life Shape experience canon only. Status: complete after PX05 commit.
- PX06: You Personal System Center. Owner: You. Boundary: You experience canon only. Status: complete after PX06 commit.
- PX07: Action Closure Recovery Experience. Owner: cross-surface closure/recovery. Boundary: Action Closure and Recovery experience canon only. Status: complete after PX07 commit.
- PX08: Trust Proof Receipts Experience. Owner: trust/proof/receipts. Boundary: Trust, proof, receipts experience canon only. Status: complete after PX08 commit.
- PX09: Copy Language Explanation System. Owner: copy/explanation. Boundary: Copy and explanation canon only. Status: complete after PX09 commit.
- PX10: Visual Interaction System. Owner: visual/interaction. Boundary: Visual interaction canon only. Status: complete after PX10 commit.
- PX11: Onboarding Setup Experience. Owner: onboarding/setup. Boundary: Onboarding and setup canon only. Status: complete after PX11 commit.
- PX12: Accessibility Cognitive Load Emotional Safety. Owner: accessibility/cognitive load. Boundary: Accessibility and emotional safety canon only. Status: complete after PX12 commit.
- PX13: Empty Edge Degraded States. Owner: empty/edge/degraded. Boundary: Empty/edge/degraded state canon only. Status: complete after PX13 commit.
- PX14: Product Depth Drilldown Architecture. Owner: drill-down/depth. Boundary: Depth and drilldown architecture canon only. Status: complete after PX14 commit; Product Depth train not started.
- PX15: Cross Surface Continuity. Owner: cross-surface. Boundary: Continuity canon only. Status: complete after PX15 commit.
- PX16: User Facing AI Trust And Recommendation Copy. Owner: recommendation/trust copy. Boundary: AI/recommendation expression canon only. Status: complete after PX16 commit.
- PX17: Release Truth Product Messaging. Owner: release messaging. Boundary: Release-safe product messaging canon only. Status: complete after PX17 commit.
- PX18: PXOS Implementation Readiness Reorder. Owner: global reorder. Boundary: Implementation readiness reorder only. Status: complete after PX18 commit; recurring gate before implementation.
- PX19: PXOS Handoff. Owner: handoff. Boundary: PXOS handoff package only. Status: complete after PX19 commit.
- PX20: PXOS Beyond Roadmap. Owner: roadmap. Boundary: Beyond roadmap update only. Status: complete after PX20 commit.

## Validation Plan

Every PX batch runs git status, diff check, PXOS drift scans, release-claim
scans when messaging is touched, doc QA advisory, batch-train gate advisory, and
focused validation named by the batch prompt. UI implementation batches later
must add screenshots/previews, accessibility evidence, copy evidence, and
focused app tests.

Every batch that touches a top-level surface must also prove the PXOS
composition rule: no stacked-card primary structure, no top-level detail
container, no dashboard-like card grid, one dominant visual object or decision,
3-second glance readability, and a named drill-down destination for secondary
detail.

## Stop Conditions

Stop on product invention, new top-level tab, unapproved train start,
unsupported release/platform/AI claim, app-code change in docs-only work,
forbidden file drift, missing product decision lock, ME/CS/AOS dependency gap,
stacked-card top-level composition, or unclassified validation failure.

## Auto-Continuation And Commit Rules

Auto-continuation is disabled by default. Continue only after Green evidence,
report, registry/context/run-state update, commit, push, and the next direct
successor being allowed. Yellow or Red stops.

## Evidence Rules

Each batch leaves an audit/report, changed files, validation logs or command
output, unresolved Yellows, rollback/repair path, and exact next prompt.

## What This Train Must Not Claim

No PXOS implementation, shipped status, release readiness, App Store readiness,
TestFlight readiness, physical-device proof, public accessibility conformance,
platform integration proof, AOS/ME/CS start, or REC02 start.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
