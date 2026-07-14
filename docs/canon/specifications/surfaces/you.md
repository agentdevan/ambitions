+++
spec_id = "SURFACE-YOU"
title = "You"
kind = "surface"
status = "normative"
owner_domain = "surface-you"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "surface.you.appearance",
  "surface.you.command-contract",
  "surface.you.contextual-education",
  "surface.you.data-controls",
  "surface.you.depth",
  "surface.you.first-viewport",
  "surface.you.identity",
  "surface.you.no-knowledge-model",
  "surface.you.privacy-data-boundary",
  "surface.you.profile",
  "surface.you.screen-inventory",
  "surface.you.settings-drilldown",
  "surface.you.time-preferences",
  "surface.you.visual-authority",
]
inherits = [
  "CONST-IA-ROOT-001",
  "SURFACE-YOU-DEPTH-001",
  "LAW-ACCOUNT-BOUNDARY-001",
  "LAW-OFFLINE-NO-ACCOUNT-001",
  "PRIVACY-VISIBILITY-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION", "APP-PERMISSIONS"]
source_owners = [
  "Native/Ambitions/Surfaces/You/",
  "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/",
  "Native/Ambitions/Core/LocalRuntimeOS/Continuity/",
  "Native/Ambitions/Core/LocalRuntimeOS/Inspection/",
  "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/",
  "Native/Ambitions/Diagnostics/",
  "Native/Ambitions/Quality/",
]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-BACKUP-READY"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Create Backup => destination: the backup verification status and backup Receipt. The handoff starts from Data and Storage explicit state contract / Backup Ready; effect: The typed verified local backup creation command appends an Event, updates the Projection, and creates a Receipt and History; the artifact is created, integrity/schema/restorability are verified, and only then is it designated a recovery point; Data and Storage explicit state contract / Backup Ready reports the outcome from this visible condition: An encrypted backup file is ready with its included scope shown. Saved information in Ambitions is unchanged; focus: the verified backup status and Receipt within Data and Storage explicit state contract / Backup Ready."
durable_effect = "Exact command consequences: Create Backup: The typed verified local backup creation command appends an Event, updates the Projection, and creates a Receipt and History; the artifact is created, integrity/schema/restorability are verified, and only then is it designated a recovery point. The durable boundary is specific to this visible evidence: An encrypted backup file is ready with its included scope shown. Saved information in Ambitions is unchanged."
recovery_rollback = "Exact rollback and recovery: Create Backup: Cancellation before recovery-point designation leaves no recovery-point claim; an incomplete artifact is quarantined and the active store remains unchanged. Recovery preserves or restores the interface evidence that says: An encrypted backup file is ready with its included scope shown. Saved information in Ambitions is unchanged."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: An encrypted backup file is ready with its included scope shown. Saved information in Ambitions is unchanged."
accessibility_focus = "VoiceOver focus contract: Create Backup announces its consequence, then success focuses the verified backup status and Receipt; rejection focuses the Create Backup control and failed verification reason. The announcement includes this user-facing evidence before focus moves: An encrypted backup file is ready with its included scope shown. Saved information in Ambitions is unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-BACKUP-READY-001"
label = "Create Backup"
canonical_owner = "surface.you.command-contract"
preconditions = ["Backup scope, storage destination, schema, capacity, and current local revision are reviewed"]
destination = "the backup verification status and backup Receipt. The handoff starts from Data and Storage explicit state contract / Backup Ready"
effect = "The typed verified local backup creation command appends an Event, updates the Projection, and creates a Receipt and History; the artifact is created, integrity/schema/restorability are verified, and only then is it designated a recovery point; Data and Storage explicit state contract / Backup Ready reports the outcome from this visible condition: An encrypted backup file is ready with its included scope shown. Saved information in Ambitions is unchanged"
success_focus = "the verified backup status and Receipt within Data and Storage explicit state contract / Backup Ready"
failure_focus = "the Create Backup control and failed verification reason while Data and Storage explicit state contract / Backup Ready remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before recovery-point designation leaves no recovery-point claim; an incomplete artifact is quarantined and the active store remains unchanged."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-DIAGNOSTICS-REDACTED"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open diagnostics => destination: the focused redacted diagnostics detail from You. The handoff starts from Data and Storage explicit state contract / Diagnostics Redacted; effect: No durable mutation occurs and no Receipt is created; local health and bounded recovery information are shown with no private titles / content and no authoritative product claim; Data and Storage explicit state contract / Diagnostics Redacted reports the outcome from this visible condition: Diagnostics are redacted before export; private life content and sensitive identifiers remain excluded; focus: the diagnostic summary within Data and Storage explicit state contract / Diagnostics Redacted."
durable_effect = "Exact command consequences: Open diagnostics: No durable mutation occurs and no Receipt is created; local health and bounded recovery information are shown with no private titles or content and no authoritative product claim. The durable boundary is specific to this visible evidence: Diagnostics are redacted before export; private life content and sensitive identifiers remain excluded."
recovery_rollback = "Exact rollback and recovery: Open diagnostics: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Diagnostics are redacted before export; private life content and sensitive identifiers remain excluded."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Diagnostics are redacted before export; private life content and sensitive identifiers remain excluded."
accessibility_focus = "VoiceOver focus contract: Open diagnostics announces its consequence, then success focuses the diagnostic summary; rejection focuses the Open diagnostics control. The announcement includes this user-facing evidence before focus moves: Diagnostics are redacted before export; private life content and sensitive identifiers remain excluded."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-DIAGNOSTICS-REDACTED-001"
label = "Open diagnostics"
canonical_owner = "surface.you.command-contract"
preconditions = ["A redacted diagnostics scope is available"]
destination = "the focused redacted diagnostics detail from You. The handoff starts from Data and Storage explicit state contract / Diagnostics Redacted"
effect = "No durable mutation occurs and no Receipt is created; local health and bounded recovery information are shown with no private titles / content and no authoritative product claim; Data and Storage explicit state contract / Diagnostics Redacted reports the outcome from this visible condition: Diagnostics are redacted before export; private life content and sensitive identifiers remain excluded"
success_focus = "the diagnostic summary within Data and Storage explicit state contract / Diagnostics Redacted"
failure_focus = "the Open diagnostics control while Data and Storage explicit state contract / Diagnostics Redacted remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "Diagnostics default to redacted local health metadata; no private titles or content leave the device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-EXPORT-FAILED"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Try again => destination: the export generation status. The handoff starts from Data and Storage explicit state contract / Export Failed; effect: No local canonical mutation is replayed; only failed artifact generation is retried; no successful export Receipt is created until the artifact completes; Data and Storage explicit state contract / Export Failed reports the outcome from this visible condition: The file could not be created. Saved information is unchanged, and no incomplete file is offered; focus: the generated export status and egress Receipt within Data and Storage explicit state contract / Export Failed."
durable_effect = "Exact command consequences: Try again: No local canonical mutation is replayed; only failed artifact generation is retried; no successful export Receipt is created until the artifact completes. The durable boundary is specific to this visible evidence: The file could not be created. Saved information is unchanged, and no incomplete file is offered."
recovery_rollback = "Exact rollback and recovery: Try again: Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command. Recovery preserves or restores the interface evidence that says: The file could not be created. Saved information is unchanged, and no incomplete file is offered."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: The file could not be created. Saved information is unchanged, and no incomplete file is offered."
accessibility_focus = "VoiceOver focus contract: Try again announces its consequence, then success focuses the generated export status and egress Receipt; rejection focuses the export failure reason and Try again control. The announcement includes this user-facing evidence before focus moves: The file could not be created. Saved information is unchanged, and no incomplete file is offered."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-EXPORT-FAILED-001"
label = "Try again"
canonical_owner = "surface.you.command-contract"
preconditions = ["The failed export attempt, current export scope, destination, and local revision are retained"]
destination = "the export generation status. The handoff starts from Data and Storage explicit state contract / Export Failed"
effect = "No local canonical mutation is replayed; only failed artifact generation is retried; no successful export Receipt is created until the artifact completes; Data and Storage explicit state contract / Export Failed reports the outcome from this visible condition: The file could not be created. Saved information is unchanged, and no incomplete file is offered"
success_focus = "the generated export status and egress Receipt within Data and Storage explicit state contract / Export Failed"
failure_focus = "the export failure reason and Try again control while Data and Storage explicit state contract / Export Failed remains visible"
commit_boundary = "External-result: the existing durable result or outbox identity is revalidated before only the failed external/read operation runs; the accepted local Event is never replayed."
rollback_undo = "Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command."
privacy_egress = "Only the previously approved minimum payload may leave the device; authorization and SYSTEM-PRIVACY-EGRESS-001 are revalidated and failure remains inspectable."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-EXPORT-PREVIEW"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Export Data => destination: the export generation result and egress Receipt. The handoff starts from Data and Storage explicit state contract / Export Preview; effect: The typed data export command appends an Event, updates the Projection, and creates a Receipt and History; the approved artifact is generated for the chosen destination and durable egress Receipt/History metadata records scope, format, and result; Data and Storage explicit state contract / Export Preview reports the outcome from this visible condition: The proposed file contents and redactions are visible. No file has been created, and saved information is unchanged; focus: the export result and egress Receipt within Data and Storage explicit state contract / Export Preview."
durable_effect = "Exact command consequences: Export Data: The typed data export command appends an Event, updates the Projection, and creates a Receipt and History; the approved artifact is generated for the chosen destination and durable egress Receipt/History metadata records scope, format, and result. The durable boundary is specific to this visible evidence: The proposed file contents and redactions are visible. No file has been created, and saved information is unchanged."
recovery_rollback = "Exact rollback and recovery: Export Data: Cancellation before successful generation creates no success claim; after success, dismissal cannot erase the artifact result or egress History and export is not a backup. Recovery preserves or restores the interface evidence that says: The proposed file contents and redactions are visible. No file has been created, and saved information is unchanged."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: The proposed file contents and redactions are visible. No file has been created, and saved information is unchanged."
accessibility_focus = "VoiceOver focus contract: Export Data announces its consequence, then success focuses the export result and egress Receipt; rejection focuses the exact export field or confirmation control. The announcement includes this user-facing evidence before focus moves: The proposed file contents and redactions are visible. No file has been created, and saved information is unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-EXPORT-PREVIEW-001"
label = "Export Data"
canonical_owner = "surface.you.command-contract"
preconditions = ["Egress confirmation is current", "Full or selective scope, redactions, format, destination, retention consequence, and current revision are explicitly reviewed"]
destination = "the export generation result and egress Receipt. The handoff starts from Data and Storage explicit state contract / Export Preview"
effect = "The typed data export command appends an Event, updates the Projection, and creates a Receipt and History; the approved artifact is generated for the chosen destination and durable egress Receipt/History metadata records scope, format, and result; Data and Storage explicit state contract / Export Preview reports the outcome from this visible condition: The proposed file contents and redactions are visible. No file has been created, and saved information is unchanged"
success_focus = "the export result and egress Receipt within Data and Storage explicit state contract / Export Preview"
failure_focus = "the exact export field or confirmation control while Data and Storage explicit state contract / Export Preview remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before successful generation creates no success claim; after success, dismissal cannot erase the artifact result or egress History and export is not a backup."
privacy_egress = "Only explicitly selected and redacted fields go to the reviewed destination under SYSTEM-PRIVACY-EGRESS-001; export never authorizes ongoing sync."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-EXPORT-PROGRESS"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Export Data => destination: the export generation result and egress Receipt. The handoff starts from Data and Storage explicit state contract / Export Progress; effect: The typed data export command appends an Event, updates the Projection, and creates a Receipt and History; the approved artifact is generated for the chosen destination and durable egress Receipt/History metadata records scope, format, and result; Data and Storage explicit state contract / Export Progress reports the outcome from this visible condition: Creating a local export with the reviewed scope and redactions; focus: the export result and egress Receipt within Data and Storage explicit state contract / Export Progress."
durable_effect = "Exact command consequences: Export Data: The typed data export command appends an Event, updates the Projection, and creates a Receipt and History; the approved artifact is generated for the chosen destination and durable egress Receipt/History metadata records scope, format, and result. The durable boundary is specific to this visible evidence: Creating a local export with the reviewed scope and redactions."
recovery_rollback = "Exact rollback and recovery: Export Data: Cancellation before successful generation creates no success claim; after success, dismissal cannot erase the artifact result or egress History and export is not a backup. Recovery preserves or restores the interface evidence that says: Creating a local export with the reviewed scope and redactions."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Creating a local export with the reviewed scope and redactions."
accessibility_focus = "VoiceOver focus contract: Export Data announces its consequence, then success focuses the export result and egress Receipt; rejection focuses the exact export field or confirmation control. The announcement includes this user-facing evidence before focus moves: Creating a local export with the reviewed scope and redactions."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-EXPORT-PROGRESS-001"
label = "Export Data"
canonical_owner = "surface.you.command-contract"
preconditions = ["Egress confirmation is current", "Full or selective scope, redactions, format, destination, retention consequence, and current revision are explicitly reviewed"]
destination = "the export generation result and egress Receipt. The handoff starts from Data and Storage explicit state contract / Export Progress"
effect = "The typed data export command appends an Event, updates the Projection, and creates a Receipt and History; the approved artifact is generated for the chosen destination and durable egress Receipt/History metadata records scope, format, and result; Data and Storage explicit state contract / Export Progress reports the outcome from this visible condition: Creating a local export with the reviewed scope and redactions"
success_focus = "the export result and egress Receipt within Data and Storage explicit state contract / Export Progress"
failure_focus = "the exact export field or confirmation control while Data and Storage explicit state contract / Export Progress remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before successful generation creates no success claim; after success, dismissal cannot erase the artifact result or egress History and export is not a backup."
privacy_egress = "Only explicitly selected and redacted fields go to the reviewed destination under SYSTEM-PRIVACY-EGRESS-001; export never authorizes ongoing sync."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-PERMANENT-DELETE-IRREVERSIBLE"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Delete local data permanently => destination: the surviving You data root and permanent-deletion Receipt. The handoff starts from Data and Storage explicit state contract / Permanent Delete Irreversible; effect: The typed local private data permanent deletion command appends an Event, updates the Projection, and creates a Receipt and History; the explicitly scoped local data is irreversibly removed after preconditions while unrelated account and retained data stay unchanged; Data and Storage explicit state contract / Permanent Delete Irreversible reports the outcome from this visible condition: Permanent deletion completed and cannot be undone / restored. The receipt identifies the deleted scope without exposing deleted content; focus: the surviving data group heading and irreversible result within Data and Storage explicit state contract / Permanent Delete Irreversible."
durable_effect = "Exact command consequences: Delete local data permanently: The typed local private data permanent deletion command appends an Event, updates the Projection, and creates a Receipt and History; the deletion boundary is irreversible, and the explicitly scoped local data is removed after preconditions while unrelated account and retained data stay unchanged. The durable boundary is specific to this visible evidence: Permanent deletion completed and cannot be undone or restored. The receipt identifies the deleted scope without exposing deleted content."
recovery_rollback = "Exact rollback and recovery: Delete local data permanently: Cancellation before commit changes nothing; after the irreversible boundary no Undo or Restore is promised, and the Receipt records the exact destroyed scope. Recovery preserves or restores the interface evidence that says: Permanent deletion completed and cannot be undone or restored. The receipt identifies the deleted scope without exposing deleted content."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Permanent deletion completed and cannot be undone or restored. The receipt identifies the deleted scope without exposing deleted content."
accessibility_focus = "VoiceOver focus contract: Delete local data permanently announces its consequence, then success focuses the surviving data group heading and irreversible result; rejection focuses the permanent-delete confirmation and unmet precondition. The announcement includes this user-facing evidence before focus moves: Permanent deletion completed and cannot be undone or restored. The receipt identifies the deleted scope without exposing deleted content."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-PERMANENT-DELETE-IRREVERSIBLE-001"
label = "Delete local data permanently"
canonical_owner = "surface.you.command-contract"
preconditions = ["Exact object, private-graph, History, search, export, continuity, and verified-backup consequences are reviewed", "Irreversible confirmation matches the current revision"]
destination = "the surviving You data root and permanent-deletion Receipt. The handoff starts from Data and Storage explicit state contract / Permanent Delete Irreversible"
effect = "The typed local private data permanent deletion command appends an Event, updates the Projection, and creates a Receipt and History; the explicitly scoped local data is irreversibly removed after preconditions while unrelated account and retained data stay unchanged; Data and Storage explicit state contract / Permanent Delete Irreversible reports the outcome from this visible condition: Permanent deletion completed and cannot be undone / restored. The receipt identifies the deleted scope without exposing deleted content"
success_focus = "the surviving data group heading and irreversible result within Data and Storage explicit state contract / Permanent Delete Irreversible"
failure_focus = "the permanent-delete confirmation and unmet precondition while Data and Storage explicit state contract / Permanent Delete Irreversible remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after the irreversible boundary no Undo or Restore is promised, and the Receipt records the exact destroyed scope."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-PERMANENT-DELETE-REVIEW"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Delete local data permanently => destination: the surviving You data root and permanent-deletion Receipt. The handoff starts from Data and Storage explicit state contract / Permanent Delete Review; effect: The typed local private data permanent deletion command appends an Event, updates the Projection, and creates a Receipt and History; the explicitly scoped local data is irreversibly removed after preconditions while unrelated account and retained data stay unchanged; Data and Storage explicit state contract / Permanent Delete Review reports the outcome from this visible condition: The exact information marked for permanent deletion is visible. Nothing has been deleted; focus: the surviving data group heading and irreversible result within Data and Storage explicit state contract / Permanent Delete Review."
durable_effect = "Exact command consequences: Delete local data permanently: The typed local private data permanent deletion command appends an Event, updates the Projection, and creates a Receipt and History; the explicitly scoped local data is irreversibly removed after preconditions while unrelated account and retained data stay unchanged. The durable boundary is specific to this visible evidence: The exact information marked for permanent deletion is visible. Nothing has been deleted."
recovery_rollback = "Exact rollback and recovery: Delete local data permanently: Cancellation before commit changes nothing; after the irreversible boundary no Undo or Restore is promised, and the Receipt records the exact destroyed scope. Recovery preserves or restores the interface evidence that says: The exact information marked for permanent deletion is visible. Nothing has been deleted."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: The exact information marked for permanent deletion is visible. Nothing has been deleted."
accessibility_focus = "VoiceOver focus contract: Delete local data permanently announces its consequence, then success focuses the surviving data group heading and irreversible result; rejection focuses the permanent-delete confirmation and unmet precondition. The announcement includes this user-facing evidence before focus moves: The exact information marked for permanent deletion is visible. Nothing has been deleted."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-PERMANENT-DELETE-REVIEW-001"
label = "Delete local data permanently"
canonical_owner = "surface.you.command-contract"
preconditions = ["Exact object, private-graph, History, search, export, continuity, and verified-backup consequences are reviewed", "Irreversible confirmation matches the current revision"]
destination = "the surviving You data root and permanent-deletion Receipt. The handoff starts from Data and Storage explicit state contract / Permanent Delete Review"
effect = "The typed local private data permanent deletion command appends an Event, updates the Projection, and creates a Receipt and History; the explicitly scoped local data is irreversibly removed after preconditions while unrelated account and retained data stay unchanged; Data and Storage explicit state contract / Permanent Delete Review reports the outcome from this visible condition: The exact information marked for permanent deletion is visible. Nothing has been deleted"
success_focus = "the surviving data group heading and irreversible result within Data and Storage explicit state contract / Permanent Delete Review"
failure_focus = "the permanent-delete confirmation and unmet precondition while Data and Storage explicit state contract / Permanent Delete Review remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after the irreversible boundary no Undo or Restore is promised, and the Receipt records the exact destroyed scope."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-RESET-REVIEW"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Reset preferences => destination: the reset preference values and reset Receipt. The handoff starts from Data and Storage explicit state contract / Reset Review; effect: The typed preference reset command appends an Event, updates the Projection, and creates a Receipt and History; preferences only return to approved defaults; the private graph, learned influences, Goals, Proof, and History remain unchanged; Data and Storage explicit state contract / Reset Review reports the outcome from this visible condition: The preferences marked for reset are visible. Current settings and product data are unchanged; focus: the first reset preference and Receipt within Data and Storage explicit state contract / Reset Review."
durable_effect = "Exact command consequences: Reset preferences: The typed preference reset command appends an Event, updates the Projection, and creates a Receipt and History; preferences only return to approved defaults; the private graph, learned influences, Goals, Proof, and History remain unchanged. The durable boundary is specific to this visible evidence: The preferences marked for reset are visible. Current settings and product data are unchanged."
recovery_rollback = "Exact rollback and recovery: Reset preferences: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: The preferences marked for reset are visible. Current settings and product data are unchanged."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: The preferences marked for reset are visible. Current settings and product data are unchanged."
accessibility_focus = "VoiceOver focus contract: Reset preferences announces its consequence, then success focuses the first reset preference and Receipt; rejection focuses the Reset preferences control and exact retained/affected scope. The announcement includes this user-facing evidence before focus moves: The preferences marked for reset are visible. Current settings and product data are unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-RESET-REVIEW-001"
label = "Reset preferences"
canonical_owner = "surface.you.command-contract"
preconditions = ["Preference scope, retained private graph, learned influences, and current revision are reviewed"]
destination = "the reset preference values and reset Receipt. The handoff starts from Data and Storage explicit state contract / Reset Review"
effect = "The typed preference reset command appends an Event, updates the Projection, and creates a Receipt and History; preferences only return to approved defaults; the private graph, learned influences, Goals, Proof, and History remain unchanged; Data and Storage explicit state contract / Reset Review reports the outcome from this visible condition: The preferences marked for reset are visible. Current settings and product data are unchanged"
success_focus = "the first reset preference and Receipt within Data and Storage explicit state contract / Reset Review"
failure_focus = "the Reset preferences control and exact retained/affected scope while Data and Storage explicit state contract / Reset Review remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-RESET-ROLLBACK"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Reset preferences => destination: the reset preference values and reset Receipt. The handoff starts from Data and Storage explicit state contract / Reset Rollback; effect: The typed preference reset command appends an Event, updates the Projection, and creates a Receipt and History; preferences only return to approved defaults; the private graph, learned influences, Goals, Proof, and History remain unchanged; Data and Storage explicit state contract / Reset Rollback reports the outcome from this visible condition: An earlier set of preferences is recorded. Current product information remains unchanged; focus: the first reset preference and Receipt within Data and Storage explicit state contract / Reset Rollback."
durable_effect = "Exact command consequences: Reset preferences: The typed preference reset command appends an Event, updates the Projection, and creates a Receipt and History; preferences only return to approved defaults; the private graph, learned influences, Goals, Proof, and History remain unchanged. The durable boundary is specific to this visible evidence: An earlier set of preferences is recorded. Current product information remains unchanged."
recovery_rollback = "Exact rollback and recovery: Reset preferences: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: An earlier set of preferences is recorded. Current product information remains unchanged."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: An earlier set of preferences is recorded. Current product information remains unchanged."
accessibility_focus = "VoiceOver focus contract: Reset preferences announces its consequence, then success focuses the first reset preference and Receipt; rejection focuses the Reset preferences control and exact retained/affected scope. The announcement includes this user-facing evidence before focus moves: An earlier set of preferences is recorded. Current product information remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-RESET-ROLLBACK-001"
label = "Reset preferences"
canonical_owner = "surface.you.command-contract"
preconditions = ["Preference scope, retained private graph, learned influences, and current revision are reviewed"]
destination = "the reset preference values and reset Receipt. The handoff starts from Data and Storage explicit state contract / Reset Rollback"
effect = "The typed preference reset command appends an Event, updates the Projection, and creates a Receipt and History; preferences only return to approved defaults; the private graph, learned influences, Goals, Proof, and History remain unchanged; Data and Storage explicit state contract / Reset Rollback reports the outcome from this visible condition: An earlier set of preferences is recorded. Current product information remains unchanged"
success_focus = "the first reset preference and Receipt within Data and Storage explicit state contract / Reset Rollback"
failure_focus = "the Reset preferences control and exact retained/affected scope while Data and Storage explicit state contract / Reset Rollback remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-RESTORE-REVIEW"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Restore Backup => destination: the atomically activated restored store and restore Receipt. The handoff starts from Data and Storage explicit state contract / Restore Review; effect: The typed verified backup restore command appends an Event, updates the Projection, and creates a Receipt and History; the verified backup is staged, projections/replay are rebuilt, integrity is checked, and the restored store activates atomically without unsupported merge; Data and Storage explicit state contract / Restore Review reports the outcome from this visible condition: The backup contents and their destination are visible. Current saved information is unchanged; focus: the restore result and Receipt within Data and Storage explicit state contract / Restore Review."
durable_effect = "Exact command consequences: Restore Backup: The typed verified backup restore command appends an Event, updates the Projection, and creates a Receipt and History; the verified backup is staged, projections/replay are rebuilt, integrity is checked, and the restored store activates atomically without unsupported merge. The durable boundary is specific to this visible evidence: The backup contents and their destination are visible. Current saved information is unchanged."
recovery_rollback = "Exact rollback and recovery: Restore Backup: Failure returns to the last honest store; cancellation before activation changes nothing, and post-activation rollback uses the operation journal without rewriting History. Recovery preserves or restores the interface evidence that says: The backup contents and their destination are visible. Current saved information is unchanged."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: The backup contents and their destination are visible. Current saved information is unchanged."
accessibility_focus = "VoiceOver focus contract: Restore Backup announces its consequence, then success focuses the restore result and Receipt; rejection focuses the Restore Backup control and failed verification stage. The announcement includes this user-facing evidence before focus moves: The backup contents and their destination are visible. Current saved information is unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-RESTORE-REVIEW-001"
label = "Restore Backup"
canonical_owner = "surface.you.command-contract"
preconditions = ["The backup is verified for integrity, schema, capacity, and restorability", "The staged migration diff and current store revision are explicitly confirmed"]
destination = "the atomically activated restored store and restore Receipt. The handoff starts from Data and Storage explicit state contract / Restore Review"
effect = "The typed verified backup restore command appends an Event, updates the Projection, and creates a Receipt and History; the verified backup is staged, projections/replay are rebuilt, integrity is checked, and the restored store activates atomically without unsupported merge; Data and Storage explicit state contract / Restore Review reports the outcome from this visible condition: The backup contents and their destination are visible. Current saved information is unchanged"
success_focus = "the restore result and Receipt within Data and Storage explicit state contract / Restore Review"
failure_focus = "the Restore Backup control and failed verification stage while Data and Storage explicit state contract / Restore Review remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Failure returns to the last honest store; cancellation before activation changes nothing, and post-activation rollback uses the operation journal without rewriting History."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-TRASH-EMPTY"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Restore => destination: the restored object under its authoritative owner and restore Receipt. The handoff starts from Data and Storage explicit state contract / Trash Empty; effect: The typed Trash object restore command appends an Event, updates the Projection, and creates a Receipt and History; the selected object leaves Trash and returns with identity, relationships, History, and projections preserved; Data and Storage explicit state contract / Trash Empty reports the outcome from this visible condition: Trash is empty. No deleted Goal, Step, Capture, Proof, / Note is present; focus: the restored object status and Receipt within Data and Storage explicit state contract / Trash Empty."
durable_effect = "Exact command consequences: Restore: The typed Trash object restore command appends an Event, updates the Projection, and creates a Receipt and History; the selected object leaves Trash and returns with identity, relationships, History, and projections preserved. The durable boundary is specific to this visible evidence: Trash is empty. No deleted Goal, Step, Capture, Proof, or Note is present."
recovery_rollback = "Exact rollback and recovery: Restore: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: Trash is empty. No deleted Goal, Step, Capture, Proof, or Note is present."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Trash is empty. No deleted Goal, Step, Capture, Proof, or Note is present."
accessibility_focus = "VoiceOver focus contract: Restore announces its consequence, then success focuses the restored object status and Receipt; rejection focuses the Trash row and Restore control. The announcement includes this user-facing evidence before focus moves: Trash is empty. No deleted Goal, Step, Capture, Proof, or Note is present."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-TRASH-EMPTY-001"
label = "Restore"
canonical_owner = "surface.you.command-contract"
preconditions = ["The trashed object identity, lineage, current revision, and restore destination are valid"]
destination = "the restored object under its authoritative owner and restore Receipt. The handoff starts from Data and Storage explicit state contract / Trash Empty"
effect = "The typed Trash object restore command appends an Event, updates the Projection, and creates a Receipt and History; the selected object leaves Trash and returns with identity, relationships, History, and projections preserved; Data and Storage explicit state contract / Trash Empty reports the outcome from this visible condition: Trash is empty. No deleted Goal, Step, Capture, Proof, / Note is present"
success_focus = "the restored object status and Receipt within Data and Storage explicit state contract / Trash Empty"
failure_focus = "the Trash row and Restore control while Data and Storage explicit state contract / Trash Empty remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-TRASH-POPULATED"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Restore => destination: the restored object under its authoritative owner and restore Receipt. The handoff starts from Data and Storage explicit state contract / Trash Populated; effect: The typed Trash object restore command appends an Event, updates the Projection, and creates a Receipt and History; the selected object leaves Trash and returns with identity, relationships, History, and projections preserved; Data and Storage explicit state contract / Trash Populated reports the outcome from this visible condition: Trash contains deleted Goals, Steps, Captures, Proof, / Notes with their deletion dates and retention deadlines; focus: the restored object status and Receipt within Data and Storage explicit state contract / Trash Populated."
durable_effect = "Exact command consequences: Restore: The typed Trash object restore command appends an Event, updates the Projection, and creates a Receipt and History; the selected object leaves Trash and returns with identity, relationships, History, and projections preserved. The durable boundary is specific to this visible evidence: Trash contains deleted Goals, Steps, Captures, Proof, or Notes with their deletion dates and retention deadlines."
recovery_rollback = "Exact rollback and recovery: Restore: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: Trash contains deleted Goals, Steps, Captures, Proof, or Notes with their deletion dates and retention deadlines."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Trash contains deleted Goals, Steps, Captures, Proof, or Notes with their deletion dates and retention deadlines."
accessibility_focus = "VoiceOver focus contract: Restore announces its consequence, then success focuses the restored object status and Receipt; rejection focuses the Trash row and Restore control. The announcement includes this user-facing evidence before focus moves: Trash contains deleted Goals, Steps, Captures, Proof, or Notes with their deletion dates and retention deadlines."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-TRASH-POPULATED-001"
label = "Restore"
canonical_owner = "surface.you.command-contract"
preconditions = ["The trashed object identity, lineage, current revision, and restore destination are valid"]
destination = "the restored object under its authoritative owner and restore Receipt. The handoff starts from Data and Storage explicit state contract / Trash Populated"
effect = "The typed Trash object restore command appends an Event, updates the Projection, and creates a Receipt and History; the selected object leaves Trash and returns with identity, relationships, History, and projections preserved; Data and Storage explicit state contract / Trash Populated reports the outcome from this visible condition: Trash contains deleted Goals, Steps, Captures, Proof, / Notes with their deletion dates and retention deadlines"
success_focus = "the restored object status and Receipt within Data and Storage explicit state contract / Trash Populated"
failure_focus = "the Trash row and Restore control while Data and Storage explicit state contract / Trash Populated remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DATA-TRASH-RESTORE"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Restore Backup => destination: the atomically activated restored store and restore Receipt. The handoff starts from Data and Storage explicit state contract / Trash Restore; effect: The typed verified backup restore command appends an Event, updates the Projection, and creates a Receipt and History; the verified backup is staged, projections/replay are rebuilt, integrity is checked, and the restored store activates atomically without unsupported merge; Data and Storage explicit state contract / Trash Restore reports the outcome from this visible condition: The trashed item and its recorded destination are visible. It remains in Trash, and its saved relationships are unchanged; focus: the restore result and Receipt within Data and Storage explicit state contract / Trash Restore."
durable_effect = "Exact command consequences: Restore Backup: The typed verified backup restore command appends an Event, updates the Projection, and creates a Receipt and History; the verified backup is staged, projections/replay are rebuilt, integrity is checked, and the restored store activates atomically without unsupported merge. The durable boundary is specific to this visible evidence: The trashed item and its recorded destination are visible. It remains in Trash, and its saved relationships are unchanged."
recovery_rollback = "Exact rollback and recovery: Restore Backup: Failure returns to the last honest store; cancellation before activation changes nothing, and post-activation rollback uses the operation journal without rewriting History. Recovery preserves or restores the interface evidence that says: The trashed item and its recorded destination are visible. It remains in Trash, and its saved relationships are unchanged."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: The trashed item and its recorded destination are visible. It remains in Trash, and its saved relationships are unchanged."
accessibility_focus = "VoiceOver focus contract: Restore Backup announces its consequence, then success focuses the restore result and Receipt; rejection focuses the Restore Backup control and failed verification stage. The announcement includes this user-facing evidence before focus moves: The trashed item and its recorded destination are visible. It remains in Trash, and its saved relationships are unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DATA-TRASH-RESTORE-001"
label = "Restore Backup"
canonical_owner = "surface.you.command-contract"
preconditions = ["The backup is verified for integrity, schema, capacity, and restorability", "The staged migration diff and current store revision are explicitly confirmed"]
destination = "the atomically activated restored store and restore Receipt. The handoff starts from Data and Storage explicit state contract / Trash Restore"
effect = "The typed verified backup restore command appends an Event, updates the Projection, and creates a Receipt and History; the verified backup is staged, projections/replay are rebuilt, integrity is checked, and the restored store activates atomically without unsupported merge; Data and Storage explicit state contract / Trash Restore reports the outcome from this visible condition: The trashed item and its recorded destination are visible. It remains in Trash, and its saved relationships are unchanged"
success_focus = "the restore result and Receipt within Data and Storage explicit state contract / Trash Restore"
failure_focus = "the Restore Backup control and failed verification stage while Data and Storage explicit state contract / Trash Restore remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Failure returns to the last honest store; cancellation before activation changes nothing, and post-activation rollback uses the operation journal without rewriting History."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-ACCOUNT-SIGNED-IN"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused Account settings drilldown. The handoff starts from You root explicit state contract / Account Signed In; effect: No durable mutation occurs and no Receipt is created; account identity and entitlement are shown separately from the private life graph, which remains local and usable without an account; You root explicit state contract / Account Signed In reports the outcome from this visible condition: You are signed in for account services. Goals, Captures, time, and personal settings remain available on this device; focus: the account identity and entitlement status within You root explicit state contract / Account Signed In."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; account identity and entitlement are shown separately from the private life graph, which remains local and usable without an account. The durable boundary is specific to this visible evidence: You are signed in for account services. Goals, Captures, time, and personal settings remain available on this device."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: You are signed in for account services. Goals, Captures, time, and personal settings remain available on this device."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: You are signed in for account services. Goals, Captures, time, and personal settings remain available on this device."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the account identity and entitlement status; rejection focuses the account row and Open settings control. The announcement includes this user-facing evidence before focus moves: You are signed in for account services. Goals, Captures, time, and personal settings remain available on this device."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-ACCOUNT-SIGNED-IN-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["Current account identity and entitlement posture are available"]
destination = "the focused Account settings drilldown. The handoff starts from You root explicit state contract / Account Signed In"
effect = "No durable mutation occurs and no Receipt is created; account identity and entitlement are shown separately from the private life graph, which remains local and usable without an account; You root explicit state contract / Account Signed In reports the outcome from this visible condition: You are signed in for account services. Goals, Captures, time, and personal settings remain available on this device"
success_focus = "the account identity and entitlement status within You root explicit state contract / Account Signed In"
failure_focus = "the account row and Open settings control while You root explicit state contract / Account Signed In remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-ACCOUNT-SIGNED-OUT"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused Account settings drilldown. The handoff starts from You root explicit state contract / Account Signed Out; effect: No durable mutation occurs and no Receipt is created; account identity and entitlement are shown separately from the private life graph, which remains local and usable without an account; You root explicit state contract / Account Signed Out reports the outcome from this visible condition: Signed out. Local goals, captures, time, proof, and preferences remain available; focus: the account identity and entitlement status within You root explicit state contract / Account Signed Out."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; account identity and entitlement are shown separately from the private life graph, which remains local and usable without an account. The durable boundary is specific to this visible evidence: Signed out. Local goals, captures, time, proof, and preferences remain available."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Signed out. Local goals, captures, time, proof, and preferences remain available."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Signed out. Local goals, captures, time, proof, and preferences remain available."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the account identity and entitlement status; rejection focuses the account row and Open settings control. The announcement includes this user-facing evidence before focus moves: Signed out. Local goals, captures, time, proof, and preferences remain available."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-ACCOUNT-SIGNED-OUT-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["Current account identity and entitlement posture are available"]
destination = "the focused Account settings drilldown. The handoff starts from You root explicit state contract / Account Signed Out"
effect = "No durable mutation occurs and no Receipt is created; account identity and entitlement are shown separately from the private life graph, which remains local and usable without an account; You root explicit state contract / Account Signed Out reports the outcome from this visible condition: Signed out. Local goals, captures, time, proof, and preferences remain available"
success_focus = "the account identity and entitlement status within You root explicit state contract / Account Signed Out"
failure_focus = "the account row and Open settings control while You root explicit state contract / Account Signed Out remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-ACTION-REQUIRED"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Root Action Required. The handoff starts from You root explicit state contract / Action Required; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You root explicit state contract / Action Required reports the outcome from this visible condition: One settings value has an unresolved condition. Other settings remain available; focus: the selected setting value / group heading within You root explicit state contract / Action Required."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: One settings value has an unresolved condition. Other settings remain available."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: One settings value has an unresolved condition. Other settings remain available."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: One settings value has an unresolved condition. Other settings remain available."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: One settings value has an unresolved condition. Other settings remain available."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-ACTION-REQUIRED-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Root Action Required. The handoff starts from You root explicit state contract / Action Required"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You root explicit state contract / Action Required reports the outcome from this visible condition: One settings value has an unresolved condition. Other settings remain available"
success_focus = "the selected setting value / group heading within You root explicit state contract / Action Required"
failure_focus = "the Open settings control while You root explicit state contract / Action Required remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-CONTINUITY-CONFLICTED"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review conflict => destination: the You Continuity disabled-status explanation. The handoff starts from You root explicit state contract / Continuity Conflicted; effect: No durable mutation occurs and no Receipt is created; the future envelope/status may be inspected, but no enable, sync, keep-local, keep-remote, merge, / last-write-wins command is authorized and local use remains unaffected; You root explicit state contract / Continuity Conflicted reports the outcome from this visible condition: Continuity copies disagree. Saved Goals, Captures, time, and preferences remain unchanged on this device; focus: the Continuity disabled status within You root explicit state contract / Continuity Conflicted."
durable_effect = "Exact command consequences: Review conflict: No durable mutation occurs and no Receipt is created; the future envelope/status may be inspected, but no enable, sync, keep-local, keep-remote, merge, or last-write-wins command is authorized and local use remains unaffected. The durable boundary is specific to this visible evidence: Continuity copies disagree. Saved Goals, Captures, time, and preferences remain unchanged on this device."
recovery_rollback = "Exact rollback and recovery: Review conflict: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Continuity copies disagree. Saved Goals, Captures, time, and preferences remain unchanged on this device."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Continuity copies disagree. Saved Goals, Captures, time, and preferences remain unchanged on this device."
accessibility_focus = "VoiceOver focus contract: Review conflict announces its consequence, then success focuses the Continuity disabled status; rejection focuses the Review conflict control and disabled-gate explanation. The announcement includes this user-facing evidence before focus moves: Continuity copies disagree. Saved Goals, Captures, time, and preferences remain unchanged on this device."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-CONTINUITY-CONFLICTED-001"
label = "Review conflict"
canonical_owner = "surface.you.command-contract"
preconditions = ["No continuity mutation is authorized", "SYSTEM-CONTINUITY-DISABLED-001 remains active"]
destination = "the You Continuity disabled-status explanation. The handoff starts from You root explicit state contract / Continuity Conflicted"
effect = "No durable mutation occurs and no Receipt is created; the future envelope/status may be inspected, but no enable, sync, keep-local, keep-remote, merge, / last-write-wins command is authorized and local use remains unaffected; You root explicit state contract / Continuity Conflicted reports the outcome from this visible condition: Continuity copies disagree. Saved Goals, Captures, time, and preferences remain unchanged on this device"
success_focus = "the Continuity disabled status within You root explicit state contract / Continuity Conflicted"
failure_focus = "the Review conflict control and disabled-gate explanation while You root explicit state contract / Continuity Conflicted remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-CONTINUITY-DISABLED"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review continuity status => destination: the You Continuity disabled-status explanation. The handoff starts from You root explicit state contract / Continuity Disabled; effect: No durable mutation occurs and no Receipt is created; the future envelope/status may be inspected, but no enable, sync, keep-local, keep-remote, merge, / last-write-wins command is authorized and local use remains unaffected; You root explicit state contract / Continuity Disabled reports the outcome from this visible condition: Continuity is off. Saved Goals, Captures, time, and preferences remain available on this device; focus: the Continuity disabled status within You root explicit state contract / Continuity Disabled."
durable_effect = "Exact command consequences: Review continuity status: No durable mutation occurs and no Receipt is created; the future envelope/status may be inspected, but no enable, sync, keep-local, keep-remote, merge, or last-write-wins command is authorized and local use remains unaffected. The durable boundary is specific to this visible evidence: Continuity is off. Saved Goals, Captures, time, and preferences remain available on this device."
recovery_rollback = "Exact rollback and recovery: Review continuity status: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Continuity is off. Saved Goals, Captures, time, and preferences remain available on this device."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Continuity is off. Saved Goals, Captures, time, and preferences remain available on this device."
accessibility_focus = "VoiceOver focus contract: Review continuity status announces its consequence, then success focuses the Continuity disabled status; rejection focuses the Review continuity status control and disabled-gate explanation. The announcement includes this user-facing evidence before focus moves: Continuity is off. Saved Goals, Captures, time, and preferences remain available on this device."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-CONTINUITY-DISABLED-001"
label = "Review continuity status"
canonical_owner = "surface.you.command-contract"
preconditions = ["No continuity mutation is authorized", "SYSTEM-CONTINUITY-DISABLED-001 remains active"]
destination = "the You Continuity disabled-status explanation. The handoff starts from You root explicit state contract / Continuity Disabled"
effect = "No durable mutation occurs and no Receipt is created; the future envelope/status may be inspected, but no enable, sync, keep-local, keep-remote, merge, / last-write-wins command is authorized and local use remains unaffected; You root explicit state contract / Continuity Disabled reports the outcome from this visible condition: Continuity is off. Saved Goals, Captures, time, and preferences remain available on this device"
success_focus = "the Continuity disabled status within You root explicit state contract / Continuity Disabled"
failure_focus = "the Review continuity status control and disabled-gate explanation while You root explicit state contract / Continuity Disabled remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-CONTINUITY-PENDING"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review conflict => destination: the You Continuity disabled-status explanation. The handoff starts from You root explicit state contract / Continuity Pending; effect: No durable mutation occurs and no Receipt is created; the future envelope/status may be inspected, but no enable, sync, keep-local, keep-remote, merge, / last-write-wins command is authorized and local use remains unaffected; You root explicit state contract / Continuity Pending reports the outcome from this visible condition: Continuity setup has not finished. This device still shows the latest saved information; focus: the Continuity disabled status within You root explicit state contract / Continuity Pending."
durable_effect = "Exact command consequences: Review conflict: No durable mutation occurs and no Receipt is created; the future envelope/status may be inspected, but no enable, sync, keep-local, keep-remote, merge, or last-write-wins command is authorized and local use remains unaffected. The durable boundary is specific to this visible evidence: Continuity setup has not finished. This device still shows the latest saved information."
recovery_rollback = "Exact rollback and recovery: Review conflict: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Continuity setup has not finished. This device still shows the latest saved information."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Continuity setup has not finished. This device still shows the latest saved information."
accessibility_focus = "VoiceOver focus contract: Review conflict announces its consequence, then success focuses the Continuity disabled status; rejection focuses the Review conflict control and disabled-gate explanation. The announcement includes this user-facing evidence before focus moves: Continuity setup has not finished. This device still shows the latest saved information."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-CONTINUITY-PENDING-001"
label = "Review conflict"
canonical_owner = "surface.you.command-contract"
preconditions = ["No continuity mutation is authorized", "SYSTEM-CONTINUITY-DISABLED-001 remains active"]
destination = "the You Continuity disabled-status explanation. The handoff starts from You root explicit state contract / Continuity Pending"
effect = "No durable mutation occurs and no Receipt is created; the future envelope/status may be inspected, but no enable, sync, keep-local, keep-remote, merge, / last-write-wins command is authorized and local use remains unaffected; You root explicit state contract / Continuity Pending reports the outcome from this visible condition: Continuity setup has not finished. This device still shows the latest saved information"
success_focus = "the Continuity disabled status within You root explicit state contract / Continuity Pending"
failure_focus = "the Review conflict control and disabled-gate explanation while You root explicit state contract / Continuity Pending remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-DIAGNOSTICS-DEGRADED"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open diagnostics => destination: the focused redacted diagnostics detail from You. The handoff starts from You root explicit state contract / Diagnostics Degraded; effect: No durable mutation occurs and no Receipt is created; local health and bounded recovery information are shown with no private titles / content and no authoritative product claim; You root explicit state contract / Diagnostics Degraded reports the outcome from this visible condition: Some diagnostics could not complete. The failed categories and known consequence are explicit; focus: the diagnostic summary within You root explicit state contract / Diagnostics Degraded."
durable_effect = "Exact command consequences: Open diagnostics: No durable mutation occurs and no Receipt is created; local health and bounded recovery information are shown with no private titles or content and no authoritative product claim. The durable boundary is specific to this visible evidence: Some diagnostics could not complete. The failed categories and known consequence are explicit."
recovery_rollback = "Exact rollback and recovery: Open diagnostics: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Some diagnostics could not complete. The failed categories and known consequence are explicit."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Some diagnostics could not complete. The failed categories and known consequence are explicit."
accessibility_focus = "VoiceOver focus contract: Open diagnostics announces its consequence, then success focuses the diagnostic summary; rejection focuses the Open diagnostics control. The announcement includes this user-facing evidence before focus moves: Some diagnostics could not complete. The failed categories and known consequence are explicit."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-DIAGNOSTICS-DEGRADED-001"
label = "Open diagnostics"
canonical_owner = "surface.you.command-contract"
preconditions = ["A redacted diagnostics scope is available"]
destination = "the focused redacted diagnostics detail from You. The handoff starts from You root explicit state contract / Diagnostics Degraded"
effect = "No durable mutation occurs and no Receipt is created; local health and bounded recovery information are shown with no private titles / content and no authoritative product claim; You root explicit state contract / Diagnostics Degraded reports the outcome from this visible condition: Some diagnostics could not complete. The failed categories and known consequence are explicit"
success_focus = "the diagnostic summary within You root explicit state contract / Diagnostics Degraded"
failure_focus = "the Open diagnostics control while You root explicit state contract / Diagnostics Degraded remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "Diagnostics default to redacted local health metadata; no private titles or content leave the device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-DIAGNOSTICS-HEALTHY"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open diagnostics => destination: the focused redacted diagnostics detail from You. The handoff starts from You root explicit state contract / Diagnostics Healthy; effect: No durable mutation occurs and no Receipt is created; local health and bounded recovery information are shown with no private titles / content and no authoritative product claim; You root explicit state contract / Diagnostics Healthy reports the outcome from this visible condition: The checked areas show no detected issue. This result covers only the health checks listed here; focus: the diagnostic summary within You root explicit state contract / Diagnostics Healthy."
durable_effect = "Exact command consequences: Open diagnostics: No durable mutation occurs and no Receipt is created; local health and bounded recovery information are shown with no private titles or content and no authoritative product claim. The durable boundary is specific to this visible evidence: The checked areas show no detected issue. This result covers only the health checks listed here."
recovery_rollback = "Exact rollback and recovery: Open diagnostics: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The checked areas show no detected issue. This result covers only the health checks listed here."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: The checked areas show no detected issue. This result covers only the health checks listed here."
accessibility_focus = "VoiceOver focus contract: Open diagnostics announces its consequence, then success focuses the diagnostic summary; rejection focuses the Open diagnostics control. The announcement includes this user-facing evidence before focus moves: The checked areas show no detected issue. This result covers only the health checks listed here."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-DIAGNOSTICS-HEALTHY-001"
label = "Open diagnostics"
canonical_owner = "surface.you.command-contract"
preconditions = ["A redacted diagnostics scope is available"]
destination = "the focused redacted diagnostics detail from You. The handoff starts from You root explicit state contract / Diagnostics Healthy"
effect = "No durable mutation occurs and no Receipt is created; local health and bounded recovery information are shown with no private titles / content and no authoritative product claim; You root explicit state contract / Diagnostics Healthy reports the outcome from this visible condition: The checked areas show no detected issue. This result covers only the health checks listed here"
success_focus = "the diagnostic summary within You root explicit state contract / Diagnostics Healthy"
failure_focus = "the Open diagnostics control while You root explicit state contract / Diagnostics Healthy remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "Diagnostics default to redacted local health metadata; no private titles or content leave the device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-LIFE-CAPITAL-EMPTY"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Life Capital => destination: the focused Life Capital native drilldown. The handoff starts from You root explicit state contract / Life Capital Empty; effect: No durable mutation occurs and no Receipt is created; Life Capital objects open for inspection; Add, Edit, Archive, Move to Trash, Restore, and Delete permanently remain separately scoped commands and never silently change a Goal / Proof; You root explicit state contract / Life Capital Empty reports the outcome from this visible condition: No Life Capital has been recorded in this scope. Ambitions does not infer / score missing life context; focus: the Life Capital heading and selected object within You root explicit state contract / Life Capital Empty."
durable_effect = "Exact command consequences: Life Capital: No durable mutation occurs and no Receipt is created; Life Capital objects open for inspection; Add, Edit, Archive, Move to Trash, Restore, and Delete permanently remain separately scoped commands and never silently change a Goal or Proof. The durable boundary is specific to this visible evidence: No Life Capital has been recorded in this scope. Ambitions does not infer or score missing life context."
recovery_rollback = "Exact rollback and recovery: Life Capital: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: No Life Capital has been recorded in this scope. Ambitions does not infer or score missing life context."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: No Life Capital has been recorded in this scope. Ambitions does not infer or score missing life context."
accessibility_focus = "VoiceOver focus contract: Life Capital announces its consequence, then success focuses the Life Capital heading and selected object; rejection focuses the Life Capital row. The announcement includes this user-facing evidence before focus moves: No Life Capital has been recorded in this scope. Ambitions does not infer or score missing life context."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-LIFE-CAPITAL-EMPTY-001"
label = "Life Capital"
canonical_owner = "surface.you.command-contract"
preconditions = ["Life Capital is user-owned and current local identity is available"]
destination = "the focused Life Capital native drilldown. The handoff starts from You root explicit state contract / Life Capital Empty"
effect = "No durable mutation occurs and no Receipt is created; Life Capital objects open for inspection; Add, Edit, Archive, Move to Trash, Restore, and Delete permanently remain separately scoped commands and never silently change a Goal / Proof; You root explicit state contract / Life Capital Empty reports the outcome from this visible condition: No Life Capital has been recorded in this scope. Ambitions does not infer / score missing life context"
success_focus = "the Life Capital heading and selected object within You root explicit state contract / Life Capital Empty"
failure_focus = "the Life Capital row while You root explicit state contract / Life Capital Empty remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-LIFE-CAPITAL-POPULATED"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Life Capital => destination: the focused Life Capital native drilldown. The handoff starts from You root explicit state contract / Life Capital Populated; effect: No durable mutation occurs and no Receipt is created; Life Capital objects open for inspection; Add, Edit, Archive, Move to Trash, Restore, and Delete permanently remain separately scoped commands and never silently change a Goal / Proof; You root explicit state contract / Life Capital Populated reports the outcome from this visible condition: Life Capital shows user-owned context with source lineage, not a score / psychological label; focus: the Life Capital heading and selected object within You root explicit state contract / Life Capital Populated."
durable_effect = "Exact command consequences: Life Capital: No durable mutation occurs and no Receipt is created; Life Capital objects open for inspection; Add, Edit, Archive, Move to Trash, Restore, and Delete permanently remain separately scoped commands and never silently change a Goal or Proof. The durable boundary is specific to this visible evidence: Life Capital shows user-owned context with source lineage, not a score or psychological label."
recovery_rollback = "Exact rollback and recovery: Life Capital: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Life Capital shows user-owned context with source lineage, not a score or psychological label."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Life Capital shows user-owned context with source lineage, not a score or psychological label."
accessibility_focus = "VoiceOver focus contract: Life Capital announces its consequence, then success focuses the Life Capital heading and selected object; rejection focuses the Life Capital row. The announcement includes this user-facing evidence before focus moves: Life Capital shows user-owned context with source lineage, not a score or psychological label."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-LIFE-CAPITAL-POPULATED-001"
label = "Life Capital"
canonical_owner = "surface.you.command-contract"
preconditions = ["Life Capital is user-owned and current local identity is available"]
destination = "the focused Life Capital native drilldown. The handoff starts from You root explicit state contract / Life Capital Populated"
effect = "No durable mutation occurs and no Receipt is created; Life Capital objects open for inspection; Add, Edit, Archive, Move to Trash, Restore, and Delete permanently remain separately scoped commands and never silently change a Goal / Proof; You root explicit state contract / Life Capital Populated reports the outcome from this visible condition: Life Capital shows user-owned context with source lineage, not a score / psychological label"
success_focus = "the Life Capital heading and selected object within You root explicit state contract / Life Capital Populated"
failure_focus = "the Life Capital row while You root explicit state contract / Life Capital Populated remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-NO-ACCOUNT-HEALTHY"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused Account settings drilldown. The handoff starts from You root explicit state contract / No Account Healthy; effect: No durable mutation occurs and no Receipt is created; account identity and entitlement are shown separately from the private life graph, which remains local and usable without an account; You root explicit state contract / No Account Healthy reports the outcome from this visible condition: No account is signed in. Goals, Captures, time, Proof, and preferences remain available on this device; focus: the account identity and entitlement status within You root explicit state contract / No Account Healthy."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; account identity and entitlement are shown separately from the private life graph, which remains local and usable without an account. The durable boundary is specific to this visible evidence: No account is signed in. Goals, Captures, time, Proof, and preferences remain available on this device."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: No account is signed in. Goals, Captures, time, Proof, and preferences remain available on this device."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: No account is signed in. Goals, Captures, time, Proof, and preferences remain available on this device."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the account identity and entitlement status; rejection focuses the account row and Open settings control. The announcement includes this user-facing evidence before focus moves: No account is signed in. Goals, Captures, time, Proof, and preferences remain available on this device."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-NO-ACCOUNT-HEALTHY-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["Current account identity and entitlement posture are available"]
destination = "the focused Account settings drilldown. The handoff starts from You root explicit state contract / No Account Healthy"
effect = "No durable mutation occurs and no Receipt is created; account identity and entitlement are shown separately from the private life graph, which remains local and usable without an account; You root explicit state contract / No Account Healthy reports the outcome from this visible condition: No account is signed in. Goals, Captures, time, Proof, and preferences remain available on this device"
success_focus = "the account identity and entitlement status within You root explicit state contract / No Account Healthy"
failure_focus = "the account row and Open settings control while You root explicit state contract / No Account Healthy remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-NORMAL"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Root Normal. The handoff starts from You root explicit state contract / Normal; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You root explicit state contract / Normal reports the outcome from this visible condition: You shows account, permissions, appearance, privacy, data, and support settings; focus: the selected setting value / group heading within You root explicit state contract / Normal."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: You shows account, permissions, appearance, privacy, data, and support settings."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: You shows account, permissions, appearance, privacy, data, and support settings."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: You shows account, permissions, appearance, privacy, data, and support settings."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: You shows account, permissions, appearance, privacy, data, and support settings."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-NORMAL-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Root Normal. The handoff starts from You root explicit state contract / Normal"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You root explicit state contract / Normal reports the outcome from this visible condition: You shows account, permissions, appearance, privacy, data, and support settings"
success_focus = "the selected setting value / group heading within You root explicit state contract / Normal"
failure_focus = "the Open settings control while You root explicit state contract / Normal remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-PERMISSIONS-AVAILABLE"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Root Permissions Available. The handoff starts from You root explicit state contract / Permissions Available; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You root explicit state contract / Permissions Available reports the outcome from this visible condition: Requested permissions are available. Existing Goals, Captures, and time are unchanged; focus: the selected setting value / group heading within You root explicit state contract / Permissions Available."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: Requested permissions are available. Existing Goals, Captures, and time are unchanged."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Requested permissions are available. Existing Goals, Captures, and time are unchanged."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Requested permissions are available. Existing Goals, Captures, and time are unchanged."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: Requested permissions are available. Existing Goals, Captures, and time are unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-PERMISSIONS-AVAILABLE-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Root Permissions Available. The handoff starts from You root explicit state contract / Permissions Available"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You root explicit state contract / Permissions Available reports the outcome from this visible condition: Requested permissions are available. Existing Goals, Captures, and time are unchanged"
success_focus = "the selected setting value / group heading within You root explicit state contract / Permissions Available"
failure_focus = "the Open settings control while You root explicit state contract / Permissions Available remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-PERMISSIONS-DENIED"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Root Permissions Denied. The handoff starts from You root explicit state contract / Permissions Denied; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You root explicit state contract / Permissions Denied reports the outcome from this visible condition: One / more permissions are denied. Unaffected Goals, Captures, time, and settings remain available; focus: the selected setting value / group heading within You root explicit state contract / Permissions Denied."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: One or more permissions are denied. Unaffected Goals, Captures, time, and settings remain available."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: One or more permissions are denied. Unaffected Goals, Captures, time, and settings remain available."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: One or more permissions are denied. Unaffected Goals, Captures, time, and settings remain available."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: One or more permissions are denied. Unaffected Goals, Captures, time, and settings remain available."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-PERMISSIONS-DENIED-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Root Permissions Denied. The handoff starts from You root explicit state contract / Permissions Denied"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You root explicit state contract / Permissions Denied reports the outcome from this visible condition: One / more permissions are denied. Unaffected Goals, Captures, time, and settings remain available"
success_focus = "the selected setting value / group heading within You root explicit state contract / Permissions Denied"
failure_focus = "the Open settings control while You root explicit state contract / Permissions Denied remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-SETUP-COMPLETE"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Root Setup Complete. The handoff starts from You root explicit state contract / Setup Complete; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You root explicit state contract / Setup Complete reports the outcome from this visible condition: Selected setup choices are complete. Optional account and service choices remain unchanged; focus: the selected setting value / group heading within You root explicit state contract / Setup Complete."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: Selected setup choices are complete. Optional account and service choices remain unchanged."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Selected setup choices are complete. Optional account and service choices remain unchanged."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Selected setup choices are complete. Optional account and service choices remain unchanged."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: Selected setup choices are complete. Optional account and service choices remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-SETUP-COMPLETE-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Root Setup Complete. The handoff starts from You root explicit state contract / Setup Complete"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You root explicit state contract / Setup Complete reports the outcome from this visible condition: Selected setup choices are complete. Optional account and service choices remain unchanged"
success_focus = "the selected setting value / group heading within You root explicit state contract / Setup Complete"
failure_focus = "the Open settings control while You root explicit state contract / Setup Complete remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-ROOT-SETUP-PARTIAL"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Root Setup Partial. The handoff starts from You root explicit state contract / Setup Partial; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You root explicit state contract / Setup Partial reports the outcome from this visible condition: Some setup choices are incomplete. Saved information and completed choices remain available; focus: the selected setting value / group heading within You root explicit state contract / Setup Partial."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: Some setup choices are incomplete. Saved information and completed choices remain available."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Some setup choices are incomplete. Saved information and completed choices remain available."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Some setup choices are incomplete. Saved information and completed choices remain available."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: Some setup choices are incomplete. Saved information and completed choices remain available."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-ROOT-SETUP-PARTIAL-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Root Setup Partial. The handoff starts from You root explicit state contract / Setup Partial"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You root explicit state contract / Setup Partial reports the outcome from this visible condition: Some setup choices are incomplete. Saved information and completed choices remain available"
success_focus = "the selected setting value / group heading within You root explicit state contract / Setup Partial"
failure_focus = "the Open settings control while You root explicit state contract / Setup Partial remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-SETTINGS-APP-LOCK-DISABLED"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Turn on App Lock => destination: the App Lock setting showing enabled. The handoff starts from You settings drilldown explicit state contract / App Lock Disabled; effect: The typed App Lock setting change command appends an Event, updates the Projection, and creates a Receipt and History; App Lock becomes enabled locally; private data, account identity, and network state remain unchanged; You settings drilldown explicit state contract / App Lock Disabled reports the outcome from this visible condition: App Lock is off. Ambitions still follows the device’s current access protection; focus: the App Lock setting value and Receipt within You settings drilldown explicit state contract / App Lock Disabled."
durable_effect = "Exact command consequences: Turn on App Lock: The typed App Lock setting change command appends an Event, updates the Projection, and creates a Receipt and History; App Lock becomes enabled locally; private data, account identity, and network state remain unchanged. The durable boundary is specific to this visible evidence: App Lock is off. Ambitions still follows the device’s current access protection."
recovery_rollback = "Exact rollback and recovery: Turn on App Lock: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: App Lock is off. Ambitions still follows the device’s current access protection."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: App Lock is off. Ambitions still follows the device’s current access protection."
accessibility_focus = "VoiceOver focus contract: Turn on App Lock announces its consequence, then success focuses the App Lock setting value and Receipt; rejection focuses the Turn on App Lock control and local authentication failure reason. The announcement includes this user-facing evidence before focus moves: App Lock is off. Ambitions still follows the device’s current access protection."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-SETTINGS-APP-LOCK-DISABLED-001"
label = "Turn on App Lock"
canonical_owner = "surface.you.command-contract"
preconditions = ["Local authentication capability and recovery limit are disclosed", "Local authentication succeeds", "The App Lock setting revision is current"]
destination = "the App Lock setting showing enabled. The handoff starts from You settings drilldown explicit state contract / App Lock Disabled"
effect = "The typed App Lock setting change command appends an Event, updates the Projection, and creates a Receipt and History; App Lock becomes enabled locally; private data, account identity, and network state remain unchanged; You settings drilldown explicit state contract / App Lock Disabled reports the outcome from this visible condition: App Lock is off. Ambitions still follows the device’s current access protection"
success_focus = "the App Lock setting value and Receipt within You settings drilldown explicit state contract / App Lock Disabled"
failure_focus = "the Turn on App Lock control and local authentication failure reason while You settings drilldown explicit state contract / App Lock Disabled remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
privacy_egress = "Authentication and the App Lock setting remain local; no Ambitions Account or network is required."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-SETTINGS-APP-LOCK-ENABLED"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Turn off App Lock => destination: the App Lock setting showing disabled. The handoff starts from You settings drilldown explicit state contract / App Lock Enabled; effect: The typed App Lock setting change command appends an Event, updates the Projection, and creates a Receipt and History; App Lock becomes disabled locally; private data, account identity, and network state remain unchanged; You settings drilldown explicit state contract / App Lock Enabled reports the outcome from this visible condition: App Lock is on for the displayed part of Ambitions. Device passcode access remains available; focus: the App Lock setting value and Receipt within You settings drilldown explicit state contract / App Lock Enabled."
durable_effect = "Exact command consequences: Turn off App Lock: The typed App Lock setting change command appends an Event, updates the Projection, and creates a Receipt and History; App Lock becomes disabled locally; private data, account identity, and network state remain unchanged. The durable boundary is specific to this visible evidence: App Lock is on for the displayed part of Ambitions. Device passcode access remains available."
recovery_rollback = "Exact rollback and recovery: Turn off App Lock: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: App Lock is on for the displayed part of Ambitions. Device passcode access remains available."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: App Lock is on for the displayed part of Ambitions. Device passcode access remains available."
accessibility_focus = "VoiceOver focus contract: Turn off App Lock announces its consequence, then success focuses the App Lock setting value and Receipt; rejection focuses the Turn off App Lock control and local authentication failure reason. The announcement includes this user-facing evidence before focus moves: App Lock is on for the displayed part of Ambitions. Device passcode access remains available."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-SETTINGS-APP-LOCK-ENABLED-001"
label = "Turn off App Lock"
canonical_owner = "surface.you.command-contract"
preconditions = ["Local authentication capability and recovery limit are disclosed", "Local authentication succeeds", "The App Lock setting revision is current"]
destination = "the App Lock setting showing disabled. The handoff starts from You settings drilldown explicit state contract / App Lock Enabled"
effect = "The typed App Lock setting change command appends an Event, updates the Projection, and creates a Receipt and History; App Lock becomes disabled locally; private data, account identity, and network state remain unchanged; You settings drilldown explicit state contract / App Lock Enabled reports the outcome from this visible condition: App Lock is on for the displayed part of Ambitions. Device passcode access remains available"
success_focus = "the App Lock setting value and Receipt within You settings drilldown explicit state contract / App Lock Enabled"
failure_focus = "the Turn off App Lock control and local authentication failure reason while You settings drilldown explicit state contract / App Lock Enabled remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
privacy_egress = "Authentication and the App Lock setting remain local; no Ambitions Account or network is required."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-SETTINGS-APPEARANCE-DARK"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Settings Appearance Dark. The handoff starts from You settings drilldown explicit state contract / Appearance Dark; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Appearance Dark reports the outcome from this visible condition: Dark appearance is active. Text, controls, and status labels keep their contrast and hierarchy; focus: the selected setting value / group heading within You settings drilldown explicit state contract / Appearance Dark."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: Dark appearance is active. Text, controls, and status labels keep their contrast and hierarchy."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Dark appearance is active. Text, controls, and status labels keep their contrast and hierarchy."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Dark appearance is active. Text, controls, and status labels keep their contrast and hierarchy."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: Dark appearance is active. Text, controls, and status labels keep their contrast and hierarchy."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-SETTINGS-APPEARANCE-DARK-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Settings Appearance Dark. The handoff starts from You settings drilldown explicit state contract / Appearance Dark"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Appearance Dark reports the outcome from this visible condition: Dark appearance is active. Text, controls, and status labels keep their contrast and hierarchy"
success_focus = "the selected setting value / group heading within You settings drilldown explicit state contract / Appearance Dark"
failure_focus = "the Open settings control while You settings drilldown explicit state contract / Appearance Dark remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-SETTINGS-APPEARANCE-LIGHT"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Settings Appearance Light. The handoff starts from You settings drilldown explicit state contract / Appearance Light; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Appearance Light reports the outcome from this visible condition: Light appearance is active. Text, controls, and status labels keep their contrast and hierarchy; focus: the selected setting value / group heading within You settings drilldown explicit state contract / Appearance Light."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: Light appearance is active. Text, controls, and status labels keep their contrast and hierarchy."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Light appearance is active. Text, controls, and status labels keep their contrast and hierarchy."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Light appearance is active. Text, controls, and status labels keep their contrast and hierarchy."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: Light appearance is active. Text, controls, and status labels keep their contrast and hierarchy."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-SETTINGS-APPEARANCE-LIGHT-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Settings Appearance Light. The handoff starts from You settings drilldown explicit state contract / Appearance Light"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Appearance Light reports the outcome from this visible condition: Light appearance is active. Text, controls, and status labels keep their contrast and hierarchy"
success_focus = "the selected setting value / group heading within You settings drilldown explicit state contract / Appearance Light"
failure_focus = "the Open settings control while You settings drilldown explicit state contract / Appearance Light remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-SETTINGS-APPEARANCE-OLED-DARK"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Settings Appearance OLED Dark. The handoff starts from You settings drilldown explicit state contract / Appearance OLED Dark; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Appearance OLED Dark reports the outcome from this visible condition: OLED Dark appearance is active. True-black backgrounds keep text, controls, and status labels readable; focus: the selected setting value / group heading within You settings drilldown explicit state contract / Appearance OLED Dark."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: OLED Dark appearance is active. True-black backgrounds keep text, controls, and status labels readable."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: OLED Dark appearance is active. True-black backgrounds keep text, controls, and status labels readable."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: OLED Dark appearance is active. True-black backgrounds keep text, controls, and status labels readable."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: OLED Dark appearance is active. True-black backgrounds keep text, controls, and status labels readable."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-SETTINGS-APPEARANCE-OLED-DARK-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Settings Appearance OLED Dark. The handoff starts from You settings drilldown explicit state contract / Appearance OLED Dark"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Appearance OLED Dark reports the outcome from this visible condition: OLED Dark appearance is active. True-black backgrounds keep text, controls, and status labels readable"
success_focus = "the selected setting value / group heading within You settings drilldown explicit state contract / Appearance OLED Dark"
failure_focus = "the Open settings control while You settings drilldown explicit state contract / Appearance OLED Dark remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-SETTINGS-APPEARANCE-SYSTEM"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Settings Appearance System. The handoff starts from You settings drilldown explicit state contract / Appearance System; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Appearance System reports the outcome from this visible condition: Appearance follows the current iOS system setting; focus: the selected setting value / group heading within You settings drilldown explicit state contract / Appearance System."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: Appearance follows the current iOS system setting."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Appearance follows the current iOS system setting."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Appearance follows the current iOS system setting."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: Appearance follows the current iOS system setting."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-SETTINGS-APPEARANCE-SYSTEM-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Settings Appearance System. The handoff starts from You settings drilldown explicit state contract / Appearance System"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Appearance System reports the outcome from this visible condition: Appearance follows the current iOS system setting"
success_focus = "the selected setting value / group heading within You settings drilldown explicit state contract / Appearance System"
failure_focus = "the Open settings control while You settings drilldown explicit state contract / Appearance System remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-SETTINGS-AUTOMATION-POLICY"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Settings Automation Policy. The handoff starts from You settings drilldown explicit state contract / Automation Policy; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Automation Policy reports the outcome from this visible condition: Automation uses the permission level shown here. Existing settings retain their saved values; focus: the selected setting value / group heading within You settings drilldown explicit state contract / Automation Policy."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: Automation uses the permission level shown here. Existing settings retain their saved values."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Automation uses the permission level shown here. Existing settings retain their saved values."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Automation uses the permission level shown here. Existing settings retain their saved values."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: Automation uses the permission level shown here. Existing settings retain their saved values."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-SETTINGS-AUTOMATION-POLICY-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Settings Automation Policy. The handoff starts from You settings drilldown explicit state contract / Automation Policy"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Automation Policy reports the outcome from this visible condition: Automation uses the permission level shown here. Existing settings retain their saved values"
success_focus = "the selected setting value / group heading within You settings drilldown explicit state contract / Automation Policy"
failure_focus = "the Open settings control while You settings drilldown explicit state contract / Automation Policy remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-SETTINGS-BIOMETRIC-UNAVAILABLE"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Settings Biometric Unavailable. The handoff starts from You settings drilldown explicit state contract / Biometric Unavailable; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Biometric Unavailable reports the outcome from this visible condition: Biometric access is unavailable. Device passcode access remains unchanged, and the user is not locked out; focus: the selected setting value / group heading within You settings drilldown explicit state contract / Biometric Unavailable."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: Biometric access is unavailable. Device passcode access remains unchanged, and the user is not locked out."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Biometric access is unavailable. Device passcode access remains unchanged, and the user is not locked out."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Biometric access is unavailable. Device passcode access remains unchanged, and the user is not locked out."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: Biometric access is unavailable. Device passcode access remains unchanged, and the user is not locked out."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-SETTINGS-BIOMETRIC-UNAVAILABLE-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Settings Biometric Unavailable. The handoff starts from You settings drilldown explicit state contract / Biometric Unavailable"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Biometric Unavailable reports the outcome from this visible condition: Biometric access is unavailable. Device passcode access remains unchanged, and the user is not locked out"
success_focus = "the selected setting value / group heading within You settings drilldown explicit state contract / Biometric Unavailable"
failure_focus = "the Open settings control while You settings drilldown explicit state contract / Biometric Unavailable remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-SETTINGS-INCREASE-CONTRAST"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Settings Increase Contrast. The handoff starts from You settings drilldown explicit state contract / Increase Contrast; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Increase Contrast reports the outcome from this visible condition: Increase Contrast is on. Labels and outlines keep meaning clear without relying on color alone; focus: the selected setting value / group heading within You settings drilldown explicit state contract / Increase Contrast."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: Increase Contrast is on. Labels and outlines keep meaning clear without relying on color alone."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Increase Contrast is on. Labels and outlines keep meaning clear without relying on color alone."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Increase Contrast is on. Labels and outlines keep meaning clear without relying on color alone."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: Increase Contrast is on. Labels and outlines keep meaning clear without relying on color alone."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-SETTINGS-INCREASE-CONTRAST-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Settings Increase Contrast. The handoff starts from You settings drilldown explicit state contract / Increase Contrast"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Increase Contrast reports the outcome from this visible condition: Increase Contrast is on. Labels and outlines keep meaning clear without relying on color alone"
success_focus = "the selected setting value / group heading within You settings drilldown explicit state contract / Increase Contrast"
failure_focus = "the Open settings control while You settings drilldown explicit state contract / Increase Contrast remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-SETTINGS-NOTIFICATION-CONTROLS"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused Notification settings drilldown. The handoff starts from You settings drilldown explicit state contract / Notification Controls; effect: No durable mutation occurs and no Receipt is created; the accepted value remains authoritative while a pending edit is reviewed; no setting is falsely saved / dismissed; You settings drilldown explicit state contract / Notification Controls reports the outcome from this visible condition: Notification controls separate category delivery from whether sensitive content may appear; focus: the notification setting value / first invalid pending edit within You settings drilldown explicit state contract / Notification Controls."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; the accepted value remains authoritative while a pending edit is reviewed; no setting is falsely saved or dismissed. The durable boundary is specific to this visible evidence: Notification controls separate category delivery from whether sensitive content may appear."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Notification controls separate category delivery from whether sensitive content may appear."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Notification controls separate category delivery from whether sensitive content may appear."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the notification setting value or first invalid pending edit; rejection focuses the Notification controls row. The announcement includes this user-facing evidence before focus moves: Notification controls separate category delivery from whether sensitive content may appear."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-SETTINGS-NOTIFICATION-CONTROLS-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The last accepted notification value and any pending edit are retained"]
destination = "the focused Notification settings drilldown. The handoff starts from You settings drilldown explicit state contract / Notification Controls"
effect = "No durable mutation occurs and no Receipt is created; the accepted value remains authoritative while a pending edit is reviewed; no setting is falsely saved / dismissed; You settings drilldown explicit state contract / Notification Controls reports the outcome from this visible condition: Notification controls separate category delivery from whether sensitive content may appear"
success_focus = "the notification setting value / first invalid pending edit within You settings drilldown explicit state contract / Notification Controls"
failure_focus = "the Notification controls row while You settings drilldown explicit state contract / Notification Controls remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-SETTINGS-PRIVACY-REVIEW"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused Privacy settings drilldown. The handoff starts from You settings drilldown explicit state contract / Privacy Review; effect: No durable mutation occurs and no Receipt is created; classification, visible/hidden fields, purpose, destination, retention, redactions, and denial effect are shown without authorizing egress; You settings drilldown explicit state contract / Privacy Review reports the outcome from this visible condition: Privacy review shows what stays local, what optional services may receive, and the controls for each boundary; focus: the privacy classification and first affected setting within You settings drilldown explicit state contract / Privacy Review."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; classification, visible/hidden fields, purpose, destination, retention, redactions, and denial effect are shown without authorizing egress. The durable boundary is specific to this visible evidence: Privacy review shows what stays local, what optional services may receive, and the controls for each boundary."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Privacy review shows what stays local, what optional services may receive, and the controls for each boundary."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Privacy review shows what stays local, what optional services may receive, and the controls for each boundary."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the privacy classification and first affected setting; rejection focuses the Privacy row and Open settings control. The announcement includes this user-facing evidence before focus moves: Privacy review shows what stays local, what optional services may receive, and the controls for each boundary."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-SETTINGS-PRIVACY-REVIEW-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["Current data classification, egress policy, and privacy setting values are available"]
destination = "the focused Privacy settings drilldown. The handoff starts from You settings drilldown explicit state contract / Privacy Review"
effect = "No durable mutation occurs and no Receipt is created; classification, visible/hidden fields, purpose, destination, retention, redactions, and denial effect are shown without authorizing egress; You settings drilldown explicit state contract / Privacy Review reports the outcome from this visible condition: Privacy review shows what stays local, what optional services may receive, and the controls for each boundary"
success_focus = "the privacy classification and first affected setting within You settings drilldown explicit state contract / Privacy Review"
failure_focus = "the Privacy row and Open settings control while You settings drilldown explicit state contract / Privacy Review remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-SETTINGS-TIME-PREFERENCES"
requirement_id = "SPEC-SURFACE-YOU-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open settings => destination: the focused native settings drilldown for Settings Time Preferences. The handoff starts from You settings drilldown explicit state contract / Time Preferences; effect: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Time Preferences reports the outcome from this visible condition: Time preferences state how Time is presented and which defaults affect future proposals; focus: the selected setting value / group heading within You settings drilldown explicit state contract / Time Preferences."
durable_effect = "Exact command consequences: Open settings: No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference or permission change. The durable boundary is specific to this visible evidence: Time preferences state how Time is presented and which defaults affect future proposals."
recovery_rollback = "Exact rollback and recovery: Open settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Time preferences state how Time is presented and which defaults affect future proposals."
offline_behavior = "Settings, private data controls, diagnostics, backup, restore, and App Lock remain local/offline; export uses only a user-chosen destination and continuity remains disabled. Offline rendering retains this state evidence: Time preferences state how Time is presented and which defaults affect future proposals."
accessibility_focus = "VoiceOver focus contract: Open settings announces its consequence, then success focuses the selected setting value or group heading; rejection focuses the Open settings control. The announcement includes this user-facing evidence before focus moves: Time preferences state how Time is presented and which defaults affect future proposals."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-SETTINGS-TIME-PREFERENCES-001"
label = "Open settings"
canonical_owner = "surface.you.command-contract"
preconditions = ["The selected settings group and last accepted values are available"]
destination = "the focused native settings drilldown for Settings Time Preferences. The handoff starts from You settings drilldown explicit state contract / Time Preferences"
effect = "No durable mutation occurs and no Receipt is created; settings open with accepted values and pending edits distinct; viewing commits no preference / permission change; You settings drilldown explicit state contract / Time Preferences reports the outcome from this visible condition: Time preferences state how Time is presented and which defaults affect future proposals"
success_focus = "the selected setting value / group heading within You settings drilldown explicit state contract / Time Preferences"
failure_focus = "the Open settings control while You settings drilldown explicit state contract / Time Preferences remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001"]
+++

