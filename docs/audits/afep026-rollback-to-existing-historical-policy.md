# AFEP-026 Rollback to Existing Historical Policy

Issue: `AMB-420`
Batch: `AFEP-026`
Date: 2026-06-01

## Result

If the machine-readable lifecycle policy needs to be removed, the repo can fall back to the existing narrative historical policy in `docs/truth/HISTORICAL_POLICY.md` without changing runtime behavior.

## Rollback Steps

1. Remove `docs/codex/AFEP_ARCHIVE_TOMBSTONE_LIFECYCLE_POLICY.json`.
2. Remove `scripts/afep026_archive_tombstone_lifecycle_validate.py`.
3. Remove `fixtures/afep026/`.
4. Remove the AFEP-026 audit reports in `docs/audits/`.
5. Keep `docs/truth/HISTORICAL_POLICY.md`, `docs/truth/*`, `AGENTS.md`, `README.md`, and current source truth as the active authority path.
6. Re-run claim scans and `git diff --check`.

## Boundary

This rollback note is a governance path only. It does not claim runtime or release effects.
