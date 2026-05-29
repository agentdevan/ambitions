# PX06 You Personal System Center Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Complete Ambitions 4.0 future-canon batch; not implemented app behavior.

## Purpose

Advance You Personal System Center for PXOS without implementing app behavior
or inventing product direction beyond locked source truth.

## Source Truth Files To Read First

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

## Product-Experience Decision Boundaries

Use `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md`. Locked decisions may be
applied. Open or deferred decisions must be recorded and not silently resolved.

## Allowed Files

- `docs/**`
- `.codex/**`
- Future implementation files only in a later implementation prompt after PXOS
  train approval, ME/CS/AOS/REC checks, and exact file ownership.

## Forbidden Files

- `Native/**`, `AppUI/**`, `Sources/**` in this future-canon prompt
- `.github/workflows/**`
- dependency manifests, lockfiles, Xcode project/signing config, build settings,
  generated build output, persistence/schema, external route implementation,
  App Intent implementation, widget implementation, production Swift, and
  production UI files

## Exact Surface Ownership

Owner: You. Boundary: You experience canon only.

## Batch-Specific Deliverables

- Define You as the Personal System Center for assumptions, trust, source truth,
  preferences, correction, export/import posture, and controls.
- Specify What Ambitions Knows, source freshness, review-needed states, and
  safe-vs-blocked controls.
- Define how memory, personalization, receipts, privacy, and correction appear
  without settings clutter on other tabs.
- Preserve You as user-facing language even where internal code still says
  Profile.

## Batch-Specific Acceptance Criteria

- You centralizes trust and controls without becoming a generic settings dump.
- Sensitive data has source/freshness/ownership labels.
- Memory and personalization remain user-controlled and local-first unless
  future proof changes that truth.
- CS gates are required before internal Profile naming retirement.

## Relationships

- Ambitions 3.0: completed baseline; do not mark incomplete or rewrite history.
- AmbitionsOS: internal intelligence/runtime dependency; PXOS owns expression.
- ME: check extraction before large UI/file expansion.
- CS: check compatibility before route/raw/external/persistence changes.
- REC: check release/product-message claims; REC02 must not start here.

## Implementation Boundary

This prompt may create or update docs/protocol/canon only. It must not start
PXOS implementation, AOS01, ME01, CS01, REC02, or Product Depth.

## Non-Goals

No new top-level tab, chatbot-first direction, generic productivity expansion,
release-readiness claim, platform-readiness claim, model/runtime work,
backend/sync/cloud work, dependency changes, workflow changes, production Swift,
visual redesign implementation, compatibility seam retirement, stacked-card top-level composition, top-level detail-container UI, or dashboard-like card grids.

## Required Validation

- `git status --short`
- `git diff --check`
- PXOS status and release-claim scans
- PXOS drift scans, including stacked-card and top-level detail-container scans
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Required Evidence / Report Output

Create or update a batch report, registry/context/run-state only after evidence,
product decision ledger entries for open decisions, and unresolved Yellow list.

## Green / Yellow / Red Criteria

Green: scope is docs-only, decisions are locked/open/deferred, no forbidden file
changed, no unsupported claim, and validation is clean or advisory-only.

Yellow: doc QA/tooling backlog or an open future decision is classified and does
not affect current implementation truth.

Red: product direction invented, PXOS marked started/complete, app code touched,
release/platform claim added, AOS/ME/CS/REC02 started, top-level tab changed, stacked-card top-level composition accepted, or
validation failure unclassified.

## Stop Conditions

Stop on Red, unclear source truth, missing owner, unbounded scope, changed-file
boundary failure, or pressure to implement product behavior.

## Rollback / Repair Expectations

Revert only your own unsafe changes, preserve evidence, classify failures, and
write a repair prompt instead of weakening gates.

## What This Batch May Claim

It may claim future PXOS canon or prompt work exists after commit.

## What This Batch Must Not Claim

It must not claim PXOS implemented, shipped, active train started, release-ready,
App Store ready, TestFlight ready, physical-device passed, platform integrated,
AOS/ME/CS started, or REC02 started.

## What This Batch Does Not Prove

No app behavior, build proof, physical-device proof, public accessibility proof,
signed archive proof, platform rendering, or implementation readiness beyond the
next named gate.

## Commit Message Recommendation

`Run PX06 You Personal System Center`

## Next Safe Prompt / Path

Use the next direct PX prompt only after this batch is Green, committed, pushed,
the next dry-run says `Execution allowed: YES`, and no Yellow/Red gate blocks
continuation. The current global Ambitions 4.0 preauthorization may satisfy
routine PXOS train continuation, but it does not replace proof or gates.

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
