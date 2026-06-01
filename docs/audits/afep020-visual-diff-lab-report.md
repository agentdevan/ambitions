# AFEP-020 Visual Diff Lab Report

## Result

Green, foundation only.

## Batch

AFEP-020 - Deterministic Visual Diff Lab.

## Scope

This batch adds a deterministic visual diff lab scaffold for the five canonical Ambitions surfaces:

- Today
- Goals
- Capture
- Time
- You

The scaffold keeps source-only preview metadata, deterministic artifact naming, and proof-boundary language local to the repo. It does not render screenshots, certify accessibility, or claim release readiness.

## Files

- `Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift`
- `Native/AmbitionsTests/App/ShellPreviewMatrixTests.swift`
- `docs/audits/afep020-visual-diff-lab-report.md`
- `docs/audits/afep020-visual-diff-fixture-matrix.md`
- `docs/audits/afep020-visual-proof-claim-boundary.md`

## Source Model

- `AFEP020VisualDiffLab` captures surface fixtures, variant dimensions, artifact bundle metadata, proof-boundary metadata, provenance references, and local-only claim flags.
- `ShellPreviewMatrix` keeps the existing AFRI-005 screenshot hook unchanged.
- The fallback screenshot proof path stays explicit through `docs/proof/afri/afri-005-shell-preview-screenshot-proof.md`.

## Validation

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-020` -> `STATUS: GREEN`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-020 --prompt prompts/batches/AFEP-020.md --batch-type source-changing` -> `Status: GREEN`
- `xcodegen generate` -> passed
- `make xcode-build-for-testing BATCH=AFEP-020` -> passed
- `make xcode-focused-test BATCH=AFEP-020 TEST=AmbitionsTests/ShellPreviewMatrixTests` -> passed
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-020 --prompt prompts/batches/AFEP-020.md --changed-from 162a3382f514a043b01f33eceaaad77ab8f685ec --batch-type source-changing` -> `Status: GREEN`
- `git diff --check` -> passed

## Claim Boundary

- No rendered screenshot proof.
- No accessibility certification claim.
- No device, CI, TestFlight, App Store, or release claim.
- No production-ready visual QA claim.

## Next Step

Keep any rendered proof work on the existing AFRI-005 path.

## Validation Artifacts

- Build summary: `.codex/xcode-summaries/AFEP-020/20260601T184106Z/build-for-testing-summary.json`
- Focused test summary: `.codex/xcode-summaries/AFEP-020/20260601T184217Z/focused-test-summary.json`
- Build log: `.codex/xcode-logs/AFEP-020/20260601T184106Z/build-for-testing.log`
- Focused test log: `.codex/xcode-logs/AFEP-020/20260601T184217Z/focused-test.log`
