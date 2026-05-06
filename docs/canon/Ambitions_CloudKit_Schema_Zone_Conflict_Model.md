# Ambitions CloudKit Schema Zone Conflict Model
<!-- markdownlint-disable MD013 -->

Status: Future contract only. No CloudKit runtime, container, entitlement,
account flow, sync engine, release readiness, App Store readiness, privacy
compliance, or legal approval is claimed.
Date: 2026-05-06
Owner: Sync / Privacy / Security
Source batch: PFC10 CloudKit Schema / Zone / Conflict Model

## Current Truth

Ambitions remains explicit local-only in the current runtime:

- No account is required.
- No launch sync is implemented.
- No CloudKit container, custom zone, entitlement, sync queue, or account state
  is implemented by this contract.
- Export/import remains the current service-level portability path.
- Any user-facing copy must continue to say sync is unavailable unless later
  implementation proof changes that truth.

## Official CloudKit Constraints

PFC10 treats Apple's CloudKit documentation as the platform boundary:

- CloudKit complements an app's existing data objects; it is not a replacement
  for the local model.
- User-specific private data depends on the user's iCloud account state.
- CloudKit records are key-value records stored in a database.
- The private database supports custom record zones.
- Custom zones group related records, can support atomic operations, and do not
  support cross-zone `CKRecord.Reference` links.
- Change tracking should use zone/database changes, subscriptions, and change
  tokens only after entitlements, container setup, and privacy review exist.

References:

- https://developer.apple.com/documentation/cloudkit
- https://developer.apple.com/documentation/cloudkit/designing_and_creating_a_cloudkit_database
- https://developer.apple.com/documentation/cloudkit/ckrecordzone
- https://developer.apple.com/documentation/cloudkit/local-records
- https://developer.apple.com/documentation/cloudkit/remote-records

## Future Provider Decision

If a future human/product/platform decision chooses CloudKit, the approved
provider posture should be:

```text
Apple-first private CloudKit sync for user-owned Ambitions state.
Local database remains primary.
CloudKit is a replication and recovery path, not a hidden source of truth.
```

Server-backed sync remains out of scope unless separately approved with account,
backend, legal/privacy, security, business, data-processing, and support
decisions.

## Container And Database Contract

Future implementation must use:

- Database scope: private CloudKit database only for user life data.
- Public database: not used for personal Ambitions records.
- Shared database: not used at launch unless a later collaboration-sharing batch
  defines explicit consent, redaction, and revocation behavior.
- Container naming: final container ID must be chosen and reviewed before
  entitlement changes. This contract intentionally does not reserve or claim a
  live container.

## Zone Model

Future CloudKit work should prefer one custom private zone for core Ambitions
state at launch:

```text
AmbitionsCoreZone
```

Rationale:

- The app needs cross-object consistency between goals, steps, captures, proof,
  receipts, memory teaching signals, preferences, and deletion tombstones.
- CloudKit references cannot cross custom zones, so splitting heavily related
  user state across zones would create merge and integrity complexity.
- A single launch zone gives PFC11 one conflict domain, one subscription plan,
  and one local fallback story.

Future zones may be added only after a migration plan explains why the data can
be isolated without cross-zone references or hidden consistency loss.

## Record Families

Future record types are contract names, not implemented schema:

| Record type | Purpose | Privacy class | Merge owner |
| --- | --- | --- | --- |
| `AmbitionGoal` | Goal shell, title, lifecycle, area, created/updated metadata | User life data | Goals |
| `AmbitionStep` | Step title, state, order, goal relationship, timing hints | User life data | Goals / Today |
| `AmbitionCapture` | Captured item, placement state, waiting/delegation metadata | User life data | Capture |
| `AmbitionProof` | Proof/evidence metadata and safe references | Sensitive proof metadata | Proof / Trust |
| `AmbitionReceipt` | Closure, correction, import/export, sync, and trust receipts | Trust history | You / Trust |
| `AmbitionMemorySignal` | Explicit teaching/correction memory only | Sensitive memory | You / What Ambitions Knows |
| `AmbitionPreference` | Non-secret user preferences and feature toggles | Preference data | You |
| `AmbitionTombstone` | Deletion/correction tombstones and causal metadata | Deletion metadata | Sync |
| `AmbitionSyncLedger` | Local device cursor, schema version, and merge receipts | Sync metadata | Sync |

Excluded from future CloudKit launch sync unless separately approved:

- Raw calendar event details.
- Notification delivery payload history.
- Widget, Live Activity, screenshot, or preview rendered state.
- Crash logs, analytics events, or observability payloads.
- Hosted AI prompts, model transcripts, or external source packs.
- Secrets, tokens, credentials, App Store receipt secrets, or service keys.
- Crisis, health, legal, financial, education, or professional-advice content
  beyond the minimum user-created records already present in local state, and
  only after safety/legal review.

## Field Rules

Every future record field must be classified before implementation:

- `portable`: included in export/import and eligible for future sync.
- `sensitive`: eligible only with minimization and redaction proof.
- `localOnly`: remains local and is never written to CloudKit.
- `derived`: recomputable from local records and not synced unless needed for
  conflict review.
