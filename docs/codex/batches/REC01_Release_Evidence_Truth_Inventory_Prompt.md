# REC01 Release Evidence Truth Inventory Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active first post-3.0 batch prompt; started by the pre-train hardening pass on 2026-05-02.

## Purpose

Inventory current Ambitions 3.0 evidence and release-claim gaps after F30 without implementing app behavior or claiming release readiness.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/audits/ambitions-3-0-final-train-closeout-report.md`
- `docs/audits/ambitions-3-0-final-faang-handoff-readiness-report.md`
- `docs/handoff/Ambitions_3_0_Testing_And_Release_Proof.md`

## Allowed Files

- `docs/**`
- `.codex/**`

## Forbidden Files

- `Native/**`, `AppUI/**`, `Sources/**`
- `.github/workflows/**`
- Dependency manifests, lockfiles, signing/project release config, persistence/schema, external route/App Intent/widget implementation files

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- Release-claim grep over `README.md AGENTS.md docs .codex`

## Required Work

- Record what F30 proves and what it does not prove.
- Inventory latest simulator proof and log paths.
- Preserve gaps for physical-device verification, public accessibility conformance, TestFlight readiness, App Store submission readiness, final RC lock, signed archive/App Store Connect validation, and rendered external-platform proof.
- Classify doc QA/tooling advisories as Yellow unless they affect claim truth.
- Update registry/context/run-state only after hardening and truth check allow activation.

## Required Validation Commands

- `git status --short`
- `git diff --check`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- Release-claim/status scans named by the activation prompt
- Changed-file boundary check limiting changes to `docs/**` and `.codex/**`

## Evidence Outputs

- `docs/audits/rec01-release-evidence-truth-inventory-report.md`
- Updated `docs/codex/BATCH_REGISTRY.md`
- Updated `docs/codex/CONTEXT_INDEX.md`
- Updated `.codex/reports/current-run-state.md`
- Updated `.codex/reports/current-batch-train-state.md`

## Green / Yellow / Red Criteria

Green: evidence inventory is complete, no readiness claim introduced, no app code changed, F17-F30 truth preserved, and validation is clean or advisory-only.

Yellow: doc QA or batch-train advisory backlog remains but is classified and does not affect release-claim truth.

Red: app code changed, release/platform readiness claim introduced, AmbitionsOS treated as implemented, F17-F30 history altered, or validation failure remains unclassified.

## Stop Conditions

Stop on Red, forbidden file drift, unclassified validation failure, release-claim ambiguity, or any pressure to implement app behavior.

## What This Batch Must Not Claim

No App Store readiness, TestFlight readiness, release readiness, final RC lock, physical-device verification, public accessibility conformance, signed archive validation, App Store Connect validation, external-platform rendering, production model behavior, or AmbitionsOS implementation.

## What This Batch Does Not Prove

REC01 does not prove release readiness. It only inventories current evidence and claim gaps.

## Commit Message Recommendation

`Harden queued trains and verify 3.0 status truth`

## Next Safe Prompt / Next Gate

`REC02 Human Operator Release Proof Plan` only after REC01 is Green or accepted Yellow, committed, pushed, and the user explicitly says `Continue Release Evidence Closure`.

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
