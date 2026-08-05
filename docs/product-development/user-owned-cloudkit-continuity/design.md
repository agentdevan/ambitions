+++
initiative = "user-owned-cloudkit-continuity"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Ambitions keeps its existing local stores and LocalRuntimeOS command/event
authority. Optional continuity is a subordinate transport projection over the
signed-in user’s private CloudKit database. The selected transport is
`CKSyncEngine`, configured only with `CKContainer(identifier:
"iCloud.com.ambitions.ios").privateCloudDatabase` and custom zone
`AmbitionsCoreZone`. Public/shared databases, `NSPersistentCloudKitContainer`,
Ambitions Account, R2, Source Atlas, and any Ambitions private backend are
structurally absent from this path.

`CKSyncEngine` schedules and retries platform work; it does not own semantic
truth. Ambitions durably persists the newest engine state serialization, but an
independent local outbox is authoritative for unsent intent because Apple clears
engine pending changes when the iCloud account changes. Account epochs prevent
account-A or unbound payloads from entering account B without a new explicit
reconciliation. All downloaded records stage, validate, causally reconcile, and
commit through idempotent local owner commands before projections change.

Production remains in `disabled` posture unless an immutable release-gate
manifest binds every Scope gate cell to exact source/build/schema/container and
physical-device evidence. No feature flag or document approval overrides it.

## User flows

### Disabled status and enablement

1. `You → Account & Sync → Continuity` opens at current local authority. While
   the release gate is incomplete, it shows only `Review Continuity Status`, the
   failed/missing gate categories, and “Saved information remains on this
   iPhone.” It instantiates no CKSyncEngine and performs no CloudKit operation.
2. A gate-complete build offers `Enable Continuity`. Preflight verifies protected
   local stores, a fresh rollback checkpoint, iCloud account availability,
   compile-time environment/container, deployed schema revision, consent/policy
   revision, and local inventory. Failure returns to `blocked` without egress.
3. After the user accepts the iCloud/private-storage, timing, quota, encryption,
   local-authority, and non-backup explanation, Ambitions creates an account
   epoch and performs a read-only remote inventory. It shows local-only,
   remote-only, equal, divergent, tombstoned, incompatible, and unreadable
   counts plus the exact proposed upload, local ingestion, merge, or quarantine.
4. Changing account, schema, policy, inventory, or checkpoint invalidates the
   preview. `Confirm Initial Reconciliation` commits one local enablement Command
   and Receipt, then creates revision-bound outbox intents. Remote facts still
   enter only through their local owners. Completion requires acknowledged
   batches and a final inventory comparison; otherwise status remains pending,
   conflicted, or blocked.

### Ordinary local change and remote receipt

1. An owning local Command commits Event, canonical state, Projection, Receipt,
   and History without waiting for CloudKit.
2. `ContinuityOutboxProjector` tails committed Event sequence from a durable
   cursor. In one ContinuityStore transaction it creates or supersedes an
   idempotent intent and advances the cursor. A crash before that transaction
   simply replays the same Event.
3. The coordinator adds only current-account, current-policy eligible intent IDs
   to CKSyncEngine. `nextRecordZoneChangeBatch` reconstructs records from the
   durable outbox and applies a versioned configuration ceiling that is no
   greater than the selected SDK/environment limit, plus measured byte and asset
   limits. Batch construction never deletes the local intent.
4. Per-record sent events mark only acknowledged matching revisions settled.
   Retryable failures remain pending; semantic/server-record conflicts stage for
   reconciliation; terminal eligibility/schema failures quarantine. UI copy says
   local, pending, sending, or acknowledged—not “saved everywhere.”
5. Fetched records first enter an encrypted inbox. Validation checks container,
   environment, account epoch, record identity, protocol/schema/policy,
   encrypted payload digest, causal context, owner eligibility, and tombstone.
   An idempotent owner Command applies a dominating change, performs a registered
   deterministic merge, or creates quarantine. Engine state is persisted only
   after prior fetched effects are durable; a crash before state persistence
   causes harmless refetch and command deduplication.

### Account loss, same-account return, and account switch

1. An account-change event immediately cancels engine operations, closes batch
   supply, freezes the old account epoch, discards that epoch’s engine
   serialization, and clears account-scoped remote cache/system fields. Local
   canonical data, outbox intents, quarantine, History, and local use remain.
2. Changes accepted with no account create `unbound` intents. Existing account-A
   intents remain frozen as A; neither set can be added to another engine.
