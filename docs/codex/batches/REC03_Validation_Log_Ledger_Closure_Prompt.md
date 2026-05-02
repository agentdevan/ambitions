# REC03 Validation Log Ledger Closure Prompt
<!-- markdownlint-disable MD013 -->

Status: Future prompt; do not run automatically. REC03 is not started.

## Batch Identity

- Batch ID: `REC03`
- Name: Validation Log Ledger Closure
- Train: Release Evidence Closure
- Mode: evidence/docs-only
- Owner: validation evidence ledger
- Required approval phrase: `Continue Release Evidence Closure`

## Purpose

Preserve, index, and classify Ambitions 3.0 validation logs and proof gaps
without rerunning app validation or claiming release readiness. REC03 makes the
repo's evidence ledger operator-readable and claim-safe.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md`
- `docs/canon/Ambitions_3_0_Evidence_Hierarchy.md`
- `docs/codex/batch-trains/REC01_REC06_RELEASE_EVIDENCE_CLOSURE_TRAIN.md`
- `docs/codex/batches/REC02_Human_Operator_Release_Proof_Plan_Prompt.md`
- `docs/audits/rec01-release-evidence-truth-inventory-report.md`
- REC02 report and operator proof plan, when present
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- Confirm REC02 is Green or accepted Yellow.
- Confirm REC03 is not already marked started or complete.
- Locate latest referenced build/test/doc QA logs without modifying output.

Stop if REC02 is missing, proof logs are ambiguous, or this batch would need
app-code validation to make a claim.

## Allowed Files

- `docs/**`
- `.codex/**`

## Forbidden Files

- `Native/**`, `AppUI/**`, `Sources/**`
- `.github/workflows/**`
- Dependency manifests, lockfiles, generated build output, Xcode project/signing
  config, persistence/schema, route/App Intent/widget implementation files

## Required Work

- Create or update a validation log ledger with:
  - command name
  - date/time if available
  - log path
  - PASS/PARTIAL/FAIL/advisory status
  - proof scope
  - what the log does not prove
  - human follow-up owner if needed
- Reconcile simulator proof versus human-only proof.
- Preserve unsupported proof gaps from REC01/REC02.
- Classify missing or stale logs as Yellow or Red according to release risk.
- Do not rewrite historical logs or generated output.

## Required Non-Goals

No app implementation, no rerun requirement unless explicitly scoped by the
user, no output-log editing, no release readiness claim, no human-proof claim,
no workflow/dependency/signing changes.

## Required Validation Commands

- `git status --short`
- `git diff --check`
- `find output/logs -maxdepth 1 -type f | sort | tail -20 || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- Release-claim scan over `README.md docs .codex`
- Changed-file boundary check limited to `docs/**` and `.codex/**`

## Required Evidence Outputs

- REC03 report under `docs/audits/`
- Validation log ledger under `docs/**`
- Updated registry/context/run-state only after evidence
- Yellow list for stale, missing, or human-only proof
- Exact next safe prompt

## Green / Yellow / Red Criteria

Green: logs are indexed, proof scope and non-claims are explicit, unsupported
proof gaps remain visible, no forbidden files change, and validation is clean or
advisory-only.

Yellow: missing/stale logs are classified, assigned, and not used for readiness
claims.

Red: missing evidence is hidden, stale logs are treated as current proof,
readiness is claimed, generated logs are edited, forbidden files change, or
validation failure is unclassified.

## Stop Conditions

Stop on Red, missing REC02 evidence, ambiguous log provenance, release-claim
ambiguity, or pressure to call stale evidence current.

## What This Batch May Claim

It may claim a validation log ledger exists after commit.

## What This Batch Must Not Claim

No new build/test pass, release readiness, App Store readiness, TestFlight
readiness, physical-device proof, public accessibility proof, or platform proof.

## Commit Message Recommendation

`Run REC03 validation log ledger closure`

## Next Safe Prompt / Path

`REC04 Release Claim Copy Guard` only after REC03 is Green or accepted Yellow,
committed, pushed, and train continuation is explicitly allowed.
