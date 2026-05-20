# AMB-FILE-BY-FILE-REPO-AUDIT-01

## 1. Executive Verdict
Status: Yellow

This is a complete audit artifact set for the tracked-file manifest. The repo contains a mixture of active implementation, supporting canon, historical archives, generated artifacts, and stale/compatibility-risk surfaces. The current active canon remains the truth docs, and the biggest audit risk is truth drift between active canon, historical material, and release/proof wording.

## 2. Current Branch/SHA/Status
- Branch: `main`
- SHA: `e27664ed0332146ed66ba3e53b8c6bc3a9c7f6c5`
- Worktree status: ?? build/audits/
?? build/reports/amb-file-by-file-audit-summary.json
?? docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-cleanup-plan.md
?? docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-reds.md
?? docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-truth-drift.md
?? docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-ui-sprawl.md
?? docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-yellows.md
?? docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01.csv
?? docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01.md
- Tracked files audited: 5189

## 3. File Counts by Top-Level Folder

| Value | Count |
| --- | ---: |
| Canon docs | 2362 |
| Codex governance | 742 |
| Native app | 605 |
| Audit/report artifact | 454 |
| Unknown | 427 |
| Scripts | 418 |
| Design system package | 75 |
| Status docs | 44 |
| Generated/build artifact | 13 |
| Project config | 13 |
| Widget UI package | 10 |
| Agent skill | 8 |
| Tests | 8 |
| Truth docs | 8 |
| External/historical | 2 |

## 4. File Counts by Authority Class

| Value | Count |
| --- | ---: |
| supporting_doc | 2409 |
| active_codex_process_truth | 749 |
| active_implementation_truth | 690 |
| generated_report | 467 |
| prompt_only | 417 |
| live_script | 369 |
| unknown | 60 |
| live_project_config | 11 |
| active_source_truth | 8 |
| live_test | 7 |
| historical_doc | 2 |

## 5. File Counts by Implementation Class

| Value | Count |
| --- | ---: |
| docs_only | 2155 |
| validation_tool | 1117 |
| historical_only | 678 |
| generated_only | 467 |
| source_present | 427 |
| test_source | 243 |
| unknown | 61 |
| preview_backed | 28 |
| configured | 13 |

## 6. File Counts by Green/Yellow/Red

| Value | Count |
| --- | ---: |
| Yellow | 3635 |
| Green | 1525 |
| Red | 29 |

## 7. Top 25 Red Files
| Risk | Path | Top level | Action | Reason |
| --- | --- | --- | --- | --- |
| Red | `docs/status/current-implementation-map.md` | Status docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `docs/status/performance-budgets.md` | Status docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `docs/status/release-evidence-packet.md` | Status docs | repair or demote | File references forbidden architecture or dependency language in an active surface. |
| Red | `docs/status/repo-authority-cleanup-baseline.md` | Status docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `docs/status/repo-cleanup-index.md` | Status docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `docs/status/repo-wide-cleanup-report.md` | Status docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `docs/status/yellow-to-green-reconciliation-plan.md` | Status docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `docs/truth/CODEX_PROCESS_TRUTH.md` | Truth docs | repair or demote | File references forbidden architecture or dependency language in an active surface. |
| Red | `docs/truth/HISTORICAL_POLICY.md` | Truth docs | repair or demote | File references forbidden architecture or dependency language in an active surface. |
| Red | `docs/truth/IMPLEMENTATION_TRUTH.md` | Truth docs | repair or demote | File references forbidden architecture or dependency language in an active surface. |
| Red | `docs/truth/PRODUCT_DESIGN_TRUTH.md` | Truth docs | repair or demote | Active truth file contains legacy IA wording that conflicts with current top-level IA. |
| Red | `docs/truth/PRODUCT_MOAT_TRUTH.md` | Truth docs | repair or demote | Active truth file contains legacy IA wording that conflicts with current top-level IA. |
| Red | `docs/truth/PRODUCT_UPGRADES_VISION.md` | Truth docs | repair or demote | File references forbidden architecture or dependency language in an active surface. |
| Red | `docs/truth/RELEASE_TRUTH.md` | Truth docs | repair or demote | File references forbidden architecture or dependency language in an active surface. |
| Red | `frontend/visual-encyclopedia/FLAGSHIP_OBJECT_SYSTEM_DOCTRINE.md` | Canon docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `frontend/visual-encyclopedia/MATURE_APP_SURFACE_UNIVERSE.yaml` | Canon docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `frontend/visual-encyclopedia/OBJECT_GRAPH_ARCHITECTURE.md` | Canon docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `frontend/visual-encyclopedia/VISUAL_SOURCE_LINKS.yaml` | Canon docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `frontend/visual-encyclopedia/VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.yaml` | Canon docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `frontend/visual-encyclopedia/contracts/VOICEOVER_ORDER_CONTRACT.md` | Canon docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `frontend/visual-encyclopedia/recipes/time/month_detail.md` | Canon docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `frontend/visual-encyclopedia/recipes/time/review_pressure_surface.md` | Canon docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `frontend/visual-encyclopedia/recipes/time/shape_month_flow.md` | Canon docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `frontend/visual-encyclopedia/recipes/time/time_stale_source_state.md` | Canon docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |
| Red | `frontend/visual-encyclopedia/recipes/today/local_runtime_source_detail_from_today.md` | Canon docs | repair or demote | File makes a release-style claim that is not proven by current evidence. |

