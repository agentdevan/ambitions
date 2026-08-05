+++
initiative = "user-owned-cloudkit-continuity"
document_type = "research"
status = "draft"
upstream = ""
+++

## Idea and user problem

Ambitions is local-first and must remain fully useful without an account or
network. People may nevertheless expect optional continuity across their own
Apple devices, recovery from device loss, and an understandable way to inspect
or resolve divergent copies. For a private life graph, a conventional “turn on
sync” treatment is unsafe: remote transport must not become command authority,
the only readable copy, a hidden hosted profile, or a source of silent data loss.

The user problem is to determine whether Ambitions can offer optional,
user-owned CloudKit continuity while keeping every device locally usable,
preserving exact history and deletion semantics, quarantining meaningful
conflicts, surviving account and network changes, and making failure or
uncertainty visible. The research must also determine whether the product and
proof burden is justified now, rather than assuming that existing CloudKit
scaffolding or platform availability makes enablement desirable.

## Current truth

This Research inspected repository `main` at
`ccaed087708facd99780c5fb84590be4bde90d88`, current canon, live continuity
source and tests, and the current known-issue register.

Current authority is deliberately restrictive:

- `PRIVACY-CLOUDKIT-CONTINUITY-001` requires local/no-account use and keeps
  user-owned CloudKit continuity disabled until privacy, conflict, recovery,
  migration, and proof requirements pass.
- `SYSTEM-CONTINUITY-SEPARATION-001` makes local device state authoritative
  offline and forbids CloudKit from becoming command, policy, sole-copy, or
  local-core authority.
- `SYSTEM-CONTINUITY-DISABLED-001` is a conjunctive gate over data
  classification, consent, identity, schema, merge, deletion, offline
  divergence, retries, account changes, restore, migration, privacy, security,
  interruption, diagnostics, and rollback.
- the only currently authorized user behavior is non-mutating continuity-status
  inspection. Enable, upload, download, merge, restore, migration, remote
  deletion, conflict choice, pause, resume, and retry remain future-gated.

Live source is more than an empty stub but is not production continuity:

- `LocalAuthoritativeSyncModel.swift` defaults the feature flag off and exposes
  local-only diagnostics and account-state posture.
- `ContinuityAuthorityGate.swift` and `SyncEligibilityPolicy.swift` restrict
  transport to eligible envelopes while preserving local/no-account authority.
- `SyncEnvelope.swift`, `CausalMergeEngine.swift`, `ConflictPolicyEngine.swift`,
  and `TombstoneSync.swift` model versioned envelopes, causal comparison,
  conflict quarantine, and deletion propagation concepts.
- `SignOutDeleteResetCoordinator.swift` models distinct sign-out, account
  deletion, local reset, and remote-cleanup consequences.
- `CloudKitContinuityClient.swift` includes private-zone preparation seams, but
  the default coordinator uses a static client and an in-memory outbox.
- focused tests prove selected model and fail-closed behaviors. They do not
  establish durable multi-device operation, production container correctness,
  device-loss recovery, schema migration, privacy approval, or release safety.

`AMB-ISSUE-2006` therefore remains open: the CloudKit sync engine is not
launch-proof, and zones/schema, stable IDs, tombstones, conflict policy,
retry/backoff, migration, and multi-device proof remain unresolved at the
required level.

Ambitions Account and Source Atlas are not candidate sync owners. Any approved
path would use the person's iCloud/CloudKit boundary and remain subordinate to
LocalRuntimeOS, persistence/replay, privacy, inspection, You, and object owners.

## Evidence

Repository evidence establishes a credible starting point and a high proof
ceiling. The current models already distinguish local authority, eligible
transport envelopes, causal clocks, conflicts, tombstones, account states, and
cleanup events. The tests explicitly keep the feature off by default and prove
that unavailable iCloud state does not block local use. Conversely, the
in-memory outbox, static defaults, absence of complete production multi-device
evidence, and open known issue demonstrate that enablement is not currently
supported.

Apple's current CloudKit guidance presents materially different implementation
choices. `NSPersistentCloudKitContainer` offers a managed local replica when an
app accepts less granular control; `CKSyncEngine` schedules private/shared
database synchronization while the app supplies records and handles events;
lower-level CloudKit APIs require the app to manage conflict resolution,
account changes, notifications, scheduling, and persisted change tokens:
<https://developer.apple.com/documentation/cloudkit/deciding-whether-cloudkit-is-right-for-your-app>.

