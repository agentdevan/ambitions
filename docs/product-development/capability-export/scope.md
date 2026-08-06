+++
initiative = "capability-export"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

The user can create one purpose-bound, human-readable summary of selected
Capabilities for a career or education advisor. Before anything leaves
Ambitions, the user sees the exact UTF-8 plain-text bytes, the selected
destination class, every included and excluded category, any deliberately
disclosed protected self-content, and the limits of Ambitions' control after a
copy reaches Files, Share Sheet, or another application.

The first export is a selective communication artifact, not a backup, resume,
credential presentation, profile synchronization, or machine interchange. It
contains only user-reviewed capability meaning and minimum selected provenance,
date, uncertainty, and freshness context. It grants no receiver authority,
changes no source object, and never implies that an outside copy can be recalled,
updated, or deleted by Ambitions.

## In scope

- A user-initiated `Share with a career or education advisor` purpose.
- Selection of one or more existing Capability revisions and an exact allowlist
  of eligible fields: capability name, user-reviewed short meaning, selected
  plain-language provenance or evidence labels and dates, and an explicit
  uncertainty or freshness note.
- Review and removal of ineligible, unknown, stale, contradictory, protected,
  or third-party-bearing text before rendering.
- Deliberate inclusion of a known protected segment about the user, one segment
  at a time, after an exact-text, destination, reason, minimum-purpose, and
  outside-copy warning.
- One exact UTF-8 `.txt` preview and one immutable confirmed revision.
- Either an explicit local save or a user-initiated handoff to a named
  destination class, with local creation and external handoff represented as
  separate outcomes.
- Cancellation, failure, retry from a fresh preview, staleness after local
  correction, retained-artifact deletion, detailed-record deletion, and
  Capability-deletion consequences.
- A content-minimized Capability Export Record plus non-reconstructive
  Receipt/History facts where applicable.
- Offline local generation, private-data containment, replay safety, and direct
  accessibility verification.

## Out of scope

- Resume, cover-letter, portfolio, PDF, rich-text, CSV, JSON, backup, restore,
  synchronization, continuous publishing, or machine-readable profile formats.
- LinkedIn or other platform write-back, scraping, account linking, employer or
  school submission, automatic publishing, or recurring destination access.
- Credential, badge, Proof artifact, attachment, source-object, transcript, or
  selective-disclosure presentation.
- Internal identifiers, hidden learned state, consumer history, unreviewed
  excerpts, inferred protected facts, third-party identifiers, or full source
  records in the artifact.
- A document-wide sensitive-content override or permission that carries across
  revisions, Capabilities, purposes, destinations, or later exports.
- Recipient identity, audience verification, receiver acceptance, delivery
  guarantees, remote deletion, external revocation, or automatic update of an
  outside copy.
- Account, R2, Source Atlas, hosted AI, analytics, telemetry, or an Ambitions
  backend as an export path or intermediary.
- Treating an exported file as canonical truth, proof of competence,
  authorization for planning, or permission to change any Capability, Goal,
  Proof, credential, schedule, or source.

## Requirements

### REQ-001 — Every export is deliberate and purpose-bound

The user must start the advisor-summary export and select the exact Capability
revisions to consider. Selection alone must create no file, handoff, permission,
or external effect. The experience must keep the advisor purpose, output class,
selected revisions, and destination class visible through confirmation.

### REQ-002 — The artifact has a minimum field allowlist

The rendered artifact may contain only selected Capability names,
user-reviewed short meanings, selected plain-language provenance or evidence
labels and dates, and explicit uncertainty or freshness notes. It must exclude
internal identifiers, hidden learned state, full source objects, attachments,
third-party names, consumer history, credentials, and any field not necessary
for the selected purpose. The user can remove any otherwise eligible segment.

### REQ-003 — Free text fails closed until classified

Every meaning and evidence label must be reviewed for protected or third-party
content before preview. A known third-party identifier, inferred protected fact,
hidden learned state, or unreviewed source excerpt is ineligible. A segment with
unknown classification stays excluded until the user edits it into an eligible
summary or removes it; unknown must never be treated as safe by silence.

### REQ-004 — Protected self-content requires per-segment disclosure

Known protected content about the user is excluded by default. The user may
deliberately include one eligible self-authored segment only after seeing its
exact text, the named destination class, the protected-content reason, a
minimum-purpose warning, and the fact that Ambitions cannot recall or update an
outside copy. The decision applies only to that segment in the confirmed
artifact revision and cannot make third-party, inferred, hidden, or unreviewed
content eligible.

### REQ-005 — Confirmation binds exact bytes and destination

The final preview must represent the exact UTF-8 bytes proposed for the `.txt`
artifact, identify deliberately disclosed segments without altering those
bytes, and show the chosen destination class. Changing text, selected
Capability revision, field selection, disclosure decision, purpose, or
destination invalidates confirmation and requires a newly reviewed preview.

### REQ-006 — Local creation and external handoff are distinct outcomes

