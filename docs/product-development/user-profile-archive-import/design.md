+++
initiative = "user-profile-archive-import"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

The first profile archive import is a local, source-independent table review in
You > Sources & Imports. It accepts one bounded UTF-8 comma- or tab-delimited
file selected by the user. The file is never treated as a LinkedIn contract:
the user confirms the delimiter and header, maps exactly one capability-name
column, and may map one source-label and one context column. Every recognized
row remains an unverified proposal until that row is separately accepted.

Acceptance creates an `ImportedProfileClaim`, not a Capability or Proof. A
separate Capability-owner command may later create or link a Capability after
the user reviews Ambitions' meaning; future-use permission starts off. The
import neither infers proficiency nor influences Goals, Paths, recommendations,
simulation, or Time.

The implementation follows the canonical mutation sequence for each accepted
row: `Command -> Event -> Projection -> Receipt -> Replay`. Raw source bytes and
uncommitted review material live only in a protected staging journal. Eligible
accepted fields and minimum provenance enter the private graph. Excluded,
rejected, or ignored content does not. No import path performs network access,
source write-back, archive traversal, or external deletion.

## User flows

### Primary import and row review

1. The user opens **You > Sources & Imports > Import profile table**. The
   introduction says that processing is private and on-device, selection makes
   no claim, Ambitions will not contact the source service, and the original
   outside file cannot be changed or deleted by Ambitions.
2. The system file picker allows one file. After selection, Ambitions copies
   the bytes into protected staging and computes a source fingerprint without
   creating a Source Reference, claim, Capability, Receipt, or network request.
3. A bounded scanner validates size, UTF-8 (including BOM), delimiter
   candidates, row limits, quoting, and structural integrity. Unsupported or
   unsafe input stops at a named error without extracting or traversing paths.
4. **Confirm format** shows comma or tab, the parsed header as inert text, and
   row/exclusion counts. The user must confirm the delimiter and map exactly one
   capability-name column. Source label and context are optional; every other
   column is visibly excluded.
5. Classification evaluates only the three mapped fields. Unknown,
   third-party-bearing, protected-category, and otherwise ineligible values are
   discarded from candidate memory after producing a transient redacted reason
   and a durable category/count. Formula-like prefixes remain inert text.
6. **Review rows** presents a linear list independent of table geometry. Each
   eligible row identifies its source position, candidate name, optional
   eligible source/context, user edits, and duplicate signal. Its actions are
   Edit, Accept claim, Reject, Compare possible duplicate, and Keep separate.
7. **Accept claim** previews the exact retained fields and states “user-provided
   claim; not verified and not yet a Capability.” Confirmation submits one
   revision-bound command. Durable success shows the new claim, Source
   Reference, Receipt, and row result; the review advances to the next pending
   row.
8. The user resolves remaining rows or chooses **Finish with remaining rows
   discarded**. The result lists accepted, rejected, excluded, failed, and
   deliberately discarded counts and links every accepted survivor.
9. Resolution securely removes staging bytes, excluded/rejected values,
   uncommitted edits, and match candidates. It retains only accepted claim
   fields, minimum provenance and mapping explanation, item-result identities,
   and content-minimized history.

### Duplicate and repeat import

- The lookup key is the source-byte fingerprint plus a canonical mapping
  fingerprint. An identical pair opens the existing active review or a
  read-only summary of completed decisions; it never creates duplicate claims.
- Changed bytes, mapping, or accepted row meaning creates a new review with an
  explicit diff. Blank and duplicate rows remain visible in counts and as
  excluded or possible-duplicate outcomes.
- Similar labels are suggestions only. Comparison shows both identities and
  provenance; only **Keep separate** or a separately confirmed relationship is
  available. Import never merges canonical identities.

### Capability handoff

