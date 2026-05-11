# Xcode Build-System Maximum Throughput Batch Report

## Status: GREEN

Batch ID:
`XCODE-BUILD-SYSTEM-MAX-01`

## Queue evidence

- Queue evidence: `.codex/state/active-batch.yml`, `docs/codex/BATCH_REGISTRY.md`, `docs/codex/AMB_REMAINING_BATCH_REFERENCE.md`, and `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json` were preserved as active sequence sources.
- PK18 remains the next product implementation batch per current queue order.

## Objective

Install a local build-lab execution model for safer, resumable, simulator-aware, result-bundle-based Xcode validation with local-first tooling and Codex control-plane integration before resuming the remaining global batch train.

## PK17 completion/pushed verification

- As provided by the handoff context for this phase, PK17 was already Green and completed in `origin/main` before this phase.
- This phase did not modify PK17 artifacts.

## Queue placement after PK17 and before PK18

- Next product implementation batch remains `PK18 Today Command Handler Extraction`.
- This phase did not renumber queue IDs, did not reactivate completed batches, and did not alter PK order.

Remaining record count: 25 active remaining-batch templates reviewed for PK18–PK41.

## Files changed

- `scripts/ambitions-build-lab-doctor.sh`
- `scripts/ambitions-xcode-version-check.sh`
- `scripts/ambitions-xcodegen-needed.sh`
- `scripts/ambitions-xcode-sim-health.sh`
- `scripts/ambitions-deriveddata-manager.sh`
- `scripts/ambitions-xcode-build-for-testing.sh`
- `scripts/ambitions-xcode-test-focused.sh`
- `scripts/ambitions-xcode-test-plan.sh`
- `scripts/ambitions-xcode-result-extract.sh`
- `scripts/ambitions-xcode-failure-classifier.py`
- `scripts/ambitions-xcode-validate.sh`
- `.xcode-version`
- `.mise.toml`
- `Brewfile.ambitions-build-lab`
- `.gitignore`
- `Makefile`
- `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md`
- `docs/codex/XCODE_VALIDATION_LANE_MATRIX.md`
- `docs/codex/XCODE_TOOLCHAIN_PINNING.md`
- `docs/codex/XCODE_RESULT_BUNDLE_PROTOCOL.md`
- `docs/codex/playbooks/XCODE_SICK_SIMULATOR_PLAYBOOK.md`
- `docs/codex/playbooks/DERIVEDDATA_HYGIENE_PLAYBOOK.md`
- `docs/codex/playbooks/XCODE_TEST_PLAN_OWNERSHIP_PLAYBOOK.md`
- `docs/codex/playbooks/XCODE_FAILURE_CLASSIFICATION_PLAYBOOK.md`
- `docs/codex/playbooks/TUIST_EVALUATION_AFTER_PK41_PLAYBOOK.md`
- `prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md`
- `docs/codex/AMB_GLOBAL_TRAIN_CODEX_IMPLEMENTATION_INSTRUCTIONS.md`
- `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md`
- `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json`
- `prompts/batches/PK18.md` through `prompts/batches/PK41.md`
- `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01.md`

## Files intentionally not changed

- Production app source under `Native/Ambitions/**/*.swift`
- `Native/Ambitions/Features`, `Native/Ambitions/Services`, `Native/Ambitions/Persistence`, `Native/Ambitions/Domain`
- `AppUI/**`, `Sources/**`
- `.github/**`, entitlements/signing/release automation artifacts
- Project wiring beyond build-system safety (`project.yml` and `.xcodeproj` unchanged in this phase)
- Existing completed queue order files (except mirror repair in train documents where required)

## Tooling added

- Brewfile + pinning stack for local build-lab operation:
  - `Brewfile.ambitions-build-lab`
  - `.mise.toml`
  - `.xcode-version`
- `.xcode-version` uses local active Xcode (`26.3`) from environment.
- Toolchain posture remains non-destructive and runner-safe (no mandatory internet install in this phase).

