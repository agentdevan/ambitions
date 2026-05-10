# IMPLEMENTATION_TRUTH.md

Status: Active implementation/source truth  
Scope: Actual repo/source implementation status, scaffold status, compatibility debt, missing implementation, and forbidden implementation claims  
Applies to: Ambitions native iPhone repo  
Owner posture: Source truth, not product vision and not release proof  
Effective rule: Live source, project files, scripts, tests, and current proof evidence win over plans, historical docs, old canon, handoffs, batch-train docs, prompts, and aspirational reports.

---

## 1. Purpose and Authority

This file is the actual implementation/source truth for Ambitions.

It answers:

- what exists in the repo now
- what is source-present
- what is wired
- what is scaffolded
- what is missing
- what is obsolete or conflicting
- what is compatibility debt
- what is unproven
- what Codex must not claim as implemented

This file does not define what Ambitions should become. That authority belongs to:

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
```

This file does not define release readiness. That authority belongs to:

```text
docs/truth/RELEASE_TRUTH.md
```

A feature is not implemented because it appears in a plan, canon document, batch document, audit, handoff, prompt, skill, README, or future roadmap. A feature is implementation truth only when live repo source/project/test/script evidence supports that state.

---

## 2. Relationship to Other Truth Files

Truth hierarchy for implementation work:

1. `docs/truth/PRODUCT_DESIGN_TRUTH.md` defines product/design direction. It does not prove implementation.
2. `docs/truth/IMPLEMENTATION_TRUTH.md` defines actual repo/source status.
3. `docs/truth/RELEASE_TRUTH.md` defines validation and release proof.
4. `docs/truth/CODEX_PROCESS_TRUTH.md` defines how Codex must inspect, patch, validate, repair, and report.
5. `docs/truth/HISTORICAL_POLICY.md` defines how old material is extracted, archived, deleted, or quarantined.

Conflict rules:

- Product/design conflict: `PRODUCT_DESIGN_TRUTH.md` wins.
- Implementation/source conflict: live source/project/test/script evidence wins.
- Release/readiness conflict: current release proof wins.
- Historical conflict: historical docs lose unless explicitly promoted by a truth file.
- Docs-only plans never prove implementation.

---

## 3. Source Evidence Standard

Implementation evidence may come from:

- Swift source files
- XcodeGen `project.yml`
- Swift package manifest
- app resources
- entitlements
- privacy manifest
- scripts
- test source files
- current validation logs
- checked-in proof artifacts, if explicitly current
- current repo tree evidence

Implementation evidence may not come from:

- old canon alone
- batch-train prompts alone
- handoff docs alone
- audit reports alone
- README claims alone
- design truth alone
- planning docs alone
- generated reports without source/log backing
- Codex memory
- model inference
- expected behavior

Implementation state labels:

| Label | Meaning |
|---|---|
| Source-present | Files/source exist in the repo. |
| Configured | Project/package/target/script config exists. |
| Wired | Source calls or dependency graph connect the feature to app runtime. |
| Scaffolded | Shape/contracts/source exist, but behavior is partial or not proven end-to-end. |
| Preview-backed | Works only through preview/demo/in-memory paths unless live proof exists. |
| Unproven | No current source/log/proof establishes the claim. |
| Not found | Inspection found no active repo/source evidence. |
| Historical | Exists only in old docs/prompts/audits/batch material. |
| Conflicting | Contradicts active truth, source, or release proof. |

---

## 4. Repository Snapshot

Current repo posture from inspected evidence:

- Native iOS app source exists under `Native/Ambitions/`.
- Xcode project is generated from `project.yml`.
- The checked-in package manifest defines shared Swift packages.
- The app is SwiftUI-first.
- The configured deployment target is iOS 17.0.
- The repo has source for app, widget extension, share extension, unit tests, UI tests, design system package, widget UI package, scripts, and substantial docs/Codex material.
- The app has local SwiftData persistence source.
- The app has App Group entitlement source.
- The app has a privacy manifest source.
- The repo has local build/setup scripts.
- The repo has no active release proof proving TestFlight/App Store/device readiness.
- No active hosted CI workflow was found during this inspection.
- Old docs and Codex/batch material are extensive and subordinate unless promoted by truth files.

Primary evidence paths:

```text
README.md
AGENTS.md
project.yml
Package.swift
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/native-build-and-release.md
docs/status/current-implementation-map.md
docs/status/release-evidence-packet.md
docs/status/repo-cleanup-index.md
Native/Ambitions/App/AmbitionsApp.swift
Native/Ambitions/App/AmbitionsRootView.swift
Native/Ambitions/App/AppTab.swift
Native/Ambitions/App/AppBootstrapper.swift
Native/Ambitions/App/AppContainerFactory.swift
Native/Ambitions/Persistence/SwiftDataStore.swift
Native/Ambitions/Persistence/SwiftDataModels.swift
Native/Ambitions/Features/Today/TodayScreen.swift
Native/Ambitions/Features/Goals/GoalsScreen.swift
Native/Ambitions/Features/Captures/CapturesScreen.swift
Native/Ambitions/Features/Plan/PlanScreen.swift
Native/Ambitions/Features/Profile/ProfileScreen.swift
Sources/Theme/AmbitionTheme.swift
Native/AmbitionsUITests/AmbitionsUITests.swift
scripts/build-local.sh
scripts/setup_macos_ios_dev.sh
Native/Ambitions/Support/Ambitions.entitlements
Native/Ambitions/Resources/PrivacyInfo.xcprivacy
```

---

## 5. Current App Architecture

The current implementation is a native SwiftUI iOS app with:

- SwiftUI `@main` app entry.
- Bootstrapper-driven launch.
- App container/dependency factory.
- Local repository preparation.
- SwiftData persistence store.
- Runtime/services dependency graph.
- SwiftUI shell/root view.
- Five canonical user-facing top-level surfaces in source wiring:
  - Today
  - Goals
  - Capture
  - Time
  - You
- Internal compatibility names remain:
  - `plan`
  - `PlanScreen`
  - `profile`
  - `ProfileScreen`
  - `captures`
  - `DayTimelineRail`
  - `GoalMissionControl`
- App Intents, external snapshots, widget/share extension targets, notification runtime, EventKit service, and external routing source exist.
- Design system package source exists.
- Widget UI package source exists.

Implementation truth:

- The architecture is source-present and substantially wired.
- End-to-end maturity is not proven by source presence alone.
- Runtime correctness, persistence correctness, extension correctness, accessibility, performance, and release readiness require validation proof.

---

## 6. Native iPhone / Xcode / Project Structure

Source evidence:

```text
project.yml
docs/native-build-and-release.md
scripts/build-local.sh
scripts/setup_macos_ios_dev.sh
```

Implementation truth:

- The repo uses XcodeGen.
- `Ambitions.xcodeproj` is generated and should not be treated as checked-in source truth.
- The configured app platform is iOS.
- The deployment target in `project.yml` is iOS 17.0.
- Swift version in `project.yml` is 5.10.
- The app target is named `Ambitions`.
- Native app source is under `Native/Ambitions`.
- Resources are under `Native/Ambitions/Resources`.
- Entitlements are configured through source paths in `project.yml`.

Unproven:

- Current project generation success.
- Current package resolution success.
- Current local simulator build success.
- Current archive success.
- Current device install behavior.

Required proof before claims:

```text
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
```

with current logs, exit codes, branch, and commit SHA.

---

## 7. Targets and Packages

Configured targets from `project.yml`:

| Target | Type | Implementation Truth |
|---|---|---|
| `Ambitions` | iOS application | Configured app target. Source-present. Runtime/build unproven without logs. |
| `AmbitionsWidgetExtension` | iOS app extension | Configured widget extension target. Runtime/device behavior unproven. |
| `AmbitionsShareExtension` | iOS app extension | Configured share extension target. Runtime/device behavior unproven. |
| `AmbitionsTests` | Unit test bundle | Configured test target. Current pass/fail unproven. |
| `AmbitionsUITests` | UI test bundle | Configured UI test target. Current pass/fail unproven. |

Configured packages from `Package.swift`:

| Product | Path | Implementation Truth |
|---|---|---|
| `AmbitionsDesignSystem` | `Sources` | Source-present shared design system package. |
| `AmbitionsWidgetUI` | `AppUI/Sources` | Source-present widget UI package depending on `AmbitionsDesignSystem`. |

Target/package configuration does not prove:

- app builds
- tests pass
- extensions run on device
- widgets render correctly
- Live Activity behavior works
- share extension imports data correctly
- App Store signing/export works

---

## 8. Domain and Data Model Status

Source evidence includes broad domain/model areas:

```text
Native/Ambitions/Domain/
Native/Ambitions/Domain/GoalEngine/
Native/Ambitions/Domain/Planning/
Native/Ambitions/Domain/Reschedule/
Native/Ambitions/Persistence/SwiftDataModels.swift
Native/Ambitions/Persistence/SwiftDataStore.swift
```

SwiftData persisted records are source-present for:

- goals
- goal drafts
- goal plans
- plan sections
- steps
- progress evidence
- feedback events
- captures
- teaching signals
- event ledger
- app state

Implementation truth:

- Domain model source is extensive.
- Persistence records exist for key product objects.
- Repositories are wired through `AppContainerFactory`.
- Some domain areas may be model/scaffold-heavy rather than complete behavior.
- Mature local intelligence, personalization, recommendation, proof transfer, and recovery loops are not proven merely by model presence.

Do not claim:

- the full external-brain graph is complete
- personalization is mature
- local learning is complete
- deterministic recommendation is complete
- all domain models are used live
- every domain object is persisted safely
- all migrations are validated

unless current source and proof establish those claims.

---

## 9. Persistence and Local-First Status

Source evidence:

```text
Native/Ambitions/App/AppContainerFactory.swift
Native/Ambitions/Persistence/SwiftDataStore.swift
Native/Ambitions/Persistence/SwiftDataModels.swift
Native/Ambitions/Support/Ambitions.entitlements
Native/Ambitions/Resources/PrivacyInfo.xcprivacy
```

Implementation truth:

- SwiftData persistence source exists.
- `AmbitionsPersistenceStore` creates a SwiftData `ModelContainer`.
- Store supports persistent and in-memory modes.
- Live configuration uses persistent mode.
- Preview/demo configuration can use in-memory mode.
- Repositories are built from `SwiftData*Repository` types in `AppContainerFactory`.
- Unit-of-work transaction receipt source exists.
- App Group entitlement exists.

Local-first truth:

- The inspected app source supports a local-first/on-device-first posture.
- No active custom hosted personal-data backend implementation was found in inspected app source.
- No active core external LLM implementation was found in inspected app source.

Unproven:

- migration safety
- corruption recovery
- backup/restore
- data deletion/export UX
- long-running data integrity
- physical-device persistence behavior
- App Group data behavior across extensions
- legal/privacy correctness

---

## 10. Apple Sync Status

Product truth allows Apple account/iCloud-style sync as a future user-owned, Apple-native, privacy-preserving exception.

Implementation evidence found:

```text
Native/Ambitions/Support/Ambitions.entitlements
```

Current source truth:

- The inspected app entitlement file contains App Group entitlement.
- No active iCloud/CloudKit entitlement was found in the inspected entitlement file.
- No active CloudKit/iCloud sync source implementation was found during inspected source search.
- Apple sync is not implemented or validated as current repo truth.

Allowed wording:

```text
Apple-native sync is an allowed future architecture exception.
```

Forbidden wording:

```text
iCloud sync is implemented.
CloudKit sync is working.
User data syncs across devices.
Sync is validated.
```

unless future source and proof establish those claims.

---

## 11. Cloudflare R2 Freshness Status

Product truth allows Cloudflare R2 only as a read-only external source for public, non-user-personal freshness/reference packs, such as:

- public dates
- public rules
- public deadlines
- public regulations
- templates
- public requirements
- non-personal metadata

Current source truth:

- No active app-source Cloudflare R2 implementation was found during inspected source search.
- No active app-source R2 fetch/client/cache/privacy boundary was found.
- R2 freshness is allowed by product architecture but currently unimplemented/unproven.

Hard boundary:

- R2 must never become a user-private life-data backend.
- Goals, captures, calendar context, schedule assumptions, proof, receipts, closure history, behavioral patterns, inferred priorities, profile, or personal context must not be uploaded to R2.
- Any future R2 request must be anonymous/non-personal or blocked.

Forbidden wording:

```text
R2 freshness is implemented.
R2 updates dates/rules in the app.
R2 is validated.
Freshness packs are production-ready.
```

unless future source and proof establish those claims.

---

## 12. External/Cloud LLM Status

Product truth:

- External/cloud LLMs are excluded from the core product architecture.
- Core intelligence must be local-first, deterministic, inspectable, and expressed through product behavior.
- Optional future AI/cloud/extension behavior must remain outside core product truth unless explicitly scoped later.

Current source truth:

- No active app-source OpenAI/API/cloud LLM implementation was found during inspected source search.
- Existing `.codex`, docs, prompts, or agent materials may mention AI/Codex, but those are not app runtime dependencies.
- `.agents` provider/backend skill material is not core app architecture.

Codex must not add:

- external LLM dependency
- OpenAI/API dependency
- cloud model calls
- chatbot-first UI
- opaque model confidence
- server-side user profiling
- hosted personal-data intelligence

unless the user explicitly scopes a non-core optional extension and the truth files are updated first.

---

## 13. Surface Implementation Status

### Today

Evidence:

```text
Native/Ambitions/App/AmbitionsRootView.swift
Native/Ambitions/Features/Today/TodayScreen.swift
Native/Ambitions/Features/Today/
```

Source-present implementation:

- Today tab/surface is wired.
- Today screen source exists.
- Loading/failed/loaded states exist.
- Day rail source exists as `DayTimelineRail`.
- Start Here-like execution state appears in source/previews.
- Step detail sheet source exists.
- Action closure sheet source exists.
- Today can route to goal detail, quick capture, and Time/Plan.
- Preview fixtures exist for multiple Today states.

Compatibility/design debt:

- Product truth says active term is Reality Meridian, not DayTimelineRail.
- Product truth says Start Here Surface must not feel like a detached card.
- Current source still contains rail/hero naming and must be reviewed against final product design truth.
- Source presence does not prove final flagship interaction/visual quality.

Implementation truth:

```text
Today is source-present and wired, but not product-complete or release-proven.
```

### Goals

Evidence:

```text
Native/Ambitions/App/AmbitionsRootView.swift
Native/Ambitions/Features/Goals/GoalsScreen.swift
Native/Ambitions/Features/Goals/
```

Source-present implementation:

- Goals tab/surface is wired.
- Goals screen source exists.
- Goal creation route exists.
- Goal detail route exists.
- Goal Mission Control lanes source exists.
- Life path, life areas, north stars, one-step goals, bands, archive summary, horizon ladder, and atlas preview source elements exist.
- Goal creation success/clarification/blocked states appear in source.

Compatibility/design debt:

- Product truth says Goals should be equal-weight Constellation Atlas with Orbital Lens drill-down.
- Product truth rejects KPI dashboard/rings/ranked life scores.
- Current source terms such as Mission Control, board, portfolio, maturity, pressure must be reviewed for drift and generic-dashboard risk.

Implementation truth:

```text
Goals is source-present and wired, but the final Constellation Atlas/Orbital Lens product model is not proven complete.
```

### Capture

Evidence:

```text
Native/Ambitions/App/AmbitionsRootView.swift
Native/Ambitions/Features/Captures/CapturesScreen.swift
Native/Ambitions/Features/Captures/
```

Source-present implementation:

- Capture tab/surface is wired.
- Capture screen source exists.
- Bottom composer source exists.
- Route preview source exists.
- Capture grouping and placement actions exist.
- Quick capture and grow-into-goal paths exist in source.
- Capture receipt preview source exists.
- Capture status handling source exists.

Compatibility/design debt:

- Product truth says Capture top level should remain quiet and composer-led.
- Product truth says route reveal should happen after input.
- Product truth rejects default notes feed/inbox/category grid.
- Current source includes ScrollView/grouped captures/actions, so it must be reviewed for top-level feed/inbox drift.

Implementation truth:

```text
Capture is source-present and wired, but final top-level Capture minimalism is not proven complete.
```

### Time / Plan

Evidence:

```text
Native/Ambitions/App/AmbitionsRootView.swift
Native/Ambitions/App/AppTab.swift
Native/Ambitions/Features/Plan/PlanScreen.swift
Native/Ambitions/Features/Plan/
```

Source-present implementation:

- User-facing tab title is `Time` through `AppTab.plan.title`.
- Navigation scaffold title is `Time`.
- Internal route/source names remain `plan`.
- `PlanScreen` source exists.
- Time/Plan source includes capacity envelope, pressure, recovery, Life Suite, lifecycle rail, timeline strip, pressure scrubber, relationship card, secondary destinations, elastic week, believability, calendar awareness, opportunity windows, decision debt, conflict court, boundary contracts, reflow, recovery, receipts, resilience, shaping actions.

Compatibility/design debt:

- Product truth says final active top-level label is Time.
- Product truth says Plan may appear only as contextual action/copy, not tab.
- Product truth says Time primary object is LifeShape Field, not calendar grid or generic planning dashboard.
- Current source still uses `PlanScreen`, `Plan*`, `plan.screen`, and many Plan identifiers.
- UI tests still contain `Plan` tab expectations, creating likely test/source naming drift.

Implementation truth:

```text
Time is user-facing source-present through Plan compatibility code. The final Time/LifeShape Field implementation is not proven complete.
```

### You / Profile

Evidence:

```text
Native/Ambitions/App/AmbitionsRootView.swift
Native/Ambitions/App/AppTab.swift
Native/Ambitions/Features/Profile/ProfileScreen.swift
Native/Ambitions/Features/Profile/
```

Source-present implementation:

- User-facing tab title is `You`.
- Internal route/source names remain `profile`.
- `ProfileScreen` source exists.
- Source includes profile/defaults, personalization, appearance, memory controls, trust center, receipts history, corrections, reviews, proof, schedule availability, plan behavior, automation trust, vacation/away time, durations, notifications, integrations/widgets/export/accessibility/support/about areas.
- Appearance preference and accent family are saveable through Profile/You source.

Compatibility/design debt:

- Product truth says active object is User System Profile, not Profile.
- Product truth says You is system control, not social profile/admin/AI settings wall.
- Current source uses Profile terminology and must be migrated carefully.
- Product truth says top-level You should be iOS Settings-like, static profile header, no search/family/social profile framing.

Implementation truth:

```text
You is source-present and wired through Profile compatibility code. Final User System Profile product model is not proven complete.
```

---

## 14. Core Object Implementation Status

| Object / System | Current Implementation Truth | Evidence |
|---|---|---|
| Reality Meridian | Product truth object exists as direction. Source still uses `DayTimelineRail`. | `PRODUCT_DESIGN_TRUTH.md`, `TodayScreen.swift` |
| Start Here Surface | Start Here-related source/previews exist; final non-card integrated surface not proven. | `TodayScreen.swift` |
| Constellation Atlas | Product truth object exists as direction. Source has Goals atlas preview/life areas/north stars but not proven final atlas. | `PRODUCT_DESIGN_TRUTH.md`, `GoalsScreen.swift` |
| Atmosphere Composer | Capture composer source exists. Final ultra-minimal top-level behavior not proven. | `CapturesScreen.swift` |
| LifeShape Field | Product truth object exists as direction. Source has Plan/Time capacity/pressure modules; final LifeShape Field not proven. | `PRODUCT_DESIGN_TRUTH.md`, `PlanScreen.swift` |
| User System Profile | Product truth object exists as direction. Source has Profile/You controls; final system profile not proven. | `PRODUCT_DESIGN_TRUTH.md`, `ProfileScreen.swift` |
| Receipts | Event ledger/proof/capture receipt/trust UI source exists. Full lifecycle unproven. | `SwiftDataModels.swift`, `TodayScreen.swift`, `CapturesScreen.swift`, `ProfileScreen.swift` |
| Action Closure | Today closure sheet and domain models source exist. Full cross-surface closure system unproven. | `TodayScreen.swift`, `Native/Ambitions/Domain/ActionClosureReceiptModels.swift` |
| Proof | Progress evidence record and proof/trust UI source exists. Proof transfer/review lifecycle unproven. | `SwiftDataModels.swift`, `ProfileScreen.swift` |
| Personal Context / Memory | Profile memory controls and event/teaching/app state records exist. Mature local learning unproven. | `SwiftDataModels.swift`, `ProfileScreen.swift` |
| Recommendation / Start Here | Today service and recommendation-related domain source exists. Mature deterministic recommendation unproven. | `TodayScreen.swift`, `Native/Ambitions/Domain/RecommendationExplanationModels.swift` |

---

## 15. Frontend Primitive / Design System Status

Evidence:

```text
Package.swift
Sources/Theme/AmbitionTheme.swift
Sources/
AppUI/Sources/
Native/Ambitions/UI/
Native/Ambitions/Features/*/#Preview blocks
```

Implementation truth:

- `AmbitionsDesignSystem` package exists.
- Theme tokens exist for dark/light mode, accent families, semantic colors, shell tokens, typography, spacing, radius, materials, motion, haptics, and panel/tap-target tokens.
- Widget UI package exists.
- SwiftUI previews exist in several surface files.
- Reusable primitive source exists.

Unproven:

- final visual quality
- screenshot parity with Product Design Truth
- snapshot testing
- device rendering
- Dynamic Type behavior across full app
- Reduce Motion equivalence
- VoiceOver equivalence
- performance under real data
- non-generic flagship quality

Source-present design system is not the same as flagship visual completion.

---

## 16. Widget / Live Activity / Extension Status

Evidence:

```text
project.yml
Native/AmbitionsWidgetExtension/
Native/AmbitionsShareExtension/
Native/Ambitions/ExternalSnapshots/
AppUI/Sources/
```

Implementation truth:

- Widget extension target is configured.
- Share extension target is configured.
- External snapshot source exists.
- ActivityKit-related `NextStepActivityAttributes` source appears in tracked source inventory.
- Widget UI package source exists.
- App Group entitlement exists.

Unproven:

- widget rendering on simulator/device
- widget refresh behavior
- App Group data handoff correctness
- Live Activity start/update/end behavior
- Dynamic Island/Lock Screen behavior
- share extension runtime import behavior
- App Intent / Shortcuts device behavior
- notification routing behavior on device

Do not claim external surfaces are working or device-validated without proof.

---

## 17. Tests and Validation Assets

Evidence:

```text
project.yml
Native/AmbitionsTests/
Native/AmbitionsUITests/AmbitionsUITests.swift
docs/native-build-and-release.md
```

Implementation truth:

- Unit test target is configured.
- UI test target is configured.
- Unit test source exists.
- UI test source exists.
- UI tests cover preview/demo flows, onboarding, shell, goals, capture, Today, Plan/Time, You/Profile, command sheet, memory lens, goal detail, and Plan modules.
- Current pass/fail is unproven.
- UI tests include stale or compatibility naming risk: they expect `Plan` tab buttons in places while app source maps the plan tab title to `Time`.

Testing truth must always separate:

```text
target exists
test source exists
test command exists
test was run
test passed
test failed
test skipped
test unavailable
```

---

## 18. Build and Script Assets

Evidence:

```text
scripts/build-local.sh
scripts/setup_macos_ios_dev.sh
docs/native-build-and-release.md
```

Implementation truth:

- `scripts/build-local.sh` exists.
- It generates `Ambitions.xcodeproj`.
- It chooses an available iPhone simulator.
- It runs `xcodebuild` with code signing disabled.
- It writes logs under `output/logs`.
- It uses `xcbeautify` when available.
- `scripts/setup_macos_ios_dev.sh` exists.
- It checks macOS/Xcode/Homebrew.
- It installs/verifies XcodeGen and optional local tooling.
- It regenerates project and verifies project discovery.

Unproven:

- scripts currently execute successfully
- local machine has required toolchain
- current build succeeds
- generated project is clean
- package resolution succeeds
- current logs exist

---

## 19. CI / Workflow Assets

Evidence:

```text
docs/status/release-evidence-packet.md
docs/native-build-and-release.md
docs/status/repo-cleanup-index.md
docs/audits/tracked-files.txt
```

Inspection result:

- Existing release/status docs say there is no active hosted CI workflow.
- `docs/audits/tracked-files.txt` was regenerated from `git ls-files` on 2026-05-10 and does not list `.github/workflows/ios-validate.yml`.
- Repo code search for workflow markers did not find active workflow evidence.

Implementation truth:

```text
No active hosted CI workflow was found in the inspected repo state.
```

Current inventory evidence:

```text
docs/audits/tracked-files.txt
```

is a regenerated tracked-file inventory for repo-hygiene lookup. It is not CI
proof, implementation proof, or release proof.

Forbidden claim:

```text
CI is configured.
CI is passing.
GitHub Actions validates the app.
```

unless a current workflow file and current run evidence exist.

---

## 20. Known Compatibility Debt

| Debt | Evidence | Risk |
|---|---|---|
| Plan vs Time | `AppTab.plan.title` returns `Time`, but internal files/routes/tests still use Plan. | UI tests/docs/source can drift; blind rename may break routing. |
| Profile vs You | User-facing title is You, internal files/routes still Profile. | Product language drift if Profile leaks into UI/docs. |
| Captures vs Capture | User-facing title is Capture, internal enum/path uses captures/Captures. | Mostly source compatibility debt. |
| DayTimelineRail vs Reality Meridian | Today source uses `DayTimelineRail`; Product Truth says Reality Meridian. | Product identity drift. |
| Hero Step Panel / Start Here | Old terms may persist in source/previews/docs. | Detached-card/generic AI suggestion risk. |
| Mission Control / board / KPI language | Goals source/docs use mission-control/board/maturity/pressure terms. | Dashboard drift risk against Product Truth. |
| Provider/backend assumptions | Provider skill roots are absent from active paths and forbidden by skill governance. | Hosted backend/provider drift risk if stale docs are reused. |
| Hosted workflow assumptions | `.github/` is absent; workflow templates are examples only. | False CI proof risk if example files are treated as active. |

Compatibility rule:

- Source compatibility names may remain temporarily when renaming would be unsafe.
- User-facing UI, active docs, and new implementation should follow `PRODUCT_DESIGN_TRUTH.md`.
- Any source rename must include tests, route migration, and rollback plan.

---

## 21. Known Naming Drift

Active product/design names from `PRODUCT_DESIGN_TRUTH.md`:

```text
Today
Goals
Capture
Time
You
Reality Meridian
Start Here Surface
Recommended step
LifeShape Field
User System Profile
Trust Seam
Receipt Surface
Quiet Reflow
Still Counts
Needs a Place
Ready to Place
Grow into Goal
```

Current source/internal compatibility names found:

```text
plan
PlanScreen
PlanRouteTarget
plan.screen
ProfileScreen
profile
captures
DayTimelineRail
HeroStep
GoalMissionControl
Mission Control
Insights
Habits
```

Implementation truth:

- Naming drift exists.
- Naming drift is not automatically a defect if it is internal compatibility debt.
- Naming drift becomes a defect when it leaks into active user-facing UI, active truth docs, new implementation plans, tests that block current truth, or Codex prompts.

---

## 22. Known Obsolete or Conflicting Areas

Areas requiring historical policy review:

```text
docs/canon/Ambitions_2_0*
docs/canon/Ambitions_3_0*
docs/canon/Ambitions_4_0*
docs/codex/batches/*
docs/audits/*
docs/handoff/*
.codex/skills/*
.agents/skills/supabase*
.agents/skills/supabase-postgres-best-practices/*
docs/status/current-implementation-map.md
docs/status/release-evidence-packet.md
docs/status/repo-cleanup-index.md
```

Current truth:

- These areas may contain useful history and traceability.
- They are not active product/design truth when conflicting with `PRODUCT_DESIGN_TRUTH.md`.
- They are not implementation truth when conflicting with live source.
- They are not release truth when lacking current validation proof.
- Provider/backend skills conflict with local-only core unless explicitly quarantined as non-core historical/developer material.

No deletion should happen until `HISTORICAL_POLICY.md` is applied in a dedicated cleanup pass.

---

## 23. Product Design Gap Map

| Product Truth Area | Current Source Evidence | Gap |
|---|---|---|
| Final IA Today/Goals/Capture/Time/You | Source maps user titles to Today/Goals/Capture/Time/You. | Internal Plan/Profile/Captures names remain. UI tests still expect Plan in places. |
| Today / Reality Meridian | Today source uses `DayTimelineRail` and rail identifiers. | Rename/concept migration to Reality Meridian not complete. |
| Start Here Surface | Today source includes Start Here-like hero/step detail. | Final seamless non-card integrated Start Here Surface not proven. |
| Goals / Constellation Atlas | Goals source includes mission-control/life-area/north-star/atlas preview parts. | Equal-weight Constellation Atlas and Orbital Lens are not proven final. |
| Capture / Atmosphere Composer | Capture source has bottom composer and route preview. | Top-level still has scroll/grouped captures; may violate quiet composer-first design. |
| Time / LifeShape Field | Plan source has capacity/pressure/reflow modules. | Final LifeShape Field as dominant primary object not proven; Plan naming remains. |
| You / User System Profile | Profile source has trust/memory/settings-like controls. | User System Profile naming/static top-level/iOS Settings-like final model not proven. |
| Local-only intelligence | SwiftData + local services source exist; no LLM source found. | Mature deterministic intelligence/local learning not proven. |
| Apple sync exception | No active sync source found. | Allowed future, not implemented. |
| R2 freshness exception | No active R2 source found. | Allowed future, not implemented. |
| Trust/receipts/proof | Event ledger, progress evidence, trust UI source exist. | Full lifecycle and validation unproven. |
| Accessibility | Labels/identifiers/reduce-motion code/previews exist. | Manual accessibility conformance unproven. |
| Performance | Theme/motion source exists. | Profiling and performance budgets unproven. |
| Anti-generic UI | Custom primitives and surfaces exist. | Actual flagship quality must be visually reviewed; source alone cannot prove it. |

---

## 24. What Is Not Implemented

The following are not implemented or not found as active source evidence during this inspection:

- Apple/iCloud/CloudKit sync.
- Cloudflare R2 freshness client/cache/pack ingestion.
- Core external/cloud LLM integration.
- Custom hosted Ambitions account system.
- Custom hosted personal-data backend.
- Server-side user profiling.
- App Store/TestFlight signing pipeline.
- Active hosted CI workflow.
- Current release proof packet with build/test/device logs.
- Physical-device validation.
- Full manual accessibility validation.
- Performance profiling evidence.
- Final Reality Meridian terminology migration.
- Final LifeShape Field proof.
- Final Constellation Atlas/Orbital Lens proof.
- Final top-level Capture minimalism proof.
- Final User System Profile proof.
- Production legal/privacy signoff.
- Public support/privacy URL validation.
- Store screenshot proof.
- Mature local personalization proof.
- Complete R2/Apple sync/offline fallback validation.

If future source implements any of these, update this file with exact evidence paths and validation status.

---

## 25. What Is Unproven

The following may have source or plans but are unproven as working/complete:

- current `xcodegen generate`
- current package resolution
- current simulator build
- current unit test pass
- current UI test pass
- current archive sanity pass
- widget runtime behavior
- Live Activity runtime behavior
- share extension runtime behavior
- App Intent runtime behavior
- notification runtime behavior
- EventKit permission and data flow behavior
- App Group data handoff behavior
- SwiftData migration/backward compatibility
- reset/delete/export/import behavior
- offline behavior under real user data
- long-session app stability
- memory/launch/scroll performance
- accessibility conformance
- Dynamic Type layout quality
- VoiceOver semantic quality
- Reduce Motion equivalence
- visual QA/screenshot quality
- local learning correctness
- recommendation correctness
- proof/receipt lifecycle correctness
- privacy/legal readiness
- release readiness

Unproven does not mean absent. It means no current accepted evidence proves the claim.

---

## 26. Forbidden Implementation Claims

Codex must not claim any of the following unless current source and proof explicitly support the exact claim:

```text
implemented
complete
fully built
fully wired
production-ready
release-ready
App Store-ready
TestFlight-ready
device-verified
CI-proven
fully tested
fully accessible
performance-safe
privacy-approved
legally approved
signed archive ready
R2 implemented
iCloud sync implemented
CloudKit sync implemented
external surfaces validated
widgets validated
Live Activities validated
share extension validated
local learning complete
recommendation engine complete
external brain complete
life OS complete
PRODUCT_DESIGN_TRUTH fully implemented
```

Allowed conservative claims when backed by current source paths:

```text
source-present
configured
wired at source level
scaffolded
preview-backed
test target exists
local validation path exists
release proof absent
device proof absent
unproven
not found
historical
conflicting
```

---

## 27. Codex Rules for Updating This File

Codex must update this file when:

- source implementation state changes
- target/package configuration changes
- app architecture changes
- persistence/sync/provider posture changes
- R2 source is added
- Apple sync/iCloud source is added
- external/cloud LLM or backend source appears
- top-level IA/source wiring changes
- Plan/Profile/Captures naming debt changes
- tests are added/removed materially
- build scripts change
- CI/workflow posture changes
- stale docs are demoted or promoted
- release proof changes implementation status

Update requirements:

1. Cite exact source paths.
2. Separate source-present from validated.
3. Separate configured from working.
4. Separate product truth from implementation truth.
5. Separate implementation truth from release truth.
6. Record compatibility debt explicitly.
7. Record forbidden claims if new overclaim risk appears.
8. Do not delete historical files while updating this file unless a separate cleanup task is approved.
9. Do not make release claims here; link to `RELEASE_TRUTH.md`.
10. Do not use “done,” “complete,” or “ready” without evidence and scope.

Final rule:

```text
When evidence is missing, write “unproven” or “not found,” not “implemented.”
```
