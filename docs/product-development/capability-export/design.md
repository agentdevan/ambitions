+++
initiative = "capability-export"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Capability Export creates one purpose-bound UTF-8 plain-text summary of exact
Capability revisions for a career or education advisor. It is a selective
communication artifact, never a backup, restorable input, resume, credential
presentation, source-object export, publishing channel, or receiver-acceptance
fact. Selection and preview do not mutate source objects or authorize egress.

The renderer has a fixed field allowlist: selected Capability names,
user-reviewed short meanings, selected plain provenance/evidence labels and
dates, and explicit uncertainty/freshness notes. Every free-text segment is
classified before preview. Unknown, third-party-bearing, inferred protected,
hidden, and unreviewed source text is excluded. Known protected self-authored
content begins excluded and may be included only through an exact-text,
per-segment, purpose-and-destination-bound disclosure decision.

The user confirms the exact rendered bytes and a destination class, then chooses
either an explicit local save or a user-initiated external handoff. Local
artifact creation and external outcome are separate facts. Direct handoff uses
a protected ephemeral file and leaves no second Ambitions-retained rendered
copy after resolution. A content-minimized `CapabilityExportRecord` preserves
purpose, revision references, category/disclosure decisions, artifact
fingerprint, destination class, time, and truthful outcomes—but never rendered
text, protected values, third-party values, or recipient identity. Replay never
repeats a handoff.

## User flows

### Select and resolve content

1. The user opens **You > Capabilities > Share with a career or education
   advisor**. The introduction keeps the purpose and `.txt` output class visible
   and states that the result is non-restorable, source objects will not change,
   and an outside copy cannot be recalled or updated by Ambitions.
2. **Select Capabilities** lists stable current revisions with freshness and
   uncertainty. Selecting one or more revisions creates only an ephemeral
   session: no file, permission, detailed record, Receipt, or handoff.
3. **Choose fields** starts from the minimum allowlist. For each Capability the
   user can remove any eligible name/meaning/provenance-evidence label/date/
   uncertainty-freshness segment. Credentials, attachments, full sources,
   hidden state, internal IDs, history, and all unlisted fields have no control
   because they cannot enter the renderer.
4. The classifier returns `eligible`, `protectedSelf`, `unknown`, or
   `ineligible(reason)` per segment. Third-party identifiers, inferred protected
   facts, hidden learned state, and unreviewed source excerpts are ineligible.
   Unknown blocks preview until **Edit summary** produces eligible text or the
   segment is removed; silence never promotes it to safe.
5. Protected self-authored content remains excluded. **Consider including**
   shows that segment's exact text, protected-content reason, advisor purpose,
   chosen destination class, minimum-purpose warning, and outside-copy warning.
   **Include this segment once** records a decision bound only to that segment,
   source revision, purpose, destination, policy, and artifact revision. It
   cannot include another segment or survive a relevant change.

### Exact preview and confirmation

6. A deterministic renderer produces the complete UTF-8 bytes with fixed
   ordering, escaping, line endings, and terminal newline. **Exact preview**
   displays those bytes as selectable read-only text plus a byte count/hash and
   a separate category ledger showing included, excluded, redacted, and
   deliberately disclosed segments. Markup in the ledger never enters the
   artifact.
7. The user chooses **Save locally** or **Hand off to another app**, then a
   destination class. The preview reiterates the exact destination and outside-
   copy boundary. Recipient identity is neither requested nor stored.
8. **Confirm exact artifact** issues a single-use token bound to purpose,
   selected Capability IDs/revisions, field/segment keys, classification policy,
   disclosure decisions, exact byte hash, renderer version, and destination
   class. Any text edit, selection/revision change, field removal, disclosure,
   purpose, policy, or destination change invalidates the token and returns to a
   new preview.

### Local save

9. For **Save locally**, Ambitions generates the confirmed bytes in protected
   storage, verifies the hash, and presents the user-selected Files destination.
   If the user explicitly chooses to retain an Ambitions-managed artifact, one
   immutable encrypted copy is adopted only after exact verification. Otherwise
   only the outside Files copy remains.
10. The result independently states `created`, `cancelled`, or `failed`, names
    whether an Ambitions-managed artifact exists, repeats the outside-copy
    boundary, and links the content-minimized record and Receipt/History. Cancel
    before generation creates no file or successful record.

### External handoff

