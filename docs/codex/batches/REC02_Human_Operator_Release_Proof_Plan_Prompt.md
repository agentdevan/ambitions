# REC02 Human Operator Release Proof Plan Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_surface_multiple_active_batches-26899932

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

Status: Queued Ambitions 4.0 evidence batch; not started; blocked pending `Continue Release Evidence Closure`.

## Batch Identity

- Batch ID: `REC02`
- Name: Human Operator Release Proof Plan
- Train: Release Evidence Closure
- Mode: evidence/docs-only
- Owner: release evidence and human-proof boundary
- Required approval phrase: `Continue Release Evidence Closure`, or current
  global Ambitions 4.0 preauthorization via
  `Run Global Batch Sequence Until Blocked`

## Purpose

Create the operator-ready human proof plan for release-adjacent evidence without
claiming that any human-only proof has passed. This batch turns the REC01 truth
inventory into exact checklists for physical device, public accessibility,
signed archive, App Store Connect, TestFlight, and rendered external-platform
proof.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md`
- `docs/canon/Ambitions_3_0_Release_Claim_Truth_Protocol.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/codex/batch-trains/REC01_REC06_RELEASE_EVIDENCE_CLOSURE_TRAIN.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/audits/rec01-release-evidence-truth-inventory-report.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- Confirm REC01 is Green or accepted Yellow by repo evidence.
- Confirm the user said exactly `Continue Release Evidence Closure`, or that
  the current prompt explicitly preauthorizes Ambitions 4.0 global execution via
  `Run Global Batch Sequence Until Blocked`.
- Confirm REC02 is not already marked started or complete.

Stop if REC01 evidence is not accepted, approval is missing from both the REC
phrase and current global 4.0 preauthorization, the branch is not `main`, or
any app/workflow/dependency file is dirty.

## Allowed Files

- `docs/**`
- `.codex/**`

## Forbidden Files

- `Native/**`, `AppUI/**`, `Sources/**`
- `.github/workflows/**`
- Dependency manifests and lockfiles
- Xcode project, signing, entitlement, build-setting, persistence/schema,
  external route, App Intent, widget, Live Activity, or platform implementation
  files

## Required Work

- Create the human operator proof plan for:
  - physical-device smoke
  - fresh install and returning-user review
  - accessibility/manual UX review
  - signed archive/export review
  - App Store Connect validation
  - TestFlight upload/review boundary
  - widgets, App Intents, Live Activities, and external rendered surfaces
- Separate Codex-verifiable proof from human-only proof.
- Define operator inputs, exact steps, expected evidence, log/screenshot paths,
  and stop conditions for each proof family.
- Preserve the boundary that REC02 plans proof but does not perform or claim it.
- Update REC evidence docs, registry/context/run-state only after validation.

## Required Non-Goals

No app implementation, no build setting change, no signing change, no workflow
change, no dependency change, no release readiness claim, no TestFlight claim,
no App Store claim, no physical-device claim, no public accessibility claim, and
no platform proof claim.

## Required Validation Commands

- `git status --short`
- `git diff --check`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- `grep -R "App Store ready\|TestFlight ready\|production ready\|physical device passed\|release ready" README.md docs .codex | cat || true`
- Changed-file boundary check limited to `docs/**` and `.codex/**`

## Required Evidence Outputs

- REC02 report under `docs/audits/`
- Operator proof checklist or plan under `docs/**`
- Updated `docs/codex/BATCH_REGISTRY.md`, `docs/codex/CONTEXT_INDEX.md`,
  `.codex/reports/current-run-state.md`, and
  `.codex/reports/current-batch-train-state.md` only after evidence
- Yellow advisory list for proof families that require human action
- Exact next safe prompt

## Green / Yellow / Red Criteria

Green: proof plan is complete, all human-only proofs are separated from Codex
proof, no unsupported claim is introduced, no forbidden file changed, and
validation is clean or advisory-only.

Yellow: doc QA/tooling backlog or unresolved human proof remains, but it is
classified and does not claim readiness.

Red: any release/platform readiness claim is introduced, human proof is treated
as passed, app behavior changes, forbidden file changes, REC01 truth is altered,
or validation failure remains unclassified.

## Stop Conditions

Stop on Red, missing approval phrase, missing REC01 evidence, release-claim
ambiguity, human-proof ambiguity, forbidden file drift, or pressure to perform
human-only proof.

## Rollback / Repair Expectations

Revert only unsafe changes from this batch. Do not weaken claim boundaries or
hide proof gaps to reach Green. If proof planning cannot be completed safely,
write a Red repair report.

## What This Batch May Claim

It may claim a human operator proof plan exists after commit.

## What This Batch Must Not Claim

No release readiness, App Store readiness, TestFlight readiness, physical-device
verification, signed archive validation, App Store Connect validation, public
accessibility conformance, external-platform rendered proof, PXOS
implementation, or AmbitionsOS implementation.

## Commit Message Recommendation

`Run REC02 human operator release proof plan`

## Next Safe Prompt / Path

`REC03 Validation Log Ledger Closure` only after REC02 is Green or accepted
Yellow, committed, pushed, and train continuation is explicitly allowed by REC
approval or current global 4.0 preauthorization.

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
