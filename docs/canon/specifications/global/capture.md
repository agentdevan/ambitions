+++
spec_id = "GLOBAL-CAPTURE"
title = "Capture"
kind = "global"
status = "normative"
owner_domain = "global-capture"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "global.capture.attachment-intake",
  "global.capture.classification",
  "global.capture.close-behavior",
  "global.capture.command-contract",
  "global.capture.draft-recovery",
  "global.capture.identity",
  "global.capture.keyboard",
  "global.capture.proposal-flow",
  "global.capture.saved-for-later",
  "global.capture.visual-authority",
]
inherits = [
  "LAW-IA-NONROOT-001",
  "OBJECT-SAVED-FOR-LATER-001",
  "CONTROL-MATERIAL-CONFIRMATION-001",
  "LAW-LOCAL-AUTHORITY-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION", "APP-PERMISSIONS"]
source_owners = [
  "Native/Ambitions/Composer/Capture/",
  "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/",
  "Native/Ambitions/Core/LocalRuntimeOS/Transactions/",
  "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/",
  "Native/Ambitions/Core/LocalRuntimeOS/State/",
  "Native/Ambitions/Core/LocalRuntimeOS/Storage/",
  "Native/Ambitions/Core/LocalRuntimeOS/Projections/",
  "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/",
  "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/",
  "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/",
  "Native/Ambitions/Core/LocalRuntimeOS/Commands/",
  "Native/Ambitions/Core/LocalRuntimeOS/Inspection/",
  "Native/Ambitions/Quality/",
]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Remove => destination: the draft attachment list after the failed row is detached. The handoff starts from Capture attachment intake explicit state contract / Attachment Failed; effect: The typed Capture draft attachment removal command appends an Event, updates the Projection, and creates a Receipt and History; only the failed attachment is detached after explicit action; draft text and every other attachment remain unchanged; Capture attachment intake explicit state contract / Attachment Failed reports the outcome from this visible condition: The attachment could not be prepared. Existing Capture text and choices remain; focus: the next attachment row or composer insertion point within Capture attachment intake explicit state contract / Attachment Failed.\nReplace => destination: the replacement picker followed by the same attachment row. The handoff starts from Capture attachment intake explicit state contract / Attachment Failed; effect: The typed Capture draft attachment replacement command appends an Event, updates the Projection, and creates a Receipt and History; the failed record remains intact until the replacement is staged, then the row points to the replacement while draft text and other attachments remain unchanged; Capture attachment intake explicit state contract / Attachment Failed reports the outcome from this visible condition: The attachment could not be prepared. Existing Capture text and choices remain; focus: the staged replacement attachment status within Capture attachment intake explicit state contract / Attachment Failed.\nRetry => destination: the same staged attachment processing row. The handoff starts from Capture attachment intake explicit state contract / Attachment Failed; effect: No local canonical mutation is replayed; only failed attachment processing is retried with the staged attachment identity and idempotency key; a successful result updates that row without duplicating the attachment; Capture attachment intake explicit state contract / Attachment Failed reports the outcome from this visible condition: The attachment could not be prepared. Existing Capture text and choices remain; focus: the retried attachment status within Capture attachment intake explicit state contract / Attachment Failed."
durable_effect = "Exact command consequences: Remove: The typed Capture draft attachment removal command appends an Event, updates the Projection, and creates a Receipt and History; only the failed attachment is detached after explicit action; draft text and every other attachment remain unchanged | Replace: The typed Capture draft attachment replacement command appends an Event, updates the Projection, and creates a Receipt and History; the failed record remains intact until the replacement is staged, then the row points to the replacement while draft text and other attachments remain unchanged | Retry: No local canonical mutation is replayed; only failed attachment processing is retried with the staged attachment identity and idempotency key; a successful result updates that row without duplicating the attachment. The durable boundary is specific to this visible evidence: The attachment could not be prepared. Existing Capture text and choices remain."
recovery_rollback = "Exact rollback and recovery: Remove: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. | Replace: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. | Retry: Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command. Recovery preserves or restores the interface evidence that says: The attachment could not be prepared. Existing Capture text and choices remain."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: The attachment could not be prepared. Existing Capture text and choices remain."
accessibility_focus = "VoiceOver focus contract: Remove announces its consequence, then success focuses the next attachment row or composer insertion point; rejection focuses the failed attachment row and Remove control | Replace announces its consequence, then success focuses the staged replacement attachment status; rejection focuses the failed attachment row and Replace control | Retry announces its consequence, then success focuses the retried attachment status; rejection focuses the failed attachment row and Retry control. The announcement includes this user-facing evidence before focus moves: The attachment could not be prepared. Existing Capture text and choices remain."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001"
label = "Remove"
canonical_owner = "global.capture.command-contract"
preconditions = ["Draft text and other attachments are retained", "The failed staged attachment identity and current draft revision exist", "The user explicitly chose Remove"]
destination = "the draft attachment list after the failed row is detached. The handoff starts from Capture attachment intake explicit state contract / Attachment Failed"
destination_id = "DEST-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001"
destination_posture = "current"
effect = "The typed Capture draft attachment removal command appends an Event, updates the Projection, and creates a Receipt and History; only the failed attachment is detached after explicit action; draft text and every other attachment remain unchanged; Capture attachment intake explicit state contract / Attachment Failed reports the outcome from this visible condition: The attachment could not be prepared. Existing Capture text and choices remain"
success_focus = "the next attachment row or composer insertion point within Capture attachment intake explicit state contract / Attachment Failed"
success_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the failed attachment row and Remove control while Capture attachment intake explicit state contract / Attachment Failed remains visible"
failure_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
recovery_id = "RECOVERY-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]
rollback_posture = "inverse_command"
inverse_command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001-INVERSE"
label = "Restore failed attachment"
canonical_owner = "global.capture.command-contract"
preconditions = ["CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001 is the exact trigger command and its exact trigger Receipt is current", "The detached failed-attachment identity, Capture draft revision, draft text, and remaining attachment set are current"]
destination = "the Capture draft attachment list with the same failed attachment row restored beside unchanged draft text and other attachments"
destination_id = "DEST-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it reattaches the same failed staged attachment record to the current Capture draft, appends a reversing Event, updates the draft attachment Projection, and creates a new inverse Receipt and History entry while draft text, other attachments, the removal Receipt, and History remain intact."
success_focus = "the restored failed attachment row and its unchanged failure status in the Capture draft"
success_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the failed-attachment restore control and exact unsafe, stale, or dependency-invalid draft/attachment reason; the detached result and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001-INVERSE"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002"
label = "Replace"
canonical_owner = "global.capture.command-contract"
preconditions = ["Draft text and other attachments are retained", "The failed staged attachment identity and current draft revision exist"]
destination = "the replacement picker followed by the same attachment row. The handoff starts from Capture attachment intake explicit state contract / Attachment Failed"
destination_id = "DEST-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002"
destination_posture = "current"
effect = "The typed Capture draft attachment replacement command appends an Event, updates the Projection, and creates a Receipt and History; the failed record remains intact until the replacement is staged, then the row points to the replacement while draft text and other attachments remain unchanged; Capture attachment intake explicit state contract / Attachment Failed reports the outcome from this visible condition: The attachment could not be prepared. Existing Capture text and choices remain"
success_focus = "the staged replacement attachment status within Capture attachment intake explicit state contract / Attachment Failed"
success_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the failed attachment row and Replace control while Capture attachment intake explicit state contract / Attachment Failed remains visible"
failure_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: opening or cancelling the picker is non-mutating; the typed draft replacement commits only after replacement bytes are staged and the current draft revision is validated."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
recovery_id = "RECOVERY-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]
rollback_posture = "inverse_command"
inverse_command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002-INVERSE"
label = "Restore prior attachment"
canonical_owner = "global.capture.command-contract"
preconditions = ["CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002 is the exact trigger command and its exact trigger Receipt is current", "The prior failed-attachment identity, staged replacement identity, Capture draft revision, and unchanged sibling attachments are current"]
destination = "the Capture draft attachment list with the prior failed attachment pointer restored and the replacement no longer selected for this row"
destination_id = "DEST-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it restores the row link to the prior failed attachment identity without deleting the staged replacement artifact, appends a reversing Event, updates the draft attachment Projection, and creates a new inverse Receipt and History entry while draft text, sibling attachments, the replacement Receipt, and History remain intact."
success_focus = "the restored prior failed attachment row with the replacement link removed from that row"
success_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the attachment-replacement recovery control and exact unsafe, stale, or dependency-invalid draft/attachment reason; the replacement result and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-002-INVERSE"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-003"
label = "Retry"
canonical_owner = "global.capture.command-contract"
preconditions = ["Draft text and other attachments are retained", "The attachment retry reuses its original idempotency key", "The failed staged attachment identity and current draft revision exist"]
destination = "the same staged attachment processing row. The handoff starts from Capture attachment intake explicit state contract / Attachment Failed"
destination_id = "DEST-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-003"
destination_posture = "current"
effect = "No local canonical mutation is replayed; only failed attachment processing is retried with the staged attachment identity and idempotency key; a successful result updates that row without duplicating the attachment; Capture attachment intake explicit state contract / Attachment Failed reports the outcome from this visible condition: The attachment could not be prepared. Existing Capture text and choices remain"
success_focus = "the retried attachment status within Capture attachment intake explicit state contract / Attachment Failed"
success_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the failed attachment row and Retry control while Capture attachment intake explicit state contract / Attachment Failed remains visible"
failure_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: the existing durable result or outbox identity is revalidated before only the failed external/read operation runs; the accepted local Event is never replayed."
rollback_undo = "Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command."
recovery_id = "RECOVERY-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-003"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "Original attachment bytes remain local unless the already approved picker/source operation requires a system handoff; no draft context is uploaded."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-ATTACHMENT-ATTACHMENT-PERMISSION-DENIED"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review permission => destination: the contextual attachment permission explanation. The handoff starts from Capture attachment intake explicit state contract / Attachment Permission Denied; effect: No durable mutation occurs and no Receipt is created; the current permission, local alternatives, and optional system Settings handoff are shown without silently reprompting; Capture attachment intake explicit state contract / Attachment Permission Denied reports the outcome from this visible condition: The attachment cannot be added because access is off. Existing Capture text remains; focus: the permission status and available local alternative within Capture attachment intake explicit state contract / Attachment Permission Denied."
durable_effect = "Exact command consequences: Review permission: No durable mutation occurs and no Receipt is created; the current permission, local alternatives, and optional system Settings handoff are shown without silently reprompting. The durable boundary is specific to this visible evidence: The attachment cannot be added because access is off. Existing Capture text remains."
recovery_rollback = "Exact rollback and recovery: Review permission: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The attachment cannot be added because access is off. Existing Capture text remains."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: The attachment cannot be added because access is off. Existing Capture text remains."
accessibility_focus = "VoiceOver focus contract: Review permission announces its consequence, then success focuses the permission status and available local alternative; rejection focuses the failed attachment row and Review permission control. The announcement includes this user-facing evidence before focus moves: The attachment cannot be added because access is off. Existing Capture text remains."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-PERMISSION-DENIED-001"
label = "Review permission"
canonical_owner = "global.capture.command-contract"
preconditions = ["The denied attachment permission and affected picker type are known"]
destination = "the contextual attachment permission explanation. The handoff starts from Capture attachment intake explicit state contract / Attachment Permission Denied"
destination_id = "DEST-CAPTURE-ATTACHMENT-ATTACHMENT-PERMISSION-DENIED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the current permission, local alternatives, and optional system Settings handoff are shown without silently reprompting; Capture attachment intake explicit state contract / Attachment Permission Denied reports the outcome from this visible condition: The attachment cannot be added because access is off. Existing Capture text remains"
success_focus = "the permission status and available local alternative within Capture attachment intake explicit state contract / Attachment Permission Denied"
success_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-PERMISSION-DENIED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the failed attachment row and Review permission control while Capture attachment intake explicit state contract / Attachment Permission Denied remains visible"
failure_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-PERMISSION-DENIED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-ATTACHMENT-ATTACHMENT-PERMISSION-DENIED-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-ATTACHMENT-ATTACHMENT-PROCESSING"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained Capture draft and initiating control. The handoff starts from Capture attachment intake explicit state contract / Attachment Processing; effect: No durable mutation occurs and no Receipt is created; optional work stops while original text, attachments, type, and accepted metadata remain unchanged; Capture attachment intake explicit state contract / Attachment Processing reports the outcome from this visible condition: The attachment is being prepared locally; the Capture remains available; this command preserves accepted product state; focus: the initiating composer control within Capture attachment intake explicit state contract / Attachment Processing."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; optional work stops while original text, attachments, type, and accepted metadata remain unchanged. The durable boundary is specific to this visible evidence: The attachment is being prepared locally; the Capture remains available."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The attachment is being prepared locally; the Capture remains available."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: The attachment is being prepared locally; the Capture remains available."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating composer control; rejection focuses the in-progress status and Cancel control. The announcement includes this user-facing evidence before focus moves: The attachment is being prepared locally; the Capture remains available."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-PROCESSING-001"
label = "Cancel"
canonical_owner = "global.capture.command-contract"
preconditions = ["Only optional attachment, validation, classification, or proposal work is in progress"]
destination = "the retained Capture draft and initiating control. The handoff starts from Capture attachment intake explicit state contract / Attachment Processing"
destination_id = "DEST-CAPTURE-ATTACHMENT-ATTACHMENT-PROCESSING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; optional work stops while original text, attachments, type, and accepted metadata remain unchanged; Capture attachment intake explicit state contract / Attachment Processing reports the outcome from this visible condition: The attachment is being prepared locally; the Capture remains available; this command preserves accepted product state"
success_focus = "the initiating composer control within Capture attachment intake explicit state contract / Attachment Processing"
success_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-PROCESSING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the in-progress status and Cancel control while Capture attachment intake explicit state contract / Attachment Processing remains visible"
failure_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-PROCESSING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-ATTACHMENT-ATTACHMENT-PROCESSING-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-ATTACHMENT-ATTACHMENT-READY"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the typed Capture proposal review. The handoff starts from Capture attachment intake explicit state contract / Attachment Ready; effect: No durable mutation occurs and no Receipt is created; staged attachments remain linked to the draft and no canonical object is committed; Capture attachment intake explicit state contract / Attachment Ready reports the outcome from this visible condition: The attachment preview is present, but attachment controls are unavailable; focus: the proposal heading and first attachment consequence within Capture attachment intake explicit state contract / Attachment Ready."
durable_effect = "Exact command consequences: Continue: No durable mutation occurs and no Receipt is created; staged attachments remain linked to the draft and no canonical object is committed. The durable boundary is specific to this visible evidence: The attachment preview is present, but attachment controls are unavailable."
recovery_rollback = "Exact rollback and recovery: Continue: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The attachment preview is present, but attachment controls are unavailable."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: The attachment preview is present, but attachment controls are unavailable."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence, then success focuses the proposal heading and first attachment consequence; rejection focuses the attachment row and Continue control. The announcement includes this user-facing evidence before focus moves: The attachment preview is present, but attachment controls are unavailable."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-READY-001"
label = "Continue"
canonical_owner = "global.capture.command-contract"
preconditions = ["All selected attachments are staged and the draft revision is current"]
destination = "the typed Capture proposal review. The handoff starts from Capture attachment intake explicit state contract / Attachment Ready"
destination_id = "DEST-CAPTURE-ATTACHMENT-ATTACHMENT-READY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; staged attachments remain linked to the draft and no canonical object is committed; Capture attachment intake explicit state contract / Attachment Ready reports the outcome from this visible condition: The attachment preview is present, but attachment controls are unavailable"
success_focus = "the proposal heading and first attachment consequence within Capture attachment intake explicit state contract / Attachment Ready"
success_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-READY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the attachment row and Continue control while Capture attachment intake explicit state contract / Attachment Ready remains visible"
failure_focus_id = "FOCUS-CAPTURE-ATTACHMENT-ATTACHMENT-READY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-ATTACHMENT-ATTACHMENT-READY-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-AMBIGUOUS-TYPE"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: the typed Capture proposal choice review. The handoff starts from Capture composer explicit state contract / Ambiguous Type; effect: No durable mutation occurs and no Receipt is created; Goal, Step, Reminder, Event, Proof, Note, and Save for Later choices show exact consequences; selection changes only the draft proposal and does not commit an object; Capture composer explicit state contract / Ambiguous Type reports the outcome from this visible condition: The Capture could describe more than one kind of item. Its original words remain unchanged; focus: the current proposed type and its consequence within Capture composer explicit state contract / Ambiguous Type."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; Goal, Step, Reminder, Event, Proof, Note, and Save for Later choices show exact consequences; selection changes only the draft proposal and does not commit an object. The durable boundary is specific to this visible evidence: The Capture could describe more than one kind of item. Its original words remain unchanged."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The Capture could describe more than one kind of item. Its original words remain unchanged."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: The Capture could describe more than one kind of item. Its original words remain unchanged."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the current proposed type and its consequence; rejection focuses the proposal conflict and Review control. The announcement includes this user-facing evidence before focus moves: The Capture could describe more than one kind of item. Its original words remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-AMBIGUOUS-TYPE-001"
label = "Review"
canonical_owner = "global.capture.command-contract"
preconditions = ["The current draft proposal, chosen type, and draft revision are retained"]
destination = "the typed Capture proposal choice review. The handoff starts from Capture composer explicit state contract / Ambiguous Type"
destination_id = "DEST-CAPTURE-COMPOSER-AMBIGUOUS-TYPE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Goal, Step, Reminder, Event, Proof, Note, and Save for Later choices show exact consequences; selection changes only the draft proposal and does not commit an object; Capture composer explicit state contract / Ambiguous Type reports the outcome from this visible condition: The Capture could describe more than one kind of item. Its original words remain unchanged"
success_focus = "the current proposed type and its consequence within Capture composer explicit state contract / Ambiguous Type"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-AMBIGUOUS-TYPE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the proposal conflict and Review control while Capture composer explicit state contract / Ambiguous Type remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-AMBIGUOUS-TYPE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-AMBIGUOUS-TYPE-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-BLANK"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture composer explicit state contract / Blank; effect: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture composer explicit state contract / Blank reports the outcome from this visible condition: Capture is ready. Nothing has been entered or saved; focus: the next unresolved proposal or placement field within Capture composer explicit state contract / Blank."
durable_effect = "Exact command consequences: Continue: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination. The durable boundary is specific to this visible evidence: Capture is ready. Nothing has been entered or saved."
recovery_rollback = "Exact rollback and recovery: Continue: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Capture is ready. Nothing has been entered or saved."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Capture is ready. Nothing has been entered or saved."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence, then success focuses the next unresolved proposal or placement field; rejection focuses the Continue control and exact blocking field. The announcement includes this user-facing evidence before focus moves: Capture is ready. Nothing has been entered or saved."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-BLANK-001"
label = "Continue"
canonical_owner = "global.capture.command-contract"
preconditions = ["The current draft revision, chosen type, attachments, and proposal are retained"]
destination = "the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture composer explicit state contract / Blank"
destination_id = "DEST-CAPTURE-COMPOSER-BLANK-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture composer explicit state contract / Blank reports the outcome from this visible condition: Capture is ready. Nothing has been entered or saved"
success_focus = "the next unresolved proposal or placement field within Capture composer explicit state contract / Blank"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-BLANK-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact blocking field while Capture composer explicit state contract / Blank remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-BLANK-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-BLANK-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-COMPOSING"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture composer explicit state contract / Composing; effect: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture composer explicit state contract / Composing reports the outcome from this visible condition: Draft in progress. Your words remain local until you choose what to do next; focus: the next unresolved proposal or placement field within Capture composer explicit state contract / Composing."
durable_effect = "Exact command consequences: Continue: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination. The durable boundary is specific to this visible evidence: Draft in progress. Your words remain local until you choose what to do next."
recovery_rollback = "Exact rollback and recovery: Continue: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Draft in progress. Your words remain local until you choose what to do next."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Draft in progress. Your words remain local until you choose what to do next."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence, then success focuses the next unresolved proposal or placement field; rejection focuses the Continue control and exact blocking field. The announcement includes this user-facing evidence before focus moves: Draft in progress. Your words remain local until you choose what to do next."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-COMPOSING-001"
label = "Continue"
canonical_owner = "global.capture.command-contract"
preconditions = ["The current draft revision, chosen type, attachments, and proposal are retained"]
destination = "the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture composer explicit state contract / Composing"
destination_id = "DEST-CAPTURE-COMPOSER-COMPOSING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture composer explicit state contract / Composing reports the outcome from this visible condition: Draft in progress. Your words remain local until you choose what to do next"
success_focus = "the next unresolved proposal or placement field within Capture composer explicit state contract / Composing"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-COMPOSING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact blocking field while Capture composer explicit state contract / Composing remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-COMPOSING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-COMPOSING-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-CONFIRMATION-REQUIRED"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture composer explicit state contract / Confirmation Required; effect: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture composer explicit state contract / Confirmation Required reports the outcome from this visible condition: The proposed Capture result and destination are visible without save controls; focus: the next unresolved proposal or placement field within Capture composer explicit state contract / Confirmation Required."
durable_effect = "Exact command consequences: Continue: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination. The durable boundary is specific to this visible evidence: The proposed Capture result and destination are visible without save controls."
recovery_rollback = "Exact rollback and recovery: Continue: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The proposed Capture result and destination are visible without save controls."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: The proposed Capture result and destination are visible without save controls."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence, then success focuses the next unresolved proposal or placement field; rejection focuses the Continue control and exact blocking field. The announcement includes this user-facing evidence before focus moves: The proposed Capture result and destination are visible without save controls."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-CONFIRMATION-REQUIRED-001"
label = "Continue"
canonical_owner = "global.capture.command-contract"
preconditions = ["The current draft revision, chosen type, attachments, and proposal are retained"]
destination = "the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture composer explicit state contract / Confirmation Required"
destination_id = "DEST-CAPTURE-COMPOSER-CONFIRMATION-REQUIRED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture composer explicit state contract / Confirmation Required reports the outcome from this visible condition: The proposed Capture result and destination are visible without save controls"
success_focus = "the next unresolved proposal or placement field within Capture composer explicit state contract / Confirmation Required"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-CONFIRMATION-REQUIRED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact blocking field while Capture composer explicit state contract / Confirmation Required remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-CONFIRMATION-REQUIRED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-CONFIRMATION-REQUIRED-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-DEGRADED-STORE"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the Capture store recovery and diagnostics review. The handoff starts from Capture composer explicit state contract / Degraded Store; effect: No durable mutation occurs and no Receipt is created; no saved-success copy or dismissal occurs; Continue only reviews safe recovery while the composer remains open; Capture composer explicit state contract / Degraded Store reports the outcome from this visible condition: Some saved information is temporarily unavailable; the Capture input remains protected; focus: the degraded-store status and first safe recovery option within Capture composer explicit state contract / Degraded Store."
durable_effect = "Exact command consequences: Continue: No durable mutation occurs and no Receipt is created; no saved-success copy or dismissal occurs; Continue only reviews safe recovery while the composer remains open. The durable boundary is specific to this visible evidence: Some saved information is temporarily unavailable; the Capture input remains protected."
recovery_rollback = "Exact rollback and recovery: Continue: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Some saved information is temporarily unavailable; the Capture input remains protected."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Some saved information is temporarily unavailable; the Capture input remains protected."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence, then success focuses the degraded-store status and first safe recovery option; rejection focuses the Continue control and store failure reason. The announcement includes this user-facing evidence before focus moves: Some saved information is temporarily unavailable; the Capture input remains protected."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-DEGRADED-STORE-001"
label = "Continue"
canonical_owner = "global.capture.command-contract"
preconditions = ["The local store is degraded and the in-memory or staged draft is retained"]
destination = "the Capture store recovery and diagnostics review. The handoff starts from Capture composer explicit state contract / Degraded Store"
destination_id = "DEST-CAPTURE-COMPOSER-DEGRADED-STORE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; no saved-success copy or dismissal occurs; Continue only reviews safe recovery while the composer remains open; Capture composer explicit state contract / Degraded Store reports the outcome from this visible condition: Some saved information is temporarily unavailable; the Capture input remains protected"
success_focus = "the degraded-store status and first safe recovery option within Capture composer explicit state contract / Degraded Store"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-DEGRADED-STORE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and store failure reason while Capture composer explicit state contract / Degraded Store remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-DEGRADED-STORE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-DEGRADED-STORE-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-DICTATING"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Stop dictation => destination: the Capture composer at the preserved insertion point. The handoff starts from Capture composer explicit state contract / Dictating; effect: The typed Capture draft transcript staging command appends an Event, updates the Projection, and creates a Receipt and History; reviewed transcript text is inserted into the current draft; raw audio is not retained unless separately chosen as a Voice attachment; Capture composer explicit state contract / Dictating reports the outcome from this visible condition: Spoken words are appearing in Capture. Nothing has been saved; focus: the transcript insertion point within Capture composer explicit state contract / Dictating."
durable_effect = "Exact command consequences: Stop dictation: The typed Capture draft transcript staging command appends an Event, updates the Projection, and creates a Receipt and History; reviewed transcript text is inserted into the current draft; raw audio is not retained unless separately chosen as a Voice attachment. The durable boundary is specific to this visible evidence: Spoken words are appearing in Capture. Nothing has been saved."
recovery_rollback = "Exact rollback and recovery: Stop dictation: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: Spoken words are appearing in Capture. Nothing has been saved."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Spoken words are appearing in Capture. Nothing has been saved."
accessibility_focus = "VoiceOver focus contract: Stop dictation announces its consequence, then success focuses the transcript insertion point; rejection focuses the dictation control with existing draft text unchanged. The announcement includes this user-facing evidence before focus moves: Spoken words are appearing in Capture. Nothing has been saved."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-DICTATING-001"
label = "Stop dictation"
canonical_owner = "global.capture.command-contract"
preconditions = ["An active dictation session and current draft insertion point exist", "The current draft revision is valid"]
destination = "the Capture composer at the preserved insertion point. The handoff starts from Capture composer explicit state contract / Dictating"
destination_id = "DEST-CAPTURE-COMPOSER-DICTATING-001"
destination_posture = "current"
effect = "The typed Capture draft transcript staging command appends an Event, updates the Projection, and creates a Receipt and History; reviewed transcript text is inserted into the current draft; raw audio is not retained unless separately chosen as a Voice attachment; Capture composer explicit state contract / Dictating reports the outcome from this visible condition: Spoken words are appearing in Capture. Nothing has been saved"
success_focus = "the transcript insertion point within Capture composer explicit state contract / Dictating"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-DICTATING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the dictation control with existing draft text unchanged while Capture composer explicit state contract / Dictating remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-DICTATING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-DICTATING-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]
rollback_posture = "inverse_command"
inverse_command_id = "CMD-CAPTURE-COMPOSER-DICTATING-001-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-CAPTURE-COMPOSER-DICTATING-001"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-CAPTURE-COMPOSER-DICTATING-001"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-CAPTURE-COMPOSER-DICTATING-001-INVERSE"
label = "Remove inserted transcript"
canonical_owner = "global.capture.command-contract"
preconditions = ["CMD-CAPTURE-COMPOSER-DICTATING-001 is the exact trigger command and its exact trigger Receipt is current", "The inserted transcript range, Capture draft revision, surrounding draft text, and absence of a separately retained Voice attachment are current"]
destination = "the Capture composer at the transcript insertion point with only the reviewed dictated text removed"
destination_id = "DEST-CAPTURE-COMPOSER-DICTATING-001-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it removes only the transcript range inserted by Stop dictation, appends a reversing Event, updates the Capture draft Projection, and creates a new inverse Receipt and History entry while surrounding text, attachments, any separately chosen Voice attachment, the dictation Receipt, and History remain intact."
success_focus = "the Capture text insertion point where the reviewed transcript was removed"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-DICTATING-001-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the transcript-removal control and exact unsafe, stale, or dependency-invalid draft/range reason; the inserted transcript and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-DICTATING-001-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-DICTATING-001-INVERSE"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-DISCARD-REVIEW"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Discard => destination: the stored origin route and focus. The handoff starts from Capture composer explicit state contract / Discard Review; effect: The typed Capture draft discard command appends an Event, updates the Projection, and creates a Receipt and History; the selected draft and its staged attachments are discarded without changing any already accepted canonical object; Capture composer explicit state contract / Discard Review reports the outcome from this visible condition: Discard this unsaved Capture? Text and unattached local choices will be removed; focus: the invoking global Capture control or origin object within Capture composer explicit state contract / Discard Review.\nKeep editing => destination: the same Capture composer draft. The handoff starts from Capture composer explicit state contract / Discard Review; effect: No durable mutation occurs and no Receipt is created; discard review closes and all draft text, attachments, proposal, selection, and focus remain intact; Capture composer explicit state contract / Discard Review reports the outcome from this visible condition: Discard this unsaved Capture? Text and unattached local choices will be removed; this command preserves accepted product state; focus: the last focused composer field within Capture composer explicit state contract / Discard Review."
durable_effect = "Exact command consequences: Discard: The typed Capture draft discard command appends an Event, updates the Projection, and creates a Receipt and History; the selected draft and its staged attachments are discarded without changing any already accepted canonical object | Keep editing: No durable mutation occurs and no Receipt is created; discard review closes and all draft text, attachments, proposal, selection, and focus remain intact. The durable boundary is specific to this visible evidence: Discard this unsaved Capture? Text and unattached local choices will be removed."
recovery_rollback = "Exact rollback and recovery: Discard: Cancellation preserves the draft; after confirmed discard, only an available draft checkpoint recovery may append a restoring mutation, otherwise Undo is unavailable. | Keep editing: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Discard this unsaved Capture? Text and unattached local choices will be removed."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Discard this unsaved Capture? Text and unattached local choices will be removed."
accessibility_focus = "VoiceOver focus contract: Discard announces its consequence, then success focuses the invoking global Capture control or origin object; rejection focuses the Discard confirmation control | Keep editing announces its consequence, then success focuses the last focused composer field; rejection focuses the Keep editing control. The announcement includes this user-facing evidence before focus moves: Discard this unsaved Capture? Text and unattached local choices will be removed."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-DISCARD-REVIEW-001"
label = "Discard"
canonical_owner = "global.capture.command-contract"
preconditions = ["Discard is explicitly confirmed", "The exact draft identity and discard consequence are shown"]
destination = "the stored origin route and focus. The handoff starts from Capture composer explicit state contract / Discard Review"
destination_id = "DEST-CAPTURE-COMPOSER-DISCARD-REVIEW-001"
destination_posture = "current"
effect = "The typed Capture draft discard command appends an Event, updates the Projection, and creates a Receipt and History; the selected draft and its staged attachments are discarded without changing any already accepted canonical object; Capture composer explicit state contract / Discard Review reports the outcome from this visible condition: Discard this unsaved Capture? Text and unattached local choices will be removed"
success_focus = "the invoking global Capture control or origin object within Capture composer explicit state contract / Discard Review"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-DISCARD-REVIEW-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Discard confirmation control while Capture composer explicit state contract / Discard Review remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-DISCARD-REVIEW-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation preserves the draft; after confirmed discard, the retained draft checkpoint is the only restore route and any restoring mutation appends History."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-DISCARD-REVIEW-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]
rollback_posture = "checkpoint_restore"
checkpoint_id = "CHECKPOINT-CAPTURE-COMPOSER-DISCARD-REVIEW-001"

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-DISCARD-REVIEW-002"
label = "Keep editing"
canonical_owner = "global.capture.command-contract"
preconditions = ["The draft identity and unsaved content remain available"]
destination = "the same Capture composer draft. The handoff starts from Capture composer explicit state contract / Discard Review"
destination_id = "DEST-CAPTURE-COMPOSER-DISCARD-REVIEW-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; discard review closes and all draft text, attachments, proposal, selection, and focus remain intact; Capture composer explicit state contract / Discard Review reports the outcome from this visible condition: Discard this unsaved Capture? Text and unattached local choices will be removed; this command preserves accepted product state"
success_focus = "the last focused composer field within Capture composer explicit state contract / Discard Review"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-DISCARD-REVIEW-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep editing control while Capture composer explicit state contract / Discard Review remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-DISCARD-REVIEW-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-DISCARD-REVIEW-002"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-INVALID-METADATA"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the first invalid Capture metadata field. The handoff starts from Capture composer explicit state contract / Invalid Metadata; effect: No durable mutation occurs and no Receipt is created; the proposal remains uncommitted and valid draft input is preserved for correction; Capture composer explicit state contract / Invalid Metadata reports the outcome from this visible condition: One Capture field is invalid. The entered text remains unchanged; focus: the exact invalid field within Capture composer explicit state contract / Invalid Metadata."
durable_effect = "Exact command consequences: Continue: No durable mutation occurs and no Receipt is created; the proposal remains uncommitted and valid draft input is preserved for correction. The durable boundary is specific to this visible evidence: One Capture field is invalid. The entered text remains unchanged."
recovery_rollback = "Exact rollback and recovery: Continue: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: One Capture field is invalid. The entered text remains unchanged."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: One Capture field is invalid. The entered text remains unchanged."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence, then success focuses the exact invalid field; rejection focuses the Continue control and validation reason. The announcement includes this user-facing evidence before focus moves: One Capture field is invalid. The entered text remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-INVALID-METADATA-001"
label = "Continue"
canonical_owner = "global.capture.command-contract"
preconditions = ["The invalid field and current draft revision are known"]
destination = "the first invalid Capture metadata field. The handoff starts from Capture composer explicit state contract / Invalid Metadata"
destination_id = "DEST-CAPTURE-COMPOSER-INVALID-METADATA-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposal remains uncommitted and valid draft input is preserved for correction; Capture composer explicit state contract / Invalid Metadata reports the outcome from this visible condition: One Capture field is invalid. The entered text remains unchanged"
success_focus = "the exact invalid field within Capture composer explicit state contract / Invalid Metadata"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-INVALID-METADATA-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and validation reason while Capture composer explicit state contract / Invalid Metadata remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-INVALID-METADATA-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-INVALID-METADATA-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-OFFLINE"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture composer explicit state contract / Offline; effect: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture composer explicit state contract / Offline reports the outcome from this visible condition: Capture remains fully available from local information without a connection; focus: the next unresolved proposal or placement field within Capture composer explicit state contract / Offline."
durable_effect = "Exact command consequences: Continue: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination. The durable boundary is specific to this visible evidence: Capture remains fully available from local information without a connection."
recovery_rollback = "Exact rollback and recovery: Continue: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Capture remains fully available from local information without a connection."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Capture remains fully available from local information without a connection."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence, then success focuses the next unresolved proposal or placement field; rejection focuses the Continue control and exact blocking field. The announcement includes this user-facing evidence before focus moves: Capture remains fully available from local information without a connection."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-OFFLINE-001"
label = "Continue"
canonical_owner = "global.capture.command-contract"
preconditions = ["The current draft revision, chosen type, attachments, and proposal are retained"]
destination = "the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture composer explicit state contract / Offline"
destination_id = "DEST-CAPTURE-COMPOSER-OFFLINE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture composer explicit state contract / Offline reports the outcome from this visible condition: Capture remains fully available from local information without a connection"
success_focus = "the next unresolved proposal or placement field within Capture composer explicit state contract / Offline"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-OFFLINE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact blocking field while Capture composer explicit state contract / Offline remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-OFFLINE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-OFFLINE-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-PARTIAL-ROUTING"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Retry routing => destination: the failed canonical-owner routing step. The handoff starts from Capture composer explicit state contract / Partial Routing; effect: No local canonical mutation is replayed; only failed route resolution is retried against the current draft revision; the draft survives and a prior accepted object is never duplicated; Capture composer explicit state contract / Partial Routing reports the outcome from this visible condition: Part of the saved Capture has been placed, while the remaining part is still pending. Both portions remain visible; focus: the resolved owner review or failed destination field within Capture composer explicit state contract / Partial Routing."
durable_effect = "Exact command consequences: Retry routing: No local canonical mutation is replayed; only failed route resolution is retried against the current draft revision; the draft survives and a prior accepted object is never duplicated. The durable boundary is specific to this visible evidence: Part of the saved Capture has been placed, while the remaining part is still pending. Both portions remain visible."
recovery_rollback = "Exact rollback and recovery: Retry routing: Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command. Recovery preserves or restores the interface evidence that says: Part of the saved Capture has been placed, while the remaining part is still pending. Both portions remain visible."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Part of the saved Capture has been placed, while the remaining part is still pending. Both portions remain visible."
accessibility_focus = "VoiceOver focus contract: Retry routing announces its consequence, then success focuses the resolved owner review or failed destination field; rejection focuses the failed route and Retry routing control. The announcement includes this user-facing evidence before focus moves: Part of the saved Capture has been placed, while the remaining part is still pending. Both portions remain visible."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-PARTIAL-ROUTING-001"
label = "Retry routing"
canonical_owner = "global.capture.command-contract"
preconditions = ["No prior accepted object may be duplicated", "The failed route, chosen type, destination, attachments, and current draft revision are retained"]
destination = "the failed canonical-owner routing step. The handoff starts from Capture composer explicit state contract / Partial Routing"
destination_id = "DEST-CAPTURE-COMPOSER-PARTIAL-ROUTING-001"
destination_posture = "current"
effect = "No local canonical mutation is replayed; only failed route resolution is retried against the current draft revision; the draft survives and a prior accepted object is never duplicated; Capture composer explicit state contract / Partial Routing reports the outcome from this visible condition: Part of the saved Capture has been placed, while the remaining part is still pending. Both portions remain visible"
success_focus = "the resolved owner review or failed destination field within Capture composer explicit state contract / Partial Routing"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-PARTIAL-ROUTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the failed route and Retry routing control while Capture composer explicit state contract / Partial Routing remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-PARTIAL-ROUTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: the existing durable result or outbox identity is revalidated before only the failed external/read operation runs; the accepted local Event is never replayed."
rollback_undo = "Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-PARTIAL-ROUTING-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The draft remains local and only the chosen local canonical owner receives the typed handoff; no network is required."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-RECOVERED"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture composer explicit state contract / Recovered; effect: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture composer explicit state contract / Recovered reports the outcome from this visible condition: Recovered draft content is visible; nothing new was saved during recovery and editing controls are unavailable; focus: the next unresolved proposal or placement field within Capture composer explicit state contract / Recovered."
durable_effect = "Exact command consequences: Continue: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination. The durable boundary is specific to this visible evidence: Recovered draft content is visible; nothing new was saved during recovery and editing controls are unavailable."
recovery_rollback = "Exact rollback and recovery: Continue: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Recovered draft content is visible; nothing new was saved during recovery and editing controls are unavailable."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Recovered draft content is visible; nothing new was saved during recovery and editing controls are unavailable."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence, then success focuses the next unresolved proposal or placement field; rejection focuses the Continue control and exact blocking field. The announcement includes this user-facing evidence before focus moves: Recovered draft content is visible; nothing new was saved during recovery and editing controls are unavailable."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-RECOVERED-001"
label = "Continue"
canonical_owner = "global.capture.command-contract"
preconditions = ["The current draft revision, chosen type, attachments, and proposal are retained"]
destination = "the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture composer explicit state contract / Recovered"
destination_id = "DEST-CAPTURE-COMPOSER-RECOVERED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture composer explicit state contract / Recovered reports the outcome from this visible condition: Recovered draft content is visible; nothing new was saved during recovery and editing controls are unavailable"
success_focus = "the next unresolved proposal or placement field within Capture composer explicit state contract / Recovered"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-RECOVERED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact blocking field while Capture composer explicit state contract / Recovered remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-RECOVERED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-RECOVERED-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-RESTORING"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the last accepted Capture draft. The handoff starts from Capture composer explicit state contract / Restoring; effect: No durable mutation occurs and no Receipt is created; optional checkpoint restoration stops without discarding the checkpoint or changing restored fields; Capture composer explicit state contract / Restoring reports the outcome from this visible condition: An earlier Capture draft is loading. Its saved text remains available; this command preserves accepted product state; focus: the last valid restored field, then the composer insertion point within Capture composer explicit state contract / Restoring."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; optional checkpoint restoration stops without discarding the checkpoint or changing restored fields. The durable boundary is specific to this visible evidence: An earlier Capture draft is loading. Its saved text remains available."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: An earlier Capture draft is loading. Its saved text remains available."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: An earlier Capture draft is loading. Its saved text remains available."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the last valid restored field, then the composer insertion point; rejection focuses the restoration status and Cancel control. The announcement includes this user-facing evidence before focus moves: An earlier Capture draft is loading. Its saved text remains available."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-RESTORING-001"
label = "Cancel"
canonical_owner = "global.capture.command-contract"
preconditions = ["A prior Capture checkpoint and last accepted draft remain available"]
destination = "the last accepted Capture draft. The handoff starts from Capture composer explicit state contract / Restoring"
destination_id = "DEST-CAPTURE-COMPOSER-RESTORING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; optional checkpoint restoration stops without discarding the checkpoint or changing restored fields; Capture composer explicit state contract / Restoring reports the outcome from this visible condition: An earlier Capture draft is loading. Its saved text remains available; this command preserves accepted product state"
success_focus = "the last valid restored field, then the composer insertion point within Capture composer explicit state contract / Restoring"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-RESTORING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the restoration status and Cancel control while Capture composer explicit state contract / Restoring remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-RESTORING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-RESTORING-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-ROUTING"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained Capture draft and proposal. The handoff starts from Capture composer explicit state contract / Routing; effect: No durable mutation occurs and no Receipt is created; pre-commit work stops; an accepted mutation is not cancelled and remains visible through its pending Receipt; Capture composer explicit state contract / Routing reports the outcome from this visible condition: The saved Capture is being organized into the selected Ambitions item. Its original text remains visible; this command preserves accepted product state; focus: the initiating proposal or save control within Capture composer explicit state contract / Routing."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; pre-commit work stops; an accepted mutation is not cancelled and remains visible through its pending Receipt. The durable boundary is specific to this visible evidence: The saved Capture is being organized into the selected Ambitions item. Its original text remains visible."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The saved Capture is being organized into the selected Ambitions item. Its original text remains visible."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: The saved Capture is being organized into the selected Ambitions item. Its original text remains visible."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating proposal or save control; rejection focuses the pending operation status and Cancel control. The announcement includes this user-facing evidence before focus moves: The saved Capture is being organized into the selected Ambitions item. Its original text remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-ROUTING-001"
label = "Cancel"
canonical_owner = "global.capture.command-contract"
preconditions = ["Any accepted mutation and pending Receipt are identified separately", "Only pre-commit save or routing work is cancellable"]
destination = "the retained Capture draft and proposal. The handoff starts from Capture composer explicit state contract / Routing"
destination_id = "DEST-CAPTURE-COMPOSER-ROUTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; pre-commit work stops; an accepted mutation is not cancelled and remains visible through its pending Receipt; Capture composer explicit state contract / Routing reports the outcome from this visible condition: The saved Capture is being organized into the selected Ambitions item. Its original text remains visible; this command preserves accepted product state"
success_focus = "the initiating proposal or save control within Capture composer explicit state contract / Routing"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-ROUTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the pending operation status and Cancel control while Capture composer explicit state contract / Routing remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-ROUTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-ROUTING-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-SAVED"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the stored origin route or accepted result owner. The handoff starts from Capture composer explicit state contract / Saved; effect: No durable mutation occurs and no Receipt is created; Capture dismisses after verified save; no additional object or schedule placement is created; Capture composer explicit state contract / Saved reports the outcome from this visible condition: Saved. The new item and its save record are available; this command preserves accepted product state; focus: the accepted result status or invoking Capture control within Capture composer explicit state contract / Saved."
durable_effect = "Exact command consequences: Done: No durable mutation occurs and no Receipt is created; Capture dismisses after verified save; no additional object or schedule placement is created. The durable boundary is specific to this visible evidence: Saved. The new item and its save record are available."
recovery_rollback = "Exact rollback and recovery: Done: No rollback control is exposed; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Saved. The new item and its save record are available."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, and save remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Saved. The new item and its save record are available."
accessibility_focus = "VoiceOver focus contract: Done announces its consequence, then success focuses the accepted result status or invoking Capture control; rejection focuses the Done control and saved result status. The announcement includes this user-facing evidence before focus moves: Saved. The new item and its save record are available."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-SAVED-001"
label = "Done"
canonical_owner = "global.capture.command-contract"
preconditions = ["The saved result and truthful Receipt or saved-draft status are visible"]
destination = "the stored origin route or accepted result owner. The handoff starts from Capture composer explicit state contract / Saved"
destination_id = "DEST-CAPTURE-COMPOSER-SAVED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Capture dismisses after verified save; no additional object or schedule placement is created; Capture composer explicit state contract / Saved reports the outcome from this visible condition: Saved. The new item and its save record are available; this command preserves accepted product state"
success_focus = "the accepted result status or invoking Capture control within Capture composer explicit state contract / Saved"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-SAVED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and saved result status while Capture composer explicit state contract / Saved remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-SAVED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-SAVED-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Undo => destination: the restored Capture result and new reversing Receipt. The handoff starts from Capture composer explicit state contract / Saved Undo Eligible; effect: The typed Capture result Undo command appends an Event, updates the Projection, and creates a Receipt and History; a reversing Event restores the pre-save result without erasing the original Receipt and History; Capture composer explicit state contract / Saved Undo Eligible reports the outcome from this visible condition: This saved Capture can be undone while the new item is unchanged; focus: the restored object or draft status and reversing Receipt within Capture composer explicit state contract / Saved Undo Eligible."
durable_effect = "Exact command consequences: Undo: The typed Capture result Undo command appends an Event, updates the Projection, and creates a Receipt and History; a reversing Event restores the pre-save result without erasing the original Receipt or History. The durable boundary is specific to this visible evidence: This saved Capture can be undone while the new item is unchanged."
recovery_rollback = "Exact rollback and recovery: Undo: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: This saved Capture can be undone while the new item is unchanged."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: This saved Capture can be undone while the new item is unchanged."
accessibility_focus = "VoiceOver focus contract: Undo announces its consequence, then success focuses the restored object or draft status and reversing Receipt; rejection focuses the Undo control and ineligibility reason. The announcement includes this user-facing evidence before focus moves: This saved Capture can be undone while the new item is unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001"
label = "Undo"
canonical_owner = "global.capture.command-contract"
preconditions = ["The reversing scope and current object revision are valid", "The saved Capture result has an eligible current Receipt"]
destination = "the restored Capture result and new reversing Receipt. The handoff starts from Capture composer explicit state contract / Saved Undo Eligible"
destination_id = "DEST-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001"
destination_posture = "current"
effect = "The typed Capture result Undo command appends an Event, updates the Projection, and creates a Receipt and History; a reversing Event restores the pre-save result without erasing the original Receipt and History; Capture composer explicit state contract / Saved Undo Eligible reports the outcome from this visible condition: This saved Capture can be undone while the new item is unchanged"
success_focus = "the restored object or draft status and reversing Receipt within Capture composer explicit state contract / Saved Undo Eligible"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Undo control and ineligibility reason while Capture composer explicit state contract / Saved Undo Eligible remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]
rollback_posture = "inverse_command"
inverse_command_id = "CMD-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001-INVERSE"
label = "Restore saved Capture"
canonical_owner = "global.capture.command-contract"
preconditions = ["CMD-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001 is the exact trigger command and its exact trigger Receipt is current", "The inverse Receipt for the saved Capture, original save Receipt, restored draft/object identities, and dependent revisions are current"]
destination = "the exact saved Capture result restored to its owning object presentation with both the save and Undo History visible"
destination_id = "DEST-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it reapplies the saved Capture result that the trigger Undo reversed, appends a reversing Event, updates the owning object and Capture Projection, and creates a new inverse Receipt and History entry while the original save Receipt, trigger Undo Receipt, and full History remain intact."
success_focus = "the restored saved Capture result and its newly appended recovery Receipt"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Restore saved Capture control and exact unsafe, stale, or dependency-invalid object/draft reason; the undone result and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE-001-INVERSE"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-SAVED-UNDO-UNAVAILABLE"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the stored origin route or accepted result owner. The handoff starts from Capture composer explicit state contract / Saved Undo Unavailable; effect: No durable mutation occurs and no Receipt is created; Capture dismisses after verified save; no additional object or schedule placement is created; Capture composer explicit state contract / Saved Undo Unavailable reports the outcome from this visible condition: This Capture change cannot be undone; its save receipt explains the safety or timing reason; this command preserves accepted product state; focus: the accepted result status or invoking Capture control within Capture composer explicit state contract / Saved Undo Unavailable."
durable_effect = "Exact command consequences: Done: No durable mutation occurs and no Receipt is created; Capture dismisses after verified save; no additional object or schedule placement is created. The durable boundary is specific to this visible evidence: This Capture change cannot be undone; its save receipt explains the safety or timing reason."
recovery_rollback = "Exact rollback and recovery: Done: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Capture change cannot be undone; its save receipt explains the safety or timing reason."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: This Capture change cannot be undone; its save receipt explains the safety or timing reason."
accessibility_focus = "VoiceOver focus contract: Done announces its consequence, then success focuses the accepted result status or invoking Capture control; rejection focuses the Done control and saved result status. The announcement includes this user-facing evidence before focus moves: This Capture change cannot be undone; its save receipt explains the safety or timing reason."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-SAVED-UNDO-UNAVAILABLE-001"
label = "Done"
canonical_owner = "global.capture.command-contract"
preconditions = ["The saved result and truthful Receipt or saved-draft status are visible"]
destination = "the stored origin route or accepted result owner. The handoff starts from Capture composer explicit state contract / Saved Undo Unavailable"
destination_id = "DEST-CAPTURE-COMPOSER-SAVED-UNDO-UNAVAILABLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Capture dismisses after verified save; no additional object or schedule placement is created; Capture composer explicit state contract / Saved Undo Unavailable reports the outcome from this visible condition: This Capture change cannot be undone; its save receipt explains the safety or timing reason; this command preserves accepted product state"
success_focus = "the accepted result status or invoking Capture control within Capture composer explicit state contract / Saved Undo Unavailable"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-SAVED-UNDO-UNAVAILABLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and saved result status while Capture composer explicit state contract / Saved Undo Unavailable remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-SAVED-UNDO-UNAVAILABLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-SAVED-UNDO-UNAVAILABLE-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-SAVING"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained Capture draft and proposal. The handoff starts from Capture composer explicit state contract / Saving; effect: No durable mutation occurs and no Receipt is created; pre-commit work stops; an accepted mutation is not cancelled and remains visible through its pending Receipt; Capture composer explicit state contract / Saving reports the outcome from this visible condition: The confirmed Capture is being saved locally; the draft stays visible until that finishes; this command preserves accepted product state; focus: the initiating proposal or save control within Capture composer explicit state contract / Saving."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; pre-commit work stops; an accepted mutation is not cancelled and remains visible through its pending Receipt. The durable boundary is specific to this visible evidence: The confirmed Capture is being saved locally; the draft stays visible until that finishes."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The confirmed Capture is being saved locally; the draft stays visible until that finishes."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: The confirmed Capture is being saved locally; the draft stays visible until that finishes."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating proposal or save control; rejection focuses the pending operation status and Cancel control. The announcement includes this user-facing evidence before focus moves: The confirmed Capture is being saved locally; the draft stays visible until that finishes."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-SAVING-001"
label = "Cancel"
canonical_owner = "global.capture.command-contract"
preconditions = ["Any accepted mutation and pending Receipt are identified separately", "Only pre-commit save or routing work is cancellable"]
destination = "the retained Capture draft and proposal. The handoff starts from Capture composer explicit state contract / Saving"
destination_id = "DEST-CAPTURE-COMPOSER-SAVING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; pre-commit work stops; an accepted mutation is not cancelled and remains visible through its pending Receipt; Capture composer explicit state contract / Saving reports the outcome from this visible condition: The confirmed Capture is being saved locally; the draft stays visible until that finishes; this command preserves accepted product state"
success_focus = "the initiating proposal or save control within Capture composer explicit state contract / Saving"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-SAVING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the pending operation status and Cancel control while Capture composer explicit state contract / Saving remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-SAVING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-SAVING-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-SCAN-IMPORTING"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the Capture draft with its prior selection and attachments. The handoff starts from Capture composer explicit state contract / Scan Importing; effect: No durable mutation occurs and no Receipt is created; scan staging stops, unaccepted camera imagery is not retained, and draft text remains unchanged; Capture composer explicit state contract / Scan Importing reports the outcome from this visible condition: Scanned content is being prepared. The current Capture text remains unchanged; this command preserves accepted product state; focus: the composer insertion point or scan control within Capture composer explicit state contract / Scan Importing."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; scan staging stops, unaccepted camera imagery is not retained, and draft text remains unchanged. The durable boundary is specific to this visible evidence: Scanned content is being prepared. The current Capture text remains unchanged."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Scanned content is being prepared. The current Capture text remains unchanged."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Scanned content is being prepared. The current Capture text remains unchanged."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the composer insertion point or scan control; rejection focuses the scan progress status and Cancel control. The announcement includes this user-facing evidence before focus moves: Scanned content is being prepared. The current Capture text remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-SCAN-IMPORTING-001"
label = "Cancel"
canonical_owner = "global.capture.command-contract"
preconditions = ["A scan is still staging and no scan result has committed"]
destination = "the Capture draft with its prior selection and attachments. The handoff starts from Capture composer explicit state contract / Scan Importing"
destination_id = "DEST-CAPTURE-COMPOSER-SCAN-IMPORTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; scan staging stops, unaccepted camera imagery is not retained, and draft text remains unchanged; Capture composer explicit state contract / Scan Importing reports the outcome from this visible condition: Scanned content is being prepared. The current Capture text remains unchanged; this command preserves accepted product state"
success_focus = "the composer insertion point or scan control within Capture composer explicit state contract / Scan Importing"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-SCAN-IMPORTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the scan progress status and Cancel control while Capture composer explicit state contract / Scan Importing remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-SCAN-IMPORTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-SCAN-IMPORTING-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-TYPED"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture composer explicit state contract / Typed; effect: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture composer explicit state contract / Typed reports the outcome from this visible condition: The entered text is ready to check. No Goal, Step, Reminder, Event, Proof, Note, or time placement has been saved; focus: the next unresolved proposal or placement field within Capture composer explicit state contract / Typed."
durable_effect = "Exact command consequences: Continue: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination. The durable boundary is specific to this visible evidence: The entered text is ready to check. No Goal, Step, Reminder, Event, Proof, Note, or time placement has been saved."
recovery_rollback = "Exact rollback and recovery: Continue: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The entered text is ready to check. No Goal, Step, Reminder, Event, Proof, Note, or time placement has been saved."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: The entered text is ready to check. No Goal, Step, Reminder, Event, Proof, Note, or time placement has been saved."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence, then success focuses the next unresolved proposal or placement field; rejection focuses the Continue control and exact blocking field. The announcement includes this user-facing evidence before focus moves: The entered text is ready to check. No Goal, Step, Reminder, Event, Proof, Note, or time placement has been saved."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-TYPED-001"
label = "Continue"
canonical_owner = "global.capture.command-contract"
preconditions = ["The current draft revision, chosen type, attachments, and proposal are retained"]
destination = "the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture composer explicit state contract / Typed"
destination_id = "DEST-CAPTURE-COMPOSER-TYPED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture composer explicit state contract / Typed reports the outcome from this visible condition: The entered text is ready to check. No Goal, Step, Reminder, Event, Proof, Note, or time placement has been saved"
success_focus = "the next unresolved proposal or placement field within Capture composer explicit state contract / Typed"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-TYPED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact blocking field while Capture composer explicit state contract / Typed remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-TYPED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-TYPED-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-COMPOSER-VALIDATING"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained Capture draft and initiating control. The handoff starts from Capture composer explicit state contract / Validating; effect: No durable mutation occurs and no Receipt is created; optional work stops while original text, attachments, type, and accepted metadata remain unchanged; Capture composer explicit state contract / Validating reports the outcome from this visible condition: Ambitions is checking the proposed Capture type and fields; entered text stays visible; this command preserves accepted product state; focus: the initiating composer control within Capture composer explicit state contract / Validating."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; optional work stops while original text, attachments, type, and accepted metadata remain unchanged. The durable boundary is specific to this visible evidence: Ambitions is checking the proposed Capture type and fields; entered text stays visible."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Ambitions is checking the proposed Capture type and fields; entered text stays visible."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Ambitions is checking the proposed Capture type and fields; entered text stays visible."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating composer control; rejection focuses the in-progress status and Cancel control. The announcement includes this user-facing evidence before focus moves: Ambitions is checking the proposed Capture type and fields; entered text stays visible."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-COMPOSER-VALIDATING-001"
label = "Cancel"
canonical_owner = "global.capture.command-contract"
preconditions = ["Only optional attachment, validation, classification, or proposal work is in progress"]
destination = "the retained Capture draft and initiating control. The handoff starts from Capture composer explicit state contract / Validating"
destination_id = "DEST-CAPTURE-COMPOSER-VALIDATING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; optional work stops while original text, attachments, type, and accepted metadata remain unchanged; Capture composer explicit state contract / Validating reports the outcome from this visible condition: Ambitions is checking the proposed Capture type and fields; entered text stays visible; this command preserves accepted product state"
success_focus = "the initiating composer control within Capture composer explicit state contract / Validating"
success_focus_id = "FOCUS-CAPTURE-COMPOSER-VALIDATING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the in-progress status and Cancel control while Capture composer explicit state contract / Validating remains visible"
failure_focus_id = "FOCUS-CAPTURE-COMPOSER-VALIDATING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-COMPOSER-VALIDATING-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-PROPOSAL-CLASSIFYING"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained Capture draft and initiating control. The handoff starts from Capture proposal and placement explicit state contract / Classifying; effect: No durable mutation occurs and no Receipt is created; optional work stops while original text, attachments, type, and accepted metadata remain unchanged; Capture proposal and placement explicit state contract / Classifying reports the outcome from this visible condition: Ambitions is identifying the Capture type while the original words remain visible; this command preserves accepted product state; focus: the initiating composer control within Capture proposal and placement explicit state contract / Classifying."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; optional work stops while original text, attachments, type, and accepted metadata remain unchanged. The durable boundary is specific to this visible evidence: Ambitions is identifying the Capture type while the original words remain visible."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Ambitions is identifying the Capture type while the original words remain visible."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Ambitions is identifying the Capture type while the original words remain visible."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating composer control; rejection focuses the in-progress status and Cancel control. The announcement includes this user-facing evidence before focus moves: Ambitions is identifying the Capture type while the original words remain visible."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-PROPOSAL-CLASSIFYING-001"
label = "Cancel"
canonical_owner = "global.capture.command-contract"
preconditions = ["Only optional attachment, validation, classification, or proposal work is in progress"]
destination = "the retained Capture draft and initiating control. The handoff starts from Capture proposal and placement explicit state contract / Classifying"
destination_id = "DEST-CAPTURE-PROPOSAL-CLASSIFYING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; optional work stops while original text, attachments, type, and accepted metadata remain unchanged; Capture proposal and placement explicit state contract / Classifying reports the outcome from this visible condition: Ambitions is identifying the Capture type while the original words remain visible; this command preserves accepted product state"
success_focus = "the initiating composer control within Capture proposal and placement explicit state contract / Classifying"
success_focus_id = "FOCUS-CAPTURE-PROPOSAL-CLASSIFYING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the in-progress status and Cancel control while Capture proposal and placement explicit state contract / Classifying remains visible"
failure_focus_id = "FOCUS-CAPTURE-PROPOSAL-CLASSIFYING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-PROPOSAL-CLASSIFYING-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-PROPOSAL-FIT-PROPOSING"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture proposal and placement explicit state contract / Fit Proposing; effect: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture proposal and placement explicit state contract / Fit Proposing reports the outcome from this visible condition: A possible object and time fit is being prepared for review, not yet saved; focus: the next unresolved proposal or placement field within Capture proposal and placement explicit state contract / Fit Proposing."
durable_effect = "Exact command consequences: Continue: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination. The durable boundary is specific to this visible evidence: A possible object and time fit is being prepared for review, not yet saved."
recovery_rollback = "Exact rollback and recovery: Continue: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A possible object and time fit is being prepared for review, not yet saved."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: A possible object and time fit is being prepared for review, not yet saved."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence, then success focuses the next unresolved proposal or placement field; rejection focuses the Continue control and exact blocking field. The announcement includes this user-facing evidence before focus moves: A possible object and time fit is being prepared for review, not yet saved."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-PROPOSAL-FIT-PROPOSING-001"
label = "Continue"
canonical_owner = "global.capture.command-contract"
preconditions = ["The current draft revision, chosen type, attachments, and proposal are retained"]
destination = "the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture proposal and placement explicit state contract / Fit Proposing"
destination_id = "DEST-CAPTURE-PROPOSAL-FIT-PROPOSING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture proposal and placement explicit state contract / Fit Proposing reports the outcome from this visible condition: A possible object and time fit is being prepared for review, not yet saved"
success_focus = "the next unresolved proposal or placement field within Capture proposal and placement explicit state contract / Fit Proposing"
success_focus_id = "FOCUS-CAPTURE-PROPOSAL-FIT-PROPOSING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact blocking field while Capture proposal and placement explicit state contract / Fit Proposing remains visible"
failure_focus_id = "FOCUS-CAPTURE-PROPOSAL-FIT-PROPOSING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-PROPOSAL-FIT-PROPOSING-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-PROPOSAL-PROPOSAL-CONFLICT"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: the typed Capture proposal choice review. The handoff starts from Capture proposal and placement explicit state contract / Proposal Conflict; effect: No durable mutation occurs and no Receipt is created; Goal, Step, Reminder, Event, Proof, Note, and Save for Later choices show exact consequences; selection changes only the draft proposal and does not commit an object; Capture proposal and placement explicit state contract / Proposal Conflict reports the outcome from this visible condition: The proposal crosses a protected or fixed boundary; both the conflict and original intent are visible; focus: the current proposed type and its consequence within Capture proposal and placement explicit state contract / Proposal Conflict."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; Goal, Step, Reminder, Event, Proof, Note, and Save for Later choices show exact consequences; selection changes only the draft proposal and does not commit an object. The durable boundary is specific to this visible evidence: The proposal crosses a protected or fixed boundary; both the conflict and original intent are visible."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The proposal crosses a protected or fixed boundary; both the conflict and original intent are visible."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: The proposal crosses a protected or fixed boundary; both the conflict and original intent are visible."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the current proposed type and its consequence; rejection focuses the proposal conflict and Review control. The announcement includes this user-facing evidence before focus moves: The proposal crosses a protected or fixed boundary; both the conflict and original intent are visible."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-PROPOSAL-PROPOSAL-CONFLICT-001"
label = "Review"
canonical_owner = "global.capture.command-contract"
preconditions = ["The current draft proposal, chosen type, and draft revision are retained"]
destination = "the typed Capture proposal choice review. The handoff starts from Capture proposal and placement explicit state contract / Proposal Conflict"
destination_id = "DEST-CAPTURE-PROPOSAL-PROPOSAL-CONFLICT-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Goal, Step, Reminder, Event, Proof, Note, and Save for Later choices show exact consequences; selection changes only the draft proposal and does not commit an object; Capture proposal and placement explicit state contract / Proposal Conflict reports the outcome from this visible condition: The proposal crosses a protected or fixed boundary; both the conflict and original intent are visible"
success_focus = "the current proposed type and its consequence within Capture proposal and placement explicit state contract / Proposal Conflict"
success_focus_id = "FOCUS-CAPTURE-PROPOSAL-PROPOSAL-CONFLICT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the proposal conflict and Review control while Capture proposal and placement explicit state contract / Proposal Conflict remains visible"
failure_focus_id = "FOCUS-CAPTURE-PROPOSAL-PROPOSAL-CONFLICT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-PROPOSAL-PROPOSAL-CONFLICT-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-PROPOSAL-PROPOSAL-READY"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture proposal and placement explicit state contract / Proposal Ready; effect: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture proposal and placement explicit state contract / Proposal Ready reports the outcome from this visible condition: The proposed item, placement, conflicts, and Proof expectation are shown before Confirm; focus: the next unresolved proposal or placement field within Capture proposal and placement explicit state contract / Proposal Ready."
durable_effect = "Exact command consequences: Continue: No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination. The durable boundary is specific to this visible evidence: The proposed item, placement, conflicts, and Proof expectation are shown before Confirm."
recovery_rollback = "Exact rollback and recovery: Continue: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The proposed item, placement, conflicts, and Proof expectation are shown before Confirm."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: The proposed item, placement, conflicts, and Proof expectation are shown before Confirm."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence, then success focuses the next unresolved proposal or placement field; rejection focuses the Continue control and exact blocking field. The announcement includes this user-facing evidence before focus moves: The proposed item, placement, conflicts, and Proof expectation are shown before Confirm."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-PROPOSAL-PROPOSAL-READY-001"
label = "Continue"
canonical_owner = "global.capture.command-contract"
preconditions = ["The current draft revision, chosen type, attachments, and proposal are retained"]
destination = "the next typed proposal, placement, or canonical-owner consequence review. The handoff starts from Capture proposal and placement explicit state contract / Proposal Ready"
destination_id = "DEST-CAPTURE-PROPOSAL-PROPOSAL-READY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the flow advances without committing an object; Back or Cancel preserves the draft and final mutation remains owned by the canonical destination; Capture proposal and placement explicit state contract / Proposal Ready reports the outcome from this visible condition: The proposed item, placement, conflicts, and Proof expectation are shown before Confirm"
success_focus = "the next unresolved proposal or placement field within Capture proposal and placement explicit state contract / Proposal Ready"
success_focus_id = "FOCUS-CAPTURE-PROPOSAL-PROPOSAL-READY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact blocking field while Capture proposal and placement explicit state contract / Proposal Ready remains visible"
failure_focus_id = "FOCUS-CAPTURE-PROPOSAL-PROPOSAL-READY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-PROPOSAL-PROPOSAL-READY-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-CAPTURE-SAVED-FOR-LATER-SAVED-FOR-LATER"
requirement_id = "SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "View all saved for later => destination: the Saved for Later collection. The handoff starts from Saved for Later explicit state contract / Saved For Later; effect: No durable mutation occurs and no Receipt is created; the committed draft list opens without promoting, reclassifying, or mutating any draft; Saved for Later explicit state contract / Saved For Later reports the outcome from this visible condition: Saved for later. This draft does not yet appear as a Goal, Step, Reminder, Event, Proof, or Note; focus: the saved draft row within Saved for Later explicit state contract / Saved For Later."
durable_effect = "Exact command consequences: View all saved for later: No durable mutation occurs and no Receipt is created; the committed draft list opens without promoting, reclassifying, or mutating any draft. The durable boundary is specific to this visible evidence: Saved for later. This draft does not yet appear as a Goal, Step, Reminder, Event, Proof, or Note."
recovery_rollback = "Exact rollback and recovery: View all saved for later: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Saved for later. This draft does not yet appear as a Goal, Step, Reminder, Event, Proof, or Note."
offline_behavior = "Capture draft text, checkpoints, proposals, attachments, routing, save, and Undo remain local/offline; system pickers or permissions are explicit handoffs and never gate the retained draft. Offline rendering retains this state evidence: Saved for later. This draft does not yet appear as a Goal, Step, Reminder, Event, Proof, or Note."
accessibility_focus = "VoiceOver focus contract: View all saved for later announces its consequence, then success focuses the saved draft row; rejection focuses the View all saved for later control. The announcement includes this user-facing evidence before focus moves: Saved for later. This draft does not yet appear as a Goal, Step, Reminder, Event, Proof, or Note."

