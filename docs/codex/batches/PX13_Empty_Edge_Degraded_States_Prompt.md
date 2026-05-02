# PX13 Empty Edge Degraded States Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete Ambitions 4.0 future-canon batch; not implemented app behavior.

## Purpose

Advance Empty Edge Degraded States for PXOS without implementing app behavior
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

Owner: empty/edge/degraded. Boundary: Empty/edge/degraded state canon only.

## Batch-Specific Deliverables

- Define empty, edge, degraded, offline, unavailable, denied-permission, stale
  source, no recommendation, overwhelming day, late start, and long-gap states.
- Map each state to Today, Goals, Capture, Plan, You, closure, trust, and proof.
- Specify fallback copy, user action, source label, and recovery path for each.
- Preserve local-first and no-hidden-automation posture.

## Batch-Specific Acceptance Criteria

- Every degraded state gives a calm next action or honest no-action state.
- Missing data is not framed as user failure.
- Model/runtime/platform unavailability is not hidden.
- Edge-state detail moves into owned surfaces, not top-level clutter.

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

Red: product direction invented, PXOS marked implemented, app code touched,
release/platform claim added, AOS/ME/CS/REC02 started, top-level tab changed,
stacked-card top-level composition accepted, or validation failure
unclassified.

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

`Run PX13 Empty Edge Degraded States`

## Next Safe Prompt / Path

Use the next direct PX prompt only after this batch is Green, committed, pushed,
the next dry-run says `Execution allowed: YES`, and no Yellow/Red gate blocks
continuation. The current global Ambitions 4.0 preauthorization may satisfy
routine PXOS train continuation, but it does not replace proof or gates.