## Scripts added/updated

- Added/updated:
  - build-lab health (`ambitions-build-lab-doctor.sh`)
  - Xcode validation and guard scripts:
    - `ambitions-xcode-version-check.sh`
    - `ambitions-xcodegen-needed.sh`
    - `ambitions-xcode-sim-health.sh`
    - `ambitions-deriveddata-manager.sh`
    - `ambitions-xcode-build-for-testing.sh`
    - `ambitions-xcode-test-focused.sh`
    - `ambitions-xcode-test-plan.sh`
    - `ambitions-xcode-result-extract.sh`
    - `ambitions-xcode-failure-classifier.py`
    - `ambitions-xcode-validate.sh`
- Added executable mode for batch scripts via explicit permissions for local runner execution.

## Docs/playbooks added/updated

- Added:
  - `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md`
  - `docs/codex/XCODE_VALIDATION_LANE_MATRIX.md`
  - `docs/codex/XCODE_TOOLCHAIN_PINNING.md`
  - `docs/codex/XCODE_RESULT_BUNDLE_PROTOCOL.md`
  - `docs/codex/playbooks/XCODE_SICK_SIMULATOR_PLAYBOOK.md`
  - `docs/codex/playbooks/DERIVEDDATA_HYGIENE_PLAYBOOK.md`
  - `docs/codex/playbooks/XCODE_TEST_PLAN_OWNERSHIP_PLAYBOOK.md`
  - `docs/codex/playbooks/XCODE_FAILURE_CLASSIFICATION_PLAYBOOK.md`
  - `docs/codex/playbooks/TUIST_EVALUATION_AFTER_PK41_PLAYBOOK.md`
- Updated:
  - `prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md`
  - `docs/codex/AMB_GLOBAL_TRAIN_CODEX_IMPLEMENTATION_INSTRUCTIONS.md`

## Prompt files updated

- `prompts/batches/PK18.md` through `prompts/batches/PK41.md` now use `scripts/ambitions-xcode-validate.sh` and wrapper lanes (`none`, `build`, `build-for-testing`, `focused-test`, `test-plan`) instead of raw `xcodebuild test`.
- `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01.md` added from batch source.
- PK21 prompt was updated to wrapper-first validation commands.

## Makefile targets updated

- `build-lab-doctor`
- `xcode-validate`
- `xcode-focused-test`
- `xcode-build-for-testing`
- `xcode-test-plan`

## Test plans added/deferred

- Deferred: no new `.xctestplan` files were added in this bounded patch due no clean, low-risk project-plan wiring.
- Decision is documented in `docs/codex/XCODE_TEST_PLAN_OWNERSHIP_PLAYBOOK.md`.

## Toolchain pinning result

- `xcode-version` and xcode tools were surfaced through:
  - `.xcode-version`
  - `Brewfile.ambitions-build-lab`
  - `scripts/ambitions-xcode-version-check.sh`
  - `scripts/ambitions-build-lab-doctor.sh`
- Required tools (`xcodebuild`, `xcodegen`) were present.
- Optional tools missing in this environment:
  - `xcparse` (for extraction features)
  - `yq`
  - `watchman`

## DerivedData policy result

- Repo-local DerivedData path standardized:
  - `.codex/DerivedData/Ambitions`
- Scripts default to local DerivedData and do not delete global DerivedData.
- Global DerivedData remains untouched by default by design.

## Simulator policy result

- Simulator policy centralized in `ambitions-xcode-sim-health.sh`.
- Simulator operations are lane-aware and avoid destructive all-simulator erase.
- `--repair` and `--erase-selected` supported for narrow remediation only.

## Result-bundle policy result

- Validation outputs target:
  - `.codex/xcode-results/<BATCH_ID>/<timestamp>/`
  - `.codex/xcode-logs/<BATCH_ID>/<timestamp>/`
  - `.codex/xcode-summaries/<BATCH_ID>/<timestamp>/`
