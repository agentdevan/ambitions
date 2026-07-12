+++
spec_id = "OBJECT-SOURCE-REFERENCE"
title = "Source Reference"
kind = "object"
status = "normative"
owner_domain = "object-source-reference"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.source-reference.identity-visibility"]
inherits = ["TIME-EXTERNAL-VISIBILITY-001", "LAW-R2-PUBLIC-ONLY-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-EVENT", "GLOBAL-TRUST-INSPECTION", "SURFACE-YOU"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Trust/", "Native/Ambitions/Quality/"]
+++

# Source Reference

## OBJ-SOURCE-REFERENCE-IDENTITY-001 — Inspectable provenance after native import

- **Concept:** `object.source-reference.identity-visibility`
- **Modality:** `MUST`
- **Scope:** Imported, shared, captured, or public-reference provenance
- **Status:** `normative`
- **Verification:** `SCENARIO-SOURCE-INSPECTION-001`
- **Supersedes:** none

A Source Reference MUST be one provenance record for an imported, shared, captured, or approved public-reference input, linked to its native candidate/object and available for inspection after native import/link. It never makes an external system the private-graph authority.

<!-- canon-section: stable-identity -->
Source Reference identity survives freshness checks, reconciliation, locator changes, parent edits, archive, Trash, restore, and external unavailability. Stable fingerprints preserve provenance lineage.

<!-- canon-section: user-meaning -->
Source explains where relevant information came from, how fresh it is, and what Ambitions imported or linked. It supports trust without crowding primary UI.

<!-- canon-section: relationships -->
It may link source system/public pack, external identifier/fingerprint, native candidate/object, Import/Diff Record, attachment, Receipt, freshness/reconciliation facts, and History Events. Private object identity remains local.

<!-- canon-section: lifecycle -->
Lifecycle is active, stale-with-inspectable-fact, unavailable-with-recovery, superseded-with-lineage, archived, Trashed, restored, or permanently deleted; freshness, permission, and import/link state are orthogonal.

Typed lifecycle commands retain provenance and parent relationships.

<!-- canon-section: valid-transitions -->
Valid transitions include candidate→linked after user approval, active→stale/unavailable, refresh/reconcile, supersede with lineage, archive, governed Trash/restore, and deletion after parent/provenance scope review. Accepted transitions preserve source facts.

Accepted transitions retain source fingerprints and native identifiers.

<!-- canon-section: invalid-transitions -->
Invalid transitions include external item silently becoming native Event, source mutation overwriting local edits, R2 receiving private context, hidden external content leaking through capacity, stale source deleting local object, or locator reuse changing identity. Validators preserve local authority.

<!-- canon-section: commands -->
Create from intake, review/link, refresh metadata, reconcile, detach, archive, Trash, restore, and delete use `Command → Event → Projection → Receipt → Replay`; adapters translate facts and cannot mutate canonical meaning directly.

<!-- canon-section: recurrence-scheduling -->
Source References do not recur, consume capacity, or own placements. Referenced Event/Step series and external occurrence identifiers remain distinct and reconcile through explicit scope.

<!-- canon-section: deletion-trash-restore-archive -->
Detach, archive, Trash, and permanent deletion are distinct from deleting the native object or external source. Restore repairs provenance projections; deletion confirms parent, import/diff, attachment, history/search/export, and rollback scope.

<!-- canon-section: history-receipts -->
Import/link, freshness/reconciliation, detach, archive, Trash, restore, and deletion create automatic Receipts/History Events. Public provenance/freshness receipts remain separate from private mutation Receipts and user Proof.

<!-- canon-section: privacy-sync-classification -->
Locators, imported metadata, parent links, and reconciliation facts are classified by source and private context. R2/Source Atlas hold public reference/freshness data only; private graph facts never egress.

<!-- canon-section: import-export -->
Import preserves external ID/fingerprint, reviewed field mapping, local decision, and native object ID. Export includes provenance only when selected; re-import uses diff rather than silent overwrite or duplication.

<!-- canon-section: projection-surfaces -->
Trust owns contextual source inspection; You owns broad Sources & Imports controls; Time/Search/object detail may link it after native import/link. Projections preserve local/private and external/public boundaries.

<!-- canon-section: accessibility -->
Semantics expose source name/type, imported/linked object, freshness, permission/availability, privacy boundary, changed fields, and review/retry/detach actions without technical locator noise in primary labels.

<!-- canon-section: source-test-ownership -->
Canonical provenance semantics belong to `Core/Domain/`; external adapters/reconciliation, public references, commands, and inspection belong to `Core/LocalRuntimeOS/ExternalWrites/`, `SourceAtlas/`, `Commands/`, and `Inspection/`; Trust/You present it and `Quality/` proves native-import visibility, stale/unavailable recovery, local authority, R2 firewall, diff/replay, Trash/restore, offline, privacy, and accessibility. Tests bind provenance to source/native identifiers; current implementation compliance is unclaimed.

Scenario fixtures bind every source transition to stable provenance identifiers.