- `receipt`: synced only if needed to explain what happened across devices.

Each synced record must include:

- Stable local identifier.
- Schema version.
- Created timestamp and last edited timestamp.
- Last edited device identifier or pseudonymous device slot.
- Last mutation receipt identifier where available.
- Deletion/correction/tombstone relationship when applicable.

## Conflict Model

Future sync must be review-first:

- No silent destructive overwrite.
- No silent goal, plan, memory, proof, or commitment mutation.
- Field-level automatic merges are allowed only for clearly additive,
  non-conflicting collections.
- Local unsynced changes remain durable when account/network state fails.
- Ambiguous conflicts create a review receipt and keep both sides available.

Default merge rules:

| Conflict | Default behavior | User-visible proof |
| --- | --- | --- |
| Same scalar field changed on two devices | Keep local active value, preserve incoming alternate for review | Conflict receipt |
| Additive child records changed independently | Merge when parent still exists and ordering is deterministic | Sync receipt |
| Parent deleted on one device and child edited on another | Keep tombstone, quarantine incoming child for review | Deletion conflict receipt |
| Memory signal deleted or rejected on one device | Deletion/rejection wins until user re-adds it | Memory correction receipt |
| Proof/evidence edited on one device and deleted on another | Deletion wins; proof metadata remains reviewable if needed | Proof deletion receipt |
| Preference changed on two devices | Last confirmed user edit wins if non-sensitive; otherwise review | Preference receipt |

## Tombstones And Deletion

Future CloudKit sync must carry tombstones for any record that can be recreated
from another device:

- Tombstones must include record type, stable record ID, deletion receipt ID,
  deletion timestamp, device slot, and schema version.
- Tombstones should retain only the minimum metadata needed to prevent
  resurrection and explain user-visible deletion history.
- Tombstone retention must be defined before implementation and reconciled with
  privacy policy, export, delete-all-memory, and account deletion posture.
- Delete-all-memory affects memory records/signals only unless the user chooses
  a broader destructive action.

## Account, Offline, And Local-Only States

Future UI/runtime must distinguish:

- `localOnlyUnavailable`: current state; sync is not implemented.
- `notSignedIntoICloud`: iCloud account unavailable.
- `iCloudRestricted`: account exists but CloudKit is restricted.
- `networkUnavailable`: local writes continue; sync waits.
- `syncPausedByUser`: user paused sync; local writes continue.
- `syncNeedsReview`: conflicts or privacy-sensitive merge decisions exist.
- `syncHealthy`: only after PFC11 implementation and evidence.

Current runtime may only report local-only unavailable.

## Subscription And Change Token Plan

Future PFC11 implementation must prove:

- Custom zone creation is idempotent.
- Zone subscription setup is idempotent and privacy-safe.
- Change tokens are stored locally without exposing private content.
- Push notifications wake sync only for minimal metadata work.
- Remote changes are fetched into a staging area before mutation.
- Local mutation receipts can be matched to CloudKit saves.
- Retry/backoff does not drain battery or block the app.

## Privacy, Legal, And Policy Prerequisites

Before implementation or user-facing sync copy:

- PFC24 App Privacy labels must be reopened for changed data behavior.
- PFC25 privacy manifest audit must be rerun after entitlements/API usage
  changes.
- PFC26 legal/privacy packet must be reviewed by a qualified human reviewer.
- PFC28 threat model must be reopened for CloudKit/account risks.
- Privacy policy/TOS must explain private iCloud behavior, portability,
  deletion, correction, conflict handling, and account-unavailable behavior.
- App Store Connect, signing, entitlements, and CloudKit Dashboard actions must
  be performed by an authorized human/operator.

## PFC11 Test Plan

PFC11 cannot close Green unless it either explicitly defers sync or proves:

- Local-only status remains available when CloudKit is not configured.
- CloudKit account unavailable state never blocks local app use.
- Zone creation and subscription setup are idempotent.
- Record encoding/decoding round trips every approved record family.
- Tombstones prevent deleted records from resurrecting.
- Same-field conflicts produce review receipts.
- Parent deletion versus child edit conflicts quarantine safely.
- Memory deletion/correction wins over stale remote memory.
- Export/import remains compatible with synced records.
- Privacy scans find no private content in logs, notifications, widgets, Live
  Activities, App Intents, or analytics.
- Migration/rollback proof exists for enabling and disabling sync.

## Hard Red Stop Conditions

Stop if future work requires any of these without explicit approval and proof:

- CloudKit entitlement, container, signing, provisioning, or App Store Connect
  action.
- Production schema or persistence migration with data-loss risk.
- Account, backend, server, hosted AI, analytics, crash SDK, or remote logging.
- Sensitive user content in external surfaces, logs, previews, or reports.
- Sync, backup, privacy, legal, release, TestFlight, App Store, device, or
  public accessibility readiness claim without evidence.
- Conflict behavior that silently overwrites, deletes, mutates, or resurrects
  user life data.
