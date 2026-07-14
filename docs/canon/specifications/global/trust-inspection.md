+++
spec_id = "GLOBAL-TRUST-INSPECTION"
title = "Trust Inspection"
kind = "global"
status = "normative"
owner_domain = "global-trust-inspection"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "global.completed.contextual-placement",
  "global.trust.command-contract",
  "global.trust.identity",
  "global.trust.layers",
  "global.trust.proportional-receipts",
  "global.trust.visual-authority",
]
inherits = [
  "LAW-IA-TRUST-001",
  "PRIVACY-VISIBILITY-001",
  "OBJECT-PROOF-REQUIREMENT-001",
  "CONST-PROOF-EVIDENCE-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION"]
source_owners = [
  "Native/Ambitions/Trust/",
  "Native/Ambitions/Core/LocalRuntimeOS/Inspection/",
  "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/",
  "Native/Ambitions/Language/",
  "Native/Ambitions/Quality/",
]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-CORRECTING"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Correct => destination: the object/fact-specific correction review. The handoff starts from Deep Trust inspection explicit state contract / Correcting; effect: No durable mutation occurs and no Receipt is created; before, current, and proposed values, provenance, affected projections, and rollback are shown; inspection does not change the fact; Deep Trust inspection explicit state contract / Correcting reports the outcome from this visible condition: A proposed correction is being applied while the prior claim remains preserved in history; focus: the first proposed correction field within Deep Trust inspection explicit state contract / Correcting.\nSave correction => destination: the corrected object status and correction Receipt. The handoff starts from Deep Trust inspection explicit state contract / Correcting; effect: The typed canonical-owner correction command appends an Event, updates the Projection, and creates a Receipt and History; the authoritative owner appends the typed correction without rewriting prior facts, then updates affected projections and History; Deep Trust inspection explicit state contract / Correcting reports the outcome from this visible condition: A proposed correction is being applied while the prior claim remains preserved in history; focus: the resulting corrected status and Receipt within Deep Trust inspection explicit state contract / Correcting."
durable_effect = "Exact command consequences: Correct: No durable mutation occurs and no Receipt is created; before, current, and proposed values, provenance, affected projections, and rollback are shown; inspection does not change the fact | Save correction: The typed canonical-owner correction command appends an Event, updates the Projection, and creates a Receipt and History; the authoritative owner appends the typed correction without rewriting prior facts, then updates affected projections and History. The durable boundary is specific to this visible evidence: A proposed correction is being applied while the prior claim remains preserved in history."
recovery_rollback = "Exact rollback and recovery: Correct: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Save correction: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: A proposed correction is being applied while the prior claim remains preserved in history."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: A proposed correction is being applied while the prior claim remains preserved in history."
accessibility_focus = "VoiceOver focus contract: Correct announces its consequence, then success focuses the first proposed correction field; rejection focuses the Correct control and unsupported-owner explanation | Save correction announces its consequence, then success focuses the resulting corrected status and Receipt; rejection focuses the invalid correction field or Save correction control. The announcement includes this user-facing evidence before focus moves: A proposed correction is being applied while the prior claim remains preserved in history."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-CORRECTING-001"
label = "Correct"
canonical_owner = "global.trust.command-contract"
preconditions = ["The object/fact identity, canonical owner, provenance, and current revision are available"]
destination = "the object/fact-specific correction review. The handoff starts from Deep Trust inspection explicit state contract / Correcting"
effect = "No durable mutation occurs and no Receipt is created; before, current, and proposed values, provenance, affected projections, and rollback are shown; inspection does not change the fact; Deep Trust inspection explicit state contract / Correcting reports the outcome from this visible condition: A proposed correction is being applied while the prior claim remains preserved in history"
success_focus = "the first proposed correction field within Deep Trust inspection explicit state contract / Correcting"
failure_focus = "the Correct control and unsupported-owner explanation while Deep Trust inspection explicit state contract / Correcting remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-CORRECTING-002"
label = "Save correction"
canonical_owner = "global.trust.command-contract"
preconditions = ["A typed correction owner is known", "Before/current/proposed values and affected projections are reviewed", "The fact revision is current"]
destination = "the corrected object status and correction Receipt. The handoff starts from Deep Trust inspection explicit state contract / Correcting"
effect = "The typed canonical-owner correction command appends an Event, updates the Projection, and creates a Receipt and History; the authoritative owner appends the typed correction without rewriting prior facts, then updates affected projections and History; Deep Trust inspection explicit state contract / Correcting reports the outcome from this visible condition: A proposed correction is being applied while the prior claim remains preserved in history"
success_focus = "the resulting corrected status and Receipt within Deep Trust inspection explicit state contract / Correcting"
failure_focus = "the invalid correction field or Save correction control while Deep Trust inspection explicit state contract / Correcting remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-CORRECTION-COMPLETE"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the initiating object or fact inspection. The handoff starts from Deep Trust inspection explicit state contract / Correction Complete; effect: No durable mutation occurs and no Receipt is created; dismissal preserves the corrected value, correction Receipt, and History without reopening or repeating correction; Deep Trust inspection explicit state contract / Correction Complete reports the outcome from this visible condition: The correction is complete. The earlier value and the reason for the change remain visible in History; focus: the corrected value and correction Receipt within Deep Trust inspection explicit state contract / Correction Complete."
durable_effect = "Exact command consequences: Done: No durable mutation occurs and no Receipt is created; dismissal preserves the corrected value, correction Receipt, and History without reopening or repeating correction. The durable boundary is specific to this visible evidence: The correction is complete. The earlier value and the reason for the change remain visible in History."
recovery_rollback = "Exact rollback and recovery: Done: No Undo is required; failed dismissal leaves the completed correction result visible, and retrying Done cannot reopen or repeat correction. Recovery preserves the interface evidence that says: The correction is complete. The earlier value and the reason for the change remain visible in History."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: The correction is complete. The earlier value and the reason for the change remain visible in History."
accessibility_focus = "VoiceOver focus contract: Done announces that the completed correction result is closing, then success focuses the corrected value and correction Receipt; failure focuses the Done control and completed result. The announcement includes this user-facing evidence before focus moves: The correction is complete. The earlier value and the reason for the change remain visible in History."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-CORRECTION-COMPLETE-DONE-001"
label = "Done"
canonical_owner = "global.trust.command-contract"
preconditions = ["The correction is complete", "The initiating object or fact route and corrected-result focus target remain available"]
destination = "the initiating object or fact inspection. The handoff starts from Deep Trust inspection explicit state contract / Correction Complete"
effect = "No durable mutation occurs and no Receipt is created; dismissal preserves the corrected value, correction Receipt, and History without reopening or repeating correction; Deep Trust inspection explicit state contract / Correction Complete reports the outcome from this visible condition: The correction is complete. The earlier value and the reason for the change remain visible in History"
success_focus = "the corrected value and correction Receipt within Deep Trust inspection explicit state contract / Correction Complete"
failure_focus = "the Done control and completed correction result while Deep Trust inspection explicit state contract / Correction Complete remains visible"
commit_boundary = "Non-mutating: dismissal returns from the completed correction result and makes no canonical commit."
rollback_undo = "No Undo is required; failed dismissal leaves the completed correction result visible, and retrying Done cannot reopen or repeat correction."
privacy_egress = "Dismissal reads only local correction-result metadata and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-CORRECTION-REQUIRED"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the initiating object or fact inspection. The handoff starts from Deep Trust inspection explicit state contract / Correction Required; effect: No durable mutation occurs and no Receipt is created; dismissal preserves the conflicting claim, evidence, provenance, and History without exposing or committing correction; Deep Trust inspection explicit state contract / Correction Required reports the outcome from this visible condition: The conflicting trust claim and evidence remain visible without correction controls; focus: the conflicting claim and evidence within Deep Trust inspection explicit state contract / Correction Required."
durable_effect = "Exact command consequences: Done: No durable mutation occurs and no Receipt is created; dismissal preserves the conflicting claim, evidence, provenance, and History without exposing or committing correction. The durable boundary is specific to this visible evidence: The conflicting trust claim and evidence remain visible without correction controls."
recovery_rollback = "Exact rollback and recovery: Done: No Undo is required; failed dismissal leaves the conflict evidence visible, and retrying Done cannot expose controls or commit correction. Recovery preserves the interface evidence that says: The conflicting trust claim and evidence remain visible without correction controls."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: The conflicting trust claim and evidence remain visible without correction controls."
accessibility_focus = "VoiceOver focus contract: Done announces that the non-actionable conflict evidence is closing, then success focuses the conflicting claim and evidence; failure focuses the Done control and conflict evidence. The announcement includes this user-facing evidence before focus moves: The conflicting trust claim and evidence remain visible without correction controls."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-CORRECTION-REQUIRED-DONE-001"
label = "Done"
canonical_owner = "global.trust.command-contract"
preconditions = ["The conflict evidence is visible without correction controls", "The initiating object or fact route and conflict-evidence focus target remain available"]
destination = "the initiating object or fact inspection. The handoff starts from Deep Trust inspection explicit state contract / Correction Required"
effect = "No durable mutation occurs and no Receipt is created; dismissal preserves the conflicting claim, evidence, provenance, and History without exposing or committing correction; Deep Trust inspection explicit state contract / Correction Required reports the outcome from this visible condition: The conflicting trust claim and evidence remain visible without correction controls"
success_focus = "the conflicting claim and evidence within Deep Trust inspection explicit state contract / Correction Required"
failure_focus = "the Done control and conflict evidence while Deep Trust inspection explicit state contract / Correction Required remains visible"
commit_boundary = "Non-mutating: dismissal returns from the non-actionable conflict evidence and makes no canonical commit."
rollback_undo = "No Undo is required; failed dismissal leaves the conflict evidence visible, and retrying Done cannot expose controls or commit correction."
privacy_egress = "Dismissal reads only local claim, evidence, provenance, and History metadata and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-HISTORY-EMPTY"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "History => destination: object-scoped History in contextual inspection, or the Trust-owned archive from You. The handoff starts from Deep Trust inspection explicit state contract / History Empty; effect: No durable mutation occurs and no Receipt is created; stable History entries and redacted values are read or paged without changing the object, History, or filter; Deep Trust inspection explicit state contract / History Empty reports the outcome from this visible condition: No recorded history exists for this subject in the inspected scope; focus: the History heading and selected stable entry within Deep Trust inspection explicit state contract / History Empty."
durable_effect = "Exact command consequences: History: No durable mutation occurs and no Receipt is created; stable History entries and redacted values are read or paged without changing the object, History, or filter. The durable boundary is specific to this visible evidence: No recorded history exists for this subject in the inspected scope."
recovery_rollback = "Exact rollback and recovery: History: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: No recorded history exists for this subject in the inspected scope."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: No recorded history exists for this subject in the inspected scope."
accessibility_focus = "VoiceOver focus contract: History announces its consequence, then success focuses the History heading and selected stable entry; rejection focuses the History control or failed page status. The announcement includes this user-facing evidence before focus moves: No recorded history exists for this subject in the inspected scope."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-HISTORY-EMPTY-001"
label = "History"
canonical_owner = "global.trust.command-contract"
preconditions = ["The object identity or Trust archive filter and ordered stable History IDs are available"]
destination = "object-scoped History in contextual inspection, or the Trust-owned archive from You. The handoff starts from Deep Trust inspection explicit state contract / History Empty"
effect = "No durable mutation occurs and no Receipt is created; stable History entries and redacted values are read or paged without changing the object, History, or filter; Deep Trust inspection explicit state contract / History Empty reports the outcome from this visible condition: No recorded history exists for this subject in the inspected scope"
success_focus = "the History heading and selected stable entry within Deep Trust inspection explicit state contract / History Empty"
failure_focus = "the History control or failed page status while Deep Trust inspection explicit state contract / History Empty remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-HISTORY-PAGINATING"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "History => destination: object-scoped History in contextual inspection, or the Trust-owned archive from You. The handoff starts from Deep Trust inspection explicit state contract / History Paginating; effect: No durable mutation occurs and no Receipt is created; stable History entries and redacted values are read or paged without changing the object, History, or filter; Deep Trust inspection explicit state contract / History Paginating reports the outcome from this visible condition: More History is loading from this device. The entries already shown remain in their recorded order; focus: the History heading and selected stable entry within Deep Trust inspection explicit state contract / History Paginating."
durable_effect = "Exact command consequences: History: No durable mutation occurs and no Receipt is created; stable History entries and redacted values are read or paged without changing the object, History, or filter. The durable boundary is specific to this visible evidence: More History is loading from this device. The entries already shown remain in their recorded order."
recovery_rollback = "Exact rollback and recovery: History: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: More History is loading from this device. The entries already shown remain in their recorded order."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: More History is loading from this device. The entries already shown remain in their recorded order."
accessibility_focus = "VoiceOver focus contract: History announces its consequence, then success focuses the History heading and selected stable entry; rejection focuses the History control or failed page status. The announcement includes this user-facing evidence before focus moves: More History is loading from this device. The entries already shown remain in their recorded order."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-HISTORY-PAGINATING-001"
label = "History"
canonical_owner = "global.trust.command-contract"
preconditions = ["The object identity or Trust archive filter and ordered stable History IDs are available"]
destination = "object-scoped History in contextual inspection, or the Trust-owned archive from You. The handoff starts from Deep Trust inspection explicit state contract / History Paginating"
effect = "No durable mutation occurs and no Receipt is created; stable History entries and redacted values are read or paged without changing the object, History, or filter; Deep Trust inspection explicit state contract / History Paginating reports the outcome from this visible condition: More History is loading from this device. The entries already shown remain in their recorded order"
success_focus = "the History heading and selected stable entry within Deep Trust inspection explicit state contract / History Paginating"
failure_focus = "the History control or failed page status while Deep Trust inspection explicit state contract / History Paginating remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-HISTORY-POPULATED"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "History => destination: object-scoped History in contextual inspection, or the Trust-owned archive from You. The handoff starts from Deep Trust inspection explicit state contract / History Populated; effect: No durable mutation occurs and no Receipt is created; stable History entries and redacted values are read or paged without changing the object, History, or filter; Deep Trust inspection explicit state contract / History Populated reports the outcome from this visible condition: History shows recorded changes in order, with related results and corrections linked; focus: the History heading and selected stable entry within Deep Trust inspection explicit state contract / History Populated."
durable_effect = "Exact command consequences: History: No durable mutation occurs and no Receipt is created; stable History entries and redacted values are read or paged without changing the object, History, or filter. The durable boundary is specific to this visible evidence: History shows recorded changes in order, with related results and corrections linked."
recovery_rollback = "Exact rollback and recovery: History: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: History shows recorded changes in order, with related results and corrections linked."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: History shows recorded changes in order, with related results and corrections linked."
accessibility_focus = "VoiceOver focus contract: History announces its consequence, then success focuses the History heading and selected stable entry; rejection focuses the History control or failed page status. The announcement includes this user-facing evidence before focus moves: History shows recorded changes in order, with related results and corrections linked."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-HISTORY-POPULATED-001"
label = "History"
canonical_owner = "global.trust.command-contract"
preconditions = ["The object identity or Trust archive filter and ordered stable History IDs are available"]
destination = "object-scoped History in contextual inspection, or the Trust-owned archive from You. The handoff starts from Deep Trust inspection explicit state contract / History Populated"
effect = "No durable mutation occurs and no Receipt is created; stable History entries and redacted values are read or paged without changing the object, History, or filter; Deep Trust inspection explicit state contract / History Populated reports the outcome from this visible condition: History shows recorded changes in order, with related results and corrections linked"
success_focus = "the History heading and selected stable entry within Deep Trust inspection explicit state contract / History Populated"
failure_focus = "the History control or failed page status while Deep Trust inspection explicit state contract / History Populated remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-LOCAL-STORE-DEGRADED"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Try again => destination: the same local Inspection record. The handoff starts from Deep Trust inspection explicit state contract / Local Store Degraded; effect: No durable mutation occurs and no Receipt is created; only the failed local read or paging request is retried; neither a product mutation nor a Receipt is created; Deep Trust inspection explicit state contract / Local Store Degraded reports the outcome from this visible condition: Some local trust detail cannot be read safely; available evidence remains scoped and marked; focus: the loaded record or retained summary within Deep Trust inspection explicit state contract / Local Store Degraded."
durable_effect = "Exact command consequences: Try again: No durable mutation occurs and no Receipt is created; only the failed local read or paging request is retried; no product mutation or Receipt is created. The durable boundary is specific to this visible evidence: Some local trust detail cannot be read safely; available evidence remains scoped and marked."
recovery_rollback = "Exact rollback and recovery: Try again: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Some local trust detail cannot be read safely; available evidence remains scoped and marked."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Some local trust detail cannot be read safely; available evidence remains scoped and marked."
accessibility_focus = "VoiceOver focus contract: Try again announces its consequence, then success focuses the loaded record or retained summary; rejection focuses the unavailable record and Try again control. The announcement includes this user-facing evidence before focus moves: Some local trust detail cannot be read safely; available evidence remains scoped and marked."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-LOCAL-STORE-DEGRADED-001"
label = "Try again"
canonical_owner = "global.trust.command-contract"
preconditions = ["The stable Receipt/object ID and local read failure class are retained"]
destination = "the same local Inspection record. The handoff starts from Deep Trust inspection explicit state contract / Local Store Degraded"
effect = "No durable mutation occurs and no Receipt is created; only the failed local read or paging request is retried; neither a product mutation nor a Receipt is created; Deep Trust inspection explicit state contract / Local Store Degraded reports the outcome from this visible condition: Some local trust detail cannot be read safely; available evidence remains scoped and marked"
success_focus = "the loaded record or retained summary within Deep Trust inspection explicit state contract / Local Store Degraded"
failure_focus = "the unavailable record and Try again control while Deep Trust inspection explicit state contract / Local Store Degraded remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-MISSING-PROOF"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Proof => destination: object-scoped Proof inspection or the owning Capture/Proof creation handoff. The handoff starts from Deep Trust inspection explicit state contract / Missing Proof; effect: No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt; Deep Trust inspection explicit state contract / Missing Proof reports the outcome from this visible condition: Required Proof is not present for this claim; the absence is explicit; focus: the Proof heading and requirement status within Deep Trust inspection explicit state contract / Missing Proof."
durable_effect = "Exact command consequences: Proof: No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt. The durable boundary is specific to this visible evidence: Required Proof is not present for this claim; the absence is explicit."
recovery_rollback = "Exact rollback and recovery: Proof: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Required Proof is not present for this claim; the absence is explicit."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Required Proof is not present for this claim; the absence is explicit."
accessibility_focus = "VoiceOver focus contract: Proof announces its consequence, then success focuses the Proof heading and requirement status; rejection focuses the Proof control and missing/failed Proof status. The announcement includes this user-facing evidence before focus moves: Required Proof is not present for this claim; the absence is explicit."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-MISSING-PROOF-001"
label = "Proof"
canonical_owner = "global.trust.command-contract"
preconditions = ["The subject identity and Proof requirement/status are available"]
destination = "object-scoped Proof inspection or the owning Capture/Proof creation handoff. The handoff starts from Deep Trust inspection explicit state contract / Missing Proof"
effect = "No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt; Deep Trust inspection explicit state contract / Missing Proof reports the outcome from this visible condition: Required Proof is not present for this claim; the absence is explicit"
success_focus = "the Proof heading and requirement status within Deep Trust inspection explicit state contract / Missing Proof"
failure_focus = "the Proof control and missing/failed Proof status while Deep Trust inspection explicit state contract / Missing Proof remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-OFFLINE-HEALTHY"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: the smallest object-scoped Trust inspection. The handoff starts from Deep Trust inspection explicit state contract / Offline Healthy; effect: No durable mutation occurs and no Receipt is created; Proof, Source, Privacy, History, Receipt, or correction context is inspected without changing the object or authorizing egress; Deep Trust inspection explicit state contract / Offline Healthy reports the outcome from this visible condition: Local Proof, history, privacy, and receipts remain inspectable without a connection; focus: the Trust category heading and selected record within Deep Trust inspection explicit state contract / Offline Healthy."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; Proof, Source, Privacy, History, Receipt, or correction context is inspected without changing the object or authorizing egress. The durable boundary is specific to this visible evidence: Local Proof, history, privacy, and receipts remain inspectable without a connection."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Local Proof, history, privacy, and receipts remain inspectable without a connection."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Local Proof, history, privacy, and receipts remain inspectable without a connection."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the Trust category heading and selected record; rejection focuses the originating marker or Review control. The announcement includes this user-facing evidence before focus moves: Local Proof, history, privacy, and receipts remain inspectable without a connection."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-OFFLINE-HEALTHY-001"
label = "Review"
canonical_owner = "global.trust.command-contract"
preconditions = ["The Trust marker/object identity and originating focus anchor are available"]
destination = "the smallest object-scoped Trust inspection. The handoff starts from Deep Trust inspection explicit state contract / Offline Healthy"
effect = "No durable mutation occurs and no Receipt is created; Proof, Source, Privacy, History, Receipt, or correction context is inspected without changing the object or authorizing egress; Deep Trust inspection explicit state contract / Offline Healthy reports the outcome from this visible condition: Local Proof, history, privacy, and receipts remain inspectable without a connection"
success_focus = "the Trust category heading and selected record within Deep Trust inspection explicit state contract / Offline Healthy"
failure_focus = "the originating marker or Review control while Deep Trust inspection explicit state contract / Offline Healthy remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-PARTIAL-HISTORY"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "History => destination: object-scoped History in contextual inspection, or the Trust-owned archive from You. The handoff starts from Deep Trust inspection explicit state contract / Partial History; effect: No durable mutation occurs and no Receipt is created; stable History entries and redacted values are read or paged without changing the object, History, or filter; Deep Trust inspection explicit state contract / Partial History reports the outcome from this visible condition: Only part of the history is available; the visible sequence is marked incomplete; focus: the History heading and selected stable entry within Deep Trust inspection explicit state contract / Partial History."
durable_effect = "Exact command consequences: History: No durable mutation occurs and no Receipt is created; stable History entries and redacted values are read or paged without changing the object, History, or filter. The durable boundary is specific to this visible evidence: Only part of the history is available; the visible sequence is marked incomplete."
recovery_rollback = "Exact rollback and recovery: History: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Only part of the history is available; the visible sequence is marked incomplete."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Only part of the history is available; the visible sequence is marked incomplete."
accessibility_focus = "VoiceOver focus contract: History announces its consequence, then success focuses the History heading and selected stable entry; rejection focuses the History control or failed page status. The announcement includes this user-facing evidence before focus moves: Only part of the history is available; the visible sequence is marked incomplete."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-PARTIAL-HISTORY-001"
label = "History"
canonical_owner = "global.trust.command-contract"
preconditions = ["The object identity or Trust archive filter and ordered stable History IDs are available"]
destination = "object-scoped History in contextual inspection, or the Trust-owned archive from You. The handoff starts from Deep Trust inspection explicit state contract / Partial History"
effect = "No durable mutation occurs and no Receipt is created; stable History entries and redacted values are read or paged without changing the object, History, or filter; Deep Trust inspection explicit state contract / Partial History reports the outcome from this visible condition: Only part of the history is available; the visible sequence is marked incomplete"
success_focus = "the History heading and selected stable entry within Deep Trust inspection explicit state contract / Partial History"
failure_focus = "the History control or failed page status while Deep Trust inspection explicit state contract / Partial History remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-PERMISSION-DENIED"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: the smallest object-scoped Trust inspection. The handoff starts from Deep Trust inspection explicit state contract / Permission Denied; effect: No durable mutation occurs and no Receipt is created; Proof, Source, Privacy, History, Receipt, or correction context is inspected without changing the object or authorizing egress; Deep Trust inspection explicit state contract / Permission Denied reports the outcome from this visible condition: Protected trust detail cannot be shown with the current access; the safe summary remains; focus: the Trust category heading and selected record within Deep Trust inspection explicit state contract / Permission Denied."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; Proof, Source, Privacy, History, Receipt, or correction context is inspected without changing the object or authorizing egress. The durable boundary is specific to this visible evidence: Protected trust detail cannot be shown with the current access; the safe summary remains."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Protected trust detail cannot be shown with the current access; the safe summary remains."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Protected trust detail cannot be shown with the current access; the safe summary remains."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the Trust category heading and selected record; rejection focuses the originating marker or Review control. The announcement includes this user-facing evidence before focus moves: Protected trust detail cannot be shown with the current access; the safe summary remains."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-PERMISSION-DENIED-001"
label = "Review"
canonical_owner = "global.trust.command-contract"
preconditions = ["The Trust marker/object identity and originating focus anchor are available"]
destination = "the smallest object-scoped Trust inspection. The handoff starts from Deep Trust inspection explicit state contract / Permission Denied"
effect = "No durable mutation occurs and no Receipt is created; Proof, Source, Privacy, History, Receipt, or correction context is inspected without changing the object or authorizing egress; Deep Trust inspection explicit state contract / Permission Denied reports the outcome from this visible condition: Protected trust detail cannot be shown with the current access; the safe summary remains"
success_focus = "the Trust category heading and selected record within Deep Trust inspection explicit state contract / Permission Denied"
failure_focus = "the originating marker or Review control while Deep Trust inspection explicit state contract / Permission Denied remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-PRIVACY-BOUNDARY-REVIEW"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review privacy => destination: the object-scoped privacy boundary review. The handoff starts from Deep Trust inspection explicit state contract / Privacy Boundary Review; effect: No durable mutation occurs and no Receipt is created; privacy consequences are inspected; dismiss or deny causes no egress, and viewing Trust never grants transfer authorization; Deep Trust inspection explicit state contract / Privacy Boundary Review reports the outcome from this visible condition: The fields proposed for disclosure and the fields kept private are visible without disclosure controls; focus: the classification and first redacted/visible field within Deep Trust inspection explicit state contract / Privacy Boundary Review."
durable_effect = "Exact command consequences: Review privacy: No durable mutation occurs and no Receipt is created; privacy consequences are inspected; dismiss or deny causes no egress, and viewing Trust never grants transfer authorization. The durable boundary is specific to this visible evidence: The fields proposed for disclosure and the fields kept private are visible without disclosure controls."
recovery_rollback = "Exact rollback and recovery: Review privacy: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The fields proposed for disclosure and the fields kept private are visible without disclosure controls."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: The fields proposed for disclosure and the fields kept private are visible without disclosure controls."
accessibility_focus = "VoiceOver focus contract: Review privacy announces its consequence, then success focuses the classification and first redacted/visible field; rejection focuses the Review privacy control and denial consequence. The announcement includes this user-facing evidence before focus moves: The fields proposed for disclosure and the fields kept private are visible without disclosure controls."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-PRIVACY-BOUNDARY-REVIEW-001"
label = "Review privacy"
canonical_owner = "global.trust.command-contract"
preconditions = ["Classification, visible/hidden fields, purpose, destination, retention, redactions, and denial effect are available"]
destination = "the object-scoped privacy boundary review. The handoff starts from Deep Trust inspection explicit state contract / Privacy Boundary Review"
effect = "No durable mutation occurs and no Receipt is created; privacy consequences are inspected; dismiss or deny causes no egress, and viewing Trust never grants transfer authorization; Deep Trust inspection explicit state contract / Privacy Boundary Review reports the outcome from this visible condition: The fields proposed for disclosure and the fields kept private are visible without disclosure controls"
success_focus = "the classification and first redacted/visible field within Deep Trust inspection explicit state contract / Privacy Boundary Review"
failure_focus = "the Review privacy control and denial consequence while Deep Trust inspection explicit state contract / Privacy Boundary Review remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "No egress occurs during review; Allow once or persistent policy, if available, remains a separate PrivacySecurity command."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-PRIVACY-PREVIEW"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review privacy => destination: the object-scoped privacy boundary review. The handoff starts from Deep Trust inspection explicit state contract / Privacy Preview; effect: No durable mutation occurs and no Receipt is created; privacy consequences are inspected; dismiss or deny causes no egress, and viewing Trust never grants transfer authorization; Deep Trust inspection explicit state contract / Privacy Preview reports the outcome from this visible condition: The exact fields that would be shown are visible before any disclosure; focus: the classification and first redacted/visible field within Deep Trust inspection explicit state contract / Privacy Preview."
durable_effect = "Exact command consequences: Review privacy: No durable mutation occurs and no Receipt is created; privacy consequences are inspected; dismiss or deny causes no egress, and viewing Trust never grants transfer authorization. The durable boundary is specific to this visible evidence: The exact fields that would be shown are visible before any disclosure."
recovery_rollback = "Exact rollback and recovery: Review privacy: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The exact fields that would be shown are visible before any disclosure."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: The exact fields that would be shown are visible before any disclosure."
accessibility_focus = "VoiceOver focus contract: Review privacy announces its consequence, then success focuses the classification and first redacted/visible field; rejection focuses the Review privacy control and denial consequence. The announcement includes this user-facing evidence before focus moves: The exact fields that would be shown are visible before any disclosure."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-PRIVACY-PREVIEW-001"
label = "Review privacy"
canonical_owner = "global.trust.command-contract"
preconditions = ["Classification, visible/hidden fields, purpose, destination, retention, redactions, and denial effect are available"]
destination = "the object-scoped privacy boundary review. The handoff starts from Deep Trust inspection explicit state contract / Privacy Preview"
effect = "No durable mutation occurs and no Receipt is created; privacy consequences are inspected; dismiss or deny causes no egress, and viewing Trust never grants transfer authorization; Deep Trust inspection explicit state contract / Privacy Preview reports the outcome from this visible condition: The exact fields that would be shown are visible before any disclosure"
success_focus = "the classification and first redacted/visible field within Deep Trust inspection explicit state contract / Privacy Preview"
failure_focus = "the Review privacy control and denial consequence while Deep Trust inspection explicit state contract / Privacy Preview remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "No egress occurs during review; Allow once or persistent policy, if available, remains a separate PrivacySecurity command."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-PRIVACY-REDACTED"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review privacy => destination: the object-scoped privacy boundary review. The handoff starts from Deep Trust inspection explicit state contract / Privacy Redacted; effect: No durable mutation occurs and no Receipt is created; privacy consequences are inspected; dismiss or deny causes no egress, and viewing Trust never grants transfer authorization; Deep Trust inspection explicit state contract / Privacy Redacted reports the outcome from this visible condition: Sensitive fields are redacted in this context; the safe summary does not imply their value; focus: the classification and first redacted/visible field within Deep Trust inspection explicit state contract / Privacy Redacted."
durable_effect = "Exact command consequences: Review privacy: No durable mutation occurs and no Receipt is created; privacy consequences are inspected; dismiss or deny causes no egress, and viewing Trust never grants transfer authorization. The durable boundary is specific to this visible evidence: Sensitive fields are redacted in this context; the safe summary does not imply their value."
recovery_rollback = "Exact rollback and recovery: Review privacy: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Sensitive fields are redacted in this context; the safe summary does not imply their value."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Sensitive fields are redacted in this context; the safe summary does not imply their value."
accessibility_focus = "VoiceOver focus contract: Review privacy announces its consequence, then success focuses the classification and first redacted/visible field; rejection focuses the Review privacy control and denial consequence. The announcement includes this user-facing evidence before focus moves: Sensitive fields are redacted in this context; the safe summary does not imply their value."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-PRIVACY-REDACTED-001"
label = "Review privacy"
canonical_owner = "global.trust.command-contract"
preconditions = ["Classification, visible/hidden fields, purpose, destination, retention, redactions, and denial effect are available"]
destination = "the object-scoped privacy boundary review. The handoff starts from Deep Trust inspection explicit state contract / Privacy Redacted"
effect = "No durable mutation occurs and no Receipt is created; privacy consequences are inspected; dismiss or deny causes no egress, and viewing Trust never grants transfer authorization; Deep Trust inspection explicit state contract / Privacy Redacted reports the outcome from this visible condition: Sensitive fields are redacted in this context; the safe summary does not imply their value"
success_focus = "the classification and first redacted/visible field within Deep Trust inspection explicit state contract / Privacy Redacted"
failure_focus = "the Review privacy control and denial consequence while Deep Trust inspection explicit state contract / Privacy Redacted remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "No egress occurs during review; Allow once or persistent policy, if available, remains a separate PrivacySecurity command."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-PROOF-LOADING"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Proof => destination: object-scoped Proof inspection or the owning Capture/Proof creation handoff. The handoff starts from Deep Trust inspection explicit state contract / Proof Loading; effect: No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt; Deep Trust inspection explicit state contract / Proof Loading reports the outcome from this visible condition: Supporting Proof is being loaded from local information; the inspected claim stays visible; focus: the Proof heading and requirement status within Deep Trust inspection explicit state contract / Proof Loading."
durable_effect = "Exact command consequences: Proof: No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt. The durable boundary is specific to this visible evidence: Supporting Proof is being loaded from local information; the inspected claim stays visible."
recovery_rollback = "Exact rollback and recovery: Proof: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Supporting Proof is being loaded from local information; the inspected claim stays visible."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Supporting Proof is being loaded from local information; the inspected claim stays visible."
accessibility_focus = "VoiceOver focus contract: Proof announces its consequence, then success focuses the Proof heading and requirement status; rejection focuses the Proof control and missing/failed Proof status. The announcement includes this user-facing evidence before focus moves: Supporting Proof is being loaded from local information; the inspected claim stays visible."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-PROOF-LOADING-001"
label = "Proof"
canonical_owner = "global.trust.command-contract"
preconditions = ["The subject identity and Proof requirement/status are available"]
destination = "object-scoped Proof inspection or the owning Capture/Proof creation handoff. The handoff starts from Deep Trust inspection explicit state contract / Proof Loading"
effect = "No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt; Deep Trust inspection explicit state contract / Proof Loading reports the outcome from this visible condition: Supporting Proof is being loaded from local information; the inspected claim stays visible"
success_focus = "the Proof heading and requirement status within Deep Trust inspection explicit state contract / Proof Loading"
failure_focus = "the Proof control and missing/failed Proof status while Deep Trust inspection explicit state contract / Proof Loading remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-RESTORING"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Restore => destination: the owning object or You Data restore review. The handoff starts from Deep Trust inspection explicit state contract / Restoring; effect: No durable mutation occurs and no Receipt is created; Trust hands off stable identity and scope; Trust itself performs no restore mutation and later displays the resulting Receipt/History; Deep Trust inspection explicit state contract / Restoring reports the outcome from this visible condition: Earlier trust details are loading again. The last accepted information and its History links remain visible; focus: the owning restore review heading within Deep Trust inspection explicit state contract / Restoring."
durable_effect = "Exact command consequences: Restore: No durable mutation occurs and no Receipt is created; Trust hands off stable identity and scope; Trust itself performs no restore mutation and later displays the resulting Receipt/History. The durable boundary is specific to this visible evidence: Earlier trust details are loading again. The last accepted information and its History links remain visible."
recovery_rollback = "Exact rollback and recovery: Restore: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Earlier trust details are loading again. The last accepted information and its History links remain visible."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Earlier trust details are loading again. The last accepted information and its History links remain visible."
accessibility_focus = "VoiceOver focus contract: Restore announces its consequence, then success focuses the owning restore review heading; rejection focuses the Restore control and unavailable-owner explanation. The announcement includes this user-facing evidence before focus moves: Earlier trust details are loading again. The last accepted information and its History links remain visible."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-RESTORING-001"
label = "Restore"
canonical_owner = "global.trust.command-contract"
preconditions = ["The inspected object identity, restore scope, canonical owner, and Trust return anchor exist"]
destination = "the owning object or You Data restore review. The handoff starts from Deep Trust inspection explicit state contract / Restoring"
effect = "No durable mutation occurs and no Receipt is created; Trust hands off stable identity and scope; Trust itself performs no restore mutation and later displays the resulting Receipt/History; Deep Trust inspection explicit state contract / Restoring reports the outcome from this visible condition: Earlier trust details are loading again. The last accepted information and its History links remain visible"
success_focus = "the owning restore review heading within Deep Trust inspection explicit state contract / Restoring"
failure_focus = "the Restore control and unavailable-owner explanation while Deep Trust inspection explicit state contract / Restoring remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-SOURCE-CHECKING"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Source => destination: the object-scoped Source Reference inspection. The handoff starts from Deep Trust inspection explicit state contract / Source Checking; effect: No durable mutation occurs and no Receipt is created; provenance and freshness are shown without refreshing the source or adopting a material source change; Deep Trust inspection explicit state contract / Source Checking reports the outcome from this visible condition: Source freshness is being checked before the source is treated as current; focus: the Source heading and freshness status within Deep Trust inspection explicit state contract / Source Checking."
durable_effect = "Exact command consequences: Source: No durable mutation occurs and no Receipt is created; provenance and freshness are shown without refreshing the source or adopting a material source change. The durable boundary is specific to this visible evidence: Source freshness is being checked before the source is treated as current."
recovery_rollback = "Exact rollback and recovery: Source: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Source freshness is being checked before the source is treated as current."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Source freshness is being checked before the source is treated as current."
accessibility_focus = "VoiceOver focus contract: Source announces its consequence, then success focuses the Source heading and freshness status; rejection focuses the Source control or unavailable-source status. The announcement includes this user-facing evidence before focus moves: Source freshness is being checked before the source is treated as current."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-SOURCE-CHECKING-001"
label = "Source"
canonical_owner = "global.trust.command-contract"
preconditions = ["The Source Reference identity, provenance, freshness, and use are available"]
destination = "the object-scoped Source Reference inspection. The handoff starts from Deep Trust inspection explicit state contract / Source Checking"
effect = "No durable mutation occurs and no Receipt is created; provenance and freshness are shown without refreshing the source or adopting a material source change; Deep Trust inspection explicit state contract / Source Checking reports the outcome from this visible condition: Source freshness is being checked before the source is treated as current"
success_focus = "the Source heading and freshness status within Deep Trust inspection explicit state contract / Source Checking"
failure_focus = "the Source control or unavailable-source status while Deep Trust inspection explicit state contract / Source Checking remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-SOURCE-CURRENT"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Source => destination: the object-scoped Source Reference inspection. The handoff starts from Deep Trust inspection explicit state contract / Source Current; effect: No durable mutation occurs and no Receipt is created; provenance and freshness are shown without refreshing the source or adopting a material source change; Deep Trust inspection explicit state contract / Source Current reports the outcome from this visible condition: This source was checked within its stated freshness period, so its information is current; focus: the Source heading and freshness status within Deep Trust inspection explicit state contract / Source Current."
durable_effect = "Exact command consequences: Source: No durable mutation occurs and no Receipt is created; provenance and freshness are shown without refreshing the source or adopting a material source change. The durable boundary is specific to this visible evidence: This source was checked within its stated freshness period, so its information is current."
recovery_rollback = "Exact rollback and recovery: Source: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This source was checked within its stated freshness period, so its information is current."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: This source was checked within its stated freshness period, so its information is current."
accessibility_focus = "VoiceOver focus contract: Source announces its consequence, then success focuses the Source heading and freshness status; rejection focuses the Source control or unavailable-source status. The announcement includes this user-facing evidence before focus moves: This source was checked within its stated freshness period, so its information is current."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-SOURCE-CURRENT-001"
label = "Source"
canonical_owner = "global.trust.command-contract"
preconditions = ["The Source Reference identity, provenance, freshness, and use are available"]
destination = "the object-scoped Source Reference inspection. The handoff starts from Deep Trust inspection explicit state contract / Source Current"
effect = "No durable mutation occurs and no Receipt is created; provenance and freshness are shown without refreshing the source or adopting a material source change; Deep Trust inspection explicit state contract / Source Current reports the outcome from this visible condition: This source was checked within its stated freshness period, so its information is current"
success_focus = "the Source heading and freshness status within Deep Trust inspection explicit state contract / Source Current"
failure_focus = "the Source control or unavailable-source status while Deep Trust inspection explicit state contract / Source Current remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-SOURCE-STALE"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Source => destination: the object-scoped Source Reference inspection. The handoff starts from Deep Trust inspection explicit state contract / Source Stale; effect: No durable mutation occurs and no Receipt is created; provenance and freshness are shown without refreshing the source or adopting a material source change; Deep Trust inspection explicit state contract / Source Stale reports the outcome from this visible condition: This Source is out of date. Its last checked information remains visible; focus: the Source heading and freshness status within Deep Trust inspection explicit state contract / Source Stale."
durable_effect = "Exact command consequences: Source: No durable mutation occurs and no Receipt is created; provenance and freshness are shown without refreshing the source or adopting a material source change. The durable boundary is specific to this visible evidence: This Source is out of date. Its last checked information remains visible."
recovery_rollback = "Exact rollback and recovery: Source: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Source is out of date. Its last checked information remains visible."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: This Source is out of date. Its last checked information remains visible."
accessibility_focus = "VoiceOver focus contract: Source announces its consequence, then success focuses the Source heading and freshness status; rejection focuses the Source control or unavailable-source status. The announcement includes this user-facing evidence before focus moves: This Source is out of date. Its last checked information remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-SOURCE-STALE-001"
label = "Source"
canonical_owner = "global.trust.command-contract"
preconditions = ["The Source Reference identity, provenance, freshness, and use are available"]
destination = "the object-scoped Source Reference inspection. The handoff starts from Deep Trust inspection explicit state contract / Source Stale"
effect = "No durable mutation occurs and no Receipt is created; provenance and freshness are shown without refreshing the source or adopting a material source change; Deep Trust inspection explicit state contract / Source Stale reports the outcome from this visible condition: This Source is out of date. Its last checked information remains visible"
success_focus = "the Source heading and freshness status within Deep Trust inspection explicit state contract / Source Stale"
failure_focus = "the Source control or unavailable-source status while Deep Trust inspection explicit state contract / Source Stale remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-DEEP-SOURCE-UNAVAILABLE"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Source => destination: the object-scoped Source Reference inspection. The handoff starts from Deep Trust inspection explicit state contract / Source Unavailable; effect: No durable mutation occurs and no Receipt is created; provenance and freshness are shown without refreshing the source or adopting a material source change; Deep Trust inspection explicit state contract / Source Unavailable reports the outcome from this visible condition: Source is unavailable. Only the displayed local evidence may inform the current decision; focus: the Source heading and freshness status within Deep Trust inspection explicit state contract / Source Unavailable."
durable_effect = "Exact command consequences: Source: No durable mutation occurs and no Receipt is created; provenance and freshness are shown without refreshing the source or adopting a material source change. The durable boundary is specific to this visible evidence: Source is unavailable. Only the displayed local evidence may inform the current decision."
recovery_rollback = "Exact rollback and recovery: Source: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Source is unavailable. Only the displayed local evidence may inform the current decision."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Source is unavailable. Only the displayed local evidence may inform the current decision."
accessibility_focus = "VoiceOver focus contract: Source announces its consequence, then success focuses the Source heading and freshness status; rejection focuses the Source control or unavailable-source status. The announcement includes this user-facing evidence before focus moves: Source is unavailable. Only the displayed local evidence may inform the current decision."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-DEEP-SOURCE-UNAVAILABLE-001"
label = "Source"
canonical_owner = "global.trust.command-contract"
preconditions = ["The Source Reference identity, provenance, freshness, and use are available"]
destination = "the object-scoped Source Reference inspection. The handoff starts from Deep Trust inspection explicit state contract / Source Unavailable"
effect = "No durable mutation occurs and no Receipt is created; provenance and freshness are shown without refreshing the source or adopting a material source change; Deep Trust inspection explicit state contract / Source Unavailable reports the outcome from this visible condition: Source is unavailable. Only the displayed local evidence may inform the current decision"
success_focus = "the Source heading and freshness status within Deep Trust inspection explicit state contract / Source Unavailable"
failure_focus = "the Source control or unavailable-source status while Deep Trust inspection explicit state contract / Source Unavailable remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-INLINE-MARKER-PRESENT"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: the smallest object-scoped Trust inspection. The handoff starts from Inline and compact Trust explicit state contract / Marker Present; effect: No durable mutation occurs and no Receipt is created; Proof, Source, Privacy, History, Receipt, or correction context is inspected without changing the object or authorizing egress; Inline and compact Trust explicit state contract / Marker Present reports the outcome from this visible condition: Trust detail is available for this object; focus: the Trust category heading and selected record within Inline and compact Trust explicit state contract / Marker Present."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; Proof, Source, Privacy, History, Receipt, or correction context is inspected without changing the object or authorizing egress. The durable boundary is specific to this visible evidence: Trust detail is available for this object."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Trust detail is available for this object."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Trust detail is available for this object."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the Trust category heading and selected record; rejection focuses the originating marker or Review control. The announcement includes this user-facing evidence before focus moves: Trust detail is available for this object."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-INLINE-MARKER-PRESENT-001"
label = "Review"
canonical_owner = "global.trust.command-contract"
preconditions = ["The Trust marker/object identity and originating focus anchor are available"]
destination = "the smallest object-scoped Trust inspection. The handoff starts from Inline and compact Trust explicit state contract / Marker Present"
effect = "No durable mutation occurs and no Receipt is created; Proof, Source, Privacy, History, Receipt, or correction context is inspected without changing the object or authorizing egress; Inline and compact Trust explicit state contract / Marker Present reports the outcome from this visible condition: Trust detail is available for this object"
success_focus = "the Trust category heading and selected record within Inline and compact Trust explicit state contract / Marker Present"
failure_focus = "the originating marker or Review control while Inline and compact Trust explicit state contract / Marker Present remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-INLINE-NO-DISCLOSURE"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "No command or transition is exposed."
durable_effect = "No command is exposed; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: ."
recovery_rollback = "No rollback or Undo is exposed; the originating object and focus remain unchanged. Recovery preserves or restores the interface evidence that says: ."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: ."
accessibility_focus = "VoiceOver exposes no Trust disclosure action and leaves focus on the originating object. The announcement includes this user-facing evidence before focus moves: ."
commands = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-INLINE-PROOF-OPTIONAL"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Proof => destination: object-scoped Proof inspection or the owning Capture/Proof creation handoff. The handoff starts from Inline and compact Trust explicit state contract / Proof Optional; effect: No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt; Inline and compact Trust explicit state contract / Proof Optional reports the outcome from this visible condition: Proof is optional for this change; adding it can improve inspection but is not required for closure; focus: the Proof heading and requirement status within Inline and compact Trust explicit state contract / Proof Optional."
durable_effect = "Exact command consequences: Proof: No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt. The durable boundary is specific to this visible evidence: Proof is optional for this change; adding it can improve inspection but is not required for closure."
recovery_rollback = "Exact rollback and recovery: Proof: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Proof is optional for this change; adding it can improve inspection but is not required for closure."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Proof is optional for this change; adding it can improve inspection but is not required for closure."
accessibility_focus = "VoiceOver focus contract: Proof announces its consequence, then success focuses the Proof heading and requirement status; rejection focuses the Proof control and missing/failed Proof status. The announcement includes this user-facing evidence before focus moves: Proof is optional for this change; adding it can improve inspection but is not required for closure."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-INLINE-PROOF-OPTIONAL-001"
label = "Proof"
canonical_owner = "global.trust.command-contract"
preconditions = ["The subject identity and Proof requirement/status are available"]
destination = "object-scoped Proof inspection or the owning Capture/Proof creation handoff. The handoff starts from Inline and compact Trust explicit state contract / Proof Optional"
effect = "No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt; Inline and compact Trust explicit state contract / Proof Optional reports the outcome from this visible condition: Proof is optional for this change; adding it can improve inspection but is not required for closure"
success_focus = "the Proof heading and requirement status within Inline and compact Trust explicit state contract / Proof Optional"
failure_focus = "the Proof control and missing/failed Proof status while Inline and compact Trust explicit state contract / Proof Optional remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-INLINE-PROOF-REQUIRED"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Proof => destination: object-scoped Proof inspection or the owning Capture/Proof creation handoff. The handoff starts from Inline and compact Trust explicit state contract / Proof Required; effect: No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt; Inline and compact Trust explicit state contract / Proof Required reports the outcome from this visible condition: Proof is required before this closure is saved; focus: the Proof heading and requirement status within Inline and compact Trust explicit state contract / Proof Required."
durable_effect = "Exact command consequences: Proof: No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt. The durable boundary is specific to this visible evidence: Proof is required before this closure is saved."
recovery_rollback = "Exact rollback and recovery: Proof: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Proof is required before this closure is saved."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Proof is required before this closure is saved."
accessibility_focus = "VoiceOver focus contract: Proof announces its consequence, then success focuses the Proof heading and requirement status; rejection focuses the Proof control and missing/failed Proof status. The announcement includes this user-facing evidence before focus moves: Proof is required before this closure is saved."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-INLINE-PROOF-REQUIRED-001"
label = "Proof"
canonical_owner = "global.trust.command-contract"
preconditions = ["The subject identity and Proof requirement/status are available"]
destination = "object-scoped Proof inspection or the owning Capture/Proof creation handoff. The handoff starts from Inline and compact Trust explicit state contract / Proof Required"
effect = "No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt; Inline and compact Trust explicit state contract / Proof Required reports the outcome from this visible condition: Proof is required before this closure is saved"
success_focus = "the Proof heading and requirement status within Inline and compact Trust explicit state contract / Proof Required"
failure_focus = "the Proof control and missing/failed Proof status while Inline and compact Trust explicit state contract / Proof Required remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-INLINE-PROOF-SATISFIED"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Proof => destination: object-scoped Proof inspection or the owning Capture/Proof creation handoff. The handoff starts from Inline and compact Trust explicit state contract / Proof Satisfied; effect: No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt; Inline and compact Trust explicit state contract / Proof Satisfied reports the outcome from this visible condition: Required Proof is attached to this change; focus: the Proof heading and requirement status within Inline and compact Trust explicit state contract / Proof Satisfied."
durable_effect = "Exact command consequences: Proof: No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt. The durable boundary is specific to this visible evidence: Required Proof is attached to this change."
recovery_rollback = "Exact rollback and recovery: Proof: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Required Proof is attached to this change."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Required Proof is attached to this change."
accessibility_focus = "VoiceOver focus contract: Proof announces its consequence, then success focuses the Proof heading and requirement status; rejection focuses the Proof control and missing/failed Proof status. The announcement includes this user-facing evidence before focus moves: Required Proof is attached to this change."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-INLINE-PROOF-SATISFIED-001"
label = "Proof"
canonical_owner = "global.trust.command-contract"
preconditions = ["The subject identity and Proof requirement/status are available"]
destination = "object-scoped Proof inspection or the owning Capture/Proof creation handoff. The handoff starts from Inline and compact Trust explicit state contract / Proof Satisfied"
effect = "No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt; Inline and compact Trust explicit state contract / Proof Satisfied reports the outcome from this visible condition: Required Proof is attached to this change"
success_focus = "the Proof heading and requirement status within Inline and compact Trust explicit state contract / Proof Satisfied"
failure_focus = "the Proof control and missing/failed Proof status while Inline and compact Trust explicit state contract / Proof Satisfied remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-INLINE-PROOF-SUGGESTED"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Proof => destination: object-scoped Proof inspection or the owning Capture/Proof creation handoff. The handoff starts from Inline and compact Trust explicit state contract / Proof Suggested; effect: No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt; Inline and compact Trust explicit state contract / Proof Suggested reports the outcome from this visible condition: Proof is suggested because this change may benefit from later inspection; it remains the user's choice; focus: the Proof heading and requirement status within Inline and compact Trust explicit state contract / Proof Suggested."
durable_effect = "Exact command consequences: Proof: No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt. The durable boundary is specific to this visible evidence: Proof is suggested because this change may benefit from later inspection; it remains the user's choice."
recovery_rollback = "Exact rollback and recovery: Proof: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Proof is suggested because this change may benefit from later inspection; it remains the user's choice."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Proof is suggested because this change may benefit from later inspection; it remains the user's choice."
accessibility_focus = "VoiceOver focus contract: Proof announces its consequence, then success focuses the Proof heading and requirement status; rejection focuses the Proof control and missing/failed Proof status. The announcement includes this user-facing evidence before focus moves: Proof is suggested because this change may benefit from later inspection; it remains the user's choice."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-INLINE-PROOF-SUGGESTED-001"
label = "Proof"
canonical_owner = "global.trust.command-contract"
preconditions = ["The subject identity and Proof requirement/status are available"]
destination = "object-scoped Proof inspection or the owning Capture/Proof creation handoff. The handoff starts from Inline and compact Trust explicit state contract / Proof Suggested"
effect = "No durable mutation occurs and no Receipt is created; existing Proof is inspected or creation context is handed off; adding Proof never auto-completes work or changes a Receipt; Inline and compact Trust explicit state contract / Proof Suggested reports the outcome from this visible condition: Proof is suggested because this change may benefit from later inspection; it remains the user's choice"
success_focus = "the Proof heading and requirement status within Inline and compact Trust explicit state contract / Proof Suggested"
failure_focus = "the Proof control and missing/failed Proof status while Inline and compact Trust explicit state contract / Proof Suggested remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-RECEIPT-ABSENT-RECEIPT-DETAIL"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: local Inspection for the object-scoped Receipt. The handoff starts from Receipt and Undo explicit state contract / Absent Receipt Detail; effect: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence; Receipt and Undo explicit state contract / Absent Receipt Detail reports the outcome from this visible condition: Details for this recorded change are unavailable. The missing information is shown clearly; focus: the Receipt heading and current result status within Receipt and Undo explicit state contract / Absent Receipt Detail."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence. The durable boundary is specific to this visible evidence: Details for this recorded change are unavailable. The missing information is shown clearly."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Details for this recorded change are unavailable. The missing information is shown clearly."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Details for this recorded change are unavailable. The missing information is shown clearly."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the Receipt heading and current result status; rejection focuses the Review control or narrow unavailable status. The announcement includes this user-facing evidence before focus moves: Details for this recorded change are unavailable. The missing information is shown clearly."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-RECEIPT-ABSENT-RECEIPT-DETAIL-001"
label = "Review"
canonical_owner = "global.trust.command-contract"
preconditions = ["The stable Receipt ID and originating object identity are available"]
destination = "local Inspection for the object-scoped Receipt. The handoff starts from Receipt and Undo explicit state contract / Absent Receipt Detail"
effect = "No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence; Receipt and Undo explicit state contract / Absent Receipt Detail reports the outcome from this visible condition: Details for this recorded change are unavailable. The missing information is shown clearly"
success_focus = "the Receipt heading and current result status within Receipt and Undo explicit state contract / Absent Receipt Detail"
failure_focus = "the Review control or narrow unavailable status while Receipt and Undo explicit state contract / Absent Receipt Detail remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-RECEIPT-LOCAL-STORE-DEGRADED"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Try again => destination: the same local Inspection record. The handoff starts from Receipt and Undo explicit state contract / Local Store Degraded; effect: No durable mutation occurs and no Receipt is created; only the failed local read or paging request is retried; neither a product mutation nor a Receipt is created; Receipt and Undo explicit state contract / Local Store Degraded reports the outcome from this visible condition: Some recorded-change details cannot be read safely. The available consequence and item remain visible; focus: the loaded record or retained summary within Receipt and Undo explicit state contract / Local Store Degraded."
durable_effect = "Exact command consequences: Try again: No durable mutation occurs and no Receipt is created; only the failed local read or paging request is retried; no product mutation or Receipt is created. The durable boundary is specific to this visible evidence: Some recorded-change details cannot be read safely. The available consequence and item remain visible."
recovery_rollback = "Exact rollback and recovery: Try again: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Some recorded-change details cannot be read safely. The available consequence and item remain visible."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Some recorded-change details cannot be read safely. The available consequence and item remain visible."
accessibility_focus = "VoiceOver focus contract: Try again announces its consequence, then success focuses the loaded record or retained summary; rejection focuses the unavailable record and Try again control. The announcement includes this user-facing evidence before focus moves: Some recorded-change details cannot be read safely. The available consequence and item remain visible."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-RECEIPT-LOCAL-STORE-DEGRADED-001"
label = "Try again"
canonical_owner = "global.trust.command-contract"
preconditions = ["The stable Receipt/object ID and local read failure class are retained"]
destination = "the same local Inspection record. The handoff starts from Receipt and Undo explicit state contract / Local Store Degraded"
effect = "No durable mutation occurs and no Receipt is created; only the failed local read or paging request is retried; neither a product mutation nor a Receipt is created; Receipt and Undo explicit state contract / Local Store Degraded reports the outcome from this visible condition: Some recorded-change details cannot be read safely. The available consequence and item remain visible"
success_focus = "the loaded record or retained summary within Receipt and Undo explicit state contract / Local Store Degraded"
failure_focus = "the unavailable record and Try again control while Receipt and Undo explicit state contract / Local Store Degraded remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-RECEIPT-OFFLINE-HEALTHY"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: local Inspection for the object-scoped Receipt. The handoff starts from Receipt and Undo explicit state contract / Offline Healthy; effect: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence; Receipt and Undo explicit state contract / Offline Healthy reports the outcome from this visible condition: Local receipts and linked history remain available without a connection; focus: the Receipt heading and current result status within Receipt and Undo explicit state contract / Offline Healthy."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence. The durable boundary is specific to this visible evidence: Local receipts and linked history remain available without a connection."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Local receipts and linked history remain available without a connection."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Local receipts and linked history remain available without a connection."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the Receipt heading and current result status; rejection focuses the Review control or narrow unavailable status. The announcement includes this user-facing evidence before focus moves: Local receipts and linked history remain available without a connection."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-RECEIPT-OFFLINE-HEALTHY-001"
label = "Review"
canonical_owner = "global.trust.command-contract"
preconditions = ["The stable Receipt ID and originating object identity are available"]
destination = "local Inspection for the object-scoped Receipt. The handoff starts from Receipt and Undo explicit state contract / Offline Healthy"
effect = "No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence; Receipt and Undo explicit state contract / Offline Healthy reports the outcome from this visible condition: Local receipts and linked history remain available without a connection"
success_focus = "the Receipt heading and current result status within Receipt and Undo explicit state contract / Offline Healthy"
failure_focus = "the Review control or narrow unavailable status while Receipt and Undo explicit state contract / Offline Healthy remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-RECEIPT-RECEIPT-COMMITTED"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: local Inspection for the object-scoped Receipt. The handoff starts from Receipt inspection explicit state contract / Receipt Committed; effect: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, and reversal eligibility status are read without changing the mutation or evidence; Receipt inspection explicit state contract / Receipt Committed reports the outcome from this visible condition: This change is recorded. Its item and lasting result are available for inspection; focus: the Receipt heading and current result status within Receipt inspection explicit state contract / Receipt Committed."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, and reversal eligibility status are read without changing the mutation or evidence. The durable boundary is specific to this visible evidence: This change is recorded. Its item and lasting result are available for inspection."
recovery_rollback = "Exact rollback and recovery: Review: No rollback control is exposed; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This change is recorded. Its item and lasting result are available for inspection."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and reversal inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: This change is recorded. Its item and lasting result are available for inspection."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the Receipt heading and current result status; rejection focuses the Review control or narrow unavailable status. The announcement includes this user-facing evidence before focus moves: This change is recorded. Its item and lasting result are available for inspection."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-RECEIPT-RECEIPT-COMMITTED-001"
label = "Review"
canonical_owner = "global.trust.command-contract"
preconditions = ["The stable Receipt ID and originating object identity are available"]
destination = "local Inspection for the object-scoped Receipt. The handoff starts from Receipt inspection explicit state contract / Receipt Committed"
effect = "No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, and reversal eligibility status are read without changing the mutation or evidence; Receipt inspection explicit state contract / Receipt Committed reports the outcome from this visible condition: This change is recorded. Its item and lasting result are available for inspection"
success_focus = "the Receipt heading and current result status within Receipt inspection explicit state contract / Receipt Committed"
failure_focus = "the Review control or narrow unavailable status while Receipt and Undo explicit state contract / Receipt Committed remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-RECEIPT-RECEIPT-COMMITTED-UNDO-ELIGIBLE"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Undo => destination: the resulting object status and reversing Receipt. The handoff starts from Receipt and Undo explicit state contract / Receipt Committed Undo Eligible; effect: The typed canonical-owner Undo command appends an Event, updates the Projection, and creates a Receipt and History; a reversing Event changes the object to the supported prior result while preserving the original Receipt and append-only History; Receipt and Undo explicit state contract / Receipt Committed Undo Eligible reports the outcome from this visible condition: This recorded change can be reversed. Its item and result are visible; focus: the resulting status and reversing Receipt within Receipt and Undo explicit state contract / Receipt Committed Undo Eligible."
durable_effect = "Exact command consequences: Undo: The typed canonical-owner Undo command appends an Event, updates the Projection, and creates a Receipt and History; a reversing Event changes the object to the supported prior result while preserving the original Receipt and append-only History. The durable boundary is specific to this visible evidence: This recorded change can be reversed. Its item and result are visible."
recovery_rollback = "Exact rollback and recovery: Undo: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: This recorded change can be reversed. Its item and result are visible."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: This recorded change can be reversed. Its item and result are visible."
accessibility_focus = "VoiceOver focus contract: Undo announces its consequence, then success focuses the resulting status and reversing Receipt; rejection focuses the Undo control and ineligibility reason. The announcement includes this user-facing evidence before focus moves: This recorded change can be reversed. Its item and result are visible."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-RECEIPT-RECEIPT-COMMITTED-UNDO-ELIGIBLE-001"
label = "Undo"
canonical_owner = "global.trust.command-contract"
preconditions = ["The Receipt identifies an eligible reversible command and current object revision", "The exact reversing consequence is reviewed"]
destination = "the resulting object status and reversing Receipt. The handoff starts from Receipt and Undo explicit state contract / Receipt Committed Undo Eligible"
effect = "The typed canonical-owner Undo command appends an Event, updates the Projection, and creates a Receipt and History; a reversing Event changes the object to the supported prior result while preserving the original Receipt and append-only History; Receipt and Undo explicit state contract / Receipt Committed Undo Eligible reports the outcome from this visible condition: This recorded change can be reversed. Its item and result are visible"
success_focus = "the resulting status and reversing Receipt within Receipt and Undo explicit state contract / Receipt Committed Undo Eligible"
failure_focus = "the Undo control and ineligibility reason while Receipt and Undo explicit state contract / Receipt Committed Undo Eligible remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-RECEIPT-RECEIPT-COMMITTED-UNDO-UNAVAILABLE"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Try again => destination: the same local Inspection record. The handoff starts from Receipt and Undo explicit state contract / Receipt Committed Undo Unavailable; effect: No durable mutation occurs and no Receipt is created; only the failed local read or paging request is retried; neither a product mutation nor a Receipt is created; Receipt and Undo explicit state contract / Receipt Committed Undo Unavailable reports the outcome from this visible condition: This recorded change cannot be reversed safely. Its item and reason remain visible; focus: the loaded record or retained summary within Receipt and Undo explicit state contract / Receipt Committed Undo Unavailable."
durable_effect = "Exact command consequences: Try again: No durable mutation occurs and no Receipt is created; only the failed local read or paging request is retried; no product mutation or Receipt is created. The durable boundary is specific to this visible evidence: This recorded change cannot be reversed safely. Its item and reason remain visible."
recovery_rollback = "Exact rollback and recovery: Try again: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This recorded change cannot be reversed safely. Its item and reason remain visible."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: This recorded change cannot be reversed safely. Its item and reason remain visible."
accessibility_focus = "VoiceOver focus contract: Try again announces its consequence, then success focuses the loaded record or retained summary; rejection focuses the unavailable record and Try again control. The announcement includes this user-facing evidence before focus moves: This recorded change cannot be reversed safely. Its item and reason remain visible."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-RECEIPT-RECEIPT-COMMITTED-UNDO-UNAVAILABLE-001"
label = "Try again"
canonical_owner = "global.trust.command-contract"
preconditions = ["The stable Receipt/object ID and local read failure class are retained"]
destination = "the same local Inspection record. The handoff starts from Receipt and Undo explicit state contract / Receipt Committed Undo Unavailable"
effect = "No durable mutation occurs and no Receipt is created; only the failed local read or paging request is retried; neither a product mutation nor a Receipt is created; Receipt and Undo explicit state contract / Receipt Committed Undo Unavailable reports the outcome from this visible condition: This recorded change cannot be reversed safely. Its item and reason remain visible"
success_focus = "the loaded record or retained summary within Receipt and Undo explicit state contract / Receipt Committed Undo Unavailable"
failure_focus = "the unavailable record and Try again control while Receipt and Undo explicit state contract / Receipt Committed Undo Unavailable remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-RECEIPT-RECEIPT-EXTERNAL-FAILED"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Try again => destination: the same Receipt external-result row. The handoff starts from Receipt and Undo explicit state contract / Receipt External Failed; effect: No local canonical mutation is replayed; only the failed external operation is retried after authorization/privacy revalidation; the accepted local Event is never reissued; Receipt and Undo explicit state contract / Receipt External Failed reports the outcome from this visible condition: The Ambitions change is saved, but the related outside update did not finish. Both outcomes remain visible; focus: the retried external result row within Receipt and Undo explicit state contract / Receipt External Failed."
durable_effect = "Exact command consequences: Try again: No local canonical mutation is replayed; only the failed external operation is retried after authorization/privacy revalidation; the accepted local Event is never reissued. The durable boundary is specific to this visible evidence: The Ambitions change is saved, but the related outside update did not finish. Both outcomes remain visible."
recovery_rollback = "Exact rollback and recovery: Try again: Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command. Recovery preserves or restores the interface evidence that says: The Ambitions change is saved, but the related outside update did not finish. Both outcomes remain visible."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: The Ambitions change is saved, but the related outside update did not finish. Both outcomes remain visible."
accessibility_focus = "VoiceOver focus contract: Try again announces its consequence, then success focuses the retried external result row; rejection focuses the failed result and Try again control. The announcement includes this user-facing evidence before focus moves: The Ambitions change is saved, but the related outside update did not finish. Both outcomes remain visible."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-RECEIPT-RECEIPT-EXTERNAL-FAILED-001"
label = "Try again"
canonical_owner = "global.trust.command-contract"
preconditions = ["The existing result/outbox/command identity, current revision, and failure class exist"]
destination = "the same Receipt external-result row. The handoff starts from Receipt and Undo explicit state contract / Receipt External Failed"
effect = "No local canonical mutation is replayed; only the failed external operation is retried after authorization/privacy revalidation; the accepted local Event is never reissued; Receipt and Undo explicit state contract / Receipt External Failed reports the outcome from this visible condition: The Ambitions change is saved, but the related outside update did not finish. Both outcomes remain visible"
success_focus = "the retried external result row within Receipt and Undo explicit state contract / Receipt External Failed"
failure_focus = "the failed result and Try again control while Receipt and Undo explicit state contract / Receipt External Failed remains visible"
commit_boundary = "External-result: the existing durable result or outbox identity is revalidated before only the failed external/read operation runs; the accepted local Event is never replayed."
rollback_undo = "Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command."
privacy_egress = "Only the previously approved minimum payload may leave the device; authorization and SYSTEM-PRIVACY-EGRESS-001 are revalidated and failure remains inspectable."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-RECEIPT-RECEIPT-PENDING"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: local Inspection for the object-scoped Receipt. The handoff starts from Receipt and Undo explicit state contract / Receipt Pending; effect: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence; Receipt and Undo explicit state contract / Receipt Pending reports the outcome from this visible condition: This change is still being recorded. Its result is not shown as complete yet; focus: the Receipt heading and current result status within Receipt and Undo explicit state contract / Receipt Pending."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence. The durable boundary is specific to this visible evidence: This change is still being recorded. Its result is not shown as complete yet."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This change is still being recorded. Its result is not shown as complete yet."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: This change is still being recorded. Its result is not shown as complete yet."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the Receipt heading and current result status; rejection focuses the Review control or narrow unavailable status. The announcement includes this user-facing evidence before focus moves: This change is still being recorded. Its result is not shown as complete yet."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-RECEIPT-RECEIPT-PENDING-001"
label = "Review"
canonical_owner = "global.trust.command-contract"
preconditions = ["The stable Receipt ID and originating object identity are available"]
destination = "local Inspection for the object-scoped Receipt. The handoff starts from Receipt and Undo explicit state contract / Receipt Pending"
effect = "No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence; Receipt and Undo explicit state contract / Receipt Pending reports the outcome from this visible condition: This change is still being recorded. Its result is not shown as complete yet"
success_focus = "the Receipt heading and current result status within Receipt and Undo explicit state contract / Receipt Pending"
failure_focus = "the Review control or narrow unavailable status while Receipt and Undo explicit state contract / Receipt Pending remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-RECEIPT-RECEIPT-RESOLVING"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: local Inspection for the object-scoped Receipt. The handoff starts from Receipt and Undo explicit state contract / Receipt Resolving; effect: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence; Receipt and Undo explicit state contract / Receipt Resolving reports the outcome from this visible condition: This recorded change is still being matched with the item it describes. The saved item remains unchanged; focus: the Receipt heading and current result status within Receipt and Undo explicit state contract / Receipt Resolving."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence. The durable boundary is specific to this visible evidence: This recorded change is still being matched with the item it describes. The saved item remains unchanged."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This recorded change is still being matched with the item it describes. The saved item remains unchanged."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: This recorded change is still being matched with the item it describes. The saved item remains unchanged."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the Receipt heading and current result status; rejection focuses the Review control or narrow unavailable status. The announcement includes this user-facing evidence before focus moves: This recorded change is still being matched with the item it describes. The saved item remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-RECEIPT-RECEIPT-RESOLVING-001"
label = "Review"
canonical_owner = "global.trust.command-contract"
preconditions = ["The stable Receipt ID and originating object identity are available"]
destination = "local Inspection for the object-scoped Receipt. The handoff starts from Receipt and Undo explicit state contract / Receipt Resolving"
effect = "No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence; Receipt and Undo explicit state contract / Receipt Resolving reports the outcome from this visible condition: This recorded change is still being matched with the item it describes. The saved item remains unchanged"
success_focus = "the Receipt heading and current result status within Receipt and Undo explicit state contract / Receipt Resolving"
failure_focus = "the Review control or narrow unavailable status while Receipt and Undo explicit state contract / Receipt Resolving remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-RECEIPT-RECEIPT-UNDONE"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: local Inspection for the object-scoped Receipt. The handoff starts from Receipt and Undo explicit state contract / Receipt Undone; effect: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence; Receipt and Undo explicit state contract / Receipt Undone reports the outcome from this visible condition: The earlier value has been restored. History keeps both the original change and the restoration; focus: the Receipt heading and current result status within Receipt and Undo explicit state contract / Receipt Undone."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence. The durable boundary is specific to this visible evidence: The earlier value has been restored. History keeps both the original change and the restoration."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The earlier value has been restored. History keeps both the original change and the restoration."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: The earlier value has been restored. History keeps both the original change and the restoration."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the Receipt heading and current result status; rejection focuses the Review control or narrow unavailable status. The announcement includes this user-facing evidence before focus moves: The earlier value has been restored. History keeps both the original change and the restoration."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-RECEIPT-RECEIPT-UNDONE-001"
label = "Review"
canonical_owner = "global.trust.command-contract"
preconditions = ["The stable Receipt ID and originating object identity are available"]
destination = "local Inspection for the object-scoped Receipt. The handoff starts from Receipt and Undo explicit state contract / Receipt Undone"
effect = "No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence; Receipt and Undo explicit state contract / Receipt Undone reports the outcome from this visible condition: The earlier value has been restored. History keeps both the original change and the restoration"
success_focus = "the Receipt heading and current result status within Receipt and Undo explicit state contract / Receipt Undone"
failure_focus = "the Review control or narrow unavailable status while Receipt and Undo explicit state contract / Receipt Undone remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-RECEIPT-RESTORING"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Restore => destination: the owning object or You Data restore review. The handoff starts from Receipt and Undo explicit state contract / Restoring; effect: No durable mutation occurs and no Receipt is created; Trust hands off stable identity and scope; Trust itself performs no restore mutation and later displays the resulting Receipt/History; Receipt and Undo explicit state contract / Restoring reports the outcome from this visible condition: Earlier details for this recorded change are loading again. The saved item and History remain unchanged; focus: the owning restore review heading within Receipt and Undo explicit state contract / Restoring."
durable_effect = "Exact command consequences: Restore: No durable mutation occurs and no Receipt is created; Trust hands off stable identity and scope; Trust itself performs no restore mutation and later displays the resulting Receipt/History. The durable boundary is specific to this visible evidence: Earlier details for this recorded change are loading again. The saved item and History remain unchanged."
recovery_rollback = "Exact rollback and recovery: Restore: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Earlier details for this recorded change are loading again. The saved item and History remain unchanged."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Earlier details for this recorded change are loading again. The saved item and History remain unchanged."
accessibility_focus = "VoiceOver focus contract: Restore announces its consequence, then success focuses the owning restore review heading; rejection focuses the Restore control and unavailable-owner explanation. The announcement includes this user-facing evidence before focus moves: Earlier details for this recorded change are loading again. The saved item and History remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-RECEIPT-RESTORING-001"
label = "Restore"
canonical_owner = "global.trust.command-contract"
preconditions = ["The inspected object identity, restore scope, canonical owner, and Trust return anchor exist"]
destination = "the owning object or You Data restore review. The handoff starts from Receipt and Undo explicit state contract / Restoring"
effect = "No durable mutation occurs and no Receipt is created; Trust hands off stable identity and scope; Trust itself performs no restore mutation and later displays the resulting Receipt/History; Receipt and Undo explicit state contract / Restoring reports the outcome from this visible condition: Earlier details for this recorded change are loading again. The saved item and History remain unchanged"
success_focus = "the owning restore review heading within Receipt and Undo explicit state contract / Restoring"
failure_focus = "the Restore control and unavailable-owner explanation while Receipt and Undo explicit state contract / Restoring remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TRUST-RECEIPT-UNDOING"
requirement_id = "SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: local Inspection for the object-scoped Receipt. The handoff starts from Receipt and Undo explicit state contract / Undoing; effect: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence; Receipt and Undo explicit state contract / Undoing reports the outcome from this visible condition: Recovery of an earlier value is in progress. The current value and both History entries remain visible; focus: the Receipt heading and current result status within Receipt and Undo explicit state contract / Undoing."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence. The durable boundary is specific to this visible evidence: Recovery of an earlier value is in progress. The current value and both History entries remain visible."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Recovery of an earlier value is in progress. The current value and both History entries remain visible."
offline_behavior = "Proof, Source, Privacy, History, Receipt, correction, and Undo inspection use local canonical state without an account or network; optional external freshness/results remain separate. Offline rendering retains this state evidence: Recovery of an earlier value is in progress. The current value and both History entries remain visible."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the Receipt heading and current result status; rejection focuses the Review control or narrow unavailable status. The announcement includes this user-facing evidence before focus moves: Recovery of an earlier value is in progress. The current value and both History entries remain visible."