From an accepted claim, **Use as a Capability** opens a Capability-owner sheet
showing the claim, proposed Ambitions meaning, relationship, and that
verification, proficiency, equivalency, and planning authority do not transfer.
Create or Link is a new command outside the import transaction. Future-use
permission is off. If no canonical Capability owner is available, the action is
absent and the imported claim remains fully inspectable.

### Cancel, finish partial, and deletion

- **Cancel** pauses an active review when its protected recovery journal is
  valid; **Discard Import** deletes only uncommitted staging and names accepted
  survivors.
- **Delete Source Record** removes retained source label, fingerprint, mapping,
  and source relationships. Claims and Capabilities remain visibly unlinked.
- **Delete Imported Claim** removes that claim and its evidence relationship;
  any Capability remains but loses that support.
- **Delete Capability** follows the Capability owner and does not delete the
  import source or unrelated claims.
- **Delete Everything From This Import** is a consequence preview with separate
  selected checkboxes for the source and each imported claim. Capabilities are
  listed as remaining unless separately selected through their owner. No
  cascade is inferred.
- Every deletion view states that the original outside file is unaffected.

## States and recovery

### Import session state machine

| State | Durable meaning | Visible next actions |
| --- | --- | --- |
| `selected` | Protected staged bytes and fingerprint exist; no parsed candidate is authoritative. | Scan or discard. |
| `scanning` | Bounded local scan is journaled; active graph unchanged. | Cancel; on interruption resume from staged bytes. |
| `formatReview` | Safe structural result and header tokens exist transiently; mapping is incomplete. | Confirm delimiter/map columns or discard. |
| `rowReview` | Mapping is bound and row outcome identities exist; eligible values are staged only. | Edit/accept/reject/compare/keep separate. |
| `partiallySettled` | One or more row commands committed independently while other rows remain. | Continue, retry failed rows, finish partial, inspect survivors. |
| `completed` | All rows have terminal truthful outcomes and staging cleanup is verified. | Inspect claims/source/Receipts or start a new import. |
| `closedPartial` | User discarded pending remainder; accepted rows survive and cleanup is verified. | Inspect or separately delete survivors. |
| `discarded` | No uncommitted material remains; committed survivors, if any, are unchanged. | Return or inspect survivors. |
| `quarantined` | Unsafe/corrupt input is isolated without candidate creation. | Delete quarantine, choose a safer file, or view redacted diagnosis. |
| `cleanupRequired` | Canonical row results are honest but staging disposal was interrupted. | Resume cleanup; no further row acceptance until cleanup succeeds. |

Row outcomes are `pending`, `eligible`, `excluded(category)`, `possibleDuplicate`,
`committing`, `accepted(claimID, revision)`, `rejected`, `failed(retryable or
terminal)`, or `discarded`. An accepted state is published only after its full
transaction commits. The interface never summarizes a partial session as “file
imported.”

### Recovery rules

- Relaunch verifies the staged-blob checksum, source/mapping fingerprints,
  journal schema, completed row IDs, pending row IDs, and last semantic focus
  ID. A valid session returns to the exact review position. A mismatch blocks
  commit and offers discard or redacted diagnosis, not guessed repair.
- Row acceptance uses `sessionID + rowOpaqueID + acceptedRevision` as its
  idempotency key. Retrying a committed key returns the existing claim and
  Receipt. It never creates a second claim.
- Low storage before a row commit leaves the row pending. Atomic storage
  failure during commit writes the whole Event/object/Source Reference/Receipt
  set or none. Previously accepted rows remain readable.
- Cancellation during scan or parse stops bounded work and preserves only the
  recoverable session scope. Cancellation before row commit changes no graph;
  after durable acceptance it cannot retract that accepted row.
- Cleanup is idempotent and may resume after interruption. Failure to remove a
  staged blob enters `cleanupRequired`, keeps it inaccessible to normal search
  or consumers, and exposes retry/delete recovery without claiming resolution.
- Unsupported journal/schema versions and corrupt staging are quarantined.
  Migration never destroys the only readable copy or silently resets state.

## Architecture and data

