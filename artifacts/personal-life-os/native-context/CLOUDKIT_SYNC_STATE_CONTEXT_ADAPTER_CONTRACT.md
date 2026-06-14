# CloudKit Sync-State Context Adapter Contract

Status: AMB-708 / PLOS-086 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane model for CloudKit sync-state context as a local planning/trust signal.

This artifact specializes the AMB-702 Native Context Mesh contract for CloudKit sync state. It defines how future Ambitions runtime code may summarize Apple-native user-owned continuity state as local context without treating sync as source authority, release proof, an account requirement, or a path to R2/public Source Atlas.

This is not app source implementation, CloudKit environment setup, iCloud account setup, entitlement change, privacy manifest change, runtime sync integration, network validation, user-data mutation, UI implementation, screenshot proof, accessibility proof, device proof, measured performance proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, App Review readiness, R2 publication, Source Atlas publication, AMB-616 parent completion, or full PLOS project completion.

## Existing Source Ownership

AMB-708 inspected these source and authority anchors before adding this contract:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `artifacts/personal-life-os/reports/PLOS-020-local-data-cloud-boundary.md`
- `artifacts/personal-life-os/reports/PLOS-021-cloudkit-schema-constraints.md`
- `artifacts/personal-life-os/native-context/NATIVE_CONTEXT_MESH_ADAPTER_CONTRACT.md`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/Ambitions/Persistence/CloudKitContinuityModels.swift`
- `Native/Ambitions/Persistence/CloudKitContinuityClient.swift`
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`
- `Native/AmbitionsTests/Persistence/CloudKitContinuityFoundationTests.swift`

Existing source already defines:

- `CloudKitContinuityFeatureFlag.defaultEnabled == false`.
- `LocalOnlySyncCapability` reports local operation authoritative.
- `CloudKitContinuitySyncState` values for local-only, disabled, unavailable, restricted, temporarily unavailable, paused, needs-review, and healthy-after-proof states.
- `CloudKitContinuityDiagnostics` fields for feature flag, account status, proof, pause, local fallback, local blocking, write/user-data capture flags, detail, and rollback.
- `LocalFirstCloudKitContinuitySyncCoordinator` queues local changes and prepares the CloudKit zone only when diagnostics are `healthy_after_proof`.
- Tests assert local operation is not blocked across mocked CloudKit account states.

These anchors are source ownership proof and downstream inputs. They are not proof that production CloudKit sync works or is release-ready.

## Core Rule

CloudKit sync state may influence local planning only as a bounded trust/explanation and fallback signal. It must never become:

- Source Atlas content
- R2 content
- public pack or seed material
- cloud LLM or hosted personalization input
- release/TestFlight/App Store readiness proof
- a requirement for local Ambitions operation
- a hidden user-data upload path
- a custom Ambitions backend/account substitute

Local device state remains authoritative unless a later active implementation issue proves explicit user-owned CloudKit sync behavior, conflict handling, tombstone/delete/export behavior, privacy copy, rollback, and validation.

## CloudKitSyncStateContextAdapter

Required fields:

| Field | Requirement | Red stop |
|---|---|---|
| `adapterId` | Stable local adapter id, default `cloudkit_sync_state_context`. | ID embeds account identifiers, private record names, device identifiers intended for external use, or user data. |
| `sourceKind` | `cloudkit_sync_state`. | Sync state is treated as Source Atlas/source authority. |
| `permissionScope` | `apple_user_owned_sync_state`; no broad data-read permission is implied by the context signal. | Adapter asks for or implies private data read/upload before value and control proof. |
| `syncCapabilityRef` | Reference to `SyncCapabilityStatus` or equivalent future provider. | Adapter invents a parallel sync-state model while source owners exist. |
| `permissionLedgerRef` | Link to future `PermissionLedger`/sync-control event where relevant. | User pause/revoke/account-unavailable state has no ledger/control path. |
| `dataClass` | `user_iCloud_state` for sync state, `local_only` for fallback receipts. | Marking private sync state as public/R2/downloaded source. |
| `sensitivityClass` | `sync-state`. | Missing sensitivity class or promotion to public metadata. |
| `slotTypes` | Only the slot types in this contract. | Raw CloudKit records, record names, payloads, account identifiers, or private data drive runtime directly. |
| `freshnessPolicy` | Stale/unknown/needs-review states degrade and cannot claim current sync. | Old sync status remains current after pause, account change, error, or revocation. |
| `revocationPolicy` | Disabled, paused, restricted, unavailable, or account-unavailable states invalidate current sync influence and keep local operation authoritative. | Denial/revocation breaks the app or leaves hidden stale sync assumptions active. |
| `allowedInfluence` | Trust/explanation, local fallback, conflict/review posture, export/delete warning, schedule/path reliability explanation. | Sync state silently mutates goals, Steps, schedules, source authority, or high-risk routing. |
| `storageBoundary` | Local sync diagnostics and future user-owned private CloudKit only after proof. | R2, public Source Atlas, Linear private details, support bundles, external prompts, analytics, telemetry, or public/share artifacts. |
| `receiptPolicy` | Local explanation when sync state changes user-visible trust/fallback messaging. | User-visible continuity/fallback changes with no inspectable reason. |
| `blockedUses` | Required explicit list below. | Adapter can claim readiness, force account use, publish data, or use sync as source authority. |

