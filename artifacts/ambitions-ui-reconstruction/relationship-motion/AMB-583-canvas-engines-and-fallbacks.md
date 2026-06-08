# AMB-583 Canvas Engines With Static Fallbacks

Verdict: Green for AMB-583 scoped implementation.

## Source Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## Scope

AMB-583 installs shared Canvas engine primitives only for active product-meaningful contours that already exist in source: Goals relationship contour, Time LifeShape pressure contour, and Motion proof-thread contour.

The proof and trace wording stays tied to SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows inspection boundaries so the Canvas engine is not used as decorative proof.

## Changed Files

- `Sources/Components/ProductMeaningCanvasEngine.swift`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`
- `Native/AmbitionsTests/App/ProductMeaningCanvasEngineTests.swift`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`
- `docs/codex/existing-code-champion-coverage.yml`
- `artifacts/ambitions-ui-reconstruction/screenshots/canvas-engines-and-fallbacks-amb-583.png`
- `artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-583-canvas-engines-and-fallbacks.md`

## Implementation Notes

- Added `ProductMeaningCanvasEngineContract`, `ProductMeaningCanvasRole`, `ProductMeaningCanvasMark`, and `ProductMeaningCanvasEngine`.
- Replaced the active Goals inline Atlas relationship Canvas with `ProductMeaningCanvasEngine(role: .goalsRelationship)`.
- Replaced the active Time inline LifeShape pressure Canvas with `ProductMeaningCanvasEngine(role: .timePressure)` while preserving each LifeShape semantic mark intensity.
- Replaced the active Motion inline proof-thread Canvas with `ProductMeaningCanvasEngine(role: .motionProofThread)`.
- Added AMB-583 registry, concept-lock, and champion coverage entries.

## Static Fallback

- Reduce Motion switches the engine from Canvas rendering to deterministic Shape strokes using the same path geometry.
- The fallback remains accessibility-hidden because adjacent object labels carry source, relationship, pressure, proof, receipt, and replay meaning.
- Increase Contrast strengthens stroke width and opacity through shared theme state styling.
- Reduce Transparency lowers gradient intensity without changing the product role.

## Performance Notes

- No TimelineView loop is introduced.
- Goals and Motion draw one contour path each.
- Time draws only the bounded LifeShape semantic mark count.
- Engine layers are non-interactive and do not add gesture hit testing.

## Visual Evidence

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/canvas-engines-and-fallbacks-amb-583.png`
- Dimensions: `1206 x 2622`
- Final screenshot launch command:

```bash
SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 8ACCD665-4807-4102-B526-5A1AE20686A8 com.ambitions.ios --args -AmbitionsInitialSurface motion -AmbitionsScreenshotMode YES -AmbitionsMotionRenderState proof
```

The final screenshot shows the Motion proof-thread contour behind the Source, Proof, and Receipt primitive lines. A Time screenshot was also tried, but the LifeShape contour was too low in the first viewport to serve as the clearest AMB-583 proof, so the final artifact was retaken on Motion.

## Validation

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-583 --prompt artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-583-canvas-engines-and-fallbacks.md` — Green.
- `python3 scripts/ambitions-champion-coverage-check.py` — Green before source edits.
- `make xcode-focused-test BATCH=AMB-583 TEST=AmbitionsTests/ProductMeaningCanvasEngineTests` — 4 tests passed after one Swift helper-name repair.
- `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/canvas-engines-and-fallbacks-amb-583.png --simulator 8ACCD665-4807-4102-B526-5A1AE20686A8 --retries 3` — screenshot written and visually inspected.

## Post-Change Validation

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-583 --prompt artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-583-canvas-engines-and-fallbacks.md --changed-from 8b0fc9046350b8e9fe62f088b4d2d78f209a3491` — Green after adding AMB-583 to the Time / LifeShape lock prefix list.
- `python3 scripts/ambitions-unsupported-claim-scan.py --changed-from 8b0fc9046350b8e9fe62f088b4d2d78f209a3491` — Green.
- `bash scripts/release-claim-safety-scan.sh` — Green.
- `bash scripts/codex-forbidden-claim-scan.sh ...` — no blocking hits.
- `python3 scripts/ambitions-champion-coverage-check.py` — Green; generated report outputs were restored before commit.
- `git diff --check` — clean.

## Proof Boundaries

- This is local simulator screenshot proof and focused-test proof only.
- No real-device, TestFlight, App Store, public accessibility, measured performance, privacy, legal, CI, or release readiness proof is claimed.
- Static fallback behavior is source-proven by the focused test and contract. Manual Reduce Motion walkthrough remains outside this AMB-583 proof.

## Rollback

Revert this commit to remove the shared Canvas engine, restore the prior inline Goals, Time, and Motion Canvas contours, and remove the AMB-583 registry, concept-lock, coverage, report, and screenshot entries.
