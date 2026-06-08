# AMB-588 Primitive Screenshot And Focused Test Gate

Verdict: Yellow

AMB-588 verified existing primitive-family screenshot artifacts and ran the focused XCTest targets that exist for the installed primitive families. The screenshot artifacts are present and dimension-readable, and all matching focused tests passed. Green is not honest because the inherited AMB-587 structural no-card scan still reports active generic/card output, with the remaining review-required debt owner-filed under AMB-607.

Runtime/source changed files: none.

Required proof artifact added:

- `artifacts/ambitions-ui-reconstruction/final-proof/AMB-588-primitive-screenshot-and-focused-test-gate.md`

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
- `docs/codex/ambitions_primitive_invention_registry.md`
- `artifacts/ambitions-ui-reconstruction/final-proof/AMB-586-primitive-family-replacement-proof-gate.md`
- `artifacts/ambitions-ui-reconstruction/final-proof/AMB-587-no-card-final-primitive-scan.md`

## Screenshot Artifact Paths

Command:

```bash
sips -g pixelWidth -g pixelHeight <artifact>
```

Verified existing screenshot artifacts:

- `artifacts/ambitions-ui-reconstruction/screenshots/today-object-stage-amb-572.png` - 1170x2532
- `artifacts/ambitions-ui-reconstruction/screenshots/time-object-stage-amb-573.png` - 1170x2532
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-object-stage-amb-574.png` - 1170x2532
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-object-stage-amb-575.png` - 1170x2532
- `artifacts/ambitions-ui-reconstruction/screenshots/you-object-stage-amb-576.png` - 1170x2532
- `artifacts/ambitions-ui-reconstruction/screenshots/capture-object-stage-amb-577.png` - 1206x2622
- `artifacts/ambitions-ui-reconstruction/screenshots/closure-recovery-family-amb-578.png` - 1206x2622
- `artifacts/ambitions-ui-reconstruction/screenshots/quiet-reflow-family-amb-579.png` - 1206x2622
- `artifacts/ambitions-ui-reconstruction/screenshots/capture-routing-family-amb-580.png` - 1206x2622
- `artifacts/ambitions-ui-reconstruction/screenshots/horizon-capacity-family-amb-581.png` - 1206x2622
- `artifacts/ambitions-ui-reconstruction/screenshots/proof-relationship-trace-family-amb-582.png` - 1206x2622
- `artifacts/ambitions-ui-reconstruction/screenshots/canvas-engines-and-fallbacks-amb-583.png` - 1206x2622

No fresh screenshots were captured for AMB-588. This gate verifies the exact existing artifact paths and dimensions.

## Adaptive And Accessibility Proof Paths

The following paths contain the recorded Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, Differentiate Without Color, VoiceOver, or fallback-contract proof for the installed primitive families:

- `artifacts/ambitions-ui-reconstruction/primitive-install/AMB-570-accessibility-fallback-family.md`
- `artifacts/ambitions-ui-reconstruction/primitive-install/AMB-571-semantic-token-extensions.md`
- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-572-today-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-573-time-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-574-motion-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-575-goals-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-576-you-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-577-capture-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/action-state/AMB-578-closure-recovery-family.md`
- `artifacts/ambitions-ui-reconstruction/action-state/AMB-579-quiet-reflow-family.md`
- `artifacts/ambitions-ui-reconstruction/action-state/AMB-580-capture-routing-family.md`
- `artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-581-horizon-capacity-family.md`
- `artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-582-proof-relationship-trace-family.md`
- `artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-583-canvas-engines-and-fallbacks.md`
- `docs/codex/ambitions_primitive_invention_registry.md`

Evidence command:

```bash
rg -n "Dynamic Type|Reduce Motion|Reduce Transparency|Increase Contrast|Differentiate Without Color|VoiceOver|accessibility" artifacts/ambitions-ui-reconstruction docs/codex/ambitions_primitive_invention_registry.md --glob "*.md" | sed -n '1,220p'
```

Classification:

- These paths prove recorded contract/source/report coverage for adaptive and accessibility fallback behavior.
- They do not prove manual VoiceOver review, public accessibility conformance, fresh Dynamic Type screenshots, fresh Reduce Motion walkthrough, fresh Reduce Transparency screenshot review, fresh Increase Contrast screenshot review, or real-device accessibility behavior.

## Focused Tests

All matching existing primitive-family focused XCTest targets were run through the repo wrapper. Total executed tests: 76.

| Command | Status | Executed tests | Summary |
|---|---:|---:|---|
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/TrustReceiptLayerDesignSystemTests` | passed | 11 | `.codex/xcode-summaries/AMB-588/20260608T155327Z-AmbitionsTests-TrustReceiptLayerDesignSystemTests-88793-1179/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/AccessibilityAdaptiveInterfaceDesignSystemTests` | passed | 11 | `.codex/xcode-summaries/AMB-588/20260608T155631Z-AmbitionsTests-AccessibilityAdaptiveInterfaceDesignSystemTests-89299-19739/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/AppearancePreferenceTests` | passed | 6 | `.codex/xcode-summaries/AMB-588/20260608T155932Z-AmbitionsTests-AppearancePreferenceTests-89975-32247/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/GoalsObjectStagePrimitiveTests` | passed | 3 | `.codex/xcode-summaries/AMB-588/20260608T160239Z-AmbitionsTests-GoalsObjectStagePrimitiveTests-90651-14714/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/HorizonCapacityPrimitiveFamilyTests` | passed | 4 | `.codex/xcode-summaries/AMB-588/20260608T160534Z-AmbitionsTests-HorizonCapacityPrimitiveFamilyTests-91313-18136/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/ClosureRecoveryPrimitiveFamilyTests` | passed | 3 | `.codex/xcode-summaries/AMB-588/20260608T160925Z-AmbitionsTests-ClosureRecoveryPrimitiveFamilyTests-92082-13691/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/QuietReflowPrimitiveFamilyTests` | passed | 4 | `.codex/xcode-summaries/AMB-588/20260608T161124Z-AmbitionsTests-QuietReflowPrimitiveFamilyTests-92646-12686/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/CaptureRoutingPrimitiveFamilyTests` | passed | 4 | `.codex/xcode-summaries/AMB-588/20260608T161825Z-AmbitionsTests-CaptureRoutingPrimitiveFamilyTests-93694-8318/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/ProofRelationshipTracePrimitiveFamilyTests` | passed | 4 | `.codex/xcode-summaries/AMB-588/20260608T162104Z-AmbitionsTests-ProofRelationshipTracePrimitiveFamilyTests-94292-8164/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/ProductMeaningCanvasEngineTests` | passed | 4 | `.codex/xcode-summaries/AMB-588/20260608T162354Z-AmbitionsTests-ProductMeaningCanvasEngineTests-94974-2017/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/MotionCurrentScreenTests` | passed | 11 | `.codex/xcode-summaries/AMB-588/20260608T162624Z-AmbitionsTests-MotionCurrentScreenTests-95572-14158/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/CapturePlacementReviewStateTests` | passed | 6 | `.codex/xcode-summaries/AMB-588/20260608T162909Z-AmbitionsTests-CapturePlacementReviewStateTests-96178-20364/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/PersonalSystemCenterDesignSystemTests` | passed | 5 | `.codex/xcode-summaries/AMB-588/20260608T163143Z-AmbitionsTests-PersonalSystemCenterDesignSystemTests-96762-27962/focused-test-summary.json` |

Focused-test log paths:

- `.codex/xcode-logs/AMB-588/20260608T155327Z-AmbitionsTests-TrustReceiptLayerDesignSystemTests-88793-1179/focused-test.log`
- `.codex/xcode-logs/AMB-588/20260608T155631Z-AmbitionsTests-AccessibilityAdaptiveInterfaceDesignSystemTests-89299-19739/focused-test.log`
- `.codex/xcode-logs/AMB-588/20260608T155932Z-AmbitionsTests-AppearancePreferenceTests-89975-32247/focused-test.log`
- `.codex/xcode-logs/AMB-588/20260608T160239Z-AmbitionsTests-GoalsObjectStagePrimitiveTests-90651-14714/focused-test.log`
- `.codex/xcode-logs/AMB-588/20260608T160534Z-AmbitionsTests-HorizonCapacityPrimitiveFamilyTests-91313-18136/focused-test.log`
- `.codex/xcode-logs/AMB-588/20260608T160925Z-AmbitionsTests-ClosureRecoveryPrimitiveFamilyTests-92082-13691/focused-test.log`
- `.codex/xcode-logs/AMB-588/20260608T161124Z-AmbitionsTests-QuietReflowPrimitiveFamilyTests-92646-12686/focused-test.log`
- `.codex/xcode-logs/AMB-588/20260608T161825Z-AmbitionsTests-CaptureRoutingPrimitiveFamilyTests-93694-8318/focused-test.log`
- `.codex/xcode-logs/AMB-588/20260608T162104Z-AmbitionsTests-ProofRelationshipTracePrimitiveFamilyTests-94292-8164/focused-test.log`
- `.codex/xcode-logs/AMB-588/20260608T162354Z-AmbitionsTests-ProductMeaningCanvasEngineTests-94974-2017/focused-test.log`
- `.codex/xcode-logs/AMB-588/20260608T162624Z-AmbitionsTests-MotionCurrentScreenTests-95572-14158/focused-test.log`
- `.codex/xcode-logs/AMB-588/20260608T162909Z-AmbitionsTests-CapturePlacementReviewStateTests-96178-20364/focused-test.log`
- `.codex/xcode-logs/AMB-588/20260608T163143Z-AmbitionsTests-PersonalSystemCenterDesignSystemTests-96762-27962/focused-test.log`

