# AMB-585 Primitive Registry Completeness Gate

Verdict: Green

AMB-585 verified the primitive invention registry against the installed primitive work from AMB-569 through AMB-583. The gate found two registry metadata gaps and repaired them with docs-only changes:

- `source-trust-strip` was installed by AMB-569 but still listed as `Proposed`; it is now listed as `Promoted` with AMB-569 as the promotion issue and AMB-607 retained as broader replacement debt.
- `accessibility-fallback-contract` was installed by AMB-570 but still listed as `Proposed`; it is now listed as `Promoted`.
- The AMB-571 semantic token extension table now carries explicit proof and rollback coverage.

No app source, app tests, project files, package files, runtime behavior, screenshots, visual baselines, privacy manifests, entitlements, or user data were changed.

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
- Installed primitive proof reports and screenshots under `artifacts/ambitions-ui-reconstruction/`

## Installed Primitive Registry Map

| Installed primitive | Registry entry | Promotion issue | Replacement proof | Accessibility behavior | Rollback |
|---|---|---|---|---|---|
| `SourceTrustReceiptStrip` | `source-trust-strip` | AMB-569 | `AMB-569-source-trust-receipt-family.md` records replacement of the Today Start Here source/freshness/receipt chip row with `SourceTrustReceiptStrip`; existing touched-surface screenshots are referenced in that report. | Registry section records VoiceOver source/freshness/receipt action order, Dynamic Type wrapping, no motion-only meaning, and Differentiate Without Color labels. | Registry section and AMB-569 report record reverting `TrustReceiptLayerPrimitives.swift`, Today usage, AMB-569 tests, concept-lock allowance, and report artifact. |
| `AmbitionsPrimitiveAccessibilityFallbackProfile` / `AmbitionsPrimitiveAccessibilityFallbackModifier` | `accessibility-fallback-contract` | AMB-570 | `AMB-570-accessibility-fallback-family.md` records the shared fallback contract and modifier install; no screenshot is claimed because this is not a rendered surface. | Registry section records Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, and Differentiate Without Color fallback behavior. | Registry section and AMB-570 report record removing fallback profile/modifier source, AMB-570 tests, registry entry, and concept-lock allowance. |
| Primitive semantic token extensions | `Primitive Semantic Token Extensions` table | AMB-571 | Registry token table maps six token IDs to `SourceTrustReceiptStrip` and `AmbitionsPrimitiveAccessibilityFallbackModifier`; `AMB-571-semantic-token-extensions.md` records proof. | Token table records behavior and contrast implications; added registry proof/rollback notes preserve non-color-only meaning. | Registry section and AMB-571 report record removing token inventory, restoring local color mappings, removing focused tests, and removing the concept-lock allowance. |
| `TodayObjectStagePrimitiveContract` / Today object-stage usage | `today-object-stage` | AMB-572 | Registry entry and `AMB-572-today-object-stage.md` record replacement of Today first-viewport panel, tile, chip, and source-strip chrome; screenshot `today-object-stage-amb-572.png`. | Registry section records VoiceOver order, Dynamic Type stacking, Reduce Motion static relation, Increase Contrast, and Differentiate Without Color behavior. | Registry section records reverting AMB-572 source/report/screenshot to restore prior Today treatment. |
| `TimeObjectStagePrimitiveContract` / Time object-stage usage | `time-object-stage` | AMB-573 | Registry entry and `AMB-573-time-object-stage.md` record replacement of Time horizon chips, rounded LifeShape canvas panel, capacity panel, source/receipt pills, continuity pills, reflow panel chrome, and unreachable stale helpers; screenshot `time-object-stage-amb-573.png`. | Registry section records VoiceOver order, Dynamic Type stacking, Reduce Motion static pressure texture, Increase Contrast, and Differentiate Without Color behavior. | Registry section records reverting AMB-573 source/report/screenshot to restore prior Time treatment. |
| `MotionObjectStagePrimitiveContract` / Motion object-stage usage | `motion-object-stage` | AMB-574 | Registry entry and `AMB-574-motion-object-stage.md` record replacement of Motion Current field panel, lane cards, state-row panels, trace pills, and source/proof/receipt panel chrome; screenshot `motion-object-stage-amb-574.png`. | Registry section records VoiceOver order, Dynamic Type preservation, Reduce Motion static proof-thread marks, Increase Contrast, and Differentiate Without Color behavior. | Registry section records reverting AMB-574 source/report/screenshot to restore prior Motion treatment. |
| `GoalsObjectStagePrimitiveContract` / Goals object-stage usage | `goals-object-stage` | AMB-575 | Registry entry and `AMB-575-goals-object-stage.md` record replacement of Goals equal-weight area band, Atlas container, relationship field shell, Orbital Lens container, lane blocks, and source/proof/trust chrome; screenshot `goals-object-stage-amb-575.png`. | Registry section records VoiceOver order, Dynamic Type preservation, Reduce Motion static Atlas field, Increase Contrast, and Differentiate Without Color behavior. | Registry section records reverting AMB-575 source/report/screenshot to restore prior Goals treatment. |
| `YouObjectStageControlPrimitiveContract` / You object-stage control group | `personal-runtime-group` | AMB-576 | Registry entry and `AMB-576-you-object-stage.md` record replacement of detached You profile hero, generic settings wall, operator-style root overview, rounded per-row card stack, and stale unreachable generic containers; screenshot `you-object-stage-amb-576.png`. | Registry section records VoiceOver grouped order, Dynamic Type row stacking, Reduce Motion native disclosure state, Increase Contrast, and Differentiate Without Color behavior. | Registry section records reverting AMB-576 source/report/screenshot to restore prior You treatment. |
| `CaptureObjectStagePrimitiveContract` / `CaptureStageGroup` | `capture-route-ribbon` | AMB-577 | Registry entry and `AMB-577-capture-object-stage.md` record replacement of Capture route cards, composer panels, category buckets, first-run card shell, and draft-route containers; screenshot `capture-object-stage-amb-577.png`. | Registry section records VoiceOver route/review/save order, Dynamic Type route stacking, Reduce Motion static reveal, Increase Contrast, Differentiate Without Color, and keyboard path behavior. | Registry section records reverting AMB-577 source/report/screenshot to restore prior Capture treatment. |
| `ClosureRecoveryPrimitiveFamily` | `closure-recovery-family` | AMB-578 | Registry entry and `AMB-578-closure-recovery-family.md` record replacement of closure panels, recovery panels, rounded recovery cards, closure outcome cards, receipt preview cards, closure tray chrome, and related generic recovery wrappers; screenshot `closure-recovery-family-amb-578.png`. | Registry section records VoiceOver closure/recovery/receipt order, Dynamic Type line stacking, Reduce Motion static labels/symbols, Increase Contrast, and Differentiate Without Color behavior. | Registry section records reverting AMB-578 source/report/screenshot to restore prior closure/recovery treatment. |
| `QuietReflowPrimitiveFamily` | `quiet-reflow-family` | AMB-579 | Registry entry and `AMB-579-quiet-reflow-family.md` record replacement of Time reflow panels, reflow option cards, before/after preview cards, Today replacement cards, impact preview cards, and receipt preview cards; screenshot `quiet-reflow-family-amb-579.png`. | Registry section records VoiceOver preview/source/control/receipt order, Dynamic Type stacking, Reduce Motion static before/after labels, Increase Contrast, and Differentiate Without Color behavior. | Registry section records reverting AMB-579 source/report/screenshot to restore prior Quiet Reflow treatment. |
| `CaptureRoutingPrimitiveFamily` | `capture-routing-family` | AMB-580 | Registry entry and `AMB-580-capture-routing-family.md` record replacement of Capture routing panels, route category grids, route proof pills, route option cards, certainty labels, and chat-like shells; screenshot `capture-routing-family-amb-580.png`. | Registry section records VoiceOver route basis/correction/receipt order, Dynamic Type line stacking, Reduce Motion static route labels, Increase Contrast, and Differentiate Without Color behavior. | Registry section records reverting AMB-580 source/report/screenshot to restore prior Capture routing treatment. |
| `HorizonCapacityPrimitiveFamily` | `horizon-capacity-family` | AMB-581 | Registry entry and `AMB-581-horizon-capacity-family.md` record replacement of Time horizon chips, capacity statement panel, source/receipt pills, continuity pills, and active Time relationship chrome; screenshot `horizon-capacity-family-amb-581.png`. | Registry section records VoiceOver selected horizon/capacity/source/receipt order, Dynamic Type line stacking, Reduce Motion static horizon labels, Increase Contrast, and Differentiate Without Color behavior. | Registry section records reverting AMB-581 source/report/screenshot to restore prior Horizon/Capacity treatment. |
| `ProofRelationshipTracePrimitiveFamily` | `proof-relationship-trace-family` | AMB-582 | Registry entry and `AMB-582-proof-relationship-trace-family.md` record replacement of Motion trace chips, Motion source/proof/receipt rows, Goals review-trail cards, and Goals receipt cards; screenshot `proof-relationship-trace-family-amb-582.png`. | Registry section records VoiceOver source/relationship/proof/receipt/replay/user-inspection order, Dynamic Type line stacking, Reduce Motion static symbols/labels, Increase Contrast, and Differentiate Without Color behavior. | Registry section records reverting AMB-582 source/report/screenshot to restore prior proof/trace treatment. |
| `ProductMeaningCanvasEngine` | `canvas-engines-static-fallbacks` | AMB-583 | Registry entry and `AMB-583-canvas-engines-and-fallbacks.md` record replacement of Goals, Time, and Motion inline Canvas contours with the shared engine; screenshot `canvas-engines-and-fallbacks-amb-583.png`. | Registry section records Reduce Motion deterministic Shape fallbacks, Increase Contrast stronger strokes, Reduce Transparency calmer opacity, and accessibility-hidden Canvas semantics backed by adjacent object text. | Registry section records reverting AMB-583 source/report/screenshot to restore prior inline Canvas contours. |

