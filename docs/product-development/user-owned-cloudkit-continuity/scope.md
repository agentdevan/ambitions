+++
initiative = "user-owned-cloudkit-continuity"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

After the complete continuity safety gate is implemented and proven for one
exact release candidate, a user may deliberately enable optional continuity of
eligible Ambitions data through that user’s private iCloud/CloudKit storage.
Accepted work remains readable, mutable, inspectable, and replayable on each
device without Ambitions Account, iCloud availability, or network access. Local
object owners accept every mutation first; CloudKit carries approved copies and
never becomes command, policy, sole-copy, or local-core authority.

The user can understand whether continuity is disabled, awaiting consent,
pending locally, sending at an indeterminate time, receiving, reconciling,
paused, interrupted, conflicted, account-blocked, migrating, restoring, or
settled. They can inspect the affected data classes and devices; recover from
ordinary interruption; review divergent copies; pause, resume, or turn off
future transport; and separately review remote deletion or restore without
silently changing local truth.

Approval of these lifecycle documents does not open the gate. Until all
conjunctive checks and physical multi-device evidence pass at the exact source,
schema, container environment, device/OS, and build revisions, shipping behavior
remains non-mutating `Review Continuity Status` with no CloudKit record read,
write, merge, migration, restore, or deletion. Continuity is not a guaranteed
backup, not immediate consistency, and not an Ambitions account.

## In scope

- A full native `You → Account & Sync → Continuity` drilldown whose current
  shipping state remains disabled until the complete gate passes.
- Deliberate enablement with explicit consent, current account/environment
  review, eligible-data disclosure, local checkpoint, initial reconciliation
  preview, and exact consequences.
- Optional transport only through the signed-in user’s private CloudKit
  database; no public/shared database and no Ambitions-operated private store.
- A closed eligibility and protection policy for canonical records, events,
  Receipts/History, tombstones, attachments, settings, derived projections,
  sensitive fields, diagnostics, and transient state.
- Local-first commit, durable pending-change truth, deterministic identity and
  causality, idempotent batching, conflict quarantine, tombstone propagation,
  and replay-safe remote ingestion.
- Initial enablement, re-enable, same-account return, different-account switch,
  device replacement, restore into empty or non-empty local state, encrypted-key
  reset, user-deleted zone, old-client, and schema-migration behavior.
- Honest pause, resume, turn-off, retry, remote-delete, conflict, migration, and
  restore flows with distinct consequence previews and Receipts where a durable
  Ambitions-owned decision commits.
- Development/production container and schema separation, production promotion
  and rollback controls, redacted diagnostics, privacy/security review, bounded
  resource behavior, and exact-revision release gating.
- Automated, simulator, accessibility, privacy-abuse, migration, interruption,
  performance, and at least two-physical-device evidence. Physical multi-device
  proof is mandatory for any enablement or continuity claim.

## Out of scope

- Requiring Ambitions Account, Sign in with Apple, Google, subscription, or any
  other Ambitions identity for local use or CloudKit continuity.
- Storing, synchronizing, profiling, inferring from, or operating the private
  graph through Account, R2, Source Atlas, an Ambitions backend, hosted AI,
  analytics, telemetry, support payloads, or public-reference infrastructure.
- CloudKit public-database or shared-database use, person-to-person sharing,
  collaboration, family/team spaces, web access, Android, iPad, Mac, watch, or
  cross-platform sync.
- Replacing the canonical local stores with a CloudKit-backed store, allowing
  downloaded records to mutate projections directly, or treating server order,
  modification time, or last writer as semantic authority.
- A general-purpose backup product, guaranteed disaster recovery, remote
  archival retention, version browsing, or a promise that CloudKit can recover
  data after every account, keychain, zone, quota, service, or all-device loss.
- Immediate-consistency, deadline, background-completion, “saved everywhere,”
  or device-presence promises that the platform and exact runtime evidence
  cannot prove.
- Automatic account-switch migration, automatic deletion of local or remote
  data, remote deletion implied by pause/turn-off/sign-out, or conflict choices
  made without the user when semantic meaning differs.
- Transport of unknown, unclassified, local-only, prohibited, or unsupported
  data merely because another record family is eligible.
- Enabling a partial subset of transport or UI before every full-gate cell passes.

## Requirements

### REQ-001 — The local no-account core remains authoritative

