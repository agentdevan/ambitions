+++
initiative = "user-owned-cloudkit-continuity"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Ambitions is local-first and must remain fully useful without an account or
network. People may nevertheless expect optional continuity across their own
Apple devices and recovery after a device is lost or replaced. For a private
life graph, a conventional “turn on sync” treatment is unsafe: remote transport
must not become command authority, the only readable copy, a hidden hosted
profile, or a source of silent data loss.

The user problem is whether Ambitions can offer understandable, optional,
user-owned CloudKit continuity while every device remains locally usable and
authoritative. A viable direction must preserve accepted offline work, exact
identity and history, deterministic conflict and deletion semantics, account
separation, migration and interruption recovery, and an honest explanation of
what has and has not reached the user’s iCloud storage. It must also justify a
substantially higher privacy, data-loss, operations, and physical-device proof
burden than local-only use.

## Current truth

This Research inspected repository `main` at
`f6d870d6cbbf688b2ead47a34d4381fb75367786`, current canon, the complete live
Continuity owner, focused tests, persistence/repair and privacy boundaries,
the current known-issue register, relevant approved product-development
initiatives, Apple’s current documentation, and the installed iOS 26.5 SDK.

Current authority is deliberately restrictive:

- `LAW-LOCAL-AUTHORITY-001` and `LAW-OFFLINE-NO-ACCOUNT-001` keep private
  decision authority and the complete core local, readable, mutable, and
  replayable without sign-in or network.
- `LAW-ACCOUNT-BOUNDARY-001` forbids Ambitions Account from storing,
  synchronizing, profiling, or inferring from the private graph and separates
  account deletion from local-data deletion.
- `PRIVACY-CLOUDKIT-CONTINUITY-001`, `SYSTEM-CONTINUITY-DISABLED-001`, and
  `SYSTEM-CONTINUITY-COMMAND-CONTRACT-001` form a conjunctive disabled gate.
  Until every privacy, identity, conflict, deletion, account, restore,
  migration, interruption, environment, observability, rollback, and proof
  cell passes, the only active behavior is non-mutating continuity-status
  inspection.
- `SYSTEM-CONTINUITY-SEPARATION-001` permits only optional user-owned iCloud
  transport subordinate to local state. CloudKit cannot be command, policy,
  sole-copy, hosted-private-backend, or local-core authority.
- `LAW-DATA-LOSS-STOP-SHIP-001` makes any reproducible silent loss of accepted,
  unsynced, unexported, or unrestorable data a blocker for the affected claim.

Live source is more than an empty stub but is not production continuity:

- `LocalAuthoritativeSyncModel.swift` defaults the feature flag off and reports
  local-only/account posture. Production composition injects
  `LocalOnlySyncCapability`; it does not run a live continuity coordinator.
- `ContinuityAuthorityGate.swift`, `SyncEligibilityPolicy.swift`,
  `SyncEnvelope.swift`, `CausalMergeEngine.swift`, `ConflictPolicyEngine.swift`,
  and `TombstoneSync.swift` model selected eligibility, envelope, scalar causal,
  quarantine, and deletion concepts. They do not define complete object-family
  eligibility, a durable causal graph, old-client behavior, or a production
  merge protocol.
- `CloudKitContinuityClient.swift` can inspect account status and prepare one
  custom zone, but the default client is static and its outbox is in memory.
  No `CKSyncEngine`, durable engine state, durable outbox, fetched-change
  ingestion, production batching, account epoch, or background delegate exists.
- `ObjectStoreSwiftData.swift` explicitly configures local stores with
  `cloudKitDatabase: .none`. `NetworkEgressPolicy.swift` and
  `EgressFirewall.swift` currently deny private-graph CloudKit egress even when
  a feature boolean is present.
- `Ambitions.entitlements` names `iCloud.com.ambitions.ios` and the CloudKit
  service, but the app currently lacks CKSyncEngine’s Remote notifications
  configuration. Entitlement presence is not container, schema, environment,
  privacy, or transport proof.
- focused tests prove model and fail-closed behaviors, including default-off,
  no-account local use, selected quarantine, and no zone setup before a proof
  boolean. They use static clients and in-memory state. They do not establish
  durable relaunch, real records, two-device divergence, account switching,
  device-loss recovery, encrypted-field behavior, schema deployment, migration,
  privacy approval, or release safety.