3. On same-account return, a locally keyed HMAC fingerprint of the current
   `CKRecord.ID` matches the frozen epoch. Ambitions revalidates gate, consent,
   schema, remote inventory, and pending digests before offering Resume.
4. On account B or an indeterminate transition, status is `accountReview`.
   Ambitions shows that prior-account pending work will not be sent. The user may
   keep continuity off or start a fresh B reconciliation. Confirmation creates
   new B intents from current canonical local truth; it never rebinds or reuses
   A/unbound payload entries. Raw account IDs are never persisted or displayed.

### Conflict and tombstone handling

- A dotted version vector compares each object’s causal frontier. Dominating
  revisions apply; equal event ID plus content digest deduplicates. Concurrent
  edits merge only through a versioned object-owner field policy whose operation
  is commutative, associative, idempotent, and fixture-proven. Wall time,
  CloudKit change tag, arrival order, and device label never choose meaning.
- Concurrent same-field changes, same-clock payload drift, missing lineage,
  unknown policy, and delete-versus-concurrent-edit preserve both encrypted
  alternatives in quarantine while current local truth remains unchanged.
  Review presents owner-language differences and only supported `Keep This
  Device`, `Keep Other Copy`, or field selections. The chosen local Command is
  revision-bound and Receipt-backed; stale review returns to comparison.
- A deletion is transported as an encrypted tombstone record, not immediate
  CloudKit record deletion. A tombstone dominates older live vectors; a later
  restore is a new causal event. After every supported client horizon and known
  replica acknowledgement, it compacts to record identity plus deletion causal
  frontier and event digest with no deleted content. That content-free marker
  remains while the continuity scope exists to prevent resurrection.

### Pause, turn off, and remote deletion

- `Pause Continuity` commits locally, stops new engine scheduling, and calls
  `cancelOperations()`. Pending work remains durable. Any in-flight unknown
  result becomes `reconciling`; pause never claims recall.
- `Resume Continuity` requires current account, gate, consent, state,
  reconciliation, and schema checks. It creates no duplicate intent.
- `Turn Off Continuity` stops future automatic transport, retires active engine
  state, and retains local data, local continuity History, frozen pending facts,
  and existing remote records. Re-enable always uses initial reconciliation.
- `Delete Remote Continuity Copy` is a separate protected flow. It verifies the
  reviewed account, readable local authority, checkpoint, conflicts, and exact
  zone consequence, then submits deletion of `AmbitionsCoreZone`. Local data is
  never selected. Unknown/partial response remains `remoteDeleting` until a
  fetch proves absence. Success retires remote metadata and account epoch but
  does not delete local objects.

### Restore, migration, encrypted-key reset, and zone loss

- A replacement/empty device reads a compatible remote inventory into staging,
  previews counts and recovery limits, then imports via local owner Commands. A
  non-empty device uses the same causal reconciliation and quarantine path.
  Checkpoint plus applied-command IDs prevent duplicate restore after relaunch.
- Schema changes are additive and versioned. A new writer dual-reads supported
  old/new envelopes; an old client may read only its declared versions and is
  blocked from writes that would erase unknown fields. Migration requires dry
  run, local checkpoint, remote inventory checkpoint, explicit confirmation,
  resumable per-record progress, and roll-forward or app rollback that continues
  to read both versions. Production CloudKit schema changes are never rolled
  back destructively.
- `CKErrorUserDidResetEncryptedDataKey`, user-deleted zone, and unexplained
  missing zone enter `remoteDataUnavailable`; absence is not a local deletion.
  With readable local truth, the user may confirm new account/causal epoch, zone
  recreation, and reupload after a fresh checkpoint. Without a readable local
  copy, the UI states that Ambitions cannot recover the missing data.

## States and recovery