[[state_command_contracts.commands]]
command_id = "CMD-TRUST-RECEIPT-UNDOING-001"
label = "Review"
canonical_owner = "global.trust.command-contract"
preconditions = ["The stable Receipt ID and originating object identity are available"]
destination = "local Inspection for the object-scoped Receipt. The handoff starts from Receipt and Undo explicit state contract / Undoing"
effect = "No durable mutation occurs and no Receipt is created; the proportional Receipt, pending/external result, or undo status is read without changing the mutation or evidence; Receipt and Undo explicit state contract / Undoing reports the outcome from this visible condition: Recovery of an earlier value is in progress. The current value and both History entries remain visible"
success_focus = "the Receipt heading and current result status within Receipt and Undo explicit state contract / Undoing"
failure_focus = "the Review control or narrow unavailable status while Receipt and Undo explicit state contract / Undoing remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001"]
+++

# Trust Inspection

Trust Inspection uses `surface-v1` because it presents contextual compact and deep inspection UI with visible objects, states, accessibility, and visual contracts. It remains non-root and object-subordinate, not persistent chrome or a dashboard.

## SPEC-GLOBAL-TRUST-INSPECTION-001 — Contextual Proof / Source / Privacy / History / Receipts

- **Concept:** `global.trust.identity`
- **Modality:** `MUST`
- **Scope:** Contextual trust presentation
- **Status:** `normative`
- **Verification:** `SCENARIO-TRUST-CONTEXT-001`
- **Supersedes:** none

