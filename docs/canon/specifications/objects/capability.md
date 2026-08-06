+++
spec_id = "OBJECT-CAPABILITY"
title = "Capability"
kind = "object"
status = "normative"
owner_domain = "object-capability"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.capability.identity-continuity"]
inherits = ["OBJ-LIFE-CAPITAL-EDITABILITY-001", "OBJ-LIFE-CAPITAL-ANTI-GAMIFICATION-001", "SYSTEM-LEARNING-LOCAL-001", "CONST-PROOF-EVIDENCE-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-GOAL", "OBJECT-PROOF", "OBJECT-RECEIPT", "SURFACE-YOU", "SYSTEM-PRIVACY-DATA-CLASSIFICATION"]
source_owners = ["Native/Ambitions/Core/Domain/Capability/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/You/", "Native/Ambitions/Surfaces/Goals/", "Native/Ambitions/Quality/"]
+++

# Capability

## OBJ-CAPABILITY-IDENTITY-001 — User-owned Life Capital meaning

- **Concept:** `object.capability.identity-continuity`
- **Modality:** `MUST`
- **Scope:** Capability identity, evidence facets, lifecycle, future-use permission, and claim ceiling
- **Status:** `normative`
- **Verification:** `SCENARIO-CAPABILITY-CONTINUITY-001`
- **Supersedes:** none

A Capability MUST be a durable, user-owned, private Life Capital record for a reusable ability, body of knowledge, or useful method. Experience is evidence or context for a Capability, never the Capability itself. A record becomes user-owned through manual creation or confirmation of a proposal; it remains distinct from every Goal, Step, Proof, Receipt, credential, public taxonomy, requirement, recommendation, and eligibility decision.

<!-- canon-section: stable-identity -->
Capability identity survives source completion, ending, archive, Trash, restore, evidence availability changes, and later destination changes. Stable Capability and evidence-relationship identifiers preserve lineage without using a source-object identifier as Capability identity.

<!-- canon-section: user-meaning -->
The user can name and explain a Capability in plain language, with optional relevant context. A manual user-stated Capability remains valid without completion, Proof, credential, or system confirmation.

<!-- canon-section: relationships -->
Capability may link independent typed evidence relationships to accepted practice observations or user-approved Proof. User-stated, practiced, and Proof-linked facets may coexist and are explanations, not an ordered ladder. A Receipt attests a mutation and MUST NOT become practice evidence by itself.

<!-- canon-section: lifecycle -->
Lifecycle is active, archived, Trashed, restored to the prior valid state, or permanently deleted with a content-free tombstone. Source lifecycle affects evidence relationship availability, contradiction, or redaction; it never automatically deletes the Capability.

<!-- canon-section: valid-transitions -->
Valid transitions include manual create, proposal confirmation, explicit correction, user-reviewed evidence attach/detach, future-use permission change, archive, Trash, restore, and permanent deletion after consequence review. Evidence from a later Goal may accumulate only after the user chooses existing, separate, or new Capability treatment.

<!-- canon-section: invalid-transitions -->
Invalid transitions include automatic inference from a Receipt alone, silent label merge, a source lifecycle mutation changing a Capability's meaning, automatic decay, score/rank/level/XP assignment, credential acceptance, recommendation fit, external eligibility judgment, or a Capability action mutating a Goal, Proof, schedule, or destination.

<!-- canon-section: commands -->
Capability commands use `Command → Event → Projection → Receipt → Replay` under the Capability owner. Source owners remain read-only to those commands; cross-owner lifecycle reconciliation uses a causally linked idempotent transaction and exposes pending state truthfully.

<!-- canon-section: recurrence-scheduling -->
Capabilities neither recur nor consume capacity. They own no schedule placement, due date, alert, or time-quality mutation.

<!-- canon-section: deletion-trash-restore-archive -->
Archive, Trash, restore, evidence detach, redaction, and permanent deletion are distinct. Permanent deletion removes Capability content, interpretation, relationships, and future influence while retaining only the governed content-free tombstone required for deterministic integrity; it does not delete the source Goal, Proof, Receipt, or History Event.

<!-- canon-section: history-receipts -->
Every durable Capability action records truthful changed state, relationship consequences, future-use consequence, recovery availability, and redacted summary. Source-object history remains owned by its source object.

<!-- canon-section: privacy-sync-classification -->
Capability names, meanings, proposals, evidence links, and corrections are private local graph data. They MUST NOT enter Account, R2, Source Atlas, hosted AI, telemetry, support payloads, or external projections. Protected or unknown classification locks future use and a sensitive inferred output remains quiet.

<!-- canon-section: import-export -->
This object has no import or export authority. A later explicit import/export contract must retain distinct source and user consent semantics and cannot manufacture an issuer-credentialed facet.

<!-- canon-section: projection-surfaces -->
You owns the Life Capital collection and Goals may host calm proposal review; neither becomes a root Capability destination nor a mutation owner. Projections show identity and meaning before provenance, uncertainty, future-use state, lifecycle, and actions.

<!-- canon-section: accessibility -->
Semantics expose name, meaning, independent facets, evidence source/type/date/availability, privacy, future-use state, lifecycle, and consequence actions without color, rank, graph, or gesture-only meaning. Named controls support VoiceOver, Voice Control, Switch Control, keyboard, Dynamic Type, reduced effects, and focus recovery.

<!-- canon-section: source-test-ownership -->
`Core/Domain/Capability/` owns stable value contracts and claim ceilings; LocalRuntimeOS owns proposal, command, persistence, reconciliation, replay, and inspection behavior; You and Goals present projections; Quality proves non-exclusive facets, Proof/Receipt separation, no scores, local-only privacy, lifecycle, correction, replay, and accessibility. Tests bind every relationship to stable Capability and source identifiers.