`AMB-ISSUE-2006` therefore remains open: zones/schema, stable identities,
tombstones, conflict policy, retry/backoff, migration, and multi-device proof
are not launch-proven. The approved `user-profile-archive-import`,
`capability-export`, and `capability-continuity-foundation` initiatives reinforce
applicable boundaries: outside effects and copies stay distinct from local
truth; deletion scopes do not silently cascade; replay does not repeat external
effects; private derived records stay out of Account, R2, Source Atlas, and
telemetry; and migration requires idempotent recovery and non-reconstructive
tombstones. They do not authorize or prove CloudKit continuity.

## Evidence

Repository evidence establishes a useful conceptual starting point and a high
proof ceiling. Local authority, eligibility, causal comparison, conflicts,
tombstones, account states, cleanup events, diagnostics, egress policy, and
pre-migration backup concepts exist as separate seams. The same evidence shows
that current “healthy after proof” and `proofVerified` booleans are assertions,
not the complete gate or runtime proof, and that the current scalar
revision/time/device ordering can silently choose one concurrent copy unless a
stronger causal model replaces it.

Apple’s current `CKSyncEngine` contract materially constrains a safe direction:

- automatic scheduling is indeterminate and depends on system conditions;
  “pending” cannot promise immediate or deadline-bound settlement;
- the app supplies pending changes and record batches, receives per-batch
  success/failure events, and remains responsible for application-specific
  errors such as server-record changes;
- engine state contains tokens, subscriptions, user identity, and pending
  changes. Apple requires the most recent opaque state serialization to be
  persisted alongside app data and restored at the next initialization;
- when the iCloud account changes, the engine resets its internal state and
  clears pending database and record-zone changes. Multiple account changes may
  collapse into one event while the app is not running. Ambitions therefore
  cannot use engine state as its only outbox and cannot infer that work pending
  for one account is safe to send to a different account; and
- the engine requires CloudKit and Remote notifications entitlements, targets
  private or shared databases rather than the public database, batches record
  changes, retries selected transient errors, and leaves semantic reconciliation
  to the app.

Primary references:

- <https://developer.apple.com/documentation/cloudkit/cksyncengine-5sie5>
- <https://developer.apple.com/documentation/cloudkit/cksyncengine-5sie5/state-swift.class>
- <https://developer.apple.com/documentation/cloudkit/cksyncengine-5sie5/event/accountchange>

Apple’s private database is owned and accessible by the signed-in iCloud user
by default and counts against that user’s iCloud quota. `CKRecord.encryptedValues`
encrypts selected values on device and decrypts them after fetch; encrypted
fields cannot be indexed or retrofitted from an existing unencrypted field.
Assets are encrypted by default. A user iCloud Keychain reset can make encrypted
CloudKit data permanently unreadable and surface as a zone-not-found condition;
Apple’s recovery guidance is to recreate zones and upload from a local cache.
That reinforces Ambitions’ local-copy authority and makes “continuity is not a
backup” a required truth, not disclaimer text.

Primary references:

- <https://developer.apple.com/documentation/cloudkit/ckcontainer/privateclouddatabase>
- <https://developer.apple.com/documentation/cloudkit/ckrecord/encryptedvalues>
- <https://developer.apple.com/documentation/cloudkit/encrypting-user-data>

A valid implementation experiment must use a non-production fixture container
and at least two physical Apple devices. It must cover concurrent and same-field
edits; offline divergence; deletion and attempted resurrection; relaunch during
every checkpoint; partial batches; quota, throttling, token, network, zone, and
encrypted-key failures; account A sign-out and account B sign-in; old schemas
and clients; restore into empty and non-empty local stores; remote zone loss;
and intentional rollback. Model unit tests, a simulator, and one successful
upload are insufficient.

## Alternatives

1. **Remain local-only and provide verified user-controlled backup/export.**
   This preserves the strongest authority boundary and avoids merge risk, but it
   does not provide ongoing multi-device continuity.
2. **Use `NSPersistentCloudKitContainer` as a managed replica.** This reduces
   transport code but couples persistence and CloudKit replication more tightly
   and offers less explicit control over Ambitions’ event eligibility, causal
   policy, account-scoped outbox, quarantine, and migration requirements.
