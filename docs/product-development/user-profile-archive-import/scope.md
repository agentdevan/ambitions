+++
initiative = "user-profile-archive-import"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

The user can select one local profile-derived table, explicitly identify the
column that contains capability claims, review every eligible row, and choose
which claims Ambitions may retain. No row becomes an Ambitions Capability,
evidence relationship, or planning influence merely because it appeared in a
file or carried a familiar label.

The first import is source-independent: it may be used with a table the user
obtained from LinkedIn or another profile archive, but Ambitions does not claim
to recognize a LinkedIn archive, filename, or schema. Unsupported, sensitive,
third-party, malformed, or unknown data fails closed. The original file remains
outside Ambitions' authority, while temporary staged data and accepted native
claims have explicit, separate lifecycles.

## In scope

- A user-initiated import of one local UTF-8 comma- or tab-delimited text table.
- Explicit delimiter/header review and column mapping before row candidates are
  created.
- One required mapped capability-name column and optional mapped source-label
  and context columns; every other column remains excluded.
- Local parsing of UTF-8 BOM, quoted delimiters, embedded line breaks, blank
  values, duplicate rows, reordered/renamed headers, and inert formula-like
  text.
- A private recoverable staged copy for the active review only, with bounded
  interruption recovery, cancellation, quarantine, and disposal.
- Per-row review, edit, accept, reject, duplicate decision, failure, and retry.
- Accepted imported claims that remain distinct from Capabilities until the
  user separately confirms or links an Ambitions meaning through the Capability
  owner.
- Minimum Source Reference and import-decision provenance for accepted claims.
- Separate discard, source-record deletion, imported-claim deletion,
  Capability deletion, and deliberate combined-deletion actions.
- Offline, no-account, accessible import with no scraping, synchronization,
  network fetch, or write-back.

## Out of scope

- Automatic LinkedIn ZIP recognition, extraction, folder traversal, filename
  matching, or stable LinkedIn schema claims.
- Positions, Projects, Education, Courses, Certifications, Languages, Honors,
  recommendations, contacts, messages, endorsements, job applications,
  advertising, account, or relationship import.
- Live LinkedIn login, OAuth/API access, scraping, background refresh, source
  monitoring, profile synchronization, or write-back.
- Credential, issuer, endorsement, employment, course-completion, equivalency,
  proficiency, or capability verification.
- Automatic inference of capabilities from job titles, projects, courses,
  descriptions, endorsements, or other free text.
- Silent duplicate merging, bulk confirmation, an “import everything” action,
  or automatic Goal/Path/Time/planning mutation.
- ZIP, spreadsheet workbook, arbitrary archive, image, PDF, JSON, or binary
  import in this first format.
- Retention of the whole source table, ignored columns, rejected rows,
  third-party values, or the user's original outside file after review.

## Requirements

### REQ-001 — Import begins with deliberate local selection

The user must explicitly choose one local text table and see that Ambitions will
read it privately on device, will not connect to the source service, and cannot
delete or update the original file outside Ambitions. Selecting a file starts a
non-authoritative staged review and creates no claim or Capability.

### REQ-002 — The first format is narrow and explicit

The file must be a bounded UTF-8 comma- or tab-delimited table. The user must
review the detected delimiter and header and explicitly map exactly one
capability-name column before row review. The user may additionally map one
source-label column and one context column. No filename, platform label, header,
or column is trusted as a stable LinkedIn contract.

### REQ-003 — Unmapped and ineligible data fails closed

Unknown and unmapped columns must not become candidate content. Third-party
names, contacts, endorsements, recommendations, messages, relationship data,
protected-category content, and classification-unknown free text are ineligible
for this import. Ambitions may show only a redacted transient reason and durable
excluded category/count; it must not retain the excluded value or a
reconstructive fingerprint.

### REQ-004 — Parsing is bounded, deterministic, and inert

Ambitions must handle UTF-8 BOM, quoted delimiters, embedded line breaks,
reordered or renamed headers, blank rows, duplicates, and formula-like prefixes
as inert text. Invalid encoding, malformed structure, unsupported format,
oversized file or row, resource exhaustion, cancellation, and interruption
must preserve the last honest state, quarantine or reject the unsafe scope, and
never execute content or traverse/extract nested paths.

### REQ-005 — Every recognized row remains a proposal

Each eligible row must appear as an uncommitted user-provided claim with the
mapped source field, candidate value, optional context, source position,
duplicate signals, and any user edit. A row must never be presented as Proof,
issuer-verified, practiced, current, equivalent, proficient, or planning-ready
merely because it parsed successfully.

### REQ-006 — Review and commit are per row

The user must be able to edit, accept, reject, keep separate, or identify a
possible duplicate for each row. Label similarity may propose a comparison but
must not merge identities. Each accepted row commits independently through the
native owner with its Source Reference, decision, Receipt, History, and replay
lineage; rejection or parser failure for another row must not roll it back or
silently accept anything else.

