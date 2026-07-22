+++
spec_id = "APP-SHELL"
title = "App Shell"
kind = "app"
status = "normative"
owner_domain = "app-shell"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "app.shell.command-contract",
  "app.shell.failure-recovery",
  "app.shell.first-viewport",
  "app.shell.global-actions",
  "app.shell.root-navigation",
  "app.shell.state",
]
inherits = [
  "LAW-SHELL-STAGE-001",
  "CONST-IA-ROOT-001",
  "LAW-IA-NONROOT-001",
  "IA-PLAIN-BRANDED-NAMING-001",
  "PLATFORM-NATIVE-IPHONE-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
  "CONST-PROOF-EVIDENCE-001",
]
depends_on = ["CONSTITUTION"]
source_owners = [
  "Native/Ambitions/App/",
  "Native/Ambitions/Stage/",
  "Native/Ambitions/DesignSystem/StagePrimitives/",
  "Native/Ambitions/Quality/",
]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-DRILLDOWN-COMPACT-MODAL"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Close => destination: the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Drilldown containment explicit state contract / Compact Modal; effect: No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Drilldown containment explicit state contract / Compact Modal reports the outcome from this visible condition: A compact choice sheet appears above the current view, which stays in place; this command preserves accepted product state; focus: the stored origin focus ID or invoking control; otherwise the owner root primary object within Drilldown containment explicit state contract / Compact Modal."
durable_effect = "Exact command consequences: Close: No durable mutation occurs and no Receipt is created; the presented sheet, overlay, Capture, Search, or Trust inspection closes while product objects remain unchanged. The durable boundary is specific to this visible evidence: A compact choice sheet appears above the current view, which stays in place."
recovery_rollback = "Exact rollback and recovery: Close: No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation. Recovery preserves or restores the interface evidence that says: A compact choice sheet appears above the current view, which stays in place."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: A compact choice sheet appears above the current view, which stays in place."
accessibility_focus = "VoiceOver focus contract: Close announces its consequence, then success focuses the stored origin focus ID or invoking control; otherwise the owner root primary object; rejection focuses the visible presentation status and its Close control. The announcement includes this user-facing evidence before focus moves: A compact choice sheet appears above the current view, which stays in place."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-DRILLDOWN-COMPACT-MODAL-001"
label = "Close"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Drilldown containment explicit state contract / Compact Modal"
destination_id = "DEST-APP-SHELL-DRILLDOWN-COMPACT-MODAL-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Drilldown containment explicit state contract / Compact Modal reports the outcome from this visible condition: A compact choice sheet appears above the current view, which stays in place; this command preserves accepted product state"
success_focus = "the stored origin focus ID or invoking control; otherwise the owner root primary object within Drilldown containment explicit state contract / Compact Modal"
success_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-COMPACT-MODAL-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible presentation status and its Close control while Drilldown containment explicit state contract / Compact Modal remains visible"
failure_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-COMPACT-MODAL-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation."
recovery_id = "RECOVERY-APP-SHELL-DRILLDOWN-COMPACT-MODAL-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-DRILLDOWN-DEEP-INSPECTION"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Close => destination: the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Drilldown containment explicit state contract / Deep Inspection; effect: No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Drilldown containment explicit state contract / Deep Inspection reports the outcome from this visible condition: A deeper inspection shows supporting history and context without changing the item; this command preserves accepted product state; focus: the stored origin focus ID or invoking control; otherwise the owner root primary object within Drilldown containment explicit state contract / Deep Inspection."
durable_effect = "Exact command consequences: Close: No durable mutation occurs and no Receipt is created; the presented sheet, overlay, Capture, Search, or Trust inspection closes while product objects remain unchanged. The durable boundary is specific to this visible evidence: A deeper inspection shows supporting history and context without changing the item."
recovery_rollback = "Exact rollback and recovery: Close: No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation. Recovery preserves or restores the interface evidence that says: A deeper inspection shows supporting history and context without changing the item."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: A deeper inspection shows supporting history and context without changing the item."
accessibility_focus = "VoiceOver focus contract: Close announces its consequence, then success focuses the stored origin focus ID or invoking control; otherwise the owner root primary object; rejection focuses the visible presentation status and its Close control. The announcement includes this user-facing evidence before focus moves: A deeper inspection shows supporting history and context without changing the item."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-DRILLDOWN-DEEP-INSPECTION-001"
label = "Close"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Drilldown containment explicit state contract / Deep Inspection"
destination_id = "DEST-APP-SHELL-DRILLDOWN-DEEP-INSPECTION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Drilldown containment explicit state contract / Deep Inspection reports the outcome from this visible condition: A deeper inspection shows supporting history and context without changing the item; this command preserves accepted product state"
success_focus = "the stored origin focus ID or invoking control; otherwise the owner root primary object within Drilldown containment explicit state contract / Deep Inspection"
success_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-DEEP-INSPECTION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible presentation status and its Close control while Drilldown containment explicit state contract / Deep Inspection remains visible"
failure_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-DEEP-INSPECTION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation."
recovery_id = "RECOVERY-APP-SHELL-DRILLDOWN-DEEP-INSPECTION-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-DRILLDOWN-DRILLDOWN"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Close => destination: the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Drilldown containment explicit state contract / Drilldown; effect: No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Drilldown containment explicit state contract / Drilldown reports the outcome from this visible condition: A detail view is open within its owning surface; the selected item remains the focus; this command preserves accepted product state; focus: the stored origin focus ID or invoking control; otherwise the owner root primary object within Drilldown containment explicit state contract / Drilldown."
durable_effect = "Exact command consequences: Close: No durable mutation occurs and no Receipt is created; the presented sheet, overlay, Capture, Search, or Trust inspection closes while product objects remain unchanged. The durable boundary is specific to this visible evidence: A detail view is open within its owning surface; the selected item remains the focus."
recovery_rollback = "Exact rollback and recovery: Close: No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation. Recovery preserves or restores the interface evidence that says: A detail view is open within its owning surface; the selected item remains the focus."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: A detail view is open within its owning surface; the selected item remains the focus."
accessibility_focus = "VoiceOver focus contract: Close announces its consequence, then success focuses the stored origin focus ID or invoking control; otherwise the owner root primary object; rejection focuses the visible presentation status and its Close control. The announcement includes this user-facing evidence before focus moves: A detail view is open within its owning surface; the selected item remains the focus."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-DRILLDOWN-DRILLDOWN-001"
label = "Close"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Drilldown containment explicit state contract / Drilldown"
destination_id = "DEST-APP-SHELL-DRILLDOWN-DRILLDOWN-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Drilldown containment explicit state contract / Drilldown reports the outcome from this visible condition: A detail view is open within its owning surface; the selected item remains the focus; this command preserves accepted product state"
success_focus = "the stored origin focus ID or invoking control; otherwise the owner root primary object within Drilldown containment explicit state contract / Drilldown"
success_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-DRILLDOWN-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible presentation status and its Close control while Drilldown containment explicit state contract / Drilldown remains visible"
failure_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-DRILLDOWN-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation."
recovery_id = "RECOVERY-APP-SHELL-DRILLDOWN-DRILLDOWN-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-DRILLDOWN-FULL-SCREEN-OVERLAY"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Close => destination: the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Drilldown containment explicit state contract / Full Screen Overlay; effect: No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Drilldown containment explicit state contract / Full Screen Overlay reports the outcome from this visible condition: A full-screen task is open. The screen beneath it remains unchanged; this command preserves accepted product state; focus: the stored origin focus ID or invoking control; otherwise the owner root primary object within Drilldown containment explicit state contract / Full Screen Overlay."
durable_effect = "Exact command consequences: Close: No durable mutation occurs and no Receipt is created; the presented sheet, overlay, Capture, Search, or Trust inspection closes while product objects remain unchanged. The durable boundary is specific to this visible evidence: A full-screen task is open. The screen beneath it remains unchanged."
recovery_rollback = "Exact rollback and recovery: Close: No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation. Recovery preserves or restores the interface evidence that says: A full-screen task is open. The screen beneath it remains unchanged."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: A full-screen task is open. The screen beneath it remains unchanged."
accessibility_focus = "VoiceOver focus contract: Close announces its consequence, then success focuses the stored origin focus ID or invoking control; otherwise the owner root primary object; rejection focuses the visible presentation status and its Close control. The announcement includes this user-facing evidence before focus moves: A full-screen task is open. The screen beneath it remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-DRILLDOWN-FULL-SCREEN-OVERLAY-001"
label = "Close"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Drilldown containment explicit state contract / Full Screen Overlay"
destination_id = "DEST-APP-SHELL-DRILLDOWN-FULL-SCREEN-OVERLAY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Drilldown containment explicit state contract / Full Screen Overlay reports the outcome from this visible condition: A full-screen task is open. The screen beneath it remains unchanged; this command preserves accepted product state"
success_focus = "the stored origin focus ID or invoking control; otherwise the owner root primary object within Drilldown containment explicit state contract / Full Screen Overlay"
success_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-FULL-SCREEN-OVERLAY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible presentation status and its Close control while Drilldown containment explicit state contract / Full Screen Overlay remains visible"
failure_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-FULL-SCREEN-OVERLAY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation."
recovery_id = "RECOVERY-APP-SHELL-DRILLDOWN-FULL-SCREEN-OVERLAY-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-DRILLDOWN-RESTORATION"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Return => destination: the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Drilldown containment explicit state contract / Restoration; effect: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Drilldown containment explicit state contract / Restoration reports the outcome from this visible condition: The prior view and focus are being restored against current saved information; focus: the owner root primary object or Today Start here heading within Drilldown containment explicit state contract / Restoration."
durable_effect = "Exact command consequences: Return: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data. The durable boundary is specific to this visible evidence: The prior view and focus are being restored against current saved information."
recovery_rollback = "Exact rollback and recovery: Return: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The prior view and focus are being restored against current saved information."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: The prior view and focus are being restored against current saved information."
accessibility_focus = "VoiceOver focus contract: Return announces its consequence, then success focuses the owner root primary object or Today Start here heading; rejection focuses the visible route-failure status and Return control. The announcement includes this user-facing evidence before focus moves: The prior view and focus are being restored against current saved information."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-DRILLDOWN-RESTORATION-001"
label = "Return"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Drilldown containment explicit state contract / Restoration"
destination_id = "DEST-APP-SHELL-DRILLDOWN-RESTORATION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Drilldown containment explicit state contract / Restoration reports the outcome from this visible condition: The prior view and focus are being restored against current saved information"
success_focus = "the owner root primary object or Today Start here heading within Drilldown containment explicit state contract / Restoration"
success_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-RESTORATION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible route-failure status and Return control while Drilldown containment explicit state contract / Restoration remains visible"
failure_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-RESTORATION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-DRILLDOWN-RESTORATION-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Return => destination: the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Drilldown containment explicit state contract / Unavailable Route; effect: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Drilldown containment explicit state contract / Unavailable Route reports the outcome from this visible condition: This destination cannot open safely; the nearest valid context remains visible; focus: the owner root primary object or Today Start here heading within Drilldown containment explicit state contract / Unavailable Route.\nTry again => destination: the original route only when current-revision route resolution succeeds; otherwise the same visible failure status. The handoff starts from Drilldown containment explicit state contract / Unavailable Route; effect: No durable mutation occurs and no Receipt is created; only route resolution is retried; neither an object mutation nor repetition of the prior command occurs; Drilldown containment explicit state contract / Unavailable Route reports the outcome from this visible condition: This destination cannot open safely; the nearest valid context remains visible; focus: the resolved destination primary object within Drilldown containment explicit state contract / Unavailable Route."
durable_effect = "Exact command consequences: Return: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data | Try again: No durable mutation occurs and no Receipt is created; only route resolution is retried; no object mutation or prior command is repeated. The durable boundary is specific to this visible evidence: This destination cannot open safely; the nearest valid context remains visible."
recovery_rollback = "Exact rollback and recovery: Return: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Try again: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This destination cannot open safely; the nearest valid context remains visible."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: This destination cannot open safely; the nearest valid context remains visible."
accessibility_focus = "VoiceOver focus contract: Return announces its consequence, then success focuses the owner root primary object or Today Start here heading; rejection focuses the visible route-failure status and Return control | Try again announces its consequence, then success focuses the resolved destination primary object; rejection focuses the route-failure reason and Try again control. The announcement includes this user-facing evidence before focus moves: This destination cannot open safely; the nearest valid context remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE-001"
label = "Return"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Drilldown containment explicit state contract / Unavailable Route"
destination_id = "DEST-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Drilldown containment explicit state contract / Unavailable Route reports the outcome from this visible condition: This destination cannot open safely; the nearest valid context remains visible"
success_focus = "the owner root primary object or Today Start here heading within Drilldown containment explicit state contract / Unavailable Route"
success_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible route-failure status and Return control while Drilldown containment explicit state contract / Unavailable Route remains visible"
failure_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged; the canonical owner root remains the explicit safe fallback."
recovery_id = "RECOVERY-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE-002"
label = "Try again"
canonical_owner = "app.shell.command-contract"
preconditions = ["Route resolution is idempotent for the current revision", "The original route and target identity are retained"]
destination = "the original route only when current-revision route resolution succeeds; otherwise the same visible failure status. The handoff starts from Drilldown containment explicit state contract / Unavailable Route"
destination_id = "DEST-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; only route resolution is retried; neither an object mutation nor repetition of the prior command occurs; Drilldown containment explicit state contract / Unavailable Route reports the outcome from this visible condition: This destination cannot open safely; the nearest valid context remains visible"
success_focus = "the resolved destination primary object within Drilldown containment explicit state contract / Unavailable Route"
success_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the route-failure reason and Try again control while Drilldown containment explicit state contract / Unavailable Route remains visible"
failure_focus_id = "FOCUS-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE-002"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-ROOT-GOALS-SELECTED"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goals => destination: the Goals Stage root. The handoff starts from Root app shell explicit state contract / Goals Selected; effect: No durable mutation occurs and no Receipt is created; the active root changes to Goals while the prior root state is preserved; Root app shell explicit state contract / Goals Selected reports the outcome from this visible condition: Goals is selected. The chosen Life Area and its Goals remain in view; focus: the Goals primary object within Root app shell explicit state contract / Goals Selected."
durable_effect = "Exact command consequences: Open Goals: No durable mutation occurs and no Receipt is created; the active root changes to Goals while the prior root state is preserved. The durable boundary is specific to this visible evidence: Goals is selected. The chosen Life Area and its Goals remain in view."
recovery_rollback = "Exact rollback and recovery: Open Goals: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Goals is selected. The chosen Life Area and its Goals remain in view."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: Goals is selected. The chosen Life Area and its Goals remain in view."
accessibility_focus = "VoiceOver focus contract: Open Goals announces its consequence, then success focuses the Goals primary object; rejection focuses the Goals root action in the root dock. The announcement includes this user-facing evidence before focus moves: Goals is selected. The chosen Life Area and its Goals remain in view."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-GOALS-SELECTED-001"
label = "Open Goals"
canonical_owner = "app.shell.command-contract"
preconditions = ["Goals is one of the four canonical roots", "The root switch request is current"]
destination = "the Goals Stage root. The handoff starts from Root app shell explicit state contract / Goals Selected"
destination_id = "DEST-APP-SHELL-ROOT-GOALS-SELECTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the active root changes to Goals while the prior root state is preserved; Root app shell explicit state contract / Goals Selected reports the outcome from this visible condition: Goals is selected. The chosen Life Area and its Goals remain in view"
success_focus = "the Goals primary object within Root app shell explicit state contract / Goals Selected"
success_focus_id = "FOCUS-APP-SHELL-ROOT-GOALS-SELECTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Goals root action in the root dock while Root app shell explicit state contract / Goals Selected remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-GOALS-SELECTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-GOALS-SELECTED-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-ROOT-TIME-SELECTED"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Time => destination: the Time Stage root. The handoff starts from Root app shell explicit state contract / Time Selected; effect: No durable mutation occurs and no Receipt is created; the active root changes to Time while the prior root state is preserved; Root app shell explicit state contract / Time Selected reports the outcome from this visible condition: Time is selected. The chosen date range remains in view; focus: the Time primary object within Root app shell explicit state contract / Time Selected."
durable_effect = "Exact command consequences: Open Time: No durable mutation occurs and no Receipt is created; the active root changes to Time while the prior root state is preserved. The durable boundary is specific to this visible evidence: Time is selected. The chosen date range remains in view."
recovery_rollback = "Exact rollback and recovery: Open Time: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Time is selected. The chosen date range remains in view."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: Time is selected. The chosen date range remains in view."
accessibility_focus = "VoiceOver focus contract: Open Time announces its consequence, then success focuses the Time primary object; rejection focuses the Time root action in the root dock. The announcement includes this user-facing evidence before focus moves: Time is selected. The chosen date range remains in view."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-TIME-SELECTED-001"
label = "Open Time"
canonical_owner = "app.shell.command-contract"
preconditions = ["The root switch request is current", "Time is one of the four canonical roots"]
destination = "the Time Stage root. The handoff starts from Root app shell explicit state contract / Time Selected"
destination_id = "DEST-APP-SHELL-ROOT-TIME-SELECTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the active root changes to Time while the prior root state is preserved; Root app shell explicit state contract / Time Selected reports the outcome from this visible condition: Time is selected. The chosen date range remains in view"
success_focus = "the Time primary object within Root app shell explicit state contract / Time Selected"
success_focus_id = "FOCUS-APP-SHELL-ROOT-TIME-SELECTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Time root action in the root dock while Root app shell explicit state contract / Time Selected remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-TIME-SELECTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-TIME-SELECTED-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-ROOT-TODAY-SELECTED"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Today => destination: the Today Stage root. The handoff starts from Root app shell explicit state contract / Today Selected; effect: No durable mutation occurs and no Receipt is created; the active root changes to Today while the prior root state is preserved; Root app shell explicit state contract / Today Selected reports the outcome from this visible condition: Today is selected. Start here and the current day remain in view; focus: the Today primary object within Root app shell explicit state contract / Today Selected."
durable_effect = "Exact command consequences: Open Today: No durable mutation occurs and no Receipt is created; the active root changes to Today while the prior root state is preserved. The durable boundary is specific to this visible evidence: Today is selected. Start here and the current day remain in view."
recovery_rollback = "Exact rollback and recovery: Open Today: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Today is selected. Start here and the current day remain in view."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: Today is selected. Start here and the current day remain in view."
accessibility_focus = "VoiceOver focus contract: Open Today announces its consequence, then success focuses the Today primary object; rejection focuses the Today root action in the root dock. The announcement includes this user-facing evidence before focus moves: Today is selected. Start here and the current day remain in view."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-TODAY-SELECTED-001"
label = "Open Today"
canonical_owner = "app.shell.command-contract"
preconditions = ["The root switch request is current", "Today is one of the four canonical roots"]
destination = "the Today Stage root. The handoff starts from Root app shell explicit state contract / Today Selected"
destination_id = "DEST-APP-SHELL-ROOT-TODAY-SELECTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the active root changes to Today while the prior root state is preserved; Root app shell explicit state contract / Today Selected reports the outcome from this visible condition: Today is selected. Start here and the current day remain in view"
success_focus = "the Today primary object within Root app shell explicit state contract / Today Selected"
success_focus_id = "FOCUS-APP-SHELL-ROOT-TODAY-SELECTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Today root action in the root dock while Root app shell explicit state contract / Today Selected remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-TODAY-SELECTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-TODAY-SELECTED-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-DUPLICATE-PRESENTATION-OWNER"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Return => destination: the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner; effect: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner reports the outcome from this visible condition: This destination is already open. The screen currently in view remains unchanged; focus: the owner root primary object or Today Start here heading within Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner.\nTry again => destination: the original route only when current-revision route resolution succeeds; otherwise the same visible failure status. The handoff starts from Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner; effect: No durable mutation occurs and no Receipt is created; only route resolution is retried; neither an object mutation nor repetition of the prior command occurs; Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner reports the outcome from this visible condition: This destination is already open. The screen currently in view remains unchanged; focus: the resolved destination primary object within Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner."
durable_effect = "Exact command consequences: Return: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data | Try again: No durable mutation occurs and no Receipt is created; only route resolution is retried; no object mutation or prior command is repeated. The durable boundary is specific to this visible evidence: This destination is already open. The screen currently in view remains unchanged."
recovery_rollback = "Exact rollback and recovery: Return: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Try again: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This destination is already open. The screen currently in view remains unchanged."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: This destination is already open. The screen currently in view remains unchanged."
accessibility_focus = "VoiceOver focus contract: Return announces its consequence, then success focuses the owner root primary object or Today Start here heading; rejection focuses the visible route-failure status and Return control | Try again announces its consequence, then success focuses the resolved destination primary object; rejection focuses the route-failure reason and Try again control. The announcement includes this user-facing evidence before focus moves: This destination is already open. The screen currently in view remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-DUPLICATE-PRESENTATION-OWNER-001"
label = "Return"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner"
destination_id = "DEST-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-DUPLICATE-PRESENTATION-OWNER-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner reports the outcome from this visible condition: This destination is already open. The screen currently in view remains unchanged"
success_focus = "the owner root primary object or Today Start here heading within Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner"
success_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-DUPLICATE-PRESENTATION-OWNER-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible route-failure status and Return control while Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-DUPLICATE-PRESENTATION-OWNER-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-DUPLICATE-PRESENTATION-OWNER-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-DUPLICATE-PRESENTATION-OWNER-002"
label = "Try again"
canonical_owner = "app.shell.command-contract"
preconditions = ["Route resolution is idempotent for the current revision", "The original route and target identity are retained"]
destination = "the original route only when current-revision route resolution succeeds; otherwise the same visible failure status. The handoff starts from Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner"
destination_id = "DEST-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-DUPLICATE-PRESENTATION-OWNER-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; only route resolution is retried; neither an object mutation nor repetition of the prior command occurs; Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner reports the outcome from this visible condition: This destination is already open. The screen currently in view remains unchanged"
success_focus = "the resolved destination primary object within Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner"
success_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-DUPLICATE-PRESENTATION-OWNER-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the route-failure reason and Try again control while Root app shell explicit state contract / Unavailable Route Duplicate Presentation Owner remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-DUPLICATE-PRESENTATION-OWNER-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-DUPLICATE-PRESENTATION-OWNER-002"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-ORPHAN-DEPTH"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Return => destination: the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Root app shell explicit state contract / Unavailable Route Orphan Depth; effect: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Root app shell explicit state contract / Unavailable Route Orphan Depth reports the outcome from this visible condition: This link points beyond an available detail view; focus: the owner root primary object or Today Start here heading within Root app shell explicit state contract / Unavailable Route Orphan Depth.\nTry again => destination: the original route only when current-revision route resolution succeeds; otherwise the same visible failure status. The handoff starts from Root app shell explicit state contract / Unavailable Route Orphan Depth; effect: No durable mutation occurs and no Receipt is created; only route resolution is retried; neither an object mutation nor repetition of the prior command occurs; Root app shell explicit state contract / Unavailable Route Orphan Depth reports the outcome from this visible condition: This link points beyond an available detail view; focus: the resolved destination primary object within Root app shell explicit state contract / Unavailable Route Orphan Depth."
durable_effect = "Exact command consequences: Return: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data | Try again: No durable mutation occurs and no Receipt is created; only route resolution is retried; no object mutation or prior command is repeated. The durable boundary is specific to this visible evidence: This link points beyond an available detail view."
recovery_rollback = "Exact rollback and recovery: Return: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Try again: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This link points beyond an available detail view."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: This link points beyond an available detail view."
accessibility_focus = "VoiceOver focus contract: Return announces its consequence, then success focuses the owner root primary object or Today Start here heading; rejection focuses the visible route-failure status and Return control | Try again announces its consequence, then success focuses the resolved destination primary object; rejection focuses the route-failure reason and Try again control. The announcement includes this user-facing evidence before focus moves: This link points beyond an available detail view."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-ORPHAN-DEPTH-001"
label = "Return"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Root app shell explicit state contract / Unavailable Route Orphan Depth"
destination_id = "DEST-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-ORPHAN-DEPTH-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Root app shell explicit state contract / Unavailable Route Orphan Depth reports the outcome from this visible condition: This link points beyond an available detail view"
success_focus = "the owner root primary object or Today Start here heading within Root app shell explicit state contract / Unavailable Route Orphan Depth"
success_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-ORPHAN-DEPTH-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible route-failure status and Return control while Root app shell explicit state contract / Unavailable Route Orphan Depth remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-ORPHAN-DEPTH-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-ORPHAN-DEPTH-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-ORPHAN-DEPTH-002"
label = "Try again"
canonical_owner = "app.shell.command-contract"
preconditions = ["Route resolution is idempotent for the current revision", "The original route and target identity are retained"]
destination = "the original route only when current-revision route resolution succeeds; otherwise the same visible failure status. The handoff starts from Root app shell explicit state contract / Unavailable Route Orphan Depth"
destination_id = "DEST-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-ORPHAN-DEPTH-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; only route resolution is retried; neither an object mutation nor repetition of the prior command occurs; Root app shell explicit state contract / Unavailable Route Orphan Depth reports the outcome from this visible condition: This link points beyond an available detail view"
success_focus = "the resolved destination primary object within Root app shell explicit state contract / Unavailable Route Orphan Depth"
success_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-ORPHAN-DEPTH-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the route-failure reason and Try again control while Root app shell explicit state contract / Unavailable Route Orphan Depth remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-ORPHAN-DEPTH-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-ORPHAN-DEPTH-002"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-STALE-OBJECT-REFERENCE"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Return => destination: the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Root app shell explicit state contract / Unavailable Route Stale Object Reference; effect: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Root app shell explicit state contract / Unavailable Route Stale Object Reference reports the outcome from this visible condition: This link points to an item that has changed, moved, or been removed; focus: the owner root primary object or Today Start here heading within Root app shell explicit state contract / Unavailable Route Stale Object Reference.\nTry again => destination: the original route only when current-revision route resolution succeeds; otherwise the same visible failure status. The handoff starts from Root app shell explicit state contract / Unavailable Route Stale Object Reference; effect: No durable mutation occurs and no Receipt is created; only route resolution is retried; neither an object mutation nor repetition of the prior command occurs; Root app shell explicit state contract / Unavailable Route Stale Object Reference reports the outcome from this visible condition: This link points to an item that has changed, moved, or been removed; focus: the resolved destination primary object within Root app shell explicit state contract / Unavailable Route Stale Object Reference."
durable_effect = "Exact command consequences: Return: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data | Try again: No durable mutation occurs and no Receipt is created; only route resolution is retried; no object mutation or prior command is repeated. The durable boundary is specific to this visible evidence: This link points to an item that has changed, moved, or been removed."
recovery_rollback = "Exact rollback and recovery: Return: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Try again: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This link points to an item that has changed, moved, or been removed."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: This link points to an item that has changed, moved, or been removed."
accessibility_focus = "VoiceOver focus contract: Return announces its consequence, then success focuses the owner root primary object or Today Start here heading; rejection focuses the visible route-failure status and Return control | Try again announces its consequence, then success focuses the resolved destination primary object; rejection focuses the route-failure reason and Try again control. The announcement includes this user-facing evidence before focus moves: This link points to an item that has changed, moved, or been removed."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-STALE-OBJECT-REFERENCE-001"
label = "Return"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Root app shell explicit state contract / Unavailable Route Stale Object Reference"
destination_id = "DEST-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-STALE-OBJECT-REFERENCE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Root app shell explicit state contract / Unavailable Route Stale Object Reference reports the outcome from this visible condition: This link points to an item that has changed, moved, or been removed"
success_focus = "the owner root primary object or Today Start here heading within Root app shell explicit state contract / Unavailable Route Stale Object Reference"
success_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-STALE-OBJECT-REFERENCE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible route-failure status and Return control while Root app shell explicit state contract / Unavailable Route Stale Object Reference remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-STALE-OBJECT-REFERENCE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-STALE-OBJECT-REFERENCE-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-STALE-OBJECT-REFERENCE-002"
label = "Try again"
canonical_owner = "app.shell.command-contract"
preconditions = ["Route resolution is idempotent for the current revision", "The original route and target identity are retained"]
destination = "the original route only when current-revision route resolution succeeds; otherwise the same visible failure status. The handoff starts from Root app shell explicit state contract / Unavailable Route Stale Object Reference"
destination_id = "DEST-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-STALE-OBJECT-REFERENCE-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; only route resolution is retried; neither an object mutation nor repetition of the prior command occurs; Root app shell explicit state contract / Unavailable Route Stale Object Reference reports the outcome from this visible condition: This link points to an item that has changed, moved, or been removed"
success_focus = "the resolved destination primary object within Root app shell explicit state contract / Unavailable Route Stale Object Reference"
success_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-STALE-OBJECT-REFERENCE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the route-failure reason and Try again control while Root app shell explicit state contract / Unavailable Route Stale Object Reference remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-STALE-OBJECT-REFERENCE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-STALE-OBJECT-REFERENCE-002"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNAUTHORIZED-TARGET"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Return => destination: the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Root app shell explicit state contract / Unavailable Route Unauthorized Target; effect: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Root app shell explicit state contract / Unavailable Route Unauthorized Target reports the outcome from this visible condition: This destination is not available with the current access; focus: the owner root primary object or Today Start here heading within Root app shell explicit state contract / Unavailable Route Unauthorized Target.\nTry again => destination: the original route only when current-revision route resolution succeeds; otherwise the same visible failure status. The handoff starts from Root app shell explicit state contract / Unavailable Route Unauthorized Target; effect: No durable mutation occurs and no Receipt is created; only route resolution is retried; neither an object mutation nor repetition of the prior command occurs; Root app shell explicit state contract / Unavailable Route Unauthorized Target reports the outcome from this visible condition: This destination is not available with the current access; focus: the resolved destination primary object within Root app shell explicit state contract / Unavailable Route Unauthorized Target."
durable_effect = "Exact command consequences: Return: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data | Try again: No durable mutation occurs and no Receipt is created; only route resolution is retried; no object mutation or prior command is repeated. The durable boundary is specific to this visible evidence: This destination is not available with the current access."
recovery_rollback = "Exact rollback and recovery: Return: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Try again: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This destination is not available with the current access."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: This destination is not available with the current access."
accessibility_focus = "VoiceOver focus contract: Return announces its consequence, then success focuses the owner root primary object or Today Start here heading; rejection focuses the visible route-failure status and Return control | Try again announces its consequence, then success focuses the resolved destination primary object; rejection focuses the route-failure reason and Try again control. The announcement includes this user-facing evidence before focus moves: This destination is not available with the current access."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNAUTHORIZED-TARGET-001"
label = "Return"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Root app shell explicit state contract / Unavailable Route Unauthorized Target"
destination_id = "DEST-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNAUTHORIZED-TARGET-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Root app shell explicit state contract / Unavailable Route Unauthorized Target reports the outcome from this visible condition: This destination is not available with the current access"
success_focus = "the owner root primary object or Today Start here heading within Root app shell explicit state contract / Unavailable Route Unauthorized Target"
success_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNAUTHORIZED-TARGET-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible route-failure status and Return control while Root app shell explicit state contract / Unavailable Route Unauthorized Target remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNAUTHORIZED-TARGET-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNAUTHORIZED-TARGET-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNAUTHORIZED-TARGET-002"
label = "Try again"
canonical_owner = "app.shell.command-contract"
preconditions = ["Route resolution is idempotent for the current revision", "The original route and target identity are retained"]
destination = "the original route only when current-revision route resolution succeeds; otherwise the same visible failure status. The handoff starts from Root app shell explicit state contract / Unavailable Route Unauthorized Target"
destination_id = "DEST-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNAUTHORIZED-TARGET-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; only route resolution is retried; neither an object mutation nor repetition of the prior command occurs; Root app shell explicit state contract / Unavailable Route Unauthorized Target reports the outcome from this visible condition: This destination is not available with the current access"
success_focus = "the resolved destination primary object within Root app shell explicit state contract / Unavailable Route Unauthorized Target"
success_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNAUTHORIZED-TARGET-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the route-failure reason and Try again control while Root app shell explicit state contract / Unavailable Route Unauthorized Target remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNAUTHORIZED-TARGET-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNAUTHORIZED-TARGET-002"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNKNOWN-OWNER"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Return => destination: the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Root app shell explicit state contract / Unavailable Route Unknown Owner; effect: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Root app shell explicit state contract / Unavailable Route Unknown Owner reports the outcome from this visible condition: This link has no recognized destination in Ambitions; focus: the owner root primary object or Today Start here heading within Root app shell explicit state contract / Unavailable Route Unknown Owner.\nTry again => destination: the original route only when current-revision route resolution succeeds; otherwise the same visible failure status. The handoff starts from Root app shell explicit state contract / Unavailable Route Unknown Owner; effect: No durable mutation occurs and no Receipt is created; only route resolution is retried; neither an object mutation nor repetition of the prior command occurs; Root app shell explicit state contract / Unavailable Route Unknown Owner reports the outcome from this visible condition: This link has no recognized destination in Ambitions; focus: the resolved destination primary object within Root app shell explicit state contract / Unavailable Route Unknown Owner."
durable_effect = "Exact command consequences: Return: No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data | Try again: No durable mutation occurs and no Receipt is created; only route resolution is retried; no object mutation or prior command is repeated. The durable boundary is specific to this visible evidence: This link has no recognized destination in Ambitions."
recovery_rollback = "Exact rollback and recovery: Return: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Try again: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This link has no recognized destination in Ambitions."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: This link has no recognized destination in Ambitions."
accessibility_focus = "VoiceOver focus contract: Return announces its consequence, then success focuses the owner root primary object or Today Start here heading; rejection focuses the visible route-failure status and Return control | Try again announces its consequence, then success focuses the resolved destination primary object; rejection focuses the route-failure reason and Try again control. The announcement includes this user-facing evidence before focus moves: This link has no recognized destination in Ambitions."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNKNOWN-OWNER-001"
label = "Return"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the preserved authoritative owner root; if that owner is invalid, Today root. The handoff starts from Root app shell explicit state contract / Unavailable Route Unknown Owner"
destination_id = "DEST-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNKNOWN-OWNER-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the unavailable or restoration route is abandoned without changing product data; Root app shell explicit state contract / Unavailable Route Unknown Owner reports the outcome from this visible condition: This link has no recognized destination in Ambitions"
success_focus = "the owner root primary object or Today Start here heading within Root app shell explicit state contract / Unavailable Route Unknown Owner"
success_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNKNOWN-OWNER-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible route-failure status and Return control while Root app shell explicit state contract / Unavailable Route Unknown Owner remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNKNOWN-OWNER-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNKNOWN-OWNER-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNKNOWN-OWNER-002"
label = "Try again"
canonical_owner = "app.shell.command-contract"
preconditions = ["Route resolution is idempotent for the current revision", "The original route and target identity are retained"]
destination = "the original route only when current-revision route resolution succeeds; otherwise the same visible failure status. The handoff starts from Root app shell explicit state contract / Unavailable Route Unknown Owner"
destination_id = "DEST-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNKNOWN-OWNER-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; only route resolution is retried; neither an object mutation nor repetition of the prior command occurs; Root app shell explicit state contract / Unavailable Route Unknown Owner reports the outcome from this visible condition: This link has no recognized destination in Ambitions"
success_focus = "the resolved destination primary object within Root app shell explicit state contract / Unavailable Route Unknown Owner"
success_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNKNOWN-OWNER-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the route-failure reason and Try again control while Root app shell explicit state contract / Unavailable Route Unknown Owner remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNKNOWN-OWNER-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-UNKNOWN-OWNER-002"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-ROOT-YOU-SELECTED"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open You => destination: the You Stage root. The handoff starts from Root app shell explicit state contract / You Selected; effect: No durable mutation occurs and no Receipt is created; the active root changes to You while the prior root state is preserved; Root app shell explicit state contract / You Selected reports the outcome from this visible condition: You is selected. The current settings section remains in view; focus: the You primary object within Root app shell explicit state contract / You Selected."
durable_effect = "Exact command consequences: Open You: No durable mutation occurs and no Receipt is created; the active root changes to You while the prior root state is preserved. The durable boundary is specific to this visible evidence: You is selected. The current settings section remains in view."
recovery_rollback = "Exact rollback and recovery: Open You: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: You is selected. The current settings section remains in view."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: You is selected. The current settings section remains in view."
accessibility_focus = "VoiceOver focus contract: Open You announces its consequence, then success focuses the You primary object; rejection focuses the You root action in the root dock. The announcement includes this user-facing evidence before focus moves: You is selected. The current settings section remains in view."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-ROOT-YOU-SELECTED-001"
label = "Open You"
canonical_owner = "app.shell.command-contract"
preconditions = ["The root switch request is current", "You is one of the four canonical roots"]
destination = "the You Stage root. The handoff starts from Root app shell explicit state contract / You Selected"
destination_id = "DEST-APP-SHELL-ROOT-YOU-SELECTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the active root changes to You while the prior root state is preserved; Root app shell explicit state contract / You Selected reports the outcome from this visible condition: You is selected. The current settings section remains in view"
success_focus = "the You primary object within Root app shell explicit state contract / You Selected"
success_focus_id = "FOCUS-APP-SHELL-ROOT-YOU-SELECTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the You root action in the root dock while Root app shell explicit state contract / You Selected remains visible"
failure_focus_id = "FOCUS-APP-SHELL-ROOT-YOU-SELECTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-APP-SHELL-ROOT-YOU-SELECTED-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-SEARCH-CAPTURE-CAPTURE-PRESENTED"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Close => destination: the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Global action placement explicit state contract / Capture Presented; effect: No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Global action placement explicit state contract / Capture Presented reports the outcome from this visible condition: Capture is open above the current screen. Anything already entered remains in the composer; this command preserves accepted product state; focus: the stored origin focus ID or invoking control; otherwise the owner root primary object within Global action placement explicit state contract / Capture Presented."
durable_effect = "Exact command consequences: Close: No durable mutation occurs and no Receipt is created; the presented sheet, overlay, Capture, Search, or Trust inspection closes while product objects remain unchanged. The durable boundary is specific to this visible evidence: Capture is open above the current screen. Anything already entered remains in the composer."
recovery_rollback = "Exact rollback and recovery: Close: No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation. Recovery preserves or restores the interface evidence that says: Capture is open above the current screen. Anything already entered remains in the composer."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: Capture is open above the current screen. Anything already entered remains in the composer."
accessibility_focus = "VoiceOver focus contract: Close announces its consequence, then success focuses the stored origin focus ID or invoking control; otherwise the owner root primary object; rejection focuses the visible presentation status and its Close control. The announcement includes this user-facing evidence before focus moves: Capture is open above the current screen. Anything already entered remains in the composer."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-SEARCH-CAPTURE-CAPTURE-PRESENTED-001"
label = "Close"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Global action placement explicit state contract / Capture Presented"
destination_id = "DEST-APP-SHELL-SEARCH-CAPTURE-CAPTURE-PRESENTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Global action placement explicit state contract / Capture Presented reports the outcome from this visible condition: Capture is open above the current screen. Anything already entered remains in the composer; this command preserves accepted product state"
success_focus = "the stored origin focus ID or invoking control; otherwise the owner root primary object within Global action placement explicit state contract / Capture Presented"
success_focus_id = "FOCUS-APP-SHELL-SEARCH-CAPTURE-CAPTURE-PRESENTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible presentation status and its Close control while Global action placement explicit state contract / Capture Presented remains visible"
failure_focus_id = "FOCUS-APP-SHELL-SEARCH-CAPTURE-CAPTURE-PRESENTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation."
recovery_id = "RECOVERY-APP-SHELL-SEARCH-CAPTURE-CAPTURE-PRESENTED-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-SEARCH-CAPTURE-IDLE"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Close => destination: the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Global action placement explicit state contract / Idle; effect: No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Global action placement explicit state contract / Idle reports the outcome from this visible condition: Capture and Search are closed. The current screen and keyboard focus remain unchanged; this command preserves accepted product state; focus: the stored origin focus ID or invoking control; otherwise the owner root primary object within Global action placement explicit state contract / Idle."
durable_effect = "Exact command consequences: Close: No durable mutation occurs and no Receipt is created; the presented sheet, overlay, Capture, Search, or Trust inspection closes while product objects remain unchanged. The durable boundary is specific to this visible evidence: Capture and Search are closed. The current screen and keyboard focus remain unchanged."
recovery_rollback = "Exact rollback and recovery: Close: No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation. Recovery preserves or restores the interface evidence that says: Capture and Search are closed. The current screen and keyboard focus remain unchanged."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: Capture and Search are closed. The current screen and keyboard focus remain unchanged."
accessibility_focus = "VoiceOver focus contract: Close announces its consequence, then success focuses the stored origin focus ID or invoking control; otherwise the owner root primary object; rejection focuses the visible presentation status and its Close control. The announcement includes this user-facing evidence before focus moves: Capture and Search are closed. The current screen and keyboard focus remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-SEARCH-CAPTURE-IDLE-001"
label = "Close"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Global action placement explicit state contract / Idle"
destination_id = "DEST-APP-SHELL-SEARCH-CAPTURE-IDLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Global action placement explicit state contract / Idle reports the outcome from this visible condition: Capture and Search are closed. The current screen and keyboard focus remain unchanged; this command preserves accepted product state"
success_focus = "the stored origin focus ID or invoking control; otherwise the owner root primary object within Global action placement explicit state contract / Idle"
success_focus_id = "FOCUS-APP-SHELL-SEARCH-CAPTURE-IDLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible presentation status and its Close control while Global action placement explicit state contract / Idle remains visible"
failure_focus_id = "FOCUS-APP-SHELL-SEARCH-CAPTURE-IDLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation."
recovery_id = "RECOVERY-APP-SHELL-SEARCH-CAPTURE-IDLE-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-SEARCH-CAPTURE-RETURNING-FOCUS"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Close => destination: the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Global action placement explicit state contract / Returning Focus; effect: No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Global action placement explicit state contract / Returning Focus reports the outcome from this visible condition: Capture or Search has closed. The screen used before it opened remains visible; this command preserves accepted product state; focus: the stored origin focus ID or invoking control; otherwise the owner root primary object within Global action placement explicit state contract / Returning Focus."
durable_effect = "Exact command consequences: Close: No durable mutation occurs and no Receipt is created; the presented sheet, overlay, Capture, Search, or Trust inspection closes while product objects remain unchanged. The durable boundary is specific to this visible evidence: Capture or Search has closed. The screen used before it opened remains visible."
recovery_rollback = "Exact rollback and recovery: Close: No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation. Recovery preserves or restores the interface evidence that says: Capture or Search has closed. The screen used before it opened remains visible."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: Capture or Search has closed. The screen used before it opened remains visible."
accessibility_focus = "VoiceOver focus contract: Close announces its consequence, then success focuses the stored origin focus ID or invoking control; otherwise the owner root primary object; rejection focuses the visible presentation status and its Close control. The announcement includes this user-facing evidence before focus moves: Capture or Search has closed. The screen used before it opened remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-SEARCH-CAPTURE-RETURNING-FOCUS-001"
label = "Close"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Global action placement explicit state contract / Returning Focus"
destination_id = "DEST-APP-SHELL-SEARCH-CAPTURE-RETURNING-FOCUS-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Global action placement explicit state contract / Returning Focus reports the outcome from this visible condition: Capture or Search has closed. The screen used before it opened remains visible; this command preserves accepted product state"
success_focus = "the stored origin focus ID or invoking control; otherwise the owner root primary object within Global action placement explicit state contract / Returning Focus"
success_focus_id = "FOCUS-APP-SHELL-SEARCH-CAPTURE-RETURNING-FOCUS-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible presentation status and its Close control while Global action placement explicit state contract / Returning Focus remains visible"
failure_focus_id = "FOCUS-APP-SHELL-SEARCH-CAPTURE-RETURNING-FOCUS-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation."
recovery_id = "RECOVERY-APP-SHELL-SEARCH-CAPTURE-RETURNING-FOCUS-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-SHELL-SEARCH-CAPTURE-SEARCH-PRESENTED"
requirement_id = "SPEC-APP-SHELL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Close => destination: the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Global action placement explicit state contract / Search Presented; effect: No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Global action placement explicit state contract / Search Presented reports the outcome from this visible condition: Search is open above the current screen. The current query and results remain private on this device; this command preserves accepted product state; focus: the stored origin focus ID or invoking control; otherwise the owner root primary object within Global action placement explicit state contract / Search Presented."
durable_effect = "Exact command consequences: Close: No durable mutation occurs and no Receipt is created; the presented sheet, overlay, Capture, Search, or Trust inspection closes while product objects remain unchanged. The durable boundary is specific to this visible evidence: Search is open above the current screen. The current query and results remain private on this device."
recovery_rollback = "Exact rollback and recovery: Close: No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation. Recovery preserves or restores the interface evidence that says: Search is open above the current screen. The current query and results remain private on this device."
offline_behavior = "Shell routing, origin restoration, canonical-root fallback, and focus return use local route state without an account or network. Offline rendering retains this state evidence: Search is open above the current screen. The current query and results remain private on this device."
accessibility_focus = "VoiceOver focus contract: Close announces its consequence, then success focuses the stored origin focus ID or invoking control; otherwise the owner root primary object; rejection focuses the visible presentation status and its Close control. The announcement includes this user-facing evidence before focus moves: Search is open above the current screen. The current query and results remain private on this device."

