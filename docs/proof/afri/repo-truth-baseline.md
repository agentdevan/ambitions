# AFRI-001 Repo Truth Baseline

Status: Green for AFRI-001 audit acceptance; Yellow findings documented below.
Issue: AMB-353 / AFRI-001 -- Repo truth audit and active source map
Created: 2026-05-31
Repo: `/Users/devan/Documents/GitHub/ambitions`
Commit inspected: `f53a2c22c`
Scope: docs/proof audit only; no app source, project, workflow, dependency, or runtime behavior changes.

This report is implementation/source evidence routing, not product canon and not release proof. Active authority still begins in `docs/truth/README.md`, and live source/project/test/script evidence wins for implementation claims.

## Intake

| Field | Value |
| --- | --- |
| Task type | Repo truth audit / active source map |
| User intent | Run AMB-353 / AFRI-001 before installing or rewiring anything |
| Files changed | `docs/proof/afri/repo-truth-baseline.md` |
| Source changes | None |
| Validation required | Static source inventory, authority read, generated/obsolete artifact risk map, validation command map |
| Approval required | None for docs/proof audit |
| Risk level | Low for repo files; Medium for future work if Yellow findings are ignored |
| Hard Red triggers checked | No cloud AI/core backend dependency introduced; no Plan top-level reintroduction; no release claims; no source edits |
| Expected output | Repo truth baseline, active package/app/shell/runtime/proof map, generated/obsolete artifact risk map |

## Authority Inspected