# You



## SPEC-SURFACE-YOU-IDENTITY-001 — Searchable personal-system command center

- **Concept:** `surface.you.identity`
- **Modality:** `MUST`
- **Scope:** You root and settings depth
- **Status:** `normative`
- **Verification:** `SCENARIO-YOU-COMMAND-CENTER-001`
- **Supersedes:** none

You MUST be a low-scroll, searchable command center for identity, Setup & Personalization, Life Capital, preferences, automation, privacy, data, security, continuity, notifications, sources, receipts, history, and redacted diagnostics. It is not a profile feed, manifesto, help center, memory dossier, or debug console.

The local profile MUST contain the user’s name, image, preferences, and personal presentation.

You MUST represent a high-agency user who lacks a reliable life operating system and MUST NOT frame the user as low-agency.

## SPEC-SURFACE-YOU-SCREEN-INVENTORY-001 — Plain groups with owned depth

- **Concept:** `surface.you.screen-inventory`
- **Modality:** `MUST`
- **Scope:** You root and owned settings/review routes
- **Status:** `normative`
- **Verification:** `AUDIT-YOU-ROUTES-001`
- **Supersedes:** none

You owns Account & Sync, Privacy & Security, Automation & Behavior, Notifications & Presence, Appearance, Data & Storage, Sources & Imports, Receipts & History, Diagnostics, Setup & Personalization, and Life Capital entry. Contextual Trust details remain owned by Trust inspection even when searchable archives are reachable through You.

