# Native Context Mesh Adapter Contract

Status: AMB-702 / PLOS-080 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane model for privacy-safe native context consumption.

This artifact defines the future `NativeContextAdapter`, `ContextSlot`, and native context influence rules for M08. It turns iOS-native and user-owned context into explicit local signals that later phases can consume only after value proof, permission state checks, privacy classification, freshness checks, and revocation behavior are satisfied.

This is not Swift implementation, runtime adapter implementation, permission prompting, EventKit/HealthKit/CoreLocation/Photos/Vision/CloudKit integration, entitlement change, privacy manifest change, background ingestion, runtime path selection, generated Step behavior, UI implementation, accessibility proof, device proof, measured performance proof, privacy/legal approval, release readiness, App Review readiness, or M08 parent completion.

## Existing Source Ownership

AMB-702 inspected these existing owners before adding this contract:

- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/PERSONAL_LIFE_OS_RUNTIME_LAW.md`
- `artifacts/personal-life-os/reports/PLOS-020-local-data-cloud-boundary.md`
- `artifacts/personal-life-os/reports/PLOS-021-cloudkit-schema-constraints.md`
- `artifacts/personal-life-os/reports/PLOS-024-receipt-retention-delete-reset-export-policy.md`
- `artifacts/personal-life-os/reports/PLOS-025-r2-source-only-boundary-matrix.md`
- `artifacts/personal-life-os/any-goal/ANY_GOAL_OPERATING_MODE_MODEL.md`
- `artifacts/personal-life-os/any-goal/HIGH_RISK_GUARDED_ROUTING_CONTRACT.md`
- `Native/Ambitions/Services/RealityModelProjector.swift`
- `Native/Ambitions/Services/RealityIntegrationAdapters.swift`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/Ambitions/Features/Time/TimeCalendarAwarenessSupport.swift`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/Ambitions/Persistence/LifeContextPersistence.swift`
- `Native/Ambitions/Domain/LifeContextModels.swift`
- `Native/Ambitions/Services/ExternalCreationImportService.swift`
- `Native/Ambitions/Domain/SourceAtlasPDFImportBoundaryModels.swift`
- `Native/Ambitions/Domain/SourceAtlasVisionOCRFallbackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasURLSourceImporterModels.swift`
- `Native/AmbitionsTests/Domain/IOS26CalendarP0ContractHarnessTests.swift`
- `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`

These are ownership anchors and dependency inputs. They are not evidence that this contract is implemented in app runtime.

## Core Rule

Native context may improve local planning only as a bounded local signal. It must never become Source Atlas content, R2 content, a public pack, a Linear artifact containing private context, an Ambitions-owned backend profile, or a permission request without prior value proof.

Every adapter must pass this sequence before it can influence a path, Step graph, schedule install, or recommendation:

1. Prove user-visible value without requesting the permission.
2. Classify data as local-only, user-iCloud state, explicit user import, downloaded public source/pathing data, user-initiated export, or never-transmitted.
3. Resolve permission state to `not_determined`, `granted_limited`, `granted_read`, `granted_write`, `granted_read_write`, `denied`, `restricted`, `revoked`, `unavailable`, or `needs_review`.
4. Create only `ContextSlot` summaries, not raw private payloads, unless a later implementation issue explicitly owns encrypted local storage.
5. Stamp freshness, precision, provenance, and revocation behavior.
6. Apply the context-to-path influence matrix.
7. Emit or link a local receipt or explanation when the context changes user-visible behavior.
8. Fall back gracefully when permission is denied, restricted, revoked, stale, or unavailable.

## NativeContextAdapter

`NativeContextAdapter` is the future protocol/spec boundary for a single native context source.

Required fields:

| Field | Requirement | Red stop |
|---|---|---|
| `adapterId` | Stable local adapter identifier. | ID embeds raw private context, names, exact locations, health values, files, photos, or user identifiers. |
| `sourceKind` | Calendar, reminders, Health/Fitness, location, files/photos/OCR import, CloudKit sync state, notifications, Focus/Shortcuts, manual life context, or other future native source. | Source is treated as generic Source Atlas content or public pack data. |
| `permissionScope` | Exact platform/user permission needed, or `none` for local/manual/system state. | Broad permission ask without scope. |
| `valueProof` | Proof shown before the permission ask. | Permission request appears before value is explained. |
| `dataClass` | Local-only, user-iCloud state, explicit import, user-initiated export, never-transmitted, or public downloaded source/pathing data. | Missing classification or private data marked R2/public. |
| `slotTypes` | Allowed `ContextSlot` kinds this adapter can emit. | Raw payloads drive runtime directly without slot contract. |
| `freshnessPolicy` | How stale context degrades and when review is required. | Stale or revoked context remains current. |
| `revocationPolicy` | What happens when permission is denied, restricted, revoked, or becomes unavailable. | Denial/revocation breaks the app or leaves hidden context active. |
| `influenceTargets` | Which pathing, schedule, elasticity, reflow, trust, or explanation areas can use the slot. | Context silently mutates goals, Steps, schedule, or learning outside allowed targets. |
| `blockedUses` | Explicit forbidden uses. | Adapter can create source-backed authority, high-risk advice, public artifacts, or R2 writes. |
| `storageBoundary` | Local storage, user iCloud state, transient memory, or explicit import container. | Private native context leaves local/user-owned boundary. |
| `receiptPolicy` | When the user can inspect why the adapter influenced behavior. | User-visible behavior changes without receipt/explanation. |
| `fallbackBehavior` | Baseline behavior when data is absent. | Denied permission stops planning or creates false precision. |

## ContextSlot

`ContextSlot` is the normalized local signal emitted by an adapter.

Required fields:

| Field | Requirement |
|---|---|
| `slotId` | Stable local identifier that does not expose raw context. |
| `adapterId` | Source adapter reference. |
| `slotKind` | Availability, busy window, reminder pressure, energy band, travel friction, explicit import candidate, sync health, notification reachability, focus constraint, life-context fact, or fallback baseline. |
| `dataClass` | Same classification vocabulary as the adapter. |
| `sensitivityClass` | Standard, calendar-derived, imported-private, health-sensitive, location-sensitive, high-risk-sensitive, sync-state, notification-state, or never-transmit. |
| `permissionState` | Current permission state at slot creation. |
| `precision` | None, coarse, bounded, limited, derived, precise-permissioned, or explicit-user-provided. |
| `freshnessState` | Current, may-need-review, based-on-older-context, stale, revoked, or unavailable. |
| `sourceSummary` | Human-readable source summary safe for local UI/logs. |
| `allowedInfluence` | Bounded effects from the influence matrix. |
| `blockedInfluence` | Forbidden effects. |
| `receiptRef` | Local receipt/explanation reference when user-visible behavior changes. |
| `deleteExportPolicy` | How slot summary is deleted, reset, exported, or excluded. |

Context slots are not finished Steps, not Source Atlas claims, not source authority, and not public proof. They are local planning signals.

## PermissionValueProof

Every permissioned adapter must show a value proof before the system permission prompt.

Required shape:

- `proofId`
- `adapterId`
- user-facing benefit in plain language
- what improves
- what does not happen
- data boundary statement
- controls/revocation path
- fallback if denied
- local receipt/explanation behavior
- high-risk or sensitive-data warning if applicable

Forbidden value-proof behavior:

- asking for permission before explaining value
- implying private data goes to R2, Source Atlas, Ambitions servers, or an external model
- implying denial blocks basic Ambitions value
- implying Calendar/Health/Location grants source authority
- using urgency, shame, scoring, or "AI needs this" language

## Source Catalogue

| Source | Context slots allowed | Data class | Sensitivity | Permission posture | Allowed influence | Blocked uses |
|---|---|---|---|---|---|---|
| Calendar | Derived busy windows, open-window confidence, write-only block receipt | local-only | calendar-derived | Value proof required before read/write | Schedule fit, Time Texture, path density, deadline pressure, explanation | Calendar clone UI, raw event upload, hidden mutation, source authority |
| Reminders | Optional existing reminder pressure, user-confirmed reminder write receipt | local-only | standard/imported-private | Value proof required if reading/writing | Reminder-aware collision warning, user-confirmed reminder creation | Importing task app hierarchy as Ambitions truth, raw reminder upload |
| Health/Fitness | Coarse energy/recovery band only when useful | local-only or never-transmitted | health-sensitive | Strong value proof, guarded and optional | Elasticity, recovery-safe variants, lighter path density | Medical advice, diagnosis, precise health values in public artifacts |
| Location | Coarse place/travel friction only when explicitly useful | local-only or never-transmitted | location-sensitive | Strong value proof, coarse by default | Travel friction, location-compatible Step variant, schedule buffer | Precise tracking, background surveillance, R2/public leak |
| Files/Photos/OCR | Explicit import candidate, extracted local text summary, source-needed marker | explicit import/local-only | imported-private/high-risk-sensitive | User-initiated import only | User-approved capture/source candidate, local source-needed scaffold | Background library scan, private import in Source Atlas/R2, raw OCR in Linear |
| CloudKit sync state | Sync health, local-only fallback, account unavailable, paused/needs review | user-iCloud state | sync-state | No data-read permission; user-owned sync controls | Trust/explanation, conflict/review posture, local-only fallback | Claiming sync readiness, blocking local operation, custom backend drift |
| Notifications | Reachability/state only | local-only | notification-state | Value proof before notifications | Reminder delivery confidence, fallback explanation | Treating notification grant as planning source or engagement pressure |
| Focus/Shortcuts | User-initiated automation/context hint | local-only | standard | Explicit user action or app intent scope | Execution lane hint, shortcut receipt | Hidden automation, broad device profiling |
| Manual life context | User-confirmed editable context | local-only; optional user iCloud later | standard/high-risk-sensitive depending field | No platform permission; user control required | Path fit, eligibility, capacity, constraints | Protected/sensitive inference without review |

## Context-To-Path Influence Matrix

| Slot kind | May influence | Must not influence |
|---|---|---|
| Availability/busy window | Path density, schedule install preview, open-window choice, Time Texture, Today fit explanation | Source authority, Source Atlas eligibility, high-risk approval, silent schedule commit |
| Reminder pressure | Collision warning, user-confirmed reminder write, lightweight follow-up | Importing external task hierarchy, replacing Ambitions Step graph, shame/overdue framing |
| Energy/recovery band | Elasticity ranking, recovery-safe variant, lighter day shape | Health advice, diagnosis, medical plan, high-risk bypass |
| Travel friction/place band | Buffer estimates, location-compatible variant, route-needed clarification | Precise tracking, public proof, source authority, background surveillance |
| Explicit import candidate | Local Held Object, Source Needed local scaffold, user-confirmed source candidate | Public Source Atlas pack, R2 object, raw OCR leakage, automatic source-backed path |
| Sync health | Trust/explanation, local-only fallback, conflict review | Release readiness, iCloud sync Green, blocking local operation |
| Notification reachability | Delivery fallback, local reminder confidence | Productivity score, engagement pressure, planning source |
| Manual life context | Eligibility/path fit, same-goal different-person local difference | Sensitive inference, protected-class targeting, public artifact |

## Revocation Behavior Matrix

| Permission state | Runtime posture | Required behavior |
|---|---|---|
| Not determined | Baseline/manual mode | Show value proof before any permission ask; do not block planning. |
| Granted limited/read/write | Use only allowed slot types | Preserve precision and blocked-use limits; emit receipt/explanation when behavior changes. |
| Denied/restricted | Baseline/manual mode | Keep app usable; remove or mark permissioned slots unavailable; explain reduced precision. |
| Revoked | Invalidate permissioned slots | Do not treat old slots as current; keep only safe receipts/history allowed by retention policy. |
| Unavailable | Local fallback | Use Ambitions-owned/manual context; do not nag. |
| Needs review | Hold or degrade | Require user review before context drives meaningful changes. |

## Fixture Matrix

Later implementation/validator phases must cover at least:

- calendar not determined shows value proof before permission request
- calendar denied produces baseline open windows and no app break
- calendar write-only can write confirmed blocks but cannot read availability
- calendar revoked invalidates calendar-derived busy windows
- stale calendar-derived context cannot drive current schedule fit
- reminders denied does not import external task hierarchy or block Ambitions Steps
- Health/Fitness not useful routes to no adapter and no permission ask
- Health/Fitness useful emits only coarse local energy/recovery band, not medical advice
- location uses coarse travel friction by default and never precise tracking without explicit scope
- Files/Photos/OCR import is user-initiated and never background scans
- imported OCR/private file text never enters R2, public Source Atlas, Linear, logs, or support bundles
- CloudKit sync unavailable keeps local operation authoritative
- CloudKit healthy-after-proof still does not prove release readiness
- notification denied degrades delivery confidence without shame or engagement pressure
- same goal can receive different path density from different local context only when slots are explicit and inspectable
- high-risk or sensitive slot cannot bypass AMB-701 guarded routing
- fixture/test/generated/preview data is not treated as production runtime context

## Red Conditions

- permission ask happens before value proof
- denied or revoked permission breaks app value
- stale/revoked context remains current
- native context is treated as Source Atlas content or R2/public pack data
- raw calendar events, reminders, health data, location, files, photos, OCR text, or personal context leave the local/user-owned boundary
- Health/Fitness or Location context produces medical, safety, legal, or financial advice
- CloudKit sync state is used to claim sync/release readiness
- notification permission becomes engagement pressure, productivity scoring, streak, or shame
- context slots silently mutate goals, Steps, schedules, learning, or proof without receipt/explanation
- fixture/test/generated/preview material is treated as production runtime proof

## Downstream Consumers

- AMB-703 / PLOS-081 Calendar context adapter and explainer
- AMB-704 / PLOS-082 Reminders context adapter if useful
- AMB-705 / PLOS-083 Health/Fitness context adapter if useful
- AMB-706 / PLOS-084 Location context adapter
- AMB-707 / PLOS-085 Files/Photos/OCR explicit import paths
- AMB-708 / PLOS-086 CloudKit sync-state context adapter
- AMB-771 / PLOS-087 Permission value proof pattern
- AMB-710 / PLOS-088 Permission ledger and revocation controls
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-621 / PLOS-M14 Step Elasticity Engine
- AMB-622 / PLOS-M15 Schedule Install Kernel
- AMB-628 / PLOS-M19 Performance Runtime hardening
- AMB-632 / PLOS-M23 CloudKit/iCloud sync hardening
- AMB-635 / PLOS-M26 certification gauntlets

## Non-Claims

This artifact does not claim app source change, Swift/domain implementation, runtime adapter implementation, runtime permission flow implementation, EventKit/HealthKit/CoreLocation/Photos/Vision/CloudKit integration, entitlement changes, privacy manifest changes, background ingestion, runtime path selection, generated Step behavior, schedule install implementation, UI implementation, screenshot proof, accessibility proof, device proof, measured performance proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, App Review readiness, CloudKit sync readiness, R2 write, production certification, AMB-616 parent completion, or full PLOS project completion.
