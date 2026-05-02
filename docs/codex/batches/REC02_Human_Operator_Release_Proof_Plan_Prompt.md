# REC02 Human Operator Release Proof Plan Prompt
<!-- markdownlint-disable MD013 -->

Status: Future prompt; do not run automatically. REC02 is not started.

## Batch Identity

- Batch ID: `REC02`
- Name: Human Operator Release Proof Plan
- Train: Release Evidence Closure
- Mode: evidence/docs-only
- Owner: release evidence and human-proof boundary
- Required approval phrase: `Continue Release Evidence Closure`

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
- Confirm the user said exactly `Continue Release Evidence Closure`.
- Confirm REC02 is not already marked started or complete.

Stop if REC01 evidence is not accepted, the approval phrase is missing, the
branch is not `main`, or any app/workflow/dependency file is dirty.

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
Yellow, committed, pushed, and train continuation is explicitly allowed.