Top-level sections MUST be concise and organized.

Appearance SHOULD offer color, material, mood, and photo options through constrained semantic design-system controls.

You MUST provide a Data center for export, import, reset, deletion, sync, backup, storage, Receipts, History, and account data.

Privacy and Data controls MUST remain distinct in You and MUST use low-scroll drilldowns.

You MUST NOT add a dedicated Help section.

You MUST expose sync status, account status, export, account/data controls, diagnostics, and recovery controls.

Each level MUST be intentionally shallow and compact, usually one viewport or a short grouped list.

You’s plain groups MUST NOT obscure hierarchy or object meaning.

You MUST embed education contextually and MUST NOT create a standalone Help destination.

Appearance controls MUST use semantic design-system controls and MAY offer system, light, dark, accent, material-intensity, built-in-theme, photo-theme, custom-photo, and accessibility appearance choices.

## SPEC-SURFACE-YOU-FIRST-VIEWPORT-001 — Identity and current state first

- **Concept:** `surface.you.first-viewport`
- **Modality:** `MUST`
- **Scope:** You first visible and semantic viewport
- **Status:** `normative`
- **Verification:** `PROOF-YOU-FIRST-VIEWPORT-001`
- **Supersedes:** none

The first viewport MUST show a quiet identity/profile summary, optional account and continuity state, privacy state, automation posture, notification state, data/security shortcuts, and settings search. Only current problems or required actions are elevated; broad stats, patterns, and diagnostics remain deeper and object-specific.

