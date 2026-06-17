# IMPLEMENTATION_TRUTH.md

Status: Active implementation/source truth  
Scope: Actual repo/source implementation status, scaffold status, compatibility debt, missing implementation, and forbidden implementation claims  
Applies to: Ambitions native iPhone repo  
Owner posture: Source truth, not product vision and not release proof  
Effective rule: Live source, project files, scripts, tests, and current proof evidence win over plans, historical docs, old canon, handoffs, batch-train docs, prompts, and aspirational reports.

This file does not define what Ambitions should become. That authority belongs to `docs/truth/PRODUCT_DESIGN_TRUTH.md`.

This file does not define release readiness. That authority belongs to `docs/truth/RELEASE_TRUTH.md`.

---

## 1. Purpose and Authority

This file answers:

- what exists in the repo now
- what is source-present
- what is wired
- what is scaffolded
- what is missing
- what is obsolete or conflicting
- what is compatibility debt
- what is unproven
- what Codex must not claim as implemented

A feature is not implemented because it appears in a plan, canon document, batch document, audit, handoff, prompt, skill, README, or future roadmap. A feature is implementation truth only when live repo source/project/test/script evidence supports that state.

---

## 2. Relationship to Other Truth Files

Truth hierarchy for implementation work:

1. `docs/truth/PRODUCT_DESIGN_TRUTH.md` defines product/design direction. It does not prove implementation.
2. `docs/truth/IMPLEMENTATION_TRUTH.md` defines actual repo/source status.
3. `docs/truth/RELEASE_TRUTH.md` defines validation and release proof.
4. `docs/truth/CODEX_PROCESS_TRUTH.md` defines Codex inspection, patch, validation, repair, and report behavior.
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
- Swift package manifests
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
| Compatibility debt | Source remains for routing/migration/history but is not current product truth. |

---

## 4. Repository Snapshot

Current repo posture from inspected evidence:

- Native iOS app source exists under `Native/Ambitions/`.
- Xcode project is generated from `project.yml`.
- The checked-in package manifest defines shared Swift packages.
- The app is SwiftUI-first.
- The configured deployment target is iOS 26.0.
- The configured Swift language version is 6.0.
- The repo has source for app, widget extension, share extension, unit tests, UI tests, design system package, widget UI package, scripts, and substantial docs/Codex material.
- The app has local SwiftData persistence source.
- The app has App Group entitlement source.
- The app has a privacy manifest source.
- The repo has local build/setup scripts.
- No active release proof proves TestFlight/App Store/device readiness.
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
Native/Ambitions/App/AmbitionsApp.swift
Native/Ambitions/App/AmbitionsRootView.swift
Native/Ambitions/App/AppTab.swift
Native/Ambitions/App/AppBootstrapper.swift
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
scripts/build-local.sh
scripts/setup_macos_ios_dev.sh
```

---

## 5. Current Product/Source Alignment

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

- `Motion` source is now compatibility/migration debt unless it is being reused as `Stage/Motion` behavior infrastructure.
- `Capture` source and composer logic may be reused as global Capture infrastructure, but not as a top-level tab contract.
- `Plan` may exist as compatibility code for Time behavior, but not as a root surface.
- `Profile` may exist as compatibility code for You behavior, but not as a root surface.
- `Pulse` may appear as historical/proof primitive naming only, not as a current tab or surface.

Hard implementation truth:

```text
If current source routes to Motion as a canonical root tab, that is product drift.
If current source routes to Capture as a canonical root tab, that is product drift.
If tests require Motion as a root tab, those tests are stale and must be migrated.
If scripts validate Today / Goals / Time / Motion / You as active IA, those scripts are stale and must be migrated.
```

---

## 6. Native iPhone / Xcode / Project Structure

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

Unproven unless current logs exist:

- current project generation success
- current package resolution success
- current local simulator build success
- current archive success
- current device install behavior

Required proof before claiming build success:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
```

with current logs, exit codes, branch, and commit SHA.

---

## 7. Domain and Persistence Status

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

## 8. Local-First, Account, R2, and AI Status

### Local persistence

Source truth:

- SwiftData persistence source exists.
- `AmbitionsPersistenceStore` creates a SwiftData `ModelContainer`.
- Store supports persistent and in-memory modes.
- Live configuration uses persistent mode.
- Preview/demo configuration can use in-memory mode.
- Repositories are built from `SwiftData*Repository` types in `AppContainerFactory`.
- Unit-of-work transaction receipt source exists.
- App Group entitlement exists.