[[state_command_contracts.commands]]
command_id = "CMD-CAPTURE-SAVED-FOR-LATER-SAVED-FOR-LATER-001"
label = "View all saved for later"
canonical_owner = "global.capture.command-contract"
preconditions = ["The Saved for Later draft committed durably"]
destination = "the Saved for Later collection. The handoff starts from Saved for Later explicit state contract / Saved For Later"
destination_id = "DEST-CAPTURE-SAVED-FOR-LATER-SAVED-FOR-LATER-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the committed draft list opens without promoting, reclassifying, or mutating any draft; Saved for Later explicit state contract / Saved For Later reports the outcome from this visible condition: Saved for later. This draft does not yet appear as a Goal, Step, Reminder, Event, Proof, or Note"
success_focus = "the saved draft row within Saved for Later explicit state contract / Saved For Later"
success_focus_id = "FOCUS-CAPTURE-SAVED-FOR-LATER-SAVED-FOR-LATER-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the View all saved for later control while Saved for Later explicit state contract / Saved For Later remains visible"
failure_focus_id = "FOCUS-CAPTURE-SAVED-FOR-LATER-SAVED-FOR-LATER-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-CAPTURE-SAVED-FOR-LATER-SAVED-FOR-LATER-001"
recovery_posture = "current"
recovery_owner = "global.capture.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001"]
+++