[[state_command_contracts.commands]]
command_id = "CMD-APP-SHELL-SEARCH-CAPTURE-SEARCH-PRESENTED-001"
label = "Close"
canonical_owner = "app.shell.command-contract"
preconditions = ["Stored origin route, origin object ID, origin revision, and origin focus ID are available", "The current shell route revision is valid"]
destination = "the still-valid origin route and origin object; otherwise the authoritative owner root, with Today root as the final fallback. The handoff starts from Global action placement explicit state contract / Search Presented"
destination_id = "DEST-APP-SHELL-SEARCH-CAPTURE-SEARCH-PRESENTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the presented view closes while product objects remain unchanged; presentation types include sheet, overlay, Capture, Search, and Trust inspection; Global action placement explicit state contract / Search Presented reports the outcome from this visible condition: Search is open above the current screen. The current query and results remain private on this device; this command preserves accepted product state"
success_focus = "the stored origin focus ID or invoking control; otherwise the owner root primary object within Global action placement explicit state contract / Search Presented"
success_focus_id = "FOCUS-APP-SHELL-SEARCH-CAPTURE-SEARCH-PRESENTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the visible presentation status and its Close control while Global action placement explicit state contract / Search Presented remains visible"
failure_focus_id = "FOCUS-APP-SHELL-SEARCH-CAPTURE-SEARCH-PRESENTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the origin route/object/focus tuple and never guesses another object or repeats a mutation."
recovery_id = "RECOVERY-APP-SHELL-SEARCH-CAPTURE-SEARCH-PRESENTED-001"
recovery_posture = "current"
recovery_owner = "app.shell.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-APP-SHELL-COMMAND-CONTRACT-001"]
+++

