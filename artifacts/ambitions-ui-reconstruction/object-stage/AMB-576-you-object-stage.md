# AMB-576 You Object-Stage Control Primitive

Verdict: Green

## Scope

AMB-576 promoted the You `personal-runtime-group` primitive into a source-backed object-stage/control primitive for Personal Runtime / User System Profile. The root You surface now starts from an explicit object-stage contract, uses grouped line controls for the first viewport, removes stale unreachable generic hero/control/system-center/defaults containers, and converts the generic catch-all detail wrapper into a semantic `YouControlGroup`.

This is source, focused unit-test, and local simulator screenshot evidence for the scoped You root and generic-wrapper replacement only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

## Active Truth Inspected

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

## What Changed

- Added `YouObjectStageControlPrimitiveContract.current` for the You Personal Runtime / User System Profile object-stage control primitive.
- Replaced the root detached title treatment with a line-anchored object-stage header.
- Replaced first-viewport rounded per-row root chrome with grouped line controls and native disclosure affordances.
- Changed the root grouping from `Account & Preferences` to `Runtime Preferences` and removed `settings band` framing.
- Removed stale unreachable `YouHeroCard`, `YouControlRoomCard`, `YouSystemCenterCard`, and `YouDefaultsCard` definitions.
- Replaced the generic `YouSectionCard` wrapper with `YouControlGroup` for receipts, corrections, proof, durations, source settings, local data, permissions, integrations, accessibility, help, and about drill-down content.
- Added bottom safe-area clearance and a lower veil so first-viewport proof does not rely on readable text behind inherited shell/tab-bar chrome.
- Added focused AMB-576 coverage to the existing `PersonalSystemCenterDesignSystemTests` target.
- Promoted `personal-runtime-group` in the primitive invention registry and allowed AMB-576 through You/profile and design primitive concept locks.
- Repaired champion coverage metadata for the AMB-575 Goals test file before AMB-576 source edits, then reran the coverage check Green before source work.

## First Viewport Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/you-object-stage-amb-576.png`
- Pixel dimensions: 1170 x 2532
- Capture commands:
  - `xcrun simctl install 81485ACD-AF10-4B92-8C03-9BB8805A4A23 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface you -AmbitionsScreenshotMode YES`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/you-object-stage-amb-576.png --simulator 81485ACD-AF10-4B92-8C03-9BB8805A4A23 --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/you-object-stage-amb-576.png`
- Visual inspection result: first viewport presents You as Personal Runtime / User System Profile with a line-anchored object header and grouped semantic control rows for planning setup, runtime preferences, history/trust, and support/system routing. It does not present a detached profile hero, operator-style root overview, or generic settings wall.
- Proof boundary: this screenshot proves the scoped You root object-stage/control install. It does not claim shared shell/tab-bar chrome repair; inherited lower native tab-bar chrome remains outside this AMB-576 changed-file boundary.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-576 TEST=AmbitionsTests/PersonalSystemCenterDesignSystemTests` - passed after one compile-token repair cycle.
- Final focused log: `.codex/xcode-logs/AMB-576/20260608T105549Z-AmbitionsTests-PersonalSystemCenterDesignSystemTests-66684-13774/focused-test.log`
- Output: `Executed 5 tests, with 0 failures (0 unexpected)`
- Repair note: the first focused run failed during build-for-testing because `theme.colors.backgroundBase` was not a valid token. The veil was repaired to use `theme.colors.surfacePrimary`, then the same focused command passed.

## Changed Files

