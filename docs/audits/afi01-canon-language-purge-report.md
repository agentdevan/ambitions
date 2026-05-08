# AFI01 Canon Language Purge Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Status: Accepted Yellow
Batch: AFI01 Canon Language Purge

## Result

AFI01 completed as a docs/canon/governance purge. Active source-truth language
now preserves `Today / Goals / Capture / Time / You` as the flagship top-level
IA and treats Plan-era language as contextual, historical, or compatibility
debt.

## Files Changed

- `docs/AmbitionsCanon/02_Continuity_Layer_Chrome.md`
- `docs/AmbitionsCanon/06_QA_Preview_Visual_Drift.md`
- `docs/codex/batches/AFI01_Canon_Language_Purge.md`
- `docs/audits/afi01-canon-language-purge-report.md`
- `docs/handoff/AFI_Ambitions_Flagship_Interface_Completion_Report.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `.codex/state/active-batch.yml`
- `scripts/canon-language-drift-scan.sh`
- `scripts/ai/acx.py`

## Behavior Changed

None. No app code, route, schema, persistence, package, project, entitlement,
signing, dependency, or runtime behavior changed.

## Banned / Compatibility Name Scan

Active AFI/governance files were scanned for:

- `ACUI`
- `Today / Goals / Capture / Plan / You`
- `Plan tab`
- `Plan screen`
- `top-level Plan`
- `Profile tab`
- `Insights tab`
- `Habits tab`

Allowed remaining hits are explicit supersession, compatibility maps, hard-Red
guards, or historical entries marked as historical evidence. Active language was
updated where it implied Plan-era naming as current truth.

## Tests Run

- `bash -n scripts/global-train-next-batch.sh scripts/global-train-status-summary.sh scripts/canon-language-drift-scan.sh`: exit 0.
- `python3 -m py_compile scripts/ai/acx.py`: exit 0.
- `scripts/canon-language-drift-scan.sh`: exit 0; Yellow changed-file hits are intentional banned-term lists, AFI supersession language, or historical registry evidence.
- `scripts/global-train-next-batch.sh`: exit 0; returned `AFI02 IA Hierarchy Lock`.
- `scripts/global-train-status-summary.sh`: exit 0; returned `AFI02 IA Hierarchy Lock`.
- `git diff --check`: exit 0.
- `python3 scripts/ai/acx_local.py bundle quick`: exit 0; raw logs under `.codex/logs/2026-05-08T10-42-16/`.
- `python3 scripts/ai/acx_impact.py <changed files>`: exit 0; matched `codex_os_tooling` and `codex_docs`.
- `python3 scripts/ai/acx_local.py bundle docs`: exit 0; `acx-gate-all` Green with advisory scan findings; raw logs under `.codex/logs/2026-05-08T10-42-16/`, `.codex/logs/2026-05-08T10-42-17/`, and `.codex/logs/2026-05-08T10-42-18/`.
- `python3 scripts/ai/acx_local.py bundle codex-os`: exit 0; `acx-gate-all` Green with advisory scan findings; raw logs under `.codex/logs/2026-05-08T10-42-40/` and `.codex/logs/2026-05-08T10-42-41/`.
- `python3 scripts/ai/acx_local.py bundle batch-closeout`: exit 0; `acx-gate-all` Green with advisory scan findings; raw logs under `.codex/logs/2026-05-08T10-42-58/` and `.codex/logs/2026-05-08T10-43-00/`.
- `scripts/batch-train-gate-check.sh || true`: exit 0; Yellow dirty-tree hint before commit.

## Tests Not Run

App build, focused Swift tests, visual packets, accessibility packets, device
tests, release/archive validation, and hosted CI were not run because this was a
docs/canon/governance language purge with no app-source changes.

## Known Risks

- Historical batch registry rows and old audit reports still contain Plan-era
  terms. Those are tolerated only as historical evidence or compatibility debt.
- Current app code may still contain legacy symbols, routes, or owner folders.
  AFI01 does not change code and does not claim user-facing implementation.

## Yellows Carried

- Historical stash remains preserved and unapplied.
- AFI02 remains required to lock hierarchy and continue reducing ambiguity.
- Visual, accessibility, and implementation proof remain future AFI work.

## Rollback Path

Revert the AFI01 docs/state/helper commit.

## Claims

Only docs/canon/governance language was reconciled.

## Non-Claims

No production readiness, app implementation completion, visual QA proof,
accessibility conformance, performance proof, release readiness, App Store
readiness, TestFlight readiness, physical-device proof, privacy/legal approval,
sync readiness, or backend completion is claimed.

## Next Eligible Batch

AFI02 IA Hierarchy Lock.