# Capture

Capture uses `surface-v1` because it presents a full-screen, user-operated composer with first-viewport, presentation, state, accessibility, and visual contracts. It remains a global overlay, not a root or tab.

## SPEC-GLOBAL-CAPTURE-IDENTITY-001 — Global durable composer

- **Concept:** `global.capture.identity`
- **Modality:** `MUST`
- **Scope:** Capture presentation and intake boundary
- **Status:** `normative`
- **Verification:** `SCENARIO-CAPTURE-IDENTITY-001`
- **Supersedes:** none

Capture MUST be a global full-screen temporary composer that preserves intent,
performs only capability-backed bounded interpretation, previews material
consequences, and transfers accepted proposals to canonical owners. A Search
creation-intent handoff preserves accepted source context and user-entered
intent. Capture owns the session draft, correction, proposal, origin, and
handoff; the destination owner revalidates and alone commits canonical data.
Capture MUST NOT become a root, tab, half-sheet quick box, inbox, category wall,
chatbot, notes feed, or permanent floating control.

The approved current baseline is full-screen text input, deterministic bounded
extraction, simple time extraction, destination proposal, Accept, Change,
Cancel, proven Quick Capture creation, and proven Capture-to-Goal handoff.

Capture SHOULD NOT primarily be a bottom floating composer.