Unproven:

- migration safety
- corruption recovery
- backup/restore
- data deletion/export UX
- long-running data integrity
- physical-device persistence behavior
- App Group data behavior across extensions
- legal/privacy correctness

### Ambitions Account

Product truth requires custom Ambitions Accounts at launch using Sign in with Apple and Google Sign-In for optional identity/entitlement/R2 reference-pack access.

Current source truth:

```text
Unproven until source and logs prove otherwise.
```

Do not claim:

- Ambitions Account is implemented
- Sign in with Apple works
- Google Sign-In works
- account recovery works
- account entitlements work
- account-gated R2 access works

unless current source and proof establish those claims.

### R2 / Source Atlas

Product truth makes R2 first-class for Source Atlas/reference freshness.

Current source truth:

- Source Atlas model source exists in the repo.
- No release proof currently validates R2 fetch, cache, entitlement gating, pack verification, or privacy boundary.

Hard boundary:

- R2 must never become a private life graph backend.
- R2 requests must not include private user context.
- Goals, captures, calendar context, schedule assumptions, proof, receipts, closure history, behavior patterns, inferred priorities, profile, or personal context must not be uploaded to R2.

Do not claim:

- R2 freshness is implemented
- R2 updates dates/rules in the app
- Source Atlas packs are production-ready
- R2 entitlement gating is validated
- R2 privacy boundary is validated

unless current source and proof establish those claims.

### External/cloud LLM status

Product truth excludes external/cloud LLMs, hosted AI services, and cloud model APIs from core architecture.

Current source truth:

- No active app-source OpenAI/API/cloud LLM implementation is treated as core architecture by active truth.
- Existing `.codex`, docs, prompts, or agent materials may mention AI/Codex, but those are not app runtime dependencies.

Codex must not add external LLM dependency, cloud model calls, chatbot-first UI, opaque model confidence, server-side user profiling, or hosted personal-data intelligence unless truth files are updated first.

---

## 9. Surface Implementation Status

### Today

Source-present evidence:

```text
Native/Ambitions/App/AmbitionsRootView.swift
Native/Ambitions/Features/Today/TodayScreen.swift
Native/Ambitions/Features/Today/
```

Implementation truth:

- Today source exists and is wired in current app source.
- Loading/failed/loaded states exist.
- Step detail and closure sheet source exist.
- Preview fixtures exist for multiple states.
- Product truth says Today is Reality Meridian + Start Here, not task list, calendar timeline, or detached card stack.
- Final live-time, mutation, accessibility, safe-area, and flagship visual behavior remain unproven unless current proof exists.

### Goals

Source-present evidence:

```text
Native/Ambitions/Features/Goals/GoalsScreen.swift
Native/Ambitions/Features/Goals/
```

Implementation truth:

- Goals source exists.
- Goal creation and detail source exist.
- Current source terms such as Mission Control, board, portfolio, maturity, pressure, or atlas preview may exist as compatibility/debt.
- Product truth says Goals should be Constellation Atlas with Life Areas, Goal Threads, Step chains, proof history, and no KPI/ranked-score/dashboard drift.
- Final Constellation Atlas/Orbital Lens behavior remains unproven unless current proof exists.

### Time

Source-present evidence:

```text
Native/Ambitions/Features/Time/TimeScreen.swift
Native/Ambitions/Features/Time/
Native/Ambitions/Features/Plan/   # compatibility/source debt where present
```

Implementation truth:

- User-facing Time source exists.
- Plan compatibility code may still exist.
- Product truth says Time is LifeShape Field, not calendar clone, agenda clone, free/busy grid, productivity score, or AI scheduling surface.
- Final Time/LifeShape Field implementation remains unproven unless current proof exists.

### You

Source-present evidence:

```text
Native/Ambitions/Features/You/YouScreen.swift
Native/Ambitions/Features/You/
```

Implementation truth:

- You source exists.
- Profile compatibility symbols may remain.
- Product truth says You is User System Profile, not social profile/admin/AI settings wall/generic settings dump.
- Final native settings/profile quality remains unproven unless current proof exists.

### Capture

Source-present evidence:

```text
Native/Ambitions/Features/Capture/CaptureScreen.swift
Native/Ambitions/Features/Capture/
```

Implementation truth:

- Capture source exists and is reusable as global composer infrastructure.
- Compatibility routes/shell modes may remain.
- Product truth says Capture is global Atmosphere Composer/Open Field, not root tab/inbox/feed/chatbot/category grid.
- Final keyboard-safe composer, attachments, mic/voice permission behavior, routing preview, and no-crash expansion remain unproven unless current proof exists.

### Motion

Source-present evidence may include:

```text
Native/Ambitions/Features/Motion/
Native/Ambitions/Features/Motion/MotionCurrentScreen.swift
Sources/Components/*ProofPulse*
```

Implementation truth:

- Motion source may exist, but Motion is not current product root IA.
- Motion code may be migrated or reused only as `Stage/Motion` behavior infrastructure.
- Tests or validators requiring Motion as root tab are stale and must migrate.
- Proof/pulse primitive names may remain source-present visual/proof infrastructure, not top-level Pulse/Motion product truth.

---

## 10. Core Object Implementation Status

| Object / System | Current Implementation Truth |
|---|---|
| Reality Meridian | Product truth object exists; source implementation/proof must be verified against current `Today` source. |
| Start Here | Source/previews may exist; final integrated non-card Start Here surface not proven by source presence. |
| Constellation Atlas | Product truth object exists; final Goals atlas behavior not proven by source presence. |
| Atmosphere Composer | Capture composer source exists; final global Capture behavior proof remains open. |
| LifeShape Field | Product truth object exists; final Time capacity object not proven by source presence. |
| User System Profile | Product truth object exists; final native You surface not proven by source presence. |
| Receipts | Event ledger/proof/capture receipt/trust UI source exists; full lifecycle unproven. |
| Action Closure | Today closure sheet and domain models source exist; full cross-surface closure system unproven. |
| Proof | Progress evidence and proof/trust source exist; proof transfer/review lifecycle unproven. |
| Personal Runtime | Profile/You controls and teaching/app state records exist; mature local learning unproven. |
| Recommendation / Start Here | Recommendation-related source exists; mature deterministic recommendation unproven. |
| Ambitions Account | Product truth requires launch account support; implementation unproven until source/proof exists. |
| R2 / Source Atlas | Product truth requires first-class reference freshness; implementation unproven until source/proof exists. |

---

## 11. Design System / Accessibility Status

Source-present evidence:

```text
Package.swift
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
- real-device rendering
- Dynamic Type behavior across full app
- Reduce Motion equivalence
- VoiceOver equivalence
- performance under real data
- non-generic flagship quality

Source-present design system is not the same as flagship visual completion.

---

## 12. Extension / Widget / App Intent Status

Configured/source-present areas may include:

- widget extension target
- share extension target
- external snapshot source
- ActivityKit-related attributes
- Widget UI package source
- App Group entitlement

Unproven unless current proof exists:

- widget rendering on simulator/device
- widget refresh behavior
- App Group data handoff correctness
- Live Activity start/update/end behavior
- Dynamic Island/Lock Screen behavior
- share extension runtime import behavior
- App Intent / Shortcuts device behavior
- notification routing behavior on device

Do not claim external surfaces work or are device-validated without proof.

---

## 13. Current Claim Boundaries

Allowed wording:

```text
The repo contains native SwiftUI iOS source.
The repo contains local persistence source.
The repo contains source for Today / Goals / Time / You and global Capture.
The repo contains Motion-related source that must be treated as compatibility/migration debt or Stage/Motion behavior infrastructure under current truth.
The repo contains product/account/R2/Source Atlas truth, but implementation proof must be verified separately.
```

Forbidden wording without current proof:

```text
Motion is a canonical top-level tab.
Capture is a canonical top-level tab.
Ambitions Account is implemented.
Sign in with Apple works.
Google Sign-In works.
R2 freshness works.
Source Atlas packs are production-ready.
iCloud/CloudKit sync works.
The app is release-ready.
The app is TestFlight-ready.
The app is App Store-ready.
The app is fully accessible.
The app is device-validated.
```

---

## 14. Required Update Triggers

Update this file whenever:

- app source migrates root IA
- Motion root source is removed, demoted, or transformed into Stage/Motion infrastructure
- Capture root compatibility is removed or migrated
- Ambitions Account source is added
- Sign in with Apple / Google Sign-In source is added
- R2/Source Atlas source is added
- iCloud/CloudKit sync source is added or removed
- privacy manifest/entitlements change
- release proof changes implementation claims
- validation proves or invalidates a source-status statement

Every update must preserve no-claim boundaries.
