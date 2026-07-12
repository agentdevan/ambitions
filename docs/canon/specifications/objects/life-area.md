+++
spec_id = "OBJECT-LIFE-AREA"
title = "Life Area"
kind = "object"
status = "normative"
owner_domain = "object-life-area"
canon_revision = 1
profile = "object-v1"
owns_concepts = [
  "object.life-area.suggested-defaults",
  "object.life-area.identity",
  "object.identity-common-fields",
  "object.identity.canonical",
  "object.owner.mutation",
  "object.state.orthogonal-axes",
  "object.memory.lifecycle-retention",
  "object.archive.planning-influence",
  "object.life-capital.editability",
  "object.life-capital.anti-gamification",
]
inherits = ["OBJECT-TAXONOMY-001", "OBJECT-CANONICAL-GRAPH-001", "OBJECT-LIFECYCLE-DELETION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "SURFACE-GOALS", "GLOBAL-CAPTURE", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/Goals/", "Native/Ambitions/Quality/"]
+++

# Life Area

## OBJ-LIFE-AREA-IDENTITY-001 — Broad editable life region

- **Concept:** `object.life-area.identity`
- **Modality:** `MUST`
- **Scope:** Life Area identity and ownership
- **Status:** `normative`
- **Verification:** `SCENARIO-LIFE-AREA-LIFECYCLE-001`
- **Supersedes:** none

A Life Area MUST be one stable, editable region of life that contains Goals and may relate free Steps or Notes. Active, hidden, archived, restored, and Trashed presentations retain that identity and do not create per-surface copies.

Life Areas MUST remain a broad editable atlas rather than ranked score cards.

A Life Area MUST be a broad, editable organizing region for direction, goals, proof, recovery, and related context.

## OBJ-COMMON-ENVELOPE-001 — Common canonical envelope

- **Concept:** `object.identity-common-fields`
- **Modality:** `MUST`
- **Scope:** Every applicable canonical object family
- **Status:** `normative`
- **Verification:** `AUDIT-OBJECT-COMMON-ENVELOPE-001`
- **Supersedes:** none

Every canonical object MUST carry stable local identity, created/updated timestamps, applicable lifecycle and orthogonal state axes, provenance, private-data and continuity classification, relationship lineage, and a recoverable soft-delete path where supported.

## OBJ-CANONICAL-IDENTITY-001 — One identity for one object

- **Concept:** `object.identity.canonical`
- **Modality:** `MUST`
- **Scope:** Canonical object identity
- **Status:** `normative`
- **Verification:** `SCENARIO-CANONICAL-IDENTITY-001`
- **Supersedes:** none

One real-world Ambitions object MUST have one canonical local identity across Today, Goals, Time, You, Search, inspection, widgets, App Intents, exports, and accessibility projections.

## OBJ-CANONICAL-OWNER-001 — One mutation owner

- **Concept:** `object.owner.mutation`
- **Modality:** `MUST`
- **Scope:** Canonical mutation routing
- **Status:** `normative`
- **Verification:** `AUDIT-RUNTIME-DIRECT-WRITE-001`
- **Supersedes:** none

Each object family MUST have one canonical mutation owner under `Core/LocalRuntimeOS/`; multiple read projections route typed commands to that owner and never become write authorities.

## OBJ-STATE-AXES-001 — Orthogonal state axes

- **Concept:** `object.state.orthogonal-axes`
- **Modality:** `MUST NOT`
- **Scope:** Lifecycle, placement, time, execution, proof, recovery, source, and sync state
- **Status:** `normative`
- **Verification:** `AUDIT-OBJECT-STATE-AXES-001`
- **Supersedes:** none

Applicable lifecycle, placement, time, execution, proof, recovery, source, and sync axes MUST remain orthogonal and MUST NOT be compressed into one overloaded enum. A change on one axis cannot silently imply a change on another.

## OBJ-MEMORY-RETENTION-001 — Retain until governed deletion

- **Concept:** `object.memory.lifecycle-retention`
- **Modality:** `MUST`
- **Scope:** Canonical local memory and deletion
- **Status:** `normative`
- **Verification:** `SCENARIO-OBJECT-DELETION-001`
- **Supersedes:** none

Accepted canonical meaning, lineage, and history MUST remain locally inspectable until the user performs the applicable governed deletion; archive, hide, completion, and closure do not erase it.

Ambitions memory MUST remain retained until the user performs governed deletion.

## OBJ-ARCHIVE-SEMANTICS-001 — Archive removes planning influence

- **Concept:** `object.archive.planning-influence`
- **Modality:** `MUST`
- **Scope:** Archived object behavior
- **Status:** `normative`
- **Verification:** `SCENARIO-OBJECT-ARCHIVE-001`
- **Supersedes:** none

Archive MUST stop the archived object from influencing ordinary future planning while preserving identity, relationships, history, receipts, restore, and explicit inspection.