Capture MUST show only destination routes proven by the owner capability
registry. A Goal, Step, Reminder, Event, Proof, Note, attachment, or Saved for
Later type is hidden when its owner acceptance and settlement path is unproven.

Capture MUST use a global typed route graph and a full-screen Stage composer instead of a tab, inbox, or note feed.

Simple captures MUST save quickly.

## SPEC-GLOBAL-CAPTURE-KEYBOARD-001 — Composer remains primary with keyboard present

- **Concept:** `global.capture.keyboard`
- **Modality:** `MUST`
- **Scope:** Keyboard, dictation, attachment, and focus presentation
- **Status:** `normative`
- **Verification:** `PROOF-CAPTURE-KEYBOARD-001`
- **Supersedes:** none

Keyboard presentation MUST preserve the text field, supported type/destination
override, primary continue action, cancellation, validation feedback, and safe-
area clearance without shrinking Capture into a utility sheet. Hardware
keyboard, Switch Control, and VoiceOver provide equivalent entry and focus
behavior. Dictation is not a current Capture capability.

The Capture field MUST rise above the keyboard, expand cleanly, and then scroll internally.

## SPEC-GLOBAL-CAPTURE-SAVED-FOR-LATER-001 — Unresolved state, never destination

- **Concept:** `global.capture.saved-for-later`
- **Modality:** `MUST`
- **Scope:** Durable unresolved intake
- **Status:** `normative`
- **Verification:** `SCENARIO-CAPTURE-SAVED-LATER-001`
- **Supersedes:** none