You MUST prioritize local settings, personalization, privacy, learning, Source, Receipts, and account control over social, admin, or generic profile framing.

## SPEC-SURFACE-YOU-DEPTH-001 — Useful depth without dashboard drift

- **Concept:** `surface.you.depth`
- **Modality:** `MUST`
- **Scope:** Stats, Life Capital, learning, diagnostics, and history
- **Status:** `normative`
- **Verification:** `AUDIT-YOU-DEPTH-001`
- **Supersedes:** none

Life Capital, broad Patterns, learning controls, receipts/history, sync conflict, and redacted diagnostics MAY have deep inspectable routes. They MUST NOT dominate the root, expose a psychological dossier or runtime architecture, create productivity scoring, or imply account/network ownership of the private graph.

## SPEC-SURFACE-YOU-VISUAL-AUTHORITY-001 — Approved You package, separate implementation proof

- **Concept:** `surface.you.visual-authority`
- **Modality:** `MUST`
- **Scope:** You root and settings visual authority
- **Status:** `normative`
- **Verification:** `PROOF-YOU-VISUAL-MAPPING-001`
- **Supersedes:** none

Visual references MUST use stable external IDs and distinguish approved design target from implementation evidence. Owner-approved VSP-06 package `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:240:93` is the You visual target.

## SPEC-SURFACE-YOU-NO-KNOWLEDGE-MODEL-001 — Data control without an AI-memory dashboard
- **Concept:** `surface.you.no-knowledge-model`
- **Modality:** `MUST NOT`
- **Scope:** You, Search, setup, privacy, and learning controls
- **Status:** `normative`
- **Verification:** `AUDIT-YOU-NO-KNOWLEDGE-MODEL-001`
- **Supersedes:** none

