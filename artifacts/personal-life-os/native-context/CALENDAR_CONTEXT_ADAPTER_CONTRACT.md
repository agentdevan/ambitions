# Calendar Context Adapter Contract

Status: AMB-703 / PLOS-081 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane contract for Calendar-derived context and permission explainer behavior.

This artifact specializes the AMB-702 Native Context Mesh contract for Calendar. It defines how a future Calendar context adapter may convert EventKit state into local, inspectable `ContextSlot` summaries for schedule fit, open-window detection, path density, deadline pressure, and trust explanations.

This is not Swift implementation, runtime adapter implementation, EventKit entitlement work, permission prompting implementation, privacy manifest change, UI implementation, accessibility proof, device proof, measured performance proof, privacy/legal approval, App Review readiness, release readiness, Calendar replacement proof, or AMB-616 parent completion.

## Existing Source Ownership

AMB-703 inspected these owners before adding this contract:

- `artifacts/personal-life-os/native-context/NATIVE_CONTEXT_MESH_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/NATIVE_CONTEXT_MESH_ADAPTER_CONTRACT.json`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/Ambitions/Services/RealityModelProjector.swift`
- `Native/Ambitions/Services/RealityIntegrationAdapters.swift`
- `Native/Ambitions/Features/Time/TimeCalendarAwarenessSupport.swift`
- `Native/Ambitions/Services/AppServices.swift`
- `Native/AmbitionsTests/Domain/IOS26CalendarP0ContractHarnessTests.swift`
- `Native/AmbitionsTests/Services/RealityIntegrationAdaptersTests.swift`
- `Native/AmbitionsTests/Services/AmbitionsCommandExecutorTests.swift`

Existing source already contains EventKit authorization seams, derived busy-window projection, Time calendar-awareness fallback copy, local-only calendar context ledger entries, recommendation explanations, confirmed calendar block write intent behavior, and tests that block broad Calendar replacement/readiness claims. AMB-703 binds a downstream contract to those owners; it does not implement new app behavior.

## CalendarContextAdapter

`CalendarContextAdapter` is the future Calendar specialization of `NativeContextAdapter`.

Required fields:

| Field | Requirement | Red stop |
|---|---|---|
| `adapterId` | Stable local ID such as `native.calendar.context`. | ID contains raw event title, attendee, location, or calendar name. |
| `sourceKind` | `calendar`. | Calendar is treated as Source Atlas, R2 pathing data, or public source authority. |
| `permissionScope` | EventKit read or write-only event scope, separated by action. | One broad permission ask covers unrelated behavior. |
| `valueProof` | Calendar-specific `PermissionValueProof` shown before read or write prompt. | System permission prompt appears before value proof. |
| `permissionLedgerRef` | Local `PermissionLedger` record for request/grant/denial/revocation. | Permission state is inferred without local ledger trail. |
| `slotTypes` | `derived_busy_window`, `open_window_confidence`, `calendar_schedule_pressure`, `calendar_write_receipt`, `calendar_denied_fallback`. | Raw events or full calendars drive runtime directly. |
| `freshnessPolicy` | Calendar-derived slots expire at the end of their observed horizon or when permission changes. | Old calendar slots remain current after revocation or horizon expiry. |
| `revocationPolicy` | Denied/restricted/revoked/unavailable clears current derived slots and falls back to Ambitions baseline windows. | Denial or revocation breaks planning or leaves stale precision. |
| `allowedInfluence` | Schedule fit, Time Texture, open-window choice, path density, deadline pressure, Today fit explanation, trust receipt. | Source authority, high-risk approval, Source Atlas eligibility, background mutation, social/share output, productivity scoring. |
| `storageBoundary` | Local-only derived summaries and local/user-owned receipts. | Raw event details, attendees, locations, or calendars leave local/user-owned boundary. |
| `receiptPolicy` | Emit local explanation or ledger link when Calendar-derived context changes user-visible fit. | Calendar-derived behavior is hidden or unexplained. |
| `fallbackBehavior` | Baseline windows and manual schedule guidance when unavailable. | App claims Calendar is required for Ambitions to work. |

## Permission Value Proof Linkage

Calendar requires value proof before both read and write prompts.

Read proof:

- Benefit: Ambitions can find real open windows instead of relying only on baseline windows.
- What improves: schedule fit, visible open-window confidence, deadline pressure, and Time explanations.
- What does not happen: Ambitions does not upload raw calendar events, sell data, train models, write events, or turn Calendar into Source Atlas.
- Boundary: derived busy windows stay local; raw event title, attendee, location, notes, and calendar metadata are not stored in public artifacts.
- Control: user can deny, restrict, revoke, or use baseline mode.
- Fallback: Time still works without Calendar access.

Write proof:

- Benefit: a user-confirmed Ambitions block can be written to Calendar.
- What improves: continuity with the user-owned schedule after explicit confirmation.
- What does not happen: Ambitions does not write calendar events silently, import the whole calendar, or mutate schedule without confirmation.
- Boundary: the written event contains Ambitions-created schedule data only.
- Control: user can deny write access or keep the block inside Ambitions.
- Fallback: the block remains local in Ambitions.

## PermissionLedger And Revocation Linkage

Future implementation must link Calendar slots and explainers to `PermissionLedger`.

Required ledger states:

| Ledger state | Calendar behavior |
|---|---|
| `not_determined` | Show value proof; do not request permission until the user chooses the Calendar-aware action. |
| `granted_read` / `granted_read_write` | Allow derived busy windows and open-window confidence within the observed horizon only. |
| `granted_write` | Allow only user-confirmed write receipt behavior; do not read availability. |
| `denied` / `restricted` | Clear current derived slots, keep baseline planning, explain reduced precision. |
| `revoked` | Invalidate current derived slots, preserve only allowed local receipts/history, require fresh value proof before re-request. |
| `unavailable` | Use Ambitions-owned/manual context, no nagging. |
| `needs_review` | Hold Calendar-derived influence until user reviews state. |

Revocation must be fail-closed for current context: no revoked or stale Calendar-derived busy window may drive schedule fit, path density, deadline pressure, or Today recommendation copy as current evidence.

## Context-To-Path Influence Matrix

| Calendar slot | May influence | Must not influence |
|---|---|---|
| `derived_busy_window` | Open-window subtraction, schedule-fit preview, Time Texture, Today fit explanation | Source Atlas eligibility, source authority, high-risk approval, direct schedule commit, share artifacts |
| `open_window_confidence` | Confidence wording for `Find real open windows`, path density, deadline pressure | Productivity score, shame/streak pressure, opaque ranking, release/performance claims |
| `calendar_schedule_pressure` | Step elasticity hint, deadline rescue warning, schedule-install preview | Medical/legal/financial advice, unsupported goal bypass, guarded-route bypass |
| `calendar_write_receipt` | Local receipt for explicit user-confirmed Calendar block | Silent writes, recurring automation claim, Calendar replacement claim |
| `calendar_denied_fallback` | Baseline windows, manual schedule guidance, reduced-precision explanation | Broken app state, repeated nagging, false precision |

## Privacy Boundary

Calendar context is local-only. It may optionally participate in user-owned iCloud/CloudKit state only as a future user-owned sync record for Ambitions receipts or schedule blocks after M23 proof; AMB-703 does not claim that proof.

Calendar context must never become:

- R2 object material
- Source Atlas pack data
- public pathing data
- Linear comment content containing private event details
- support bundle content unless explicitly user-exported and redacted by future M24 rules
- external model prompt/context
- analytics, telemetry, crash, or engagement payload

Allowed local summaries:

- bounded time ranges such as "90 minutes calendar-derived busy time"
- permission state
- observed horizon start/end
- open-window count
- local receipt/explanation IDs

Blocked raw material:

- event titles
- attendee names/emails
- locations
- notes/descriptions
- calendar names
- recurrence details unless a future implementation issue owns redacted handling

## Fixture Matrix

Future implementation/validator work must cover at least:

- not-determined read shows value proof before system permission prompt
- denied read keeps baseline open windows and records no raw event access
- restricted read keeps baseline mode and explains reduced precision
- write-only can create user-confirmed Ambitions blocks but cannot read availability
- granted read emits only derived busy windows, not raw event details
- revoked read invalidates current Calendar-derived slots
- stale observed horizon cannot drive current schedule fit
- all-day events normalize to bounded busy windows without exposing titles
- overlapping events collapse only into derived pressure, not raw event lists
- no Calendar-derived slot becomes Source Atlas, R2, Linear, or public proof
- a user-confirmed Calendar write emits receipt/explanation
- unconfirmed write intent blocks safely
- denied write leaves the block local in Ambitions
- calendar context cannot approve high-risk guarded routes
- fixture/test/generated Calendar data is not production runtime proof
- broad Calendar replacement, release, accessibility, privacy/legal, performance, TestFlight, App Store, and App Review claims are blocked without exact proof

## Downstream Consumers

- AMB-704 / PLOS-082 Reminders context adapter if useful
- AMB-771 / PLOS-087 Permission value proof pattern
- AMB-710 / PLOS-088 Permission ledger and revocation controls
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-621 / PLOS-M14 Step Elasticity Engine
- AMB-622 / PLOS-M15 Schedule Install Kernel
- AMB-628 / PLOS-M19 Performance Runtime hardening
- AMB-632 / PLOS-M23 CloudKit/iCloud sync hardening
- AMB-635 / PLOS-M26 certification gauntlets

## Red Conditions

- Calendar permission ask happens before value proof
- denied/revoked Calendar permission breaks Ambitions
- stale Calendar context remains current
- Calendar context becomes Source Atlas, R2, public pack, Linear private content, support-bundle private content, or external prompt content
- raw event details leave the local/user-owned boundary
- Calendar write happens without explicit user confirmation
- Calendar-derived context silently mutates goals, Steps, schedules, learning, or proof without receipt/explanation
- Calendar context bypasses high-risk guarded routing or Step Quality Firewall
- broad Calendar replacement, release, privacy/legal, accessibility, device, performance, TestFlight, App Store, or App Review readiness is claimed without exact proof

## Non-Claims

AMB-703 does not claim app source change, Swift/domain implementation, runtime adapter implementation, EventKit permission prompting implementation, EventKit entitlement change, privacy manifest change, background ingestion, schedule install implementation, Calendar replacement, UI implementation, screenshot proof, accessibility proof, device proof, measured performance proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, App Review readiness, CloudKit sync readiness, R2 write, production certification, AMB-616 parent completion, or full PLOS project completion.
