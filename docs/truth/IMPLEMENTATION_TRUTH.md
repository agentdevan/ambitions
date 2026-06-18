# IMPLEMENTATION_TRUTH.md

Status: Active implementation/source truth  
Scope: Actual repo/source implementation status, scaffold status, compatibility debt, missing implementation, forbidden implementation claims, and implementation no-claim boundaries  
Applies to: Ambitions native iPhone repo  
Owner posture: Source truth, not product vision and not release proof  
Effective rule: Live source, project files, scripts, tests, and current proof evidence win over plans, historical docs, old canon, handoffs, batch-train docs, prompts, and aspirational reports.

This file does not define what Ambitions should become. That authority belongs to `docs/truth/PRODUCT_DESIGN_TRUTH.md`.

This file does not define release readiness. That authority belongs to `docs/truth/RELEASE_TRUTH.md`.

---

## 1. Source Evidence Standard

Implementation evidence may come from current Swift source, project configuration, package manifests, resources, entitlements, privacy manifest, scripts, tests, current validation logs, checked-in current proof artifacts, and current repo tree evidence.

Implementation evidence may not come from old canon alone, batch-train prompts alone, handoff docs alone, audit reports alone, README claims alone, design truth alone, planning docs alone, generated reports without source/log backing, Codex memory, model inference, or expected behavior.

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
| Compatibility debt | Source remains for routing/migration/history but is not current product truth. |

---

## 2. Repository Snapshot

Current repo posture from inspected evidence:

- Native iOS app source exists under `Native/Ambitions/`.
- Xcode project is generated from `project.yml`.
- The checked-in package manifest defines shared Swift packages.
- The app is SwiftUI-first.
- The configured deployment target is iOS 26.0.
- The configured Swift language version is 6.0.
- The repo has source for app, widget extension, share extension, unit tests, UI tests, design system package, widget UI package, retained local scripts, and compact truth/build docs.
- The app has local SwiftData persistence source.
- The app has App Group entitlement source.
- The app has a privacy manifest source.
- The repo has local build/setup scripts.
- No active release proof proves TestFlight/App Store/device readiness.
- Old docs, generated proof, prompts, train material, and Codex control-plane files are not retained as implementation evidence.

Primary evidence paths:

```text
README.md
AGENTS.md
project.yml
Package.swift
docs/truth/PRODUCT_DESIGN_TRUTH.md
Native/Ambitions/App/AmbitionsApp.swift
Native/Ambitions/App/AmbitionsRootView.swift
Native/Ambitions/App/AppTab.swift
Native/Ambitions/App/AppContainerFactory.swift
Native/Ambitions/Persistence/SwiftDataStore.swift
Native/Ambitions/Persistence/SwiftDataModels.swift
Native/Ambitions/Features/Today/TodayScreen.swift
Native/Ambitions/Features/Goals/GoalsScreen.swift
Native/Ambitions/Features/Capture/CaptureScreen.swift
Native/Ambitions/Features/Time/TimeScreen.swift
Native/Ambitions/Features/You/YouScreen.swift
Native/Ambitions/Features/Motion/MotionCurrentScreen.swift
Native/Ambitions/Support/Ambitions.entitlements
Native/Ambitions/Resources/PrivacyInfo.xcprivacy
Native/AmbitionsUITests/AmbitionsUITests.swift
```

---

## 3. Current Product/Source Alignment

Active product/design truth from `PRODUCT_DESIGN_TRUTH.md` is:

```text
Persistent surfaces:
Today / Goals / Time / You

Global composer:
Capture

Cross-surface behavior layer:
Motion

Inspectable trust layer:
Proof / Source / Privacy / History / Receipts
```

Current source-state reality:

- Source may still contain `AppTab.motion`, Motion feature files, Motion tests, Motion screenshots, and Motion proof artifacts.
- Source may still contain `AppTab.capture`, Capture screen modes, capture navigation routes, capture inbox terms, or other compatibility paths.
- Source may still contain `Plan`, `Profile`, `Captures`, `Pulse`, `DayTimelineRail`, `GoalMissionControl`, and other prior compatibility names.
- These source facts do not override current product truth.

