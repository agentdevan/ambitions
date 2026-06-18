# Design Truth Refraction Audit

Status: Yellow
Branch: `main`
Commit: `8d095586156ba72bd4e960ed69c14db511af4aa9`
Scope: Train 0/1 only: canon readback, file inventory, classification, and audit artifacts. No product UI rebuild, file deletion, aesthetic replacement, Train 2 guard implementation, screenshot proof, accessibility proof, mutation proof, privacy proof, or release proof is claimed.

## Inventory Summary

- Git-tracked files classified: 2307
- Swift files classified: 836
- Markdown files classified: 474
- Status counts: Delete=5, Green=1678, Red=122, Split=114, Test-only=262, Yellow=126
- Raw search logs over 25 MB are replaced with hit counts, samples, command lines, and top file summaries.

## Top 20 Red Files

| File | Lines | Classification | Primary issue | Status |
| --- | --- | --- | --- | --- |
| Native/AmbitionsUITests/AmbitionsUITests.swift | 2435 | test-only | none | Red |
| docs/truth/PRODUCT_DESIGN_TRUTH.md | 3462 | obsolete architecture | none | Red |
| Native/Ambitions/Domain/ActionClosureReceiptModels.swift | 2421 | needs hardening | none | Red |
| Native/Ambitions/Domain/SourceAtlasPackModels.swift | 3030 | oversized | none | Red |
| Native/Ambitions/Features/Goals/GoalComponents.swift | 2427 | oversized | none | Red |
| Native/Ambitions/Features/Goals/GoalsFeatureModels.swift | 2276 | oversized | none | Red |
| Native/Ambitions/Features/Goals/GoalsFeatureService.swift | 4562 | stub | none | Red |
| Native/Ambitions/Features/Time/TimeFeatureService.swift | 2450 | oversized | none | Red |
| Native/Ambitions/Features/Today/TodayFeatureService.swift | 2495 | stub | none | Red |
| Native/Ambitions/Features/You/YouFeatureService.swift | 6181 | stub | none | Red |
| Native/Ambitions/Features/You/YouScreen.swift | 3515 | preview-only | none | Red |
| Native/Ambitions/Persistence/SwiftDataRepositories.swift | 3002 | needs hardening | none | Red |
| Native/AmbitionsTests/You/YouFeatureServiceTests.swift | 2485 | test-only | none | Red |
| Native/Ambitions/Features/Time/TimeScreen.swift | 1992 | preview-only | none | Red |
| Native/Ambitions/App/AppShellView.swift | 1944 | oversized | none | Red |
| Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift | 1836 | oversized | none | Red |
| Native/Ambitions/Domain/LifeContextModels.swift | 1805 | oversized | none | Red |
| Native/Ambitions/Features/Today/TodayPanels.swift | 1797 | oversized | none | Red |
| Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift | 1753 | test-only | none | Red |
| Native/Ambitions/Domain/RecommendationExplanationModels.swift | 1737 | oversized | none | Red |

## Top 20 Files To Split

| File | Lines | Current responsibility | Recommendation | Status |
| --- | --- | --- | --- | --- |
| Native/Ambitions/Features/You/YouFeatureService.swift | 6181 | Surface file owned by You. | replace | Red |
| Native/Ambitions/Features/Goals/GoalsFeatureService.swift | 4562 | Surface file owned by Goals. | replace | Red |
| Native/Ambitions/Features/You/YouScreen.swift | 3515 | Surface file owned by You. | split | Red |
| Native/Ambitions/Domain/SourceAtlasPackModels.swift | 3030 | Core Domain file owned by Source Atlas / R2. | split | Red |
| Native/Ambitions/Persistence/SwiftDataRepositories.swift | 3002 | Persistence file owned by Broad repo. | split | Red |
| Native/Ambitions/Features/Today/TodayFeatureService.swift | 2495 | Surface file owned by Today. | replace | Red |
| Native/AmbitionsTests/You/YouFeatureServiceTests.swift | 2485 | Tests for You / YouFeatureServiceTests.swift. | split | Red |
| Native/Ambitions/Features/Time/TimeFeatureService.swift | 2450 | Surface file owned by Time. | split | Red |
| Native/AmbitionsUITests/AmbitionsUITests.swift | 2435 | Tests for Broad repo / AmbitionsUITests.swift. | split | Red |
| Native/Ambitions/Features/Goals/GoalComponents.swift | 2427 | Surface file owned by Goals. | split | Red |
| Native/Ambitions/Domain/ActionClosureReceiptModels.swift | 2421 | Core Domain file owned by Trust / release proof. | split | Red |
| Native/Ambitions/Features/Goals/GoalsFeatureModels.swift | 2276 | Surface file owned by Goals. | split | Red |
| Native/Ambitions/Features/Time/TimeScreen.swift | 1992 | Surface file owned by Time. | split | Red |
| Native/Ambitions/App/AppShellView.swift | 1944 | App file owned by Stage shell. | split | Red |
| Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift | 1836 | Core Domain file owned by Goals. | split | Red |
| Native/Ambitions/Domain/LifeContextModels.swift | 1805 | Core Domain file owned by Broad repo. | split | Red |
| Native/Ambitions/Features/Today/TodayPanels.swift | 1797 | Surface file owned by Today. | split | Red |
| Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift | 1753 | Tests for Broad repo / StepCandidateFieldGeneratorTests.swift. | split | Red |
| Native/Ambitions/Domain/RecommendationExplanationModels.swift | 1737 | Core Domain file owned by Broad repo. | split | Red |
| Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift | 1588 | Tests for Time / TimeFeatureServiceTests.swift. | split | Red |