### Ownership and interfaces

- `Surfaces/You/SourcesImports` owns selection, mapping, row review, result,
  deletion previews, and focus restoration. Trust provides contextual Source,
  Receipt, and History inspection.
- `Repair/ProfileTableImport` owns bounded scanning, deterministic CSV/TSV
  parsing, canonical mapping fingerprints, row diffing, and cleanup planning.
  Its parser emits facts only and cannot mutate canonical state.
- `Attachments`/`Storage` own encrypted staged bytes, file protection, atomic
  blob replacement, checksums, quarantine, and cleanup recovery.
- `PrivacySecurity` classifies mapped values before candidate persistence and
  owns fail-closed retention/egress decisions. Unknown classification is
  exclusion, never an implicit allowance.
- `Commands` owns per-row acceptance and deletion. `Inspection` owns Source
  Reference, Receipt, History, import-result, and lineage projections.
- The future Capability owner alone owns Capability creation/linking and its
  future-use permission. The importer exposes a typed handoff but no direct
  Capability write.

The parser interface receives immutable staged bytes, declared delimiter,
declared header row, mapped column indices, and calibrated resource limits. It
returns structural facts, opaque row identities, eligible field candidates,
redacted exclusion categories/counts, and diagnostics. It never returns
unmapped values to durable persistence or logging.

### Durable records

`ProfileImportSession` is a purpose-limited operation journal, not a canonical
content object. It stores a stable session ID, staged-blob locator/checksum,
source-byte fingerprint, canonical mapping fingerprint, delimiter, safe header
tokens needed for the selected mapping, schema/policy versions, opaque row IDs,
row outcomes, counts, operation state, revision, cleanup state, and recovery
focus ID. Eligible raw values and edits are encrypted staging fields and are
erased at terminal cleanup. Excluded values and reconstructive fingerprints
are never stored.

`ImportedProfileClaim` stores a stable claim ID, user-reviewed name, optional
eligible source label/context, source position, lifecycle, revision, and links
to a minimum Source Reference and acceptance lineage. It carries explicit
`userProvided/unverified` semantics and no proficiency, equivalency, recency,
future-use, or planning-authority field.

The minimum Source Reference stores source kind `profileTable`, a
non-user-facing source fingerprint while retained, selected mapping field
names/positions, claim relationship, freshness/unavailable state, and import
decision IDs. Content-minimized item results retain opaque item ID, terminal
category, command/Receipt linkage where applicable, and no rejected value.

### Command and event boundaries

`AcceptImportedProfileClaim` validates the current session, row, mapping,
classification, edit revision, duplicate decision, and expected store revision.
Its atomic write set is claim revision, Source Reference link, History Event,
Receipt, row terminal outcome, and projection invalidation. Rejection is a
session decision, not claim creation. Deletion uses separate typed commands for
source, claim, Capability handoff, and combined explicitly selected scope.

Concurrent commands serialize through a session actor and canonical object
actors. Compare-and-set revisions reject stale row edits or a changed source
mapping and return the user to review. Multiple windows may inspect, but only a
current revision may commit. Deterministic causal order, not timestamps alone,
orders row results.

### Persistence, migration, and replay

The first schema change is additive: new session/result/claim tables, event
payload versions, Source Reference relationship kinds, and protected staging
blob metadata. Existing stores migrate to empty import collections; no legacy
record is inferred to be an imported claim. The minimum supported direct
upgrade remains the owning persistence horizon. Unknown event or store versions
block with explicit recovery/export handling; corrupt blobs quarantine.

Event payloads are versioned and decoded through explicit adapters. Replay
reconstructs accepted claims, Source relationships, deletion tombstones,
partial item outcomes, Receipts, History, and cleanup-required state. It does
not reopen the file picker, reread the original outside file, recreate excluded
content, resume parser work without a valid journal, issue a network request,
or repeat deletion outside Ambitions. Projection rebuild must be checksum-
equivalent and cannot turn a claim into a Capability.