Every core read, write, Command, Event, Projection, Receipt, History inspection,
repair, and replay path must remain usable without an Ambitions account,
available iCloud account, or network. A continuity failure, conflict, migration,
quota, or account condition may degrade only continuity and must not block or
roll back an accepted local mutation. CloudKit must never be the only readable
copy or a prerequisite for opening the local store.

### REQ-002 — The disabled gate is complete and conjunctive

Production continuity must remain disabled unless one exact release candidate
has current executable evidence for every canon gate cell: classification and
consent; local authority; private-container, encryption/key, Account/R2
separation; stable record/schema/causal identity; deterministic merge and human
quarantine; tombstones and deletion; offline divergence; retries, batching,
quota, token, and partial failure; iCloud unavailable/disabled, account change,
and device removal; backup/checkpoint, restore, and duplicate prevention;
pause/sign-out/turn-off/remote-delete/reset; old-client compatibility and minimum
upgrade; development/production separation; schema migration and rollback;
privacy/security/threat review; interruption/relaunch; redacted diagnostics;
physical multi-device behavior; and release rollback. A feature flag, prose,
schema, entitlement, source seam, model test, simulator, or successful upload
cannot satisfy the gate alone.

### REQ-003 — Enablement is deliberate, informed, and revocable

Before enablement, the user must see that continuity uses their iCloud private
storage, remains separate from Ambitions Account, retains local authority,
operates on indeterminate timing, consumes their iCloud quota, is not a guaranteed
backup, and includes only the named eligible data classes. They must review the
current local/remote/account/environment state, a current verified local
checkpoint, any conflict or migration blocker, and the initial reconciliation
consequence before one explicit confirmation. Consent is versioned to the exact
eligibility, schema, encryption, and consequence contract and becomes stale
when any of those materially changes.

### REQ-004 — Continuity uses only the current user’s private iCloud boundary

Eligible continuity data may enter only the private CloudKit database of the
iCloud account that the user reviewed. Public/shared databases and Ambitions
Account, R2, Source Atlas, hosted private backends, AI, analytics, telemetry,
and support channels must receive none of it. Account identifiers must remain
purpose-limited local security metadata and must not become profile, ranking,
entitlement, or cross-service identity.

### REQ-005 — Eligibility, minimization, and protection fail closed

Every transported record family and field must have an explicit versioned
classification, source owner, purpose, retention, deletion, migration,
attachment, and protection decision. Unknown, newly introduced, unclassified,
derived-cache, device-local, prohibited, or unsupported values stay local and
cannot be embedded in identifiers, unencrypted metadata, logs, indexes, or
diagnostics. Eligible private content and assets must use the reviewed CloudKit
protection contract; only the minimum non-content routing and causal metadata
may remain outside encrypted content fields.

### REQ-006 — Local acceptance and pending work survive transport failure

An accepted local mutation must commit through its canonical local owner before
continuity work exists. Its continuity intent and exact source revision must
survive app termination, device restart, low storage handling, transport-state
loss, retry, and iCloud account events independently of any platform scheduler’s
opaque state. A pending entry must be idempotent, revision-bound, and removable
only after durable acknowledged settlement, supersession, explicit quarantine,
or a user-reviewed cancellation consequence.

### REQ-007 — Scheduling and settlement language is honest

Automatic continuity timing must be presented as indeterminate. “Pending” means
accepted locally and waiting for transport or reconciliation; “sending” means a
specific batch attempt is in progress; “on this device” never implies another
device has received it. A manual retry or refresh may request work but must not
promise server acceptance, remote-device receipt, or a completion deadline.
Last success must identify the last acknowledged scope and time without implying
that all current data is settled.

### REQ-008 — Identity, causality, and replay are stable and deterministic

Each eligible object, event, attachment, tombstone, account epoch, schema,
policy, and transport intent must have stable identities and causal lineage.
Equivalent local truth, remote facts, causal history, policy, and tombstones
must produce the same accept, keep, merge, reject, or quarantine result
regardless of delivery order, wall-clock skew, device name, retry count, or
batch boundaries. Downloaded data may affect canonical state only through a
validated, idempotent local owner command whose replay performs no network
effect.

### REQ-009 — Initial enablement and re-enable reconcile before transport