## Inherited Yellow Debt

AMB-587 recorded that `python3 scripts/ios26-anti-card-check.py --surface global --batch AMB-587 --markdown` returned structural Red with 127 red findings. AMB-588 does not reclassify or remediate that debt.

Remaining owner:

- AMB-607 - classify and replace active card/container structures.

## Validation

- `sips -g pixelWidth -g pixelHeight <artifact>` - completed for the 12 screenshot artifacts listed above.
- `rg -n "Dynamic Type|Reduce Motion|Reduce Transparency|Increase Contrast|Differentiate Without Color|VoiceOver|accessibility" artifacts/ambitions-ui-reconstruction docs/codex/ambitions_primitive_invention_registry.md --glob "*.md" | sed -n '1,220p'` - completed; proof paths listed above.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/TrustReceiptLayerDesignSystemTests` - passed; 11 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/AccessibilityAdaptiveInterfaceDesignSystemTests` - passed; 11 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/AppearancePreferenceTests` - passed; 6 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/GoalsObjectStagePrimitiveTests` - passed; 3 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/HorizonCapacityPrimitiveFamilyTests` - passed; 4 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/ClosureRecoveryPrimitiveFamilyTests` - passed; 3 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/QuietReflowPrimitiveFamilyTests` - passed; 4 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/CaptureRoutingPrimitiveFamilyTests` - passed; 4 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/ProofRelationshipTracePrimitiveFamilyTests` - passed; 4 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/ProductMeaningCanvasEngineTests` - passed; 4 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/MotionCurrentScreenTests` - passed; 11 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/CapturePlacementReviewStateTests` - passed; 6 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/PersonalSystemCenterDesignSystemTests` - passed; 5 executed tests.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-588 --prompt docs/codex/ambitions_primitive_invention_registry.md --changed-from a9e19e2618ff937485e69cdb94e0a6009922a437 --batch-type audit-only --changed-path artifacts/ambitions-ui-reconstruction/final-proof/AMB-588-primitive-screenshot-and-focused-test-gate.md` - Green; report `build/reports/parallel-implementation-guard/AMB-588-post.md`.
- `python3 scripts/ambitions-unsupported-claim-scan.py artifacts/ambitions-ui-reconstruction/final-proof/AMB-588-primitive-screenshot-and-focused-test-gate.md` - Green.
- `bash scripts/codex-forbidden-claim-scan.sh artifacts/ambitions-ui-reconstruction/final-proof/AMB-588-primitive-screenshot-and-focused-test-gate.md` - no blocking hits.
- `git diff --check` - passed.
- `bash scripts/release-claim-safety-scan.sh` - Green after staging the AMB-588 report.

## Proof Boundaries

- This report proves only existing screenshot artifact presence/dimensions, recorded adaptive/accessibility proof paths, and focused-test results for matching existing XCTest targets.
- It does not claim fresh app build beyond focused-test wrapper validation, fresh screenshot capture, human visual approval, public accessibility conformance, manual VoiceOver behavior, Dynamic Type visual review, Reduce Motion walkthrough, Reduce Transparency visual review, Increase Contrast visual review, performance readiness, real-device behavior, privacy/legal approval, TestFlight readiness, App Store readiness, or release readiness.
- It does not claim AMB-607 no-card debt is resolved.

## Rollback

- Remove this AMB-588 proof report if the gate needs rollback.
- No app source rollback is needed because AMB-588 changed no app source.

## Required Completion Footer

Verdict: Yellow
Artifact paths:
- artifacts/ambitions-ui-reconstruction/final-proof/AMB-588-primitive-screenshot-and-focused-test-gate.md
Focused tests:
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/TrustReceiptLayerDesignSystemTests` - passed; 11 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/AccessibilityAdaptiveInterfaceDesignSystemTests` - passed; 11 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/AppearancePreferenceTests` - passed; 6 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/GoalsObjectStagePrimitiveTests` - passed; 3 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/HorizonCapacityPrimitiveFamilyTests` - passed; 4 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/ClosureRecoveryPrimitiveFamilyTests` - passed; 3 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/QuietReflowPrimitiveFamilyTests` - passed; 4 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/CaptureRoutingPrimitiveFamilyTests` - passed; 4 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/ProofRelationshipTracePrimitiveFamilyTests` - passed; 4 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/ProductMeaningCanvasEngineTests` - passed; 4 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/MotionCurrentScreenTests` - passed; 11 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/CapturePlacementReviewStateTests` - passed; 6 executed tests.
- `make xcode-focused-test BATCH=AMB-588 TEST=AmbitionsTests/PersonalSystemCenterDesignSystemTests` - passed; 5 executed tests.
Changed files:
- none (runtime/source); required report artifact added only.
Remaining Yellow debt:
- AMB-607