Trust MUST expose Proof, Source, Privacy, History, Receipts, and relevant rationale in the context of the object or change being inspected. It MUST NOT become a root, global dashboard, analytics feed, permanent badge field, architecture browser, or replacement for the object.

Proof MUST appear in completed Step, Goal detail, Receipt, Search result, and related detail flows when relevant.

Proof-required status MUST be visible before execution.

Required proof SHOULD be shown in Today, Goal detail, Capture proposal, and step detail wherever relevant.

## SPEC-GLOBAL-TRUST-LAYERS-001 — Disclosure expands only as needed

- **Concept:** `global.trust.layers`
- **Modality:** `MUST`
- **Scope:** Inline marker, compact row, deep inspection, and searchable archive
- **Status:** `normative`
- **Verification:** `SCENARIO-TRUST-LAYERS-001`
- **Supersedes:** none

Trust disclosure MUST progress from an inline marker where a fact matters, to a compact detail row, to deep object-specific inspection, with searchable archives reachable through You. Proof requirements appear before execution/completion. Source/privacy details appear at meaningful boundaries. Every claim identifies provenance, freshness/status, affected object/change, and available correction or recovery without overstating evidence.

Source details SHOULD remain inspection-level, not prominent on every recommendation.

Ambitions SHOULD NOT show when a path used external/reference knowledge by default.