You MUST NOT expose a user-facing model of “what Ambitions knows” or present private context as an AI memory dashboard. Searchable privacy, data, learning, automation, export, reset, deletion, sync, backup, storage, Receipt, and History controls remain available through their plain owning sections.

You MUST expose privacy and data controls without presenting an explicit knowledge model that creates anxiety or resembles an AI memory dashboard.

## SPEC-SURFACE-YOU-PROFILE-001 — You profile

- **Concept:** `surface.you.profile`
- **Modality:** `MUST`
- **Scope:** User profile controls
- **Status:** `normative`
- **Verification:** `SCENARIO-YOU-PROFILE-001`
- **Supersedes:** none

You MUST present user-owned profile, preference, privacy, continuity, and support controls without turning identity into hosted product authority.

## SPEC-SURFACE-YOU-APPEARANCE-001 — Appearance controls

- **Concept:** `surface.you.appearance`
- **Modality:** `MUST`
- **Scope:** Appearance preferences
- **Status:** `normative`
- **Verification:** `SCENARIO-YOU-APPEARANCE-001`
- **Supersedes:** none

Appearance controls MUST preserve system defaults, explicit user overrides, accessibility settings, preview, persistence, reset, and offline behavior.

## SPEC-SURFACE-YOU-DATA-CONTROLS-001 — Data controls

