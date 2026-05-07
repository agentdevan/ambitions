# Resume Global Batch Train Alias Report

Status: Green for alias creation.
Date: 2026-05-06
Type: docs/governance/Codex OS handoff.

## Goal

Make `resume global batch train` a canonical repo-local operator phrase so Codex can resume the Ambitions global batch train without the user restating the full orchestration prompt.

## Files Changed

- `AGENTS.md`
- `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`
- `docs/audits/resume-global-batch-train-alias-report.md`

## Implementation Summary

Added `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md` as the source-truth alias contract for global train resumption.

Updated `AGENTS.md` so Codex reads the alias document when the user says `resume global batch train`.

The alias instructs Codex to resume from repo evidence, close parked overlay Yellow items if safe, verify hosted workflows remain removed, classify residual hosted-workflow mentions, continue to AOS17 unless newer repo evidence advances the train, and continue eligible batches until complete or unrecoverable Red.

## Non-Claims

This alias does not claim AOS17 has started, the FIO01 Yellow is closed, app behavior changed, production Swift changed, release readiness, App Store readiness, TestFlight readiness, physical-device proof, public accessibility conformance, legal/privacy compliance, or hosted CI proof.

## Validation Notes

Connector-side proof:

- `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md` was created.
- `AGENTS.md` references `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md` in the read order and repo-local Codex system list.
- No production app code was touched.

Local follow-up validation:

```bash
git status --short
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
rg -n "resume global batch train|RESUME_GLOBAL_BATCH_TRAIN" AGENTS.md README.md docs .codex || true
```
