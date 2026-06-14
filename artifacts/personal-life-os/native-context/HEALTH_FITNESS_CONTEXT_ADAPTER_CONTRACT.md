# Health/Fitness Context Adapter Contract

Status: AMB-705 / PLOS-083 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane contract for Health/Fitness context adapter usefulness, sensitive-data permission behavior, and privacy-safe local influence.

This artifact specializes the AMB-702 Native Context Mesh contract for Health/Fitness. It defines why Health/Fitness context is not useful for launch core by default, which future coarse local summaries may become useful after value proof, how any future adapter must link to `PermissionValueProof` and `PermissionLedger`, and which privacy, high-risk, and fixture gates block overreach.

This is not Swift implementation, runtime adapter implementation, HealthKit integration, HealthKit entitlement work, permission prompting implementation, privacy manifest change, UI implementation, accessibility proof, device proof, measured performance proof, privacy/legal approval, medical guidance approval, App Review readiness, release readiness, Health/Fitness replacement proof, or AMB-616 parent completion.

## Existing Source Ownership

AMB-705 inspected these owners before adding this contract:

- `artifacts/personal-life-os/native-context/NATIVE_CONTEXT_MESH_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/NATIVE_CONTEXT_MESH_ADAPTER_CONTRACT.json`
- `artifacts/personal-life-os/native-context/CALENDAR_CONTEXT_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/REMINDERS_CONTEXT_ADAPTER_CONTRACT.md`
- `Native/Ambitions/Domain/LifeContextModels.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalEnergyFitModels.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalEnergyLearningModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSPerformanceEnergyModels.swift`
- `Native/Ambitions/Services/ExecutionResilienceProjector.swift`
- `Native/AmbitionsTests/Domain/LifeContextModelsTests.swift`
- `Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift`

Focused source inspection found no active HealthKit implementation, no `HKHealthStore`, no HealthKit entitlement, and no production `HealthFitnessContextAdapter` source type. Existing source already has local/user-provided life context, energy pattern, recovery constraints, health-sensitive fact categories, assumed-neutral energy capacity fallback, goal energy-fit models, and recovery-safe projection seams. AMB-705 binds a downstream Health/Fitness context adapter contract to those owners; it does not implement new app behavior.

## Usefulness Decision

Health/Fitness context is not useful for launch core by default because Ambitions already has manual/local energy and recovery context seams and because Health/Fitness data is high-sensitivity, easy to overclaim, and unsafe if converted into medical advice or productivity scoring.

Allowed future usefulness only after a separate source-changing issue proves value and privacy gates:

- optional coarse `energy_recovery_band` or `movement_readiness_band` derived locally from explicitly permitted Health/Fitness signals
- reduced-intensity or recovery-safe path shaping when the user has asked for that help and can inspect the reason
- explanation that Ambitions is using baseline/manual energy assumptions when Health/Fitness is absent, denied, restricted, revoked, unavailable, or stale
- local receipts when Health/Fitness context changes a user-visible recommendation, elasticity choice, or recovery suggestion

Not useful, and therefore blocked:

- precise Health/Fitness values as runtime facts, public proof, Source Atlas material, R2 material, Linear content, support-bundle private material, external model prompts, analytics, telemetry, or crash payloads
- medical advice, diagnosis, treatment, training prescription, safety clearance, nutrition prescription, medication guidance, fertility/pregnancy inference, mental-health inference, or professional-boundary bypass
- workouts, sleep stages, heart data, symptoms, medications, diagnoses, fertility data, body measurements, mindfulness data, menstrual/cycle data, or detailed movement history as Ambitions planning evidence
- shame, streaks, fitness pressure, productivity scores, life scores, readiness scores, or "optimize yourself" framing
- a permission prompt before value proof or a claim that Ambitions needs Health/Fitness access to work

Default posture: no Health/Fitness permission ask and no Health/Fitness adapter in launch core unless a future issue proves a user-visible value case, local-only coarse derivation, revocation behavior, fixture coverage, and no medical/high-risk overclaim.

## HealthFitnessContextAdapter

`HealthFitnessContextAdapter` is the future Health/Fitness specialization of `NativeContextAdapter`.