- **Concept:** `surface.you.data-controls`
- **Modality:** `MUST`
- **Scope:** User data management
- **Status:** `normative`
- **Verification:** `SCENARIO-YOU-DATA-CONTROLS-001`
- **Supersedes:** none

You data controls MUST expose export, backup, restore, Trash, reset, diagnostics, and continuity consequences with confirmation, progress, recovery, and proof.

## SPEC-SURFACE-YOU-PRIVACY-DATA-BOUNDARY-001 — Privacy and data boundary

- **Concept:** `surface.you.privacy-data-boundary`
- **Modality:** `MUST`
- **Scope:** Privacy and continuity controls
- **Status:** `normative`
- **Verification:** `SCENARIO-YOU-PRIVACY-DATA-001`
- **Supersedes:** none

You MUST distinguish local private data, optional account identity, optional continuity, public reference infrastructure, and external-platform data before user action.

## SPEC-SURFACE-YOU-CONTEXTUAL-EDUCATION-001 — Contextual education

- **Concept:** `surface.you.contextual-education`
- **Modality:** `SHOULD`
- **Scope:** Settings and unfamiliar states
- **Status:** `normative`
- **Verification:** `A11Y-YOU-CONTEXTUAL-EDUCATION-001`
- **Supersedes:** none

You SHOULD provide concise contextual education at the relevant control or state and MUST NOT require a separate Help destination for discoverability.

