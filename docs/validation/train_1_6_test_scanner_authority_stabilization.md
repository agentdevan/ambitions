# Train 1.6 Test Runner + Scanner Authority Stabilization

Status: Green
Branch: design-truth-refraction
Base checkpoint: c0d1dc361b6b321900d28db5bbaa020b0cf3f2e0
Validation timestamp: 2026-06-18T12:34:57Z
Scope: Train 1.6 only. Train 2 did not begin.

## Commands Run

- `python3 -m py_compile scripts/ambitions-design-truth-refraction-audit.py scripts/ambitions-vocabulary-drift-scan.py scripts/ambitions-moat-drift-scan.py scripts/ambitions-repo-authority-validate.py`
- `python3 scripts/ambitions-design-truth-refraction-audit.py --check`
- `python3 scripts/ambitions-design-truth-refraction-audit.py --write`
- `git diff --check`
- `python3 scripts/ambitions-legacy-ia-route-lint.py`
- `scripts/ambitions-xcode-build-for-testing.sh --batch DESIGN-TRUTH-REFRACTION-TRAIN-1-6`
- `scripts/ambitions-xcode-validate.sh --batch DESIGN-TRUTH-REFRACTION-TRAIN-1-6 --lane focused-test --test AmbitionsTests/RepoTruthAuditLedgerTests,AmbitionsTests/StageMotionRoutingTests --json`
- `python3 scripts/ambitions-vocabulary-drift-scan.py`
- `python3 scripts/ambitions-moat-drift-scan.py`
- `python3 scripts/ambitions-repo-authority-validate.py`

## Pass / Fail Results

- Python compile: passed.
- Audit generator `--check`: initially failed after scanner/front-door changes because generated audit artifacts were stale; passed after a settling `--write` cycle.
- `git diff --check`: initially failed on generated Markdown hard-break trailing spaces; passed after generator formatting was fixed and artifacts were regenerated.
- Legacy IA route lint: passed.
- Build-for-testing: passed.
- Focused Xcode validation: passed.
- Vocabulary drift scan: passed.
- Moat drift scan: passed.
- Repo authority validation: passed.

## Xcode Artifacts

- Build summary: `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-1-6/20260618T122724Z-bft-96836-30239/build-for-testing-summary.json`
- Build log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-1-6/20260618T122724Z-bft-96836-30239/build-for-testing.log`
- Build result bundle: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-1-6/20260618T122724Z-bft-96836-30239/build-for-testing.xcresult`
- Focused validation summary: `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-1-6/20260618T122845Z-validate-97914-16108/validate-summary.json`
- Focused validation benchmark: `.codex/xcode-benchmarks/DESIGN-TRUTH-REFRACTION-TRAIN-1-6/20260618T122845Z-validate-97914-16108/validate-benchmark.json`
- `RepoTruthAuditLedgerTests` summary: `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-1-6/20260618T122854Z-AmbitionsTests-RepoTruthAuditLedgerTests-98093-3214/focused-test-summary.json`
- `RepoTruthAuditLedgerTests` log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-1-6/20260618T122854Z-AmbitionsTests-RepoTruthAuditLedgerTests-98093-3214/focused-test.log`
- `RepoTruthAuditLedgerTests` result bundle: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-1-6/20260618T122854Z-AmbitionsTests-RepoTruthAuditLedgerTests-98093-3214/focused-test.xcresult`
- `StageMotionRoutingTests` summary: `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-1-6/20260618T123057Z-AmbitionsTests-StageMotionRoutingTests-99262-353/focused-test-summary.json`
- `StageMotionRoutingTests` log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-1-6/20260618T123057Z-AmbitionsTests-StageMotionRoutingTests-99262-353/focused-test.log`
- `StageMotionRoutingTests` result bundle: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-1-6/20260618T123057Z-AmbitionsTests-StageMotionRoutingTests-99262-353/focused-test.xcresult`

## Focused Tests Actually Executed

- `RepoTruthAuditLedgerTests`: 3 tests executed, 0 failures.
- `StageMotionRoutingTests`: 4 tests executed, 0 failures.
- Focused validation wrapper total: 2 suites, 7 tests executed, 0 failures.

## Focused Tests Not Run

- No separate audit-generator XCTest suite exists in this slice. Audit-generator coverage was exercised through `python3 scripts/ambitions-design-truth-refraction-audit.py --check` and `--write`.
- No broad app test plan, UI test plan, screenshot matrix, accessibility matrix, mutation proof matrix, privacy proof, or release proof was run or claimed.

