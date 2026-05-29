# Ambitions 3.0 Run State Protocol

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, rewrite-authority-before-proof, status-expedite
> Dispositions: clarify-status-before-use, rewrite-authority-before-proof, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active Codex run-control protocol

## Purpose

Long Codex runs must be resumable from repo files, not only from chat memory.
Run state records the active task, selected context, decisions, validation,
risks, and next checkpoint.

## Required Fields

- current task
- task size
- active mode
- active primitive
- active surface
- active context pack
- active skill
- active operation
- active validation pack
- docs read
- files allowed
- files forbidden
- files touched
- decisions made
- tests run
- failures
- open risks
- next phase
- stop conditions
- last checkpoint

## Rules

- At the start of every phase, re-read `.codex/reports/current-run-state.md`
  and the selected context pack.
- After every phase, update run state or write a run report when persistent
  state would create noise.
- For long prompts, checkpoint after each phase.
- If context seems compressed, stale, or uncertain, rebuild state from files
  before continuing.
- No XL batch may proceed without run-state updates after each checkpoint.

## Persistent State Policy

`.codex/reports/current-run-state.md` is committed as a default template. For
ordinary runs, prefer final reports or audit docs over constantly changing this
file. For XL runs, update it deliberately and reset it to default before final
closeout unless the user asks to preserve live state.

## Batch Train State

Batch trains also use `.codex/reports/current-batch-train-state.md`. Treat it as the train-level sibling to current run state. It records train name, type, active batch, completed batches, gate status, selected context pack, skill, operation, validation pack, allowed/forbidden files, files touched, commands, tests, failures, architecture warnings, checkpoint history, stop condition, next batch, and resume instructions. Re-read it after compaction before continuing any train.

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