Saved for Later MUST remain a durable, searchable, locally recoverable unresolved state with explicit promotion. It MUST NOT become a Capture inbox, root, Today backlog, or persistent destination. Only explicit scheduling/promotion or one earned fit suggestion may bring it into active execution.

Save for Later bypasses the proposal wizard, stores the current input and attachments durably, then MUST show a confirmation with View All Saved for Later or Okay.

## SPEC-GLOBAL-CAPTURE-DRAFT-RECOVERY-001 — Original input survives every branch

- **Concept:** `global.capture.draft-recovery`
- **Modality:** `MUST`
- **Scope:** Interruption, crash, denial, attachment, validation, routing, and discard
- **Status:** `normative`
- **Verification:** `SCENARIO-CAPTURE-DRAFT-RECOVERY-001`
- **Supersedes:** none

The original expression and unaffected interpretation MUST survive every
in-session correction and owner handoff. Durable draft recovery across crash or
relaunch is optional and MUST NOT be promised until an owning draft store,
retention/deletion policy, migration, restoration, privacy behavior, and proof
exist. Exact cursor, field-focus, and keyboard restoration remain best effort.

## SPEC-GLOBAL-CAPTURE-PROPOSAL-FLOW-001 — Adaptive complexity without interrogation

- **Concept:** `global.capture.proposal-flow`
- **Modality:** `MUST`
- **Scope:** Classification, metadata, placement, conflict, confirmation, and receipt
- **Status:** `normative`
- **Verification:** `SCENARIO-CAPTURE-PROPOSAL-001`
- **Supersedes:** none

