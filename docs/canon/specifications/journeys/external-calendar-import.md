+++
spec_id = "JOURNEY-EXTERNAL-CALENDAR-IMPORT"
title = "External Calendar Import"
kind = "journey"
status = "normative"
owner_domain = "journey-external-calendar-import"
canon_revision = 1
profile = "journey-v1"
owns_concepts = ["journey.calendar-diff.conflict-choice", "journey.calendar-diff.grouping", "journey.calendar-diff.no-silent-mutation", "journey.calendar-diff.notification-handoff", "journey.calendar-invite-diff",
  "journey.calendar-import.commit",
  "journey.calendar-import.candidate",
]
inherits = ["TIME-EXTERNAL-VISIBILITY-001", "CONTROL-MATERIAL-CONFIRMATION-001", "LAW-RUNTIME-NO-DIRECT-WRITE-001", "LAW-RUNTIME-DURABLE-SUCCESS-001"]
depends_on = ["CONSTITUTION", "APP-PERMISSIONS", "SURFACE-TIME", "OBJECT-IMPORT-DIFF-RECORD", "OBJECT-EVENT", "OBJECT-SOURCE-REFERENCE", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Surfaces/Time/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Trust/", "Native/Ambitions/Quality/"]
+++

# External Calendar Import

This shadow journey coordinates reviewed import; Event and Import/Diff Record owners retain identity, recurrence, decision, and lifecycle law.

## JOURNEY-CALENDAR-DIFF-001 — External facts never silently mutate native Time

- **Concept:** `journey.calendar-diff.no-silent-mutation`
- **Modality:** `MUST`
- **Scope:** Discovery, diff, import, link, keep-external, ignore, and reconciliation
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-CALENDAR-DIFF-001`
- **Supersedes:** none

An external calendar adapter MUST supply facts to typed discovery/refresh commands, never mutate state itself. Discovery and refresh are durable local commits of the Import/Diff Record, source lineage, unreviewed state, and badge contribution with Receipt/replay; that commit creates no Ambitions Event and reserves no planning capacity until an explicit review outcome. `Import into Ambitions`, Link, Replace, `Keep external but reserve time`, `Ignore for planning`, and `Reject permanently` remain non-durable outcome previews until confirmed.

Ambitions MUST NOT silently import, mutate, or reflow when the user adds or changes items in Apple Calendar.

Imported or replaced Ambitions-owned objects MUST NOT mutate silently when Apple Calendar changes.

Time MUST NOT show persistent source markers for imported native objects.

Rejected or ignored external calendar items MUST be dismissed and MUST NOT continue contributing to the badge count.

Pending external-import review MUST appear as a small actionable control in the Time header or toolbar with the unreviewed-item count.

An external calendar change MUST NOT commit silently.

Apple Calendar and other approved calendar sources MUST be onboarding, migration, and external-change sources.

Import MUST create an Ambitions-owned object with provenance and a Receipt.

An external calendar change MUST NOT silently mutate an Ambitions-owned object.

An External Calendar Candidate MUST be an external item awaiting user review.

## JOURNEY-CALENDAR-DIFF-GROUPING-001 — Pending review is grouped by schedule impact
- **Concept:** `journey.calendar-diff.grouping`
- **Modality:** `MUST`
- **Scope:** External calendar diff review
- **Status:** `normative`
- **Verification:** `SCENARIO-CALENDAR-DIFF-GROUPING-001`
- **Supersedes:** none

External diff review MUST group pending items as Needs attention, Safe to import, Duplicate or link candidates, Removed source, or Ignored history so schedule consequence outranks raw chronology or source administration.

## JOURNEY-CALENDAR-CONFLICT-CHOICE-001 — Import conflicts are chosen before commit
- **Concept:** `journey.calendar-diff.conflict-choice`
- **Modality:** `MUST`
- **Scope:** Selected external item conflicting with Ambitions Time
- **Status:** `normative`
- **Verification:** `SCENARIO-CALENDAR-IMPORT-CONFLICT-001`
- **Supersedes:** none

Before import commit, Ambitions MUST show affected objects, available reflow, and consequences and let the user choose Import and reflow, Import without reflow, Keep external, Ignore, or Edit before import. Import never silently triggers reflow.

An External Calendar Candidate MUST NOT appear as an Ambitions Event before import.

## JOURNEY-CALENDAR-NOTIFICATION-HANDOFF-001 — Import never silently duplicates alerts
- **Concept:** `journey.calendar-diff.notification-handoff`
- **Modality:** `MUST NOT`
- **Scope:** External alerts and Ambitions Notification Rules during import
- **Status:** `normative`
- **Verification:** `SCENARIO-CALENDAR-NOTIFICATION-HANDOFF-001`
- **Supersedes:** none

Import MUST NOT silently alter Apple Calendar alerts or create duplicate notifications. Review shows existing alerts, proposed Ambitions rules, and duplication risk and offers Import with Ambitions notifications, Import without them, Edit notification rules, or Keep external.

Imported Apple Calendar alerts MUST become Ambitions-native notification settings on the imported Event.

During import review, Ambitions MUST show existing external alerts, the Ambitions-native notification rules that will be created, and any duplicate-notification risk.

Calendar notification handoff MUST offer Import with Ambitions notifications, Import without Ambitions notifications, Edit notification rules, and Keep external.

<!-- canon-section: trigger-starting-state -->
Triggers are permission-approved source scan, manual import, changed external fingerprint, Time review, or reconciliation notice; starting state identifies source, privacy-filtered fact, fingerprint, prior decision, native link, diff, recurrence range, capacity effect, permission, and freshness.

<!-- canon-section: preconditions -->
Permission is contextual and current; minimum necessary source facts can be read; stable fingerprinting and local review storage are available. Permission denial and offline use preserve Ambitions-owned Time.

<!-- canon-section: happy-path -->
Read source facts through the adapter, validate a typed discovery or refresh command, durably create/update the Import/Diff Record, source lineage, unreviewed state, and badge contribution, and issue its Receipt/replay without creating an Ambitions Event or reserving capacity. Then present privacy-safe differences and every exact reviewed outcome; preview native-object, capacity, decision-lineage, badge, and external consequences independently; confirm range/destination where applicable; commit the review decision locally with a separate Receipt/history; and only then perform any external write. `Import into Ambitions` alone creates the selected canonical native object; Replace preserves one existing canonical identity, and Link retains external authority without creating a second canonical Event.

<!-- canon-section: branches -->
Each reviewed decision stores source fingerprint, exact decision label, native-object effect, capacity effect, lineage effect, and badge effect as separate facts.
Branches are `Import into Ambitions`, Replace, Link, `Keep external but reserve time`, `Ignore for planning`, `Reject permanently`, select occurrence/future/series/range, redact optional fields, or revoke permission. `Import into Ambitions` creates a native object with provenance and removes its candidate from the unreviewed badge. `Keep external but reserve time` creates no native Event UI/object, keeps external authority, reserves planning capacity, records the reviewed decision/source mapping, and removes its badge contribution. `Ignore for planning` creates no native object, reserves no capacity, retains ignored-history lineage, and removes its badge contribution. `Reject permanently` creates no native object or capacity reservation, stores dismissal lineage, removes its badge contribution, and suppresses that candidate lineage unless a materially new external item appears.

<!-- canon-section: cancellation -->
A canceled pre-discovery preview commits no Import/Diff Record, source lineage, or badge contribution. Once discovery/refresh commits, canceling or dismissing review preserves the durable Import/Diff Record, source lineage, unreviewed badge contribution, zero native-object creation, and zero capacity effect. Canceling an outcome preview creates no reviewed decision or native object; permission revocation stops reads without deleting accepted local records or rewriting prior decisions.

<!-- canon-section: interruption-resume -->
Resume discovery/refresh from the durable Import/Diff Record, source lineage, unreviewed state, badge contribution, and discovery Receipt/replay, with no implied Event or capacity reservation. Resume review from that durable base plus any prior decision, field selection, range, capacity choice, dismissal/ignored lineage, badge state, and focus. A changed source fingerprint commits a refresh lineage before invalidating outcome confirmation; a permanently rejected lineage returns only for a materially new external item.

<!-- canon-section: commit-boundary -->
Two command IDs separate discovery acceptance from review-outcome acceptance, and each resolves its own Receipt/replay chain.
The discovery command validates candidate/source identity and diff facts before durably committing the Import/Diff Record, source lineage, unreviewed state, badge contribution, Receipt, and replay. It commits no Ambitions Event and no capacity reservation. Any pre-discovery preview is non-durable. After discovery, field selection, consequence preview, and outcome selection remain non-durable as reviewed-decision, native-object, or capacity state while retaining the durable unreviewed lineage/badge base. Import/Replace/Link or one of the three exact external-only decisions crosses a second boundary only after current validation, confirmation, local decision commit, projection, and Receipt; writeback follows after that local commit.

<!-- canon-section: failure -->
The failure record retains candidate/source/native IDs, discovery/refresh commit result, prior review decision, capacity reservation, source/decision lineage, badge state, and external result.
Failure before discovery commit creates no review record or badge. Failure after a durable discovery/refresh commit preserves its Import/Diff Record, source lineage, unreviewed badge, zero native-object/capacity effect, and Receipt/replay. Recurrence ambiguity, invalid outcome, review rejection, partial import, or external-write failure preserves the last committed review/native/capacity/lineage/badge truth and states exactly what remains local, external, pending, or failed.

<!-- canon-section: recovery -->
Offer reauthorize before discovery, retry discovery idempotently, refresh the durable diff/source lineage, resume review with the unreviewed badge intact, choose fewer fields/range, Link instead, choose one exact external-only outcome, reconcile local/external divergence, or restore the prior native mapping/decision from history. Recovery never erases a committed discovery lineage or converts discovery alone into native-object/capacity state.

<!-- canon-section: undo-rollback -->
Every supported reversal records the prior and restored native-object, capacity, lineage, and badge facts under the same candidate/source identifiers.
Undo an Import/Link/Replace or reversible reviewed decision through canonical commands and retain the review record, source lineage, capacity history, badge history, and Receipt. Permanent rejection follows its declared dismissal lineage rather than a generic Undo promise; external reversal is separately queued/reconciled, and source deletion never silently deletes a native Event.

<!-- canon-section: receipts-proof -->
Discovery/refresh Receipts and History Events bind the Import/Diff Record, source fingerprint/lineage, unreviewed state, badge contribution, zero native-object creation, and zero capacity reservation. Separate review-decision Receipts/history record the exact outcome, native-object creation or noncreation, capacity reservation or nonreservation, dismissal/ignored lineage, badge removal, field/range scope, privacy selection, external dispatch/result, reconciliation, and undo. An Import/Diff Record or source fact is not user Proof.

<!-- canon-section: accessibility -->
Semantics expose source summary at approved privacy level, changed fields and prior/new values, range, native-object consequence, capacity reservation, dismissal lineage, badge consequence, destination, external effects, exact choice labels, and applicable recovery without side-by-side or color dependence; focus returns to the record/native object and Dynamic Type stacks diffs.

<!-- canon-section: offline -->
Ambitions-owned Time and previously committed Import/Diff Records, source lineage, unreviewed badges, review decisions, native facts, capacity reservations, ignored history, dismissal lineage, Receipts, and replay remain usable offline. New source reads/writes wait; offline review of stored facts preserves the discovery-versus-outcome boundaries and never converts stale external facts into native Events or uploads private context.

<!-- canon-section: scenario-tests -->
Execute `SCENARIO-JOURNEY-CALENDAR-DISCOVERY-COMMIT-001`, `SCENARIO-JOURNEY-CALENDAR-REFRESH-COMMIT-001`, `SCENARIO-JOURNEY-CALENDAR-PREDISCOVERY-CANCEL-001`, `SCENARIO-JOURNEY-CALENDAR-REVIEW-DISMISS-001`, `SCENARIO-JOURNEY-CALENDAR-IMPORT-NATIVE-001`, `SCENARIO-JOURNEY-CALENDAR-KEEP-EXTERNAL-RESERVE-001`, `SCENARIO-JOURNEY-CALENDAR-IGNORE-PLANNING-001`, `SCENARIO-JOURNEY-CALENDAR-REJECT-PERMANENTLY-001`, `SCENARIO-JOURNEY-CALENDAR-RECURRENCE-001`, `SCENARIO-JOURNEY-CALENDAR-PERMISSION-001`, `SCENARIO-JOURNEY-CALENDAR-EXTERNAL-FAILURE-001`, and `SCENARIO-JOURNEY-CALENDAR-UNDO-001`; independently assert discovery/refresh durable Record/source-lineage/unreviewed-badge Receipt/replay, no Event or capacity from discovery alone, pre-discovery preview non-durability, review dismissal preservation, each outcome's native/capacity/lineage/badge effects, materially-new-item reappearance, adapter non-mutation, stable IDs, local-before-external ordering, offline safety, and accessible diff review.



## JOURNEY-CALENDAR-INVITE-DIFF-001 — Imported invite diff review

- **Concept:** `journey.calendar-invite-diff`
- **Modality:** `MUST NOT`
- **Scope:** Imported invite diff review
- **Status:** `normative`
- **Verification:** `REVIEW-JOURNEY-CALENDAR-INVITE-DIFF-001`
- **Supersedes:** none

Imported invite Events MUST preserve attendee, organizer, RSVP, location, notes, and source metadata; later changes MUST enter external diff review with explicit accept, keep, split, unlink, or ignore choices and MUST NOT silently mutate native truth.

## JOURNEY-CALENDAR-IMPORT-COMMIT-001 — Calendar import commit

- **Concept:** `journey.calendar-import.commit`
- **Modality:** `MUST`
- **Scope:** Accepted import decisions
- **Status:** `normative`
- **Verification:** `SCENARIO-CALENDAR-IMPORT-COMMIT-001`
- **Supersedes:** none

An accepted calendar import MUST validate the selected diff, commit local canonical state atomically, preserve source lineage, and issue Receipt and History evidence.

## JOURNEY-CALENDAR-CANDIDATE-001 — Calendar import candidate

- **Concept:** `journey.calendar-import.candidate`
- **Modality:** `MUST`
- **Scope:** Unreviewed imported records
- **Status:** `normative`
- **Verification:** `SCENARIO-CALENDAR-CANDIDATE-001`
- **Supersedes:** none

An unreviewed imported record MUST remain a candidate and MUST NOT silently become an Ambitions Event, reserve canonical capacity, or authorize outbound mutation.