## 8. Top 50 Yellow Files
| Risk | Path | Top level | Action | Reason |
| --- | --- | --- | --- | --- |
| Yellow | `.agents/skills/ambitions-release-proof-honesty/SKILL.md` | Agent skill | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/DEPARTMENT_REGISTRY.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/GLOBAL_BATCH_TRAIN.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/OPERATING_SYSTEM.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/PR_PROTOCOL.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/REPO_INVENTORY.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/REVIEW_BOARD.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/SESSION_BOOTSTRAP.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/SKILL_GOVERNANCE.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/TOOLING_AND_VALIDATION.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/VALIDATION_HARNESS.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/evals/prompts/03-ios-extension-builder.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/evals/prompts/06-ios-qa-regression-checker.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/evals/prompts/07-design-system-guard.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/evals/prompts/13-environment-blocked-validation.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/evals/prompts/21-weak-validation-refinement.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/evals/prompts/22-release-miss-refinement.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/evals/skill-eval-matrix.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/hooks/user_prompt_submit_guard.py` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/improvement/failure-taxonomy.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/improvement/prompt-patterns.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/manifests/repair-profiles.yml` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/manifests/skills-routing-map.yml` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/manifests/visual-proof-map.yml` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/operations/batch-execution-protocol.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/operations/manual-signoff-checklists.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/operations/release-claim-truth-protocol.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/operations/task-classification.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/operations/task-intake.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/operations/validation-policy.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/review-boards/ambitions-ui-primitive-review-board.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/review-boards/ambitionsos-product-review-board.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/review-boards/continuity-sync-archive-review-board.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/review-boards/dream-safety-legality-review-board.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/review-boards/edge-case-abuse-resistance-review-board.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/review-boards/living-dream-architecture-review-board.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/review-boards/living-plan-recompiler-review-board.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/review-boards/signature-experience-review-board.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/review-boards/signature-interface-review-board.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/review-boards/source-claim-pack-security-review-board.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/review-boards/top-level-surface-review-board.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/routes/README.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/skills/accepted-yellow-classifier.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/skills/accessibility-cognitive-load-reviewer.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/skills/accessibility-privacy-performance-quality-reviewer.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/skills/adaptive-screen-implementation-reviewer.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/skills/ambitions-canon-v2-reconciler/SKILL.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/skills/ambitions-ios-surface-polisher/SKILL.md` | Codex governance | retain with proof or extraction plan | Contains legacy naming that should stay compatibility-only or be rewritten. |
| Yellow | `.codex/skills/ambitions-long-term-data-survival-reviewer.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |
| Yellow | `.codex/skills/ambitions-time-context-builder/SKILL.md` | Codex governance | retain with proof or extraction plan | Classified conservatively from path, content, and current authority boundaries. |

## 9. UI Sprawl Findings
- SwiftUI view files detected: 92
- View files over 350 lines: 38
- Files with direct UI literals: 56
- Object-related UI files: 86
- Expected final-state folders missing: 16

### Missing Expected Folders
- `Native/Ambitions/Features/Today/RealityMeridian/`
- `Native/Ambitions/Features/Today/StartHere/`
- `Native/Ambitions/Features/Today/ProofTrail/`
- `Native/Ambitions/Features/Today/ReceiptDrawer/`
- `Native/Ambitions/Features/Today/Closure/`
- `Native/Ambitions/Features/Goals/ConstellationAtlas/`
- `Native/Ambitions/Features/Capture/AtmosphereComposer/`
- `Native/Ambitions/Features/Time/LifeShapeField/`
- `Native/Ambitions/Features/You/UserSystemProfile/`
- `Native/Ambitions/Features/You/TrustConsole/`
- `Native/Ambitions/UI/Chrome/`
- `Native/Ambitions/UI/Materials/`
- `Native/Ambitions/UI/Motion/`
- `Native/Ambitions/UI/Haptics/`
- `Native/Ambitions/UI/PreviewSupport/`
- `Native/Ambitions/UI/Accessibility/`