9. For **Hand off to another app**, Ambitions creates a uniquely named,
   file-protected ephemeral artifact only after confirmation and verifies its
   hash before presenting the native share surface. The handoff exposes exactly
   that file and no additional metadata or private context.
10. Provider completion settles as `handedOff`, `cancelled`, `failed`,
    `pending`, or `ambiguous`. “Handed off” means the system/provider accepted
    the handoff; it does not claim receipt, delivery, reading, retention, or
    acceptance by a person. Ambiguous is never called delivered.
11. After terminal resolution, Ambitions deletes the ephemeral rendered copy
    and verifies cleanup. The detailed record and minimized Receipt/History
    remain; a destination-owned temporary or outside copy may remain beyond
    Ambitions' control.

### Staleness, retry, and deletion

- A correction, contradiction, freshness change, or permanent deletion of a
  selected Capability marks any surviving detailed relationship stale. It does
  not rewrite an immutable retained artifact or an outside copy.
- Retry always starts a new attempt from current Capability revisions, current
  classification, new segment decisions, exact new bytes, destination review,
  and confirmation. No old disclosure token or artifact is reused.
- **Delete retained artifact** removes Ambitions-managed bytes and leaves the
  content-minimized detailed record plus non-reconstructive history.
- **Delete export record and artifact** removes revision references, decisions,
  fingerprint, outcomes, and any managed bytes. Only a content-free export fact
  and outside-copy warning may remain.
- Permanent Capability deletion previews known outside-copy possibility,
  removes that Capability's references from every detailed export record, and
  deletes every Ambitions-managed artifact containing it. It does not claim to
  affect Files, provider, application, or recipient copies.

## States and recovery

### Session and attempt state

| State | Durable meaning | Permitted action/recovery |
| --- | --- | --- |
| `selecting` | Ephemeral purpose and selected revision set only; no artifact/effect. | Select or cancel. |
| `resolvingContent` | Field and segment decisions are local draft state; unknown segments block. | Edit/remove/classify, review protected disclosure, or cancel. |
| `previewReady` | Exact renderer inputs and bytes/hash exist in protected session storage; not confirmed. | Inspect, change destination, or regenerate. |
| `confirmed` | Single-use confirmation binds the exact revision/hash/destination; no effect yet. | Execute chosen route or cancel before generation. |
| `generating` | Local pending attempt is durable; exact bytes are being generated and verified. | Relaunch resumes local generation/cleanup without external reissue. |
| `localCreated` | Local result is truthful; optional managed-artifact identity is known. | Inspect/delete record or artifact. |
| `handoffPending` | Confirmed ephemeral artifact is offered to the native provider. | Await result; cancellation depends on provider phase. |
| `handedOff` | Provider accepted the handoff; downstream delivery is unknown. | Inspect warning/record; delete managed temporary state. |
| `cancelled` | No success is claimed; before generation no file exists. | Start a fresh attempt. |
| `failed` | Exact phase/reason is recorded; no broader success. | Fresh retry or cleanup. |
| `ambiguous` | Invocation occurred but downstream outcome cannot be established. | Inspect uncertainty; never retry automatically or call delivered. |
| `cleanupRequired` | Canonical result is known, but Ambitions temporary/managed-byte deletion needs recovery. | Resume verified cleanup; content remains inaccessible to consumers. |
| `stale` | A referenced Capability revision changed or disappeared after the attempt. | Inspect historical boundary or make a fresh export. |

The local-creation outcome and external-handoff outcome are separate fields;
they cannot be collapsed into one success boolean. A direct handoff can have a
verified local temporary creation plus an ambiguous external result while still
requiring cleanup. The result UI describes each independently.

### Interruption and concurrency

Relaunch validates the session/attempt schema, source revision set, renderer and
policy versions, exact-byte hash, confirmation digest, managed/ephemeral blob
identity, external-operation state, and cleanup marker. A mismatch invalidates
confirmation and offers fresh preview or cleanup, never guessed continuation.
Before external invocation, cancellation deletes generated temporary bytes and
records no success. After invocation begins, the provider result or honest
ambiguous state settles before cleanup; UI does not promise cancellation it
cannot enforce.

A per-attempt actor serializes generation, handoff, result application, and
cleanup. Capability reads use a revision-consistent snapshot. Compare-and-set
immediately before generation rejects changed or deleted Capabilities,
classification policy, disclosure set, purpose, destination, renderer, or hash.
Only one effect may consume a confirmation token. Repeated commands return the
existing local attempt by idempotency key rather than creating another file or
handoff.