## Proposed Rows Excluded From Installed Inventory

These registry rows remain proposed and are not treated as installed AMB-585 primitives:

- `surface-object-frame`
- `proof-receipt-lane`
- `life-shape-control-band`
- `motion-current-thread`

They remain seeded governance rows for later promotion work, primarily AMB-607, and are not AMB-585 Red blockers because no installed source owner was found for them in the AMB-569 through AMB-583 primitive-install sequence.

## Focused Tests

Focused tests are `not available` for this read-only registry completeness gate. Existing primitive-specific tests exist for several individual primitive families, but AMB-585 does not install source behavior and there is no directly relevant existing registry-completeness XCTest target. Creating a broad new test harness would violate the AMB-585 testing rule.

Evidence command:

```bash
rg --files Native/AmbitionsTests | rg -i 'primitive|registry|invention|source.*trust|accessibility.*fallback|canvas|objectstage|relationship|horizon|reflow|capture.*routing'
```

Result:

- Found individual primitive-family tests, including `HorizonCapacityPrimitiveFamilyTests`, `GoalsObjectStagePrimitiveTests`, `ProofRelationshipTracePrimitiveFamilyTests`, `CaptureRoutingPrimitiveFamilyTests`, `ProductMeaningCanvasEngineTests`, `QuietReflowPrimitiveFamilyTests`, and `ClosureRecoveryPrimitiveFamilyTests`.
- Found no directly relevant registry-completeness test target.