3. **Use `CKSyncEngine` with an Ambitions-owned durable local continuity
   journal.** This best matches an existing local-authoritative store: the
   platform can schedule private-database transport while Ambitions owns
   eligibility, encrypted record construction, outbox durability, account
   epochs, merge, conflict, tombstone, migration, Receipt, and local commit
   semantics. It also leaves a substantial correctness and operations burden.
4. **Use lower-level CloudKit operations.** This gives maximum scheduling and
   token control but duplicates more retry, subscription, batching, account, and
   state machinery that CKSyncEngine already supplies.
5. **Use Ambitions Account, R2, or another Ambitions private backend.** Current
   canon forbids this direction; it would change the product’s privacy and
   authority model rather than implement user-owned continuity.
6. **Enable a convenient subset before the full gate passes.** A partial record
   or device subset can still cause resurrection, cross-account disclosure,
   restore duplication, or silent loss. The current gate is intentionally
   conjunctive and rejects safety-by-subset claims.

## Unknowns and risks

- Exact object-family and field eligibility needs a closed classification
  matrix. Attachments, protected/sensitive facts, device-local preferences,
  derived projections, diagnostics, and transient operation state cannot inherit
  eligibility from broad “private graph” membership.
- A version-vector/event-causality model, compaction horizon, tombstone retention
  rule, and old-client floor must preserve deterministic meaning without
  indefinite private-content retention.
- Conflict comparison must translate object-owner semantics into understandable
  consequences. A generic record diff or timestamp choice is not sufficient.
- A durable outbox independent of CKSyncEngine must avoid duplicate delivery,
  survive state reset, and isolate account epochs without turning local history
  into a second remote authority.
- Initial enablement, restore, re-enable, account switch, key reset, and zone
  recreation all combine local and remote populations. Each needs a dry run,
  verified checkpoint, duplicate prevention, and explicit consequence review.
- CloudKit encrypted fields improve protection but constrain indexing and schema
  evolution. iCloud Keychain reset, user-deleted zones, quota exhaustion, and
  loss of every device’s local copy remain real data-loss ceilings.
- The continuity control center can become operationally noisy or imply an
  Ambitions account. Copy and state design must identify iCloud as optional
  user-owned storage and preserve ordinary local use during every failure.
- Development/production schema promotion, entitlement changes, privacy review,
  production rollback, and support diagnostics are operational product risks,
  not one-time coding tasks.
- Physical two-device proof is mandatory but still cannot prove every production
  account, network, quota, or service condition. Release claims need an explicit
  residual-risk ceiling.

These are Design and verification obligations, not unresolved product forks.
If no implementation can preserve local authority, account isolation,
deterministic history/deletion, and humane recovery under these constraints,
continuity must remain disabled and local-only use remains the product.

## Recommended direction

Advance to a bounded Scope for **optional user-owned CloudKit continuity** while
keeping production continuity disabled and local/no-account operation fully
authoritative. CKSyncEngine over the user’s private CloudKit database is the
leading technical hypothesis for Design to validate, not an architecture
commitment made by Research. Any selected design must leave eligibility,
identity, conflict, tombstone, migration, Receipt, account-isolation, and
recovery meaning under Ambitions’ local owners.

The product direction should make enablement a reviewed opt-in only after the
complete gate passes; treat pending work as local and timing-indeterminate; keep
different iCloud accounts isolated; require human review before any prior- or
unbound-account payload can enter a different account; protect eligible private
content with a reviewed encryption and key-recovery contract; and make pause,
turn-off, remote deletion, restore, migration, and conflict choices separate
consequence-bearing actions.

The initiative should deliver a complete executable gate and physical
multi-device evidence contract, not pre-authorize transport. If implementation
or proof is incomplete, the shippable result remains disabled status inspection
with no CloudKit read or write. No Research approval, Scope, Design, entitlement,
schema, source presence, model test, simulator run, or successful upload alone
constitutes implementation, privacy, device, release, or App Store proof.

Review verdict: **PASS** after grounding the current disabled posture, local
authority boundary, independent durable-outbox requirement, account-reset and
key-reset behavior, deterministic conflict/tombstone obligations, and exact-
revision physical multi-device proof ceiling. Devan delegated phase approval;
Research approved 2026-08-05.