Required fields:

| Field | Requirement | Red stop |
|---|---|---|
| `adapterId` | Stable local ID such as `native.health_fitness.context`. | ID contains diagnosis, workout, body metric, sleep, cycle, medication, symptom, location, or user identifier. |
| `sourceKind` | `health_fitness`. | Health/Fitness is treated as Source Atlas, R2 pathing data, public source authority, or professional advice source. |
| `permissionScope` | Exact minimal scope for one coarse summary family, or `none` when not useful. | Broad HealthKit request covers unrelated categories or precise values. |
| `usefulnessDecision` | Explicit `not_useful_for_launch_core`, `coarse_energy_recovery_allowed`, `movement_readiness_allowed`, or `blocked`. | Adapter requests permission or reads data before usefulness is established. |
| `sensitivityClass` | `health_sensitive` and `never_transmit` for permissioned summaries; manual baseline may be local-only. | Health/Fitness context is classified as standard/public/R2 eligible. |
| `valueProof` | Health/Fitness-specific `PermissionValueProof` shown before any platform prompt. | System permission prompt appears before value proof. |
| `permissionLedgerRef` | Local `PermissionLedger` record for request/grant/denial/revocation/unavailability. | Permission state is inferred without ledger trail or revocation receipt. |
| `slotTypes` | `health_not_useful`, `health_denied_fallback`, future `coarse_energy_recovery_band`, future `movement_readiness_band`. | Raw Health/Fitness records or precise values drive runtime directly. |
| `freshnessPolicy` | Permissioned summaries expire quickly and become unavailable on permission change. | Old or revoked Health/Fitness summaries remain current. |
| `revocationPolicy` | Denied/restricted/revoked/unavailable clears current permissioned slots and falls back to manual/baseline energy and recovery behavior. | Denial or revocation breaks planning, Step execution, recovery, or Today. |
| `allowedInfluence` | Local elasticity ranking, recovery-safe variants, lighter path density, reduced-precision explanation, optional reflection. | Medical advice, diagnosis, high-risk approval, Source Atlas eligibility, public/share output, productivity score, shame/streak pressure. |
| `storageBoundary` | Local-only derived summaries or transient memory; no public/cloud/source-pack storage. | Raw or derived Health/Fitness context leaves local/user-owned boundary or enters R2/Source Atlas. |
| `receiptPolicy` | Emit a local explanation or ledger link when Health/Fitness context changes user-visible behavior. | Health/Fitness-derived behavior is hidden or unexplained. |
| `fallbackBehavior` | Keep Ambitions fully usable with assumed-neutral/manual energy and recovery context. | App claims Health/Fitness permission is required for Ambitions value. |

## Permission Value Proof Linkage

Health/Fitness requires strong value proof before any system permission prompt. The proof must be narrower than generic health access and must name the exact coarse summary family being requested.

Future coarse energy/recovery proof:

- Benefit: Ambitions can make a local recommendation gentler when coarse energy or recovery context suggests a lighter day.
- What improves: recovery-safe Step variants, path density, and explanation quality.
- What does not happen: Ambitions does not diagnose, treat, prescribe, train, upload health data, create Source Atlas content, create R2 objects, train models, rank the user, or share Health/Fitness context.
- Boundary: only coarse local summary bands may be used; raw Health/Fitness values and records are not stored in public artifacts or sent to external systems.
- Control: user can deny, restrict, revoke, pause, or use manual/baseline energy context.
- Fallback: Start here, Step, Goal Detail, local closure, and recovery remain usable without Health/Fitness access.
- Sensitive warning: Health/Fitness is high-sensitivity context and cannot approve high-risk guarded routes or become medical advice.

Forbidden value-proof behavior:

- "Ambitions needs Health/Fitness to plan for you"
- "AI needs your health data"
- readiness, optimization, or score-pressure language
- medical, diagnosis, treatment, training, nutrition, medication, fertility, mental-health, or professional advice implications
- implying denial reduces core app value beyond reduced precision

## PermissionLedger And Revocation Linkage

Future implementation must link Health/Fitness slots and explainers to `PermissionLedger`.

Required ledger states:

| Ledger state | Health/Fitness behavior |
|---|---|
| `not_determined` | Show value proof only when the user chooses a Health/Fitness-aware path; do not request permission by default. |
| `granted_limited` | Use only the exact coarse summary family covered by value proof. |
| `granted_read` | Emit only allowed coarse derived local slots; no raw records or precise values. |
| `denied` / `restricted` | Keep assumed-neutral/manual energy and recovery behavior; explain reduced precision without nagging. |
| `revoked` | Invalidate current permissioned summaries and stop Health/Fitness-derived influence until fresh value proof and explicit action. |
| `unavailable` | Use baseline/manual energy and recovery behavior; no repeated permission prompts. |
| `needs_review` | Hold Health/Fitness influence until the user reviews the permission/value state. |

Revocation must be fail-closed for current context: no revoked or stale Health/Fitness-derived band may drive path density, recovery copy, Today recommendation wording, schedule fit, Step elasticity, or learning as current evidence.

## Sensitivity Classes

| Sensitivity class | Meaning | Allowed storage |
|---|---|---|
| `health_not_useful` | Health/Fitness adapter is disabled or not useful for the current feature. | Local configuration/receipt only. |
| `health_denied_fallback` | Permission denied, restricted, revoked, unavailable, or not requested. | Local permission state and reduced-precision explanation only. |
| `coarse_energy_recovery_band` | Future derived local energy/recovery band, never raw values. | Local-only transient or encrypted local store in future scope. |
| `movement_readiness_band` | Future coarse movement-readiness band, never workouts or precise activity history. | Local-only transient or encrypted local store in future scope. |
| `health_sensitive_never_transmit` | Any Health/Fitness-derived summary with permissioned provenance. | Never R2, Source Atlas, Linear, support bundles, external prompts, analytics, telemetry, or public proof. |

## Context-To-Path Influence Matrix

| Health/Fitness slot | May influence | Must not influence |
|---|---|---|
| `health_not_useful` | Skip permission prompt, keep Ambitions-local/manual energy behavior, explain no Health/Fitness use | Hidden permission request, feature-disabled copy, Health/Fitness dependency claim |
| `health_denied_fallback` | Assumed-neutral energy/recovery, manual edit route, reduced-precision explanation, no nagging | Broken app state, false precision, shame, streaks, readiness score, engagement pressure |
| `coarse_energy_recovery_band` | Future recovery-safe Step variant, lighter path density, elasticity ranking, local explanation | Medical advice, diagnosis, treatment, training plan, high-risk approval, source authority, public/share artifact |
| `movement_readiness_band` | Future lightweight movement-compatible variant or recovery caution when user asked for it | Fitness coaching, workout prescription, safety clearance, productivity/life score, generic habit streak |
| `health_stale_or_revoked` | Invalidate current Health/Fitness influence and fall back to baseline/manual context | Continuing current influence, hidden mutation, learning update, share projection, Source Atlas/R2 content |

## Privacy Boundary

Health/Fitness context is local-only and never-transmit. It may not participate in R2, public Source Atlas, Linear private details, support bundle private content, external model prompts, analytics, telemetry, crash reporting, or engagement payloads. Optional user-owned iCloud/CloudKit continuity is not claimed by AMB-705 and would require future M23 proof, privacy manifest review, delete/export behavior, and explicit owner authority.

Allowed local summaries:

- permission state
- adapter usefulness decision
- local explanation ID
- local receipt/ledger ID
- future coarse `energy_recovery_band` or `movement_readiness_band` with no raw values and only after separate proof

Blocked raw material:

- HealthKit samples or identifiers
- step counts, workouts, activity rings, calories, distance, heart rate, HRV, VO2, sleep stages, respiratory metrics, symptoms, medications, diagnoses, lab results, fertility/cycle data, body measurements, mindfulness data, clinical records, and detailed timestamps
- data that can reconstruct medical conditions, activity patterns, sleep patterns, symptoms, treatment, pregnancy/fertility, mental-health state, or professional-care relationships

Forbidden destinations:

- R2 objects
- Source Atlas packs, seeds, claims, or public pathing data
- Linear comments containing private Health/Fitness details
- unredacted support bundles or diagnostics
- external prompts or hosted inference context
- analytics, telemetry, crash, or engagement payloads
- public/share/progress-story artifacts