Implementation classification:

- Motion source is now compatibility debt unless reused as `Stage/Motion` behavior infrastructure.
- `Capture` source and composer logic may be reused as global Capture infrastructure, but not as a top-level tab contract.
- `Plan` may exist as compatibility code for Time behavior, but not as a root surface.
- `Profile` may exist as compatibility code for You behavior, but not as a root surface.
- `Pulse` may appear as historical/proof primitive naming only, not as a current tab or surface.

Hard implementation truth:

```text
If current source routes to Motion as a canonical root tab, that is product drift.
If current source routes to Capture as a canonical root tab, that is product drift.
If tests require Motion as a root tab, those tests are stale and must be migrated.
If scripts validate Motion as a root IA surface, those scripts are stale and must be migrated.
```

---

## 4. Native iPhone / Xcode / Project Structure

Implementation truth:

- The repo uses XcodeGen.
- `Ambitions.xcodeproj` is generated and should not be treated as checked-in source truth.
- The configured app platform is iOS.
- The deployment target in `project.yml` is iOS 26.0.
- Swift version in `project.yml` is 6.0.
- The app target is named `Ambitions`.
- Native app source is under `Native/Ambitions`.
- Resources are under `Native/Ambitions/Resources`.
- Entitlements are configured through source paths in `project.yml`.