| State | Durable meaning | Recovery/actions |
| --- | --- | --- |
| `disabled` | Release gate incomplete; no engine or CloudKit I/O. | Review gate; local use continues. |
| `ineligible` | Account/device/protection/schema cannot qualify. | Resolve named condition or remain local-only. |
| `eligibleNotEnabled` | Gate complete; no consent or remote scope. | Enable preflight. |
| `preflighting` | Local/account/environment/checkpoint checks only. | Cancel safely; no remote mutation. |
| `awaitingInitialReview` | Read-only inventories and exact plan are revision-bound. | Confirm or cancel; changed inputs invalidate. |
| `enabledIdle` | Current account/consent valid; no known pending scope. | Refresh, pause, turn off. |
| `localPending` | Local commits have durable unsent intents. | Wait, request send, pause; no ETA. |
| `sending` | One identified batch is being supplied/sent. | Cancel to pause; reconcile unknown result. |
| `remotePending` / `receiving` | Server changes are known or staged. | Fetch/validate/apply; local work remains open. |
| `reconciling` | Result or local/remote equality is not yet proven. | Idempotent inventory/checkpoint comparison. |
| `conflictedQuarantined` | Both alternatives are protected; local accepted truth unchanged. | Review owner-supported choices. |
| `retrying` | Retryable failure with bounded next attempt. | Wait, request retry, pause. |
| `paused` | No new transport; durable intent retained. | Resume after full revalidation or turn off. |
| `unavailable` / `signedOut` | Network/iCloud unavailable; local core unaffected. | System recovery, same-account revalidation. |
| `accountReview` | Current account differs or cannot be proven. | Keep off or fresh-account reconciliation; no old payload send. |
| `migrating` | Checkpointed per-record additive transition in progress. | Resume, roll forward, or compatible app rollback. |
| `restoring` | Remote candidates are staging/committing locally. | Resume idempotently; conflicts quarantine. |
| `remoteDeleting` | Separate zone deletion is pending or unverified. | Reconcile, retry, or report blocked; local stays. |
| `remoteDataUnavailable` | Key reset/deleted/missing zone; no deletion inference. | Recreate/reupload from local after review, or state non-recovery. |
| `blocked` | Gate, corruption, unknown version, privacy, quota, or checkpoint blocker. | Named repair/export/status route; never bypass. |
| `settled` | Exact inventory frontier is acknowledged for the recorded time/scope. | New local work returns to pending. |

Every operation journal includes operation ID, account epoch, expected local and
remote frontiers, gate/policy/schema revisions, checkpoint, phase, per-item
outcome, retry metadata, and stable semantic focus ID. Before local command
commit, cancellation changes no canonical data. After commit, recovery resumes
the exact operation; it never rewinds accepted local work or repeats a remote
effect during replay. Low storage, protected-data unavailability, corrupt state,
or state checksum mismatch blocks transport and preserves source bytes.

## Architecture and data

### Components and ownership

- Existing canonical object Commands, EventJournal, stores, projections,
  Receipts, History, replay, and tombstone owners remain authoritative.
- `ContinuityAuthorityGate` consumes a generated closed eligibility manifest and
  release-gate manifest; it cannot infer eligibility from broad privacy class.
- `ContinuityOutboxProjector` derives durable intent from committed Events.
  `ContinuityStore` owns consent, account epochs, outbox, inbox, engine state,
  system fields, cursors, quarantine, operation journals, and redacted ledger.
- `CKSyncEngineContinuityDriver` is the sole CloudKit adapter and always uses the
  compile-time environment manifest’s private database and custom zone.
- `ContinuityReconciler` validates envelopes and invokes typed local-owner
  commands. It cannot write canonical stores or projections directly.
- Boundary/PrivacySecurity enforce destination and field protection. Inspection
  owns redacted diagnostics. You owns presentation/focus, not transport.
- Quality owns executable release-gate evaluation; production composition uses
  `DisabledContinuityCapability` unless the immutable exact-revision manifest is
  complete. The existing boolean `proofVerified` is removed as authority.

### Durable stores and transaction rules

`ContinuityStore.sqlite` is actor-isolated under the canonical local runtime
storage root and contains versioned tables:

- `continuity_control`: release-gate digest, consent revision, state, operation,
  environment, schema/policy revisions, checkpoint, and local Event cursor;
- `account_epochs`: random epoch ID, device-local keyed account fingerprint,
  status, consent binding, and no raw CK user record ID;
- `outbox`: intent/event/object IDs, account binding (`epoch` or `unbound`),
  operation, source revision/digest, dotted vector, encrypted local payload
  locator, attachment locators, status, attempt, and acknowledgement;
- `inbox`: fetched system fields, encrypted record bytes, account/environment,
  validation, owner-command ID, and applied/quarantined result;
- `engine_state`: latest `CKSyncEngine.State.Serialization` bytes keyed by
  environment/container/database/account epoch with checksum and generation;
- `remote_records`: opaque record ID, encoded CK system fields/change tag,
  schema, causal/content digest, tombstone phase, and last acknowledgement;