The user must choose either a local save or an external handoff. Cancellation
before generation creates no file and no successful result. A local save may
retain one Ambitions-managed artifact only by explicit choice. A direct handoff
must not retain a second rendered copy after the handoff resolves. Created,
cancelled, failed, pending, handed off, and externally ambiguous outcomes must
remain distinguishable, and an ambiguous receiver result must not be described
as delivered.

### REQ-007 — The local core remains offline and contained

Selection, classification, preview, and local artifact creation must work
offline. Capability content must not pass through Account, R2, Source Atlas,
hosted AI, analytics, telemetry, or an Ambitions backend. A handoff may cross
the private boundary only after the exact preview is confirmed and only through
the user-selected destination action; it authorizes neither later nor broader
egress.

### REQ-008 — The durable export record is content-minimized

Each confirmed attempt must create a private Capability Export Record containing
only the advisor purpose, selected Capability revision references, included and
excluded field categories, redaction and deliberate-disclosure decisions,
artifact fingerprint, destination class, time, and separate local-creation and
external-handoff outcomes. It must not retain rendered text, protected segment
values, third-party values, or recipient identity.

### REQ-009 — Outside copies have an explicit control boundary

After a handoff or user-managed local save, Ambitions must state that the
outside copy may be retained, copied, changed, or shared beyond its control. A
later local correction, contradiction, freshness change, or deletion marks the
detailed export relationship stale where it still exists but cannot update,
recall, redact, or prove deletion of an outside copy.

### REQ-010 — Artifact and record deletion are separate choices

The user may delete an Ambitions-retained artifact while retaining its
content-minimized detailed record, or delete the detailed record and retained
artifact together. Artifact deletion removes its bytes. Detailed-record
deletion removes selected-revision references, decisions, fingerprint, and
outcomes. Receipt/History may retain at most a content-free fact that an export
occurred and an outside-copy warning; it must not reconstruct names, meanings,
evidence, recipient, protected text, or artifact bytes.

### REQ-011 — Capability deletion removes local export references

Before permanent Capability deletion, Ambitions must warn when a known export
may have produced an outside copy. Deletion must remove that Capability's
references from detailed export records and any Ambitions-retained artifact
containing it. A non-reconstructive outside-copy warning may remain, but no
Capability content or identity may remain through the export surface. Ambitions
must not claim that the deletion affected a copy owned by Files, a recipient,
or another application.

### REQ-012 — Export changes no source authority

Creating, saving, handing off, failing, cancelling, or deleting an export must
not mutate the selected Capabilities or related Goals, Steps, Proofs,
credentials, sources, plans, schedules, or learned state. An artifact is a
dated representation of the selected revisions, not a backup, restorable input,
credential, Proof, verified capability, or receiver-acceptance fact.

### REQ-013 — Receipts, History, and replay stay truthful

Canonical mutation must record the detailed local attempt and its truthful
external result without repeating the external effect during replay. Retry must
begin from current Capability truth, re-run classification, create a new exact
preview and confirmation, and produce a separate attempt rather than silently
reusing an earlier artifact or disclosure decision.

### REQ-014 — The experience is accessible and fail-quiet

Purpose, selection, field inclusion and exclusion, free-text resolution,
protected-segment warnings, exact preview, destination, confirmation, progress,
cancellation, result, staleness, deletion, and recovery must have deterministic
semantic order. All actions must support VoiceOver, Voice Control, Switch
Control, Full Keyboard Access, Dynamic Type, increased contrast, reduced
effects, non-color state, named non-gesture controls, status announcements, and
predictable focus restoration. Classification uncertainty or unavailable
handoff must block quietly with a recoverable explanation and no partial
disclosure.

## Acceptance criteria

1. **AC-001 (REQ-001):** Entering advisor-summary export and selecting
   Capability revisions creates no file, handoff, destination permission, or
   successful record; cancelling at that point leaves source data unchanged.
2. **AC-002 (REQ-002):** The rendered fixture contains only the selected name,
   reviewed meaning, permitted evidence/provenance labels and dates, and
   uncertainty/freshness note. Internal IDs, full sources, attachments, hidden
   state, history, credentials, third-party names, and unselected fields are
   absent from the exact bytes.
3. **AC-003 (REQ-003):** Known third-party, inferred protected, hidden, and
   unreviewed-source fixtures are ineligible. An unknown-classification segment
   blocks preview until edited into eligible text or removed and is never
   exported under a default-safe assumption.
4. **AC-004 (REQ-004):** Protected self-content begins excluded. Including one
   segment requires review of its exact text, destination, reason,
   minimum-purpose warning, and outside-copy boundary; the choice does not
   include another segment or survive a relevant revision change.
5. **AC-005 (REQ-005):** The confirmed preview byte-for-byte matches the
   created artifact. Changing any selected Capability, field, text, disclosure,
   purpose, or destination invalidates confirmation and prevents generation
   until a new preview is approved.
6. **AC-006 (REQ-006):** Cancel before generation leaves no artifact and no
   success. Local save retains only the explicitly chosen artifact; direct
   handoff retains no second rendered copy. Cancelled, failed, pending,
   successful local creation, successful handoff, and ambiguous handoff are
   presented as distinct outcomes.