Low storage, file-provider cancellation, permission loss, protected-data
unavailability, process death, provider timeout, and cleanup failure preserve
the last honest source store and exact result. Recovery offers new destination,
fresh preview, inspect pending/ambiguous result, or verified cleanup. No export
failure mutates a Capability or treats the artifact as backup.

## Architecture and data

### Ownership and data flow

- The canonical Capability owner supplies immutable revision snapshots and
  correction/freshness/deletion notifications. Export cannot edit or become the
  Capability owner.
- `Surfaces/You/Capabilities/Export` owns purpose, selection, field/segment
  resolution, exact preview, destination, confirmation, result, staleness, and
  deletion UI. Trust owns detailed record, Receipt, History, and outside-copy
  inspection.
- `PrivacySecurity` owns field eligibility, segment classification, protected-
  self disclosure policy, destination-bound confirmation, egress firewall, and
  prohibited-destination enforcement.
- `Repair/CapabilityExport` owns deterministic renderer input assembly,
  exact-byte generation/hash verification, artifact lifetime planning, and
  cleanup. The renderer is pure and cannot query hidden/source data.
- `Storage`/encrypted blob vault own protected preview, managed artifact, and
  ephemeral handoff bytes, atomic writes, checksums, and deletion verification.
- `ExternalOperations` owns local pending intent, one effect invocation,
  provider result/reconciliation, and no-reissue-on-replay. The native share
  adapter receives only a confirmed artifact URL and declared content type.
- `Commands`/`Inspection` own export attempt, staleness/deletion commands,
  Receipt, History, and replay projections.

The renderer input is a closed `CapabilityAdvisorSummaryInput`: purpose enum,
ordered exact Capability revision snapshots, allowlisted segment structs,
classification decisions, approved disclosure selections, uncertainty/freshness
values, locale, and renderer version. There is no generic key/value bag and no
Credential, Proof artifact, attachment, Source object, hidden-state, or raw-
history field type. The pure renderer returns bytes plus a segment-to-byte-range
manifest used only for preview verification and discarded at terminal cleanup.

### Ephemeral and durable models

`CapabilityExportSession` is a protected operation journal containing session
ID/revision, purpose, source revision set, selected segment keys, category-level
classification decisions, protected-disclosure decision IDs, destination
class, renderer/policy versions, preview blob ID/hash/byte count, confirmation
digest, operation state, semantic focus ID, and cleanup markers. It may hold
rendered bytes only until the attempt resolves and required managed adoption or
cleanup completes. It is excluded from canonical content search and consumers.

`CapabilityExportRecord` stores stable attempt ID, advisor-purpose enum,
selected Capability revision references, included/excluded/redacted/disclosed
field categories, disclosure decision IDs and reason categories, artifact
fingerprint, destination class, attempt time, separate local-creation and
external-handoff outcomes, managed-artifact ID if retained, stale relationship
status, Receipt/History/external-operation IDs, schema/policy versions, and
lifecycle. It never stores rendered text, byte ranges, protected or third-party
values, recipient identity, destination application identity, or a reversible
content digest lookup index.

An Ambitions-managed artifact is an immutable encrypted blob separately owned
from its detailed record and labelled non-restorable. A direct-handoff artifact
uses a unique protected temporary directory, no backup/sync eligibility, and an
expiration/cleanup journal. The system share provider may create copies outside
this boundary; those are neither indexed nor controlled by Ambitions.

### Mutation, persistence, migration, and replay

`ConfirmCapabilityExport` validates current revisions, classifications,
disclosures, exact-byte hash, purpose, and destination, then atomically commits
the content-minimized attempt, History, Receipt, and local/external operation
intent before generation/effect. Artifact adoption and external outcome are
typed independently settling results appended to the same attempt lineage.
Artifact deletion, combined record deletion, stale marking, and Capability-
deletion cleanup use separate commands and consequence previews.

The additive first migration creates export session/record/artifact-link/event
schemas and initializes them empty. No prior share Receipt or file is inferred
to be a Capability export. The supported upgrade horizon, rollback point,
idempotent schema adapters, and last-readable-copy rule come from persistence
canon. Unknown/corrupt schemas block or quarantine; they do not silently erase
artifacts or source data.