## Focused Test Runner Finding

Train 1.5 looked idle because `xcodebuild test-without-building` spent a long period in package resolution before test execution, while the wrapper captured output until completion. Train 1.6 reproduced the quiet period but then reached real test execution. No runner code change was needed.

Observed behavior:

- Simulator destination was valid: `iPhone 17`, UDID `81485ACD-AF10-4B92-8C03-9BB8805A4A23`, booted.
- `RepoTruthAuditLedgerTests` began execution after repeated `Resolve Package Graph` lines and passed.
- `StageMotionRoutingTests` then ran and passed.
- The wrapper correctly reported executed-test counts and would have rejected a zero-test pass.

## Scanner Changes Made

- `scripts/ambitions-vocabulary-drift-scan.py`
  - Treats `Ambitions is not:` and `Avoid:` style sections as negative-example sections.
  - Replaces stale required terms `Recovery Thread` and `Recommendation Trace` with current truth terms `Recovery` and `Recommendation Accountability`.
- `scripts/ambitions-moat-drift-scan.py`
  - Treats `Ambitions is not:` and `Avoid:` style sections as negative-example sections.
- `scripts/ambitions-design-truth-refraction-audit.py`
  - Removes generated Markdown trailing spaces so regenerated audit artifacts satisfy `git diff --check`.

## Authority Map Changes Made

- `scripts/ambitions-repo-authority-validate.py` now validates the active authority map:
  - `README.md`
  - `AGENTS.md`
  - `docs/README.md`
  - `docs/truth/README.md`
  - `docs/truth/PRODUCT_DESIGN_TRUTH.md`
  - `docs/truth/PRODUCT_MOAT_TRUTH.md`
  - `docs/truth/IMPLEMENTATION_TRUTH.md`
  - `docs/truth/RELEASE_TRUTH.md`
  - `docs/truth/CODEX_PROCESS_TRUTH.md`
  - `docs/truth/HISTORICAL_POLICY.md`
  - `docs/validation`
  - `docs/audits`
  - `docs/architecture`
  - `docs/codex`
  - `project.yml`
  - `Package.swift`
- `README.md` and `docs/README.md` were narrowed to existing truth, audit, validation, architecture, Codex, and source entry points.

Old required paths removed from validator authority requirements because they are not present and are not current authority under `docs/truth/*`:

- `frontend/README.md`
- `frontend/installed-canon.md`
- `frontend/intended-canon.md`
- `frontend/visual-encyclopedia/README.md`
- `frontend/visual-encyclopedia/AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md`
- `backend/README.md`
- `codex-os/README.md`
- `product-canon/README.md`
- `validation/README.md`
- `history/README.md`
- `docs/canon/README.md`
- `docs/status/repo-authority-cleanup-baseline.md`
- `docs/status/repo-authority-cleanup-active-path-allowlist.md`
- `docs/status/repo-authority-cleanup-final-report.md`

Rationale: active repo authority starts in `docs/truth/*`; missing legacy portal paths should not be recreated just to satisfy stale validation.

## False Positives Removed

- `calendar clone` and `chatbot` under `Ambitions is not:` in `PRODUCT_DESIGN_TRUTH.md`.
- `overdue` and `streak broken` under `Avoid:` in `PRODUCT_MOAT_TRUTH.md`.
- Missing `Recovery Thread` and `Recommendation Trace` requirements, which were stale scanner vocabulary relative to current truth wording.
- Missing legacy authority portal paths, now treated as obsolete validator assumptions rather than required files.

## Enforcement Preserved

- Forbidden terms remain scanned outside negative-example sections.
- Native Swift source, tests, and product-facing copy scanned by the moat scanner are not globally exempted.
- The authority validator now rejects stale front-door references to obsolete portal paths.
- Product Design Truth was not rewritten to satisfy scanners.

## Remaining Yellow / Red Risks

- `.swiftpm/xcode/xcuserdata/devan.xcuserdatad/xcschemes/xcschememanagement.plist` remains a pre-existing local Xcode user-data modification and was not touched for Train 1.6.
- Broad XCTest suites, UI tests, screenshot proof, accessibility proof, mutation proof, privacy proof, and release proof remain not run and not claimed.

## Product Behavior Changed

No. No production Swift runtime or product UI files were changed.

## Train 2 Go / No-Go

Train 2 is allowed to begin from the Train 1.6 validation/scanner/authority perspective.

Train 2 did not begin in this pass.
