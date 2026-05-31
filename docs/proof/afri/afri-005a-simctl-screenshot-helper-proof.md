# AFRI-005A Simctl Screenshot Helper Proof

Issue: AMB-393 / AFRI-005A

## Scope

- Added centralized simulator screenshot helper: `scripts/sim/simctl_screenshot.sh`.
- Added local smoke validation: `scripts/sim/simctl_screenshot_smoke.sh`.
- Added caller gate: `scripts/visual-qa/validate_screenshot_callers.sh`.
- The helper requires a `.png` output, creates nested output directories, resolves final paths, captures through a temp `.png`, validates non-empty PNG output, and moves the validated file into place.
- The helper supports explicit simulator selection, `${SIMULATOR_UDID}`, and `booted` fallback.
- The helper runs `xcrun simctl bootstatus`, retries screenshot capture, and emits a Markdown diagnostic on failure.

## Validation

- Pre guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-393 --batch-type guard-repair --prompt /tmp/AMB-393-AFRI-005A-guard-prompt.md` passed Green.
- Syntax checks:
  - `bash -n scripts/sim/simctl_screenshot.sh`
  - `bash -n scripts/sim/simctl_screenshot_smoke.sh`
  - `bash -n scripts/visual-qa/validate_screenshot_callers.sh`
- Caller gate: `bash scripts/visual-qa/validate_screenshot_callers.sh` passed Green.
- Forced failure: `bash scripts/sim/simctl_screenshot_smoke.sh --failure-only` produced a Red diagnostic artifact.
- Success smoke: `bash scripts/sim/simctl_screenshot_smoke.sh --success-only` captured a nested PNG twice and overwrote safely.

## Proof Artifacts

- Successful screenshot artifact: `output/visual-qa/simctl-smoke/nested/simctl-smoke.png`
- Successful screenshot size: `290625` bytes on both overwrite runs.
- Forced-failure diagnostic artifact: `output/visual-qa/simctl-smoke/failure/forced-failure.diagnostic.md`
- Booted simulator used for success smoke: `iPhone 17 (8ACCD665-4807-4102-B526-5A1AE20686A8)`

## Boundaries

- This is proof-harness/tooling evidence only.
- The output screenshot and diagnostic artifacts are generated validation outputs, not committed source.
- This does not claim full screenshot matrix completion, visual QA approval, rendered UI quality, accessibility approval, physical-device validation, TestFlight/App Store readiness, CI proof, or release readiness.
- Historical proof docs may still mention older direct commands; the caller gate scans active scripts, tests, harnesses, and validation packs for direct simctl screenshot export.

## Rollback

Revert the AMB-393 commit to remove the helper, smoke script, caller gate, and this proof packet. AFRI-033 / visual QA must remain blocked if no hardened screenshot export helper is available.
