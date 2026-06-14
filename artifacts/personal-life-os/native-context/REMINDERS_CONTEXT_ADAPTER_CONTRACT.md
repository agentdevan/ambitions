# Reminders Context Adapter Contract

Status: AMB-704 / PLOS-082 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane contract for Reminders context adapter usefulness, permission/value behavior, and privacy-safe local influence.

This artifact specializes the AMB-702 Native Context Mesh contract for Reminders. It defines when a future Reminders adapter is useful, what it may emit, what it must not import, how it links to `PermissionValueProof`, how denied or revoked permission degrades, and which fixture obligations later implementation/validator phases must satisfy.

This is not Swift implementation, runtime adapter implementation, EventKit/Reminders entitlement work, permission prompting implementation, privacy manifest change, UI implementation, accessibility proof, device proof, measured performance proof, privacy/legal approval, App Review readiness, release readiness, Reminders replacement proof, or AMB-616 parent completion.

## Existing Source Ownership

AMB-704 inspected these owners before adding this contract:

- `artifacts/personal-life-os/native-context/NATIVE_CONTEXT_MESH_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/NATIVE_CONTEXT_MESH_ADAPTER_CONTRACT.json`
- `artifacts/personal-life-os/native-context/CALENDAR_CONTEXT_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/CALENDAR_CONTEXT_ADAPTER_CONTRACT.json`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/Ambitions/Domain/ReminderModels.swift`
- `Native/Ambitions/Domain/ReminderNaturalLanguageCaptureParser.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/AmbitionsTests/Domain/IOS26RemindersP0ContractHarnessTests.swift`
- `Native/AmbitionsTests/App/CalendarReminderActionFlowTests.swift`
- `Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift`

Existing source already contains EventKit reminder write seams, local reminder domain models, reminder source/receipt/replay inspection boundaries, repository export/delete behavior, Goal Detail reminder creation action flow, and tests that block broad Reminders replacement/readiness claims. AMB-704 binds a downstream context adapter contract to those owners; it does not implement new app behavior.

## Usefulness Decision

A Reminders adapter is useful only when it preserves Ambitions' Personal Life OS model instead of importing an external task app hierarchy.

Allowed usefulness:

- write a user-confirmed Ambitions step reminder into Apple Reminders after value proof and explicit action
- surface a local reminder write receipt so the user can inspect what was written
- optionally detect coarse reminder pressure in a future issue only if the user asks for Reminders-aware planning and the implementation can prove local-only, redacted, revocable summaries
- explain reduced precision when Reminders access is denied or revoked

Not useful, and therefore blocked:

- importing Reminders lists as Ambitions tasks
- treating Apple Reminders as source authority, Source Atlas content, or public pathing material
- turning Ambitions into a generic to-do/reminder app
- using overdue reminder pressure for shame, streaks, productivity score, or urgency theater
- reading reminder titles, notes, list names, recurrence, completion history, or metadata into Linear, R2, public artifacts, external prompts, analytics, telemetry, or support bundles

Default posture: write-receipt and explicit user-confirmed reminder creation are useful now as a contract; broad read ingestion remains blocked until a future issue proves value, storage, revocation, redaction, fixture coverage, and user controls.

## RemindersContextAdapter

`RemindersContextAdapter` is the future Reminders specialization of `NativeContextAdapter`.

Required fields:

| Field | Requirement | Red stop |
|---|---|---|
| `adapterId` | Stable local ID such as `native.reminders.context`. | ID contains reminder title, list name, note content, recurrence text, or user identifier. |
| `sourceKind` | `reminders`. | Reminders are treated as Source Atlas, R2 pathing data, public source authority, or finished Ambitions Steps. |
| `permissionScope` | EventKit Reminders write scope by default; future read scope requires separate value proof and issue authority. | One broad permission ask covers write, read, import, and background ingestion. |
| `usefulnessDecision` | Explicit `write_receipt_only`, `read_summary_allowed`, `not_useful`, or `blocked`. | Adapter reads Reminders before a usefulness decision exists. |
| `valueProof` | Reminders-specific `PermissionValueProof` shown before any Reminders permission prompt. | System permission prompt appears before value proof. |
| `permissionLedgerRef` | Local `PermissionLedger` record for request/grant/denial/revocation. | Permission state is inferred without local ledger trail. |
| `slotTypes` | `reminder_write_receipt`, `reminder_permission_fallback`, future `reminder_pressure_summary` only after proof. | Raw reminders, lists, notes, recurrence details, or completed-reminder history drive runtime directly. |
| `freshnessPolicy` | Write receipts remain historical; pressure summaries expire quickly and become unavailable on permission change. | Old or revoked Reminders summaries remain current. |
| `revocationPolicy` | Denied/restricted/revoked/unavailable clears current permissioned slots and falls back to Ambitions-local reminder behavior. | Denial or revocation breaks planning, reminder creation, or Step execution. |
| `allowedInfluence` | Explicit reminder write receipt, local follow-up confidence, collision warning, reduced-precision explanation. | Source authority, high-risk approval, Step graph replacement, Source Atlas eligibility, background mutation, public/share output, productivity scoring. |
| `storageBoundary` | Local-only Ambitions reminder records, local receipts, user-owned Reminders write target after explicit confirmation. | Raw Reminder content leaves local/user-owned boundary. |
| `receiptPolicy` | Emit a local explanation or ledger link when a reminder is written or Reminders state changes user-visible behavior. | Reminder-derived behavior is hidden or unexplained. |
| `fallbackBehavior` | Keep Ambitions-local reminder/step behavior usable when Reminders is absent. | App claims Reminders is required for Ambitions to work. |

## Permission Value Proof Linkage

Reminders requires value proof before both write and any future read prompt.

Write proof:

- Benefit: Ambitions can put a user-confirmed step reminder into the user's Apple Reminders list.
- What improves: continuity with an external Apple-native reminder surface after explicit confirmation.
- What does not happen: Ambitions does not import Reminders lists, read existing reminders, upload reminder content, train models, create Source Atlas content, or write reminders silently.
- Boundary: Ambitions writes only the user-confirmed reminder payload and stores only local receipt/explanation metadata.
- Control: user can deny, restrict, revoke, or keep the reminder inside Ambitions.
- Fallback: the step and local Ambitions reminder remain usable without Reminders access.

Future read proof, if ever authorized:

- Benefit: Ambitions may warn about coarse reminder pressure or conflict without importing tasks.
- What improves: local collision awareness and reduced accidental overload.
- What does not happen: Ambitions does not ingest lists as tasks, rank the user, shame overdue reminders, or expose raw reminder material.
- Boundary: only derived counts/pressure summaries may be local slots; titles, notes, list names, attendees, recurrence details, completion history, and identifiers are blocked from public/support/external surfaces.
- Control: user can revoke access and clear current derived summaries.
- Fallback: baseline local Ambitions reminder behavior continues.

## PermissionLedger And Revocation Linkage

Future implementation must link Reminders slots and explainers to `PermissionLedger`.

Required ledger states:

| Ledger state | Reminders behavior |
|---|---|
| `not_determined` | Show value proof; do not request permission until the user chooses a Reminders-aware action. |
| `granted_write` / `granted_read_write` | Allow only explicit user-confirmed reminder writes unless a future read-proof issue exists. |
| `granted_read` | No active use in AMB-704; future read summary must be separately scoped. |
| `denied` / `restricted` | Keep Ambitions-local reminder and Step behavior; explain reduced Apple Reminders continuity. |
| `revoked` | Invalidate current permissioned summaries and stop Apple Reminders writes until fresh value proof and user action. |
| `unavailable` | Use Ambitions-owned local reminder behavior; no nagging. |
| `needs_review` | Hold Reminders influence until user reviews the permission/value state. |

Revocation must be fail-closed for current context: no revoked or stale Reminders-derived pressure may drive collision warnings, path density, Today recommendation copy, or schedule fit as current evidence.

## Context-To-Path Influence Matrix

| Reminders slot | May influence | Must not influence |
|---|---|---|
| `reminder_write_receipt` | Local receipt for explicit user-confirmed Apple Reminders write, follow-up explanation, You inspection trail | Silent writes, recurring automation claim, Reminders replacement claim, Source Atlas eligibility |
| `reminder_permission_fallback` | Keep local Ambitions reminder behavior, explain reduced external continuity, avoid repeated permission nagging | Broken app state, false precision, shame/overdue pressure, engagement pressure |
| `reminder_pressure_summary` | Future coarse collision warning and local overload signal only after read-proof issue authority | Importing external task hierarchy, replacing Ambitions Step graph, productivity score, high-risk approval, public/share artifacts |
| `reminder_not_useful` | Skip permission prompt and keep Ambitions-local behavior | Hidden permission request, feature disabled messaging that implies Ambitions cannot work |

## Privacy Boundary

Reminders context is local-only. A user-confirmed write targets the user's Apple Reminders store through EventKit, but Ambitions must not treat that Apple-owned surface as Ambitions backend storage or source authority.

Reminders context must never become:

- R2 object material
- Source Atlas pack data
- public pathing data
- Linear comment content containing private reminder details
- support bundle content unless explicitly user-exported and redacted by future M24 rules
- external model prompt/context
- analytics, telemetry, crash, or engagement payload

Allowed local summaries:

- permission state
- explicit write receipt ID
- selected Ambitions step ID/reference
- local explanation ID
- future coarse reminder-pressure count without raw titles, only if separately authorized

Blocked raw material:

- reminder titles read from Apple Reminders
- list names
- notes/descriptions
- recurrence details
- completion history
- reminder identifiers from Apple Reminders in public artifacts
- reminder metadata that can reconstruct private obligations

## Fixture Matrix

Future implementation/validator work must cover at least:

- not-determined write shows value proof before system permission prompt
- denied write leaves the Step and local Ambitions reminder behavior usable
- restricted write explains reduced external continuity without repeated nagging
- granted write creates only a user-confirmed Apple Reminders item and local receipt
- write flow does not read existing Reminders lists or reminder content
- revoked write stops Apple Reminders writes until fresh value proof and explicit action
- future read summary cannot run without separate value proof and issue authority
- any future reminder-pressure summary expires and cannot remain current after revocation
- reminder titles, list names, notes, recurrence details, and completion history never enter R2, Source Atlas, Linear, support bundles, external prompts, analytics, or telemetry
- Reminders context cannot approve high-risk guarded routes
- Reminders context cannot replace the Ambitions Step graph or produce generic task-list anatomy
- denied Reminders permission cannot block Start here, Step, Goal Detail, or local closure
- fixture/test/generated Reminders data is not production runtime proof
- broad Reminders replacement, release, accessibility, privacy/legal, performance, TestFlight, App Store, and App Review claims are blocked without exact proof

## Downstream Consumers

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

## Red Conditions

- Reminders permission ask happens before value proof
- denied or revoked Reminders permission breaks Ambitions
- stale Reminders-derived context remains current
- Reminders context becomes Source Atlas, R2, public pack, Linear private content, support-bundle private content, or external prompt content
- raw reminder details leave the local/user-owned boundary
- Apple Reminders write happens without explicit user confirmation
- existing Reminders lists are imported as Ambitions tasks or source authority
- Reminders context silently mutates goals, Steps, schedules, learning, or proof without receipt/explanation
- Reminders context bypasses high-risk guarded routing or Step Quality Firewall
- Reminders becomes shame/overdue pressure, streak pressure, productivity score, or generic to-do app framing
- broad Reminders replacement, release, privacy/legal, accessibility, device, performance, TestFlight, App Store, or App Review readiness is claimed without exact proof

## Non-Claims

AMB-704 does not claim app source change, Swift/domain implementation, runtime adapter implementation, EventKit Reminders permission prompting implementation, EventKit entitlement change, privacy manifest change, background ingestion, Reminders read implementation, Apple Reminders import implementation, generic task-list replacement, UI implementation, screenshot proof, accessibility proof, device proof, measured performance proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, App Review readiness, CloudKit sync readiness, R2 write, production certification, AMB-616 parent completion, or full PLOS project completion.