`CKSyncEngine` scheduling is intentionally dependent on system conditions, and
its opaque state must be persisted across launches. That rules out promises of
immediate settlement and makes interruption, retry, diagnostics, and local
authority first-class research concerns:
<https://developer.apple.com/documentation/cloudkit/cksyncengine>.

Apple's remote-record model uses subscriptions and server change tokens while
the application maintains an on-device cache. CloudKit also reports partial
errors and explicit deletion changes. These platform primitives do not choose
Ambitions' semantic merge, tombstone, history, migration, or user-conflict
policy:
<https://developer.apple.com/documentation/cloudkit/remote-records>.

A valid experiment must therefore use at least two real Apple devices and
adversarial fixtures for concurrent edits, offline divergence, deletion,
reinstall/restore, account loss/change, old schema, interrupted transfer,
partial failure, quota/backoff, stale tokens, and incompatible clients. Model
unit tests and a successful upload are insufficient.

## Alternatives

1. **Remain local-only and provide verified user-controlled backup/export.**
   This preserves the strongest authority boundary and avoids merge risk, but
   does not provide ongoing multi-device continuity.
2. **Use `NSPersistentCloudKitContainer` as a largely managed replica.** This
   reduces transport code but may not provide the explicit event, causal,
   migration, conflict, and local-authority control required by the current
   private graph and runtime.
3. **Use `CKSyncEngine` with explicit versioned envelopes and Ambitions-owned
   merge policy.** This may fit the local-authoritative model while delegating
   scheduling mechanics to the platform. It still requires durable engine
   state, outbox integration, schema ownership, conflict UX, and exhaustive
   proof.
4. **Use lower-level CloudKit operations.** This gives maximum control but has
   the largest correctness, retry, account, token, background, and maintenance
   burden.
5. **Use Ambitions Account or an Ambitions backend for private-graph sync.**
   Current canon forbids this direction; it would change the product's privacy
   and authority model rather than implement optional user-owned continuity.
6. **Enable only a convenient subset of records or devices.** Partial
   enablement can still create silent divergence, deletion, restore, and
   authority failures. The current gate is intentionally conjunctive and does
   not permit safety claims by subset.

## Unknowns and risks

- Is ongoing continuity valuable enough to justify its data-loss, privacy,
  support, testing, and release burden compared with verified backup/export?
- Which canonical Events, projections, attachments, Receipts, History, settings,
  and derived stores are eligible for transport, and which must be regenerated
  or remain device-local?
- Can one stable record and causal identity model survive schema evolution,
  object deletion/restoration, local compaction, and old-client participation?
- Which conflicts can resolve deterministically, which require quarantine, and
  how can a person compare consequences without viewing architecture jargon?
- How are tombstones retained long enough to prevent resurrection without
  keeping deleted private information indefinitely?
- What durable outbox, engine-state, retry, checkpoint, backup, and rollback
  model preserves accepted local work across crashes and account changes?
- What does turning continuity off do to remote data, pending writes, local
  copies, diagnostics, and later re-enablement? Remote deletion must remain a
  separate destructive action.
- How are CloudKit development and production environments, entitlements,
  schema deployment, encryption, privacy review, and release rollback proven?
- A passing simulator or single-device suite could create false confidence.
  Physical multi-device, interruption, migration, accessibility, privacy, and
  recovery evidence are mandatory before any enablement claim.
- The existing scaffolding may constrain the investigation prematurely. It is
  evidence to test, not an architecture that Research must preserve.

## Recommended direction

Continue to Research **optional user-owned CloudKit continuity** while keeping
the production feature disabled and local operation authoritative. The leading
hypothesis is an explicit versioned-envelope design over the private CloudKit
database, potentially using `CKSyncEngine` for transport scheduling while
Ambitions retains eligibility, semantic merge, conflict, tombstone, migration,
Receipt, and local commit authority.

Research should first compare verified backup/export, managed Core Data
mirroring, `CKSyncEngine`, and lower-level CloudKit against the complete current
gate. It should define a representative but bounded private-graph fixture and
run a technical spike that cannot mutate production user data. The spike must
falsify unsafe assumptions through concurrent edits, deletion/resurrection,
offline divergence, interruption, account change, stale schema, partial
failure, restore, and old-client cases on real devices.

The initiative should end or remain deferred if no approach can preserve local
authority, humane conflict handling, deterministic history, migration and
rollback, and acceptable operational cost. This draft does not approve Scope,
Design, CloudKit entitlement or schema changes, production transport,
implementation, migration, or user-facing enablement.