Source Atlas SHOULD be invisible by default.

## SPEC-GLOBAL-TRUST-PROPORTIONAL-RECEIPTS-001 — Receipt disclosure matches consequence
- **Concept:** `global.trust.proportional-receipts`
- **Modality:** `MUST`
- **Scope:** Accepted mutations and their immediate confirmation
- **Status:** `normative`
- **Verification:** `SCENARIO-TRUST-PROPORTIONAL-RECEIPT-001`
- **Supersedes:** none

Every accepted mutation MUST create its durable Receipt while disclosure remains proportional: small changes receive lightweight confirmation; meaningful or externally consequential changes expose a Receipt with inspect and Undo where supported; Save for Later uses its specified durable confirmation and exit path.

## SPEC-GLOBAL-TRUST-VISUAL-AUTHORITY-001 — Approved Trust package preserves evidence distinctions

- **Concept:** `global.trust.visual-authority`
- **Modality:** `MUST`
- **Scope:** Markers, rows, and deep inspection visual authority
- **Status:** `normative`
- **Verification:** `PROOF-TRUST-VISUAL-MAPPING-001`
- **Supersedes:** none

Visual references MUST use stable external IDs and distinguish approved direction, successor final package, implementation proof, and the evidence being inspected. `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:250:104` remains direction only; owner-approved VSP-07 successor package `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:257:93` is the contextual Trust target. Neither node proves SwiftUI parity, accessibility, device/runtime behavior, Visual Green, or release status.