Replay reconstructs detailed records, independent outcomes, staleness,
artifact ownership, deletion tombstones, Receipts, History, external-operation
state, and cleanup requirements. It never renders bytes from current source,
opens a file picker/share sheet, repeats a handoff, recreates a deleted
artifact, reuses a disclosure decision, marks an ambiguous attempt delivered,
or mutates a Capability. Projection rebuilds are checksum-equivalent and
content-minimized.

Rendering, classification over approved inputs, hashing, local writes, and
cleanup run off the main actor with calibrated limits for Capability/segment
count, segment/total bytes, memory, storage amplification, cancellation, and
provider duration. Preview and generated bytes must compare exactly; no
platform text normalization may occur after confirmation.

## Privacy and accessibility

Capability snapshots, free text, classifications, disclosure choices, exact
preview/artifact bytes, source revisions, and export relationships are private
local graph data. Preview and local creation work offline. No content or derived
private context may pass through Account, R2, Source Atlas, Ambitions backend,
hosted AI, analytics, telemetry, diagnostics, or implicit support upload. The
only eligible egress is the exact confirmed artifact through the user-selected
Files or native handoff action; the confirmation authorizes no future access.

Unknown classification blocks quietly. Protected disclosure is allowed only
for known self-authored content and only by an exact, single-segment decision;
third-party, inferred, hidden, or unreviewed source content stays structurally
ineligible. Logs and diagnostics contain attempt IDs, policy/renderer versions,
category counts, byte-size buckets, destination class, state/reason codes, and
timings—not names, meanings, evidence, protected text, recipient, exact hash
lookup material, or destination application. Locked-device UI redacts preview
and record relationships until protected data is available.

Accessibility order is purpose/outside-copy boundary; selected revisions;
included/excluded categories; each segment and classification; protected
warning/decision; exact preview; destination; confirmation; progress; local and
external results; staleness; deletion/recovery. Exact bytes are available as a
linear read-only text view with line/section navigation and byte metadata; the
experience never requires side-by-side diff, table geometry, color, animation,
gesture, or haptic interpretation.

VoiceOver labels segment identity/state/reason/action and reads the artifact in
deterministic order; headings and rotors separate preview from the decision
ledger. Focus returns to the initiating segment, destination control, attempt,
or nearest stable heading after edits, disclosure, share dismissal, error, and
deletion. State changes announce whether nothing left Ambitions and distinguish
created, cancelled, failed, pending, handed off, ambiguous, cleanup-required,
and stale. Voice Control, Switch Control, Full Keyboard Access, and hardware
keyboard reach every named non-gesture action. Dynamic Type, Bold Text, Button
Shapes, Increase Contrast, Differentiate Without Color, Reduce Motion/
Transparency, RTL/localization, adequate targets, and sensitive locked-device
behavior require direct verification on the real Files/share surfaces.

## Requirement traceability

| Scope requirement | Design binding |
| --- | --- |
| REQ-001 | Selection steps 1-2 bind advisor purpose, exact Capability revisions, format, and destination visibility while creating no file/effect. |
| REQ-002 | Steps 3 and the closed renderer input enforce the minimum field allowlist and user removal without generic source access. |
| REQ-003 | Step 4 and fail-closed classifier keep unknown blocked and third-party/inferred/hidden/unreviewed content ineligible. |
| REQ-004 | Step 5 binds one exact protected self segment to purpose/destination/revision and never broadens eligibility. |
| REQ-005 | Steps 6-8 and the confirmation digest bind exact UTF-8 bytes, revisions, decisions, renderer/policy, purpose, and destination; all changes invalidate. |
| REQ-006 | Separate local-save/handoff flows, independent outcome fields, temporary cleanup, and ambiguous-state copy distinguish every result. |
| REQ-007 | Offline components and structural egress adapter allow only the confirmed artifact through the selected action and prohibit backend/intermediary paths. |
| REQ-008 | `CapabilityExportRecord` stores category/decision/reference/fingerprint/outcome metadata and excludes reconstructive text, protected values, third-party values, and recipient. |
| REQ-009 | Result/staleness flows and immutable artifact/outside-copy model state Ambitions cannot update, recall, redact, or prove deletion elsewhere. |
| REQ-010 | Separate artifact-only and combined deletion commands enforce exact byte/record scope and content-free remaining lineage. |
| REQ-011 | Capability-owner notification and cleanup command remove detailed references and all Ambitions-managed containing artifacts while preserving the outside-copy warning only. |
| REQ-012 | Closed snapshot reads, non-restorable copy, and command ownership ensure every export/result/deletion leaves Capabilities and related objects unchanged. |
| REQ-013 | Durable local intent, typed independently settling results, replay prohibition, and fresh-retry flow keep Receipts/History/effects truthful. |
| REQ-014 | Accessibility design covers deterministic meaning/order, all input modes, reflow, non-color/reduced effects, announcements/focus, errors, and no partial disclosure. |