Simple supported input MUST prepare quickly. Complexity introduces only the
supported destination, simple time, ambiguity correction, consequence,
confirmation, and owner handoff steps. Interpretation is visible, editable,
deterministic, bounded, and local. Material interpretation never commits
silently.

Only proven Quick Capture and Capture-to-Goal paths are current baseline.
Additional destinations require capability proof before they appear.

The Capture proposal flow MUST use native controls, preserve its draft locally, and provide reversible navigation.

Events, Reminders, Steps, Goals, and Proof MUST each expose controls relevant to that object type.

Capture may propose a destination or simple time only within implemented rules.
It MUST NOT claim arbitrary semantic understanding, universal conflict
detection, coordinated multi-root mutation, partial settlement, or
Capture-specific Undo.

## SPEC-GLOBAL-CAPTURE-VISUAL-AUTHORITY-001 — Provisional Capture revision and implementation boundary

- **Concept:** `global.capture.visual-authority`
- **Modality:** `MUST`
- **Scope:** Full-screen composer visual authority
- **Status:** `normative`
- **Verification:** `PROOF-CAPTURE-VISUAL-MAPPING-001`
- **Supersedes:** none

Visual review MUST keep owner-authorized provisional direction distinct from
historical package provenance and current implementation. `AVF-CAPTURE-S07-R01
— Bounded Adaptive Meaning Fold` is the current provisional direction. The
earlier VSP-05 package remains historical and establishes no current SwiftUI,
accessibility, device, runtime, or Figma approval.