## Allowed Slot Types

| Slot | Meaning | May influence | Must not influence |
|---|---|---|---|
| `sync_local_only_unavailable` | CloudKit continuity is off or unavailable; local device remains authoritative. | Trust explanation, local-only copy, fallback receipts, export/delete reminders. | Blocking local operation, account nagging, readiness claims. |
| `sync_disabled` | User or build setting disables continuity. | Local-only trust posture, rollback explanation. | Hidden re-enable, degraded core value, Source Atlas/R2 publication. |
| `sync_account_unavailable` | iCloud account is absent or unavailable. | Explain local-only operation, avoid cross-device assumptions. | Treating missing account as app failure or forcing account setup. |
| `sync_restricted` | Account or policy restricts CloudKit. | Review/fallback explanation, local-only write path. | Unsafe retry loops, hidden upload, current sync claims. |
| `sync_temporarily_unavailable` | CloudKit is temporarily unavailable. | Degraded continuity explanation, retry posture, local outbox review. | Blocking local writes, claiming data loss, pressure copy. |
| `sync_paused_by_user` | User paused continuity. | Respect pause, stop sync influence, local-only explanation. | Continuing sync-derived assumptions, nagging, hidden upload. |
| `sync_needs_review` | Available status lacks proof or needs conflict/review. | Conflict/review posture, trust glyph/detail, hold sync-influenced claims. | Healthy/current claims, schedule/path mutation, release readiness. |
| `sync_healthy_after_proof` | Future proof-backed state for a scoped sync path. | Limited trust explanation after exact proof, still local-authoritative until invoked. | Release/App Store readiness, blanket user-data sync claims, M23/M26 certification. |

## State Mapping

| Source state | Context slot | Required behavior |
|---|---|---|
| `localOnlyUnavailable` | `sync_local_only_unavailable` | Local-only operation remains normal. Do not request account setup. |
| `disabled` | `sync_disabled` | Respect disabled state and record rollback/control detail. |
| `accountUnavailable` | `sync_account_unavailable` | Keep local data authoritative and explain no cross-device assumption. |
| `restricted` | `sync_restricted` | Keep local operation available; surface review only where relevant. |
| `temporarilyUnavailable` | `sync_temporarily_unavailable` | Use local queue/fallback posture; no panic or shame language. |
| `paused` | `sync_paused_by_user` | Stop current sync influence until user resumes. |
| `needsReview` | `sync_needs_review` | Hold sync-dependent behavior behind review/proof. |
| `healthyAfterProof` | `sync_healthy_after_proof` | Permit only the exact proven sync explanation; do not generalize to release readiness. |

## Context-To-Path Influence Matrix

| Signal | May influence | Must not influence |
|---|---|---|
| Local-only/unavailable sync | Fallback explanation, local receipt copy, cross-device feature affordance disabled state, export/delete reminder. | Recommended step quality, source authority, schedule install, Step graph, high-risk routing, public sharing. |
| Account unavailable/restricted | Conflict/review posture, local-only continuity explanation, user-control surface. | Blocking local planning, creating account requirement, shame/urgency pressure. |
| Temporarily unavailable | Retry/backoff explanation, local outbox count warning, last-local-success trust detail. | Hidden retries that mutate data, lost-data claims without proof, readiness claims. |
| Paused by user | Respect pause, stop sync-derived trust messaging, show local-only authority. | Continuing stale cross-device assumptions or re-enabling sync. |
| Needs review | Trust glyph/detail, conflict review queue, hold sync-current claims. | Treating remote state as authoritative, automatic conflict resolution, release proof. |
| Healthy after proof | Narrow cross-device continuity explanation for exact proven family/path. | App Store sync readiness, M23 completion, M26 certification, private data in R2/Source Atlas. |

