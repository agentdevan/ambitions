# REC06 Release Evidence Closure Handoff Prompt

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

Status: Queued Ambitions 4.0 evidence batch; not started; blocked pending `Continue Release Evidence Closure` or current global 4.0 preauthorization and REC05 Green.

## Batch Identity

- Batch ID: `REC06`
- Name: Release Evidence Closure Handoff
- Train: Release Evidence Closure
- Mode: evidence/docs-only
- Owner: release evidence closure and next decision
- Required approval phrase: `Continue Release Evidence Closure` or current
  global Ambitions 4.0 preauthorization

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
- Decide whether global order can move to the next train through the global
  orchestrator and current preauthorization only after REC06 is committed and
  the next-batch dry-run says `Execution allowed: YES`.

## Required Non-Goals

No app implementation, no release readiness claim, no human proof claim, no
Product Depth/PXOS/AOS/ME/CS implementation or current-app activation, no
workflow/dependency change, no signing/platform action.

## Required Validation Commands

- `git status --short`
- `git diff --check`
- Release-claim scan over `README.md docs .codex`
- Status scan for unintended started/completed queued trains
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

Red: release readiness is claimed, human proof is faked, a queued train is
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

After REC06, select the next global batch only through the global orchestrator,
current preauthorization, and the mandatory dry-run gate. Do not claim the next
train has started, and do not claim future canon is implemented, until the next
batch actually begins and produces evidence.

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
