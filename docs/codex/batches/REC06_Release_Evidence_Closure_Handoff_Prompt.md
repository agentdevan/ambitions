# REC06 Release Evidence Closure Handoff Prompt
<!-- markdownlint-disable MD013 -->

Status: Future prompt; do not run automatically. REC06 is not started.

## Batch Identity

- Batch ID: `REC06`
- Name: Release Evidence Closure Handoff
- Train: Release Evidence Closure
- Mode: evidence/docs-only
- Owner: release evidence closure and next decision
- Required approval phrase: `Continue Release Evidence Closure`

## Purpose

Close the Release Evidence Closure train with an evidence-bound handoff, final
Yellow list, remaining human-proof checklist, and exact next decision path. This
batch must not convert evidence closure into release readiness.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/codex/batch-trains/REC01_REC06_RELEASE_EVIDENCE_CLOSURE_TRAIN.md`
- REC01-REC05 reports and outputs
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_BATCH_CONTINUATION_PROTOCOL.md`
- `docs/codex/GLOBAL_BATCH_FAANG_QUALITY_BAR.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- Confirm REC05 is Green or accepted Yellow.
- Confirm no unresolved Red exists in REC01-REC05.
- Confirm no human proof is being marked passed by Codex.

Stop if REC evidence is incomplete, contradictory, or claim-unsafe.

## Allowed Files

- `docs/**`
- `.codex/**`

## Forbidden Files

- `Native/**`, `AppUI/**`, `Sources/**`
- `.github/workflows/**`
- Dependency manifests, lockfiles, signing/project config, generated output,
  persistence/schema, route/App Intent/widget implementation files

## Required Work

- Produce final REC closure handoff with:
  - REC01-REC06 result summary
  - evidence proven
  - evidence not proven
  - human-proof checklist still pending
  - unsupported claims still blocked
  - validation logs and report links
  - remaining Yellow advisories
  - Red findings found/fixed/deferred
  - exact next decision prompt/path
- Update registry/context/run-state only after evidence.
- Mark REC closure truth carefully without claiming release readiness.
- Decide whether global order can move to the next train only as a future
  decision path, not as automatic execution.

## Required Non-Goals

No app implementation, no release readiness claim, no human proof claim, no train
auto-start, no Product Depth/PXOS/AOS/ME/CS activation, no workflow/dependency
change, no signing/platform action.

## Required Validation Commands

- `git status --short`
- `git diff --check`
- Release-claim scan over `README.md docs .codex`
- Status scan for unintended started/completed future trains
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- Changed-file boundary check limited to `docs/**` and `.codex/**`

## Required Evidence Outputs

- REC06 final closure report under `docs/audits/`
- Updated `docs/codex/BATCH_REGISTRY.md`
- Updated `docs/codex/CONTEXT_INDEX.md`
- Updated `.codex/reports/current-run-state.md`
- Updated `.codex/reports/current-batch-train-state.md`
- Exact next recommended prompt/path

## Green / Yellow / Red Criteria

Green: REC closure handoff is complete, claim-safe, evidence-bound, no forbidden
files changed, and validation is clean or advisory-only.

Yellow: nonblocking doc/tooling/human-proof advisories remain classified and do
not imply readiness.

Red: release readiness is claimed, human proof is faked, a future train is
started by implication, unsupported platform claims appear, app files change, or
validation failure is unclassified.

## Stop Conditions

Stop on Red, REC evidence contradiction, human-proof ambiguity, future-train
activation pressure, release-claim ambiguity, or changed-file boundary failure.

## What This Batch May Claim

It may claim Release Evidence Closure handoff exists after commit if Green.

## What This Batch Must Not Claim

No release readiness, App Store readiness, TestFlight readiness, final RC lock,
physical-device proof, signed archive validation, App Store Connect validation,
public accessibility conformance, external-platform proof, PXOS implementation,
AmbitionsOS implementation, or automatic next-train start.

## Commit Message Recommendation

`Run REC06 release evidence closure handoff`

## Next Safe Prompt / Path

After REC06, stop. The next path must be chosen explicitly through the global
orchestrator, for example `Run Next Global Batch`, `Start PXOS Future-Canon
Train`, `Start ME Train`, `Start CS Train`, or `Start AOS Train`.