# App Shell

This specification defines intended app-shell composition.

## SPEC-APP-SHELL-ROOT-NAVIGATION-001 — Root-depth shell ownership

- **Concept:** `app.shell.root-navigation`
- **Modality:** `MUST`
- **Scope:** Shell chrome at root depth and while leaving root depth
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SHELL-ROOT-001`, `SCENARIO-APP-SHELL-DEPTH-002`
- **Supersedes:** none

The shell MUST have one state owner for the selected root, four independent
root-local paths and selections, global presentation, crown context, dock
posture, selected-root-aware depth, editing presentation, restoration, focus
return, and external origin. Depth and chrome MUST derive only from the selected
root path; an inactive root cannot drive active-root chrome.

The target root selector is the right-edge Crowned Edge Dock defined by
`AVF-SHELL-S07-R01`. It exposes Today, Goals, Time, and You in constitutional
order and separately exposes global Search and Capture. Search and Capture are
full-screen temporary presentations, never roots, tabs, inboxes, or canonical
stores. The dock is planned architecture until reconstruction and direct proof;
current source presence does not establish compliance.

The dock MUST implement Hidden, Peek, Expanded, labelled accessibility, opaque
Reduce Transparency, mirrored handedness, RTL, keyboard-aware, and lower-reach
equivalents through one shell-owned posture model. Assistive use MUST expose
labelled selection and actions without requiring edge discovery, drag, long
press, position, color, material, or motion. Native Back and the leading-edge
interactive gesture remain framework-owned and cannot be intercepted by dock
geometry after mirroring.

## SPEC-APP-SHELL-GLOBAL-ACTIONS-001 — Integrated global-action access

- **Concept:** `app.shell.global-actions`
- **Modality:** `MUST`
- **Scope:** Shell access points for global Capture and Search
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SHELL-GLOBAL-ACTIONS-001`, `AUDIT-APP-SHELL-DUPLICATE-CONTROL-001`
- **Supersedes:** none

