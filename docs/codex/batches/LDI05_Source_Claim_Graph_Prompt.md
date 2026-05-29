# LDI05 Source Claim Graph Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-24100554, AMB28-same_source_file_targeted_by_multiple_active_batches-55112340, AMB28-same_source_file_targeted_by_multiple_active_batches-65738276, AMB28-same_source_file_targeted_by_multiple_active_batches-69341060, AMB28-same_source_file_targeted_by_multiple_active_batches-90872127, AMB28-same_source_file_targeted_by_multiple_active_batches-91424747, AMB28-same_source_file_targeted_by_multiple_active_batches-98560090, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

## Batch Identity

- Batch ID: LDI05
- Title: Source Claim Graph
- Train: LDI01-LDI22 Living Dream Intelligence Train
- Default global placement: after AOS30 unless explicit user decision changes it
- Type: future implementation / governance according to boundary

## Status

Queued. Do not start until global order selects this batch or the user explicitly authorizes an earlier LDI gate.

## Purpose

Implements claim graph contracts and proof fixtures.

## Source Truth Files To Read First

- README.md
- AGENTS.md
- docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md
- docs/canon/Ambitions_3_0_Primitive_Architecture.md
- docs/canon/AmbitionsOS_Living_Dream_Architecture_Index.md
- docs/canon/AmbitionsOS_Living_Dream_System_Map.md
- docs/canon/AmbitionsOS_Dream_Handling_Lanes_And_Ladder.md
- docs/canon/AmbitionsOS_Source_Claim_Graph_And_Pack_System.md
- docs/canon/AmbitionsOS_Living_Plan_Recompiler.md
- docs/canon/AmbitionsOS_Safety_Legality_Feasibility_Triage.md
- docs/canon/AmbitionsOS_Continuity_Sync_Archive_And_Merge.md
- docs/canon/AmbitionsOS_LDI_Evaluation_And_Governance.md
- docs/codex/LDI_BATCH_GATE_MATRIX.md
- docs/codex/LDI_DEPENDENCY_GRAPH.md
- docs/codex/BATCH_REGISTRY.md
- docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `scripts/global-train-next-batch.sh || true`
- `scripts/ldi-gate-check.sh || true`
- `scripts/ldi-release-claim-scan.sh || true`

## Allowed Files

- docs/canon/** when owned by this batch
- docs/codex/** when owned by this batch
- docs/audits/**
- .codex/skills/** and .codex/review-boards/** only if this batch owns governance changes
- scripts/ldi-*.sh and scripts/ldi-*.py
- Native/Ambitions/** only when this batch explicitly owns implementation and the owner map is recorded before edits
- Native/AmbitionsTests/** only for focused tests owned by this batch

## Forbidden Files

- .github/workflows/**
- signing, entitlements, provisioning, TestFlight, App Store, release config
- route/raw-value/persistence/schema changes unless this exact batch owns them and proof is named before edits
- backend/account/telemetry/hosted AI/user-data server implementation
- new top-level destination or tab
- broad SI/PD/AOS rewrites

## Ownership Target Or Discovery Rule

Boundary: atomic claims, source refs, claim states, jurisdiction, freshness policies.

Before implementation, name exact owner files, non-owner files, tests, preview or fixture seams, rollback files, and route/raw/persistence/accessibility non-change proof. If owner files are not provable, stop and create an owner-map repair batch.

## Required Implementation Boundary

Implement only the smallest usable slice that advances Source Claim Graph. Any runtime behavior must be deterministic, local-first, evidence-producing, and compatible with Ambitions' five destination IA.

## Non-Goals

No promise that every dream becomes a plan. No unsafe operationalization. No professional advice. No silent commitment mutation. No hosted AI or user-data backend. No release readiness claim.

## Required Codex OS Gates

- LDI Source Truth Gate
- Handling Lane Gate when lanes are touched
- Safety Legality Feasibility Gate when capture/routing/safety is touched
- Source Claim Pack Gate when claims or packs are touched
- Pack Supply Chain Gate when packs/imports are touched
- Local-First Privacy Gate
- No Silent Mutation Gate when plans/commitments are touched
- Professional Boundary Gate when regulated domains are touched
- Release Claim Safety Gate
- Evidence Manifest Gate
- Rollback Gate

## Required Skills / Review Boards

- .codex/skills/living-dream-architect.md
- .codex/skills/dream-safety-legality-triage-reviewer.md when safety/triage is touched
- .codex/skills/source-claim-graph-architect.md when claims are touched
- .codex/skills/pack-supply-chain-security-reviewer.md when packs are touched
- .codex/skills/living-plan-recompiler-architect.md when recompile/mutation is touched
- .codex/review-boards/living-dream-architecture-review-board.md
- .codex/review-boards/dream-safety-legality-review-board.md when safety is touched
- .codex/review-boards/source-claim-pack-security-review-board.md when claims/packs are touched

## Validation Commands

- `git diff --check`
- `scripts/ldi-gate-check.sh || true`
- `scripts/ldi-release-claim-scan.sh || true`
- `scripts/ldi-handling-lane-scan.sh || true`
- `python3 scripts/ldi-source-pack-schema-check.py || true`
- `python3 scripts/ldi-safety-redteam-fixture-check.py || true`
- `python3 scripts/ldi-pack-supply-chain-scan.py || true`
- focused Swift build/tests only if production Swift is touched

## Required Evidence Outputs

Batch report with files changed, source truth read, owner map, tests or not-run reason, preview/fixture evidence or not-run reason, route/raw/persistence/accessibility proof where relevant, Yellow owners, Red repairs, rollback path, and next eligible batch.

## Green Criteria

Implementation stays inside boundary, required gates pass, proof is concrete, no forbidden files touched, no unsupported claims, and working tree is clean after commit.

## Yellow Criteria

Future fixture or human/device proof is unavailable but no claim is made, advisory scans report planned fixture gaps, or a queued prerequisite owns a deferred piece.

## Red Criteria

Unsafe plan operationalized, professional advice claimed, user data server/backend/hosted AI introduced, new top-level destination created, commitments move silently, source truth conflicts unresolved, forbidden file touched, or release/platform claim outruns proof.

## Stop Conditions

Stop on Red, unknown dirty tree, owner-map uncertainty, route/raw/persistence risk without proof, or validation failure caused by this batch that cannot be repaired safely.

## Rollback / Repair Expectations

Revert only this batch's changed owner files. Preserve previous completed train history. If scope is too broad, split into A/B/C owner-map/proof/implementation stages.

## What This Batch May Claim

It may claim only the specific docs, contracts, fixtures, tests, or implementation proven by its evidence.

## What This Batch Must Not Claim

No full Living Dream runtime, production AI, official requirement verification, professional advice, device proof, public accessibility compliance, TestFlight readiness, App Store readiness, or release readiness.

## What This Batch Does Not Prove

It does not prove every dream can become a plan, that source packs are official, that CloudKit sync is shipped, or that human review happened unless evidence says so.

## Commit Message Recommendation

`Run LDI05 Source Claim Graph`

## Next Safe Prompt / Next Gate

After Green or accepted Yellow, ask global train for the next eligible batch. Expected next gate: LDI06.

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
