+++
spec_id = "OBJECT-IMPORT-DIFF-RECORD"
title = "Import / Diff Record"
kind = "object"
status = "normative"
owner_domain = "object-import-diff-record"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.import-diff-record.identity-lifecycle"]
inherits = ["TIME-EXTERNAL-VISIBILITY-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-EVENT", "OBJECT-SOURCE-REFERENCE", "SURFACE-TIME", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/Time/", "Native/Ambitions/Quality/"]
+++

# Import / Diff Record

## OBJ-IMPORT-DIFF-RECORD-IDENTITY-001 — External-calendar review state

- **Concept:** `object.import-diff-record.identity-lifecycle`
- **Modality:** `MUST`
- **Scope:** Source event, native candidate, user decision, and impact
- **Status:** `normative`
- **Verification:** `SCENARIO-CALENDAR-IMPORT-DIFF-001`
- **Supersedes:** none

An Import / Diff Record MUST be one durable review identity linking an external source item/fingerprint, privacy-filtered fact, native candidate or linked object, field-level diff, user decision, schedule/capacity impact, Source Reference, Receipt, and rollback. Its state is unreviewed, imported, linked, kept external, ignored, or replaced with lineage.

<!-- canon-section: stable-identity -->
Record identity survives refresh, field diff changes, review decisions, replacement, source deletion/unavailability, archive, Trash, restore, and reconciliation. Stable source fingerprints prevent duplicate review identities.

<!-- canon-section: user-meaning -->
The record lets the user decide what an external calendar item should become and understand schedule/privacy effects before Ambitions changes native state. Review preserves choice.

<!-- canon-section: relationships -->
It references source system/item/fingerprint, privacy-filtered capacity fact, candidate/native Event or link, field diffs, occurrence/range scope, decision/impact, Source Reference, Receipt, and History Events. External and native identities remain distinct.

<!-- canon-section: lifecycle -->
Lifecycle is unreviewed, imported, linked, kept external, ignored, replaced-with-lineage, archived, Trashed, restored, or permanently deleted; source availability, freshness, conflict, and external effect are orthogonal.

<!-- canon-section: valid-transitions -->
Valid transitions include discovered→unreviewed, unreviewed→imported/linked/kept-external/ignored, prior decision→reviewed replacement after new diff, archive, governed Trash/restore, and deletion after source/native/history scope review. Each decision is durable.

<!-- canon-section: invalid-transitions -->
Invalid transitions include hidden external item silently becoming native Event, import overwriting local edits, source deletion deleting native object, ambiguous recurrence scope, private field leakage for capacity, adapter direct mutation, or replaced record losing prior decision. Validators preserve both sides.

<!-- canon-section: commands -->
Discover candidate, refresh diff, review, import, link, keep external, ignore, replace/reconcile, archive, Trash, restore, and delete use `Command → Event → Projection → Receipt → Replay`; adapters supply facts and cannot accept decisions or mutate native state.

<!-- canon-section: recurrence-scheduling -->
Diffs declare occurrence-only, future, entire-series, or selected-import-range scope. External capacity may affect fit while private content stays hidden; accepted import creates/reconciles native Event recurrence and Schedule Placement separately.

Each reconciliation command stores its selected occurrence range.

<!-- canon-section: deletion-trash-restore-archive -->
Ignore/keep external/archive/Trash/delete are distinct. Restore repairs review/source/native links; permanent deletion confirms source reference, native object, recurrence range, history/search/export, external write, and rollback scope.

<!-- canon-section: history-receipts -->
Every accepted import/link/keep/ignore/replace/reconcile decision and material native/external effect creates automatic Receipt and before/after History Events, separating local acceptance from external result.

<!-- canon-section: privacy-sync-classification -->
External titles/attendees/locations/notes and native mappings are private local data. Privacy-filtered capacity may omit content; Account/R2/Source Atlas never receive private diff context.

<!-- canon-section: import-export -->
Import is the object’s core reviewed action and preserves source fingerprint, selected fields, decision, native ID, and diff lineage. Export/writeback is separately previewed; refresh/re-import performs deterministic diff/reconciliation.

<!-- canon-section: projection-surfaces -->
Time owns calendar review; You owns broad Sources & Imports controls; Trust/Search/native detail inspect source/diff/decision. Every projection retains record, source, and native IDs.

<!-- canon-section: accessibility -->
Semantics expose source item summary at approved privacy level, changed fields, prior/new values, recurrence scope, capacity impact, conflicts, destination choices, external effects, and Undo without side-by-side visual dependence.

<!-- canon-section: source-test-ownership -->
Canonical review semantics belong to `Core/Domain/`; external adapters/diff reconciliation, scheduling impact, commands, and inspection belong to `Core/LocalRuntimeOS/ExternalWrites/`, `Scheduling/`, `Commands/`, and `Inspection/`; Time presents review and `Quality/` proves all decisions, field/series diffs, privacy-filtered capacity, local/external separation, rollback/replay, source deletion, offline, and accessibility. Tests bind decisions to stable record/source/native IDs; current implementation compliance is unclaimed.