## OBJ-LIFE-AREA-SUGGESTED-DEFAULTS-001 — Defaults remain suggestions
- **Concept:** `object.life-area.suggested-defaults`
- **Modality:** `MAY`
- **Scope:** First-use Life Area suggestions and later organization
- **Status:** `normative`
- **Verification:** `SCENARIO-LIFE-AREA-DEFAULTS-001`
- **Supersedes:** none

Ambitions MAY offer suggested Life Areas as a starting point. The user can rename, hide, reorder, replace, or remove every suggestion; no default silently becomes identity, planning priority, or permanent taxonomy.

Ambitions MUST start with suggested Life Area defaults, and the user MAY rename, hide, reorder, or customize them.

<!-- canon-section: stable-identity -->
Life Area identity is generated locally once and survives rename, hide, archive, restore, reordering, and projection changes. A title, color, icon, or Goals grouping is not identity.

<!-- canon-section: user-meaning -->
A Life Area helps the user organize a broad region such as health, work, home, or relationships without requiring a score, rigid ontology, or exposed graph language.

<!-- canon-section: relationships -->
It contains Goals and may relate free Steps and Notes. Child relationships reference canonical identities; deleting or moving a Life Area requires an impact preview and never silently deletes children.

<!-- canon-section: lifecycle -->
Lifecycle is active, hidden, archived, Trashed, restored, or permanently deleted. Hidden affects presentation, archive affects planning influence, and neither means completion or deletion.

<!-- canon-section: valid-transitions -->
Valid transitions are create→active; active↔hidden; active/hidden→archived; archived→active or hidden through restore; supported live states→Trash; Trash→the last valid live state; and Trash→permanent deletion after consequence confirmation.

<!-- canon-section: invalid-transitions -->
Invalid transitions include archive→completed, hide→deleted, projection-only mutation, direct permanent deletion without Trash/confirmation where recovery is supported, and any transition that orphans children without an explicit reassignment plan.

<!-- canon-section: commands -->
Create, rename, reorder, hide, show, archive, restore, move children, Trash, restore from Trash, and permanently delete use `Command → Event → Projection → Receipt → Replay`, including validation, rollback preparation, history, and truthful rejection receipts.

<!-- canon-section: recurrence-scheduling -->
Life Areas do not recur or consume capacity. Their Goals and Steps may carry independent recurrence and Schedule Placement relationships.

<!-- canon-section: deletion-trash-restore-archive -->
Trash preserves lineage and affected-child review. Restore repairs projections and planning influence according to the restored lifecycle. Permanent deletion confirms child scope, export/continuity consequences, tombstones if an approved continuity system exists, and rollback limits.

<!-- canon-section: history-receipts -->
Material edits, child moves, archive, Trash, restore, and permanent-deletion acceptance emit automatic mutation Receipts and History Events; these are not user Proof.

<!-- canon-section: privacy-sync-classification -->
Life Area names, relationships, and planning influence are private local graph data. Account and R2 never receive them. classification changes require preview and receipt.

<!-- canon-section: import-export -->
Import creates or links one local identity only after preview. Export is explicit and scoped. Re-import reconciles provenance/lineage instead of duplicating a Life Area; deletion/export interactions state what cannot be restored.

<!-- canon-section: projection-surfaces -->
Goals owns the primary Life Area presentation; Today, Time, You, Capture, Search, and Trust may show derived context. Every actionable projection retains canonical ID and routes mutation to the owner.

<!-- canon-section: accessibility -->
Every projection exposes name, lifecycle, planning influence, child count, consequence, and actions in a stable reading order without color or spatial position alone; focus returns to the restored or next valid object.

VoiceOver actions name the affected Life Area and the exact lifecycle consequence.

<!-- canon-section: source-test-ownership -->
Canonical target ownership is `Core/Domain/` for value semantics and `Core/LocalRuntimeOS/Planning/`, `Commands/`, and `Inspection/` for mutation/history; `Surfaces/Goals/` presents it and `Quality/` proves lifecycle, child-impact, Trash/restore, replay, offline, privacy, and accessibility scenarios.

## OBJ-LIFE-CAPITAL-EDITABILITY-001 — Life Capital editability

- **Concept:** `object.life-capital.editability`
- **Modality:** `MUST`
- **Scope:** Life Capital records
- **Status:** `normative`
- **Verification:** `SCENARIO-LIFE-CAPITAL-EDIT-001`
- **Supersedes:** none

Life Capital records MUST remain inspectable and user-editable without converting them into scores, streaks, or hidden behavioral authority.

## OBJ-LIFE-CAPITAL-ANTI-GAMIFICATION-001 — Life Capital anti-gamification

- **Concept:** `object.life-capital.anti-gamification`
- **Modality:** `MUST NOT`
- **Scope:** Life Capital presentation and use
- **Status:** `normative`
- **Verification:** `AUDIT-LIFE-CAPITAL-ANTI-GAMIFICATION-001`
- **Supersedes:** none

Life Capital MUST NOT become a score, streak, rank, XP system, shame mechanism, or hidden mutation authority.
