+++
spec_id = "OBJECT-ATTACHMENT"
title = "Attachment"
kind = "object"
status = "normative"
owner_domain = "object-attachment"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.attachment.identity-privacy"]
inherits = ["OBJECT-LIFECYCLE-DELETION-001", "LAW-LOCAL-AUTHORITY-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "GLOBAL-CAPTURE", "OBJECT-PROOF", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Storage/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Trust/", "Native/Ambitions/Quality/"]
+++

# Attachment

## OBJ-ATTACHMENT-IDENTITY-001 — Durable local media, file, or link record

- **Concept:** `object.attachment.identity-privacy`
- **Modality:** `MUST`
- **Scope:** Attachment identity, storage, privacy, and deletion
- **Status:** `normative`
- **Verification:** `SCENARIO-ATTACHMENT-LIFECYCLE-001`
- **Supersedes:** none

An Attachment MUST be one durable local media, file, or link record associated with an object, draft, or Proof through explicit relationships. It is export-controlled, independently inspectable, and deletable without becoming a copy of its parent.

<!-- canon-section: stable-identity -->
Attachment identity survives filename/metadata changes, processing state, relinking, local relocation, archive, Trash, restore, and export. Content digests support integrity without replacing identity.

<!-- canon-section: user-meaning -->
An Attachment preserves supporting material the user intentionally keeps with life context. It does not imply Proof, completion, execution, or public sharing.

<!-- canon-section: relationships -->
It may link to multiple approved local objects/drafts/Proof records, source provenance, Receipts, and History Events. Deleting a link differs from deleting shared content.

<!-- canon-section: lifecycle -->
Lifecycle is active, unavailable-with-recovery, archived, Trashed, restored, or permanently deleted; processing, permission, local availability, and export state are orthogonal. Status remains inspectable.

Typed lifecycle commands record the affected Attachment identifier and prior state.

<!-- canon-section: valid-transitions -->
Valid transitions include ingest→active, active↔unavailable after source/permission change, relink, active→archived, supported state→Trash, Trash→prior state, and permanent deletion after reference-scope confirmation. Per-part failure retains accepted material.

Accepted transitions retain content integrity and parent relationships.

<!-- canon-section: invalid-transitions -->
Invalid transitions include attachment failure deleting parent input, parent deletion silently deleting shared content, link removal implying file erasure, cloud upload without explicit authority, or media content auto-certifying Proof. Validators preserve parent state.

<!-- canon-section: commands -->
Ingest, link/unlink, rename metadata, replace, retry processing, export, archive, Trash, restore, and permanently delete use `Command → Event → Projection → Receipt → Replay`; large-content work is bounded and cancellation-safe.

<!-- canon-section: recurrence-scheduling -->
Attachments do not recur, consume capacity, carry due dates, or own placements/alerts. Parent scheduling never changes Attachment lifecycle.

<!-- canon-section: deletion-trash-restore-archive -->
Unlink, archive, Trash, and permanent content deletion are distinct. Trash preserves bytes or recoverable locator per policy; restore repairs links; permanent deletion confirms every parent/link, export, history/search, storage, and rollback consequence.

<!-- canon-section: history-receipts -->
Ingest, material metadata/content replacement, link changes, export, Trash, restore, and deletion create automatic Receipts/History Events with digest/provenance and per-part outcome. These records are not user Proof.

<!-- canon-section: privacy-sync-classification -->
Attachment bytes, metadata, thumbnails, OCR, and links are private local data by default. Account/R2/Source Atlas never receive them; export/share and any approved continuity path require explicit classification, preview, and consent.

<!-- canon-section: import-export -->
Import records source, content digest, permission/bookmark state, and local copy/link policy. Export enumerates bytes/metadata and destination; re-import reconciles digest/provenance without silent duplication.

<!-- canon-section: projection-surfaces -->
Parent object, Capture, Proof, Search, and Trust may project thumbnail/summary/status. Every action resolves Attachment and parent identifiers; unavailable media retains descriptive context and recovery.

Projection actions route to canonical attachment commands.

<!-- canon-section: accessibility -->
Semantics expose type, accessible name/description, parent context, availability, privacy, source, size consequence, and open/replace/remove/export actions. Media meaning has a text equivalent.

<!-- canon-section: source-test-ownership -->
Canonical metadata semantics belong to `Core/Domain/`; local storage, streaming, mutation, and inspection belong to `Core/LocalRuntimeOS/Storage/`, `Commands/`, and `Inspection/`; Trust presents it and `Quality/` proves per-part failure, permission denial, shared-link deletion, integrity, export scope, Trash/restore, replay, resource pressure, privacy, and accessibility. Tests bind bytes/links to stable Attachment identifiers;