The shell MUST provide Crowned Edge Dock access to the constitutionally
non-root global systems without making either a root or alternate mutation
owner. The shell owns entry, full-screen presentation containment, origin,
return context, focus transfer, and duplicate-control prevention. Search and
Capture own their session state and transfer mutations to canonical owners.

No duplicate first-viewport or floating action may obscure content. Alternate
keyboard and accessibility commands invoke the same global presentation owner.

## SPEC-APP-SHELL-FIRST-VIEWPORT-001 — Product object dominates shell chrome

- **Concept:** `app.shell.first-viewport`
- **Modality:** `MUST`
- **Scope:** Every root first viewport
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SHELL-FIRST-VIEWPORT-001`, `PROOF-APP-SHELL-HIERARCHY-001`
- **Supersedes:** none

The shell MUST reserve system safe areas for status, compact contextual actions, the active surface, and root navigation while leaving the active surface's primary product object visually and semantically dominant. Atmosphere may extend full-screen; readable content and controls remain safe. Shell material must feel integrated rather than boxed, bordered, detached, or layered over the product object. No shell action may obscure actionable content.

A floating plus button MUST NOT obscure content.

A product object MUST dominate shell chrome. The compact semantic crown may
identify the selected root or focused object and its contextual actions, but it
must not become a heavy header, duplicate owner, or obstacle to native Back,
Dynamic Type, safe areas, keyboard focus, or localization.

## APP-SHELL-STATE-001 — Shell state follows route state

- **Concept:** `app.shell.state`
- **Modality:** `MUST`
- **Scope:** Root, drilldown, overlay, inspection, restoration, and unavailable-route states
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SHELL-STATE-001`, `SCENARIO-APP-SHELL-RESTORE-001`
- **Supersedes:** none