- `Native/Ambitions/Features/You/YouRootSurface.swift`
- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/AmbitionsTests/App/PersonalSystemCenterDesignSystemTests.swift`
- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-576-you-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/you-object-stage-amb-576.png`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`
- `docs/codex/existing-code-champion-coverage.yml`

## Registry Entries

- `docs/codex/ambitions_primitive_invention_registry.md` now promotes `personal-runtime-group` for AMB-576 and records AMB-576 proof artifacts.
- `docs/codex/concept-lock-registry.yml` now allows AMB-576 for `you_profile_personal_runtime` and `design_primitives`.
- `docs/codex/existing-code-champion-coverage.yml` now records the AMB-575 `GoalsObjectStagePrimitiveTests.swift` test-only owner metadata that preflight required before AMB-576 source work.

## Validation

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-576 --prompt docs/codex/ambitions_primitive_invention_registry.md` - passed before source edits.
- `python3 scripts/ambitions-champion-coverage-check.py` - failed once on missing AMB-575 test metadata, then passed after the self-heal metadata repair.
- `make xcode-focused-test BATCH=AMB-576 TEST=AmbitionsTests/PersonalSystemCenterDesignSystemTests` - passed; final output `Executed 5 tests, with 0 failures (0 unexpected)`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-576 --prompt docs/codex/ambitions_primitive_invention_registry.md --changed-from 16c905f91c3972f9a7666d6421ce0bdca6769740` - passed; report `build/reports/parallel-implementation-guard/AMB-576-post.md`.
- `python3 scripts/ambitions-unsupported-claim-scan.py --changed-from 16c905f91c3972f9a7666d6421ce0bdca6769740` - passed.
- `bash scripts/release-claim-safety-scan.sh` - passed.
- `bash scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Features/You/YouRootSurface.swift Native/Ambitions/Features/You/YouScreen.swift Native/AmbitionsTests/App/PersonalSystemCenterDesignSystemTests.swift docs/codex/ambitions_primitive_invention_registry.md docs/codex/concept-lock-registry.yml docs/codex/existing-code-champion-coverage.yml artifacts/ambitions-ui-reconstruction/object-stage/AMB-576-you-object-stage.md` - no blocking hits; one context-only provider-boundary sentence in `YouScreen.swift`.
- `python3 scripts/ambitions-champion-coverage-check.py` - passed; generated build reports were restored and not committed.
- `git diff --check` - passed.

## Rollback Notes

- Revert the AMB-576 commit to restore the prior You root row-card chrome, generic catch-all section wrapper, stale unreachable generic containers, primitive registry state, concept-lock prefixes, and focused test assertions.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/object-stage/AMB-576-you-object-stage.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/you-object-stage-amb-576.png`

## Remaining Yellow Debt

- None for the AMB-576 You object-stage/control scope.
- Shared shell/tab-bar lower-viewport polish is not claimed by this report and remains outside this issue's changed-file boundary.

## Required Completion Footer

Verdict: Green
Artifact paths:
- artifacts/ambitions-ui-reconstruction/object-stage/AMB-576-you-object-stage.md
- artifacts/ambitions-ui-reconstruction/screenshots/you-object-stage-amb-576.png
Focused tests:
- make xcode-focused-test BATCH=AMB-576 TEST=AmbitionsTests/PersonalSystemCenterDesignSystemTests - passed; Executed 5 tests, with 0 failures (0 unexpected)
Changed files:
- Native/Ambitions/Features/You/YouRootSurface.swift
- Native/Ambitions/Features/You/YouScreen.swift
- Native/AmbitionsTests/App/PersonalSystemCenterDesignSystemTests.swift
- artifacts/ambitions-ui-reconstruction/object-stage/AMB-576-you-object-stage.md
- artifacts/ambitions-ui-reconstruction/screenshots/you-object-stage-amb-576.png
- docs/codex/ambitions_primitive_invention_registry.md
- docs/codex/concept-lock-registry.yml
- docs/codex/existing-code-champion-coverage.yml
Rollback notes:
- Revert the AMB-576 commit to restore prior You root row-card chrome, generic catch-all section wrapper, stale unreachable generic containers, primitive registry state, concept-lock prefixes, and focused test assertions.
Remaining Yellow debt:
- None for the AMB-576 You object-stage/control scope; shared shell/tab-bar lower-viewport polish is outside this issue.