Required proof before claiming build success:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
```

with current logs, exit codes, branch, and commit SHA.

---

## 5. Domain and Persistence Status

Source evidence includes broad domain/model areas:

```text
Native/Ambitions/Domain/
Native/Ambitions/Domain/GoalEngine/
Native/Ambitions/Domain/Planning/
Native/Ambitions/Domain/Reschedule/
Native/Ambitions/Persistence/SwiftDataModels.swift
Native/Ambitions/Persistence/SwiftDataStore.swift
```

SwiftData persisted records are source-present for goals, goal drafts, goal plans, plan sections, steps, progress evidence, feedback events, captures, teaching signals, event ledger, and app state.

Implementation truth:

- Domain model source is extensive.
- Persistence records exist for key product objects.
- Repositories are wired through `AppContainerFactory`.
- Some domain areas may be model/scaffold-heavy rather than complete behavior.
- Mature local intelligence, personalization, recommendation, proof transfer, and recovery loops are not proven merely by model presence.

Do not claim the full external-brain graph, personalization, local learning, deterministic recommendation, model usage, persistence safety, or migrations are complete unless current source and proof establish those claims.

---

## 6. Local-First, Account, R2, and AI Status

### Local persistence

Source truth:

- SwiftData persistence source exists.
- `AmbitionsPersistenceStore` creates a SwiftData `ModelContainer`.
- Store supports persistent and in-memory modes.
- Live configuration uses persistent mode.
- Repositories are built from `SwiftData*Repository` types in `AppContainerFactory`.
- Unit-of-work transaction receipt source exists.
- App Group entitlement exists.

Unproven: migration safety, corruption recovery, backup/restore, data deletion/export UX, long-running data integrity, physical-device persistence, App Group behavior across extensions, and legal/privacy correctness.

### Ambitions Account

Product truth requires custom Ambitions Accounts at launch using Sign in with Apple and Google Sign-In for optional identity, entitlement, and R2 reference-pack access.

The app must keep its offline core usable with no account. Ambitions Account source must not store or sync the private life graph unless future canon explicitly approves user-owned sync and current proof exists.

Current source truth:

```text
Unproven until source and logs prove otherwise.
```

Do not claim Ambitions Account, Sign in with Apple, Google Sign-In, account recovery, account entitlements, account-gated R2 access, or account private life graph behavior is implemented unless current source and proof establish those claims.

### R2 / Source Atlas

Product truth makes R2 first-class for Source Atlas/reference freshness.

Current source truth:

- Source Atlas model source exists in the repo.
- No release proof currently validates R2 fetch, cache, entitlement gating, pack verification, or privacy boundary.

Hard boundary:

- R2 is not a user-data backend.
- R2 must never become a private life graph backend.
- R2 requests must not include private user context.
- Goals, captures, calendar context, schedule assumptions, proof, receipts, closure history, behavior patterns, inferred priorities, profile, or personal context must not be uploaded to R2.

Do not claim R2 freshness, R2 production updates, Source Atlas pack readiness, R2 entitlement gating, or R2 privacy validation unless current source and proof establish those claims.

### External/cloud LLM status

Product truth excludes external/cloud LLMs, hosted AI services, and cloud model APIs from core architecture.

Hosted AI services and cloud LLMs are not core architecture and are excluded from Ambitions app runtime dependencies.

Current source truth:

- No active app-source OpenAI/API/cloud LLM implementation is treated as core architecture by active truth.
- Retained docs and skills may mention AI/Codex as local contributor tooling, but those are not app runtime dependencies.

Codex must not add external LLM dependency, cloud model calls, chatbot-first UI, opaque model confidence, server-side user profiling, or hosted personal-data intelligence unless truth files are updated first.

---

## 7. Surface Implementation Status

### Today

Source-present evidence: `Native/Ambitions/Features/Today/TodayScreen.swift` and `Native/Ambitions/Features/Today/`.

Implementation truth: Today source exists and is wired in current app source. Product truth says Today is Reality Meridian + Start Here, not task list, calendar timeline, or detached card stack. Final live-time, mutation, accessibility, safe-area, and flagship visual behavior remain unproven unless current proof exists.

### Goals

Source-present evidence: `Native/Ambitions/Features/Goals/GoalsScreen.swift` and `Native/Ambitions/Features/Goals/`.

Implementation truth: Goals source exists. Product truth says Goals should be Constellation Atlas with Life Areas, Goal Threads, Step chains, proof history, and no KPI/ranked-score/dashboard drift. Final Constellation Atlas behavior remains unproven unless current proof exists.

### Time

Source-present evidence: `Native/Ambitions/Features/Time/TimeScreen.swift` and `Native/Ambitions/Features/Time/`.

Implementation truth: Time source exists. Plan compatibility code may still exist. Product truth says Time is LifeShape Field, not calendar clone, agenda clone, free/busy grid, productivity score, or AI scheduling surface. Final LifeShape Field implementation remains unproven unless current proof exists.

### You

Source-present evidence: `Native/Ambitions/Features/You/YouScreen.swift` and `Native/Ambitions/Features/You/`.

Implementation truth: You source exists. Profile compatibility symbols may remain. Product truth says You is User System Profile, not social profile/admin/AI settings wall/generic settings dump. Final native settings/profile quality remains unproven unless current proof exists.

### Capture

Source-present evidence: `Native/Ambitions/Features/Capture/CaptureScreen.swift` and `Native/Ambitions/Features/Capture/`.

Implementation truth: Capture source exists. Capture may still be implemented through old route/screen assumptions. Product truth says Capture is global composer, not a root tab. Final global composer behavior remains unproven unless current proof exists.

### Motion

Source-present evidence: `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift` and `Native/Ambitions/Features/Motion/`.

Implementation truth: Motion source exists. Product truth says Motion is cross-surface behavior, not a root destination. Motion root/screen source is compatibility debt unless migrated into Stage/Motion behavior infrastructure. Final Stage/Motion behavior remains unproven unless current proof exists.

---

## 8. Implementation Hard Stops

Hard Red for implementation claims:

- claiming root IA is migrated before source/tests/scripts prove `Today / Goals / Time / You`
- claiming Motion is removed as root while source/tests still require Motion root
- claiming Capture is global-only while source/tests still require Capture root
- claiming Ambitions Account works without current auth/source/proof
- claiming R2 works without current fetch/cache/entitlement/privacy proof
- claiming hosted AI/cloud LLM is part of core runtime
- claiming offline core works if account/network becomes required
- claiming accessibility/performance/device/release readiness without current proof

This is implementation truth, not release proof.

---

## 9. Historical Proof Is Not Current Proof

Old batch reports, generated proof ledgers, screenshots, prompts, train closeouts, and deleted control-plane material are not implementation proof.

Current implementation claims require live source/project/test/script evidence and, where release-facing, current logs under `RELEASE_TRUTH.md`.