- `quarantine`: two-sided encrypted candidates, reason/policy, frontiers,
  review revision, and resolution command; and
- `operations`/`diagnostics`: checkpointed per-item outcomes and content-free
  evidence fields.

Payload/attachment/inbox/quarantine bytes use complete file protection and are
unavailable while protected data is locked. Non-content engine scheduling state
uses the minimum protection required by measured background behavior, but no
batch is supplied and no fetch applied while content is unavailable. Writes use
SQLite transactions, checksums, fsync, and compare-and-set revisions. Outbox
creation plus cursor advance is atomic; owner-command application precedes
engine-state advancement; repeated fetch/send events are idempotent.

### Record, eligibility, and protection contract

One CloudKit record type, `AmbitionsContinuityEnvelopeV1`, avoids queryable
private categories. `CKRecord.ID.recordName` is a base32 SHA-256 opaque key over
protocol namespace plus a random canonical UUID, preserving stable equality
without encoding an owner family or user value. Unencrypted fields are limited
to protocol version, operation class, random envelope ID, and bounded chunk/
asset counts. Canonical ID, owner family, event payload, dotted vector,
causal/content/payload digests, tombstone meaning, policy details, and all user
content use `CKRecord.encryptedValues`; `CKAsset` carries eligible large bytes
and uses CloudKit asset encryption. Encrypted fields are never indexed. Digests
are domain-separated from other hash uses, verified only after decryption, and
never emitted to unencrypted metadata, diagnostics, or other destinations. CloudKit
system fields are persisted only for change tags and transport reconciliation.

The generated eligibility inventory gives every durable field exactly one
disposition:

| Disposition | Included data |
| --- | --- |
| `eligibleEncrypted` | Explicitly approved canonical owner Events/state needed to reconstruct Goals/Life Areas/Paths/Steps, Captures/drafts, Time placements, Proof/evidence, Receipts/History, user-owned capabilities/learning controls, and approved app preferences. |
| `eligibleAsset` | Owner-linked attachment whose field classification, quota, deletion, migration, and tombstone contract all pass. |
| `regenerateLocal` | Search indexes, projections, caches, thumbnails, derived schedules, and other deterministic local rebuilds. |
| `sourceOwnedLocal` | Calendar/Reminder source records, permission state, notifications, device UI state, external snapshots, and Source Atlas/R2 public caches. |
| `prohibited` | Account credentials/tokens, keys, raw account/device IDs, diagnostics payload, unsupported/protected fields, hosted-AI/telemetry/support data, and every unknown field. |

The gate fails if inventory coverage is not one-to-one. Highly sensitive or
owner-restricted fields remain prohibited until that owner’s explicit manifest
row, encrypted transport, deletion, restore, and physical proof pass; no family
inherits blanket approval.

### Causality, account epochs, and CKSyncEngine

Each installation has a random replica ID. Each owner event advances a dotted
version vector `(replicaID, counter, context)`; clocks are diagnostic only.
Compaction retains causal frontiers and content-free tombstones. Merge policies
are registered by owner + schema + field; absent/unknown policies quarantine.

The account fingerprint is HMAC-SHA256 over container, environment, and current
CK user record ID using a `WhenUnlockedThisDeviceOnly` Keychain key. It supports
same-device account comparison only and is never egressed. Account changes
archive/freeze the old epoch and initialize a fresh CKSyncEngine with `nil`
state for a new account. Because Apple resets engine state and pending changes,
the driver repopulates engine pending IDs only from eligible current-epoch
outbox rows after reconciliation. Serialized engine state is an optimization and
cursor record, never the only pending-work record.

Automatic scheduling is accepted as indeterminate. Explicit send/fetch calls
are requests with cancellable operation IDs, not completion promises. Platform-
handled transient errors stay retrying; application errors map per record to
retry, quarantine, migration, account review, or blocked. Batches use
`RecordZoneChangeBatch` capacity plus measured byte/asset ceilings.

### Environment, schema, migration, and rollout

Debug/device-proof builds use a separately provisioned development container
and entitlements; Release uses only `iCloud.com.ambitions.ios` production.
`ContinuityEnvironmentManifest` is compile-time selected and asserts bundle,
container, database scope, zone, schema digest, signing class, and release-gate
digest. Runtime switching is impossible. Production schema promotion is
reviewed from text-exported schema, diffed, additive, and verified before the
matching writer build can pass its gate.

