# AFRI-033A Screenshot Matrix Helper Gate Proof

Issue: AMB-394 / AFRI-033A
Date: 2026-05-31
Scope: Guard visual QA screenshot matrix capture behind the centralized hardened `simctl` screenshot helper.

## Result

Status: Green for helper-gated capture and Red for forced helper failure.

`scripts/visual-qa/capture_matrix.sh` now routes every screenshot capture through `scripts/sim/simctl_screenshot.sh`, writes deterministic matrix outputs, and records helper diagnostics when capture fails. The matrix script does not call `xcrun simctl io ... screenshot` directly.

## Evidence

- `bash -n scripts/visual-qa/capture_matrix.sh`: passed.
- `bash scripts/visual-qa/validate_screenshot_callers.sh`: passed after wording repair; no direct screenshot export callers outside the helper/smoke allowlist.
- `bash scripts/visual-qa/capture_matrix.sh --smoke --output-dir output/visual-qa/afri-033a-smoke`: passed.
- Smoke report: `output/visual-qa/afri-033a-smoke/visual-qa-matrix-report.md`.
- Smoke status: `GREEN`.
- Smoke screenshots:
  - `today-normal`
  - `today-recovery`
  - `you-reduce-motion`
- `bash scripts/visual-qa/capture_matrix.sh --smoke --force-failure --output-dir output/visual-qa/afri-033a-forced`: failed as expected with exit status 1.
- Forced failure report: `output/visual-qa/afri-033a-forced/visual-qa-matrix-report.md`.
- Forced failure status: `RED`.
- Forced failure diagnostic: `output/visual-qa/afri-033a-forced/diagnostics/forced-failure.diagnostic.md`.
- Forced failure diagnostic reason: invalid simulator `AMB-394-NO-SUCH-SIMULATOR` failed `xcrun simctl bootstatus`.

## Matrix Contract

Full matrix states recorded by the helper-gated script:

- `today-normal`
- `today-low-capacity`
- `today-protected-time`
- `today-recovery`
- `today-source-stale`
- `today-source-unavailable`
- `today-empty-manual`
- `today-receipt`
- `goals-normal`
- `goals-blocked`
- `capture-normal`
- `capture-empty`
- `time-normal`
- `time-protected-time`
- `you-normal`
- `you-dynamic-type`
- `you-reduce-motion`
- `you-increase-contrast`

## Claim Boundary

This proof verifies helper-gated screenshot export, deterministic output/report paths, and Red diagnostic surfacing. It is not visual design approval, accessibility approval, release proof, App Store proof, or evidence that every matrix state has been manually reviewed.