Active truth files inspected:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md` from the current task context
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

Supporting files inspected:

- `docs/native-build-and-release.md`
- `validation/README.md`
- `docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md`
- `docs/status/current-implementation-map.md`
- `docs/status/release-evidence-packet.md`
- `docs/status/repo-cleanup-index.md`
- `docs/status/repo-authority-cleanup-active-path-allowlist.md`
- `.github/README.md`
- `.github/workflows/governance-doctor.yml`
- `Makefile`
- `GNUmakefile`

## Current Repo Shape

| Area | Active evidence | Classification |
| --- | --- | --- |
| Root authority | `README.md`, `docs/truth/README.md`, `docs/README.md`, `AGENTS.md` | Active authority/front-door routing |
| Native app source | `Native/Ambitions/` | Active app target source |
| Unit tests | `Native/AmbitionsTests/` | Active unit-test target source |
| UI tests | `Native/AmbitionsUITests/` | Active UI-test target source |
| Widget extension | `Native/AmbitionsWidgetExtension/` | Active extension target source |
| Share extension | `Native/AmbitionsShareExtension/` | Active extension target source |
| Design system package | `Sources/` | Active SwiftPM product source |
| Widget UI package | `AppUI/Sources/` | Active SwiftPM product source |
| Local validation scripts | `scripts/`, `Makefile`, `validation/README.md`, `docs/native-build-and-release.md` | Active local validation path |
| Hosted CI | `.github/workflows/governance-doctor.yml` | Yellow conflict; see CI section |
| Historical/supporting docs | `docs/canon/`, `docs/codex/`, `docs/status/`, `docs/AmbitionsCanon/`, `.codex/`, `.agents/`, `history/` | Supporting/historical unless active truth promotes |

Static source inventory from current file counts:

- `Native/Ambitions`: 372 Swift files.
- `Native/AmbitionsTests`: 269 Swift files.
- `Sources` plus `AppUI/Sources`: 64 Swift files.
- Widget/share extension source roots contain 9 source/config files plus shared app-owned `ExternalSnapshots` files referenced by `project.yml`.

## Package Structure

| Source | Evidence | Notes |
| --- | --- | --- |
| Swift package manifest | `Package.swift` | Package name is `AmbitionsDesignSystem`; products are `AmbitionsDesignSystem` and `AmbitionsWidgetUI`. |
| Design system product | `Sources/` | Product target `AmbitionsDesignSystem`; includes theme, components, accessibility, previews, generated token/source authority files. |
| Widget UI product | `AppUI/Sources/` | Product target `AmbitionsWidgetUI`; depends on `AmbitionsDesignSystem`. |
| XcodeGen package reference | `project.yml` -> `packages: AmbitionsPackages: path: .` | App and tests consume local package products through the generated Xcode project. |
| External runtime package | Not found in `Package.swift` or `project.yml` | No active `AmbitionsExperienceKernel` package dependency is currently wired. |

Active checked-in generated package source:

- `Sources/Theme/AmbitionObjectTokens.generated.swift`
- `Sources/Theme/AmbitionStateTokens.generated.swift`
- `Sources/Theme/AmbitionTokens.generated.swift`
- `Sources/Theme/AmbitionsFrontendAuthority.generated.swift`
- `Sources/Theme/AmbitionsRecipeID.generated.swift`
- `Sources/Theme/AmbitionsSurfaceID.generated.swift`

These generated Swift files are tracked active package source. Treat them as generator-owned; do not hand-edit in implementation work unless the owning generator/gate requires it.

## Xcode Project Shape

| Area | Evidence | Classification |
| --- | --- | --- |
| Project source truth | `project.yml` | Active XcodeGen source truth |
| Generated project | `Ambitions.xcodeproj/` | Ignored generated local artifact; not checked-in source truth |
| App target | `Ambitions` | iOS app target, deployment target `26.0`, Swift `6.0`, bundle `com.ambitions.ios` |
| Widget target | `AmbitionsWidgetExtension` | iOS app-extension target, embeds widget source plus selected `Native/Ambitions/ExternalSnapshots` files |
| Share target | `AmbitionsShareExtension` | iOS app-extension target, embeds share source plus selected `Native/Ambitions/ExternalSnapshots` files |
| Unit test target | `AmbitionsTests` | Depends on app target and design-system package |
| UI test target | `AmbitionsUITests` | Depends on app target and `AppIntents.framework` |
| Scheme | `Ambitions` | Builds app, extensions, unit tests, and UI tests |

`Ambitions.xcodeproj/` exists locally, but `git check-ignore` confirms it is ignored by `/Ambitions.xcodeproj/`. Future source changes should edit `project.yml` and regenerate locally, not treat the `.xcodeproj` as source authority.

## App Shell And Route Entry

| Concern | Active evidence | Notes |
| --- | --- | --- |
| App entry | `Native/Ambitions/App/AmbitionsApp.swift` | `@main` SwiftUI app activates `NotificationRuntime`, owns `AppBootstrapper`, handles URLs and active-scene import. |
| Bootstrap | `Native/Ambitions/App/AppBootstrapper.swift` | Resolves live/preview/demo bootstrap mode, builds `AppContainer`, queues deep links, imports external creations, routes notifications/widgets. |
| Dependency container | `Native/Ambitions/App/AppContainer.swift` | Holds session, runtime, navigation, feature services, platform services, routers, and onboarding/memory-lens services. |
| Container factory | `Native/Ambitions/App/AppContainerFactory.swift` | Creates SwiftData repositories, notification/EventKit services, runtime, feature services, external routers, and snapshot refresh. |
| Environment injection | `Native/Ambitions/App/AppEnvironment.swift` | Injects `AppContainer` into SwiftUI environment. |
| Root shell | `Native/Ambitions/App/AmbitionsRootView.swift` | Top-level `TabView` exposes the canonical five destinations. |
| Navigation model | `Native/Ambitions/App/AppNavigation.swift` | Owns selected tab, Goals/Time/You paths, overlays, external routing destinations, and compatibility route aliases. |
| Tab model | `Native/Ambitions/App/AppTab.swift` | `allCases` is `[.today, .goals, .capture, .time, .you]`; `.habits`, `.insights`, `.plan`, `.profile`, and `.captures` remain compatibility/internal seams. |
| Shell chrome | `Native/Ambitions/App/AppShellView.swift`, `Native/Ambitions/App/AppMeridianShell.swift` | App shell header/rail primitives exist as SwiftUI source. |
| External routes | `Native/Ambitions/App/AppExternalRouting.swift` | Handles deep links, notifications, widgets, compatibility `plan`/`time` and `captures`/`inbox` routing. |

Active user-facing top-level IA remains Today / Goals / Capture / Time / You. `Plan` is not active top-level IA; it is present as internal compatibility in code and docs.

## IA Surface Map

| Surface | Source owner | Primary evidence | Current posture |
| --- | --- | --- | --- |
| Today | `Native/Ambitions/Features/Today/` | `TodayScreen.swift`, `TodayRealityMeridian*`, `TodayStartHereSurface.swift`, `StartHereProductKernelProjection.swift` | Active surface foundation; uses `container.todayService`; not release proof. |
| Goals | `Native/Ambitions/Features/Goals/` | `GoalsScreen.swift`, `GoalsFeatureService.swift`, `GoalMissionControl*`, `GoalsOverview*` | Active surface foundation; Constellation Atlas/goal overview source exists; not release proof. |
| Capture | `Native/Ambitions/Features/Capture/` | `CaptureScreen.swift`, `CaptureAtmosphereComposer.swift`, `CaptureViewModel.swift` | Active surface foundation; composer-first source exists; not release proof. |
| Time | `Native/Ambitions/Features/Time/` | `TimeScreen.swift`, `TimeFeatureService.swift`, `TimeLifeShapeField.swift`, `Time*` | Active surface foundation; Time owns shape/capacity routes; legacy `plan` naming remains in some state/background contexts. |
| You | `Native/Ambitions/Features/You/` | `YouScreen.swift`, `YouFeatureService.swift`, `YouRootSurface.swift`, `You*` cards/projectors | Active surface foundation; User System Profile source exists; not release proof. |
| Habits/Rituals | `Native/Ambitions/Features/Habits/` | `HabitsScreen.swift`, `HabitsFeatureService.swift` | Compatibility/subroute under Time, not top-level IA. |
| Insights/History | `Native/Ambitions/Features/Insights/` | `InsightsScreen.swift`, `InsightsFeatureService.swift` | Compatibility/subroute under You, not top-level IA. |
| Onboarding | `Native/Ambitions/Features/Onboarding/` | `ProgressiveIntelligenceOnboarding.swift` | Supporting launch/setup flow, not top-level IA. |

## Runtime, Domain, Services, And Proof Map

| Layer | Active evidence | Notes |
| --- | --- | --- |
| Runtime container | `Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift` | `AmbitionsRuntime` stores repositories, services, platform integrations, `PrivateLifeRuntimeKernel`, and prototype runtime. |
| Runtime factory | `Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift` | Wires repository-backed services, local sync, local knowledge provider, notification scheduling, snapshot refresh, and runtime action executor. |
| Private Life Runtime kernel | `Native/Ambitions/Runtime/PrivateLifeRuntimeKernelContracts.swift` | Source-present and wired; `PrivateLifeRuntimeBoundary.localOnly` excludes hosted backend, remote intelligence backend, and external cloud LLM dependency. |
| Runtime services | `Native/Ambitions/Runtime/AmbitionsRuntimeServices.swift` | Loads repository-backed memory/context and executes external actions through Today service. |
| Domain models | `Native/Ambitions/Domain/` | Large domain layer for goals, planning, proof, closure, source atlas, life graph/context, runtime contracts, privacy/safety, recommendations, Today/You models, and more. |
| Goal engine | `Native/Ambitions/Domain/GoalEngine/` | Goal understanding, planning, freshness, domain packs, energy fit, path intelligence, and step candidates. |
| Planning | `Native/Ambitions/Domain/Planning/` | Deterministic planning and living-plan governance/recompile/merge/migration source exists. |
| Services | `Native/Ambitions/Services/` | Repository-backed feature/projector/services including capture, goals, knowledge, local schedule, memory lens, reality adapters, recommendations, reviews, and smart attachments. |
| Proof target | `docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md` | Active supporting proof spec only; it defines proof requirements, not proof completion. |
| Proof mode | `Native/Ambitions/Domain/ProofMode/AppDrivingProofModeRouter.swift`, `Native/AmbitionsTests/ProofMode/` | Proof-mode source/tests exist; current pass/fail requires current logs. |
| Existing proof docs | `docs/proof/` | Contains AMB-FE-BE and harness proof artifacts; useful supporting evidence only when tied to current source/logs. |

Source-present/wired is not the same as end-to-end runtime proof. Private Life Runtime moat proof still requires current test/log evidence for same-intent/different-context behavior, replay, closure/recovery, receipt continuity, and user correction.

## Persistence And Local Data Map

| Concern | Active evidence | Notes |
| --- | --- | --- |
| SwiftData store | `Native/Ambitions/Persistence/SwiftDataStore.swift` | `AmbitionsPersistenceStore` owns the SwiftData schema and read/write/transaction/reset boundaries. |
| SwiftData models | `Native/Ambitions/Persistence/SwiftDataModels.swift` | Model types include goals, drafts, plans, steps, evidence, feedback, captures, reminders, teaching, event/side-effect ledgers, tombstones, app state, action receipt history, and life context. |
| Repositories | `Native/Ambitions/Persistence/SwiftDataRepositories.swift` | Repository mapping and persistence adapters exist; some records use normalized fields plus JSON snapshots. |
| Migration/recovery scaffolds | `StorageSchemaVersionLedger.swift`, `StorageMigrationPlanScaffold.swift`, `StorageMigrationExecutionReadiness.swift`, `PreMigrationBackup.swift`, `PortableRestoreRollback.swift` | Source-present; migration safety still requires focused proof. |
| Local sync posture | `SyncCapabilityContracts.swift`, `LocalOnlySyncCapability()` in runtime factory | Local-only default; optional sync decisions belong to later AFRI gates. |
| App Group | `Native/Ambitions/Support/Ambitions.entitlements`, extension entitlements | App Group `group.com.ambitions.shared` source exists. |
| Privacy manifest | `Native/Ambitions/Resources/PrivacyInfo.xcprivacy` | Source exists and currently declares no tracking, no collected data, and no accessed API types; this is manifest source, not privacy/legal approval. |

## External Surface Map

| Surface | Active evidence | Current posture |
| --- | --- | --- |
| App Intents | `Native/Ambitions/AppIntents/` | Source foundation exists. |
| External snapshots | `Native/Ambitions/ExternalSnapshots/` | App/extension-shared contracts, writer, widget projection, action payloads, and activity attributes exist. |
| Widget extension | `Native/AmbitionsWidgetExtension/` | Widget bundle, widgets, Live Activity widget, entitlements, and Info.plist exist. |
| Share extension | `Native/AmbitionsShareExtension/` | Share intake view/controller, entitlements, and Info.plist exist. |
| Notifications | `Native/Ambitions/Notifications/` | Local notification foundation, notification runtime, and Live Activity service source exist. |
| Calendar/reminders | `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift` | EventKit integration source exists. |

These are source foundations only. They do not prove device behavior, extension behavior, permission behavior, rendered widget/Live Activity behavior, App Intent behavior, or App Store readiness.

## Validation Command Map

| Purpose | Command | Proof boundary |
| --- | --- | --- |
| Worktree cleanliness | `git status --short` | Shows local dirty state only. |
| Project generation | `xcodegen generate` | Generates `Ambitions.xcodeproj`; does not prove build/test/release. |
| Local simulator build | `./scripts/build-local.sh` | Local build proof only when current log exits 0. |
| Xcode package resolution | `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies` | Package-resolution proof only when current command exits 0. |
| Unit tests | `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available-simulator-name>" -only-testing:AmbitionsTests test` | Unit-test proof only with current logs/result bundle. |
| UI tests | `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available-simulator-name>" -only-testing:AmbitionsUITests test` | UI-test proof only with current logs/result bundle; current UI suite uses preview bootstrap per docs. |
| Unsigned archive sanity | `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -configuration Release -destination "generic/platform=iOS" -archivePath output/Ambitions.xcarchive CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY="" archive` | Unsigned archive sanity only; no signing/TestFlight/App Store proof. |
| Ambitions runner | `scripts/ambitions-codex-train.sh <BATCH_ID> <PROMPT_FILE>` or `make batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>` | Batch runner path; proof depends on current logs and changed-file scope. |
| Dirty-worktree reconciliation | `bash scripts/codex-post-pk03-dirty-reconciliation.sh` | Local dirty-state gate only. |
| Repo authority validation | `python3 scripts/ambitions-repo-authority-validate.py` / `make repo-doctor` / `make repo-doctor-strict` | Governance validation only; not app proof. |
| Private runtime wiring scan | `python3 scripts/ambitions-private-runtime-wiring-check.py` / `make private-runtime-wiring-check` | Repo-derived wiring scan; not runtime behavior proof by itself. |
| Linear sync dry run/apply | `make linear-sync-dry-run`, `make linear-sync-apply` | Repo-to-Linear control-plane sync only; write apply requires local Linear token. |
| MCP validation | `python3 tools/mcp/ambitions_repo_mcp/server.py --self-test`; `python3 tools/mcp/ambitions_proof_mcp/server.py --self-test` | Local developer tooling validation only. |