Local migration adds ContinuityStore without changing existing local store
CloudKit configuration. First migration creates empty continuity tables and
disabled state; it sends nothing and infers no consent. Every later migration
has dry run, backup/checkpoint, minimum-reader/writer matrix, crash-resume tests,
checksum validation, quarantine, and compatible rollback. Rollout order is
disabled source and tests, development two-device proof, production-schema dry
run/promotion, signed release-candidate proof, privacy/security approval, then
explicit manifest activation. Any mismatch returns production to disabled; it
does not delete local or remote data.

## Privacy and accessibility

All canonical content, envelopes, outbox/inbox/quarantine, account fingerprints,
conflicts, operations, and diagnostics are private local graph data. Only
manifest-eligible encrypted values/assets enter the reviewed user-private
database. No private bytes or reconstructive hashes enter Account, R2, Source
Atlas, public/shared CloudKit, backend, AI, analytics, telemetry, logs, crash or
support payloads. CloudKit encrypted fields use user iCloud key material; the UI
states that key reset or loss of all readable copies may prevent recovery.
Screen capture, locked-device presentation, clipboard, notifications, widgets,
and App Intents receive no private continuity details.

The drilldown’s semantic order is title, local-authority statement, state,
account posture, last acknowledged scope, pending/conflict/error counts,
eligible categories, consequence/recovery, then actions. Device rows mean known
Ambitions replica acknowledgements, not Apple-device management. Conflict
alternatives use headings, source-relative language, field labels, and
consequences rather than raw records. Private values are not spoken while the
privacy screen is active or protected data unavailable.

Every state/action has stable label, value, hint, heading, error, progress,
announcement, and focus ID. VoiceOver reads both conflict alternatives before
choices; Voice Control names include action and scope; Switch Control, Full
Keyboard Access, and hardware keyboard reach every command. Dynamic Type stacks
all comparison/confirmation content. Bold Text, Button Shapes, Increase
Contrast, Differentiate Without Color, Reduce Motion/Transparency, RTL, and
localization preserve meaning. Cancellation/error returns focus to the invoking
control; success focuses the result; stale revisions focus the changed fact.

## Requirement traceability

| Scope requirement | Design binding |
| --- | --- |
| REQ-001 | Existing local stores/owners remain authoritative; disabled/unavailable/account flows never block local Commands or replay. |
| REQ-002 | Immutable exact-revision release manifest, disabled production composition, closed inventory, and rollout order enforce every conjunctive cell. |
| REQ-003 | Enablement steps bind disclosure, checkpoint, read-only inventory, versioned consent, invalidation, and explicit confirmation. |
| REQ-004 | Private-database-only driver, compile-time manifest, account HMAC, and structural destination exclusions isolate the boundary. |
| REQ-005 | One-to-one eligibility inventory, encrypted values/assets, opaque routing fields, and unknown-prohibited default fail closed. |
| REQ-006 | Event-tailed independent outbox, atomic cursor, revision intent, and acknowledgement rules survive engine/account/relaunch loss. |
| REQ-007 | State copy and CKSyncEngine scheduling contract distinguish local, pending, sending, acknowledged, and exact last success without ETA. |
| REQ-008 | Dotted vectors, owner policy registry, idempotent local Commands, digest validation, and no-network replay provide determinism. |
| REQ-009 | Read-only local/remote inventories, classified plan, checkpoint, invalidation, and confirmed initial/re-enable flow prevent premature transport. |
| REQ-010 | Registered deterministic merges, two-sided encrypted quarantine, human field consequences, CAS choice, Receipt, and stale recovery resolve conflict. |
| REQ-011 | Tombstone records, causal dominance, concurrent delete quarantine, two-phase content minimization, and persistent frontier prevent resurrection. |
| REQ-012 | Account event shutdown, epoch-scoped stores, independent outbox, same-account HMAC check, and fresh-B intent creation prevent cross-account send. |
| REQ-013 | Per-item journal/outcomes, idempotency, engine-state ordering, error mapping, bounded retry, and checkpoint recovery preserve partial truth. |
| REQ-014 | Separate Pause, Resume, and Turn Off Commands define cancellation ambiguity, revalidation, durable pending retention, and no deletion. |
| REQ-015 | Protected separate zone-deletion flow, current-account/checkpoint preview, absence reconciliation, and local exclusion isolate destruction. |
| REQ-016 | Staged remote inventory, local owner import, non-empty causal reconciliation, applied IDs, and explicit non-backup/missing-data states define restore. |
| REQ-017 | Separate environments, additive encrypted schema, reader/writer matrix, unknown-version quarantine, checkpoints, dual-read, and rollback define migration. |
| REQ-018 | `remoteDataUnavailable`, no deletion inference, local continuation, fresh-epoch recreate/reupload, and no-local-copy ceiling cover key/zone loss. |
| REQ-019 | Complete state table, projected facts, replica wording, valid-action filtering, and loading/stale/protected states define the control center. |
| REQ-020 | Content-free diagnostics table, local Inspection owner, prohibited destinations, and non-authoritative records enforce redaction. |
| REQ-021 | Semantic order, conflict reading, all assistive inputs/settings, stable announcements/focus, RTL/localization, and privacy speech cover accessibility. |
| REQ-022 | Batch/byte/asset limits, actor isolation, protected-data deferral, backpressure, bounded retries, cancellation, and measured budgets constrain resources. |
| REQ-023 | Development and signed-production two-device matrices plus immutable evidence bindings and fail-closed manifest define claim proof. |