Parsing and hashing stream off the main actor with bounded bytes, rows, columns,
field length, quoting depth, memory, work time, and cancellation. Limits are
calibrated from representative fixtures and devices before implementation; this
Design does not invent numeric budgets.

## Privacy and accessibility

All selected bytes, mapped values, edits, claims, provenance, duplicate facts,
and derived results are private local graph data. Staging uses complete file
protection and the encrypted blob vault and is excluded from Spotlight,
widgets, previews, logs, telemetry, Account, R2, Source Atlas, hosted AI,
analytics, and support bundles. The import networking capability is structurally
absent. Diagnostics contain only operation IDs, schema/policy versions, size
buckets, exclusion categories/counts, and error codes. Clipboard and screen
capture receive no automatic copy. Locked-device presentation uses redacted
counts until protected data is available.

The UI explains retained versus transient fields at mapping, row acceptance,
finish, and deletion. Excluded and deleted text cannot remain in search,
diagnostics, snapshots, history summaries, or reconstructive hashes. A deleted
source or claim leaves only the minimum content-free tombstone required for
idempotency and truthful history. The outside file boundary is named in every
deletion consequence.

Accessibility semantics use a linear hierarchy: screen purpose, privacy/source
boundary, format and mapping, progress summary, current row identity and state,
candidate values, duplicate comparison, available actions, consequence, then
navigation. Tables are never required for comprehension. Each row exposes a
stable label/value/hint, explicit status text, and named actions; no swipe,
long-press, color, motion, haptic, or spatial position is the sole path.

VoiceOver headings/rotors and deterministic semantic focus IDs preserve order
and return focus to the initiating row or nearest surviving row. Acceptance,
failure, exclusion-count change, partial finish, cleanup, and deletion announce
the result and next action without interrupting edits. Voice Control, Switch
Control, Full Keyboard Access, and hardware keyboard reach every control with
adequate target size. Dynamic Type through accessibility sizes reflows rows,
warnings, comparisons, and confirmations without truncation; Bold Text and
Button Shapes remain usable. Reduce Motion uses focus-preserving crossfades,
Reduce Transparency uses opaque surfaces, Increase Contrast strengthens
boundaries, and Differentiate Without Color preserves icons plus labels.
Right-to-left layouts and localization retain logical row order and do not
localize identifiers into unstable keys.

## Requirement traceability

| Scope requirement | Design binding |
| --- | --- |
| REQ-001 | Primary steps 1-2 establish deliberate local selection, outside-file notice, private staging, and zero canonical/network effect. |
| REQ-002 | Primary steps 3-4 and the parser contract limit input to bounded UTF-8 CSV/TSV with explicit delimiter/header and exact mapping cardinality. |
| REQ-003 | Primary step 5, PrivacySecurity ownership, and the privacy rules fail closed without durable values or reconstructive hashes. |
| REQ-004 | The bounded inert parser and recovery rules cover BOM, quotes, embedded lines, blank/duplicate rows, formula prefixes, cancellation, hostile input, and quarantine. |
| REQ-005 | Primary step 6 and `ImportedProfileClaim` semantics label every row as an uncommitted, user-provided, unverified proposal. |
| REQ-006 | Primary step 7 and `AcceptImportedProfileClaim` provide independent row actions and atomic Command/Event/Projection/Receipt/Replay lineage. |
| REQ-007 | Capability handoff and the record model preserve the Claim/Capability/Proof boundary and future-use-off default. |
| REQ-008 | Duplicate/repeat flow binds identical bytes plus mapping to existing decisions and requires a diff for every changed input. |
| REQ-009 | Session states and cleanup rules limit staging to active review/recovery and restore the exact semantic focus and row position. |
| REQ-010 | Primary step 9 and durable-record definitions retain only accepted fields, minimum provenance, opaque results, and minimized lineage. |
| REQ-011 | Partial states, idempotency keys, outcome list, and low-storage/interruption recovery keep every independent result truthful. |
| REQ-012 | The five deletion flows are separate typed commands with explicit selected scope and no inferred cascade. |
| REQ-013 | Privacy/deletion rules remove searchable or reconstructive content and retain content-free tombstones while naming the outside-file boundary. |
| REQ-014 | Structural absence of networking, local owners, private classification, and non-influential record fields enforce offline containment. |
| REQ-015 | The accessibility design provides stable order, complete semantic state/actions, assistive-input equivalence, reflow, non-color/reduced-effects behavior, focus, and announcements. |