Validation run for this AFRI-001 audit:

- `git status --short`
- `git rev-parse --short HEAD`
- `find`/`rg --files` source inventory commands
- targeted `sed` reads of truth files, root docs, project/package files, app shell/runtime/persistence/surface files, validation docs, Makefile, and GitHub workflow policy files
- `git check-ignore -v` for generated project/source-atlas sidecar paths
- `git ls-files` for generated Swift package files and GitHub workflow files

Validation not run:

- `xcodegen generate`
- `./scripts/build-local.sh`
- `xcodebuild` package resolution/build/test/archive
- accessibility, performance, privacy/legal, device, TestFlight, App Store, signed archive, or human release gates

Reason: AFRI-001 is a repo truth audit and source map. It adds one docs/proof artifact and does not change app source.

## CI And Hosted Automation Map

Yellow finding: active docs conflict with tracked workflow config.

- `.github/README.md` says no tracked `.github/workflows/*.yml` file should run on `push` by default and future workflows should be manual-only through `workflow_dispatch`.
- `.github/workflows/governance-doctor.yml` is tracked and currently declares both `pull_request` and `push` triggers on `main`.

This report does not change CI policy or workflow files. Treat this as a documented Yellow governance conflict for a later repo-governance issue, not as hosted CI proof. Per `RELEASE_TRUTH.md`, hosted CI proof is not claimed here.