### REQ-007 — Imported claims and Capabilities remain distinct

Acceptance creates a user-provided imported claim with archive provenance, not
a Capability. The user may separately create a Capability from it or link it to
an existing Capability only after reviewing the Ambitions meaning and choosing
the relationship. Confirmation routes to the Capability owner, starts
future-use permission off, and cannot transfer verification, proficiency, or
hidden planning authority from the import.

### REQ-008 — Duplicate and repeat import behavior is inspectable

Re-selecting identical source bytes and mapping must show the existing import
review or completed decisions rather than create duplicate claims. Changed
bytes, mapping, or row meaning must produce a new diff requiring review. Blank
and duplicate rows remain visible as excluded or possible-duplicate decisions;
they must not disappear in a way that obscures counts or partial results.

### REQ-009 — Staging has a purpose-limited lifetime

Ambitions may retain a private staged copy, parsed eligible values, uncommitted
edits, and candidate matches only while the review or its explicit crash/
interruption recovery remains active. Resume must return to the same file
fingerprint, mapping, completed and pending row IDs, and focus. Cancel or
Discard Import deletes all uncommitted staged material; it does not delete rows
already accepted through individual commits.

### REQ-010 — Resolution minimizes retained source data

After the review is completed, partially completed and deliberately closed, or
discarded, Ambitions must remove raw staged bytes, ignored columns, excluded
values, rejected rows, and uncommitted edits. It may retain only accepted claim
fields, the minimum source label/fingerprint/field mapping needed to explain
those claims, completed/failed item identities needed for truthful partial
results, and content-minimized Receipt/History/replay facts.

### REQ-011 — Partial outcomes and recovery are truthful

Progress, cancellation, low storage, interruption, and row-level failure must
show which rows committed, failed, remain pending, or were excluded. Retry must
be idempotent and cannot duplicate a committed claim. Discarding the remainder
must name accepted survivors and provide direct inspection or separately
selected deletion; no success state may imply the entire table was imported.

### REQ-012 — Deletion actions remain separate

The product must distinguish:

- **Discard Import:** delete only uncommitted staged material.
- **Delete Source Record:** remove retained source label, fingerprint, mapping,
  and source relationships; accepted claims and Capabilities remain, visibly
  unlinked and unable to use that source as evidence or duplicate authority.
- **Delete Imported Claim:** remove that claim and its evidence relationship;
  related Capabilities remain user-owned but lose that support.
- **Delete Capability:** follow the Capability lifecycle and unlink retained
  claims without silently deleting the source record or other claims.
- **Delete Everything From This Import:** preview and explicitly select the
  source record and imported claims together, list Capabilities that will remain
  or may be separately selected, and never infer a cascade.

### REQ-013 — Deletion leaves no reconstructive content

After governed deletion, Receipt and History may retain only the minimum
content-free fact that an import, source removal, claim deletion, or Capability
deletion occurred. Deleted source labels, mapped values, context, third-party
content, and claim meaning must not remain searchable or reconstructable. The
original file outside Ambitions remains unaffected and must be named as outside
Ambitions' deletion authority.

### REQ-014 — Import is private, local, and non-influential by default

Selected bytes, rows, mappings, claims, provenance, duplicate decisions, and
derived facts are private local graph data. The flow must work without account
or network and must send nothing to LinkedIn, Account, R2, Source Atlas, hosted
AI, analytics, telemetry, or another external destination. No staged or
accepted claim may influence recommendations, simulation, Goals, Paths, or Time
unless a later approved consumer separately earns that authority.

### REQ-015 — The complete review is accessible

File purpose, mapping, excluded categories/counts, every row and its state,
edits, duplicate comparisons, partial progress, retained/deleted scope,
confirmation, result, failure, and recovery must have a stable semantic order.
The flow must support VoiceOver, Voice Control, Switch Control, Full Keyboard
Access, Dynamic Type, increased contrast, reduced effects, non-color states,
named non-gesture controls, and deterministic focus restoration and
announcements.

## Acceptance criteria

1. **AC-001 (REQ-001, REQ-002):** Selecting a supported local table creates no
   claim. The user reviews comma/tab and headers, maps one capability-name
   column, optionally maps source/context, and sees that no service connection
   or outside-file deletion will occur.
2. **AC-002 (REQ-002, REQ-004):** A valid UTF-8 table with BOM, quoted commas,
   embedded line breaks, or reordered headers parses only after explicit
   mapping; a ZIP, workbook, JSON file, invalid encoding, or nested archive is
   shown as unsupported without extraction or candidate creation.
3. **AC-003 (REQ-003):** Unknown columns and rows containing third-party,
   protected, or classification-unknown content produce only redacted excluded
   categories/counts. Their values and reconstructive fingerprints are absent
   from staged candidates and durable state.
