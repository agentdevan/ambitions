# REC05 Human Review Packet Prompt

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

Status: Queued Ambitions 4.0 evidence batch; not started; blocked pending `Continue Release Evidence Closure` or current global 4.0 preauthorization and REC04 Green.

## Batch Identity

- Batch ID: `REC05`
- Name: Human Review Packet
- Train: Release Evidence Closure
- Mode: evidence/docs-only
- Owner: operator release review handoff
- Required approval phrase: `Continue Release Evidence Closure` or current
  global Ambitions 4.0 preauthorization

## Purpose

Create the human/operator release review packet that a product owner can use to
decide what to verify next. This packet must be explicit about evidence,
non-claims, human-only proof, and stop conditions.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md`
- `docs/canon/Ambitions_3_0_FAANG_Handoff_Readiness_Gate.md`
- `docs/codex/batch-trains/REC01_REC06_RELEASE_EVIDENCE_CLOSURE_TRAIN.md`
- REC01-REC04 reports
- Human operator proof plan from REC02
- Validation ledger from REC03
- Claim scan report from REC04
- `docs/codex/GLOBAL_BATCH_CONTINUATION_PROTOCOL.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- Confirm REC04 is Green or accepted Yellow.
- Confirm no human proof is being marked passed by Codex.

Stop if REC01-REC04 evidence is incomplete or contradictory.

## Allowed Files

- `docs/**`
- `.codex/**`

## Forbidden Files

- `Native/**`, `AppUI/**`, `Sources/**`
- `.github/workflows/**`
- Dependency manifests, lockfiles, signing/project config, generated output,
  persistence/schema, route/App Intent/widget implementation files

## Required Work

- Create a human review packet with:
  - current evidence summary
  - release-claim boundary
  - validation ledger links
  - human proof checklist
  - screenshots/manual review checklist if needed
  - operator stop conditions
  - exact launch/build/review references when already documented
  - decision options and consequences
- Separate "verified by repo evidence" from "requires human/operator proof".
- Preserve REC and Ambitions 3.0 historical truth.
- Do not claim the human review happened.

## Required Non-Goals

No app implementation, no archive/signing/App Store Connect action, no TestFlight
upload, no device proof, no release decision, no workflow/dependency/signing
change, no product strategy rewrite.

## Required Validation Commands

- `git status --short`
- `git diff --check`
- Release-claim scan over `README.md docs .codex`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- Changed-file boundary check limited to `docs/**` and `.codex/**`

## Required Evidence Outputs

- REC05 report under `docs/audits/`
- Human review packet under `docs/**`
- Updated registry/context/run-state only after evidence
- Remaining human-proof checklist
- Exact next safe prompt

## Green / Yellow / Red Criteria

Green: packet is operator-ready, evidence and non-claims are separated, human
proof is not faked, no forbidden files changed, and validation is clean or
advisory-only.

Yellow: human proof remains pending and is clearly assigned to the operator.

Red: packet claims approval/readiness, Codex marks human proof as passed, app
files change, release/platform claim is introduced, or validation failure is
unclassified.

## Stop Conditions

Stop on Red, missing REC04 evidence, human-proof ambiguity, release-claim
ambiguity, or pressure to make a release decision.

## What This Batch May Claim

It may claim a human review packet exists after commit.

## What This Batch Must Not Claim

No human approval, release readiness, App Store readiness, TestFlight readiness,
physical-device proof, public accessibility conformance, signed archive
validation, App Store Connect validation, or external-platform proof.

## Commit Message Recommendation

`Run REC05 human review packet`

## Next Safe Prompt / Path

`REC06 Release Evidence Closure Handoff` only after REC05 is Green or accepted
Yellow, committed, pushed, and train continuation is explicitly allowed.

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