## Experience Kernel Artifact Map

Search scope: active source/config (`Native`, `Sources`, `AppUI`, `Package.swift`, `project.yml`) plus active/supporting truth/status/proof/canon/batch docs.

| Artifact / signal | Evidence | Classification |
| --- | --- | --- |
| `AmbitionsExperienceKernel` package dependency | No match in `Package.swift`, `project.yml`, `Native`, `Sources`, or `AppUI` | Not installed/wired as an active package |
| `docs/canon/AmbitionsOS_Experience_Kernel.md` | Present | Historical/supporting canon unless compatible with truth files |
| `docs/codex/batches/AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt.md` | Present | Historical/supporting prompt, not active implementation proof |
| `Native/Ambitions/Runtime/PrivateLifeRuntimeKernelContracts.swift` | Present | Active runtime source, not the generated external Experience Kernel package |
| `Native/Ambitions/Features/Today/StartHereProductKernelProjection.swift` | Present | Active Today projection source, not the generated external Experience Kernel package |
| `.codex/DerivedData/...Kernel...` | Ignored build/index byproducts | Generated local build artifacts; never source truth |

Conclusion: no prior generated `AmbitionsExperienceKernel` package artifact is active in package/project configuration. Kernel-named historical docs and live runtime/source files must not be conflated with an installed external package.