## SPEC-GLOBAL-TRUST-COMMAND-CONTRACT-001 — Exact state command ownership

- **Concept:** `global.trust.command-contract`
- **Modality:** `MUST`
- **Scope:** Structured state command contracts for this specification
- **Status:** `normative`
- **Verification:** `SCENARIO-GLOBAL-TRUST-COMMAND-CONTRACT-001`
- **Supersedes:** none

The owning specification MUST authorize only the state-bound command labels `Correct`, `Done`, `History`, `Proof`, `Restore`, `Review`, `Review privacy`, `Save correction`, `Source`, `Try again`, `Undo` for the structured states declared in this file. Every command MUST bind stable state and object identity, current revision, canonical owner, preconditions, destination, exact effect and focus targets; navigation, inspection, selection, preview, refresh, and cancellation remain non-mutating. A durable mutation MUST commit only after current-revision validation and required confirmation through Command -> Event -> Projection -> Receipt -> Replay; cancellation or rejection preserves accepted input, and rollback or Undo uses an owning typed command without rewriting history. Local canonical behavior MUST remain available offline without an account; external results remain separate and retryable without replaying the local commit. Sensitive content MUST remain local unless explicit minimum-field egress review passes. VoiceOver MUST announce object, accepted or rejected outcome, consequence, recovery or Undo availability, and destination focus; no color, motion, gesture, or position may carry command meaning alone. Verification MUST prove every declared state, command, transition, commit boundary, durable effect, rollback, offline, privacy, accessibility, and focus mapping against the structured contract.

