# AMB-1810 Background Task Registration Proof

Status: Implemented Yellow / Ready For Review for this BackgroundTasks leaf
Date: 2026-07-05T19:50:00Z
Branch: `main`
Baseline main SHA: `7f0ad8e5d86ec1f58d988596fab3ed017b1e2577`
Commit SHA: artifact commit SHA is recorded in Linear after commit/push
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: no simulator app run, real background execution, expiration delivery, or physical-device procedure was run
Exit code(s): listed in Validation Run below
Artifact paths: this manifest and `docs/qa/evidence/2026-07-05-amb-1810-background-task-registration-proof/background-task-registration.json`
Parent: `AMB-1689` Parent Feature - Background Task Integration
Issue: `AMB-1810` Background Task Leaf - Allowed use-case and registration proof

## Scope

This leaf defines and wires the first allowed BackgroundTasks use case:

```text
com.ambitions.source-atlas.public-pack-refresh
```

The task is an app-refresh task for public/reference Source Atlas pack
freshness only. It is not a background planner, not a hidden automation engine,
not a private graph writer, and not a release/device proof claim.

## Allowed Use Cases

Allowed for this leaf:

- public/reference Source Atlas pack refresh;
- offline fallback to existing bundled or cached public packs;
- cache freshness metadata updates under `Core/LocalRuntimeOS/SourceAtlas`;
- cancellation/expiration flowing through the existing cancellation-aware
  Source Atlas lifecycle refresh service.

Not allowed for this leaf:

- changing goals, steps, schedules, captures, proof, receipts, or private user
  context;
- silently moving Steps or protected time;
- generating final plans, final schedules, or Step lists;
- uploading private graph data or private context;
- blocking local/offline core value when refresh fails.

## Source-Backed Path

| Step | Source evidence | AMB-1810 result |
| --- | --- | --- |
| Identifier allowlist | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackBackgroundRefreshTask.swift` keeps the single allowed identifier as `com.ambitions.source-atlas.public-pack-refresh`. | The background task route is Source Atlas public/reference only. |
| Plist configuration | `Native/Ambitions/Support/Info.plist` adds `BGTaskSchedulerPermittedIdentifiers` with the allowed identifier and `UIBackgroundModes` with `fetch`. | The app declares the permitted identifier required for the app-refresh registration path. |
| SwiftUI registration | `Native/Ambitions/App/AmbitionsRootScene.swift` registers `.backgroundTask(.appRefresh(SourceAtlasPublicPackBackgroundRefreshTaskIdentifier.publicPackRefresh))`. | The identifier is attached once to the app scene. |
| Handler route | `Native/Ambitions/App/AppBootstrapper.swift` handles the task by calling `sourceAtlasLifecycleRefreshService.refreshPublicSourceAtlasPacks` with `mode: .background`. | Background work routes to the existing LocalRuntimeOS Source Atlas owner. |
| Mutation boundary | `SourceAtlasPublicPackBackgroundRefreshTaskResolution` and `SourceAtlasPublicPackLifecycleRefreshResolution` keep `sentPrivateRuntimeContext`, `scheduledHiddenRuntimeMutation`, `generatedFinalPlan`, `generatedFinalSchedule`, and `generatedStepList` false. | The allowed task cannot claim private graph mutation authority. |
| Expiration/cancellation path | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackLifecycleRefreshServiceTests.swift` already covers cancelled lifecycle refresh returning `.cancelled` without blocking local planning or generating hidden mutations. | Expiration semantics are source-covered through task cancellation, but not device-proven. |

## Validation Run

Completed for this packet:

| Command | Exit code | Result |
| --- | ---: | --- |
| `plutil -lint Native/Ambitions/Support/Info.plist` | 0 | App plist parsed after BackgroundTasks keys were added. |
| `python3 -m json.tool docs/qa/evidence/2026-07-05-amb-1810-background-task-registration-proof/background-task-registration.json` | 0 | JSON evidence parsed. |
| `git diff --check` | 0 | Passed after source/config/evidence edits. |
| `swiftc -parse Native/Ambitions/App/AmbitionsRootScene.swift Native/Ambitions/App/AppBootstrapper.swift Native/AmbitionsTests/App/AppSourceAtlasLifecycleRefreshSchedulerTests.swift` | 0 | Swift parser accepted the app registration, handler, and focused source/plist assertions; no XCTest execution. |
| `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/App/AmbitionsRootScene.swift Native/Ambitions/App/AppBootstrapper.swift Native/Ambitions/Support/Info.plist Native/AmbitionsTests/App/AppSourceAtlasLifecycleRefreshSchedulerTests.swift docs/qa/evidence/2026-07-05-amb-1810-background-task-registration-proof/manifest.md docs/qa/evidence/2026-07-05-amb-1810-background-task-registration-proof/background-task-registration.json` | 0 | Unsupported completion/readiness claim scan passed. |
| `python3 scripts/source-atlas-no-private-graph-egress-audit.py` | 0 | Source Atlas no-private-graph egress audit passed. |
| `xcodegen generate` | 0 | Project regenerated. |
| `python3 scripts/ambitions-remediation-governance-check.py` | 0 | Passed; `changed_paths=6`, `production_swift_files=1423`, `overHardLineCapFiles=0`. |
| `python3 scripts/ambitions-quality-gate.py` | 0 | Passed; strict quality gates Green. |
| `python3 scripts/ambitions-architecture-inventory.py` | 0 | Passed; final-tree parity achieved. |
| `python3 scripts/ambitions-green-standard-audit.py` | 0 | Passed; no disallowed architecture-as-UI strings found in active primary UI source. |
| `python3 scripts/ambitions-vocabulary-drift-scan.py` | 0 | Passed; canonical active vocabulary present and ban terms absent. |
| `python3 scripts/ambitions-local-first-boundary-scan.py` | 0 | Passed; local-first/account/R2/hosted-AI boundary checks passed in active authority files. |
| `python3 scripts/source-atlas-boundary-audit.py` | 0 | Source Atlas boundary audit passed for 40 targets. |
| `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s` | 25 | Initial simulator preflight failed because active Xcode processes were blocking the check. |
| `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s --repair --kill-active-xcode` | 0 | Repaired by killing active Xcode processes; selected `iPhone 17 Pro Max` simulator `DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6` passed. |

## Validation Not Run

- Focused background-task XCTest execution, xcodebuild package resolution,
  xcodebuild build, xcodebuild test, build-for-testing, UI tests, simulator app
  launch, real BGTaskScheduler delivery, expiration delivery, physical-device
  procedure, Source Atlas production R2 fetch, privacy/legal review, release
  gate, and App Store validation were not run for AMB-1810 under the current
  user instruction authorizing issue completion without testing until advised
  otherwise.

## Non-Claims

- No real background execution proof.
- No real expiration delivery proof.
- No physical-device proof.
- No Source Atlas production readiness.
- No R2 production readiness.
- No privacy/legal approval.
- No TestFlight, App Store, Release Green, device readiness, or product
  completion claim.
- `AMB-1689` remains In Progress because device behavior, scheduling cadence,
  retry/backoff policy, and broader background-task acceptance remain outside
  this leaf.

## Apple Platform Notes

- Apple Platform Source Atlas section consulted:
  `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md` section 11,
  BackgroundTasks Atlas.
- Apple APIs/frameworks/patterns used: SwiftUI `Scene.backgroundTask` with
  `.appRefresh`, `BGTaskSchedulerPermittedIdentifiers`, and `UIBackgroundModes`
  `fetch`.
- iOS availability: app deployment target is iOS 26.0; no additional
  availability gate is needed for this scoped path.
- Permission/privacy impact: no user permission prompt is added; no private
  life graph, goals, captures, schedules, receipts, proof, behavior, or inferred
  priorities are sent to Source Atlas/R2.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `App`, `Core/LocalRuntimeOS/SourceAtlas`,
  `Native/AmbitionsTests`, app Info.plist, and QA evidence.
- Files moved or created: this manifest and a paired JSON evidence file.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture/proof debt remains: yes. Device background execution and
  parent retry/backoff/cadence proof remain open.
- Next repair train if debt remains: continue `AMB-1689` leaves for real
  background-device proof and broader background task policy.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.

## Rollback

Revert this evidence folder plus the `Info.plist`, `AmbitionsRootScene`,
`AppBootstrapper`, and focused test changes. Move `AMB-1810` back to
`Ready For Codex` or `Needs Repair` if the app-refresh identifier is no longer
registered and routed to the LocalRuntimeOS Source Atlas refresh service.