4. **AC-004 (REQ-004):** Formula-prefixed text remains inert. Malformed,
   oversized, cancelled, or resource-limited input reports an exact safe result,
   preserves prior committed data, and provides retry, narrower input, discard,
   or return without false success.
5. **AC-005 (REQ-005, REQ-006):** A parsed Skills-style row appears as an
   unverified user-provided claim. The user can edit and accept it independently;
   accepting one row does not accept, merge, verify, or mutate another.
6. **AC-006 (REQ-007):** An accepted claim remains distinct from Capability and
   Proof. Separate confirmation can create or link a Capability with future-use
   off, while preserving archive provenance and making no proficiency,
   equivalency, issuer, or planning claim.
7. **AC-007 (REQ-008):** Re-importing identical bytes and mapping shows prior
   decisions without duplication. Changed bytes or mapping produces an explicit
   diff; duplicate labels offer keep-separate or reviewed relationship choices
   and never merge silently.
8. **AC-008 (REQ-009, REQ-010):** Relaunch resumes the same active review.
   Discard removes all uncommitted staged bytes, values, edits, and matches.
   Resolving a review retains only accepted fields and minimum provenance, not
   ignored/rejected/raw table content.
9. **AC-009 (REQ-011):** A partial import lists committed, failed, pending, and
   excluded row IDs. Retry is idempotent; discarding the remainder leaves
   committed survivors visible with separate deletion controls.
10. **AC-010 (REQ-012, REQ-013):** Each deletion action previews its exact
    scope. Source deletion leaves claims/Capabilities unlinked; claim deletion
    removes only its support; Capability deletion leaves unrelated source and
    claims; combined deletion requires explicit selection and leaves only
    non-reconstructive facts.
11. **AC-011 (REQ-014):** Import, resume, review, commit, discard, inspection,
    and deletion work offline, privacy-egress tests show no prohibited
    destination receives any payload, and no imported item changes planning.
12. **AC-012 (REQ-015):** Direct accessibility verification covers mapping,
    row review, duplicate comparison, partial progress, deletion previews,
    cancellation, failure, result, and recovery without dependence on table
    geometry, gesture, color, motion, or visual-only state.

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

- `docs/canon/specifications/systems/import-export-repair.md` should own the
  supported table boundary, hostile-input limits, staged review, row-level
  partial settlement, quarantine, deterministic retry, and disposal.
- `docs/canon/specifications/objects/source-reference.md` should own minimum
  profile-table provenance, source deletion/unlinking, and the outside-source
  boundary without making LinkedIn or another platform authoritative.
- Canon needs a private imported-profile-claim contract, separate from
  Capability and Proof, to own accepted claim identity, user edits, archive
  provenance, lifecycle, and deletion. It must inherit existing canonical
  mutation, privacy, Receipt, History, replay, and deletion law.
- `docs/canon/specifications/objects/import-diff-record.md` should be generalized
  or paired with a profile-row review contract so field mapping, per-row
  decisions, duplicates, partial results, and stable source lineage are owned
  without weakening calendar-specific behavior.
- The canonical Capability owner should own only separately confirmed
  Capability creation/linkage and future-use permission; the import adapter and
  review surface cannot commit Capability meaning directly.
- `docs/canon/specifications/systems/privacy-and-data-classification.md` should
  own free-text eligibility, protected/third-party exclusion, retention,
  non-reconstructive deletion, and prohibited egress.
- You's Sources & Imports depth and Trust should present review and provenance;
  existing Receipt, History, replay, deletion, and accessibility canon remains
  applicable.

## Risks and open decisions

Resolved product decisions:

- The first format is one explicitly mapped UTF-8 comma- or tab-delimited table,
  not a LinkedIn ZIP or auto-detected platform schema.
- Only one capability-name column and optional source/context columns are
  eligible; everything else is excluded.
- Every accepted row is an imported claim, not a Capability, Proof, or verified
  fact. Capability linkage is a separate user decision.
- Partial commits settle independently, and staged/uncommitted data has a
  purpose-limited lifetime.
- Discard, source deletion, claim deletion, Capability deletion, and combined
  deletion have separate consequences.

Dependencies and delivery risks:

- Capability creation/linking cannot ship until the canonical Capability owner
  and its relationship/deletion contract exist; import review must not invent a
  temporary competing owner.
- Representative private archive variability remains unavailable. Any later
  LinkedIn-specific detection, ZIP handling, or additional category mapping
  requires new Research and Scope.
- Free-text classification may exclude legitimate rows; safe manual re-entry
  remains the fallback rather than lowering the protection boundary.
- Large or hostile input requires explicit calibrated limits, streaming,
  cancellation, path-safety, storage-pressure, crash, and replay verification.
- Verification must prove stage cleanup, partial settlement, deterministic
  duplicate behavior, no hidden retention, no egress, non-cascading deletion,
  and direct accessibility behavior.