Shell state MUST distinguish selected root, each root-local path and selection,
global Search/Capture presentation, crown, dock posture, selected-root-aware
depth, editing presentation, restoration, focus return, and external origin. It
also distinguishes root, drilldown, full-screen overlay, compact modal, deep
inspection, restoration, and unavailable-route presentation states. A shell
transition cannot mutate canonical product data; accepted product actions
remain subject to the constitutional runtime sequence.

Detailed native/custom ownership, dock state, gesture arbitration, restoration,
external-entry, and focus contracts are accepted in
`docs/adr/ADR-2026-07-22-shell-navigation-restoration-reconciliation.md`.

## APP-SHELL-FAILURE-001 — Shell failure preserves a usable local root

- **Concept:** `app.shell.failure-recovery`
- **Modality:** `MUST`
- **Scope:** Shell composition, route-presentation, focus, and chrome failures
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SHELL-FAILURE-001`, `SCENARIO-APP-SHELL-FOCUS-RECOVERY-001`
- **Supersedes:** none

When shell composition or route presentation fails, the app MUST preserve or recover to the nearest valid local state without fabricating success or discarding accepted input. Recovery prefers the current valid root and its preserved state, then a deterministic root anchor. The failure presentation states what remains available, offers a retry or safe return when meaningful, restores focus, and never exposes a blank, duplicate, or unreachable shell.

## SPEC-APP-SHELL-COMMAND-CONTRACT-001 — Exact state command ownership

- **Concept:** `app.shell.command-contract`
- **Modality:** `MUST`
- **Scope:** Structured state command contracts for this specification
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SHELL-COMMAND-CONTRACT-001`
- **Supersedes:** none

