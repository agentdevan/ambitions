# Batch / Prompt / Train Ledger Schema

Status: Active schema draft
Owner: BATCH-LEDGER-001
Linear issue: AMB-24

Repo truth wins. This schema defines how Ambitions inventories batches, prompts, trains, runner artifacts, and proof artifacts without treating Linear as repo truth.

## Item types

- batch
- prompt
- train
- runner
- proof_artifact
- sequence_authority
- status_mirror
- historical_reference

## Required fields

- stable_id
- item_type
- repo_path
- title
- source_authority
- current_status
- proof_state
- touched_surfaces
- touched_systems
- proof_paths
- conflicts
- no_claims

## Status values

Forward:
- planned
- installed_not_run
- source_present
- partial
- implemented_source_only
- validated
- accepted_yellow
- green
- red
- unknown

Non-forward:
- canceled
- retired
- superseded
- historical

## Proof states

- none
- source_only
- audit
- dry_run
- test_log
- build_log
- screenshot
- device
- release_packet
- current_green
- current_yellow
- current_red
- historical_only

## Conflict types

- duplicate_batch
- overlapping_scope
- stale_status
- old_canon_language
- old_ia_language
- release_overclaim
- implementation_overclaim
- proof_missing
- source_missing
- prompt_without_runner
- manifest_mismatch
- superseded_by_ios26
- historical_only

## Rules

- Source-only is not implemented.
- Audit-only is not current proof.
- Unknown remains unknown until evidence exists.
- Historical and superseded work cannot become active by default.
- Linear status is not repo truth.
- Green requires current evidence and exact proof paths.

## Non-claims

This schema does not prove implementation, build success, test success, accessibility validation, performance validation, device validation, privacy/legal approval, TestFlight readiness, App Store readiness, or release readiness.

## AMB-24 required field refinements

Additional required/generated fields:

- initial_added_date
- initial_added_commit
- touched_files
- source_of_truth_docs
- duplicates
- blockers
- related_linear_issues
- runner_command
- linear_sync_key

## Status definitions

- planned: known work not started.
- implemented: source landed and matching proof exists.
- partial implementation: source landed without complete proof.
- implemented_source_only: source exists, but proof is missing or incomplete.
- validated: current command/log proof exists for the scoped claim.
- accepted_yellow: known gap is documented and explicitly accepted.
- green: current evidence satisfies the scoped gate.
- red: blocking failure or unsafe contradiction exists.
- unknown: evidence is insufficient.
- canceled: intentionally stopped.
- retired: no longer runnable.
- superseded: replaced by newer authority.
- historical: retained for traceability only.

## Generator and sync requirements

- Every ledger item must have a stable_id.
- Every generated Linear mirror must include a linear_sync_key.
- Duplicate records are not allowed.
- Historical records must not become active work by default.
- Partial implementation must never be promoted to implemented without proof.

## AMB-24 required field refinements

Additional required/generated fields:

- initial_added_date
- initial_added_commit
- touched_files
- source_of_truth_docs
- duplicates
- blockers
- related_linear_issues
- runner_command
- linear_sync_key

## Status definitions

- planned: known work not started.
- implemented: source landed and matching proof exists.
- partial implementation: source landed without complete proof.
- implemented_source_only: source exists, but proof is missing or incomplete.
- validated: current command/log proof exists for the scoped claim.
- accepted_yellow: known gap is documented and explicitly accepted.
- green: current evidence satisfies the scoped gate.
- red: blocking failure or unsafe contradiction exists.
- unknown: evidence is insufficient.
- canceled: intentionally stopped.
- retired: no longer runnable.
- superseded: replaced by newer authority.
- historical: retained for traceability only.
## Generator and sync requirements

- Every ledger item must have a stable_id.
- Every generated Linear mirror must include a linear_sync_key.
- Duplicate records are not allowed.
- Historical records must not become active work by default.
- Partial implementation must never be promoted to implemented without proof.
