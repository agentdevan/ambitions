# REC04 Release Claim Copy Guard Prompt
<!-- markdownlint-disable MD013 -->

Status: Future prompt; do not run automatically. REC04 is not started.

## Batch Identity

- Batch ID: `REC04`
- Name: Release Claim Copy Guard
- Train: Release Evidence Closure
- Mode: evidence/docs-only
- Owner: release claim and active-copy truth
- Required approval phrase: `Continue Release Evidence Closure`

## Purpose

Audit active docs and handoff copy for release, App Store, TestFlight, platform,
physical-device, accessibility, and implementation claims that outrun REC01-REC03
evidence. Fix only claim-boundary wording. Do not change product strategy or app
behavior.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Release_Claim_Truth_Protocol.md`
- `docs/canon/Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md`
- `docs/canon/PXOS_Release_Safe_Product_Messaging.md`
- `docs/codex/batch-trains/REC01_REC06_RELEASE_EVIDENCE_CLOSURE_TRAIN.md`
- REC01, REC02, and REC03 reports
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/GLOBAL_BATCH_FAANG_QUALITY_BAR.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- Confirm REC03 is Green or accepted Yellow.
- Run release-claim scan before editing and save/classify hits.

Stop if evidence cannot determine whether a claim is supported.

## Allowed Files

- `README.md` only if active release/status wording needs correction
- `docs/**`
- `.codex/**`

## Forbidden Files

- `Native/**`, `AppUI/**`, `Sources/**`
- `.github/workflows/**`
- Dependency manifests, lockfiles, signing/project config, generated output,
  persistence/schema, route/App Intent/widget implementation files

## Required Work

- Scan active docs and handoff copy for unsupported claims.
- Classify hits as allowed negative example, historical claim, supported current
  truth, or unsupported active claim.
- Correct unsupported active claims to evidence-bound language.
- Preserve historical evidence without rewriting history.
- Keep Ambitions 3.0 completion truth and REC01 active truth intact.
- Update report/registry/context/run-state only after validation.

## Required Non-Goals

No broad docs cleanup, no product strategy rewrite, no app implementation, no
release readiness claim, no platform-proof claim, no PXOS/AOS implementation
claim, no workflow/dependency/signing changes.

## Required Validation Commands

- `git status --short`
- `git diff --check`
- `grep -R "App Store ready\|TestFlight ready\|production ready\|release ready\|physical device passed\|AmbitionsOS implemented\|PXOS implemented" README.md docs .codex | cat || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- Changed-file boundary check limited to `README.md`, `docs/**`, and `.codex/**`

## Required Evidence Outputs

- REC04 report under `docs/audits/`
- Claim scan summary with allowed and corrected hits
- Updated active docs only where unsupported claims existed
- Updated registry/context/run-state after evidence
- Exact next safe prompt

## Green / Yellow / Red Criteria

Green: unsupported active claims are removed or corrected, allowed negative and
historical hits are classified, no forbidden files changed, and validation is
clean or advisory-only.

Yellow: broad historical/negative scan hits remain but are classified and safe.

Red: unsupported readiness/platform claim remains active, product strategy is
rewritten, app code changes, historical truth is altered, or validation failure
is unclassified.

## Stop Conditions

Stop on Red, claim ambiguity that cannot be resolved from evidence, pressure to
claim readiness, or broad docs cleanup pressure.

## What This Batch May Claim

It may claim release-claim copy guard has run after commit.

## What This Batch Must Not Claim

No release readiness, App Store readiness, TestFlight readiness, final RC lock,
physical-device proof, signed archive validation, App Store Connect validation,
public accessibility conformance, external-platform proof, PXOS implementation,
or AmbitionsOS implementation.

## Commit Message Recommendation

`Run REC04 release claim copy guard`

## Next Safe Prompt / Path

`REC05 Human Review Packet` only after REC04 is Green or accepted Yellow,
committed, pushed, and train continuation is explicitly allowed.