## Verification design

| Lane | Required evidence |
| --- | --- |
| Domain/unit | Closed eligibility inventory; record encoding/encryption metadata; dotted-vector dominance/concurrency; every owner merge; tombstone compaction; account epoch/fingerprint; state/action table; copy non-claims. |
| Store/command/replay | Atomic outbox cursor; crash before/after every commit/state update/ack; idempotent fetch/send; owner-command-only ingestion; quarantine CAS; no network on replay; corruption/low-storage/protected-data recovery. |
| CKSyncEngine integration | Persist/restore newest serialization; independent outbox repopulation; indeterminate scheduling; batch ceilings; per-record outcomes; transient/application errors; account event clears engine pending while local intent survives. |
| Account/privacy | Account A → signed out → account B sends zero A/unbound payload before review; same-A return; multiple changes while quit; exhaustive destination denial; raw account/key/payload absence from metadata/logs/support; encrypted-field/asset inspection. |
| Conflict/deletion | Two-device concurrent fields, same-clock drift, duplicate, delete/edit, offline old client, tombstone compaction, pause ambiguity, turn-off retention, separate zone deletion, no local cascade, no resurrection. |
| Migration/restore | Empty/non-empty restore, device replacement, duplicate prevention, every supported version, unknown old/new client, additive schema, dev/prod separation, crash points, rollback, key reset, user-deleted/missing zone, local reupload and no-local-copy ceiling. |
| UI/accessibility | Every state and command on a physical iPhone; VoiceOver, Voice Control, Switch Control, keyboard, Dynamic Type, Bold Text, Button Shapes, contrast/non-color, reduced effects, RTL/localization, protected-data privacy, announcements/focus. |
| Performance/resource | Named small/large/attachment/conflict/quota fixtures on supported devices; latency percentiles/max, memory, energy, storage/network amplification, batch/retry/cancel duration, main-thread responsiveness, and measured regression thresholds. |
| Physical multi-device | At least two signed physical iPhones prove same-account initial/ongoing continuity, offline divergence, interruption/relaunch, conflict, tombstone/no resurrection, account A/no-account/B isolation, same-A return, old-client/schema transition, replacement restore, pause/turn-off/delete, and accessibility. |
| Build/release | Generated project, entitlements and Remote notifications, signed container/environment/schema, privacy/security threat review, exact command counts, gate manifest, release rollback, and known gaps. Source/unit/simulator success alone makes no runtime/device/release claim. |

## Open decisions

There are no unresolved product or architecture decisions. Implementation may
calibrate numeric batch, retention-horizon, performance, storage, and retry
budgets from measured fixtures; choose internal SQLite indexes and SwiftUI file
decomposition; and refine owner merge implementations. It may not change the
private-database-only boundary, independent account-scoped outbox, encrypted
content contract, local command authority, deterministic quarantine/tombstone
rules, separate destructive flows, complete disabled gate, or physical
two-device proof. If any invariant cannot be implemented and proven, the only
valid production state is disabled.

Review verdict: **PASS** after repairing the metadata-protection boundary,
binding batching to the selected SDK/environment rather than an unsupported
fixed limit, and confirming complete traceability for account isolation,
independent durable intent, deterministic merge/quarantine, tombstones,
restore/migration, accessibility, and exact-revision physical-device gates.
Devan delegated phase approval; Design approved 2026-08-05.