Enablement and re-enable must first inspect both local and private-CloudKit
populations without mutating either. The user must see whether the remote scope
is empty, compatible, ahead, behind, divergent, account-mismatched, or
unreadable; the number and classes of affected records; conflicts, unsupported
versions, deletions, and checkpoint state; and the exact proposed upload,
download, merge, quarantine, or no-change consequence. No initial upload, download,
or merge occurs before the current preview is explicitly confirmed.

### REQ-010 — Semantic conflicts are deterministic and human-reviewable

Causally ordered, owner-defined non-overlapping changes may merge
deterministically. Concurrent same-meaning changes may deduplicate only through
an exact owner rule. Concurrent changes whose semantic consequences differ,
same-causal-identity payload drift, missing lineage, unsupported policy, and
delete-versus-edit cases must quarantine both alternatives without changing
accepted local truth. Review must explain human-meaningful differences and
offer only owner-supported `Keep This Device`, `Keep Other Copy`, or explicit
selected-change merge actions. Each choice commits locally with a Receipt and
preserves sufficient non-sensitive conflict lineage for history and rollback.

### REQ-011 — Tombstones prevent resurrection without indefinite content retention

Governed local deletion must create a versioned causal tombstone before remote
propagation. A tombstone supersedes older live copies; a causally later restore
is a distinct owner command, never inference from an old client. Tombstones must
survive the supported offline-device and old-client horizon, compaction, restore,
and replay, then minimize to the least content-free integrity fact that still
prevents resurrection. Local-only deletion never enters CloudKit. Remote
deletion failure must leave local deletion truthful and visibly pending or
blocked rather than resurrecting content.

### REQ-012 — Account changes isolate prior and current account data

Sign-out, sign-in, and account switch must pause transport, preserve local use,
invalidate account-scoped transport state, and re-evaluate the complete gate.
Pending work, remote cache, cursors, and serialized scheduler state must be
scoped to the reviewed account epoch. Work bound to account A must never be
sent to account B. Work created while no account is available is unbound local
work. Same-account return may resume only after identity, consent, state, and
schema revalidation; a different or indeterminate account requires an explicit
review of local, prior-account, and current-account consequences before any
eligible local content is newly bound or sent.

### REQ-013 — Interruption, retry, and partial failure preserve exact truth

Network loss, throttling, quota, transient service errors, token expiration,
zone busy/missing, per-record rejection, server-record change, cancellation,
background suspension, process death, low storage, and partial batches must
retain accepted local data and exact causal progress. Retry is idempotent,
bounded, backpressured, and respects platform retry guidance. Successful items
settle independently; failed and unknown items remain pending, quarantined, or
blocked with a specific next action. No whole-batch success may be inferred from
partial success or an ambiguous interruption.

### REQ-014 — Pause, resume, and turn-off have separate consequences

Pause must stop scheduling new transport and cancel in-flight work where
possible while preserving local writes and durable pending work; an operation
that may already have reached CloudKit remains `reconciling` until checked.
Resume must revalidate account, consent, gate, schema, conflicts, and pending
scope before continuing. Turn Off must stop future automatic continuity and
retain all local data; it must delete neither remote data nor local continuity
history. Re-enable returns through the full reconciliation flow.

### REQ-015 — Remote deletion is a separate destructive flow

Deleting the user’s remote Ambitions continuity copy must never be implied by
pause, turn-off, Ambitions Account sign-out/deletion, iCloud sign-out, app
deletion, or local reset. The separate flow must verify the current reviewed
iCloud account, readable local authority, a current checkpoint/recovery path,
the exact remote record/zone and pending/conflict consequences, and explicit
confirmation. It must report partial or indeterminate deletion honestly and
must not delete local canonical data. Local-data deletion remains separately
owned by each object or data-administration contract.

### REQ-016 — Restore and device replacement never silently overwrite local work

On an empty or replacement device, restore must verify account, environment,
schema, protection/key availability, checkpoint/cursor integrity, and remote
scope before previewing a local import. On a non-empty device, remote content
must reconcile causally with current local work and quarantine conflicts; it
must not become overwrite authority. Restore commits through local owners,
prevents duplicates, records a Receipt, survives interruption, and explains
that CloudKit continuity is not guaranteed backup. Missing, user-deleted, or
undecryptable remote data cannot be reported as restorable.

### REQ-017 — Schema migration, old clients, and environments fail safely

