# AMB-575 Goals Object-Stage Primitive

Verdict: Green

## Scope

AMB-575 replaced the active Goals first-viewport Atlas/Lens generic containers with a named Goals object-stage primitive. The contract uses `Direction Atlas` as the active product object and preserves `Constellation Atlas` as the source-compatible stage name already used by the component.

This is source, focused unit-test, and local simulator screenshot evidence for the scoped Goals first viewport only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

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

- Added `GoalsObjectStagePrimitiveContract.current` so the Goals first viewport has an inspectable object-stage primitive contract.
- Replaced the active equal-weight area band, Atlas container, relationship field shell, Orbital Lens container, lane blocks, and source/proof/trust block chrome with rule, texture, and inline relationship primitives.
- Reworked life-area items from large rounded capsule containers into line-based relationship items with selected markers.
- Replaced the Constellation Atlas object container with `atlasObjectTexture`, top/bottom rules, and a left relationship marker.
- Renamed the visual relationship field to `atlasRelationshipField` and removed the rounded field shell.
- Replaced the Orbital Lens container with top/bottom/leading rules while preserving its expand/collapse behavior.
- Added Goals-owned bottom chrome clearance and a veil so first-viewport proof does not depend on readable lower text behind shell/tab-bar chrome.
- Added focused AMB-575 tests for the primitive contract, first-stage source slice, bottom clearance, and registry entry.
- Registered `goals-object-stage` in the primitive invention registry and allowed AMB-575 through the design primitive concept lock.

## First Viewport Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/goals-object-stage-amb-575.png`
- Pixel dimensions: 1170 x 2532
- Capture commands:
  - `xcrun simctl install 81485ACD-AF10-4B92-8C03-9BB8805A4A23 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface goals -AmbitionsScreenshotMode YES -AmbitionsGoalsRenderState proof-available`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/goals-object-stage-amb-575.png --simulator 81485ACD-AF10-4B92-8C03-9BB8805A4A23 --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/goals-object-stage-amb-575.png`
- Visual inspection result: first viewport presents a Direction Atlas object stage with line-based life-area items, Atlas relationship texture, source/proof/receipt/Today relationships, and an Orbital Lens treatment rendered without the prior rounded Atlas/Lens containers.
- Proof boundary: this screenshot proves the Goals object-stage first viewport. It does not claim full lower-scroll lens visual approval or shared shell/tab-bar chrome repair; inherited native tab-bar chrome remains outside this AMB-575 object-stage proof.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-575 TEST=AmbitionsTests/GoalsObjectStagePrimitiveTests` — passed
- Final focused log: `.codex/xcode-logs/AMB-575/20260608T102202Z-AmbitionsTests-GoalsObjectStagePrimitiveTests-52241-2452/focused-test.log`
- Output: `Executed 3 tests, with 0 failures (0 unexpected)`

## Changed Files

- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/AmbitionsTests/Goals/GoalsObjectStagePrimitiveTests.swift`
- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-575-goals-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-object-stage-amb-575.png`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`

## Registry Entries

- `docs/codex/ambitions_primitive_invention_registry.md` now includes `goals-object-stage` in the current registry table and a detailed primitive entry.
- `docs/codex/concept-lock-registry.yml` now allows AMB-575 for `design_primitives`.

## Rollback Notes

- Revert the AMB-575 commit to restore the prior Goals first-viewport equal-weight area band, Atlas container, relationship field shell, Orbital Lens container, lane blocks, and source/proof/trust block treatment.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/object-stage/AMB-575-goals-object-stage.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/goals-object-stage-amb-575.png`

## Remaining Yellow Debt

- None for the AMB-575 Goals object-stage scope.
- Shared shell/tab-bar lower-viewport polish is not claimed by this report and remains outside this issue's changed-file boundary.

## Required Completion Footer

Verdict: Green
Artifact paths:
- artifacts/ambitions-ui-reconstruction/object-stage/AMB-575-goals-object-stage.md
- artifacts/ambitions-ui-reconstruction/screenshots/goals-object-stage-amb-575.png
Focused tests:
- make xcode-focused-test BATCH=AMB-575 TEST=AmbitionsTests/GoalsObjectStagePrimitiveTests — passed; Executed 3 tests, with 0 failures (0 unexpected)
Changed files:
- Native/Ambitions/Features/Goals/GoalComponents.swift
- Native/Ambitions/Features/Goals/GoalsScreen.swift
- Native/AmbitionsTests/Goals/GoalsObjectStagePrimitiveTests.swift
- artifacts/ambitions-ui-reconstruction/object-stage/AMB-575-goals-object-stage.md
- artifacts/ambitions-ui-reconstruction/screenshots/goals-object-stage-amb-575.png
- docs/codex/ambitions_primitive_invention_registry.md
- docs/codex/concept-lock-registry.yml
Rollback notes:
- Revert the AMB-575 commit to restore the prior Goals first-viewport equal-weight area band, Atlas container, relationship field shell, Orbital Lens container, lane blocks, and source/proof/trust block treatment.
Remaining Yellow debt:
- None for the AMB-575 Goals object-stage scope; shared shell/tab-bar lower-viewport polish is outside this issue.