## SPEC-GLOBAL-CAPTURE-CLASSIFICATION-001 — Capture classification

- **Concept:** `global.capture.classification`
- **Modality:** `MUST`
- **Scope:** Captured drafts
- **Status:** `normative`
- **Verification:** `TEST-CAPTURE-CLASSIFICATION-001`
- **Supersedes:** none

Capture classification MUST remain local, inspectable, reversible, and nonmutating until the user accepts a typed proposal.

## SPEC-GLOBAL-CAPTURE-ATTACHMENT-INTAKE-001 — Capture attachment intake

- **Concept:** `global.capture.attachment-intake`
- **Modality:** `MUST`
- **Scope:** Capture attachments
- **Status:** `normative`
- **Verification:** `TEST-CAPTURE-ATTACHMENT-INTAKE-001`
- **Supersedes:** none

Attachment intake is absent from the current baseline except for individually
proven external/share routes. Any future adapter MUST preserve original bytes
and draft linkage, stream within bounded resources, disclose per-attachment
failure, remain local by default, and pass capability/privacy proof before its
control appears.

## SPEC-GLOBAL-CAPTURE-COMMAND-CONTRACT-001 — Exact state command ownership

- **Concept:** `global.capture.command-contract`
- **Modality:** `MUST`
- **Scope:** Structured state command contracts for this specification
- **Status:** `normative`
- **Verification:** `SCENARIO-GLOBAL-CAPTURE-COMMAND-CONTRACT-001`
- **Supersedes:** none

