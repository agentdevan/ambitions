# Location Context Adapter Contract

Status: AMB-706 / PLOS-084 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane contract for Location context adapter usefulness, permission value proof, privacy-safe local travel/place influence, and revocation behavior.

This artifact specializes the AMB-702 Native Context Mesh contract for Location. It defines the launch-safe baseline as manual/coarse local place and travel context already represented in `LifeContextModels`, makes precise platform location future-only, and blocks Location from becoming tracking, surveillance, public proof, Source Atlas material, R2 material, or high-risk authority.

This is not Swift implementation, runtime adapter implementation, CoreLocation integration, location entitlement work, permission prompting implementation, privacy manifest change, background location access, geofencing, map/timeline behavior, UI implementation, accessibility proof, device proof, measured performance proof, privacy/legal approval, App Review readiness, release readiness, Location replacement proof, or AMB-616 parent completion.

## Existing Source Ownership

AMB-706 inspected these owners before adding this contract:

- `artifacts/personal-life-os/native-context/NATIVE_CONTEXT_MESH_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/NATIVE_CONTEXT_MESH_ADAPTER_CONTRACT.json`
- `artifacts/personal-life-os/native-context/CALENDAR_CONTEXT_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/REMINDERS_CONTEXT_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/HEALTH_FITNESS_CONTEXT_ADAPTER_CONTRACT.md`
- `Native/Ambitions/Domain/LifeContextModels.swift`
- `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift`
- `Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift`
- `Native/Ambitions/Runtime/PersonalizationFactorLedgerBuilder.swift`
- `Native/Ambitions/Runtime/PrivateLifeRuntimeKernelContracts.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/AmbitionsTests/Domain/LifeContextModelsTests.swift`
- `Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift`

Focused source inspection found no active `CoreLocation` import, no `CLLocationManager`, no `CLLocation`, no `CLAuthorizationStatus`, no `NSLocation*` usage, and no production `LocationContextAdapter` source type. Existing source already has local/user-provided timezone, general location label, location precision, travel radius, transportation access, location-dependent pathway flags, travel requirements, travel model projection, Step access fit, personalization ledger factors, and You inspection rows. AMB-706 binds a downstream Location context adapter contract to those owners; it does not implement new app behavior.

## Usefulness Decision

Location context is useful for launch core only as manual or coarse local travel/place friction that the user can inspect and edit. Ambitions does not need platform location permission to deliver core value, and the launch-safe default is no CoreLocation prompt.

Allowed current posture:

- manual/user-provided timezone
- manual/user-provided general location label
- manual/user-provided location precision such as timezone, city/region, or user-entered place
- manual/user-provided travel radius and transportation access
- route/access assumptions that remain inspectable in You and local runtime explanations

Allowed future usefulness only after a separate source-changing issue proves value and privacy gates:

- optional coarse `place_band` or `travel_friction_band` derived locally from explicitly permitted location state
- timezone or city/region confirmation when user asks Ambitions to keep location assumptions current
- location-compatible Step variants when the user has asked for local place/travel awareness
- schedule buffer or route-needed clarification from coarse travel friction
- local receipts when Location context changes a user-visible recommendation, schedule fit, elasticity choice, or recovery suggestion

Not useful, and therefore blocked:

- precise latitude/longitude, precise address, GPS trace, visit history, route history, geofence events, home/work inference, map search history, Wi-Fi/Bluetooth identifiers, or detailed location timestamps as planning evidence
- background surveillance, passive visit detection, persistent location tracking, or location timeline UI
- Location context as Source Atlas, R2, public proof, Linear private detail, support-bundle private detail, external prompt content, analytics, telemetry, crash, engagement, or sharing material
- stalking, surveillance, harassment, evasion, safety-bypass, protected-class inference, minor/student location leakage, or professional/high-risk approval
- shame, streaks, fitness/readiness/productivity/life scores, or generic map/calendar/task-app anatomy
- a permission prompt before value proof or a claim that Ambitions needs location access to work

Default posture: no CoreLocation permission ask and no platform Location adapter in launch core unless a future issue proves a user-visible value case, coarse local derivation, revocation behavior, fixture coverage, and no surveillance/high-risk/privacy overclaim.

## LocationContextAdapter

`LocationContextAdapter` is the future Location specialization of `NativeContextAdapter`.

Required fields:

| Field | Requirement | Red stop |
|---|---|---|
| `adapterId` | Stable local ID such as `native.location.context`. | ID contains coordinates, address, route, place name, device identifier, or user identifier. |
| `sourceKind` | `location`. | Location is treated as Source Atlas, R2 pathing data, public source authority, analytics, or professional/safety advice source. |
| `permissionScope` | `none` for manual/coarse launch baseline; future exact minimal scope for one coarse summary family. | Broad, always-on, background, precise, or geofence permission is requested without separate issue authority. |
| `usefulnessDecision` | Explicit `manual_location_context_only`, `coarse_travel_friction_allowed`, `place_band_allowed`, or `blocked`. | Adapter requests permission or reads platform location before usefulness is established. |
| `sensitivityClass` | `location_sensitive` and `never_transmit` for permissioned summaries; manual baseline remains local-only. | Location context is classified as standard/public/R2 eligible. |
| `valueProof` | Location-specific `PermissionValueProof` shown before any platform prompt. | System permission prompt appears before value proof. |
| `permissionLedgerRef` | Local `PermissionLedger` record for request/grant/denial/revocation/unavailability. | Permission state is inferred without ledger trail or revocation receipt. |
| `slotTypes` | `location_not_useful`, `location_denied_fallback`, `timezone_context`, `city_region_context`, `user_entered_place`, future `coarse_place_band`, future `travel_friction_band`. | Raw coordinates, traces, visits, routes, geofences, or exact addresses drive runtime directly. |
| `precisionPolicy` | Coarse by default; precise-permissioned values are future-only and never transmitted. | Precise values are stored, logged, exported, shared, or used as public/source facts. |
| `freshnessPolicy` | Permissioned summaries expire quickly and become unavailable on permission change. | Old or revoked Location summaries remain current. |
| `revocationPolicy` | Denied/restricted/revoked/unavailable clears current permissioned slots and falls back to manual/baseline travel context. | Denial or revocation breaks planning, Step execution, recovery, or Today. |
| `allowedInfluence` | Local travel friction, location-compatible variants, schedule buffer, route-needed clarification, reduced-precision explanation. | Precise tracking, source authority, high-risk approval, safety advice, public/share output, productivity score, shame/streak pressure. |
| `storageBoundary` | Local-only derived summaries or transient memory; no public/cloud/source-pack storage. | Raw or derived Location context leaves local/user-owned boundary or enters R2/Source Atlas. |
| `receiptPolicy` | Emit a local explanation or ledger link when Location context changes user-visible behavior. | Location-derived behavior is hidden or unexplained. |
| `fallbackBehavior` | Keep Ambitions fully usable with manual/baseline timezone, place, travel radius, and transportation access. | App claims Location permission is required for Ambitions value. |

## Permission Value Proof Linkage

Location requires strong value proof before any system permission prompt. The proof must name the exact coarse summary being requested and must explain why manual context is insufficient for that user-selected path.

Future coarse travel/place proof:

- Benefit: Ambitions can avoid suggesting steps that do not fit the places, access, and travel friction available now.
- What improves: location-compatible Step variants, schedule buffer, route-needed clarification, and reduced impossible suggestions.
- What does not happen: Ambitions does not track the user, run background surveillance, infer home/work, upload location, create Source Atlas content, create R2 objects, train models, rank the user, or share Location context.
- Boundary: only coarse local place/travel summaries may be used; precise coordinates, route traces, visits, addresses, and detailed timestamps are not stored in public artifacts or sent to external systems.
- Control: user can deny, restrict, revoke, pause, or use manual/baseline location and travel context.
- Fallback: Start here, Step, Goal Detail, local closure, and recovery remain usable without Location access.
- Sensitive warning: Location is high-sensitivity context and cannot approve high-risk guarded routes, safety/legal/professional routes, or unsafe behavior.

Forbidden value-proof behavior:

- "Ambitions needs your location to plan for you"
- "AI needs your location"
- urgency, optimization, productivity score, or safety-clearance language
- implying denial reduces core app value beyond reduced precision
- implying precise tracking, background access, or home/work inference
- implying Location grants source authority or high-risk approval

## PermissionLedger And Revocation Linkage

Future implementation must link Location slots and explainers to `PermissionLedger`.

Required ledger states:

| Ledger state | Location behavior |
|---|---|
| `not_determined` | Show value proof only when the user chooses a Location-aware path; do not request permission by default. |
| `granted_limited` | Use only the exact coarse summary family covered by value proof. |
| `granted_while_in_use` | Future-only; emit only allowed coarse derived local slots, never background tracking. |
| `granted_read` | Future-only platform/source wrapper state; use only coarse local summaries. |
| `denied` / `restricted` | Keep manual/baseline location, travel radius, and transportation behavior; explain reduced precision without nagging. |
| `revoked` | Invalidate current permissioned summaries and stop Location-derived influence until fresh value proof and explicit action. |
| `unavailable` | Use baseline/manual location and travel behavior; no repeated permission prompts. |
| `needs_review` | Hold Location influence until the user reviews the permission/value state. |

Revocation must be fail-closed for current context: no revoked or stale Location-derived band may drive path density, schedule fit, Today recommendation wording, Step elasticity, travel buffer, learning, or share projection as current evidence.

## Sensitivity Classes

| Sensitivity class | Meaning | Allowed storage |
|---|---|---|
| `location_not_useful` | Location adapter is disabled or not useful for the current feature. | Local configuration/receipt only. |
| `location_denied_fallback` | Permission denied, restricted, revoked, unavailable, or not requested. | Local permission state and reduced-precision explanation only. |
| `timezone_only` | Timezone context from user/manual/device-safe source. | Local profile context; optional future user-owned iCloud only after proof. |
| `city_region` | Broad city/region or metro label, not precise address. | Local profile context; optional future user-owned iCloud only after proof. |
| `user_entered_place` | User-entered place/access label such as campus, home base, or general commute anchor. | Local profile context; no public/source-pack storage. |
| `coarse_place_band` | Future derived local place band, never exact coordinates. | Local-only transient or encrypted local store in future scope. |
| `travel_friction_band` | Future derived local travel friction band, not route history. | Local-only transient or encrypted local store in future scope. |
| `precise_permissioned_never_transmit` | Future precise-permissioned provenance used only to derive allowed coarse slots. | Never R2, Source Atlas, Linear, support bundles, external prompts, analytics, telemetry, public proof, or sharing. |

## Context-To-Path Influence Matrix

| Location slot | May influence | Must not influence |
|---|---|---|
| `location_not_useful` | Skip permission prompt, keep manual travel/place behavior, explain no platform Location use | Hidden permission request, feature-disabled copy, Location dependency claim |
| `location_denied_fallback` | Manual timezone/place/travel radius, reduced-precision explanation, no nagging | Broken app state, false precision, shame, streaks, score pressure, engagement pressure |
| `timezone_context` | Scheduling/travel grounding, timezone-sensitive explanation | Place inference, precise travel tracking, source authority, public proof |
| `city_region_context` | Broad local access, travel-radius assumptions, regional opportunity fit when user provided | Exact address, route history, public/R2/source-pack place fact, protected-class inference |
| `user_entered_place` | Route/access assumption, location-compatible Step variant, local explanation | Home/work inference beyond user wording, precise tracking, sharing/public proof |
| `coarse_place_band` | Future place-compatible variant, route-needed clarification | Exact lat/long, geofence, visit history, surveillance, safety/legal approval |
| `travel_friction_band` | Schedule buffer, travel-compatible Step variants, path density, local explanation | Route history, commute profiling, productivity score, public/share projection |
| `location_stale_or_revoked` | Invalidate current Location influence and fall back to manual/baseline context | Continuing current influence, hidden mutation, learning update, share projection, Source Atlas/R2 content |

## Privacy Boundary

Location context is local-only and never-transmit when permissioned. It may not participate in R2, public Source Atlas, Linear private details, support bundle private content, external model prompts, analytics, telemetry, crash reporting, engagement payloads, or public/share/progress-story artifacts. Optional user-owned iCloud/CloudKit continuity is not claimed by AMB-706 and would require future M23 proof, privacy manifest review, delete/export behavior, and explicit owner authority.

Allowed local summaries:

- permission state
- adapter usefulness decision
- local explanation ID
- local receipt/ledger ID
- manual timezone, general location label, travel radius, transportation access, and precision label
- future coarse `place_band` or `travel_friction_band` with no raw coordinates and only after separate proof

Blocked raw material:

- latitude/longitude
- precise address
- GPS trace
- visit history
- route history
- geofence events
- home/work inference
- map search history
- Wi-Fi/Bluetooth/cell identifiers
- device identifiers tied to place
- detailed location timestamps
- minor/student precise place context
- stalking, surveillance, evasion, or harassment context

Forbidden destinations:

- R2 objects
- Source Atlas packs, seeds, claims, requirements, or public pathing data
- Linear comments containing private Location details
- unredacted support bundles or diagnostics
- external prompts or hosted inference context
- analytics, telemetry, crash, or engagement payloads
- public/share/progress-story artifacts
- screenshots or visual proofs containing private precise location details

## Fixture Matrix

Future implementation/validator work must cover at least:

- launch core uses manual/coarse location and travel context without a platform permission ask
- not-determined Location state shows value proof before any system permission prompt
- value proof names the exact coarse summary family and denies broad/background/precise access
- denied Location permission leaves Start here, Step, Goal Detail, local closure, and recovery usable
- restricted or unavailable Location state uses baseline/manual location and travel behavior without repeated nagging
- revoked Location permission invalidates current permissioned summaries
- stale Location summaries cannot drive current path density, Today recommendation copy, schedule fit, Step elasticity, travel buffer, or learning
- granted limited/while-in-use scope emits only coarse local bands and no raw coordinates, routes, visits, geofence events, or precise addresses
- raw Location values never enter R2, Source Atlas, Linear, support bundles, external prompts, analytics, telemetry, screenshots, or public artifacts
- Location context cannot approve high-risk guarded routes or soften unsafe-blocked behavior
- Location context cannot enable stalking, surveillance, harassment, evasion, safety/legal/professional advice, protected-class inference, or minor/student precise-location leakage
- Location context cannot create shame, streaks, readiness scores, productivity scores, life scores, or generic map/calendar/task app anatomy
- manual/user-provided timezone, place, travel radius, and transportation access remain available without Location access
- fixture/test/generated Location data is not production runtime proof
- CoreLocation integration, privacy/legal, release, accessibility, device, performance, TestFlight, App Store, and App Review claims are blocked without exact proof

## Downstream Consumers

- AMB-707 / PLOS-085 Files/Photos/OCR explicit import context paths
- AMB-708 / PLOS-086 CloudKit sync-state context adapter
- AMB-771 / PLOS-087 Permission value proof pattern
- AMB-710 / PLOS-088 Permission ledger and revocation controls
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-621 / PLOS-M14 Step Elasticity Engine
- AMB-622 / PLOS-M15 Schedule Install Kernel
- AMB-623 / PLOS-M16 Life Consequence / Cross-Goal Reflow Engine
- AMB-625 / PLOS-M18 High-risk safety, legality, and jurisdiction
- AMB-628 / PLOS-M19 Performance Runtime hardening
- AMB-632 / PLOS-M23 CloudKit/iCloud sync hardening
- AMB-635 / PLOS-M26 certification gauntlets

## Red Conditions

- Location permission ask happens before value proof
- denied, restricted, revoked, stale, or unavailable Location permission breaks Ambitions or leaves stale influence active
- raw or precise Location values drive runtime directly
- Location context becomes Source Atlas, R2, public pack, Linear private content, support-bundle private content, external prompt content, analytics, telemetry, crash, engagement, or share/progress-story material
- Location context produces safety, legal, medical, financial, immigration, law-enforcement, stalking, surveillance, harassment, evasion, or professional-boundary guidance
- Location context bypasses high-risk guarded routing, unsafe-blocked routing, Step Quality Firewall, or source authority gates
- Location context silently mutates goals, Steps, schedules, learning, proof, or recovery without receipt/explanation
- Location becomes shame, streak pressure, readiness score, productivity score, life score, location gamification, or generic map/calendar/task app framing
- Location, CoreLocation integration, release, privacy/legal, accessibility, device, performance, TestFlight, App Store, or App Review readiness is claimed without exact proof

## Non-Claims

AMB-706 does not claim app source change, Swift/domain implementation, runtime adapter implementation, CoreLocation integration, location entitlement change, permission prompting implementation, privacy manifest change, background location access, geofencing, map/timeline behavior, Location replacement, safety/legal/privacy approval, UI implementation, screenshot proof, accessibility proof, device proof, measured performance proof, release readiness, TestFlight readiness, App Store readiness, App Review readiness, CloudKit sync readiness, R2 write, production certification, AMB-616 parent completion, or full PLOS project completion.