## Privacy Boundary

Allowed local summaries:

- sync mode
- sync state
- feature flag state
- account-status category
- proof-verified boolean
- user-paused boolean
- local-only fallback state
- local-operation-blocked boolean
- writes-user-data boolean
- user-data-captured boolean
- pending/review counts when redacted and local
- local receipt or ledger references
- rollback detail

Blocked raw material:

- CloudKit record payloads
- raw goals, steps, captures, proof, receipts, local learning, preferences, tombstones, or sync ledger payloads
- CloudKit record names when they can reveal private identity
- device identifiers outside local diagnostics
- account identifiers
- zone/database identifiers beyond non-private configuration names already present in source
- conflict payload bodies
- private outbox entries
- raw error logs containing user data or secrets

Forbidden destinations:

- R2 objects
- public Source Atlas packs, seeds, claims, requirements, pathing data, manifests, release receipts, or validation reports
- Linear comments containing private sync payloads
- support bundles or diagnostics without redaction and user action
- external prompts or hosted inference context
- analytics, telemetry, crash, or engagement payloads
- public share/progress story artifacts
- screenshots or visual proof with private sync/account data

## Permission Ledger And Revocation Linkage

CloudKit sync state is not a generic platform permission prompt in this contract, but future sync controls must still be ledgered because they affect user trust.

Required ledger/control events:

- sync offered after value proof
- sync enabled
- sync disabled
- sync paused
- sync resumed
- account unavailable
- account restricted
- temporarily unavailable
- needs review
- proof verified for a specific path/family
- conflict review opened
- local fallback activated
- delete/reset/export action pending sync propagation
- rollback to local-only

Revocation behavior:

- disabled or paused sync invalidates current sync-state influence immediately
- account unavailable/restricted/unavailable states cannot block local writes
- stale `healthy_after_proof` must degrade to `needs_review` until refreshed
- conflict review must preserve local authority until future implementation proof defines otherwise
- deletion/reset/export semantics remain future-owned and cannot be implied by AMB-708

## Fixture Matrix

Later implementation/validator phases must cover at least:

- feature flag off emits local-only/unavailable slot
- disabled state keeps local operation authoritative
- no iCloud account emits account-unavailable fallback without blocking planning
- restricted account emits restricted fallback without retry pressure
- temporary unavailability emits retry/degraded explanation without local write failure
- user pause invalidates current sync influence
- unknown/available-without-proof maps to needs-review
- healthy-after-proof remains scoped and does not claim release readiness
- stale healthy proof degrades to needs-review
- conflict review blocks remote authority but not local use
- pending outbox count is local/redacted and not public proof
- delete/reset/export pending propagation does not resurrect data
- sync state never enters Source Atlas, R2, Linear private detail, support bundle, external prompt, analytics, telemetry, crash, or public/share artifact
- fixture/test/generated sync states are not treated as production runtime proof

## Red Conditions

- Sync state is used to claim iCloud/CloudKit release readiness.
- CloudKit account availability becomes required for basic Ambitions operation.
- Local writes are blocked because CloudKit is disabled, paused, unavailable, restricted, or needs review.
- Stale/revoked/paused sync state remains current.
- Sync state is treated as Source Atlas content, source authority, R2 material, public proof, analytics, telemetry, or external model context.
- CloudKit record payloads, private record names, account identifiers, or conflict bodies enter Linear, logs, public artifacts, support bundles, screenshots, or R2.
- A custom Ambitions account/backend is introduced as a sync dependency.
- Fixture/test/generated sync states are treated as production proof.

## Downstream Consumers

- AMB-771 / PLOS-087 Permission value proof pattern
- AMB-710 / PLOS-088 Permission ledger and revocation controls
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-621 / PLOS-M14 Step Elasticity Engine
- AMB-622 / PLOS-M15 Schedule Install Kernel
- AMB-628 / PLOS-M19 Performance Runtime hardening
- AMB-632 / PLOS-M23 CloudKit/iCloud sync hardening
- AMB-635 / PLOS-M26 certification gauntlets

## Non-Claims

AMB-708 does not claim app source change, Swift/domain implementation, runtime adapter implementation, CloudKit environment setup, CloudKit transport implementation, account setup, entitlement change, privacy manifest change, runtime sync integration, user-data upload, user-data mutation, conflict UI, delete/reset/export propagation, UI implementation, screenshot proof, accessibility proof, device proof, measured performance proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, App Review readiness, R2 write, Source Atlas publication, production certification, AMB-616 parent completion, or full PLOS project completion.