The owning specification MUST authorize only the state-bound command labels `Close`, `Open Goals`, `Open Time`, `Open Today`, `Open You`, `Return`, `Try again` for the structured states declared in this file. Every command MUST bind stable state and object identity, current revision, canonical owner, preconditions, destination, exact effect and focus targets; navigation, inspection, selection, preview, refresh, and cancellation remain non-mutating. A durable mutation MUST commit only after current-revision validation and required confirmation through Command -> Event -> Projection -> Receipt -> Replay; cancellation or rejection preserves accepted input, and rollback or Undo uses an owning typed command without rewriting history. Local canonical behavior MUST remain available offline without an account; external results remain separate and retryable without replaying the local commit. Sensitive content MUST remain local unless explicit minimum-field egress review passes. VoiceOver MUST announce object, accepted or rejected outcome, consequence, recovery or Undo availability, and destination focus; no color, motion, gesture, or position may carry command meaning alone. Verification MUST prove every declared state, command, transition, commit boundary, durable effect, rollback, offline, privacy, accessibility, and focus mapping against the structured contract.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
The shell is responsible for root-depth chrome, safe-area composition, contextual global-system entry, presentation containment, return context, and focus handoff.
It is not responsible for constitutional root IA, surface content, Capture/Search behavior, object mutation, or privacy policy.

