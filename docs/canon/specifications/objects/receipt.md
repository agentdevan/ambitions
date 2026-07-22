+++
spec_id = "OBJECT-RECEIPT"
title = "Receipt"
kind = "object"
status = "normative"
owner_domain = "object-receipt"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.receipt.identity-lifecycle"]
inherits = ["RUNTIME-MUTATION-SEQUENCE-001", "LAW-RUNTIME-DURABLE-SUCCESS-001", "CONST-PROOF-EVIDENCE-001"]
depends_on = ["CONSTITUTION", "OBJECT-PROOF", "GLOBAL-TRUST-INSPECTION", "SURFACE-YOU"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Trust/", "Native/Ambitions/Surfaces/You/", "Native/Ambitions/Quality/"]
+++

# Receipt

## OBJ-RECEIPT-IDENTITY-001 — User-readable meaningful-mutation record

- **Concept:** `object.receipt.identity-lifecycle`
- **Modality:** `MUST`
- **Scope:** Meaningful mutation, acceptance, consequence, and inspection
- **Status:** `normative`
- **Verification:** `SCENARIO-RUNTIME-MUTATION-001`
- **Supersedes:** none

A Receipt MUST be one durable, searchable, user-readable automatic record for a
mutation-registry-covered meaningful result, linked to command, owning domain,
accepted/rejected result, affected objects and revisions, History Events,
source/actor, consequence, external-effect status, replay, retention/privacy
class, and reversibility metadata. It attests to system behavior and remains
separate from user Proof. Navigation, selection, query, preview, refresh, and
cancellation do not create Receipts.

A Receipt MUST expose Undo only while an implemented typed inverse or
compensating command is eligible. A rollback ID, snapshot, or prior value is not
proof of Undo.

A Schedule Change Set MUST be a proposed or accepted group of placement changes with rationale, affected objects, confirmation state, receipt, and rollback context.

<!-- canon-section: stable-identity -->
Receipt identity is issued once for an idempotent mutation result and survives projection, search, external reconciliation, subject archive/Trash, correction links, and replay. Stable identifiers bind command and history lineage.

<!-- canon-section: user-meaning -->
A Receipt answers what Ambitions accepted or rejected, what changed, why, what remains pending, and how to inspect or reverse it. It never certifies user evidence quality.

Readable consequence summaries preserve user trust and control.

<!-- canon-section: relationships -->
It references command/idempotency key, affected canonical object/relationship IDs, History Events, source/actor, confirmation, external effects, rollback/reconciliation, and related Proof only as context. Relationships are immutable facts plus append-only resolution links.

<!-- canon-section: lifecycle -->
Lifecycle is issued and durable, optionally reconciled/superseded-by-correction with lineage, retained with subject history, or removed only under governed permanent-deletion/privacy law. Pending/succeeded/failed/reconciled external effect is an orthogonal axis.

<!-- canon-section: valid-transitions -->
Valid transitions append external-effect/reconciliation/correction facts to the same lineage and link reversal Receipts; governed deletion redacts/removes only approved scope. Durable acceptance remains immutable.

<!-- canon-section: invalid-transitions -->
Invalid transitions include editing accepted facts in place, issuing success before durable local commit, deleting failure/rejection history to appear successful, using Receipt as Proof, or external success rewriting local acceptance time. Validators preserve truthful lineage.

<!-- canon-section: commands -->
Receipts are emitted automatically only for operations whose mutation-registry
row requires them. User actions may inspect, search where approved, invoke a
proven linked Undo, or request governed deletion/redaction through supported
commands. Unsupported export or rollback controls remain absent. A Receipt
cannot synthesize partial settlement; independently settling scope results must
exist first.

<!-- canon-section: recurrence-scheduling -->
Receipts do not recur or consume capacity. A recurrence/placement mutation Receipt records series/occurrence scope and affected placement identifiers; it never becomes a schedule item.

<!-- canon-section: deletion-trash-restore-archive -->
Subject archive/Trash preserves Receipt lineage. Governed permanent deletion confirms audit, privacy, rollback, dependent history, export, and continuity scope; required integrity facts may be tombstoned/redacted only under approved law.

<!-- canon-section: history-receipts -->
Receipt is the readable consequence summary; History Events are exact before/after mutation facts. Every Receipt resolves its History Events and replay result; Proof remains a separate user-controlled object.

<!-- canon-section: privacy-sync-classification -->
Receipt content is private local graph data and may expose sensitive relationships. Account/R2 never receive it; display/export/diagnostics use minimum necessary fields and explicit redaction preview.

<!-- canon-section: import-export -->
Import/export/external-write mutations issue local Receipts that separate local acceptance from external pending/success/failure/reconciliation. Receipt export is explicit, scoped, and provenance-bearing.

<!-- canon-section: projection-surfaces -->
Trust and You own contextual/archive inspection; affected objects, Search, and Motion may link the exact Receipt. Projections preserve readable consequence and canonical IDs.

<!-- canon-section: accessibility -->
Semantics expose result, affected objects, before/after summary, source/actor, time, pending external effects, rationale, Undo/repair, and privacy in a stable reading order. Status never relies on color or animation.

Ordered actions name the exact affected object and reversal consequence.

<!-- canon-section: source-test-ownership -->
Canonical facts belong to `Core/Domain/`; issuance, idempotency binding, inspection, replay, reconciliation, and governed deletion belong to `Core/LocalRuntimeOS/Inspection/` and `Commands/`; Trust/You present it and `Quality/` proves durable-success ordering, rejection, Proof separation, replay, rollback, external reconciliation, deletion/privacy, offline, search, and accessibility. Tests bind every Receipt to command/history/object identifiers;
