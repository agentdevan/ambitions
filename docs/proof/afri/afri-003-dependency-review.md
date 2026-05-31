# AFRI-003 Dependency Review

Status: Green for AFRI-003 bounded capability container scope.
Issue: AMB-355 / AFRI-003 -- Bounded capability container
Created: 2026-05-31
Repo: `/Users/devan/Documents/GitHub/ambitions`
Commit inspected before change: `55ff8b2f9`

This artifact is architecture/dependency proof only. It is not release proof, privacy approval, performance proof, public accessibility proof, or device proof.

## Authority Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `project.yml`
- `Package.swift`

## Capability Slices Installed

| Slice | Owner path | Contents |
| --- | --- | --- |
| shell | `AppContainer.shell` | navigation, action router, command router, memory lens service |
| runtime | `AppContainer.runtimeCapability` | runtime and feature services sourced from runtime |
| persistence | `AppContainer.persistence` | bootstrap configuration and in-memory/persistent store boundary |
| platform | `AppContainer.platform` | notification, calendar/reminders, external routing/action/import services |
| user system | `AppContainer.userSystem` | session, onboarding service, and appearance preference application seam |
| feature factory | `AppContainer.featureFactory` | Today, Capture, Goals, Habits, Time, Insights, You services |

## Dependency Boundary

- New capability slices are created by `AppContainer` at construction time.
- `AppEnvironment.appContainer(_:)` now injects both the legacy full container and the bounded slices.
- The legacy `AppContainer` service properties remain as compatibility adapters for shell and migration callers outside this feature-screen slice.
- `AppContainerFactory` remains the live construction owner.
- `PreviewAppContainerFactory` mirrors the same capability construction path for previews.
- Capability slices do not create a new runtime, persistence store, SourceRecord path, Receipt path, or ReplayTrace path.

## Screen Access Review

- `TodayScreen`, `CaptureScreen`, `GoalsScreen`, `GoalDetailScreen`, `CreateGoalScreen`, `TimeScreen`, `WeeklyReviewScreen`, `HabitsScreen`, `InsightsScreen`, and `YouScreen` now read bounded capability environment slices instead of `@Environment(\.appContainer)`.
- Feature service reads flow through `AppFeatureFactoryCapability`.
- Shell navigation and command routing flow through `AppShellCapability`.
- You notification authorization flows through `AppPlatformCapability`.
- Today session display name and You appearance preference application flow through `AppUserSystemCapability`.
- `rg -n '@Environment\(\\.appContainer\)|container\.' Native/Ambitions/Features -S` returned no matches for feature-screen full-container access after the migration. Preview `.appContainer(...)` modifiers remain as injection helpers, not screen dependency reads.
- `AppShellView` remains a shell owner and may read the full `AppContainer`; this artifact does not classify shell ownership as feature-screen dependency access.

## Concept Lock Boundary

- AMB-355 is allowlisted for `capture_routing`, `you_profile_personal_runtime`, and `persistence_external_surfaces` only for this dependency-injection migration.
- This batch does not create a new Capture router, You profile owner, persistence owner, external surface owner, SourceRecord path, Receipt path, or ReplayTrace path.
- Existing `Dashboard` type names and variables outside AFRI-003 additions remain historical implementation terminology. AFRI-003 does not claim a broad terminology retirement.

## Validation Run

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-355 --prompt /tmp/AMB-355-AFRI-003-guard-prompt.md`
  - Result: Green.
- `xcodegen generate`
  - Result: Success.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/AppContainerFactoryTests build-for-testing`
  - Result: `** TEST BUILD SUCCEEDED **`.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/AppContainerFactoryTests -only-testing:AmbitionsTests/AppShellNavigationTests`
  - Result: `** TEST SUCCEEDED **`.
  - Executed 31 tests, 0 failures.
  - Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_10-17-54--0400.xcresult`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-355 --prompt /tmp/AMB-355-AFRI-003-guard-prompt.md --changed-from 55ff8b2f9 --changed-path Native/Ambitions/App --changed-path Native/Ambitions/PreviewSupport --changed-path Native/Ambitions/Features --changed-path Native/AmbitionsTests --changed-path docs/codex/concept-lock-registry.yml --changed-path docs/proof/afri/afri-003-dependency-review.md`
  - Result: Green after the repair cycle.
  - Final report path: `build/reports/parallel-implementation-guard/AMB-355-post.md`.

## Not Yet Verified

- Full app suite, full UI suite, physical device, signed archive, release/privacy/performance/public accessibility proof.

## Rollback

- Revert `Native/Ambitions/App/AppCapabilities.swift`, `Native/Ambitions/App/AppContainer.swift`, `Native/Ambitions/App/AppContainerFactory.swift`, `Native/Ambitions/App/AppEnvironment.swift`, the migrated feature-screen dependency reads, `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`, `Native/AmbitionsTests/App/AppContainerFactoryTests.swift`, `docs/codex/concept-lock-registry.yml`, and this proof artifact.