## Validation

- `rg -n "^\\| .* \\| Promoted \\||^### |^Proof artifact:|^Rollback:|^Semantic token extension proof|^Semantic token extension rollback|^## Primitive Semantic Token Extensions" docs/codex/ambitions_primitive_invention_registry.md` - passed; promoted table rows and detailed proof/rollback sections are present.
- `rg --files artifacts/ambitions-ui-reconstruction | rg 'AMB-5(69|70|71|72|73|74|75|76|77|78|79|80|81|82|83)'` - passed; prior proof artifacts exist for each installed primitive issue AMB-569 through AMB-583.
- `rg --files Native/AmbitionsTests | rg -i 'primitive|registry|invention|source.*trust|accessibility.*fallback|canvas|objectstage|relationship|horizon|reflow|capture.*routing'` - completed; no directly relevant registry-completeness focused XCTest target exists.
- `rg -n "SourceTrustReceiptStrip|AmbitionsPrimitiveAccessibilityFallback|TodayObjectStagePrimitiveContract|TimeObjectStagePrimitiveContract|MotionObjectStagePrimitiveContract|GoalsObjectStagePrimitiveContract|YouObjectStageControlPrimitiveContract|CaptureObjectStagePrimitiveContract|ClosureRecoveryPrimitiveFamilyContract|QuietReflowPrimitiveFamilyContract|CaptureRoutingPrimitiveFamilyContract|HorizonCapacityPrimitiveFamilyContract|ProofRelationshipTracePrimitiveFamilyContract|ProductMeaningCanvasEngineContract|AmbitionPrimitiveSemanticToken" Sources Native/Ambitions docs/codex/ambitions_primitive_invention_registry.md` - passed; installed source primitive and token owners are present in source and mapped in registry/report evidence.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-585 --prompt docs/codex/ambitions_primitive_invention_registry.md --changed-from 59e3af9e0efb1859baf72a738e31fb9f6479d545 --batch-type audit-only --changed-path docs/codex/ambitions_primitive_invention_registry.md --changed-path artifacts/ambitions-ui-reconstruction/final-proof/AMB-585-primitive-registry-completeness-gate.md` - Green; report `build/reports/parallel-implementation-guard/AMB-585-post.md`.
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/codex/ambitions_primitive_invention_registry.md artifacts/ambitions-ui-reconstruction/final-proof/AMB-585-primitive-registry-completeness-gate.md` - Green.
- `bash scripts/codex-forbidden-claim-scan.sh docs/codex/ambitions_primitive_invention_registry.md artifacts/ambitions-ui-reconstruction/final-proof/AMB-585-primitive-registry-completeness-gate.md` - no blocking hits.
- `bash scripts/release-claim-safety-scan.sh` - Green.
- `git diff --check` - passed.