## Completeness contract

<!-- canon-section: purpose-user-question -->
Trust answers what changed or is required, why it matters, where the fact came from, what remains private, what evidence exists, and how the user can correct, undo, or recover.

<!-- canon-section: entry-exit -->
Entry comes from a relevant object marker/detail row, Search Inspect result, receipt/history archive, proof requirement, privacy boundary, or source-change notice. Dismissal returns to the originating object/change and restores focus.

<!-- canon-section: routes-presentation -->
Inline markers and compact rows stay subordinate to the object. Deep inspection uses the smallest native presentation that preserves meaning. Searchable archives live under You entry but remain Trust-owned; no presentation becomes root chrome.

<!-- canon-section: displayed-objects -->
Displayed facts include proof level/evidence, receipt mutation summary, prior/current values where safe, source/provenance/freshness, privacy classification/egress, history sequence, rationale, external result, and available correction/undo/recovery.

<!-- canon-section: resting-states -->
The trust-state matrix separates disclosure depth, evidence status, provenance freshness, receipt result, privacy review, and correction state.
Required states include no special disclosure, marker present, proof optional/suggested/required/satisfied, source current/stale/unavailable, receipt pending/committed/external-failed/undone, privacy-boundary review, history empty/populated, and correction required.

<!-- canon-section: loading-transitional -->
Proof load, receipt resolution, history pagination, source freshness check, privacy preview, undo, correction, and restoration retain the last valid local fact and expose bounded progress or stale state rather than blanking the object.