## 10. Runtime/Proof/Trust Findings
- Active truth docs establish the current top-level IA as `Today / Goals / Capture / Time / You`.
- `Plan` remains compatibility-only or contextual language in the active canon, not top-level IA.
- Historical and generated artifacts are retained for traceability, but they must not be used as proof of runtime, accessibility, release, or simulator/device readiness.

## 11. Docs/Canon/History Sprawl Findings
- The repo still contains large supporting, historical, and audit-only document layers.
- Several docs carry compatibility or older naming that should remain classified instead of being treated as active product truth.

## 12. Prompt/Codex Governance Findings
- Prompt and governance surfaces are substantial and must continue to be routed through the runner/header discipline.
- Historical prompt material should remain archive-classified unless it is explicitly refreshed.

## 13. Build/Project/Test Findings
- The audit deliberately did not modify `Native/`, `Sources/`, `AppUI/`, `project.yml`, or `Package.swift`.
- Validation command outcomes are recorded separately below and in the JSON summary.

## 14. Files That Should Be Retained
- Active truth docs under `docs/truth/`.
- Active implementation under `Native/`, `Sources/`, and `AppUI/`.
- Runner and governance scripts that are part of current control-plane behavior.

## 15. Files That Should Be Extracted/Refactored
- Large SwiftUI view files over 350 lines.
- Feature files that embed reusable UI primitives instead of delegating to shared components.

## 16. Files That Should Be Demoted to Historical
- Older audit receipts and legacy canon portals that are no longer active truth.

## 17. Archive Candidates
- Generated build/output artifacts and old `.codex/runs/` records.

## 18. Delete Candidates
- None marked for deletion by this conservative audit.

## 19. Exact Next Remediation Trains
1. Split oversized SwiftUI views and extract repeated primitives into `Sources/Components/` or `Native/Ambitions/UI/` seams.
2. Continue truth-drift cleanup in supporting canon and historical docs, especially around `Plan` compatibility language.
3. Review generated and audit-only artifacts for archival retention versus keep-delete policy.

## 20. Acceptance Gates
- Every tracked file has one CSV row.
- Every Red file has a reason.
- Every Yellow file has a recommended action.
- Active truth conflicts are called out rather than hidden.
- Generated artifacts live only in `docs/audits/`, `build/audits/`, or `build/reports/`.

## 21. UI Sprawl Detail
- View files: 92
- Large view files: 38
- Literal UI files: 56
- Object files: 86

