# Permission Value Proof Pattern

Status: AMB-771 / PLOS-087 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane contract for proving user value before sensitive permission prompts or picker-like private-data exposure.

This artifact specializes AMB-702's Native Context Mesh contract into a reusable `PermissionValueProof` pattern. It is the gate that every permissioned native context adapter must satisfy before Ambitions asks for Calendar, Reminders, Health/Fitness, Location, Notifications, Files/Photos/OCR import, or future user-owned sync controls.

This is not app source implementation, Swift/domain implementation, runtime permission prompting, UI implementation, entitlement work, privacy manifest change, platform API integration, CloudKit transport, R2 publication, Source Atlas publication, screenshot proof, accessibility proof, device proof, measured performance proof, privacy/legal approval, release readiness, App Review readiness, AMB-616 parent completion, or full PLOS project completion.

## Existing Source Ownership

AMB-771 inspected these owners before adding this contract:

- `artifacts/personal-life-os/native-context/NATIVE_CONTEXT_MESH_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/CALENDAR_CONTEXT_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/REMINDERS_CONTEXT_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/HEALTH_FITNESS_CONTEXT_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/LOCATION_CONTEXT_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/FILES_PHOTOS_OCR_IMPORT_CONTEXT_PATHS.md`
- `artifacts/personal-life-os/native-context/CLOUDKIT_SYNC_STATE_CONTEXT_ADAPTER_CONTRACT.md`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/Ambitions/Services/RealityIntegrationAdapters.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Features/Time/TimeFeatureService.swift`

Existing source already has permission states, trust-center permission rows, calendar/reminders request surfaces, and local receipt/explanation patterns. AMB-771 does not change those sources. It defines the downstream contract future implementation must satisfy before those surfaces expand or request sensitive access.

## Core Rule

Ambitions must prove value before asking for sensitive access. A value proof is not a marketing prompt, onboarding upsell, AI permission grab, or generic disclosure. It is a local, inspectable pre-permission explanation that names:

1. the exact adapter and permission scope,
2. the user-visible benefit,
3. the specific Ambitions behavior that improves,
4. what will not happen,
5. the local/iCloud/R2 data boundary,
6. the fallback if the user denies, restricts, cancels, or revokes access,
7. the control/revocation path,
8. the receipt or explanation the user can inspect later,
9. any high-risk or sensitive-data limitations.

No system permission prompt, broad import picker, background source scan, write action, or sync-control enablement can occur until the value proof has been shown and the user has taken the next explicit action.

## PermissionValueProof

Required fields:

| Field | Requirement | Red stop |
|---|---|---|
| `proofId` | Stable local ID that does not embed private user data. | ID contains raw event titles, file names, health values, location, account identifiers, or private text. |
| `adapterId` | Owning native context adapter. | Proof is detached from a source owner or used as a generic permission prompt. |
| `sourceKind` | Calendar, reminders, health_fitness, location, files_photos_ocr_import, cloudkit_sync_state, notifications, focus_shortcuts, or future explicit source. | Source kind is missing or mislabeled as Source Atlas/R2/public content. |
| `permissionScope` | Exact platform/user action requested, such as calendar read, calendar write, reminders write, selected photo, coarse location, notification delivery, or sync enable. | Broad access is requested when a narrower scope exists. |
| `trigger` | User action that makes the proof relevant. | Proof appears as a default setup nag or permission wall before value is visible. |
| `benefit` | Plain-language user benefit tied to Ambitions' Personal Life OS model. | Copy says generic productivity, AI needs access, score/streak, or fear-of-missing-out. |
| `improves` | Specific local behaviors that may improve. | Claims broad runtime quality, source authority, release readiness, or guaranteed outcomes. |
| `doesNotDo` | Explicit blocked behaviors. | Omits privacy boundary, broad scan, upload, analytics, external model, or hidden mutation limits. |
| `dataBoundary` | Local-only, user-iCloud, explicit import, never-transmitted, or user-initiated export classification. | Private data is implied to enter R2, public Source Atlas, Linear, telemetry, support, or external prompts. |
| `fallback` | What remains useful if denied/restricted/canceled/revoked. | Denial blocks basic Ambitions value or creates shame/nagging. |
| `controls` | Where the user can revoke, pause, delete, reset, export, or review. | No control path exists before permission is requested. |
| `receiptPolicy` | Local receipt/explanation when permissioned context changes visible behavior. | Permissioned context silently mutates goals, Steps, schedule, learning, proof, sharing, or recovery. |
| `ledgerEvent` | Future `PermissionLedger` event emitted by showing/accepting/denying/revoking the proof. | Permission state is inferred with no ledger trail. |
| `sensitiveLimit` | High-risk, protected, health, location, file/photo/OCR, account, or sync restrictions. | Sensitive access can generate high-risk advice or public artifacts. |

## Proof Lifecycle

| State | Required behavior |
|---|---|
| `not_needed` | Adapter does not need sensitive permission for current path; do not show proof. |
| `eligible_to_explain` | User action makes a value proof relevant; show proof without triggering platform prompt. |
| `proof_shown` | User has seen local benefit, boundary, fallback, and controls. |
| `user_continues` | User explicitly chooses the permissioned action after proof. |
| `system_prompt_allowed` | Platform prompt or picker can appear only for the exact scope proven. |
| `granted` | Emit allowed slots only within proven scope and create ledger/receipt links. |
| `denied_or_canceled` | Keep Ambitions usable; clear or avoid permissioned slots; no nagging. |
| `restricted_or_unavailable` | Degrade to local/manual baseline and explain reduced precision. |
| `revoked` | Invalidate current permissioned influence and require fresh value proof before re-request. |
| `needs_review` | Hold permissioned influence until the user reviews scope, stale state, or conflict. |

## Adapter Proof Matrix

| Adapter/source | Proof trigger | Scope that can be requested | Proof must say | Fallback |
|---|---|---|---|---|
| Calendar read | User chooses Calendar-aware Time/plan fit. | Bounded read of busy windows/open-window derivation. | Ambitions derives availability locally and does not upload raw event details or become a calendar clone. | Baseline planning windows and manual Time Texture. |
| Calendar write | User confirms writing an Ambitions block. | Write user-confirmed Ambitions block only. | Ambitions writes only the confirmed block and does not read the calendar from write-only access. | Keep block local in Ambitions. |
| Reminders write | User chooses to create an Apple Reminder from a Step. | Write a user-confirmed reminder only. | Ambitions does not import the user's Reminders hierarchy as tasks. | Keep Step/reminder local. |
| Future Reminders read | Future issue explicitly owns read usefulness. | Narrow read summary after separate proof. | Existing reminder pressure is optional and not a task-list import. | No Reminders-derived pressure. |
| Health/Fitness | Future issue proves usefulness for a selected path. | Coarse local energy/recovery band only. | No medical advice, diagnosis, training plan, or precise health values. | Manual energy/recovery context or no adapter. |
| Location | User chooses a location-aware path where manual context is insufficient. | Coarse local place/travel-friction summary. | No precise tracking, background location, surveillance, or public proof. | Manual place/travel context or no adapter. |
| Files/Photos/OCR | User selects or shares private material. | Explicit selected item/picker/import surface only. | No library/folder/background scan, raw upload, Source Atlas/R2 publication, or external prompt. | Manual entry, Held Object, or source-needed scaffold. |
| CloudKit sync state/control | User chooses to review/enable/pause user-owned sync. | User-owned sync control state only after exact proof. | Local operation remains authoritative and sync is not release readiness. | Local-only operation with export/delete reminders. |
| Notifications | User chooses notification delivery for a local reminder. | Notification delivery permission only. | No engagement pressure, productivity scoring, or planning source. | In-app/local reminder fallback. |

## Copy Contract

Allowed proof copy must be:

- short, local-first, and specific to the user's current action
- written in Ambitions language: Start here, Recommended step, Start now, Open step, Step
- explicit that denial keeps Ambitions usable
- explicit about local/user-owned data boundaries
- explicit about controls and revocation
- calm and non-urgent

Forbidden proof copy includes:

- "AI needs access"
- "Unlock smarter productivity"
- "Don't miss out"
- "Connect everything to get the full experience"
- "Your calendar/tasks/photos make planning accurate"
- "Required to continue"
- "Improve your score/streak"
- any claim that private data goes to R2, Source Atlas, Ambitions servers, analytics, telemetry, support, external prompts, or public/share artifacts

## PermissionLedger Linkage

Future AMB-710 ledger work must be able to record at least these value-proof events:

- `value_proof_eligible`
- `value_proof_shown`
- `value_proof_dismissed`
- `value_proof_continued`
- `system_prompt_presented`
- `permission_granted`
- `permission_denied`
- `permission_restricted`
- `permission_canceled`
- `permission_revoked`
- `permission_unavailable`
- `permission_needs_review`
- `permission_scope_changed`
- `permissioned_influence_invalidated`

Ledger payloads must avoid raw private context. Allowed references are stable proof IDs, adapter IDs, source kind, scope, local receipt references, redacted state, and timestamps.

## Context-To-Path Influence Rules

Value proof may unlock only the influence described by the owning adapter. It does not itself authorize:

- source authority
- Source Atlas or R2 publication
- generated Step quality bypass
- high-risk approval
- schedule install commit
- cross-goal reflow mutation
- sharing eligibility
- learning updates from raw private data
- release, App Store, privacy/legal, device, accessibility, or performance readiness

Permissioned context that changes user-visible behavior must link to a receipt/explanation. If a permission is denied, restricted, canceled, revoked, stale, or unavailable, the runtime must use baseline/manual behavior without nagging or false precision.

## Privacy Boundary

Allowed local summaries:

- proof ID
- adapter ID
- source kind
- permission scope
- proof lifecycle state
- user action trigger
- local receipt/reference ID
- permission state category
- redacted fallback reason
- control/revocation link reference

Blocked raw material:

- raw calendar events, reminder bodies, health values, workouts, location trails, files, photos, OCR text, account identifiers, CloudKit record payloads, private source text, contacts, attendees, exact filenames, EXIF/GPS, private notes, local learning detail, or protected/sensitive inferred attributes

Forbidden destinations:

- R2 objects
- public Source Atlas packs, seeds, claims, requirements, manifests, release receipts, validation reports, or pathing data
- Linear private details
- support bundles without explicit user redaction/export action
- external prompts or hosted inference context
- analytics, telemetry, crash, or engagement payloads
- public/share/progress-story artifacts
- screenshots or visual proof containing private permissioned data

## Fixture Matrix

Future implementation/validator phases must cover at least:

- every permissioned adapter shows value proof before any system prompt
- not-needed adapters do not show proof or prompt by default
- proof copy names exact scope and fallback
- proof copy blocks AI-needs-access, score, streak, shame, and generic productivity language
- user dismissal keeps Ambitions usable and does not nag
- user continuation permits only the exact proven scope
- denied/restricted/canceled state keeps Start here, Step, Goal Detail, local closure, and recovery usable
- revoked permission invalidates current permissioned influence and requires fresh value proof before re-request
- stale proof degrades to needs-review before permissioned influence
- Calendar read and write proofs remain separate
- Reminders write and future read proofs remain separate
- Health/Fitness proof cannot claim medical/training guidance
- Location proof cannot request precise/background tracking by default
- Files/Photos/OCR proof cannot imply library/folder/background scan
- CloudKit sync proof cannot claim release readiness or account requirement
- notification proof cannot become engagement pressure
- value-proof ledger payload excludes raw private context
- fixture/test/generated permission states are not production runtime proof

## Red Conditions

- system permission prompt appears before value proof
- proof is shown as a setup wall instead of a relevant user action
- proof scope is broader than the action needs
- denial, restriction, cancellation, or revocation breaks core Ambitions value
- revoked or stale permissioned context remains current
- private permissioned data enters R2, Source Atlas, Linear, support, external prompts, analytics, telemetry, screenshots, public share, or progress artifacts
- value proof claims release, App Store, privacy/legal, accessibility, device, performance, M23, M26, or production readiness
- value proof uses shame, urgency, productivity scoring, streaks, or "AI needs this" language
- proof pattern bypasses Source Authority, Step Quality Firewall, high-risk safety, schedule preview/commit, or receipt requirements

## Downstream Consumers

- AMB-710 / PLOS-088 Permission ledger and revocation controls
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-621 / PLOS-M14 Step Elasticity Engine
- AMB-622 / PLOS-M15 Schedule Install Kernel
- AMB-623 / PLOS-M16 Life Consequence / Cross-Goal Reflow Engine
- AMB-625 / PLOS-M18 High-risk safety, legality, and jurisdiction
- AMB-628 / PLOS-M19 Performance Runtime hardening
- AMB-632 / PLOS-M23 CloudKit/iCloud sync hardening
- AMB-633 / PLOS-M24 Observability, support, diagnostics, and data export
- AMB-634 / PLOS-M25 App Review / compliance readiness
- AMB-635 / PLOS-M26 certification gauntlets

## Non-Claims

AMB-771 does not claim app source change, Swift/domain implementation, runtime permission flow implementation, PermissionLedger runtime implementation, UI implementation, entitlement change, privacy manifest change, EventKit/HealthKit/CoreLocation/Photos/Vision/CloudKit integration, CloudKit transport, user-data upload, user-data mutation, screenshot proof, accessibility proof, device proof, measured performance proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, App Review readiness, R2 write, Source Atlas publication, production certification, AMB-616 parent completion, or full PLOS project completion.