<!-- canon-section: empty-degraded -->
Each degraded fact retains the originating object, known local evidence, narrow uncertainty, and safe repair controls.
Missing proof, unavailable source, stale freshness, absent receipt detail, partial history, offline, permission denial, or local-store degradation is stated narrowly. The originating object remains usable where safe; retry, correct, export, diagnostics, or dismiss is offered without fabricated evidence.

<!-- canon-section: commands-actions -->
Open proof/source/privacy/history/receipt, add proof, inspect change, correct fact, review privacy boundary, retry external result, undo, export, and open diagnostics are explicit object-scoped actions. Inspection itself cannot mutate canonical state.

<!-- canon-section: durable-effects -->
Viewing is non-mutating. Accepted proof, correction, undo, privacy authorization, or retry routes through canonical commands and produces events, projections, receipts, and replay state. History remains append-only and inspectable.

<!-- canon-section: failure-rollback -->
Inspection failure leaves the source object and accepted state intact. Failed correction/undo retains current state and explains scope. Partial external result remains durable and retryable; privacy denial prevents egress and preserves local content.

<!-- canon-section: offline -->
Local inspection covers proof, receipts, history, privacy classification, rationale, correction, undo, and replay.
Local proof, receipts, history, privacy classification, rationale, correction, and replay remain inspectable offline. Optional source freshness may be stale/unavailable but cannot trigger private upload or block local trust facts.