## Top 20 Stubs/Adapters To Retire Or Harden

| File | Classification | Recommendation | Status |
| --- | --- | --- | --- |
| Native/Ambitions/Domain/ActionClosureReceiptModels.swift | needs hardening | split | Red |
| Native/Ambitions/Features/Goals/GoalsFeatureService.swift | stub | replace | Red |
| Native/Ambitions/Features/Today/TodayFeatureService.swift | stub | replace | Red |
| Native/Ambitions/Features/You/YouFeatureService.swift | stub | replace | Red |
| Native/Ambitions/Persistence/SwiftDataRepositories.swift | needs hardening | split | Red |
| scripts/ambitions-codex-train.sh | needs hardening | harden | Yellow |
| docs/audits/file_by_file_truth_ledger.md | stub | replace | Yellow |
| artifacts/ambitions-master-build/validation/AMB-1058/focused-root-shell-tests.log | stub | replace | Yellow |
| artifacts/ambitions-master-build/validation/AMB-1061-focused-component-tests.log | stub | replace | Yellow |
| docs/codex/existing-code-champion-coverage.yml | stub | replace | Yellow |
| Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift | stub | replace | Red |
| tools/source-atlas/coverage.py | stub | replace | Yellow |
| Sources/Accessibility/AccessibilityNutrition.swift | needs hardening | split | Red |
| Native/Ambitions/Services/AmbitionsCommandExecutor.swift | needs hardening | split | Red |
| Native/Ambitions/Services/ReviewsV1Projector.swift | needs hardening | split | Red |
| Native/Ambitions/Domain/ScreenContractModels.swift | needs hardening | split | Red |
| Native/Ambitions/Runtime/AnyGoalRuntimeCoverage.swift | needs hardening | split | Red |
| Native/Ambitions/Features/Time/TimeFeatureModels.swift | needs hardening | split | Red |
| Native/Ambitions/Domain/SafeAutomationPolicyModels.swift | needs hardening | split | Red |
| docs/audits/intelligence-consolidation/EXISTING_CODE_CHAMPION_COVERAGE.md | stub | replace | Yellow |

## Obsolete Motion/Capture/Root-Tab Architecture Found

| File | Classification | Finding | Status |
| --- | --- | --- | --- |
| docs/truth/PRODUCT_DESIGN_TRUTH.md | obsolete architecture | none | Red |
| docs/truth/PRODUCT_DESIGN_TRUTH.format-backup-20260616T220228.md | obsolete canon | Format backup is obsolete supporting canon and must not override active truth. | Delete |
| Native/Ambitions/Features/Motion/MotionCurrentScreen.swift | obsolete architecture | Motion feature file remains outside Stage/Motion behavior ownership. | Red |
| docs/truth/HISTORICAL_POLICY.md | obsolete canon | Historical policy says active IA includes Motion; PRODUCT_DESIGN_TRUTH wins with Today / Goals / Time / You. | Delete |
| Native/Ambitions/Features/Capture/CaptureScreen.swift | preview-only | CaptureScreen still exposes topLevelCapture shell mode for compatibility/previews. | Red |
| Native/Ambitions/App/ShellCommandModels.swift | oversized | Motion-named shell command source remains as compatibility vocabulary for audit review. | Red |
| Native/Ambitions/App/AmbitionsRootView.swift | needs split | Root shell still uses technical TabView; native tab chrome is hidden but StageRoot guard is not yet formalized. | Red |
| Native/Ambitions/App/AppNavigation.swift | needs split | Capture inbox compatibility route remains and must be validated as overlay/global composer, not root destination. | Red |
| Native/Ambitions/Features/Motion/MotionCurrentAction.swift | obsolete architecture | Motion feature file remains outside Stage/Motion behavior ownership. | Red |
| docs/audits/obsolete_architecture_audit.md | obsolete architecture | none | Red |
| scripts/ambitions-historical-baseline-train-guard.py | obsolete canon | none | Delete |
| scripts/governance/ambitions-historical-registry-extract.py | obsolete canon | none | Delete |
| PURGE_HISTORICAL_MANIFEST_20260616T230124.txt | obsolete canon | none | Delete |

## Recommended P0 Implementation Train Order

- Train 2: Add enforcement gates for root architecture, shell chrome, forbidden language, copy policy, and scenario matrix baseline.
- Train 3: Harden root stage/shell routing, capture overlay policy, drilldown dock policy, and Motion/Capture non-root guards.
- Train 4: Establish semantic material/chrome policy before touching more product views.
- Train 5-10: Refactor Today, Closure, Capture, Goals, Time, and You only after guards exist.
- Train 11-13: Migrate Motion behavior, trust/inspection, large-file splits, and remaining stub/adapter hardening.

## Validation Run By Generator

- `git ls-files` inventory for all tracked files.
- `wc -l` line counts for all tracked files.
- Targeted architecture scan: `obsolete architecture` with 257 hits in 63 files.
- Targeted stub/adapter scan: `stub and adapter` with 2206 hits in 455 files.
- Targeted forbidden-language scan: `forbidden language` with 544 hits in 149 files.

## Validation Not Run / Not Claimed In This Artifact

- Xcode build/test success is not claimed by this generated artifact.
- Screenshot matrix was not run.
- VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, and real-device accessibility proof were not run.
- Mutation proof was not run.
- Large-file splits were not performed.
- Stub retirement was not performed.
- Release, TestFlight, App Store, privacy/legal, account, R2, and device readiness are not claimed.