Development and production containers/schemas must remain distinct. Every
production schema change requires a compatible-reader/writer matrix, minimum
supported client, dry run, verified checkpoint, migration plan, interruption
recovery, rollback/roll-forward rule, and exact environment promotion evidence.
Unknown record, payload, causal, policy, encryption, or tombstone versions must
remain preserved and quarantined; an old or incompatible client must not write
through the gate, erase unknown fields, or cause resurrection.

### REQ-018 — Encrypted-key reset and remote zone loss preserve local authority

If CloudKit cannot decrypt eligible content, the user resets iCloud encrypted
data keys, or the remote zone is missing or user-deleted, continuity must block
and explain what is known without treating remote absence as a local deletion.
Local data remains readable and mutable. Zone recreation and upload may occur
only after account validation, a fresh local checkpoint, a complete remote-loss
preview, explicit confirmation, and a new causal/account epoch. If no readable
local copy exists, Ambitions must state that continuity cannot recover it.

### REQ-019 — The control center exposes complete, actionable state

The Continuity drilldown must distinguish disabled, ineligible,
eligible-not-enabled, enabled-idle, local-pending, sending, remote-pending,
receiving, reconciling, conflicted/quarantined, retrying, paused, unavailable,
signed-out, account-review, migrating, restoring, remote-deleting, blocked, and
settled states. It must show local authority, reviewed iCloud account posture,
eligible categories, last acknowledged success, pending/failed/conflict counts,
known devices/account epochs without pretending to manage Apple devices, and
only actions valid for the exact state. Empty, loading, stale, protected-data,
and diagnostics-unavailable states must be explicit.

### REQ-020 — Diagnostics are local, redacted, and non-authoritative

Diagnostics may retain only purpose-limited environment/container class,
gate/policy/schema versions, opaque account/device/envelope/batch/cursor/causal
identifiers, counts, result/error categories, retry state, migration/restore
phase, and Receipt links. They must not contain private payload, user-facing
content, unredacted account identifiers, encryption material, or reconstructive
hashes and must not leave the device through Account, R2, Source Atlas,
analytics, telemetry, or support. Diagnostics never authorize retry, merge,
deletion, migration, restore, or enablement.

### REQ-021 — Every continuity and recovery path is accessible

The experience must provide deterministic semantic order; headings, labels,
values, hints, progress, consequences, and named actions for every state;
VoiceOver conflict comparison and status announcements; Voice Control, Switch
Control, Full Keyboard Access, and hardware-keyboard equivalence; Dynamic Type
through accessibility sizes; Bold Text, Button Shapes, Increase Contrast,
Differentiate Without Color, Reduce Motion, Reduce Transparency, RTL, and
localization support; and stable focus on success, cancellation, interruption,
error, conflict, migration, restore, and destructive confirmation. Color,
motion, haptics, spatial position, swipe, or long press cannot be the only cue
or action.

### REQ-022 — Work is bounded, cancellable, and quota-aware

Envelope creation, encryption, attachment handling, batching, fetch, merge,
projection rebuild, migration, restore, diagnostics, and deletion must be
bounded, backpressured, cancellable where safe, and off the main actor when
material. The product must surface iCloud quota and local-storage blockers
without discarding accepted work and must not drain battery, network, memory,
or storage through unbounded retry or full-graph rebuilding.

### REQ-023 — Claims require exact-revision physical multi-device proof

Any enablement, continuity, conflict, restore, migration, privacy, accessibility,
or release claim must bind the exact source commit, build, signing/entitlements,
container and environment, deployed schema, policy/gate versions, fixtures and
hashes, device models/OS/account topology, commands, launched/executed/pass
counts, and known gaps. At least two physical iPhones must prove same-account
continuity, offline divergence, interruption, deletion/resurrection prevention,
account A → no account → account B isolation, same-account return, old-client or
schema transition, restore, pause/turn-off/remote-delete boundaries, and
accessibility. Simulator and automated evidence supplement but do not replace
physical multi-device proof.

## Acceptance criteria

1. **AC-001 (REQ-001):** With no Ambitions account, no iCloud account, and no
   network, a physical device opens existing data, creates and changes canonical
   objects, records History/Receipts, relaunches, and replays while continuity
   reports unavailable and blocks no local operation.
2. **AC-002 (REQ-002):** Removing or failing any one gate evidence cell leaves
   the production control at non-mutating disabled status and produces zero
   private-CloudKit record reads/writes, migrations, restores, or deletions.