- `.gitignore` updated to ignore these artifacts by default.
- `ambitions-xcode-result-extract.sh` preserves raw `.xcresult` fallback when `xcparse` is unavailable.

## Failure-classifier result

- `scripts/ambitions-xcode-failure-classifier.py` was added and validates as Python syntax-valid.
- It supports the required classification set and JSON output for downstream lane reporting.

## Validation commands and exit codes

Phase 04 repair rerun:

1. `git diff --check`
   - exit: 0
2. `bash -n scripts/ambitions-build-lab-doctor.sh`
   - exit: 0
3. `bash -n scripts/ambitions-xcode-version-check.sh`
   - exit: 0
4. `bash -n scripts/ambitions-xcodegen-needed.sh`
   - exit: 0
5. `bash -n scripts/ambitions-xcode-sim-health.sh`
   - exit: 0
6. `bash -n scripts/ambitions-deriveddata-manager.sh`
   - exit: 0
7. `bash -n scripts/ambitions-xcode-build-for-testing.sh`
   - exit: 0
8. `bash -n scripts/ambitions-xcode-test-focused.sh`
   - exit: 0
9. `bash -n scripts/ambitions-xcode-test-plan.sh`
   - exit: 0
10. `bash -n scripts/ambitions-xcode-result-extract.sh`
    - exit: 0
11. `bash -n scripts/ambitions-xcode-validate.sh`
    - exit: 0
12. `python3 -m py_compile scripts/ambitions-xcode-failure-classifier.py`
    - exit: 0
13. `python3 -m json.tool docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json >/tmp/ambitions-global-remaining-train-blueprint-json-check.txt`
    - exit: 0
14. `make prompt-audit || true`
    - exit: 0; informational Yellow classification persisted for support/eval/template files, with 162 active runnable prompts audited.
15. `make batch-self-check || true`
    - exit: 0; Green runner self-check.
16. `python3 scripts/ambitions-control-plane-check.py || true`
    - exit: 0; Green queue invariants.
17. `python3 scripts/ambitions-final-report-gate.py docs/audits/xcode-build-system-max-report.md --strict || true`
    - exit: 0; Green required closeout fields.
18. `scripts/ambitions-build-lab-doctor.sh || true`
    - exit: 0; required tools present, optional `xcparse`, `yq`, and `watchman` missing.
19. `scripts/ambitions-xcode-validate.sh --batch XCODE-BUILD-SYSTEM-MAX-01 --lane none`
    - exit: 10; expected `no_validation_required` for lane `none`.

Original Phase 03 validation context retained below:

1. `git status --short`
   - exit: 0
2. `git diff --check`
   - exit: 0
3. `bash -n scripts/ambitions-build-lab-doctor.sh`
   - exit: 0
4. `bash -n scripts/ambitions-xcode-version-check.sh`
   - exit: 0
5. `bash -n scripts/ambitions-xcodegen-needed.sh`
   - exit: 0
6. `bash -n scripts/ambitions-xcode-sim-health.sh`
   - exit: 0
7. `bash -n scripts/ambitions-deriveddata-manager.sh`
   - exit: 0
8. `bash -n scripts/ambitions-xcode-build-for-testing.sh`
   - exit: 0
9. `bash -n scripts/ambitions-xcode-test-focused.sh`
   - exit: 0
10. `bash -n scripts/ambitions-xcode-test-plan.sh`
    - exit: 0
11. `bash -n scripts/ambitions-xcode-result-extract.sh`
    - exit: 0
12. `bash -n scripts/ambitions-xcode-validate.sh`
    - exit: 0
13. `python3 -m py_compile scripts/ambitions-xcode-failure-classifier.py`
    - exit: 0
14. `python3 -m json.tool docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json >/tmp/ambitions-global-remaining-train-blueprint-json-check.txt`
    - exit: 0
