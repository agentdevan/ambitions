# Train 1.5 Validation Unblock + Audit Checkpoint

Status: Yellow
Branch: design-truth-refraction
Base: 0449794e22dc3219988d83189702d0d07fe1a321
Scope: Train 1.5 only. Train 2 did not begin.

## Build Result

- `scripts/ambitions-xcode-build-for-testing.sh --batch DESIGN-TRUTH-REFRACTION-TRAIN-1-5`: passed.
- Summary: `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-1-5/20260618T114851Z-bft-70686-26293/build-for-testing-summary.json`
- Result bundle: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-1-5/20260618T114851Z-bft-70686-26293/build-for-testing.xcresult`
- Log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-1-5/20260618T114851Z-bft-70686-26293/build-for-testing.log`
- Note: the wrapper summary kept `failure_category: "unknown"` even though `status` was `passed`; the build log ended with `Test Build Succeeded`.

## Build Blocker Fixed

- Fixed `Native/AmbitionsTests/App/StageMotionRoutingTests.swift` by replacing invalid enum-case destructuring of `ShellOverlayState.memoryLens` with assertions against the routed overlay struct.
- The corrected test checks `overlay.kind == .memoryLens` and `overlay.query == expectedQuery`.
- Production code changed: no.

## Tests Run

- Build-for-testing compiled the app test target, including `RepoTruthAuditLedgerTests` and the previously blocking `StageMotionRoutingTests`.
- `scripts/ambitions-xcode-test-focused.sh --batch DESIGN-TRUTH-REFRACTION-TRAIN-1-5 --only-testing AmbitionsTests/RepoTruthAuditLedgerTests` was started but did not reach test execution; it remained idle in `test-without-building` startup/package-resolution state and was terminated.

## Tests Not Run

- Focused `RepoTruthAuditLedgerTests` execution is not claimed.
- Focused `StageMotionRoutingTests` execution is not claimed.
- Screenshot proof, accessibility proof, mutation proof, large-file split proof, and stub-retirement proof were not run and are not claimed for this train.

## Scanner Results

- `python3 -m py_compile scripts/ambitions-design-truth-refraction-audit.py`: passed.
- `python3 scripts/ambitions-design-truth-refraction-audit.py --check`: passed.
- `git diff --check`: passed before this checkpoint document was added.
- Final `git diff --check` retry after adding this checkpoint document was blocked by local Git processes hanging in an uninterruptible state; no whitespace failure is claimed or concealed.
- Direct trailing-whitespace check on the two Train 1.5 changed files passed.
- `python3 scripts/ambitions-legacy-ia-route-lint.py`: passed.
- `python3 scripts/ambitions-vocabulary-drift-scan.py`: failed.
- `python3 scripts/ambitions-moat-drift-scan.py`: failed.
- `python3 scripts/ambitions-repo-authority-validate.py`: failed.

## False Positives Identified

- Vocabulary/moat scanners flagged explicitly negative examples in truth docs, including `calendar clone`, `chatbot`, `overdue`, and `streak broken`. These are documented as forbidden product directions, not active user-facing copy. The recommended repair is a narrow scanner exclusion for explicitly marked negative-example or avoid-language sections, not a Product Design Truth rewrite.
- Repo authority validation requires legacy authority paths such as `frontend/README.md`, `frontend/installed-canon.md`, `backend/README.md`, `product-canon/README.md`, and `docs/canon/README.md`. These paths should not be recreated during Train 1.5 unless current authority confirms they are still canon. The validator likely needs a narrow update to the current authority map.

## Files Changed

- `Native/AmbitionsTests/App/StageMotionRoutingTests.swift`
- `docs/validation/train_1_5_validation_unblock.md`

Train 0/1 intended untracked files remain the audit infrastructure, tests, generator, and generated audit docs:

- `Native/Ambitions/Diagnostics/RepoTruthAuditLedger.swift`
- `Native/AmbitionsTests/App/RepoTruthAuditLedgerTests.swift`
- `scripts/ambitions-design-truth-refraction-audit.py`
- `docs/audits/design_truth_readback.md`
- `docs/audits/design_truth_refraction_audit.md`
- `docs/audits/file_by_file_truth_ledger.md`
- `docs/audits/obsolete_architecture_audit.md`
- `docs/audits/large_swift_file_discipline_audit.md`
- `docs/audits/stub_adapter_retirement_audit.md`
- `docs/audits/forbidden_language_audit.md`

## Product Behavior Changed

No. The only source fix is test-only and compile-only.

## Checkpoint Decision

- Train 0/1 can be committed as a Yellow reviewable checkpoint if the known scanner false positives, stale validator findings, and focused-test execution gap are accepted.
- Train 2 is not allowed to begin from this pass.
