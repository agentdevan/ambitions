# AMB-581 Horizon / Capacity Primitive Family

Verdict: Green for AMB-581 scoped execution

## Scope

AMB-581 installs shared Horizon / Capacity primitives for the active Time / LifeShape Field horizon, capacity, source/receipt, and continuity relationship surfaces. The primitives keep horizon controls subordinate to Time relationship/capacity state and not root-tab behavior.

This file was also used as the AMB-581-specific guard prompt after an initial broad primitive-registry prompt evaluated unrelated prior primitive content.

## Active Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## Changed Files

- `Sources/Components/HorizonCapacityPrimitiveFamily.swift`
- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
- `Native/AmbitionsTests/Time/HorizonCapacityPrimitiveFamilyTests.swift`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`
- `docs/codex/existing-code-champion-coverage.yml`
- `artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-581-horizon-capacity-family.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/horizon-capacity-family-amb-581.png`

## Implementation Notes

- Added `HorizonCapacityPrimitiveFamilyContract`, `HorizonCapacityPrimitiveRole`, `HorizonCapacityPrimitiveStage`, and `HorizonCapacityPrimitiveLine`.
- Replaced the active Time horizon selector, capacity statement, source/receipt row, and continuity dock with Horizon / Capacity primitive stage/line rows.
- Kept Day / Week / Month as relationship choices inside Time. They do not become root tabs or root navigation.
- Left dormant Time compatibility/card helpers in place, but added a focused test proving the active `TimeScreen` body does not instantiate the old card helpers.
- Registered the primitive family and AMB-581 guard/coverage permissions.

## Screenshot Proof

- Path: `artifacts/ambitions-ui-reconstruction/screenshots/horizon-capacity-family-amb-581.png`
- Command: `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/horizon-capacity-family-amb-581.png --simulator 8ACCD665-4807-4102-B526-5A1AE20686A8 --retries 3`
- Dimensions: `1206 x 2622`
- Visual inspection: The final screenshot retake shows the Horizon primitive stage with readable Day, Week, and Month primitive rows. An earlier screenshot had letter-by-letter wrapping in a three-column layout; that was treated as repair evidence, replaced with a vertical primitive stack, and taken again.

## Validation

- Pre parallel guard, repaired scoped prompt: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-581 --prompt artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-581-horizon-capacity-family.md`
  - Result: Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-581-pre.md`
- Champion coverage preflight: `python3 scripts/ambitions-champion-coverage-check.py`
  - Result: Green; generated reports restored before commit.
- Focused test, final post-repair run: `make xcode-focused-test BATCH=AMB-581 TEST=AmbitionsTests/HorizonCapacityPrimitiveFamilyTests`
  - Result: Green.
  - Final log: `.codex/xcode-logs/AMB-581/20260608T140112Z-AmbitionsTests-HorizonCapacityPrimitiveFamilyTests-40493-16797/focused-test.log`
  - Final output: `Executed 4 tests, with 0 failures (0 unexpected)`.

Post-change validation:

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-581 --prompt artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-581-horizon-capacity-family.md --changed-from 489441da82ebb31b16a6da7ce25dda604a0a1bfb`
  - Result: Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-581-post.md`
- `python3 scripts/ambitions-unsupported-claim-scan.py --changed-from 489441da82ebb31b16a6da7ce25dda604a0a1bfb`
  - Result: Green.
- `bash scripts/release-claim-safety-scan.sh`
  - Result: Green.
- `bash scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Features/Time/TimeLifeShapeField.swift Native/AmbitionsTests/Time/HorizonCapacityPrimitiveFamilyTests.swift Sources/Components/HorizonCapacityPrimitiveFamily.swift docs/codex/ambitions_primitive_invention_registry.md docs/codex/concept-lock-registry.yml docs/codex/existing-code-champion-coverage.yml artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-581-horizon-capacity-family.md`
  - Result: Green.
- `python3 scripts/ambitions-champion-coverage-check.py`
  - Result: Green; generated report files restored before commit.
- `git diff --check`
  - Result: Green.

## Repair Cycles

- Initial broad guard prompt was Red because it evaluated unrelated prior primitive registry content. Repaired by using this AMB-581 issue-scoped report prompt.
- Initial issue-scoped prompt was Red because it did not explicitly preserve runtime inspection terms. Repaired by adding SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows inspection wording.
- Focused test showed the active continuity dock still used `Label(item, systemImage: continuityIcon(at: index))`. Repaired by converting it to Horizon / Capacity primitive rows.
- Screenshot inspection showed the three-column horizon primitive layout compressed labels into unreadable columns. Repaired by changing the horizon selector to a vertical primitive stack and taking the screenshot again.

## Proof Boundary

Verified for AMB-581:

- The active Time field uses the shared Horizon / Capacity primitive family.
- Active generic horizon chip text, capacity statement text, calendar boundary pill, and continuity label paths covered by the focused test are absent.
- Old Time card helpers remain unreachable from the active `TimeScreen` body.
- The AMB-581 screenshot artifact exists and was visually inspected.

Not verified and not claimed:

- Full-app regression.
- Full manual accessibility QA.
- Real-device behavior.
- Performance readiness.
- Privacy/legal approval.
- CI, TestFlight, App Store, or release readiness.

## Rollback Notes

Revert the AMB-581 commit to remove the new primitive family, active Time wiring, focused tests, registry entries, and screenshot/report artifacts. No migration or user-data mutation was introduced.