<!-- canon-section: privacy-data-classification -->
Trust often handles the most sensitive private graph facts. Disclosure is minimum-necessary, contextual, redacted in logs/screenshots by default, protected from shoulder/notification leakage, and never sent to Account, R2, Source Atlas, or hosted AI. Export requires preview.

<!-- canon-section: accessibility-reading-order -->
VoiceOver reads object/change identity, trust category, current status, concise explanation, evidence/provenance, consequence, then actions. History is ordered and headed; before/after values are verbalized safely; markers never rely on color/icon alone; dismissal restores origin focus.

<!-- canon-section: dynamic-type -->
Markers expand into labeled rows, comparisons stack vertically, history and proof wrap fully, and no provenance, privacy consequence, status, or action is truncated into ambiguity.

<!-- canon-section: reduce-motion -->
Disclosure expansion, proof attachment, receipt resolution, history changes, and undo use immediate updates or restrained fades while retaining announcements, sequence, and focus.

<!-- canon-section: reduce-transparency -->
Trust materials become opaque semantic surfaces with equivalent category, hierarchy, comparison, warning, and contrast.

<!-- canon-section: copy-state-language -->
Use Proof, Source, Privacy, History, Receipt, Changed by, Used for planning, Still counts, Review, and Undo contextually. Avoid ledger/runtime/model confidence, surveillance language, shame, or proof-strength grading.

<!-- canon-section: visual-authority -->
The named successor package controls geometry, hierarchy, composition, states, and adaptive layout.
Stable IDs `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:250:104` and `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:257:93` preserve direction/successor provenance. Source rendering, evidence correctness, accessibility/device behavior, implementation parity, and release proof remain separate.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Trust/` owns contextual presentation/disclosure policy; `Core/LocalRuntimeOS/Inspection/` owns facts, receipts, proof, undo, and history; `PrivacySecurity/` owns classification/egress; `Language/` owns humane copy; `Quality/` owns proof.

<!-- canon-section: tests -->
The scenario matrix spans disclosure, evidence, source, receipt, privacy, correction, history, replay, accessibility, and focus behavior.
Tests cover every trust layer/category/state, proof-before-completion, source stale/unavailable, receipt external failure/undo, privacy denial, correction, history order/pagination, redaction, offline/replay, Search/You entry, VoiceOver semantics/order/actions, Dynamic Type, reduced effects, contrast, and focus return.

<!-- canon-section: proof -->
Evidence artifacts bind executed scenarios to exact source revisions and environments.
Required proof includes object-scoped receipts/history/proof fixtures, privacy and redaction evidence, failure/recovery logs, screenshot/accessibility matrices, scoped visual approval, exact commands/exits, source revision, known gaps, and rollback. Trust UI cannot self-certify the claims it displays.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Trust detail, proof/receipt/history paging, correction/undo validation, and freshness work MUST remain bounded and cancellable, perform no interaction-path network gating or synchronous disk I/O, use no polling or unbounded background loop, and preserve the originating object and foreground responsiveness under resource pressure. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. Implementation authorization requires an owner-approved performance-registry record declaring device floor, OS, build configuration, representative proof/receipt/history data scale, warm/cold state, measurement tool, percentile/maximum, and regression threshold.

## SPEC-COMPLETED-CONTEXTUAL-PLACEMENT-001 — Contextual Completed placement

- **Concept:** `global.completed.contextual-placement`
- **Modality:** `MUST NOT`
- **Scope:** Contextual Completed placement
- **Status:** `normative`
- **Verification:** `REVIEW-SPEC-COMPLETED-CONTEXTUAL-PLACEMENT-001`
- **Supersedes:** none

Completed MUST remain contextual across Today recent activity, Goals proof/history, Time past context, and You Receipts/History; it MUST NOT become a fifth root or mere completed bin.