<!-- canon-section: inputs-outputs -->
Inputs are the current route, presentation depth, active-surface chrome contract, safe-area environment, accessibility environment, and recoverable prior focus. Outputs are one composed shell state, visible chrome policy, presentation handoff, and deterministic return/focus target; no output is canonical product data.

<!-- canon-section: authority-boundary -->
`LAW-SHELL-STAGE-001` and the constitutional IA laws remain authoritative for Stage and root ownership. This file refines shell composition only, references the root set rather than restating it, and delegates all global-system and surface behavior to their owning specifications.

<!-- canon-section: data-classification -->
Shell route and focus state are local operational metadata.

<!-- canon-section: state-model -->
The shell record separates route depth, presentation ownership, return, and focus.

The required shell states are root, drilldown, full-screen overlay, compact modal, deep inspection, restoration, and unavailable route. Transitions retain one active presentation owner and one valid return path; duplicate shell, crown, dock, or global-action ownership is invalid.

<!-- canon-section: failure-recovery -->
Composition, route, or focus failure retains accepted local state, offers retry or safe return, and restores a valid root anchor without fake success. Draft and mutation recovery belong to their owning systems and must not be silently cleared by shell recovery.

<!-- canon-section: local-network-boundary -->
Root switching, shell presentation, Capture/Search entry, dismissal, and recovery remain available without sign-in or network. Network state may affect content owned by another system; it never gates the shell itself.