3. **AC-003 (REQ-003):** Enablement presents the named account boundary,
   eligible classes, timing, quota, encryption/key, checkpoint, initial
   reconciliation, local-authority, and non-backup consequences; any changed
   schema/policy/preview invalidates confirmation.
4. **AC-004 (REQ-004):** Destination-matrix evidence shows eligible fixture
   bytes only in the reviewed user-private CloudKit database and zero private
   payload in public/shared CloudKit, Account, R2, Source Atlas, backend, AI,
   analytics, telemetry, diagnostics egress, or support outputs.
5. **AC-005 (REQ-005):** Exhaustive classification fixtures send every allowed
   field through the approved protection path and keep unknown, newly added,
   local-only, prohibited, derived, and unsupported fields/assets entirely
   local without encoding their values into metadata, identifiers, or logs.
6. **AC-006 (REQ-006):** A locally accepted mutation remains readable and has
   exactly one pending intent after process/device restart, transport-state
   serialization loss, retry, and account-event reset; acknowledged settlement
   removes only the matching revision-bound intent.
7. **AC-007 (REQ-007):** Delayed automatic scheduling and a manual request show
   truthful local/pending/sending/acknowledged states with no completion ETA or
   other-device claim; last success excludes newer pending revisions.
8. **AC-008 (REQ-008):** Reordering identical fetched envelopes, retries, batch
   partitions, wall clocks, and device labels yields byte-equivalent canonical
   and projection results, and replay emits no CloudKit operation.
9. **AC-009 (REQ-009):** Empty/empty, local-only, remote-only, equal, divergent,
   incompatible, account-mismatched, and unreadable preflight fixtures each show
   exact counts/consequences and perform no mutation before explicit confirmation.
10. **AC-010 (REQ-010):** Two devices editing the same semantic field offline
    preserve both alternatives and unchanged accepted local truth until a
    human-readable owner-supported choice commits once with Receipt/History;
    no timestamp or server change tag silently selects meaning.
11. **AC-011 (REQ-011):** Delete/offline-old-device/return, delete-versus-edit,
    restore, compaction, and replay fixtures never resurrect an older live copy,
    while local-only deletion never leaves the device and expired tombstones
    retain no reconstructive content.
12. **AC-012 (REQ-012):** After account A has pending and remote data, sign-out
    followed by account B sign-in sends zero A-bound or unbound payload before
    explicit review. Local work continues. Same-account return resumes only
    after identity/gate/state revalidation and preserves one pending intent.
13. **AC-013 (REQ-013):** Fault injection at every batch/checkpoint produces
    exact acknowledged, pending, failed, quarantined, and unknown item sets;
    retries create no duplicate local or remote semantic effect and respect
    bounded backoff/quota behavior.
14. **AC-014 (REQ-014):** Pause during an in-flight batch preserves local work
    and reports ambiguous scope until reconciliation; Resume revalidates before
    continuing; Turn Off stops later automatic transport while byte-equivalent
    local and existing remote records remain.
15. **AC-015 (REQ-015):** Remote deletion cannot be reached from pause, turn-off,
    sign-out, Ambitions Account deletion, app removal, or local reset. Its own
    confirmed flow deletes only the reviewed remote scope, preserves local data,
    and reports partial/unknown results per item or zone.
16. **AC-016 (REQ-016):** A replacement physical device restores an eligible
    fixture once through local owners; a non-empty device quarantines divergent
    copies; interruption resumes without duplicates; missing/undecryptable
    remote content is never reported as recovered.
17. **AC-017 (REQ-017):** Every supported upgrade, minimum-client boundary,
    unknown-version fixture, migration crash point, development/production
    promotion check, and rollback path preserves a readable local copy and
    prevents incompatible writes or field erasure.
18. **AC-018 (REQ-018):** Encrypted-key reset, user-deleted-zone, and missing-zone
    fixtures block transport without deleting local truth. Recreate/reupload is
    unavailable until fresh checkpoint, preview, account validation, and
    confirmation; no-local-copy state makes a clear non-recovery statement.
19. **AC-019 (REQ-019):** Every named state renders with correct local authority,
    account posture, counts, last success, valid actions, stale/loading/empty
    truth, and deterministic return focus; state transitions match durable facts.
