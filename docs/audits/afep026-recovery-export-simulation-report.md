# AFEP-026 Recovery Export Simulation Report

Issue: `AMB-420`
Batch: `AFEP-026`
Date: 2026-06-01

## Result

The lifecycle policy requires export-safe views and rollback metadata for tombstoned and delete-candidate material, which makes recovery and extraction steps explicit instead of implicit.

## Simulation Summary

- Tombstoned material must retain provenance, recoverability, finalization, export-safe view, extraction evidence, and rollback metadata.
- Delete-candidate material must retain those fields plus extract-then-delete evidence.
- Generated, local-only, and proof-only material remain non-authority by default.

## Validation Results

- `python3 scripts/afep026_archive_tombstone_lifecycle_validate.py --self-test` -> passed
- `python3 scripts/afep026_archive_tombstone_lifecycle_validate.py --manifest docs/codex/AFEP_ARCHIVE_TOMBSTONE_LIFECYCLE_POLICY.json --fixtures fixtures/afep026` -> passed
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/afep026-archive-tombstone-lifecycle-report.md docs/audits/afep026-historical-policy-alignment-report.md docs/audits/afep026-recovery-export-simulation-report.md docs/audits/afep026-rollback-to-existing-historical-policy.md` -> passed

## Boundary

This report simulates recovery and export handling at the policy level only. It is not runtime deletion behavior, not storage behavior, and not proof of user-data export or restoration in production.