## Verification design

| Evidence lane | Required evidence |
| --- | --- |
| Renderer/unit | Golden exact-byte fixtures for ordering, escaping, Unicode, normalization preservation, LF line endings, terminal newline, locale/RTL inputs, empty optionals, dates, uncertainty/freshness, and deterministic hashes. Assert allowlist absence for IDs, credentials, attachments, full source, history, hidden/third-party content, and segment-ledger markup. |
| Classification/policy | Fixtures for eligible, unknown, known protected self, inferred protected, third-party, hidden, and unreviewed-source segments; edit/remove recovery; one-segment disclosure; change invalidation; destination/purpose binding; and no broad grant or cross-attempt reuse. |
| Command/domain | Revision-consistent snapshots, stale CAS, exact confirmation digest, single token consumption, source immutability, idempotent generation, local versus handoff results, retry freshness, staleness, Receipt/History minimization, artifact-only/combined deletion, Capability-deletion cleanup, and content-free tombstones. |
| Persistence/migration | Additive upgrade across supported horizon, every crash/low-storage point, protected-data unavailable, hash mismatch, provider interruption, managed adoption, ephemeral cleanup, corrupt/quarantined record/blob, rollback, compaction, projection rebuild, deletion remanence, and replay equivalence/no handoff. |
| Privacy/security | Byte-inspect all outputs, stores, caches, logs, diagnostics, search, previews, snapshots, clipboard hooks, Account/R2/Source Atlas/backend/hosted-AI/analytics/telemetry requests, and share metadata. Prove only exact confirmed bytes cross the selected action and no retained direct-handoff duplicate remains. |
| Integration/runtime | Offline selection/classification/preview/local save; exact preview-to-file comparison; Files cancel/failure/success; native share cancel/failure/pending/handed-off/ambiguous fixtures; relaunch before/after invocation; correction staleness; every deletion path; outside-file survival; and source byte/fact identity before/after. |
| Accessibility | Automated semantics plus direct iPhone VoiceOver order/rotors/actions/announcements/focus on actual preview/Files/share surfaces; Voice Control, Switch Control, Full Keyboard Access, hardware keyboard, Dynamic Type, Bold Text, Button Shapes, contrast/non-color, Reduce Motion/Transparency, RTL/localization, reach/handedness, locked-device privacy, failures, and cleanup recovery. Automation alone is insufficient. |
| Performance/resource | Calibrate representative Capability/segment/text scales for classification, render/hash, preview load/scroll, file write, share presentation, memory, energy, storage amplification, cancellation, and cleanup on supported devices. Derive thresholds from measured fixtures. |
| Build/static | XcodeGen after `project.yml` membership changes, focused and changed-scope Code Quality lanes, SwiftLint/static analysis/secrets scan, `git diff --check`, source-ownership/privacy audit, and canon validation for later canon edits. |

Evidence binds exact commit, input/revision fixture hashes, renderer/policy/schema
versions, test command, device/OS/toolchain, launched/executed/pass counts,
artifact hashes and filesystem/share traces, and known gaps. Source/unit proof is
not rendered UI, exact external-provider, accessibility, physical-device,
privacy-abuse, migration, deletion-remanence, or release proof.

## Open decisions

There are no unresolved product decisions. Resume/rich/machine formats,
credential presentation, automatic publishing, platform write-back, recurring
destination access, receiver identity/verification, broad sensitive-content
grants, or remote recall/deletion must return to Research and Scope.

Implementation grooming must resolve technical-only choices: canonical
Capability snapshot API availability; renderer normalization/version details;
classification policy and licensed deterministic fixtures; exact Files versus
native-share adapter result mapping; protected temporary-file lifecycle on each
supported OS; calibrated limits; and persistence/event schema IDs. These may
not widen the fixed field or egress boundaries.
