# REC04 Release Claim Copy Guard Prompt

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

Status: Queued Ambitions 4.0 evidence batch; not started; blocked pending
`Continue Release Evidence Closure` or current global 4.0 preauthorization, and
REC03 Green.

## Batch Identity

- Batch ID: `REC04`
- Name: Release Claim Copy Guard
- Train: Release Evidence Closure
- Mode: evidence/docs-only
- Owner: release claim and active-copy truth
- Required approval phrase: `Continue Release Evidence Closure` or current
  `Run Global Batch Sequence Until Blocked` Ambitions 4.0 preauthorization

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