## SPEC-SURFACE-YOU-COMMAND-CONTRACT-001 — Exact state command ownership

- **Concept:** `surface.you.command-contract`
- **Modality:** `MUST`
- **Scope:** Structured state command contracts for this specification
- **Status:** `normative`
- **Verification:** `SCENARIO-SURFACE-YOU-COMMAND-CONTRACT-001`
- **Supersedes:** none

The owning specification MUST authorize only the state-bound command labels `Create Backup`, `Delete local data permanently`, `Export Data`, `Life Capital`, `Open diagnostics`, `Open settings`, `Reset preferences`, `Restore`, `Restore Backup`, `Review conflict`, `Review continuity status`, `Try again`, `Turn off App Lock`, `Turn on App Lock` for the structured states declared in this file. Every command MUST bind stable state and object identity, current revision, canonical owner, preconditions, destination, exact effect and focus targets; navigation, inspection, selection, preview, refresh, and cancellation remain non-mutating. A durable mutation MUST commit only after current-revision validation and required confirmation through Command -> Event -> Projection -> Receipt -> Replay; cancellation or rejection preserves accepted input, and rollback or Undo uses an owning typed command without rewriting history. Local canonical behavior MUST remain available offline without an account; external results remain separate and retryable without replaying the local commit. Sensitive content MUST remain local unless explicit minimum-field egress review passes. VoiceOver MUST announce object, accepted or rejected outcome, consequence, recovery or Undo availability, and destination focus; no color, motion, gesture, or position may carry command meaning alone. Verification MUST prove every declared state, command, transition, commit boundary, durable effect, rollback, offline, privacy, accessibility, and focus mapping against the structured contract.