<!-- canon-section: determinism -->
Given the same valid route, presentation depth, active-surface contract, and accessibility environment, the shell produces the same ownership, visibility, dismissal, and focus policy. Presentation heuristics may not invent a root or duplicate a global action.

<!-- canon-section: observability -->
Scoped proof must be able to inspect route depth, active presentation owner, dock visibility, global-action ownership, return route, focus target, and recovery result without recording private content.

<!-- canon-section: source-ownership -->
Stable implementation routing is `App/` for app assembly and route intake, `Stage/` for shell and presentation ownership, semantic Stage primitives for shared chrome, and `Quality/` for shell proof. The listed paths are implementation mappings, not proof that the behavior is complete.

<!-- canon-section: tests-proof -->
Required proof covers root-only dock visibility, no extra root/global control, native drilldown return, preserved return context, focus restoration, safe-area behavior, VoiceOver labels/actions/order, Dynamic Type, Reduce Motion, Reduce Transparency, contrast, and failure recovery. Current passing evidence is required before any scoped Green claim.

<!-- canon-section: performance-resource-constraints -->
On the oldest supported physical iPhone in an optimized build, measured across 200 root, drilldown, overlay, and dismissal transitions with all four constitutional roots, depth up to 20, and three simultaneous presentation classes, shell policy evaluation MUST complete within 8 ms at P95 and accepted root-switch dispatch within 50 ms at P95. The first stable product frame after dispatch MUST arrive within 100 ms at P95, with no main-thread stall above 50 ms. The 200-transition run MUST add no more than 5 MiB resident memory, perform zero synchronous disk I/O and zero network calls on the interaction path, and leave no duplicate presentation owner. Shell state uses no polling or autonomous background work.