15. `make prompt-audit || true`
    - exit: 0 (reported `YELLOW`, see below)
16. `make batch-self-check || true`
    - exit: 0
17. `python3 scripts/ambitions-control-plane-check.py || true`
    - exit: 0 (GREEN invariants)
18. `python3 scripts/ambitions-final-report-gate.py docs/audits/xcode-build-system-max-report.md --strict || true`
    - exit: 0 after report was present
19. `scripts/ambitions-build-lab-doctor.sh || true`
    - exit: 0
20. `scripts/ambitions-xcode-validate.sh --batch XCODE-BUILD-SYSTEM-MAX-01 --lane none`
    - exit: 10 (`no_validation_required` from wrapper path for this lane)

## Defects found

- Missing required report file before final report gate execution (`docs/audits/xcode-build-system-max-report.md`).
- `make prompt-audit` returned `YELLOW` due broad classification notes (non-blocking classification status).
- Wrapper validation lane `none` exited `10` (expected behavior) and did not run tests/synthesis.
- `xcodebuild` output extractor path (`xcparse`) missing in environment.
- Phase 03 review found that the build-for-testing, focused-test, and test-plan wrappers created only batch-level artifact directories before writing under timestamp-level paths.
- Phase 03 review found stale raw focused `xcodebuild` validation language in `docs/codex/AMB_GLOBAL_TRAIN_CODEX_IMPLEMENTATION_INSTRUCTIONS.md`.

## Defects repaired

- Added `docs/audits/xcode-build-system-max-report.md`.
- Added full Build Lab/validation scripts and docs/playbook ownership in allowed scope.
- Added `.gitignore` entries for result/log/summaries and DerivedData paths.
- Updated PK18–PK41 prompts and remaining execution template to use wrapper commands.
- Added timestamp-level result/log/summary directory creation in:
  - `scripts/ambitions-xcode-build-for-testing.sh`
  - `scripts/ambitions-xcode-test-focused.sh`
  - `scripts/ambitions-xcode-test-plan.sh`
- Replaced stale raw focused `xcodebuild` governance phrases in `docs/codex/AMB_GLOBAL_TRAIN_CODEX_IMPLEMENTATION_INSTRUCTIONS.md` with wrapper lane language.

## Defects deferred

- Full-suite and UI-terminal validation execution for each batch remains deferred to batch owners and local lanes after this tooling batch.
- Optional simulator/tooling conveniences (`xcparse`, `yq`, `watchman`) remain deferred install/dependency tasks.
- `.xctestplan` physical wiring was deferred due no clean low-risk project integration point in this pass.

## Accepted Yellow rationale (if any)

- None for final batch status after Phase 04 repair.
- Environment notes retained:
  - No `xcparse` on this machine, so rich extraction remains partial.
  - `make prompt-audit` status is informational Yellow without active template/prompt metadata violation.
- No production validation proof was run in this phase; this is a tooling-only batch.

## Claims made

- Build Lab wrapper-first Xcode validation and lane guidance now exists in scripts/docs/prompts.
- Repo-local DerivedData path and artifact ignore policy are documented and implemented.
- PK18 queue continuity is preserved and remains the next implementation batch.

## Claims not made

- No claim that app functionality changed.
- No claim of full test suite pass, simulator proof pass, terminal proof pass, accessibility pass, or release readiness.
- No claim that missing optional tooling has been installed in environment.

## Rollback notes

- Preferred rollback command:
  - `git revert <commit-sha>`
- Manual rollback (if needed):
  - Remove build-lab scripts.
  - Revert Build Lab docs/playbooks updates.
  - Remove Makefile target additions.
  - Remove `Brewfile.ambitions-build-lab`, `.mise.toml`, `.xcode-version`, and `.gitignore` additions.
  - Remove optional `.xctestplan` files if later added.

## Next eligible implementation batch

- `PK18 Today Command Handler Extraction`
