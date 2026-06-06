# AMB-520 Packet 12 Visual Proof Closeout

Status: Accepted Yellow
Date: 2026-06-06
Branch: main
Base SHA: `d4d1de11564d29d85b8ac84bc3dea91862991727`

## Scope

AMB-520 is a proof/review packet for screenshots, QA, accessibility variants, and claim boundaries across Today, Capture, Time, Goals, Motion, and You.

This closeout is proof-only. It does not change app source, tests, project files, package manifests, privacy manifests, entitlements, screenshot baselines, or runtime behavior.

## Active Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Files Changed

- `prompts/batches/AMB-520.md`
- `docs/audits/screenshots/AMB-520/AMB-520-proof-matrix.md`
- `docs/codex/reports/AMB-520-packet-12-visual-proof-closeout.md`

## Why

The first runner pass stopped Red before source changes because the AMB-520 prompt did not explicitly carry all required runtime inspection terms for guard compatibility: `SourceRecord`, `ReplayTrace`, and `You / What Ambitions knows`.

The prompt was repaired narrowly, and the packet now records a staged proof matrix with explicit screenshot/accessibility gaps and no baseline mutation.

## Verified

- AMB-519 dependency is cleared by Linear Done / Green closeout at commit `d4d1de11564d29d85b8ac84bc3dea91862991727`.
- Runtime root is `AmbitionsApp -> LaunchGateView -> AmbitionsRootView -> SwiftUI TabView`.
- `AppMeridianShell.swift` was not used as runtime-root proof.
- `AppTab.allCases` is `Today / Goals / Time / Motion / You`.
- `AppTab.capture` is compatibility, not an active top-level tab.
- AMB-520 proof matrix exists and documents all required surfaces, states, variants, source proof, and remaining gaps.
- No screenshot or visual baseline was accepted, regenerated, or bulk-updated.
- Screenshots are not claimed as release, accessibility, performance, privacy, TestFlight, App Store, or readiness proof.

## Validation

Run:

- `BATCH_TYPE=proof-only AUTO_BRANCH=0 AUTO_COMMIT=1 AUTO_PUSH=1 ALLOW_MAIN_COMMIT=1 ALLOW_YELLOW_COMMIT=1 KEEP_GOING_ON_YELLOW=1 MAX_REPAIR_PASSES=1 scripts/ambitions-codex-train.sh AMB-520 prompts/batches/AMB-520.md` -> stopped Red in phase 01 before edits because the prompt lacked required runtime inspection terms.
- `git diff --check` -> passed.
- `bash -n scripts/ambitions-codex-train.sh` -> passed.
- `jq empty docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json` -> passed.
- active-batch source-reference existence check with shell parsing -> passed.
- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-520` -> GREEN.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-520 --prompt prompts/batches/AMB-520.md --batch-type source-changing` -> GREEN after prompt repair.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-520 --prompt prompts/batches/AMB-520.md --changed-from d4d1de11564d29d85b8ac84bc3dea91862991727 --batch-type source-changing` -> GREEN.
- `bash scripts/visual-qa/validate_screenshot_callers.sh` -> GREEN; it also printed missing-path warnings for absent optional `validation` and `.codex/validation` scan directories.
- `bash scripts/fet-visual-qa-packet-check.sh` -> advisory Yellow/Red: found `docs/audits/screenshots/AMB-520`, but reports `RED_MISSING docs/codex/FRONTEND_SCREENSHOT_EVIDENCE_STANDARD.md`; no changed Swift UI files detected.
- `bash scripts/ambitions-xcode-benchmark.sh --status` -> installed; timing-only, not build/test/release proof.
- targeted stale/readiness claim scan over AMB-520 prompt and proof docs -> only the prompt's Red-condition policy text matched; no active readiness claim found.

## Not Verified

- `xcodegen generate`
- `./scripts/build-local.sh`
- `xcodebuild`
- rendered screenshots
- screenshot baselines
- rendered visual approval
- manual VoiceOver traversal
- Dynamic Type simulator/device proof
- Reduce Motion simulator/device proof
- Increase Contrast simulator/device proof
- Reduce Transparency simulator/device proof
- Differentiate Without Color simulator/device proof
- tap-target measurement
- performance proof
- privacy/legal approval
- physical-device proof
- TestFlight readiness
- App Store readiness
- release readiness

Reason: AMB-520 is using the Packet 0R verified command boundary and produced a staged proof matrix, not release-facing visual approval.

## Yellow Items

- Rendered screenshots are still missing.
- Human visual review is still missing.
- Accessibility variants are documented but not manually or visually verified.
- `scripts/fet-visual-qa-packet-check.sh` is advisory and may remain Yellow/Red for missing broader screenshot-evidence convention files outside this packet.

## Red Blockers

None remaining for this proof-only accepted-Yellow closeout.

## Yellow Accepted Reason

The packet produced a staged proof matrix with explicit gaps, repaired the runner/guard prompt defect, preserved no-claim boundaries, and did not update baselines. It remains Yellow because rendered screenshots, human visual review, manual accessibility traversal, simulator/device accessibility variants, tap-target measurement, performance proof, privacy/legal proof, and release proof were not produced.

## Rollback

Before commit:

```bash
git restore prompts/batches/AMB-520.md docs/codex/reports/AMB-520-packet-12-visual-proof-closeout.md
rm -rf docs/audits/screenshots/AMB-520
```

After commit, revert the AMB-520 commit.

## Next Gate

Next eligible packet after accepted Yellow/Green closeout: `AMB-521`, subject to current truth and Linear dependency preflight.