## Fixture Matrix

Future implementation/validator work must cover at least:

- Health/Fitness not useful for launch core produces no permission ask
- not-determined Health/Fitness state shows value proof before any system permission prompt
- value proof names the exact coarse summary family and denies broad access
- denied Health/Fitness permission leaves Start here, Step, Goal Detail, local closure, and recovery usable
- restricted or unavailable Health/Fitness state uses baseline/manual energy and recovery behavior without repeated nagging
- revoked Health/Fitness permission invalidates current permissioned summaries
- stale Health/Fitness summaries cannot drive current path density, Today recommendation copy, schedule fit, Step elasticity, or learning
- granted limited/read scope emits only coarse local bands and no raw records or precise values
- raw Health/Fitness values never enter R2, Source Atlas, Linear, support bundles, external prompts, analytics, telemetry, screenshots, or public artifacts
- Health/Fitness context cannot approve high-risk guarded routes or soften unsafe-blocked behavior
- Health/Fitness context cannot create medical advice, diagnosis, treatment, training plan, nutrition plan, medication guidance, fertility/pregnancy guidance, or professional-boundary bypass
- Health/Fitness context cannot create shame, streaks, readiness scores, productivity scores, life scores, or generic fitness app anatomy
- manual/user-provided energy and recovery context remains available without Health/Fitness access
- fixture/test/generated Health/Fitness data is not production runtime proof
- Health/Fitness replacement, HealthKit integration, privacy/legal, release, accessibility, device, performance, TestFlight, App Store, and App Review claims are blocked without exact proof

## Downstream Consumers

- AMB-706 / PLOS-084 Location context adapter
- AMB-707 / PLOS-085 Files/Photos/OCR explicit import paths
- AMB-708 / PLOS-086 CloudKit sync-state context adapter
- AMB-771 / PLOS-087 Permission value proof pattern
- AMB-710 / PLOS-088 Permission ledger and revocation controls
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-621 / PLOS-M14 Step Elasticity Engine
- AMB-623 / PLOS-M16 Life Consequence / Cross-Goal Reflow Engine
- AMB-625 / PLOS-M18 High-risk safety, legality, and jurisdiction
- AMB-628 / PLOS-M19 Performance Runtime hardening
- AMB-632 / PLOS-M23 CloudKit/iCloud sync hardening
- AMB-635 / PLOS-M26 certification gauntlets

## Red Conditions

- Health/Fitness permission ask happens before value proof
- denied, restricted, revoked, stale, or unavailable Health/Fitness permission breaks Ambitions or leaves stale influence active
- raw or precise Health/Fitness values drive runtime directly
- Health/Fitness context becomes Source Atlas, R2, public pack, Linear private content, support-bundle private content, external prompt content, analytics, telemetry, crash, or share/progress-story material
- Health/Fitness context produces medical advice, diagnosis, treatment, training, safety clearance, nutrition, medication, fertility/pregnancy, mental-health, or professional-boundary guidance
- Health/Fitness context bypasses high-risk guarded routing, unsafe-blocked routing, Step Quality Firewall, or source authority gates
- Health/Fitness context silently mutates goals, Steps, schedules, learning, proof, or recovery without receipt/explanation
- Health/Fitness becomes shame, streak pressure, readiness score, productivity score, life score, fitness gamification, or generic habit/fitness app framing
- Health/Fitness, HealthKit integration, release, privacy/legal, accessibility, device, performance, TestFlight, App Store, or App Review readiness is claimed without exact proof

## Non-Claims

AMB-705 does not claim app source change, Swift/domain implementation, runtime adapter implementation, HealthKit integration, HealthKit entitlement change, permission prompting implementation, privacy manifest change, background ingestion, Health/Fitness read implementation, Health/Fitness replacement, medical/legal/privacy approval, UI implementation, screenshot proof, accessibility proof, device proof, measured performance proof, release readiness, TestFlight readiness, App Store readiness, App Review readiness, CloudKit sync readiness, R2 write, production certification, AMB-616 parent completion, or full PLOS project completion.
