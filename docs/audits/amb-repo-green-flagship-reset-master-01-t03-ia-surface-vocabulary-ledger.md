# AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER Surface Vocabulary Ledger

Status: Classification ledger for stale IA/surface vocabulary.
Date: 2026-05-20T13:30:12.816602+00:00

## Scope
- Scanned tracked files under the batch-approved documentation, source, test, prompt, and governance roots.
- Classified each vocabulary hit without performing replacements or renames.
- Preserved compatibility, historical, supporting, and ordinary-language hits as classified evidence.

## Summary Counts
| classification | count |
| --- | --- |
| active_truth_allowed | 772 |
| active_forbidden_root | 1269 |
| internal_compatibility | 62 |
| accessibility_identifier | 1554 |
| test_expectation | 459 |
| historical | 16744 |
| supporting | 20016 |
| ordinary_language | 10626 |
| needs_owner_review | 0 |

Total hits: `51502`
Files with hits: `2542`

## Forbidden Active Ownership Map
| term | location | excerpt | repair train |
| --- | --- | --- | --- |
| `Captures` | `.codex/evals/prompts/07-design-system-guard.md:5` | `Polish the Captures screen so it feels like the rest of Ambitions without redesigning unrelated tabs.` | `Capture singularization / compatibility seam` |
| `captures` | `.codex/evals/prompts/07-design-system-guard.md:15` | `- Limits changes to the captures surface and any truly necessary shared UI seam.` | `Capture singularization / compatibility seam` |
| `Insights` | `.codex/manifests/repair-profiles.yml:35` | `- "Insights top-level"` | `You / contextual intelligence compatibility seam` |
| `plan` | `.codex/manifests/skills-routing-map.yml:56` | `skills: ["ambitions-operating-shell-builder", "ambitions-ios-surface-polisher", "capture-flow-implementer", "reality-rail-builder", "start-here-recommendation-builder", "goal-miss…` | `Time / Plan compatibility seam` |
| `Plan` | `.codex/operations/frontend-regression-pack.md:14` | `- shell command can route to Plan` | `Time / Plan compatibility seam` |
| `Insights` | `.codex/operations/task-classification.md:20` | `- `surface-rebuild`: Today, Goals, Goal intake, Goal Detail, Plan, Insights, Profile, onboarding surfaces` | `You / contextual intelligence compatibility seam` |
| `Plan` | `.codex/operations/task-classification.md:20` | `- `surface-rebuild`: Today, Goals, Goal intake, Goal Detail, Plan, Insights, Profile, onboarding surfaces` | `Time / Plan compatibility seam` |
| `Profile` | `.codex/operations/task-classification.md:20` | `- `surface-rebuild`: Today, Goals, Goal intake, Goal Detail, Plan, Insights, Profile, onboarding surfaces` | `You / Personal System Center compatibility seam` |
| `Plan` | `.codex/review-boards/top-level-surface-review-board.md:6` | `Gate any work touching Today, Goals, Capture, Plan, or You top-level` | `Time / Plan compatibility seam` |
| `Plan` | `.codex/skills/ambitions-canon-v2-reconciler/SKILL.md:27` | `- Ambitions has exactly five top-level tabs: `Today`, `Goals`, `Capture`, `Plan`, `You`.` | `Time / Plan compatibility seam` |
| `Plan` | `.codex/skills/ambitions-time-context-builder/SKILL.md:88` | `- Use `ambitions-ios-surface-polisher` if time context appears in visible Plan, Today, or You surfaces.` | `Time / Plan compatibility seam` |
| `captures` | `.codex/skills/capture-flow-implementer/SKILL.md:82` | `- Check that the captures tab still compiles and loads.` | `Capture singularization / compatibility seam` |
| `captures` | `.codex/skills/capture-flow-implementer/templates/capture-routing-checklist.md:4` | `- Verify tab routing reaches the captures screen.` | `Capture singularization / compatibility seam` |
| `Plan` | `.codex/skills/product-canon-drift-reviewer.md:10` | `- Top-level tabs remain `Today / Goals / Capture / Plan / You`.` | `Time / Plan compatibility seam` |
| `profile` | `.codex/skills/repo-truth-enforcer/SKILL.md:40` | `- profile/service/user-facing copy` | `You / Personal System Center compatibility seam` |
| `Plan` | `.codex/skills/surface-specific-ui-reviewer.md:3` | `Review Today, Goals, Capture, Plan, You, Memory, and Trust surfaces against their PXEQ surface matrix owner, primary visual object, and anti-generic checks.` | `Time / Plan compatibility seam` |
| `captures` | `Native/Ambitions/App/AppExternalRouting.swift:135` | `if payload.action == "open-captures-inbox" || payload.values["surface"] == "captures-inbox" {` | `Capture singularization / compatibility seam` |
| `captures` | `Native/Ambitions/App/AppExternalRouting.swift:135` | `if payload.action == "open-captures-inbox" || payload.values["surface"] == "captures-inbox" {` | `Capture singularization / compatibility seam` |
| `captures` | `Native/Ambitions/App/AppExternalRouting.swift:152` | `if payload.action == "open-captures-inbox" || payload.values["surface"] == "captures-inbox" {` | `Capture singularization / compatibility seam` |
| `captures` | `Native/Ambitions/App/AppExternalRouting.swift:152` | `if payload.action == "open-captures-inbox" || payload.values["surface"] == "captures-inbox" {` | `Capture singularization / compatibility seam` |
| `habits` | `Native/Ambitions/App/AppNavigation.swift:101` | `if tab == .habits {` | `Time / Rituals compatibility seam` |
| `insights` | `Native/Ambitions/App/AppNavigation.swift:103` | `} else if tab == .insights {` | `You / contextual intelligence compatibility seam` |
| `plan` | `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift:358` | `intent: OpenAmbitionsDestinationIntent(destination: .plan),` | `Time / Plan compatibility seam` |
| `plan` | `Native/Ambitions/ExternalSnapshots/ExternalSurfaceContractModels.swift:94` | `fallbackTab: "plan",` | `Time / Plan compatibility seam` |
| `plan` | `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotBuilder.swift:173` | `action: ExternalSurfaceVariantAction(title: "Open Time", surface: .tab, tab: "plan"),` | `Time / Plan compatibility seam` |
| `plan` | `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift:73` | `fallbackTab: contract.fallbackTab ?? "plan"` | `Time / Plan compatibility seam` |
| `plan` | `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift:74` | `)?.absoluteString ?? "ambitions://tab/plan?origin=live_activity"` | `Time / Plan compatibility seam` |
| `plan` | `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift:131` | `?? ExternalSurfaceActionPayload.safeDeepLinkURL(surface: .goalDetail, goalID: goalID, origin: .liveActivity, fallbackTab: "plan")?.absoluteString` | `Time / Plan compatibility seam` |
| `plan` | `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift:132` | `?? "ambitions://tab/plan?origin=live_activity"` | `Time / Plan compatibility seam` |
| `captures` | `Native/Ambitions/Features/Shared/ActivationContract.swift:201` | `secondaryAction: DegradedStateAction(title: "Open Capture", systemImage: "tray.full", routingHint: .captures),` | `Capture singularization / compatibility seam` |
| `habits` | `Native/Ambitions/Features/Time/TimeScreen.swift:1961` | `if destination.timeRoute == .habits {` | `Time / Rituals compatibility seam` |
| `Profile` | `Native/Ambitions/PreviewSupport/PreviewFixtures.swift:279` | `YouSystemCenterItem(id: "profile", title: "Profile", subtitle: "Name and default landing tab.", icon: "person.crop.circle", statusLabel: "Local", semanticState: .neutral, accessib…` | `You / Personal System Center compatibility seam` |
| `profile` | `Native/Ambitions/PreviewSupport/PreviewFixtures.swift:279` | `YouSystemCenterItem(id: "profile", title: "Profile", subtitle: "Name and default landing tab.", icon: "person.crop.circle", statusLabel: "Local", semanticState: .neutral, accessib…` | `You / Personal System Center compatibility seam` |
| `profile` | `Native/Ambitions/PreviewSupport/PreviewFixtures.swift:279` | `YouSystemCenterItem(id: "profile", title: "Profile", subtitle: "Name and default landing tab.", icon: "person.crop.circle", statusLabel: "Local", semanticState: .neutral, accessib…` | `You / Personal System Center compatibility seam` |
| `profile` | `Native/Ambitions/PreviewSupport/PreviewFixtures.swift:553` | `SettingsItem(id: "profile-receipts-review", title: "Reviews", subtitle: "Recovery Review and Life OS Receipt summarize local events, receipts, proof, and corrections without creat…` | `You / Personal System Center compatibility seam` |
| `Plan` | `Native/Ambitions/PreviewSupport/PreviewFixtures.swift:788` | `privacyBoundary: "Routes to Plan without calendar writes or silent reshaping.",` | `Time / Plan compatibility seam` |
| `Plan` | `Native/Ambitions/PreviewSupport/PreviewFixtures.swift:809` | `surface: "Today / Plan",` | `Time / Plan compatibility seam` |
| `plan` | `Native/Ambitions/PreviewSupport/PreviewHabitsScenarios.swift:42` | `subtitle: "Several loops need a gentler restart, so the screen is prioritizing easier versions and plan correction first.",` | `Time / Plan compatibility seam` |
| `Plan` | `Native/Ambitions/Services/SmartAttachmentService.swift:350` | `return "Matched an existing Plan destination by local wording."` | `Time / Plan compatibility seam` |
| `plan` | `Native/Ambitions/Support/CrossSurfaceContinuityMaturityReport.swift:66` | `surface: .plan,` | `Time / Plan compatibility seam` |
| `Plan` | `Native/Ambitions/Support/CrossSurfaceContinuityMaturityReport.swift:69` | `owningRoute: "Plan tab and Weekly Review",` | `Time / Plan compatibility seam` |
| `Plan` | `Native/Ambitions/Support/CrossSurfaceContinuityMaturityReport.swift:87` | `owningRoute: "You / Plan review routes",` | `Time / Plan compatibility seam` |
| `plan` | `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift:102` | `?? ExternalSurfaceActionPayload.safeDeepLinkURL(surface: .goalDetail, goalID: state.goalID, origin: .liveActivity, fallbackTab: "plan")!` | `Time / Plan compatibility seam` |
| `Plan` | `Sources/Accessibility/AccessibilityNutrition.swift:816` | `surfaceProofs.contains { $0.surface == "Plan" || $0.primaryObject == "Plan" }` | `Time / Plan compatibility seam` |
| `Plan` | `Sources/Accessibility/AccessibilityNutrition.swift:816` | `surfaceProofs.contains { $0.surface == "Plan" || $0.primaryObject == "Plan" }` | `Time / Plan compatibility seam` |
| `plan` | `Sources/Components/FE09ComponentSystemPrimitives.swift:242` | `"plan tab",` | `Time / Plan compatibility seam` |
| `profile` | `Sources/Components/FE09ComponentSystemPrimitives.swift:243` | `"profile tab",` | `You / Personal System Center compatibility seam` |
| `Plan` | `Sources/Previews/SI03ShellNavigationPreviews.swift:14` | `statusMessage: "Top-level destinations stay Today, Goals, Capture, Plan, and You.",` | `Time / Plan compatibility seam` |
| `Plan` | `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift:690` | `activeTopLevelSurfaces.contains("Plan") || scorecards.contains { $0.surface == "Plan" }` | `Time / Plan compatibility seam` |
| `Plan` | `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift:690` | `activeTopLevelSurfaces.contains("Plan") || scorecards.contains { $0.surface == "Plan" }` | `Time / Plan compatibility seam` |
| `Plan` | `build/audits/amb_file_by_file_repo_audit.py:26` | `"Plan tab",` | `Time / Plan compatibility seam` |
| `Plan` | `build/audits/amb_file_by_file_repo_audit.py:27` | `"Plan as top-level tab",` | `Time / Plan compatibility seam` |
| `Plan` | `build/audits/amb_file_by_file_repo_audit.py:28` | `"Plan returns as a top-level tab",` | `Time / Plan compatibility seam` |
| `Profile` | `build/audits/amb_file_by_file_repo_audit.py:29` | `"Profile tab",` | `You / Personal System Center compatibility seam` |
| `Plan` | `docs/codex/AIR_AMBITIONS_INTELLIGENCE_RUNTIME_FOLD_IN_OVERLAY.md:44` | `- Plan restored as top-level` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/AIR_AMBITIONS_INTELLIGENCE_RUNTIME_FOLD_IN_OVERLAY.md:79` | `- Plan as a top-level destination becomes Time.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/AIR_AMBITIONS_INTELLIGENCE_RUNTIME_FOLD_IN_OVERLAY.md:81` | `- Active/future `Plan LifeShape` user-facing scope becomes `Time LifeShape`.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/AIR_AMBITIONS_INTELLIGENCE_RUNTIME_FOLD_IN_OVERLAY.md:82` | `- Plan as a future intelligence UI surface owner becomes Time.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/AMBITIONS_CANON_UI_COMPLETION_INSERTION_OVERLAY.md:80` | `Lock final top-level IA: Today, Goals, Capture, Time, You. Supersede Plan as a top-level destination. Document Goals → Time → Today hierarchy.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/AMBITIONS_CANON_UI_COMPLETION_INSERTION_OVERLAY.md:177` | `3. Plan returns as a top-level destination.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/BATCH_REGISTRY.md:39` | `Time / You. Plan is superseded as a top-level destination and remains valid` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/BATCH_REGISTRY.md:827` | `top-level composition bar to Today, Goals, Capture, Plan, and You, named` | `Time / Plan compatibility seam` |
| `Captures` | `docs/codex/BATCH_REGISTRY.md:1020` | `| 01 | Pre-Phase-9 cleanup and Captures tab | Completed | Runtime truth cleanup, capture source normalization, captures-tab wiring verification, routing, and targeted tests are co…` | `Capture singularization / compatibility seam` |
| `captures` | `docs/codex/BATCH_REGISTRY.md:1020` | `| 01 | Pre-Phase-9 cleanup and Captures tab | Completed | Runtime truth cleanup, capture source normalization, captures-tab wiring verification, routing, and targeted tests are co…` | `Capture singularization / compatibility seam` |
| `Plan` | `docs/codex/BATCH_REGISTRY.md:1104` | `| M07 | Path Builder and Long-Range Roadmap UI | Completed | Added a Goal Detail-owned Path Builder projection/UI with phases, dependencies, fork prompts, proof checks, Today/Plan…` | `Time / Plan compatibility seam` |
| `Profile` | `docs/codex/BATCH_REGISTRY.md:1110` | `| R01 | Final Accessibility Verification and Claims Lock | Completed | Added a code-backed claims lock and You/Profile claim status copy; public accessibility claims remain blocke…` | `You / Personal System Center compatibility seam` |
| `Plan` | `docs/codex/BATCH_REGISTRY.md:1130` | `| 68 | Command Pipeline Foundation | Completed | Shared command model, validation states, execution results, conservative local executor, quick-capture command execution, route-on…` | `Time / Plan compatibility seam` |
| `captures` | `docs/codex/BATCH_REGISTRY.md:1130` | `| 68 | Command Pipeline Foundation | Completed | Shared command model, validation states, execution results, conservative local executor, quick-capture command execution, route-on…` | `Capture singularization / compatibility seam` |
| `Plan` | `docs/codex/BATCH_REGISTRY.md:1131` | `| 69 | Capture 2.0 Core | Completed | Capture 2.0 domain taxonomy, conservative classification, Plan-seed representation, goal attachment, waiting/optional/archive routing, truthf…` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/BATCH_REGISTRY.md:1131` | `| 69 | Capture 2.0 Core | Completed | Capture 2.0 domain taxonomy, conservative classification, Plan-seed representation, goal attachment, waiting/optional/archive routing, truthf…` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/BATCH_REGISTRY.md:1155` | `| 93 | Widgets and Live Activity Ambient Continuity | Future / resequenced | Future external surface batch; newly integrated planned canon includes calm snapshots for Next Visible…` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/BATCH_REGISTRY.md:1262` | `| FVQ02 Five Top-Level Surface Visual Sweep | Complete / Accepted Yellow | FVQ02 captured durable simulator screenshots for Today, Goals, Capture, Plan, and You; removed the gener…` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/BATCH_REGISTRY.md:1262` | `| FVQ02 Five Top-Level Surface Visual Sweep | Complete / Accepted Yellow | FVQ02 captured durable simulator screenshots for Today, Goals, Capture, Plan, and You; removed the gener…` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/CONTEXT_INDEX.md:30` | `Plan remains superseded as a top-level destination.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/CONTEXT_INDEX.md:42` | `This week can hold. Plan remains superseded as top-level.` | `Time / Plan compatibility seam` |
| `habits` | `docs/codex/FAANG_HANDOFF_REPO_CLEANUP_PROMPT.md:180` | `'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|missed' . || true` | `Time / Rituals compatibility seam` |
| `insights` | `docs/codex/FAANG_HANDOFF_REPO_CLEANUP_PROMPT.md:180` | `'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|missed' . || true` | `You / contextual intelligence compatibility seam` |
| `profile` | `docs/codex/FAANG_HANDOFF_REPO_CLEANUP_PROMPT.md:180` | `'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|missed' . || true` | `You / Personal System Center compatibility seam` |
| `Plan` | `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md:54` | `| 24 | Cross-surface proof/review integration | Shared trust / all surfaces | Today proof receipt, Goals proof/history, Capture receipt, Plan reflow receipt, You trust history, sh…` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md:54` | `| 24 | Cross-surface proof/review integration | Shared trust / all surfaces | Today proof receipt, Goals proof/history, Capture receipt, Plan reflow receipt, You trust history, sh…` | `Time / Plan compatibility seam` |
| `Profile` | `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md:54` | `| 24 | Cross-surface proof/review integration | Shared trust / all surfaces | Today proof receipt, Goals proof/history, Capture receipt, Plan reflow receipt, You trust history, sh…` | `You / Personal System Center compatibility seam` |
| `Profile` | `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md:134` | `bounded You/Profile cross-surface proof/review integration on 2026-05-05.` | `You / Personal System Center compatibility seam` |
| `Plan` | `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md:18` | `| 6 FCP surface maturity | Remaining FCP implementation | Mature You, Capture, Plan, Goals, object states, and status grammar around the shared object language. | All 25 objects a…` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md:29` | `top-level destination and older ACUI/Plan-era sequencing is superseded where it` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md:284` | `| Top-Level Surface Composition Gate | Any Today/Goals/Capture/Plan/You top-level UI work | Proposed surface is a vertical stack of generic cards or detail archive. |` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md:52` | ``Plan` is superseded as a top-level destination and remains valid only as an` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md:33` | `| Top-Level Surface Composition Gate | Today/Goals/Capture/Plan/You top-level UI | Glance, one-primary-object, and drill-down discipline pass. | Minor hierarchy risk has owner. | …` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md:19` | ``Plan` is superseded as a top-level destination and remains valid only as an` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md:316` | `| 032 | FCP25 Loading / Empty / Degraded State Objectization | FCP | Implementation | Completed Green on 2026-05-06 as bounded shared/top-level object-state evidence with a Flagsh…` | `Time / Plan compatibility seam` |
| `habits` | `docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md:106` | `rg -n --hidden --glob '!/.git/**' 'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|miss…` | `Time / Rituals compatibility seam` |
| `insights` | `docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md:106` | `rg -n --hidden --glob '!/.git/**' 'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|miss…` | `You / contextual intelligence compatibility seam` |
| `profile` | `docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md:106` | `rg -n --hidden --glob '!/.git/**' 'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|miss…` | `You / Personal System Center compatibility seam` |
| `Plan` | `docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md:61` | `- Plan restored as top-level tab.` | `Time / Plan compatibility seam` |
| `Captures` | `docs/codex/OBJECT_OS_MRI25_34_UPGRADE_OVERLAY.md:143` | `- Captures route to Proof, Source, Constraint, Commitment, Reflection, Goal Seed, Held Item, Needs a Place, Ready to Place, or Grow into Goal.` | `Capture singularization / compatibility seam` |
| `Plan` | `docs/codex/PXOS_DEPENDENCY_GRAPH.md:10` | `- PX05 is complete as Plan future-canon surface work.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/PXOS_GATE_MATRIX.md:10` | `| 3 Surface Ownership | Today/Goals/Capture/Plan/You/cross-surface owner named | Owner unclear |` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md:87` | `| Cross-surface continuity follows Capture -> Place -> Plan -> Do Today -> Close / Recover -> Save Proof | PX15 and core loop canon | Cross-surface continuity | all surfaces | PX1…` | `Time / Plan compatibility seam` |
| `plan` | `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md:97` | `- AOS16: Performance Energy Kernel. Gate: must be active before runtime-heavy implementation and must inherit HPS09/HPS10 and Source Atlas PDF/OCR/pack traversal budgets. Owner: P…` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md:16` | `FCP turns the Ambitions 10/10 Flagship Completion Plan into sequenced, gated implementation. It upgrades every major primitive, component, surface, object, state, motion, trust, p…` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md:16` | `FCP turns the Ambitions 10/10 Flagship Completion Plan into sequenced, gated implementation. It upgrades every major primitive, component, surface, object, state, motion, trust, p…` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md:16` | `Deepen Ambitions' existing Today, Goals, Capture, Plan, and You surfaces through drill-downs, detail flows, proof, recovery, review, setup, and cross-surface continuity without ad…` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md:65` | `- PD17: Cross-Surface Proof and Review Integration. Type: Mixed implementation. Owner: Cross-surface. Boundary: Connect Today, Goals, Capture, Plan, and You through proof and revi…` | `Time / Plan compatibility seam` |
| `Profile` | `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md:65` | `- PD17: Cross-Surface Proof and Review Integration. Type: Mixed implementation. Owner: Cross-surface. Boundary: Connect Today, Goals, Capture, Plan, and You through proof and revi…` | `You / Personal System Center compatibility seam` |
| `Profile` | `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md:65` | `- PD17: Cross-Surface Proof and Review Integration. Type: Mixed implementation. Owner: Cross-surface. Boundary: Connect Today, Goals, Capture, Plan, and You through proof and revi…` | `You / Personal System Center compatibility seam` |
| `Plan` | `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md:73` | `| SI17 | Top-Level Surface Composition Implementation | SwiftUI implementation | 064 | Complete | Applied SI composition bar to Today, Goals, Capture, Plan, and You. |` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/AFI02_IA_Hierarchy_Lock.md:35` | `- Source-truth scan for Plan-tab / Plan-screen / top-level Plan wording.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/AFI02_IA_Hierarchy_Lock.md:35` | `- Source-truth scan for Plan-tab / Plan-screen / top-level Plan wording.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/AFI02_IA_Hierarchy_Lock.md:35` | `- Source-truth scan for Plan-tab / Plan-screen / top-level Plan wording.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/AFI04_Material_System_Proof.md:22` | `Plan as the top-level LifeShape Field surface.` | `Time / Plan compatibility seam` |
| `plan` | `docs/codex/batches/AFI05_Shell_And_Continuity_Chrome.md:23` | `the fourth top-level destination while preserving `.plan` raw values and route` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/AFI05_Shell_And_Continuity_Chrome.md:32` | `failures after repairing one stale Plan-era expected title in the screen` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/AFI15_Founder_Acceptance_Review.md:43` | `- Plan-era as a top-level IA` | `Time / Plan compatibility seam` |
| `Captures` | `docs/codex/batches/BATCH-01-pre-phase9-cleanup-and-captures-tab.md:1` | `# Batch 01 — Pre-Phase-9 Cleanup And Captures Tab` | `Capture singularization / compatibility seam` |
| `Captures` | `docs/codex/batches/BATCH-01-pre-phase9-cleanup-and-captures-tab.md:9` | `Complete the pre-Phase-9 cleanup slice and land the first-class Captures tab wiring already defined in the seeded checklist, without pulling later roadmap work forward.` | `Capture singularization / compatibility seam` |
| `Captures` | `docs/codex/batches/BATCH-01-pre-phase9-cleanup-and-captures-tab.md:21` | `- add or confirm the Captures tab in `AmbitionsRootView`` | `Capture singularization / compatibility seam` |
| `Captures` | `docs/codex/batches/BATCH-01-pre-phase9-cleanup-and-captures-tab.md:42` | `- Captures tab wiring in `AmbitionsRootView`` | `Capture singularization / compatibility seam` |
| `Captures` | `docs/codex/batches/BATCH-01-pre-phase9-cleanup-and-captures-tab.md:50` | `- Captures is a first-class app tab backed by the existing container and routing seams.` | `Capture singularization / compatibility seam` |
| `Captures` | `docs/codex/batches/BATCH-04-canon-batch-2-first-class-capture-core.md:40` | `- The Captures tab is already routed through the app container and tab model.` | `Capture singularization / compatibility seam` |
| `Profile` | `docs/codex/batches/BATCH-17-canon-batch-14-runtime-separation.md:80` | `- Profile reports sync/trust status through injection without becoming a runtime settings surface` | `You / Personal System Center compatibility seam` |
| `Plan` | `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md:9` | `Restore shell truth across the app and repo by reconciling top-level information architecture and navigation with canon, recovering Plan as a real canonical weekly-shaping surface…` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md:17` | `- Plan canon recovery as a first-class weekly-shaping surface` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md:41` | `- Plan is restored as a real canonical weekly-shaping surface` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md:95` | `- Plan confirmed visible as a first-class surface` | `Time / Plan compatibility seam` |
| `captures` | `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md:102` | `- stored preferred-tab values of `.captures` now normalize to Today on load/save` | `Capture singularization / compatibility seam` |
| `Plan` | `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md:103` | `- stored preferred-tab values of `.habits` now normalize to Plan on load/save` | `Time / Plan compatibility seam` |
| `habits` | `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md:103` | `- stored preferred-tab values of `.habits` now normalize to Plan on load/save` | `Time / Rituals compatibility seam` |
| `Plan` | `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md:112` | `- Plan now exists as a truthful first-class weekly-shaping surface rather than a missing canon role` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md:119` | `Batch 35 is complete only when shell truth, navigation truth, and Plan canon recovery are landed and validated clearly enough to make external-surface validation in Batch 36 trust…` | `Time / Plan compatibility seam` |
| `Profile` | `docs/codex/batches/BATCH-36-post-2.0-hardening-trust-extensions-and-external-surface-validation.md:56` | `- Centralized external-surface truth wording across Profile, previews, placeholders, and docs.` | `You / Personal System Center compatibility seam` |
| `Profile` | `docs/codex/batches/BATCH-36-post-2.0-hardening-trust-extensions-and-external-surface-validation.md:57` | `- Added a narrow Profile trust surface that reflects notification authorization without turning Profile into a broader integration center.` | `You / Personal System Center compatibility seam` |
| `Profile` | `docs/codex/batches/BATCH-36-post-2.0-hardening-trust-extensions-and-external-surface-validation.md:57` | `- Added a narrow Profile trust surface that reflects notification authorization without turning Profile into a broader integration center.` | `You / Personal System Center compatibility seam` |
| `captures` | `docs/codex/batches/BATCH-36-post-2.0-hardening-trust-extensions-and-external-surface-validation.md:68` | `- Passed `AmbitionsUITests`, including canonical landing coverage for `ambitions://tab/plan` and `ambitions://captures/inbox`.` | `Capture singularization / compatibility seam` |
| `plan` | `docs/codex/batches/BATCH-36-post-2.0-hardening-trust-extensions-and-external-surface-validation.md:68` | `- Passed `AmbitionsUITests`, including canonical landing coverage for `ambitions://tab/plan` and `ambitions://captures/inbox`.` | `Time / Plan compatibility seam` |
| `Profile` | `docs/codex/batches/CS02_Profile_To_You_Internal_Naming_Retirement_Prompt.md:217` | `- visible top-level tab regresses from `You` to `Profile`.` | `You / Personal System Center compatibility seam` |
| `Plan` | `docs/codex/batches/CS03_Insights_Compatibility_Retirement_Prompt.md:142` | `- Visible top-level tab label remains `Plan`.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/CS03_Insights_Compatibility_Retirement_Prompt.md:191` | `| User-facing tab label | Must remain `Plan` | Shell/display proof |` | `Time / Plan compatibility seam` |
| `Habits` | `docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md:135` | `- Creating duplicate `Habits` and `Rituals` top-level destinations.` | `Time / Rituals compatibility seam` |
| `Plan` | `docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md:142` | `- Visible top-level tabs remain `Today / Goals / Capture / Plan / You`.` | `Time / Plan compatibility seam` |
| `Habits` | `docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md:189` | `| Preferred/default tab `.habits` | Canonicalizes to `.plan` without storing a visible Habits default. | CS04B shell/default proof |` | `Time / Rituals compatibility seam` |
| `habits` | `docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md:189` | `| Preferred/default tab `.habits` | Canonicalizes to `.plan` without storing a visible Habits default. | CS04B shell/default proof |` | `Time / Rituals compatibility seam` |
| `plan` | `docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md:189` | `| Preferred/default tab `.habits` | Canonicalizes to `.plan` without storing a visible Habits default. | CS04B shell/default proof |` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md:192` | `| User-facing tab labels | Must remain `Today / Goals / Capture / Plan / You`; route copy may say `Rituals`. | Shell/display proof |` | `Time / Plan compatibility seam` |
| `Habits` | `docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md:237` | `Red: broad Habits-to-Rituals or Habits-to-Plan rename, route/deep-link uncertainty, raw-value uncertainty, default/persistence uncertainty, `PlanRouteTarget.habits` deletion witho…` | `Time / Rituals compatibility seam` |
| `Habits` | `docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md:237` | `Red: broad Habits-to-Rituals or Habits-to-Plan rename, route/deep-link uncertainty, raw-value uncertainty, default/persistence uncertainty, `PlanRouteTarget.habits` deletion witho…` | `Time / Rituals compatibility seam` |
| `Habits` | `docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md:237` | `Red: broad Habits-to-Rituals or Habits-to-Plan rename, route/deep-link uncertainty, raw-value uncertainty, default/persistence uncertainty, `PlanRouteTarget.habits` deletion witho…` | `Time / Rituals compatibility seam` |
| `Plan` | `docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md:237` | `Red: broad Habits-to-Rituals or Habits-to-Plan rename, route/deep-link uncertainty, raw-value uncertainty, default/persistence uncertainty, `PlanRouteTarget.habits` deletion witho…` | `Time / Plan compatibility seam` |
| `habits` | `docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md:237` | `Red: broad Habits-to-Rituals or Habits-to-Plan rename, route/deep-link uncertainty, raw-value uncertainty, default/persistence uncertainty, `PlanRouteTarget.habits` deletion witho…` | `Time / Rituals compatibility seam` |
| `Plan` | `docs/codex/batches/DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt.md:38` | ``Implement Plan dynamic adaptive screen`` | `Time / Plan compatibility seam` |
| `Profile` | `docs/codex/batches/DAV07_You_SystemProfilePanel_And_GroupedNavigation_Implementation_Prompt.md:16` | `Profile raw value migration, default tab changes, persistence/schema, dependencies, workflows.` | `You / Personal System Center compatibility seam` |
| `plan` | `docs/codex/batches/F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt.md:32` | `- one-tap destination access plan` | `Time / Plan compatibility seam` |
| `habits` | `docs/codex/batches/F22_Product_Language_And_Doc_QA_Final_Migration_Prompt.md:17` | `rg -n --hidden --glob '!/.git/**' 'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|miss…` | `Time / Rituals compatibility seam` |
| `insights` | `docs/codex/batches/F22_Product_Language_And_Doc_QA_Final_Migration_Prompt.md:17` | `rg -n --hidden --glob '!/.git/**' 'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|miss…` | `You / contextual intelligence compatibility seam` |
| `profile` | `docs/codex/batches/F22_Product_Language_And_Doc_QA_Final_Migration_Prompt.md:17` | `rg -n --hidden --glob '!/.git/**' 'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|miss…` | `You / Personal System Center compatibility seam` |
| `Plan` | `docs/codex/batches/FCP17_Schedule_Availability_Defaults_Center_Prompt.md:14` | `truth. It gives Plan and Today a reviewable user-control surface for hard` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/FL02_Life_Inventory_Object_Model_Prompt.md:33` | `- Life Inventory maps to Today, Capture, Goals, Plan, You, Memory Lens, AmbitionsOS, and LDI without creating a sixth tab.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/FL02_Life_Inventory_Object_Model_Prompt.md:64` | `- Surface mapping covers Today, Capture, Goals, Plan, You, Memory Lens, AOS, and LDI.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/HPS01_Verified_Human_Progress_OS_Category_Lock_Prompt.md:52` | `- Five-tab coherence remains Today / Goals / Capture / Plan / You.` | `Time / Plan compatibility seam` |
| `Profile` | `docs/codex/batches/ME06_ProfileScreen_You_Surface_Extraction_Prompt.md:11` | `- Extraction target: Extract You/Profile surface sections while preserving user-facing You naming.` | `You / Personal System Center compatibility seam` |
| `Plan` | `docs/codex/batches/ME07_PlanScreen_Extraction_Prompt.md:11` | `- Extraction target: Extract Plan screen composition without redesign.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt.md:107` | `- Every candidate names Today, Goals, Capture, Plan, You, or cross-surface proof/review ownership.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/PD12_Plan_Reflow_Decision_Depth_Prompt.md:12` | `- Primary surface ownership: Plan` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/PD13_Plan_Recovery_And_Pressure_Review_Prompt.md:12` | `- Primary surface ownership: Plan` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/PD14_Life_Shape_Drilldowns_Prompt.md:12` | `- Primary surface ownership: Plan` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/PX01_Product_Experience_OS_Canon_And_Surface_Hierarchy_Prompt.md:55` | `- Lock the five top-level surfaces: Today, Goals, Capture, Plan, You.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/PX05_Plan_Life_Shape_Experience_Prompt.md:60` | `- Name what belongs in Plan detail views versus the top-level Plan orientation.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/PX05_Plan_Life_Shape_Experience_Prompt.md:60` | `- Name what belongs in Plan detail views versus the top-level Plan orientation.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/PX15_Cross_Surface_Continuity_Prompt.md:54` | `- Define cross-surface continuity for Capture -> Place -> Plan -> Do Today ->` | `Time / Plan compatibility seam` |
| `Plan` | `docs/codex/batches/SI08_LifeShape_Time_Capacity_Map_Prompt.md:85` | `Plan feels like a shaping surface.` | `Time / Plan compatibility seam` |
| `Insights` | `docs/codex/batches/batch-51.md:24` | `Rebuild Insights and reflection surfaces into a narrative truth layer rather than a generic analytics screen.` | `You / contextual intelligence compatibility seam` |
| `Plan` | `docs/codex/batches/batch-57.md:27` | `- larger-screen Plan workspace refinements` | `Time / Plan compatibility seam` |
| `Insights` | `docs/codex/batches/batch-57.md:28` | `- larger-screen Insights and Goal Detail patterns` | `You / contextual intelligence compatibility seam` |
| `Captures` | `docs/codex/repo-audit-baseline.md:219` | `- The Captures tab reads from `captureService.listCaptures()`.` | `Capture singularization / compatibility seam` |
| `Plan` | `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md:117` | `- `Plan` as user-facing top-level IA` | `Time / Plan compatibility seam` |
| `Profile` | `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md:118` | `- `Profile` as top-level shell label` | `You / Personal System Center compatibility seam` |
| `Insights` | `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md:119` | `- `Insights` as top-level shell label` | `You / contextual intelligence compatibility seam` |
| `Habits` | `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md:120` | `- `Habits` as top-level shell label` | `Time / Rituals compatibility seam` |
| `Plan` | `docs/codex/visual-quality/FVQ_VISUAL_EXCELLENCE_TRAIN.md:27` | `2. FVQ02 Five Top-Level Surface Visual Sweep — Today, Goals, Capture, Plan, You.` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/FINAL_RECONCILED_BATCH_REGISTRY.md:91` | `| Plan (top-level destination) | Time |` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/SUPERSEDED_AND_ARCHIVE_BATCHES.md:22` | `## Plan As Top-Level Destination` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12862` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12866` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12870` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12874` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12878` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12882` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12886` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12890` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12894` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12898` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12902` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12906` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12910` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12914` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12918` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12922` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12926` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12930` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12934` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12938` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |
| `Plan` | `docs/governance/generated/canon_impact_map.json:12942` | `"signal": "possible active Plan top-level residue"` | `Time / Plan compatibility seam` |