Structured state contracts describe the maximum named design inventory; they do
not activate a capability. The current baseline exposes only Cancel, Change,
Continue/Accept, and the proven destination-owner result actions. Every active
command MUST bind stable session/object identity, revision, owner, preconditions,
destination, consequence, and focus targets. Capture cannot commit a destination
mutation; owner handoff follows the shared mutation lifecycle. Receipt and Undo
appear only when the destination owner’s registry proves them. VoiceOver
announces interpretation, correction, owner destination, accepted/rejected
result, consequence, recovery, and focus without relying on color, motion,
gesture, or position.

## Completeness contract

<!-- canon-section: purpose-user-question -->
Capture answers how to place meaningful input somewhere safe, understand only necessary consequences, and turn accepted intent into a real canonical object without losing the original.

<!-- canon-section: entry-exit -->
Entry comes from integrated shell create, contextual creation, Share/deep link, or draft recovery. Dismissal returns to exact root/depth/focus; successful save returns with confirmation and route option; unresolved save remains reachable without a destination.

<!-- canon-section: routes-presentation -->
Capture is full-screen non-root presentation. Type/detail/proposal/review stages remain inside one recoverable composer flow. Permission and attachment pickers are contextual system presentations; canonical object detail opens only after accepted save.

<!-- canon-section: displayed-objects -->
The draft, text, visible type, attachments, metadata, destination, schedule proposal, alternatives, conflict/consequence summary, confirmation state, and save result are presented. Internal classifier/runtime structures remain hidden.

<!-- canon-section: resting-states -->
The composer state machine identifies content, interpretation, attachment, proposal, confirmation, persistence, and recovery phases.
Required states are blank, composing, typed, attachment-ready, proposal-ready, confirmation-required, Saved for Later, saved, recovered, and explicit-discard review.

<!-- canon-section: loading-transitional -->
Dictation, scan/import, attachment processing, classification, fit proposal, validation, routing, save, and restoration expose bounded progress/cancellation while preserving draft text and prior valid state.

<!-- canon-section: empty-degraded -->
Blank is useful and never an interrogation. Denied permission, offline, failed attachment, ambiguous type, invalid metadata, conflict, partial routing, and degraded store preserve input and offer edit, remove/replace attachment, retry, save unresolved, export, or cancel safely.

<!-- canon-section: commands-actions -->
The action set maps each visible control to a typed composer or canonical-owner command.
Enter, dictate, attach, choose type, edit metadata, review proposal, choose alternative, confirm consequence, save, Save for Later, retry, remove/replace attachment, discard, and undo use explicit actions. No gesture or spatial arrangement is required.

<!-- canon-section: durable-effects -->
Durable state separates draft persistence, accepted object mutation, attachment result, unresolved promotion, and receipt history.
Draft persistence precedes optional processing. Accepted save routes one validated command to the canonical owner and yields event, projections, receipt, replay, and attachment result. Saved for Later retains unresolved identity and promotion history.

<!-- canon-section: failure-rollback -->
Validation or routing rejection leaves the draft intact. Partial attachment or external failure records per-part status. Retry is idempotent; undo reverses safe accepted creation through canonical history; discard is explicit and never inferred from dismissal.

<!-- canon-section: offline -->
Local capability covers composition, classification, persistence, routing, receipt creation, and replay.
Text, deterministic core classification, type override, draft recovery, Saved for Later, local attachments, canonical local save, receipt, and replay work without account/network. Optional reference assistance can fail without blocking save.

<!-- canon-section: privacy-data-classification -->
Drafts, text, attachments, inferred type, context, constraints, and proposals are private local data. Camera/Photos/Files/voice permissions are contextual. No draft/private context goes to Account, R2, Source Atlas, or hosted AI; export/share is explicit and previewed.

<!-- canon-section: accessibility-reading-order -->
VoiceOver orders close/context, composer, type, attachments, proposal/consequences, alternatives, primary action, and recovery. Every attachment and proposal state has label/value/actions; validation focus moves to the exact issue; keyboard/dictation and non-spatial actions have parity.

<!-- canon-section: dynamic-type -->
Composer, type, attachments, consequences, and actions reflow vertically above keyboard with scroll-to-focus and no obscured input, clipped consequence, or hidden dismissal.

<!-- canon-section: reduce-motion -->
Stage transitions, classification changes, attachment progress, and proposal expansion use immediate state changes or restrained fades while retaining announcements and focus.

<!-- canon-section: reduce-transparency -->
Composer materials become opaque semantic surfaces with equivalent hierarchy, keyboard separation, attachment state, validation, and contrast.

<!-- canon-section: copy-state-language -->
Composer vocabulary names the object, proposal, consequence, persistence choice, and recovery action directly.
Use Capture, Goal, Step, Reminder, Event, Proof, Note, Save for Later, Review, and Undo. Avoid chatbot prompts, AI confidence, runtime language, shame, or false saved-success copy.

<!-- canon-section: visual-authority -->
The named package controls geometry, hierarchy, composition, states, and adaptive layout.
Stable package ID `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:217:93` supplies the selected Capture design direction. Draft/runtime behavior, source rendering, accessibility, and device behavior remain separately testable.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Composer/Capture/` owns presentation; `Core/LocalRuntimeOS/CaptureRouting/` owns durable intake/classification/routing; `Commands/` owns accepted mutation; `Inspection/` owns receipts/history; `Quality/` owns validation.

<!-- canon-section: tests -->
Tests cover simple/complex proposals, type correction, draft persistence across every failure, Saved for Later reachability/promotion, attachment per-part failure, conflict confirmation, idempotent save, undo/replay, offline, privacy denial, keyboard/focus, VoiceOver actions/order, Dynamic Type, reduced effects, contrast, and return context.

<!-- canon-section: proof -->
Applicable validation includes crash/interruption recovery, attachment/permission failure fixtures, command/receipt/replay tests, rendered-state and keyboard matrices, accessibility checks, privacy-boundary tests, visual comparison, and rollback.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Capture draft restoration, classification, proposal, attachment streaming, and local save acknowledgement MUST remain bounded and cancellable, use bounded media buffers, perform no core-path network gating or interaction-path synchronous disk I/O, use no polling or unbounded background loop, and preserve original input under resource pressure. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. The implementation must define and test a performance-budget record declaring device floor, OS, build configuration, representative draft/attachment/proposal data scale, warm/cold state, measurement tool, percentile/maximum, memory and storage-pressure measures, and regression threshold.

## SPEC-GLOBAL-CAPTURE-CLOSE-BEHAVIOR-001 — Capture close behavior

- **Concept:** `global.capture.close-behavior`
- **Modality:** `MUST`
- **Scope:** Capture close behavior
- **Status:** `normative`
- **Verification:** `REVIEW-SPEC-GLOBAL-CAPTURE-CLOSE-BEHAVIOR-001`
- **Supersedes:** none

Save for Later MUST commit durably, show `View all saved for later` and `Okay`, and close on `Okay`; Step, Goal, Reminder, Event, Proof, and Note saves MUST continue through proposal.