7. **AC-007 (REQ-007):** Offline tests complete selection, classification,
   preview, and local save. Egress tests show no Capability content reaches a
   prohibited service, log, or diagnostic, and only the confirmed artifact is
   offered to the user-selected handoff action.
8. **AC-008 (REQ-008):** The detailed record contains purpose, revision
   references, category decisions, artifact fingerprint, destination class,
   time, and separate outcomes, while inspection proves it cannot reconstruct
   the rendered text, protected values, third-party values, or recipient.
9. **AC-009 (REQ-009):** Correcting a Capability after handoff marks the local
   export relationship stale and displays the outside-copy warning without
   claiming that the prior file was changed, recalled, or deleted.
10. **AC-010 (REQ-010):** Retained-artifact deletion removes bytes but preserves
    the selected content-minimized record. Combined deletion removes both; any
    surviving Receipt/History fact cannot reconstruct the exported content,
    destination identity, or protected segment.
11. **AC-011 (REQ-011):** Permanent Capability deletion warns about a known
    outside-copy possibility, removes its detailed export references and all
    Ambitions-retained artifacts containing it, and leaves no reconstructive
    Capability value while making no remote-deletion claim.
12. **AC-012 (REQ-012, REQ-013):** Export and deletion leave all source objects
    unchanged. Replay does not repeat a handoff, and retry requires current
    source truth, fresh classification, a new exact preview, new confirmation,
    and a separately inspectable attempt.
13. **AC-013 (REQ-014):** Direct accessibility verification covers selection,
    exclusions, free-text resolution, disclosure warnings, exact preview,
    destination, progress, cancellation, result, staleness, deletion, and
    recovery without gesture, color, motion, side-by-side layout, or
    visual-only meaning; blocked states disclose nothing.

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

- Canon requires a private Capability Export Record contract to own purpose,
  selected Capability revision references, category-level decisions, artifact
  fingerprint, destination class, separate creation/handoff outcomes,
  staleness, retention, and deletion without retaining exported content. The
  canonical Capability owner must own revision selection and the consequences
  of Capability correction or deletion.
- `docs/canon/specifications/systems/import-export-repair.md` should own the
  purpose-bound selective-export boundary, exact-artifact review, deterministic
  retry, cancellation, and the distinction between export, backup, and restore.
- `docs/canon/specifications/journeys/backup-restore-reset.md` should state that
  an advisor summary is not restorable product data and own user-visible local
  artifact, result, and deletion expectations where that journey intersects.
- `docs/canon/specifications/systems/privacy-and-data-classification.md` should
  own field minimization, fail-closed free-text classification, per-segment
  protected self-disclosure, destination-bound confirmation, prohibited egress,
  and the outside-copy boundary.
- Existing external-effect law should own local creation versus handoff,
  pending/result truth, idempotency, and the prohibition on replayed egress.
  `docs/canon/specifications/objects/receipt.md` and
  `docs/canon/specifications/objects/history-event.md` should own only the
  minimum non-reconstructive evidence their contracts permit.
- `docs/canon/specifications/surfaces/you.md` should own discoverability and
  selection; `docs/canon/specifications/global/trust-inspection.md` should own
  inspection of included/excluded categories, provenance limits, uncertainty,
  results, and outside-copy warnings. Existing offline, deletion, and
  accessibility canon remains fully applicable.

## Risks and open decisions

Resolved product decisions:

- The first purpose is a human-readable capability summary for a user-chosen
  career or education advisor, and the only first format is UTF-8 plain text.
- The artifact uses the fixed minimum field allowlist. Resume formatting,
  machine interchange, backup, source-object export, and credentials are not
  implied extensions.
- Unknown free text fails closed. Known third-party identifiers, inferred
  protected facts, hidden learned state, and unreviewed source excerpts are
  never eligible; protected self-content requires a per-segment decision.
- Confirmation binds exact bytes and destination. Local save and external
  handoff have independent results, and direct handoff retains no duplicate
  rendered artifact inside Ambitions.
- The detailed record is content-minimized. Local artifact deletion, detailed
  record deletion, Capability deletion, and the outside-copy boundary remain
  distinct.

Dependencies and delivery risks:

- This initiative depends on a canonical Capability owner with stable revision,
  correction, freshness, contradiction, and deletion semantics. Export must not
  invent or become that owner.
- Free-text classification can miss sensitive nuance; exact-byte preview and
  per-segment disclosure reduce accidental sharing but cannot guarantee a
  recipient's handling or downstream fairness.
- Destination applications may cancel, fail, retain temporary files, or report
  ambiguous results. Product copy and verification must preserve that
  uncertainty rather than claim delivery.
- Source attribution or redistribution obligations may make an otherwise plain
  evidence label ineligible. Design/grooming must establish deterministic
  fixtures without broadening the allowed fields.
- File-system and share-provider behavior can leave outside or temporary copies
  beyond Ambitions' deletion authority; deletion and data-remanence validation
  must keep local proof separate from external claims.
- Exact preview, Dynamic Type, assistive-technology reading order, cancellation,
  progress, and recovery require direct accessibility validation on the actual
  export surfaces.