## Generated And Obsolete Artifact Risk Map

| Path / pattern | Evidence | Risk | Handling |
| --- | --- | --- | --- |
| `Ambitions.xcodeproj/` | Exists locally; ignored by `.gitignore` | Stale generated project can mislead audits if treated as source truth | Source truth is `project.yml`; regenerate locally when needed. |
| `.generated/` | Ignored by `.gitignore` | Generated sidecar data can be stale/non-authoritative | Do not commit; do not use as proof without current generator/log evidence. |
| `source-atlas/generated/` | Ignored by `.gitignore` except separate tracked docs/receipts may exist elsewhere | Generated scenario/receipt material can look authoritative | Use only with source-atlas validation context and current receipt/log evidence. |
| `docs/governance/generated/` | 30 tracked files found in generated/supporting area | Can be mistaken for active truth | Supporting governance outputs only; truth files and live source win. |
| `prompts/generated/` | Tracked generated prompt exists | Prompt material can be stale or runner-bound | Do not execute directly unless runner/header rules are satisfied. |
| `Sources/Theme/*.generated.swift` | 6 tracked generated Swift files | Hand edits can break generator ownership | Active package source, but generator-owned. |
| `.codex/DerivedData/`, `DerivedData/`, `output/DerivedData-*` | Ignored/generated build state exists | Can leak stale build results into proof claims | Current command logs/result bundles are required for proof. |
| `docs/canon/Ambitions_4_0*`, AOS/EB prompt docs | Historical/supporting docs present | Can revive obsolete or lower-authority canon | Use only after truth files and only when compatible. |
| `Native/Ambitions/Features/Habits`, `Native/Ambitions/Features/Insights` | Active source folders exist | Could be mistaken for top-level IA | Treat as Time/You compatibility subroutes, not top-level destinations. |
| `.github/workflows/governance-doctor.yml` | Tracked workflow has `push` and `pull_request` triggers | Conflicts with `.github/README.md` and local-validation posture | Yellow governance conflict; do not claim hosted CI proof. |