### Large View Files
- `AppUI/Sources/WidgetFamiliesPrimary.swift`
- `AppUI/Sources/WidgetFamiliesSecondary.swift`
- `AppUI/Sources/WidgetFoundation.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Capture/CaptureScreen.swift`
- `Native/Ambitions/Features/Goals/CreateGoalScreen.swift`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
- `Native/Ambitions/Features/Goals/GoalLifePathSignaturePrimitives.swift`
- `Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift`
- `Native/Ambitions/Features/Insights/InsightsScreen.swift`
- `Native/Ambitions/Features/Onboarding/ProgressiveIntelligenceOnboarding.swift`
- `Native/Ambitions/Features/Shared/DegradedStateOrchestrator.swift`
- `Native/Ambitions/Features/Time/TimeLifeShapeTimeCapacityMap.swift`
- `Native/Ambitions/Features/Time/TimeScreen.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/Ambitions/UI/SourceAtlasUIPrimitives.swift`
- `Sources/Components/AmbitionsExtendedTactileKit.swift`
- `Sources/Components/AmbitionsFlagshipTactilePrimitives.swift`
- `Sources/Components/AmbitionsPremiumMaterials.swift`
- `Sources/Components/ControlPrimitives.swift`
- `Sources/Components/DynamicAdaptiveVisualPrimitives.swift`
- `Sources/Components/GroupedNavigationList.swift`
- `Sources/Components/IconographyStatusPrimitives.swift`
- `Sources/Components/InformationPrimitives.swift`
- `Sources/Components/LifeDirectionalIntegrationPrimitives.swift`
- `Sources/Components/LoadingDegradedStatePrimitives.swift`
- `Sources/Components/ShellChromePrimitives.swift`
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`
- `Sources/Components/TrustReceiptLayerPrimitives.swift`
- `Sources/Previews/ComponentPreviews.swift`
- `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift`
- `Sources/Theme/AmbitionTheme.swift`

### Literal UI Files
- `AppUI/Sources/WidgetPreviews.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift`
- `Native/Ambitions/Features/Capture/CaptureScreen.swift`
- `Native/Ambitions/Features/Goals/CreateGoalScreen.swift`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
- `Native/Ambitions/Features/Goals/GoalLifePathSignaturePrimitives.swift`
- `Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift`
- `Native/Ambitions/Features/Habits/HabitComponents.swift`
- `Native/Ambitions/Features/Insights/InsightsScreen.swift`
- `Native/Ambitions/Features/Onboarding/ProgressiveIntelligenceOnboarding.swift`
- `Native/Ambitions/Features/Time/TimeFoundationCards.swift`
- `Native/Ambitions/Features/Time/TimeLifeShapeDrillDownPanel.swift`
- `Native/Ambitions/Features/Time/TimeLifeShapeTimeCapacityMap.swift`
- `Native/Ambitions/Features/Time/TimeLifeSuiteCard.swift`
- `Native/Ambitions/Features/Time/TimeReflowDecisionCard.swift`
- `Native/Ambitions/Features/Time/TimeScreen.swift`
- `Native/Ambitions/Features/Today/TodayActionClosureSheet.swift`
- `Native/Ambitions/Features/Today/TodayBackground.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/Ambitions/UI/SourceAtlasUIPrimitives.swift`
- `Native/AmbitionsShareExtension/ShareIntakeView.swift`
- `Native/AmbitionsTests/App/AccessibilityAdaptiveInterfaceDesignSystemTests.swift`
- `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`
- `Native/AmbitionsWidgetExtension/NextStepWidget.swift`
- `Sources/Components/AmbitionsExtendedTactileKit.swift`
- `Sources/Components/AmbitionsFlagshipTactilePrimitives.swift`
- `Sources/Components/AmbitionsV2CanonicalComponents.swift`
- `Sources/Components/ChromeButtonPrimitives.swift`
- `Sources/Components/ControlPrimitives.swift`
- `Sources/Components/DynamicAdaptiveVisualPrimitives.swift`
- `Sources/Components/FeedbackPrimitives.swift`
- `Sources/Components/GroupedNavigationList.swift`
- `Sources/Components/InformationPrimitives.swift`

## 22. Truth Drift Targets
- `docs/truth/CODEX_PROCESS_TRUTH.md`: File references forbidden architecture or dependency language in an active surface.
- `docs/truth/HISTORICAL_POLICY.md`: File references forbidden architecture or dependency language in an active surface.
- `docs/truth/IMPLEMENTATION_TRUTH.md`: File references forbidden architecture or dependency language in an active surface.
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`: Active truth file contains legacy IA wording that conflicts with current top-level IA.
- `docs/truth/PRODUCT_MOAT_TRUTH.md`: Active truth file contains legacy IA wording that conflicts with current top-level IA.
- `docs/truth/PRODUCT_UPGRADES_VISION.md`: File references forbidden architecture or dependency language in an active surface.
- `docs/truth/RELEASE_TRUTH.md`: File references forbidden architecture or dependency language in an active surface.

## 23. Validation Commands Run
| Command | Status | Notes |
| --- | --- | --- |
| `python3 scripts/ambitions_validate_prompt_headers.py` | Green | Returned `GREEN`. |
| `python3 scripts/ambitions_validate_batch_ids.py` | Green | Returned `GREEN`. |
| `python3 scripts/ambitions_codex_os_validate.py` | Red | File is missing in this checkout. |
| `xcodegen generate` | Green | Regenerated `Ambitions.xcodeproj`. |
| `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies` | Yellow | Timed out after 60 seconds. |
| `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 16' build CODE_SIGNING_ALLOWED=NO` | Yellow | Timed out after 60 seconds. |
| `git diff --check` | Green | No whitespace or patch-discipline errors. |

## 24. Validation Outputs
- `python3 scripts/ambitions_validate_prompt_headers.py` -> `GREEN`
- `python3 scripts/ambitions_validate_batch_ids.py` -> `GREEN`
- `python3 scripts/ambitions_codex_os_validate.py` -> missing file error
- `xcodegen generate` -> `Created project at /Users/devan/Documents/GitHub/ambitions/Ambitions.xcodeproj`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies` -> timed out after 60 seconds
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 16' build CODE_SIGNING_ALLOWED=NO` -> timed out after 60 seconds
- `git diff --check` -> no output, exit 0