## Completeness contract

<!-- canon-section: purpose-user-question -->
You answers what Ambitions knows or is allowed to do, what the user controls, how private data is handled, and where personal-system settings and evidence can be inspected or changed.

<!-- canon-section: entry-exit -->
Entry is root selection, settings Search, permission/account/diagnostic handoff, notification deep link, or restoration. Exit uses native back/root switching while preserving query, group, detail state, unsaved edits, and focus.

<!-- canon-section: routes-presentation -->
The root is a searchable grouped index. Complex setup, Life Capital, conflict review, export preview, destructive review, and diagnostics use native depth or focused review; contextual Trust inspection remains a separate non-root owner.

<!-- canon-section: displayed-objects -->
Displayed objects include profile summary, explicit account/continuity/privacy/permission states, automation policies, notification controls, Life Capital, source/import status, receipts/history links, data controls, and redacted health facts. Internal models never become primary objects.

<!-- canon-section: resting-states -->
Required states include no-account healthy, optional account signed in/out, continuity disabled/pending/conflicted, permissions available/denied, normal, action-required, setup partial/complete, Life Capital empty/populated, and diagnostics healthy/degraded.

<!-- canon-section: loading-transitional -->
Transition state records operation phase, retained local snapshot, progress, cancellation, and focus target.
Sign-in/out, continuity preflight, permission return, export, delete/reset preview, Life Capital impact simulation, source review, and diagnostics refresh preserve local data and expose cancellable progress where work is not immediate.

<!-- canon-section: empty-degraded -->
The degraded-state matrix pairs each capability condition with preserved local function and a precise recovery action.
No account is a healthy state. Denied permission, unavailable network, stale source, continuity conflict, export failure, or diagnostics failure preserves local core and offers exact recovery. Empty Life Capital or history is not filled with fabricated insight.

<!-- canon-section: commands-actions -->
Search setting, edit preference, change automation, manage permission, sign in/out, review continuity conflict, add/edit/archive/delete Life Capital, export, backup/restore, lock, Trash/restore, reset/delete, inspect receipt/history, and retry diagnostics use explicit validated actions and consequence review.

<!-- canon-section: durable-effects -->
Accepted policy, privacy, security, Life Capital, source, continuity, export, archive/delete, and destructive operations create canonical local events/receipts where product-significant, replay safely, and update affected paths only after preview/approval.

<!-- canon-section: failure-rollback -->
Failed sign-in, sync, export, import, permission, or diagnostics work does not erase local data or accepted settings. Destructive actions require scope preview and confirmation. Retry is idempotent; rollback/restore retains history and revalidates projections.

<!-- canon-section: offline -->
All local settings, privacy explanations, Life Capital, automation controls, local history, export preparation, app lock, and diagnostics remain available as applicable without account or network. Optional identity or reference access never gates core use.

<!-- canon-section: privacy-data-classification -->
The classification matrix assigns each datum to local graph, continuity, account, public-reference, export, or diagnostic scope.
You explicitly separates local private graph, optional CloudKit continuity, Ambitions Account identity/entitlement, public-only R2/reference access, permissions, exports, and diagnostics. Private content is excluded from diagnostic/export packages by default and needs explicit preview/inclusion.

<!-- canon-section: accessibility-reading-order -->
VoiceOver reads identity/current action state, search, then groups in stable order. Every toggle exposes label, current value, consequence, and exact action; destructive and conflict reviews expose complete summaries and focus-safe choices without relying on icons, color, or spatial grouping.

<!-- canon-section: dynamic-type -->
Groups and detail reflow to one column; labels, values, warnings, search results, and destructive consequences remain fully readable and actionable with no horizontal dependency.

<!-- canon-section: reduce-motion -->
Group expansion, status changes, setup progress, and drilldown transitions use restrained fades or immediate updates while retaining announcements, progress, and focus.

<!-- canon-section: reduce-transparency -->
Materials become opaque semantic backgrounds with equivalent grouping, hierarchy, contrast, selection, and privacy/action state.

<!-- canon-section: copy-state-language -->
Use plain account, privacy, sync/continuity, notification, Life Capital, source, receipt, history, export, archive, and delete language. Avoid runtime taxonomy, psychological labels, productivity scores, AI memory, or proof/readiness claims.

<!-- canon-section: visual-authority -->
The named package controls geometry, hierarchy, composition, states, and adaptive layout.
Stable package ID `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:240:93` supplies approved You design authority. Source rendering, privacy/account behavior, accessibility/device evidence, implementation parity, and release proof remain separate.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Surfaces/You/` owns presentation; `Core/LocalRuntimeOS/PrivacySecurity/`, `Continuity/`, `Inspection/`, and `Diagnostics/` own facts/behavior; app `Diagnostics/` presents redacted health; `Quality/` owns proof.

<!-- canon-section: tests -->
Tests cover grouping/search/deep links, no-account use, privacy boundaries, permission recovery, automation scope, Life Capital impact/archive/delete, sign-out local retention, continuity conflict, export/diagnostic redaction, destructive previews, offline, VoiceOver order/actions, Dynamic Type, reduced effects, contrast, and focus.

<!-- canon-section: proof -->
Required proof includes state/scenario logs, privacy-boundary evidence, redacted export/diagnostics fixtures, receipts/replay, screenshot/accessibility matrices, independent visual mapping/acceptance, exact commands/exits, current environment, skipped checks, known risks, and rollback. No readiness is inferred from this spec.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
You root loading, settings search, Life Capital/history access, and redacted diagnostics refresh MUST remain bounded and cancellable, perform no interaction-path network gating or synchronous disk I/O, use no polling or unbounded background loop, and preserve foreground responsiveness under Low Power Mode, thermal pressure, protected-data unavailability, and storage pressure. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. Implementation authorization requires an owner-approved performance-registry record declaring device floor, OS, build configuration, representative settings/Life Capital/history data scale, warm/cold state, measurement tool, percentile/maximum, and regression threshold.

## SPEC-SURFACE-YOU-SETTINGS-DRILLDOWN-001 — Settings drilldown presentation

- **Concept:** `surface.you.settings-drilldown`
- **Modality:** `MUST`
- **Scope:** Settings drilldown presentation
- **Status:** `normative`
- **Verification:** `REVIEW-SPEC-SURFACE-YOU-SETTINGS-DRILLDOWN-001`
- **Supersedes:** none

Major settings areas MUST open as focused full-screen native drilldowns with low-scroll, scoped content.

## SPEC-SURFACE-YOU-TIME-PREFERENCES-001 — Time preference inventory

- **Concept:** `surface.you.time-preferences`
- **Modality:** `MUST`
- **Scope:** Time preference inventory
- **Status:** `normative`
- **Verification:** `REVIEW-SPEC-SURFACE-YOU-TIME-PREFERENCES-001`
- **Supersedes:** none

You MUST expose searchable Time preferences for week start, time format, working bounds, default duration, alerts, schedule state/reflow rule, time zone, transition buffers, import sources, and visual density.