## Verification design

| Evidence lane | Required evidence |
| --- | --- |
| Parser/unit | Deterministic fixtures for UTF-8/BOM, comma/tab, quoted delimiters, embedded lines, renamed/reordered headers, blank/duplicate rows, inert formula prefixes, invalid encoding, malformed quotes, unsupported extensions/content, oversized file/row/column, cancellation, and bounded resource exhaustion. Assert excluded values never enter outputs, logs, hashes, or stores. |
| Domain/command | Tests for every row action, stale revisions, independent commit/failure, idempotent retry, exact Receipt/History/Source linkage, Claim/Capability/Proof separation, future-use off, all five deletion commands, and no planning projection changes. |
| Persistence/migration | Additive migration from the oldest supported store, empty initialization, every crash point, low-storage atomicity, staging corruption/quarantine, cleanup resumption, unsupported schema recovery, tombstones, compaction, projection deletion/rebuild, and replay checksum equivalence. |
| Privacy/security | Destination-matrix and egress-firewall tests prove no request to LinkedIn, Account, R2, Source Atlas, hosted AI, analytics, or telemetry; inspect stores, logs, caches, snapshots, search, clipboard hooks, and diagnostics for excluded/rejected/deleted text or reconstructive fingerprints; verify file protection and locked-device redaction. |
| Integration/runtime | On-device fixtures exercise selection, mapping, row editing, duplicate comparison, identical re-import, changed diff, partial settlement, relaunch, discard, finish, every deletion preview/result, offline mode, and Files outside-copy survival. Record launched/executed/pass counts and exact fixture hashes. |
| Accessibility | Automated semantics plus direct iPhone verification for VoiceOver order/rotors/actions/announcements/focus, Voice Control, Switch Control, Full Keyboard Access, hardware keyboard, Dynamic Type, Bold Text, Button Shapes, Increase Contrast, Differentiate Without Color, Reduce Motion/Transparency, RTL/localization, locked-device privacy, errors, and recovery. Bind evidence to commit/device/OS; automation alone is insufficient. |
| Performance/resource | Calibrate representative small/large/hostile tables on supported devices. Record scan/hash/parse/review latency distributions, peak memory, energy, storage amplification, cancellation latency, and cleanup duration; establish regression thresholds from measurements rather than invented values. |
| Build/static | Regenerate the Xcode project from `project.yml` if membership changes; run focused tests, changed-scope Code Quality checks, SwiftLint/static analysis/secrets scan, `git diff --check`, and canon validation for any later canon edits. |

Acceptance evidence must bind the exact source commit, fixture bytes and hashes,
schema/policy versions, device/OS/build/toolchain, test command, launched count,
executed count, pass/fail count, and known gaps. Source presence and unit tests do
not claim rendered, accessibility, physical-device, privacy-abuse, migration,
or release proof.

## Open decisions

There are no unresolved product decisions. Any request for LinkedIn ZIP/schema
recognition, additional categories, automatic inference, network access, bulk
acceptance, or planning influence must return to Research and Scope.

Implementation grooming must resolve only technical choices: calibrated parser
limits and benchmark corpus; concrete persistence/table and event schema IDs;
encrypted staging key/file-protection integration; semantic focus-ID encoding;
and the canonical Capability-owner API/availability check. Those choices may
not weaken the product boundaries above.