Additional forbidden active ownership hits omitted from markdown: `435`

## Yellow Owner-Review List
- None

## Allowed Hit Policy
- `active_truth_allowed`: Current truth files and current truth-consistent statements are allowed and do not imply implementation proof.
- `internal_compatibility`: Compatibility seams, aliases, raw values, and migration surfaces are retained until a scoped owner proves retirement.
- `accessibility_identifier`: Stable automation identifiers are compatibility surfaces and should be frozen, aliased, or retired only with proof.
- `test_expectation`: Tests may assert current compatibility or visible labels; do not rewrite them blindly during a vocabulary audit.
- `historical`: Historical material stays labeled as history and is not cleanup proof.
- `supporting`: Supporting material is non-authority and may retain compatibility language when clearly classified.
- `ordinary_language`: Ordinary prose uses of the words are allowed and should not be rewritten without need.
- `needs_owner_review`: Ambiguous hits require a human or scoped owner decision before any cleanup or rename.

## Non-Claims
- No source, test, or product behavior was changed by this scan.
- No zero-hit claim is made for the vocabulary families.
- No implementation, accessibility, performance, privacy, or release readiness claim is made.
- No blind replacement or mass rename was performed.

## Notes
- JSON detail: `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.json`
- This ledger is classification evidence only; it does not justify blind cleanup or zero-hit claims.