20. **AC-020 (REQ-020):** Store/log/network/support inspection across success and
    every failure finds only the allowed redacted diagnostic fields and no
    payload, raw account identifier, key material, or reconstructive fingerprint.
21. **AC-021 (REQ-021):** Direct physical-iPhone accessibility verification
    completes enablement, status, conflict, interruption, migration, restore,
    pause, turn-off, and remote-delete paths with every named assistive setting
    and input mode, including deterministic announcements and focus recovery.
22. **AC-022 (REQ-022):** Representative small, large, attachment-heavy,
    conflict-heavy, quota-limited, and hostile fixtures stay within measured
    approved latency/memory/energy/storage/network/retry thresholds, remain
    responsive, and cancel or backpressure without data loss.
23. **AC-023 (REQ-023):** The release gate rejects missing or mismatched source,
    build, entitlement, environment, schema, fixture, test-count, device,
    accessibility, privacy, migration, rollback, or two-device evidence and
    cannot be overridden by a runtime feature flag.

## Frontend impact contract

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: The approved requirements, acceptance criteria, and user flows own visible terminology and non-claims; implementation must localize that meaning without inventing promotional, score, authority, or outcome language.
- Accessibility: Every new child view and action must preserve the approved semantic order, Dynamic Type/reflow, assistive-input parity, non-color meaning, focus, announcements, and reduced-effects behavior.
- Visual proof: One production-intended native fixture and viewport requires owner visual approval before implementation, followed by changed-state runtime, screenshot, accessibility, and named-device evidence required by Verification.

## Canon impact

- `docs/canon/specifications/systems/sync-and-continuity.md` remains the owning
  specification. Implementation should refine its eligible-data, account-epoch,
  pending/settlement, encrypted-key/zone-loss, tombstone horizon, state, and
  exact gate contracts without weakening the current disabled posture.
- `docs/canon/specifications/systems/privacy-and-data-classification.md` needs a
  purpose-bound private-CloudKit continuity class distinct from Account/R2,
  public reference, diagnostics, and hosted-private-backend egress.
- `docs/canon/specifications/systems/persistence-and-replay.md` needs the durable
  continuity intent, transport-state, account isolation, idempotent ingestion,
  no-network-on-replay, checkpoint, compaction, and migration invariants.
- `docs/canon/specifications/journeys/backup-restore-reset.md` needs to distinguish
  continuity from backup and own initial reconciliation, device replacement,
  key/zone loss, remote deletion, duplicate prevention, and recovery ceilings.
- `docs/canon/specifications/surfaces/you.md` and the canonical UX blueprint need
  the complete future-gated Continuity drilldown, states, copy, commands,
  consequences, focus, and accessibility mappings while preserving disabled
  status until proof passes.
- Engineering testing, security/privacy, accessibility, performance, and
  release standards need the exact-revision two-device and production
  environment proof contract. No canon change in this initiative directory
  itself authorizes source implementation or feature enablement.

## Risks and open decisions

There are no unresolved product decisions in this Scope. It commits optional
user-private continuity, complete local/no-account authority, a conjunctive
disabled gate, account isolation with explicit cross-account review,
deterministic quarantine and tombstones, separate destructive flows, honest
indeterminate timing and recovery, and physical multi-device proof.

Design must resolve the technical representation of causal history, account
epochs, durable intent and scheduler state, record/field/attachment eligibility,
encrypted fields and key-reset handling, batching/checkpoints, tombstone and
old-client horizons, local command ingestion, schema migration, UI state
projection, and exact proof fixtures. These choices may not weaken the product
requirements above.

The principal stop condition is data safety: if the selected architecture cannot
prove that account B receives no account-A or unreviewed-unbound payload, cannot
prevent resurrection and silent conflict loss, cannot preserve accepted local
work through scheduler/account/interruption resets, or cannot produce the
complete physical-device and rollback evidence, implementation must leave
continuity disabled. That is a gate result, not authority to narrow the gate or
ship a partial subset.

Review verdict: **PASS** after resolving the private-database-only boundary,
complete conjunctive disabled gate, fail-closed eligibility, account-epoch
isolation, durable pending truth, deterministic merge/quarantine and tombstones,
distinct pause/turn-off/remote-delete flows, migration/restore behavior,
accessibility, and exact-revision physical multi-device proof. Devan delegated
phase approval; Scope approved 2026-08-05.