## Active / Deprecated / Supporting Artifact Summary

Active:

- `docs/truth/*`
- `README.md`, `docs/README.md`, `AGENTS.md`
- `project.yml`, `Package.swift`
- `Native/Ambitions/`
- `Native/AmbitionsTests/`
- `Native/AmbitionsUITests/`
- `Native/AmbitionsWidgetExtension/`
- `Native/AmbitionsShareExtension/`
- `Sources/`
- `AppUI/Sources/`
- `scripts/`
- `validation/README.md`
- `docs/native-build-and-release.md`

Supporting:

- `docs/status/*`
- `docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md`
- `docs/proof/*`
- `docs/AmbitionsCanon/*`
- `docs/codex/*`
- `.codex/*`
- `.agents/*`
- `frontend/`, `backend/`, `codex-os/`, `product-canon/`, `history/`
- `tools/mcp/*`

Deprecated or compatibility-only:

- `Plan` as a top-level destination: not active; only internal/contextual compatibility.
- `Habits` and `Insights` as top-level destinations: not active; currently subroute/compatibility source areas.
- `Ambitions.xcodeproj/`: generated local artifact, not source truth.
- Historical AOS/EB/kernel prompt files: not active implementation proof.

## Acceptance Gate Result

| Gate | Result | Evidence |
| --- | --- | --- |
| Repo truth report exists | Green | This file: `docs/proof/afri/repo-truth-baseline.md` |
| Active package/app/shell/runtime/proof map exists | Green | Sections above map package, XcodeGen project, shell, IA surfaces, runtime/domain/services, persistence, proof, validation |
| Generated/obsolete artifact risk documented | Green with Yellow findings | Risk map documents generated project, generated sidecars, historical docs, compatibility source folders, and CI workflow conflict |

## Claim Boundaries

Verified in this audit:

- Source/config/docs paths listed above exist in the current worktree.
- `project.yml` is the active XcodeGen project source.
- `Package.swift` exposes local `AmbitionsDesignSystem` and `AmbitionsWidgetUI` products.
- App shell source exposes canonical Today / Goals / Capture / Time / You top-level tabs.
- Runtime, persistence, services, app intent, widget, share, notification, and EventKit source foundations exist.
- Generated/stale artifact risk and CI workflow conflict are documented.

Not verified:

- App build success.
- Unit or UI test success.
- Private Life Runtime proof target completion.
- Accessibility conformance.
- Performance validation.
- Privacy/legal approval.
- Signed archive, TestFlight, App Store, or physical-device readiness.
- Hosted CI proof.

## Rollback

Rollback for AFRI-001 is docs-only: delete `docs/proof/afri/repo-truth-baseline.md` and reopen AMB-353. No source, project, dependency, workflow, generated artifact, or runtime rollback is required.

## Next Eligible Issue

If AMB-353 is accepted, the next issue is AMB-354 / AFRI-002 -- Canonical root shell and app chrome integrity.