## Proof Boundaries

- This is registry completeness proof and docs-only metadata repair.
- This does not prove a fresh app build, fresh individual primitive tests, fresh screenshots, manual visual approval, public accessibility conformance, performance readiness, physical-device behavior, privacy/legal approval, TestFlight readiness, App Store readiness, or release readiness.
- Prior screenshots and focused tests are mapped as prior primitive-install proof artifacts only; AMB-585 did not create new screenshot or source validation proof.

## Changed Files

- `docs/codex/ambitions_primitive_invention_registry.md`
- `artifacts/ambitions-ui-reconstruction/final-proof/AMB-585-primitive-registry-completeness-gate.md`

## Rollback

- Revert the AMB-585 commit to remove this final-proof report and restore the prior registry metadata for `source-trust-strip`, `accessibility-fallback-contract`, and AMB-571 semantic token extension proof/rollback notes.
- No app source rollback is needed because AMB-585 made no app source changes.

## Required Completion Footer

Verdict: Green
Artifact paths:
- artifacts/ambitions-ui-reconstruction/final-proof/AMB-585-primitive-registry-completeness-gate.md
Focused tests:
- `not available` - AMB-585 is a read-only registry completeness gate with no directly relevant existing registry-completeness XCTest target; creating a broad harness would violate the testing rule.
Changed files:
- docs/codex/ambitions_primitive_invention_registry.md
- artifacts/ambitions-ui-reconstruction/final-proof/AMB-585-primitive-registry-completeness-gate.md
Remaining Yellow debt:
- None for AMB-585 registry completeness.
- AMB-607 remains broader source-row replacement debt recorded by `source-trust-strip`; it is not missing registry coverage.
