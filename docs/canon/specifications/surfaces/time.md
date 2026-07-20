+++
spec_id = "SURFACE-TIME"
title = "Time"
kind = "surface"
status = "normative"
owner_domain = "surface-time"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "surface.time.creation-routes",
  "surface.time.cebr-fit",
  "surface.time.day",
  "surface.time.degraded-command-contract",
  "surface.time.detail-command-contract",
  "surface.time.first-viewport",
  "surface.time.imported-source",
  "surface.time.list",
  "surface.time.month",
  "surface.time.object-detail",
  "surface.time.primary-identity",
  "surface.time.purpose",
  "surface.time.search",
  "surface.time.step-membership",
  "surface.time.today-control",
  "surface.time.view-command-contract",
  "surface.time.view-switching",
  "surface.time.views",
  "surface.time.visual-authority",
  "surface.time.visual-geometry",
  "surface.time.week",
  "surface.time.year",
]
inherits = [
  "CONST-IA-ROOT-001",
  "PLATFORM-CALENDAR-REPLACEMENT-001",
  "TIME-EXTERNAL-VISIBILITY-001",
  "CONTROL-MATERIAL-CONFIRMATION-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION", "APP-PERMISSIONS"]
source_owners = [
  "Native/Ambitions/Surfaces/Time/",
  "Native/Ambitions/Core/Time/",
  "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/",
  "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/",
  "Native/Ambitions/Core/LocalRuntimeOS/Continuity/",
  "Native/Ambitions/Core/LocalRuntimeOS/Inspection/",
  "Native/Ambitions/Quality/",
]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DAY-CONFLICTING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Adjust plan => destination: the multi-item Time adjustment review. The handoff starts from Time Day explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Conflicting reports the outcome from this visible condition: A protected-time conflict is visible. Ambitions does not move either time item silently; focus: the affected object and proposed placement consequence within Time Day explicit state contract / Conflicting.\nChange duration => destination: the duration-boundary placement preview. The handoff starts from Time Day explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Conflicting reports the outcome from this visible condition: A protected-time conflict is visible. Ambitions does not move either time item silently; focus: the affected object and proposed placement consequence within Time Day explicit state contract / Conflicting.\nChange start => destination: the start-boundary placement preview. The handoff starts from Time Day explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Conflicting reports the outcome from this visible condition: A protected-time conflict is visible. Ambitions does not move either time item silently; focus: the affected object and proposed placement consequence within Time Day explicit state contract / Conflicting.\nKeep current => destination: the unchanged Time Day object and current placement. The handoff starts from Time Day explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Day explicit state contract / Conflicting reports the outcome from this visible condition: A protected-time conflict is visible. Ambitions does not move either time item silently; this command preserves accepted product state; focus: the unchanged object and placement status within Time Day explicit state contract / Conflicting.\nMove => destination: the object-scoped placement preview. The handoff starts from Time Day explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Conflicting reports the outcome from this visible condition: A protected-time conflict is visible. Ambitions does not move either time item silently; focus: the affected object and proposed placement consequence within Time Day explicit state contract / Conflicting.\nResolve conflict => destination: the revision-bound Time conflict comparison. The handoff starts from Time Day explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed; Time Day explicit state contract / Conflicting reports the outcome from this visible condition: A protected-time conflict is visible. Ambitions does not move either time item silently; focus: the affected object and proposed placement consequence within Time Day explicit state contract / Conflicting."
durable_effect = "Exact command consequences: Adjust plan: No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change duration: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change start: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Keep current: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Resolve conflict: No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed. The durable boundary is specific to this visible evidence: A protected-time conflict is visible. Ambitions does not move either time item silently."
recovery_rollback = "Exact rollback and recovery: Adjust plan: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change duration: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change start: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Keep current: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Resolve conflict: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A protected-time conflict is visible. Ambitions does not move either time item silently."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: A protected-time conflict is visible. Ambitions does not move either time item silently."
accessibility_focus = "VoiceOver focus contract: Adjust plan announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Adjust plan control and exact invalid field or boundary | Change duration announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change duration control and exact invalid field or boundary | Change start announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change start control and exact invalid field or boundary | Keep current announces its consequence, then success focuses the unchanged object and placement status; rejection focuses the Keep current control | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary | Resolve conflict announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Resolve conflict control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: A protected-time conflict is visible. Ambitions does not move either time item silently."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-CONFLICTING-001"
label = "Adjust plan"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the multi-item Time adjustment review. The handoff starts from Time Day explicit state contract / Conflicting"
destination_id = "DEST-TIME-DAY-CONFLICTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Conflicting reports the outcome from this visible condition: A protected-time conflict is visible. Ambitions does not move either time item silently"
success_focus = "the affected object and proposed placement consequence within Time Day explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-DAY-CONFLICTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Adjust plan control and exact invalid field or boundary while Time Day explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-DAY-CONFLICTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-CONFLICTING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-CONFLICTING-002"
label = "Change duration"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the duration-boundary placement preview. The handoff starts from Time Day explicit state contract / Conflicting"
destination_id = "DEST-TIME-DAY-CONFLICTING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Conflicting reports the outcome from this visible condition: A protected-time conflict is visible. Ambitions does not move either time item silently"
success_focus = "the affected object and proposed placement consequence within Time Day explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-DAY-CONFLICTING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change duration control and exact invalid field or boundary while Time Day explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-DAY-CONFLICTING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-CONFLICTING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-CONFLICTING-003"
label = "Change start"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the start-boundary placement preview. The handoff starts from Time Day explicit state contract / Conflicting"
destination_id = "DEST-TIME-DAY-CONFLICTING-003"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Conflicting reports the outcome from this visible condition: A protected-time conflict is visible. Ambitions does not move either time item silently"
success_focus = "the affected object and proposed placement consequence within Time Day explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-DAY-CONFLICTING-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change start control and exact invalid field or boundary while Time Day explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-DAY-CONFLICTING-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-CONFLICTING-003"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-CONFLICTING-004"
label = "Keep current"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["A placement or conflict proposal is open and the current placement revision remains valid"]
destination = "the unchanged Time Day object and current placement. The handoff starts from Time Day explicit state contract / Conflicting"
destination_id = "DEST-TIME-DAY-CONFLICTING-004"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Day explicit state contract / Conflicting reports the outcome from this visible condition: A protected-time conflict is visible. Ambitions does not move either time item silently; this command preserves accepted product state"
success_focus = "the unchanged object and placement status within Time Day explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-DAY-CONFLICTING-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep current control while Time Day explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-DAY-CONFLICTING-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-CONFLICTING-004"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-CONFLICTING-005"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time Day explicit state contract / Conflicting"
destination_id = "DEST-TIME-DAY-CONFLICTING-005"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Conflicting reports the outcome from this visible condition: A protected-time conflict is visible. Ambitions does not move either time item silently"
success_focus = "the affected object and proposed placement consequence within Time Day explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-DAY-CONFLICTING-005-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time Day explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-DAY-CONFLICTING-005-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-CONFLICTING-005"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-CONFLICTING-006"
label = "Resolve conflict"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the revision-bound Time conflict comparison. The handoff starts from Time Day explicit state contract / Conflicting"
destination_id = "DEST-TIME-DAY-CONFLICTING-006"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed; Time Day explicit state contract / Conflicting reports the outcome from this visible condition: A protected-time conflict is visible. Ambitions does not move either time item silently"
success_focus = "the affected object and proposed placement consequence within Time Day explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-DAY-CONFLICTING-006-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Resolve conflict control and exact invalid field or boundary while Time Day explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-DAY-CONFLICTING-006-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-CONFLICTING-006"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DAY-DENSE"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Day. The handoff starts from Time Day explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Day explicit state contract / Dense reports the outcome from this visible condition: This day is busy. Protected and fixed time remains visible without pressure or judgment; focus: the selected object heading or selected date heading within Time Day explicit state contract / Dense."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: This day is busy. Protected and fixed time remains visible without pressure or judgment."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This day is busy. Protected and fixed time remains visible without pressure or judgment."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: This day is busy. Protected and fixed time remains visible without pressure or judgment."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Day object/date control. The announcement includes this user-facing evidence before focus moves: This day is busy. Protected and fixed time remains visible without pressure or judgment."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-DENSE-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Day range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Day. The handoff starts from Time Day explicit state contract / Dense"
destination_id = "DEST-TIME-DAY-DENSE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Day explicit state contract / Dense reports the outcome from this visible condition: This day is busy. Protected and fixed time remains visible without pressure or judgment"
success_focus = "the selected object heading or selected date heading within Time Day explicit state contract / Dense"
success_focus_id = "FOCUS-TIME-DAY-DENSE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Day object/date control while Time Day explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-TIME-DAY-DENSE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-DENSE-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DAY-EDITING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Change duration => destination: the duration-boundary placement preview. The handoff starts from Time Day explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Editing reports the outcome from this visible condition: The saved placement and proposed placement are both visible before Save or Cancel; focus: the affected object and proposed placement consequence within Time Day explicit state contract / Editing.\nChange start => destination: the start-boundary placement preview. The handoff starts from Time Day explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Editing reports the outcome from this visible condition: The saved placement and proposed placement are both visible before Save or Cancel; focus: the affected object and proposed placement consequence within Time Day explicit state contract / Editing.\nEdit => destination: compact canonical object edit detail. The handoff starts from Time Day explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; the editable object fields is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Editing reports the outcome from this visible condition: The saved placement and proposed placement are both visible before Save or Cancel; focus: the affected object and proposed placement consequence within Time Day explicit state contract / Editing.\nMove => destination: the object-scoped placement preview. The handoff starts from Time Day explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Editing reports the outcome from this visible condition: The saved placement and proposed placement are both visible before Save or Cancel; focus: the affected object and proposed placement consequence within Time Day explicit state contract / Editing."
durable_effect = "Exact command consequences: Change duration: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change start: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Edit: No durable mutation occurs and no Receipt is created; the editable object fields is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. The durable boundary is specific to this visible evidence: The saved placement and proposed placement are both visible before Save or Cancel."
recovery_rollback = "Exact rollback and recovery: Change duration: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change start: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Edit: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The saved placement and proposed placement are both visible before Save or Cancel."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The saved placement and proposed placement are both visible before Save or Cancel."
accessibility_focus = "VoiceOver focus contract: Change duration announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change duration control and exact invalid field or boundary | Change start announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change start control and exact invalid field or boundary | Edit announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Edit control and exact invalid field or boundary | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: The saved placement and proposed placement are both visible before Save or Cancel."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-EDITING-001"
label = "Change duration"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the duration-boundary placement preview. The handoff starts from Time Day explicit state contract / Editing"
destination_id = "DEST-TIME-DAY-EDITING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Editing reports the outcome from this visible condition: The saved placement and proposed placement are both visible before Save or Cancel"
success_focus = "the affected object and proposed placement consequence within Time Day explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-DAY-EDITING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change duration control and exact invalid field or boundary while Time Day explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-DAY-EDITING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-EDITING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-EDITING-002"
label = "Change start"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the start-boundary placement preview. The handoff starts from Time Day explicit state contract / Editing"
destination_id = "DEST-TIME-DAY-EDITING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Editing reports the outcome from this visible condition: The saved placement and proposed placement are both visible before Save or Cancel"
success_focus = "the affected object and proposed placement consequence within Time Day explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-DAY-EDITING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change start control and exact invalid field or boundary while Time Day explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-DAY-EDITING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-EDITING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-EDITING-003"
label = "Edit"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "compact canonical object edit detail. The handoff starts from Time Day explicit state contract / Editing"
destination_id = "DEST-TIME-DAY-EDITING-003"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the editable object fields is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Editing reports the outcome from this visible condition: The saved placement and proposed placement are both visible before Save or Cancel"
success_focus = "the affected object and proposed placement consequence within Time Day explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-DAY-EDITING-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Edit control and exact invalid field or boundary while Time Day explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-DAY-EDITING-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-EDITING-003"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-EDITING-004"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time Day explicit state contract / Editing"
destination_id = "DEST-TIME-DAY-EDITING-004"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Editing reports the outcome from this visible condition: The saved placement and proposed placement are both visible before Save or Cancel"
success_focus = "the affected object and proposed placement consequence within Time Day explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-DAY-EDITING-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time Day explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-DAY-EDITING-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-EDITING-004"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DAY-EMPTY"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Today => destination: the current local date in Time Day. The handoff starts from Time Day explicit state contract / Empty; effect: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Day explicit state contract / Empty reports the outcome from this visible condition: No Ambitions Events, Reminders, or protected blocks appear on this day; focus: the current-period date heading within Time Day explicit state contract / Empty."
durable_effect = "Exact command consequences: Today: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts. The durable boundary is specific to this visible evidence: No Ambitions Events, Reminders, or protected blocks appear on this day."
recovery_rollback = "Exact rollback and recovery: Today: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: No Ambitions Events, Reminders, or protected blocks appear on this day."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: No Ambitions Events, Reminders, or protected blocks appear on this day."
accessibility_focus = "VoiceOver focus contract: Today announces its consequence, then success focuses the current-period date heading; rejection focuses the Today control and retained prior range. The announcement includes this user-facing evidence before focus moves: No Ambitions Events, Reminders, or protected blocks appear on this day."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-EMPTY-001"
label = "Today"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The preferred Day view and current local date are available"]
destination = "the current local date in Time Day. The handoff starts from Time Day explicit state contract / Empty"
destination_id = "DEST-TIME-DAY-EMPTY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Day explicit state contract / Empty reports the outcome from this visible condition: No Ambitions Events, Reminders, or protected blocks appear on this day"
success_focus = "the current-period date heading within Time Day explicit state contract / Empty"
success_focus_id = "FOCUS-TIME-DAY-EMPTY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Today control and retained prior range while Time Day explicit state contract / Empty remains visible"
failure_focus_id = "FOCUS-TIME-DAY-EMPTY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-EMPTY-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DAY-EXTERNAL-HIDDEN-CAPACITY"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Day. The handoff starts from Time Day explicit state contract / External Hidden Capacity; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Day explicit state contract / External Hidden Capacity reports the outcome from this visible condition: External details hidden. Day shows occupied intervals only, never title, attendees, notes, or location; focus: the selected object heading or selected date heading within Time Day explicit state contract / External Hidden Capacity."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: External details hidden. Day shows occupied intervals only, never title, attendees, notes, or location."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: External details hidden. Day shows occupied intervals only, never title, attendees, notes, or location."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: External details hidden. Day shows occupied intervals only, never title, attendees, notes, or location."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Day object/date control. The announcement includes this user-facing evidence before focus moves: External details hidden. Day shows occupied intervals only, never title, attendees, notes, or location."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-EXTERNAL-HIDDEN-CAPACITY-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Day range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Day. The handoff starts from Time Day explicit state contract / External Hidden Capacity"
destination_id = "DEST-TIME-DAY-EXTERNAL-HIDDEN-CAPACITY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Day explicit state contract / External Hidden Capacity reports the outcome from this visible condition: External details hidden. Day shows occupied intervals only, never title, attendees, notes, or location"
success_focus = "the selected object heading or selected date heading within Time Day explicit state contract / External Hidden Capacity"
success_focus_id = "FOCUS-TIME-DAY-EXTERNAL-HIDDEN-CAPACITY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Day object/date control while Time Day explicit state contract / External Hidden Capacity remains visible"
failure_focus_id = "FOCUS-TIME-DAY-EXTERNAL-HIDDEN-CAPACITY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-EXTERNAL-HIDDEN-CAPACITY-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DAY-IMPORTING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained Time Day range and pending import summary. The handoff starts from Time Day explicit state contract / Importing; effect: No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt; Time Day explicit state contract / Importing reports the outcome from this visible condition: Outside calendar items are being compared. No Ambitions Event or Reminder has been saved; this command preserves accepted product state; focus: the initiating Day import control or date heading within Time Day explicit state contract / Importing."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt. The durable boundary is specific to this visible evidence: Outside calendar items are being compared. No Ambitions Event or Reminder has been saved."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Outside calendar items are being compared. No Ambitions Event or Reminder has been saved."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Outside calendar items are being compared. No Ambitions Event or Reminder has been saved."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating Day import control or date heading; rejection focuses the import progress status and Cancel control. The announcement includes this user-facing evidence before focus moves: Outside calendar items are being compared. No Ambitions Event or Reminder has been saved."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-IMPORTING-001"
label = "Cancel"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Any accepted import and Receipt are identified separately", "Only pending import comparison or optional loading remains uncommitted"]
destination = "the retained Time Day range and pending import summary. The handoff starts from Time Day explicit state contract / Importing"
destination_id = "DEST-TIME-DAY-IMPORTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt; Time Day explicit state contract / Importing reports the outcome from this visible condition: Outside calendar items are being compared. No Ambitions Event or Reminder has been saved; this command preserves accepted product state"
success_focus = "the initiating Day import control or date heading within Time Day explicit state contract / Importing"
success_focus_id = "FOCUS-TIME-DAY-IMPORTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the import progress status and Cancel control while Time Day explicit state contract / Importing remains visible"
failure_focus_id = "FOCUS-TIME-DAY-IMPORTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-IMPORTING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DAY-NOW-ANCHORED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Today => destination: the current local date in Time Day. The handoff starts from Time Day explicit state contract / Now Anchored; effect: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Day explicit state contract / Now Anchored reports the outcome from this visible condition: Now and Today mark the actual time. The next Event follows chronological order without ranking; focus: the current-period date heading within Time Day explicit state contract / Now Anchored."
durable_effect = "Exact command consequences: Today: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts. The durable boundary is specific to this visible evidence: Now and Today mark the actual time. The next Event follows chronological order without ranking."
recovery_rollback = "Exact rollback and recovery: Today: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Now and Today mark the actual time. The next Event follows chronological order without ranking."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Now and Today mark the actual time. The next Event follows chronological order without ranking."
accessibility_focus = "VoiceOver focus contract: Today announces its consequence, then success focuses the current-period date heading; rejection focuses the Today control and retained prior range. The announcement includes this user-facing evidence before focus moves: Now and Today mark the actual time. The next Event follows chronological order without ranking."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-NOW-ANCHORED-001"
label = "Today"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The preferred Day view and current local date are available"]
destination = "the current local date in Time Day. The handoff starts from Time Day explicit state contract / Now Anchored"
destination_id = "DEST-TIME-DAY-NOW-ANCHORED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Day explicit state contract / Now Anchored reports the outcome from this visible condition: Now and Today mark the actual time. The next Event follows chronological order without ranking"
success_focus = "the current-period date heading within Time Day explicit state contract / Now Anchored"
success_focus_id = "FOCUS-TIME-DAY-NOW-ANCHORED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Today control and retained prior range while Time Day explicit state contract / Now Anchored remains visible"
failure_focus_id = "FOCUS-TIME-DAY-NOW-ANCHORED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-NOW-ANCHORED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DAY-POPULATED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Day. The handoff starts from Time Day explicit state contract / Populated; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Day explicit state contract / Populated reports the outcome from this visible condition: Events, Reminders, and protected blocks appear at their actual times and remain visually distinct; focus: the selected object heading or selected date heading within Time Day explicit state contract / Populated."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: Events, Reminders, and protected blocks appear at their actual times and remain visually distinct."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Events, Reminders, and protected blocks appear at their actual times and remain visually distinct."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Events, Reminders, and protected blocks appear at their actual times and remain visually distinct."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Day object/date control. The announcement includes this user-facing evidence before focus moves: Events, Reminders, and protected blocks appear at their actual times and remain visually distinct."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-POPULATED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Day range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Day. The handoff starts from Time Day explicit state contract / Populated"
destination_id = "DEST-TIME-DAY-POPULATED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Day explicit state contract / Populated reports the outcome from this visible condition: Events, Reminders, and protected blocks appear at their actual times and remain visually distinct"
success_focus = "the selected object heading or selected date heading within Time Day explicit state contract / Populated"
success_focus_id = "FOCUS-TIME-DAY-POPULATED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Day object/date control while Time Day explicit state contract / Populated remains visible"
failure_focus_id = "FOCUS-TIME-DAY-POPULATED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-POPULATED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DAY-PREVIEWING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Keep current => destination: the unchanged Time Day object and current placement. The handoff starts from Time Day explicit state contract / Previewing; effect: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Day explicit state contract / Previewing reports the outcome from this visible condition: The saved time and proposed move are both visible before any change; this command preserves accepted product state; focus: the unchanged object and placement status within Time Day explicit state contract / Previewing.\nMove => destination: the object-scoped placement preview. The handoff starts from Time Day explicit state contract / Previewing; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Previewing reports the outcome from this visible condition: The saved time and proposed move are both visible before any change; focus: the affected object and proposed placement consequence within Time Day explicit state contract / Previewing."
durable_effect = "Exact command consequences: Keep current: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. The durable boundary is specific to this visible evidence: The saved time and proposed move are both visible before any change."
recovery_rollback = "Exact rollback and recovery: Keep current: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The saved time and proposed move are both visible before any change."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The saved time and proposed move are both visible before any change."
accessibility_focus = "VoiceOver focus contract: Keep current announces its consequence, then success focuses the unchanged object and placement status; rejection focuses the Keep current control | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: The saved time and proposed move are both visible before any change."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-PREVIEWING-001"
label = "Keep current"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["A placement or conflict proposal is open and the current placement revision remains valid"]
destination = "the unchanged Time Day object and current placement. The handoff starts from Time Day explicit state contract / Previewing"
destination_id = "DEST-TIME-DAY-PREVIEWING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Day explicit state contract / Previewing reports the outcome from this visible condition: The saved time and proposed move are both visible before any change; this command preserves accepted product state"
success_focus = "the unchanged object and placement status within Time Day explicit state contract / Previewing"
success_focus_id = "FOCUS-TIME-DAY-PREVIEWING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep current control while Time Day explicit state contract / Previewing remains visible"
failure_focus_id = "FOCUS-TIME-DAY-PREVIEWING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-PREVIEWING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-PREVIEWING-002"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time Day explicit state contract / Previewing"
destination_id = "DEST-TIME-DAY-PREVIEWING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Day explicit state contract / Previewing reports the outcome from this visible condition: The saved time and proposed move are both visible before any change"
success_focus = "the affected object and proposed placement consequence within Time Day explicit state contract / Previewing"
success_focus_id = "FOCUS-TIME-DAY-PREVIEWING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time Day explicit state contract / Previewing remains visible"
failure_focus_id = "FOCUS-TIME-DAY-PREVIEWING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-PREVIEWING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DAY-RESTORED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Day. The handoff starts from Time Day explicit state contract / Restored; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Day explicit state contract / Restored reports the outcome from this visible condition: The previously viewed day and selected item are visible again with current saved information; focus: the selected object heading or selected date heading within Time Day explicit state contract / Restored."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The previously viewed day and selected item are visible again with current saved information."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The previously viewed day and selected item are visible again with current saved information."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The previously viewed day and selected item are visible again with current saved information."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Day object/date control. The announcement includes this user-facing evidence before focus moves: The previously viewed day and selected item are visible again with current saved information."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-RESTORED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Day range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Day. The handoff starts from Time Day explicit state contract / Restored"
destination_id = "DEST-TIME-DAY-RESTORED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Day explicit state contract / Restored reports the outcome from this visible condition: The previously viewed day and selected item are visible again with current saved information"
success_focus = "the selected object heading or selected date heading within Time Day explicit state contract / Restored"
success_focus_id = "FOCUS-TIME-DAY-RESTORED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Day object/date control while Time Day explicit state contract / Restored remains visible"
failure_focus_id = "FOCUS-TIME-DAY-RESTORED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-RESTORED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DAY-SELECTED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Day. The handoff starts from Time Day explicit state contract / Selected; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Day explicit state contract / Selected reports the outcome from this visible condition: One Event, Reminder, or protected block is selected. Its saved details are shown; focus: the selected object heading or selected date heading within Time Day explicit state contract / Selected."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: One Event, Reminder, or protected block is selected. Its saved details are shown."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: One Event, Reminder, or protected block is selected. Its saved details are shown."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: One Event, Reminder, or protected block is selected. Its saved details are shown."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Day object/date control. The announcement includes this user-facing evidence before focus moves: One Event, Reminder, or protected block is selected. Its saved details are shown."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DAY-SELECTED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Day range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Day. The handoff starts from Time Day explicit state contract / Selected"
destination_id = "DEST-TIME-DAY-SELECTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Day explicit state contract / Selected reports the outcome from this visible condition: One Event, Reminder, or protected block is selected. Its saved details are shown"
success_focus = "the selected object heading or selected date heading within Time Day explicit state contract / Selected"
success_focus_id = "FOCUS-TIME-DAY-SELECTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Day object/date control while Time Day explicit state contract / Selected remains visible"
failure_focus_id = "FOCUS-TIME-DAY-SELECTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DAY-SELECTED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DEGRADED-EXTERNAL-WRITE-FAILURE"
requirement_id = "SPEC-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Retry external update => destination: the existing external-write result row. The handoff starts from Time degraded-state owner explicit state contract / External Write Failure; effect: No local canonical mutation is replayed; only the failed external update is retried with the durable outbox identity; the accepted local mutation is never replayed and local state remains authoritative; Time degraded-state owner explicit state contract / External Write Failure reports the outcome from this visible condition: The calendar update did not finish. The accepted Ambitions change remains recorded separately; focus: the external result status and local object within Time degraded-state owner explicit state contract / External Write Failure.\nReview details => destination: the object-scoped external or offline detail. The handoff starts from Time degraded-state owner explicit state contract / External Write Failure; effect: No durable mutation occurs and no Receipt is created; local success/capability and unresolved external state are shown separately without retrying or changing either; Time degraded-state owner explicit state contract / External Write Failure reports the outcome from this visible condition: The calendar update did not finish. The accepted Ambitions change remains recorded separately; focus: the local object status followed by external result status within Time degraded-state owner explicit state contract / External Write Failure."
durable_effect = "Exact command consequences: Retry external update: No local canonical mutation is replayed; only the failed external update is retried with the durable outbox identity; the accepted local mutation is never replayed and local state remains authoritative | Review details: No durable mutation occurs and no Receipt is created; local success/capability and unresolved external state are shown separately without retrying or changing either. The durable boundary is specific to this visible evidence: The calendar update did not finish. The accepted Ambitions change remains recorded separately."
recovery_rollback = "Exact rollback and recovery: Retry external update: Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command. | Review details: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The calendar update did not finish. The accepted Ambitions change remains recorded separately."
offline_behavior = "Local Time remains usable offline; source, permission, import, and external-write failures remain narrow and inspectable, and continuity remains disabled under SYSTEM-CONTINUITY-DISABLED-001. Offline rendering retains this state evidence: The calendar update did not finish. The accepted Ambitions change remains recorded separately."
accessibility_focus = "VoiceOver focus contract: Retry external update announces its consequence, then success focuses the external result status and local object; rejection focuses the failed external result and Retry external update control | Review details announces its consequence, then success focuses the local object status followed by external result status; rejection focuses the Review details control. The announcement includes this user-facing evidence before focus moves: The calendar update did not finish. The accepted Ambitions change remains recorded separately."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-EXTERNAL-WRITE-FAILURE-001"
label = "Retry external update"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["The accepted local Event, existing outbox/result ID, current revision, and external failure class exist"]
destination = "the existing external-write result row. The handoff starts from Time degraded-state owner explicit state contract / External Write Failure"
destination_id = "DEST-TIME-DEGRADED-EXTERNAL-WRITE-FAILURE-001"
destination_posture = "current"
effect = "No local canonical mutation is replayed; only the failed external update is retried with the durable outbox identity; the accepted local mutation is never replayed and local state remains authoritative; Time degraded-state owner explicit state contract / External Write Failure reports the outcome from this visible condition: The calendar update did not finish. The accepted Ambitions change remains recorded separately"
success_focus = "the external result status and local object within Time degraded-state owner explicit state contract / External Write Failure"
success_focus_id = "FOCUS-TIME-DEGRADED-EXTERNAL-WRITE-FAILURE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the failed external result and Retry external update control while Time degraded-state owner explicit state contract / External Write Failure remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-EXTERNAL-WRITE-FAILURE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: the existing durable result or outbox identity is revalidated before only the failed external/read operation runs; the accepted local Event is never replayed."
rollback_undo = "Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command."
recovery_id = "RECOVERY-TIME-DEGRADED-EXTERNAL-WRITE-FAILURE-001"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "Only the previously approved minimum payload may leave the device; authorization and SYSTEM-PRIVACY-EGRESS-001 are revalidated and failure remains inspectable."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-EXTERNAL-WRITE-FAILURE-002"
label = "Review details"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["The affected local object and external/offline result are retained"]
destination = "the object-scoped external or offline detail. The handoff starts from Time degraded-state owner explicit state contract / External Write Failure"
destination_id = "DEST-TIME-DEGRADED-EXTERNAL-WRITE-FAILURE-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; local success/capability and unresolved external state are shown separately without retrying or changing either; Time degraded-state owner explicit state contract / External Write Failure reports the outcome from this visible condition: The calendar update did not finish. The accepted Ambitions change remains recorded separately"
success_focus = "the local object status followed by external result status within Time degraded-state owner explicit state contract / External Write Failure"
success_focus_id = "FOCUS-TIME-DEGRADED-EXTERNAL-WRITE-FAILURE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review details control while Time degraded-state owner explicit state contract / External Write Failure remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-EXTERNAL-WRITE-FAILURE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DEGRADED-EXTERNAL-WRITE-FAILURE-002"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DEGRADED-LOCAL-STORE-DEGRADATION"
requirement_id = "SPEC-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open diagnostics => destination: the focused redacted diagnostics detail in You. The handoff starts from Time degraded-state owner explicit state contract / Local Store Degradation; effect: No durable mutation occurs and no Receipt is created; diagnostics open without changing the store, objects, or last verified projection; Time degraded-state owner explicit state contract / Local Store Degradation reports the outcome from this visible condition: Some saved Time information is unavailable while safe recovery options are checked; focus: the local-store diagnostic summary within Time degraded-state owner explicit state contract / Local Store Degradation.\nRetry local store => destination: the same local-store recovery status. The handoff starts from Time degraded-state owner explicit state contract / Local Store Degradation; effect: No local canonical mutation is replayed; only local-store availability and durable verification are retried; no saved-success state appears until verification succeeds and no product mutation is replayed; Time degraded-state owner explicit state contract / Local Store Degradation reports the outcome from this visible condition: Some saved Time information is unavailable while safe recovery options are checked; focus: the verified local-store status or retained last verified projection within Time degraded-state owner explicit state contract / Local Store Degradation."
durable_effect = "Exact command consequences: Open diagnostics: No durable mutation occurs and no Receipt is created; diagnostics open without changing the store, objects, or last verified projection | Retry local store: No local canonical mutation is replayed; only local-store availability and durable verification are retried; no saved-success state appears until verification succeeds and no product mutation is replayed. The durable boundary is specific to this visible evidence: Some saved Time information is unavailable while safe recovery options are checked."
recovery_rollback = "Exact rollback and recovery: Open diagnostics: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Retry local store: Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command. Recovery preserves or restores the interface evidence that says: Some saved Time information is unavailable while safe recovery options are checked."
offline_behavior = "Local Time remains usable offline; source, permission, import, and external-write failures remain narrow and inspectable, and continuity remains disabled under SYSTEM-CONTINUITY-DISABLED-001. Offline rendering retains this state evidence: Some saved Time information is unavailable while safe recovery options are checked."
accessibility_focus = "VoiceOver focus contract: Open diagnostics announces its consequence, then success focuses the local-store diagnostic summary; rejection focuses the Open diagnostics control and local-store status | Retry local store announces its consequence, then success focuses the verified local-store status or retained last verified projection; rejection focuses the local-store failure reason and Retry local store control. The announcement includes this user-facing evidence before focus moves: Some saved Time information is unavailable while safe recovery options are checked."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-LOCAL-STORE-DEGRADATION-001"
label = "Open diagnostics"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["The local-store failure class is redacted and the last verified projection is retained"]
destination = "the focused redacted diagnostics detail in You. The handoff starts from Time degraded-state owner explicit state contract / Local Store Degradation"
destination_id = "DEST-TIME-DEGRADED-LOCAL-STORE-DEGRADATION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; diagnostics open without changing the store, objects, or last verified projection; Time degraded-state owner explicit state contract / Local Store Degradation reports the outcome from this visible condition: Some saved Time information is unavailable while safe recovery options are checked"
success_focus = "the local-store diagnostic summary within Time degraded-state owner explicit state contract / Local Store Degradation"
success_focus_id = "FOCUS-TIME-DEGRADED-LOCAL-STORE-DEGRADATION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open diagnostics control and local-store status while Time degraded-state owner explicit state contract / Local Store Degradation remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-LOCAL-STORE-DEGRADATION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DEGRADED-LOCAL-STORE-DEGRADATION-001"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "Only redacted health metadata is shown; no private titles or content leave the device."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-LOCAL-STORE-DEGRADATION-002"
label = "Retry local store"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["Mutations are frozen", "The last verified projection and current store failure class are retained"]
destination = "the same local-store recovery status. The handoff starts from Time degraded-state owner explicit state contract / Local Store Degradation"
destination_id = "DEST-TIME-DEGRADED-LOCAL-STORE-DEGRADATION-002"
destination_posture = "current"
effect = "No local canonical mutation is replayed; only local-store availability and durable verification are retried; no saved-success state appears until verification succeeds and no product mutation is replayed; Time degraded-state owner explicit state contract / Local Store Degradation reports the outcome from this visible condition: Some saved Time information is unavailable while safe recovery options are checked"
success_focus = "the verified local-store status or retained last verified projection within Time degraded-state owner explicit state contract / Local Store Degradation"
success_focus_id = "FOCUS-TIME-DEGRADED-LOCAL-STORE-DEGRADATION-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the local-store failure reason and Retry local store control while Time degraded-state owner explicit state contract / Local Store Degradation remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-LOCAL-STORE-DEGRADATION-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: the existing durable result or outbox identity is revalidated before only the failed external/read operation runs; the accepted local Event is never replayed."
rollback_undo = "Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command."
recovery_id = "RECOVERY-TIME-DEGRADED-LOCAL-STORE-DEGRADATION-002"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "The retry is entirely local and performs no network or egress operation."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DEGRADED-OFFLINE-HEALTHY"
requirement_id = "SPEC-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review details => destination: the object-scoped external or offline detail. The handoff starts from Time degraded-state owner explicit state contract / Offline Healthy; effect: No durable mutation occurs and no Receipt is created; local success/capability and unresolved external state are shown separately without retrying or changing either; Time degraded-state owner explicit state contract / Offline Healthy reports the outcome from this visible condition: Time works from saved local information without a connection; focus: the local object status followed by external result status within Time degraded-state owner explicit state contract / Offline Healthy."
durable_effect = "Exact command consequences: Review details: No durable mutation occurs and no Receipt is created; local success/capability and unresolved external state are shown separately without retrying or changing either. The durable boundary is specific to this visible evidence: Time works from saved local information without a connection."
recovery_rollback = "Exact rollback and recovery: Review details: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Time works from saved local information without a connection."
offline_behavior = "Local Time remains usable offline; source, permission, import, and external-write failures remain narrow and inspectable, and continuity remains disabled under SYSTEM-CONTINUITY-DISABLED-001. Offline rendering retains this state evidence: Time works from saved local information without a connection."
accessibility_focus = "VoiceOver focus contract: Review details announces its consequence, then success focuses the local object status followed by external result status; rejection focuses the Review details control. The announcement includes this user-facing evidence before focus moves: Time works from saved local information without a connection."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-OFFLINE-HEALTHY-001"
label = "Review details"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["The affected local object and external/offline result are retained"]
destination = "the object-scoped external or offline detail. The handoff starts from Time degraded-state owner explicit state contract / Offline Healthy"
destination_id = "DEST-TIME-DEGRADED-OFFLINE-HEALTHY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; local success/capability and unresolved external state are shown separately without retrying or changing either; Time degraded-state owner explicit state contract / Offline Healthy reports the outcome from this visible condition: Time works from saved local information without a connection"
success_focus = "the local object status followed by external result status within Time degraded-state owner explicit state contract / Offline Healthy"
success_focus_id = "FOCUS-TIME-DEGRADED-OFFLINE-HEALTHY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review details control while Time degraded-state owner explicit state contract / Offline Healthy remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-OFFLINE-HEALTHY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DEGRADED-OFFLINE-HEALTHY-001"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DEGRADED-PARTIAL-IMPORT"
requirement_id = "SPEC-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review partial import => destination: the grouped partial-import result review. The handoff starts from Time degraded-state owner explicit state contract / Partial Import; effect: No durable mutation occurs and no Receipt is created; accepted, rejected, and pending records are shown separately; no retry, acceptance, or Undo occurs during review; Time degraded-state owner explicit state contract / Partial Import reports the outcome from this visible condition: Some calendar items were not imported; completed items remain clearly identified; focus: the first failed or pending import record within Time degraded-state owner explicit state contract / Partial Import.\nRetry failed items => destination: the grouped partial-import result. The handoff starts from Time degraded-state owner explicit state contract / Partial Import; effect: No local canonical mutation is replayed; only failed import IDs are retried; accepted records are not duplicated and pending records remain identifiable; Time degraded-state owner explicit state contract / Partial Import reports the outcome from this visible condition: Some calendar items were not imported; completed items remain clearly identified; focus: the first retried record result within Time degraded-state owner explicit state contract / Partial Import."
durable_effect = "Exact command consequences: Review partial import: No durable mutation occurs and no Receipt is created; accepted, rejected, and pending records are shown separately; no retry, acceptance, or Undo occurs during review | Retry failed items: No local canonical mutation is replayed; only failed import IDs are retried; accepted records are not duplicated and pending records remain identifiable. The durable boundary is specific to this visible evidence: Some calendar items were not imported; completed items remain clearly identified."
recovery_rollback = "Exact rollback and recovery: Review partial import: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Retry failed items: Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command. Recovery preserves or restores the interface evidence that says: Some calendar items were not imported; completed items remain clearly identified."
offline_behavior = "Local Time remains usable offline; source, permission, import, and external-write failures remain narrow and inspectable, and continuity remains disabled under SYSTEM-CONTINUITY-DISABLED-001. Offline rendering retains this state evidence: Some calendar items were not imported; completed items remain clearly identified."
accessibility_focus = "VoiceOver focus contract: Review partial import announces its consequence, then success focuses the first failed or pending import record; rejection focuses the Review partial import control | Retry failed items announces its consequence, then success focuses the first retried record result; rejection focuses the first failed record and Retry failed items control. The announcement includes this user-facing evidence before focus moves: Some calendar items were not imported; completed items remain clearly identified."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-PARTIAL-IMPORT-001"
label = "Review partial import"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["The durable import/diff transaction ID and accepted, rejected, and pending record IDs exist"]
destination = "the grouped partial-import result review. The handoff starts from Time degraded-state owner explicit state contract / Partial Import"
destination_id = "DEST-TIME-DEGRADED-PARTIAL-IMPORT-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; accepted, rejected, and pending records are shown separately; no retry, acceptance, or Undo occurs during review; Time degraded-state owner explicit state contract / Partial Import reports the outcome from this visible condition: Some calendar items were not imported; completed items remain clearly identified"
success_focus = "the first failed or pending import record within Time degraded-state owner explicit state contract / Partial Import"
success_focus_id = "FOCUS-TIME-DEGRADED-PARTIAL-IMPORT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review partial import control while Time degraded-state owner explicit state contract / Partial Import remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-PARTIAL-IMPORT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DEGRADED-PARTIAL-IMPORT-001"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-PARTIAL-IMPORT-002"
label = "Retry failed items"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["The import transaction and exact failed record IDs exist", "The source and local revisions are revalidated"]
destination = "the grouped partial-import result. The handoff starts from Time degraded-state owner explicit state contract / Partial Import"
destination_id = "DEST-TIME-DEGRADED-PARTIAL-IMPORT-002"
destination_posture = "current"
effect = "No local canonical mutation is replayed; only failed import IDs are retried; accepted records are not duplicated and pending records remain identifiable; Time degraded-state owner explicit state contract / Partial Import reports the outcome from this visible condition: Some calendar items were not imported; completed items remain clearly identified"
success_focus = "the first retried record result within Time degraded-state owner explicit state contract / Partial Import"
success_focus_id = "FOCUS-TIME-DEGRADED-PARTIAL-IMPORT-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the first failed record and Retry failed items control while Time degraded-state owner explicit state contract / Partial Import remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-PARTIAL-IMPORT-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: the existing durable result or outbox identity is revalidated before only the failed external/read operation runs; the accepted local Event is never replayed."
rollback_undo = "Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command."
recovery_id = "RECOVERY-TIME-DEGRADED-PARTIAL-IMPORT-002"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "Only the previously approved minimum payload may leave the device; authorization and SYSTEM-PRIVACY-EGRESS-001 are revalidated and failure remains inspectable."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DEGRADED-PENDING-EXTERNAL-DIFF"
requirement_id = "SPEC-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review changes => destination: the Time external-calendar changes review. The handoff starts from Time degraded-state owner explicit state contract / Pending External Diff; effect: No durable mutation occurs and no Receipt is created; pending external changes are grouped and compared; dismissal preserves the diff and no local Event is adopted; Time degraded-state owner explicit state contract / Pending External Diff reports the outcome from this visible condition: Outside calendar changes are waiting. Ambitions-owned time remains unchanged; focus: the first changed group and its consequence within Time degraded-state owner explicit state contract / Pending External Diff."
durable_effect = "Exact command consequences: Review changes: No durable mutation occurs and no Receipt is created; pending external changes are grouped and compared; dismissal preserves the diff and no local Event is adopted. The durable boundary is specific to this visible evidence: Outside calendar changes are waiting. Ambitions-owned time remains unchanged."
recovery_rollback = "Exact rollback and recovery: Review changes: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Outside calendar changes are waiting. Ambitions-owned time remains unchanged."
offline_behavior = "Local Time remains usable offline; source, permission, import, and external-write failures remain narrow and inspectable, and continuity remains disabled under SYSTEM-CONTINUITY-DISABLED-001. Offline rendering retains this state evidence: Outside calendar changes are waiting. Ambitions-owned time remains unchanged."
accessibility_focus = "VoiceOver focus contract: Review changes announces its consequence, then success focuses the first changed group and its consequence; rejection focuses the pending external diff status and Review changes control. The announcement includes this user-facing evidence before focus moves: Outside calendar changes are waiting. Ambitions-owned time remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-PENDING-EXTERNAL-DIFF-001"
label = "Review changes"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["External source, diff record IDs, affected local identities, and Time return anchor exist"]
destination = "the Time external-calendar changes review. The handoff starts from Time degraded-state owner explicit state contract / Pending External Diff"
destination_id = "DEST-TIME-DEGRADED-PENDING-EXTERNAL-DIFF-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; pending external changes are grouped and compared; dismissal preserves the diff and no local Event is adopted; Time degraded-state owner explicit state contract / Pending External Diff reports the outcome from this visible condition: Outside calendar changes are waiting. Ambitions-owned time remains unchanged"
success_focus = "the first changed group and its consequence within Time degraded-state owner explicit state contract / Pending External Diff"
success_focus_id = "FOCUS-TIME-DEGRADED-PENDING-EXTERNAL-DIFF-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the pending external diff status and Review changes control while Time degraded-state owner explicit state contract / Pending External Diff remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-PENDING-EXTERNAL-DIFF-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DEGRADED-PENDING-EXTERNAL-DIFF-001"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DEGRADED-PERMISSION-DENIED"
requirement_id = "SPEC-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Settings => destination: system Settings for Calendar access. The handoff starts from Time degraded-state owner explicit state contract / Permission Denied; effect: No durable mutation occurs and no Receipt is created; the app yields to system Settings while local Time and Ambitions-owned objects remain unchanged; Time degraded-state owner explicit state contract / Permission Denied reports the outcome from this visible condition: Calendar access is off. The Ambitions schedule remains available; focus: the affected Time status after returning within Time degraded-state owner explicit state contract / Permission Denied.\nReview calendar access => destination: the contextual Calendar permission explanation. The handoff starts from Time degraded-state owner explicit state contract / Permission Denied; effect: No durable mutation occurs and no Receipt is created; current permission and request eligibility are shown; local Time objects remain usable and no system prompt runs without Continue; Time degraded-state owner explicit state contract / Permission Denied reports the outcome from this visible condition: Calendar access is off. The Ambitions schedule remains available; focus: the calendar permission status and local Time capability within Time degraded-state owner explicit state contract / Permission Denied."
durable_effect = "Exact command consequences: Open Settings: No durable mutation occurs and no Receipt is created; the app yields to system Settings while local Time and Ambitions-owned objects remain unchanged | Review calendar access: No durable mutation occurs and no Receipt is created; current permission and request eligibility are shown; local Time objects remain usable and no system prompt runs without Continue. The durable boundary is specific to this visible evidence: Calendar access is off. The Ambitions schedule remains available."
recovery_rollback = "Exact rollback and recovery: Open Settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Review calendar access: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Calendar access is off. The Ambitions schedule remains available."
offline_behavior = "Local Time remains usable offline; source, permission, import, and external-write failures remain narrow and inspectable, and continuity remains disabled under SYSTEM-CONTINUITY-DISABLED-001. Offline rendering retains this state evidence: Calendar access is off. The Ambitions schedule remains available."
accessibility_focus = "VoiceOver focus contract: Open Settings announces its consequence, then success focuses the affected Time status after returning; rejection focuses the Open Settings control | Review calendar access announces its consequence, then success focuses the calendar permission status and local Time capability; rejection focuses the Review calendar access control. The announcement includes this user-facing evidence before focus moves: Calendar access is off. The Ambitions schedule remains available."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-PERMISSION-DENIED-001"
label = "Open Settings"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["Calendar permission is denied or restricted", "The user chose system Settings"]
destination = "system Settings for Calendar access. The handoff starts from Time degraded-state owner explicit state contract / Permission Denied"
destination_id = "DEST-TIME-DEGRADED-PERMISSION-DENIED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the app yields to system Settings while local Time and Ambitions-owned objects remain unchanged; Time degraded-state owner explicit state contract / Permission Denied reports the outcome from this visible condition: Calendar access is off. The Ambitions schedule remains available"
success_focus = "the affected Time status after returning within Time degraded-state owner explicit state contract / Permission Denied"
success_focus_id = "FOCUS-TIME-DEGRADED-PERMISSION-DENIED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open Settings control while Time degraded-state owner explicit state contract / Permission Denied remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-PERMISSION-DENIED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DEGRADED-PERMISSION-DENIED-001"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "No private Time content is sent; only the system Settings route is opened."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-PERMISSION-DENIED-002"
label = "Review calendar access"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["Calendar permission status and affected external controls are known"]
destination = "the contextual Calendar permission explanation. The handoff starts from Time degraded-state owner explicit state contract / Permission Denied"
destination_id = "DEST-TIME-DEGRADED-PERMISSION-DENIED-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; current permission and request eligibility are shown; local Time objects remain usable and no system prompt runs without Continue; Time degraded-state owner explicit state contract / Permission Denied reports the outcome from this visible condition: Calendar access is off. The Ambitions schedule remains available"
success_focus = "the calendar permission status and local Time capability within Time degraded-state owner explicit state contract / Permission Denied"
success_focus_id = "FOCUS-TIME-DEGRADED-PERMISSION-DENIED-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review calendar access control while Time degraded-state owner explicit state contract / Permission Denied remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-PERMISSION-DENIED-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DEGRADED-PERMISSION-DENIED-002"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DEGRADED-STALE-SOURCE"
requirement_id = "SPEC-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Refresh source => destination: the same Time source-health row. The handoff starts from Time degraded-state owner explicit state contract / Stale Source; effect: No local canonical mutation is replayed; only source freshness is checked and recorded; local objects and placements remain unchanged and stale facts remain labeled until success; Time degraded-state owner explicit state contract / Stale Source reports the outcome from this visible condition: Calendar information may be out of date; saved Ambitions time remains available; focus: the refreshed source status within Time degraded-state owner explicit state contract / Stale Source.\nReview source => destination: the object-scoped source reference inspection. The handoff starts from Time degraded-state owner explicit state contract / Stale Source; effect: No durable mutation occurs and no Receipt is created; the stale or unavailable source is inspected without refreshing it or changing any Time object; Time degraded-state owner explicit state contract / Stale Source reports the outcome from this visible condition: Calendar information may be out of date; saved Ambitions time remains available; focus: the source heading and freshness status within Time degraded-state owner explicit state contract / Stale Source."
durable_effect = "Exact command consequences: Refresh source: No local canonical mutation is replayed; only source freshness is checked and recorded; local objects and placements remain unchanged and stale facts remain labeled until success | Review source: No durable mutation occurs and no Receipt is created; the stale or unavailable source is inspected without refreshing it or changing any Time object. The durable boundary is specific to this visible evidence: Calendar information may be out of date; saved Ambitions time remains available."
recovery_rollback = "Exact rollback and recovery: Refresh source: Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command. | Review source: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Calendar information may be out of date; saved Ambitions time remains available."
offline_behavior = "Local Time remains usable offline; source, permission, import, and external-write failures remain narrow and inspectable, and continuity remains disabled under SYSTEM-CONTINUITY-DISABLED-001. Offline rendering retains this state evidence: Calendar information may be out of date; saved Ambitions time remains available."
accessibility_focus = "VoiceOver focus contract: Refresh source announces its consequence, then success focuses the refreshed source status; rejection focuses the stale source row and Refresh source control | Review source announces its consequence, then success focuses the source heading and freshness status; rejection focuses the Review source control. The announcement includes this user-facing evidence before focus moves: Calendar information may be out of date; saved Ambitions time remains available."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-STALE-SOURCE-001"
label = "Refresh source"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["No private Time context is required by the source request", "The public/external source is enabled"]
destination = "the same Time source-health row. The handoff starts from Time degraded-state owner explicit state contract / Stale Source"
destination_id = "DEST-TIME-DEGRADED-STALE-SOURCE-001"
destination_posture = "current"
effect = "No local canonical mutation is replayed; only source freshness is checked and recorded; local objects and placements remain unchanged and stale facts remain labeled until success; Time degraded-state owner explicit state contract / Stale Source reports the outcome from this visible condition: Calendar information may be out of date; saved Ambitions time remains available"
success_focus = "the refreshed source status within Time degraded-state owner explicit state contract / Stale Source"
success_focus_id = "FOCUS-TIME-DEGRADED-STALE-SOURCE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the stale source row and Refresh source control while Time degraded-state owner explicit state contract / Stale Source remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-STALE-SOURCE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: the existing durable result or outbox identity is revalidated before only the failed external/read operation runs; the accepted local Event is never replayed."
rollback_undo = "Cancelling the retry preserves the accepted local state and prior external result; any supported local Undo remains a separate typed command."
recovery_id = "RECOVERY-TIME-DEGRADED-STALE-SOURCE-001"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "Only the source's approved public request leaves the device; goals, schedules, capacity, and private context are excluded."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-STALE-SOURCE-002"
label = "Review source"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["The source reference, provenance, freshness, and use are available"]
destination = "the object-scoped source reference inspection. The handoff starts from Time degraded-state owner explicit state contract / Stale Source"
destination_id = "DEST-TIME-DEGRADED-STALE-SOURCE-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the stale or unavailable source is inspected without refreshing it or changing any Time object; Time degraded-state owner explicit state contract / Stale Source reports the outcome from this visible condition: Calendar information may be out of date; saved Ambitions time remains available"
success_focus = "the source heading and freshness status within Time degraded-state owner explicit state contract / Stale Source"
success_focus_id = "FOCUS-TIME-DEGRADED-STALE-SOURCE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review source control while Time degraded-state owner explicit state contract / Stale Source remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-STALE-SOURCE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DEGRADED-STALE-SOURCE-002"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DEGRADED-SYNC-CONFLICT"
requirement_id = "SPEC-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review conflict => destination: the You Continuity disabled-status explanation. The handoff starts from Time degraded-state owner explicit state contract / Sync Conflict; effect: No durable mutation occurs and no Receipt is created; the pending/conflict envelope may be inspected as future design input, but no enable, sync, keep-remote, keep-local, merge, or last-write-wins command is authorized; Time degraded-state owner explicit state contract / Sync Conflict reports the outcome from this visible condition: Two calendar versions disagree. The saved choice remains unchanged; focus: the Continuity disabled status within Time degraded-state owner explicit state contract / Sync Conflict."
durable_effect = "Exact command consequences: Review conflict: No durable mutation occurs and no Receipt is created; the pending/conflict envelope may be inspected as future design input, but no enable, sync, keep-remote, keep-local, merge, or last-write-wins command is authorized. The durable boundary is specific to this visible evidence: Two calendar versions disagree. The saved choice remains unchanged."
recovery_rollback = "Exact rollback and recovery: Review conflict: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Two calendar versions disagree. The saved choice remains unchanged."
offline_behavior = "Local Time remains usable offline; source, permission, import, and external-write failures remain narrow and inspectable, and continuity remains disabled under SYSTEM-CONTINUITY-DISABLED-001. Offline rendering retains this state evidence: Two calendar versions disagree. The saved choice remains unchanged."
accessibility_focus = "VoiceOver focus contract: Review conflict announces its consequence, then success focuses the Continuity disabled status; rejection focuses the Review conflict control and disabled-gate explanation. The announcement includes this user-facing evidence before focus moves: Two calendar versions disagree. The saved choice remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-SYNC-CONFLICT-001"
label = "Review conflict"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["No continuity operation is authorized", "SYSTEM-CONTINUITY-DISABLED-001 remains active"]
destination = "the You Continuity disabled-status explanation. The handoff starts from Time degraded-state owner explicit state contract / Sync Conflict"
destination_id = "DEST-TIME-DEGRADED-SYNC-CONFLICT-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the pending/conflict envelope may be inspected as future design input, but no enable, sync, keep-remote, keep-local, merge, or last-write-wins command is authorized; Time degraded-state owner explicit state contract / Sync Conflict reports the outcome from this visible condition: Two calendar versions disagree. The saved choice remains unchanged"
success_focus = "the Continuity disabled status within Time degraded-state owner explicit state contract / Sync Conflict"
success_focus_id = "FOCUS-TIME-DEGRADED-SYNC-CONFLICT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review conflict control and disabled-gate explanation while Time degraded-state owner explicit state contract / Sync Conflict remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-SYNC-CONFLICT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DEGRADED-SYNC-CONFLICT-001"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DEGRADED-SYNC-PENDING"
requirement_id = "SPEC-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review continuity status => destination: the You Continuity disabled-status explanation. The handoff starts from Time degraded-state owner explicit state contract / Sync Pending; effect: No durable mutation occurs and no Receipt is created; the pending/conflict envelope may be inspected as future design input, but no enable, sync, keep-remote, keep-local, merge, or last-write-wins command is authorized; Time degraded-state owner explicit state contract / Sync Pending reports the outcome from this visible condition: Calendar changes are still being checked; the last confirmed schedule stays visible; focus: the Continuity disabled status within Time degraded-state owner explicit state contract / Sync Pending."
durable_effect = "Exact command consequences: Review continuity status: No durable mutation occurs and no Receipt is created; the pending/conflict envelope may be inspected as future design input, but no enable, sync, keep-remote, keep-local, merge, or last-write-wins command is authorized. The durable boundary is specific to this visible evidence: Calendar changes are still being checked; the last confirmed schedule stays visible."
recovery_rollback = "Exact rollback and recovery: Review continuity status: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Calendar changes are still being checked; the last confirmed schedule stays visible."
offline_behavior = "Local Time remains usable offline; source, permission, import, and external-write failures remain narrow and inspectable, and continuity remains disabled under SYSTEM-CONTINUITY-DISABLED-001. Offline rendering retains this state evidence: Calendar changes are still being checked; the last confirmed schedule stays visible."
accessibility_focus = "VoiceOver focus contract: Review continuity status announces its consequence, then success focuses the Continuity disabled status; rejection focuses the Review continuity status control and disabled-gate explanation. The announcement includes this user-facing evidence before focus moves: Calendar changes are still being checked; the last confirmed schedule stays visible."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DEGRADED-SYNC-PENDING-001"
label = "Review continuity status"
canonical_owner = "surface.time.degraded-command-contract"
preconditions = ["No continuity operation is authorized", "SYSTEM-CONTINUITY-DISABLED-001 remains active"]
destination = "the You Continuity disabled-status explanation. The handoff starts from Time degraded-state owner explicit state contract / Sync Pending"
destination_id = "DEST-TIME-DEGRADED-SYNC-PENDING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the pending/conflict envelope may be inspected as future design input, but no enable, sync, keep-remote, keep-local, merge, or last-write-wins command is authorized; Time degraded-state owner explicit state contract / Sync Pending reports the outcome from this visible condition: Calendar changes are still being checked; the last confirmed schedule stays visible"
success_focus = "the Continuity disabled status within Time degraded-state owner explicit state contract / Sync Pending"
success_focus_id = "FOCUS-TIME-DEGRADED-SYNC-PENDING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review continuity status control and disabled-gate explanation while Time degraded-state owner explicit state contract / Sync Pending remains visible"
failure_focus_id = "FOCUS-TIME-DEGRADED-SYNC-PENDING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-DEGRADED-SYNC-PENDING-001"
recovery_posture = "current"
recovery_owner = "surface.time.degraded-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DETAIL-CONFLICT-REVIEW"
requirement_id = "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the unchanged owner detail or conflict origin from Time object detail — Conflict Review; effect: No durable mutation occurs and no Receipt is created; Cancel preserves accepted canonical state and closes the draft, conflict preview, or exact-scope confirmation without changing the saved object, recurrence, placement, notification, or external source. Visible evidence remains: The protected conflict stays visible while the current placement remains unchanged.; focus: the Cancel result heading or selected object in Time object detail — Conflict Review.\nEntire Series => destination: the recurrence consequence preview for the complete series; effect: No durable mutation occurs and no Receipt is created; the scope selection updates only the nested consequence preview; focus: the selected recurrence scope and first affected object.\nThis Occurrence => destination: the recurrence consequence preview for the selected occurrence; effect: No durable mutation occurs and no Receipt is created; the scope selection updates only the nested consequence preview; focus: the selected recurrence scope and first affected object.\nThis and Following => destination: the recurrence consequence preview from the selected occurrence forward; effect: No durable mutation occurs and no Receipt is created; the scope selection updates only the nested consequence preview; focus: the selected recurrence scope and first affected object."
durable_effect = "Exact Time detail consequences: Cancel: No durable mutation occurs and no Receipt is created; Cancel preserves accepted canonical state and closes the draft, conflict preview, or exact-scope confirmation without changing the saved object, recurrence, placement, notification, or external source. Visible evidence remains: The protected conflict stays visible while the current placement remains unchanged. External candidates stay source-owned; linked sources hand off explicitly; native local commit precedes external write. Current visible status: The protected conflict stays visible while the current placement remains unchanged."
recovery_rollback = "Exact draft, Trash, restore, permanent-deletion, and external-failure recovery: Cancel: No Undo is required; the unchanged current object regains focus and any invalid draft remains available only where the user explicitly chose to keep editing. Restore revalidates recurrence, placement, capacity, and notifications; permanent deletion is available only from Trash after a separate exact-scope confirmation. Recovery preserves: The protected conflict stays visible while the current placement remains unchanged."
offline_behavior = "Ambitions-owned detail, edit, Save, Trash, Restore, History, and Receipts remain local and usable offline. External reads, handoffs, or writes wait; failure cannot roll back accepted local truth. Offline evidence remains: The protected conflict stays visible while the current placement remains unchanged."
accessibility_focus = "VoiceOver identifies object class, source ownership, recurrence scope, consequence, and recovery without color dependence: Cancel announces object class and consequence; success focuses the Cancel result heading or selected object in Time object detail — Conflict Review; rejection focuses the Cancel control and first invalid field or exact ownership reason in Time object detail — Conflict Review. Dynamic Type stacks fields and recurrence choices. The announcement first communicates: The protected conflict stays visible while the current placement remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-CONFLICT-REVIEW-001"
label = "Cancel"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["The current revision, stable object identity, source ownership, and permission have been revalidated", "The object class is resolved as Ambitions-owned Event, Reminder, Step placement, external candidate, or linked external source"]
destination = "the unchanged owner detail or conflict origin from Time object detail — Conflict Review"
destination_id = "DEST-TIME-DETAIL-CONFLICT-REVIEW-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Cancel preserves accepted canonical state and closes the draft, conflict preview, or exact-scope confirmation without changing the saved object, recurrence, placement, notification, or external source. Visible evidence remains: The protected conflict stays visible while the current placement remains unchanged."
success_focus = "the Cancel result heading or selected object in Time object detail — Conflict Review"
success_focus_id = "FOCUS-TIME-DETAIL-CONFLICT-REVIEW-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Cancel control and first invalid field or exact ownership reason in Time object detail — Conflict Review"
failure_focus_id = "FOCUS-TIME-DETAIL-CONFLICT-REVIEW-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: cancellation completes before the canonical mutation boundary."
rollback_undo = "No Undo is required; the unchanged current object regains focus and any invalid draft remains available only where the user explicitly chose to keep editing."
recovery_id = "RECOVERY-TIME-DETAIL-CONFLICT-REVIEW-001"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "Native detail and history remain local; source inspection exposes only approved lineage, and any explicit external handoff sends no private life graph context."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-CONFLICT-REVIEW-002"
label = "Entire Series"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["A recurring Ambitions-owned object and exact occurrence identity are present", "The current object revision and recurrence definition remain valid", "The selected scope can be previewed without committing a mutation"]
destination = "the recurrence consequence preview for the complete series"
destination_id = "DEST-TIME-DETAIL-CONFLICT-REVIEW-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the scope selection updates only the nested consequence preview"
success_focus = "the selected recurrence scope and first affected object"
success_focus_id = "FOCUS-TIME-DETAIL-CONFLICT-REVIEW-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Entire Series control and exact invalid recurrence boundary"
failure_focus_id = "FOCUS-TIME-DETAIL-CONFLICT-REVIEW-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-TIME-DETAIL-CONFLICT-REVIEW-002"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "No egress occurs; private object content, History, Proof, and Receipts remain local."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-CONFLICT-REVIEW-003"
label = "This Occurrence"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["A recurring Ambitions-owned object and exact occurrence identity are present", "The current object revision and recurrence definition remain valid", "The selected scope can be previewed without committing a mutation"]
destination = "the recurrence consequence preview for the selected occurrence"
destination_id = "DEST-TIME-DETAIL-CONFLICT-REVIEW-003"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the scope selection updates only the nested consequence preview"
success_focus = "the selected recurrence scope and first affected object"
success_focus_id = "FOCUS-TIME-DETAIL-CONFLICT-REVIEW-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the This Occurrence control and exact invalid recurrence boundary"
failure_focus_id = "FOCUS-TIME-DETAIL-CONFLICT-REVIEW-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-TIME-DETAIL-CONFLICT-REVIEW-003"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "No egress occurs; private object content, History, Proof, and Receipts remain local."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-CONFLICT-REVIEW-004"
label = "This and Following"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["A recurring Ambitions-owned object and exact occurrence identity are present", "The current object revision and recurrence definition remain valid", "The selected scope can be previewed without committing a mutation"]
destination = "the recurrence consequence preview from the selected occurrence forward"
destination_id = "DEST-TIME-DETAIL-CONFLICT-REVIEW-004"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the scope selection updates only the nested consequence preview"
success_focus = "the selected recurrence scope and first affected object"
success_focus_id = "FOCUS-TIME-DETAIL-CONFLICT-REVIEW-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the This and Following control and exact invalid recurrence boundary"
failure_focus_id = "FOCUS-TIME-DETAIL-CONFLICT-REVIEW-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-TIME-DETAIL-CONFLICT-REVIEW-004"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "No egress occurs; private object content, History, Proof, and Receipts remain local."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DETAIL-EDITING"
requirement_id = "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the unchanged owner detail or conflict origin from Time object detail — Editing; effect: No durable mutation occurs and no Receipt is created; Cancel preserves accepted canonical state and closes the draft, conflict preview, or exact-scope confirmation without changing the saved object, recurrence, placement, notification, or external source. Visible evidence remains: Original and proposed time values remain separate while the change is considered.; focus: the Cancel result heading or selected object in Time object detail — Editing.\nSave => destination: the saved Time object detail result and Receipt inspection for Editing; effect: A typed Save Command validates stable identity, current revision, fields, ownership, permission, and recurrence scope; it appends an Event, updates the Time Projection, and creates a Receipt and History entry. Local commit precedes any optional external write, whose failure preserves local truth and opens degraded reconciliation. Visible evidence becomes: Original and proposed time values remain separate while the change is considered.; focus: the Save result heading or selected object in Time object detail — Editing."
durable_effect = "Exact Time detail consequences: Cancel: No durable mutation occurs and no Receipt is created; Cancel preserves accepted canonical state and closes the draft, conflict preview, or exact-scope confirmation without changing the saved object, recurrence, placement, notification, or external source. Visible evidence remains: Original and proposed time values remain separate while the change is considered. | Save: A typed Save Command validates stable identity, current revision, fields, ownership, permission, and recurrence scope; it appends an Event, updates the Time Projection, and creates a Receipt and History entry. Local commit precedes any optional external write, whose failure preserves local truth and opens degraded reconciliation. Visible evidence becomes: Original and proposed time values remain separate while the change is considered. External candidates stay source-owned; linked sources hand off explicitly; native local commit precedes external write. Current visible status: Original and proposed time values remain separate while the change is considered."
recovery_rollback = "Exact draft, Trash, restore, permanent-deletion, and external-failure recovery: Cancel: No Undo is required; the unchanged current object regains focus and any invalid draft remains available only where the user explicitly chose to keep editing. | Save: Before commit, Cancel preserves the draft and saved object separately; after commit, a safe inverse uses a typed Undo command, otherwise History or degraded reconciliation preserves the local result. Restore revalidates recurrence, placement, capacity, and notifications; permanent deletion is available only from Trash after a separate exact-scope confirmation. Recovery preserves: Original and proposed time values remain separate while the change is considered."
offline_behavior = "Ambitions-owned detail, edit, Save, Trash, Restore, History, and Receipts remain local and usable offline. External reads, handoffs, or writes wait; failure cannot roll back accepted local truth. Offline evidence remains: Original and proposed time values remain separate while the change is considered."
accessibility_focus = "VoiceOver identifies object class, source ownership, recurrence scope, consequence, and recovery without color dependence: Cancel announces object class and consequence; success focuses the Cancel result heading or selected object in Time object detail — Editing; rejection focuses the Cancel control and first invalid field or exact ownership reason in Time object detail — Editing | Save announces object class and consequence; success focuses the Save result heading or selected object in Time object detail — Editing; rejection focuses the Save control and first invalid field or exact ownership reason in Time object detail — Editing. Dynamic Type stacks fields and recurrence choices. The announcement first communicates: Original and proposed time values remain separate while the change is considered."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-EDITING-001"
label = "Cancel"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["The current revision, stable object identity, source ownership, and permission have been revalidated", "The object class is resolved as Ambitions-owned Event, Reminder, Step placement, external candidate, or linked external source"]
destination = "the unchanged owner detail or conflict origin from Time object detail — Editing"
destination_id = "DEST-TIME-DETAIL-EDITING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Cancel preserves accepted canonical state and closes the draft, conflict preview, or exact-scope confirmation without changing the saved object, recurrence, placement, notification, or external source. Visible evidence remains: Original and proposed time values remain separate while the change is considered."
success_focus = "the Cancel result heading or selected object in Time object detail — Editing"
success_focus_id = "FOCUS-TIME-DETAIL-EDITING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Cancel control and first invalid field or exact ownership reason in Time object detail — Editing"
failure_focus_id = "FOCUS-TIME-DETAIL-EDITING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: cancellation completes before the canonical mutation boundary."
rollback_undo = "No Undo is required; the unchanged current object regains focus and any invalid draft remains available only where the user explicitly chose to keep editing."
recovery_id = "RECOVERY-TIME-DETAIL-EDITING-001"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "Native detail and history remain local; source inspection exposes only approved lineage, and any explicit external handoff sends no private life graph context."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-EDITING-002"
label = "Save"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["Every edited field is valid and the draft remains separate from the saved object", "For recurrence, This Occurrence, This and Following, or Entire Series is selected with affected objects and schedule consequences previewed", "The command is exposed only for an Ambitions-owned item; external candidates hand off to import review and linked external sources hand off to source inspection", "The current revision, stable object identity, source ownership, and permission have been revalidated", "The object class is resolved as Ambitions-owned Event, Reminder, Step placement, external candidate, or linked external source"]
destination = "the saved Time object detail result and Receipt inspection for Editing"
destination_id = "DEST-TIME-DETAIL-EDITING-002"
destination_posture = "current"
effect = "A typed Save Command validates stable identity, current revision, fields, ownership, permission, and recurrence scope; it appends an Event, updates the Time Projection, and creates a Receipt and History entry. Local commit precedes any optional external write, whose failure preserves local truth and opens degraded reconciliation. Visible evidence becomes: Original and proposed time values remain separate while the change is considered."
success_focus = "the Save result heading or selected object in Time object detail — Editing"
success_focus_id = "FOCUS-TIME-DETAIL-EDITING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Save control and first invalid field or exact ownership reason in Time object detail — Editing"
failure_focus_id = "FOCUS-TIME-DETAIL-EDITING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: Save commits only through the Time owner after current-revision validation through Event, Projection, Receipt, History, and replay-safe ownership."
rollback_undo = "Before commit, Cancel preserves the draft and saved object separately; after commit, a safe inverse uses a typed Undo command, otherwise History or degraded reconciliation preserves the local result."
recovery_id = "RECOVERY-TIME-DETAIL-EDITING-002"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "Native detail and history remain local; source inspection exposes only approved lineage, and any explicit external handoff sends no private life graph context."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-TIME-DETAIL-EDITING-002-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-DETAIL-EDITING-002"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-TIME-DETAIL-EDITING-002"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-TIME-DETAIL-EDITING-002-INVERSE"
label = "Restore prior time values"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["CMD-TIME-DETAIL-EDITING-002 is the exact trigger command and its exact trigger Receipt is current", "The saved time-item revision, exact prior field set, recurrence scope, placement/capacity dependencies, notification posture, and external-write status are current"]
destination = "Time detail for the exact item with its pre-save fields, recurrence scope, placement, and local notification posture restored"
destination_id = "DEST-TIME-DETAIL-EDITING-002-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it restores the exact pre-save time fields and recurrence scope, recomputes only the affected placement/capacity and local notification projections, appends a reversing Event, updates the Time Projection, and creates a new inverse Receipt and History entry while the Save Receipt and History remain intact and any optional external write reconciles separately."
success_focus = "the first restored time field followed by the restored recurrence/placement summary and inverse Receipt"
success_focus_id = "FOCUS-TIME-DETAIL-EDITING-002-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Restore prior time values control and exact unsafe, stale, or dependency-invalid field/recurrence/placement reason; the saved values and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-DETAIL-EDITING-002-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-TIME-DETAIL-EDITING-002-INVERSE"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DETAIL-SAVED"
requirement_id = "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Edit => destination: the owner-specific native editor for the selected Time object from Time object detail — Saved; effect: No durable mutation occurs and no Receipt is created; Edit opens a draft separate from the saved object. External candidates and linked external sources route to import review or source inspection instead of native editing. Visible evidence remains: The confirmed time change and its receipt are available for inspection.; focus: the Edit result heading or selected object in Time object detail — Saved."
durable_effect = "Exact Time detail consequences: Edit: No durable mutation occurs and no Receipt is created; Edit opens a draft separate from the saved object. External candidates and linked external sources route to import review or source inspection instead of native editing. Visible evidence remains: The confirmed time change and its receipt are available for inspection. External candidates stay source-owned; linked sources hand off explicitly; native local commit precedes external write. Current visible status: The confirmed time change and its receipt are available for inspection."
recovery_rollback = "Exact draft, Trash, restore, permanent-deletion, and external-failure recovery: Edit: No Undo is required; dismissing the editor restores focus to the unchanged saved object, and invalid edits retain the draft while focusing the first invalid field. Restore revalidates recurrence, placement, capacity, and notifications; permanent deletion is available only from Trash after a separate exact-scope confirmation. Recovery preserves: The confirmed time change and its receipt are available for inspection."
offline_behavior = "Ambitions-owned detail, edit, Save, Trash, Restore, History, and Receipts remain local and usable offline. External reads, handoffs, or writes wait; failure cannot roll back accepted local truth. Offline evidence remains: The confirmed time change and its receipt are available for inspection."
accessibility_focus = "VoiceOver identifies object class, source ownership, recurrence scope, consequence, and recovery without color dependence: Edit announces object class and consequence; success focuses the Edit result heading or selected object in Time object detail — Saved; rejection focuses the Edit control and first invalid field or exact ownership reason in Time object detail — Saved. Dynamic Type stacks fields and recurrence choices. The announcement first communicates: The confirmed time change and its receipt are available for inspection."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-SAVED-001"
label = "Edit"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["The command is exposed only for an Ambitions-owned item; external candidates hand off to import review and linked external sources hand off to source inspection", "The current revision, stable object identity, source ownership, and permission have been revalidated", "The object class is resolved as Ambitions-owned Event, Reminder, Step placement, external candidate, or linked external source"]
destination = "the owner-specific native editor for the selected Time object from Time object detail — Saved"
destination_id = "DEST-TIME-DETAIL-SAVED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Edit opens a draft separate from the saved object. External candidates and linked external sources route to import review or source inspection instead of native editing. Visible evidence remains: The confirmed time change and its receipt are available for inspection."
success_focus = "the Edit result heading or selected object in Time object detail — Saved"
success_focus_id = "FOCUS-TIME-DETAIL-SAVED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Edit control and first invalid field or exact ownership reason in Time object detail — Saved"
failure_focus_id = "FOCUS-TIME-DETAIL-SAVED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: opening an owner-specific edit draft completes without a canonical commit."
rollback_undo = "No Undo is required; dismissing the editor restores focus to the unchanged saved object, and invalid edits retain the draft while focusing the first invalid field."
recovery_id = "RECOVERY-TIME-DETAIL-SAVED-001"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "Native detail and history remain local; source inspection exposes only approved lineage, and any explicit external handoff sends no private life graph context."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DETAIL-UNDO-ELIGIBLE"
requirement_id = "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Edit => destination: the owner-specific native editor for the selected Time object from Time object detail — Undo Eligible; effect: No durable mutation occurs and no Receipt is created; Edit opens a draft separate from the saved object. External candidates and linked external sources route to import review or source inspection instead of native editing. Visible evidence remains: This change is marked as reversible, but no reversal action is offered here.; focus: the Edit result heading or selected object in Time object detail — Undo Eligible."
durable_effect = "Exact Time detail consequences: Edit: No durable mutation occurs and no Receipt is created; Edit opens a draft separate from the saved object. External candidates and linked external sources route to import review or source inspection instead of native editing. Visible evidence remains: This change is marked as reversible, but no reversal action is offered here. External candidates stay source-owned; linked sources hand off explicitly; native local commit precedes external write. Current visible status: This change is marked as reversible, but no reversal action is offered here."
recovery_rollback = "Exact draft, Trash, restore, permanent-deletion, and external-failure recovery: Edit: No Undo is required; dismissing the editor restores focus to the unchanged saved object, and invalid edits retain the draft while focusing the first invalid field. Restore revalidates recurrence, placement, capacity, and notifications; permanent deletion is available only from Trash after a separate exact-scope confirmation. Recovery preserves: This change is marked as reversible, but no reversal action is offered here."
offline_behavior = "Ambitions-owned detail, edit, Save, Trash, Restore, History, and Receipts remain local and usable offline. External reads, handoffs, or writes wait; failure cannot roll back accepted local truth. Offline evidence remains: This change is marked as reversible, but no reversal action is offered here."
accessibility_focus = "VoiceOver identifies object class, source ownership, recurrence scope, consequence, and recovery without color dependence: Edit announces object class and consequence; success focuses the Edit result heading or selected object in Time object detail — Undo Eligible; rejection focuses the Edit control and first invalid field or exact ownership reason in Time object detail — Undo Eligible. Dynamic Type stacks fields and recurrence choices. The announcement first communicates: This change is marked as reversible, but no reversal action is offered here."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-UNDO-ELIGIBLE-001"
label = "Edit"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["The command is exposed only for an Ambitions-owned item; external candidates hand off to import review and linked external sources hand off to source inspection", "The current revision, stable object identity, source ownership, and permission have been revalidated", "The object class is resolved as Ambitions-owned Event, Reminder, Step placement, external candidate, or linked external source"]
destination = "the owner-specific native editor for the selected Time object from Time object detail — Undo Eligible"
destination_id = "DEST-TIME-DETAIL-UNDO-ELIGIBLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Edit opens a draft separate from the saved object. External candidates and linked external sources route to import review or source inspection instead of native editing. Visible evidence remains: This change is marked as reversible, but no reversal action is offered here."
success_focus = "the Edit result heading or selected object in Time object detail — Undo Eligible"
success_focus_id = "FOCUS-TIME-DETAIL-UNDO-ELIGIBLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Edit control and first invalid field or exact ownership reason in Time object detail — Undo Eligible"
failure_focus_id = "FOCUS-TIME-DETAIL-UNDO-ELIGIBLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: opening an owner-specific edit draft completes without a canonical commit."
rollback_undo = "No Undo is required; dismissing the editor restores focus to the unchanged saved object, and invalid edits retain the draft while focusing the first invalid field."
recovery_id = "RECOVERY-TIME-DETAIL-UNDO-ELIGIBLE-001"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "Native detail and history remain local; source inspection exposes only approved lineage, and any explicit external handoff sends no private life graph context."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DETAIL-UNDO-UNAVAILABLE"
requirement_id = "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Edit => destination: the owner-specific native editor for the selected Time object from Time object detail — Undo Unavailable; effect: No durable mutation occurs and no Receipt is created; Edit opens a draft separate from the saved object. External candidates and linked external sources route to import review or source inspection instead of native editing. Visible evidence remains: This change cannot be reversed here, and the reason stays visible.; focus: the Edit result heading or selected object in Time object detail — Undo Unavailable."
durable_effect = "Exact Time detail consequences: Edit: No durable mutation occurs and no Receipt is created; Edit opens a draft separate from the saved object. External candidates and linked external sources route to import review or source inspection instead of native editing. Visible evidence remains: This change cannot be reversed here, and the reason stays visible. External candidates stay source-owned; linked sources hand off explicitly; native local commit precedes external write. Current visible status: This change cannot be reversed here, and the reason stays visible."
recovery_rollback = "Exact draft, Trash, restore, permanent-deletion, and external-failure recovery: Edit: No Undo is required; dismissing the editor restores focus to the unchanged saved object, and invalid edits retain the draft while focusing the first invalid field. Restore revalidates recurrence, placement, capacity, and notifications; permanent deletion is available only from Trash after a separate exact-scope confirmation. Recovery preserves: This change cannot be reversed here, and the reason stays visible."
offline_behavior = "Ambitions-owned detail, edit, Save, Trash, Restore, History, and Receipts remain local and usable offline. External reads, handoffs, or writes wait; failure cannot roll back accepted local truth. Offline evidence remains: This change cannot be reversed here, and the reason stays visible."
accessibility_focus = "VoiceOver identifies object class, source ownership, recurrence scope, consequence, and recovery without color dependence: Edit announces object class and consequence; success focuses the Edit result heading or selected object in Time object detail — Undo Unavailable; rejection focuses the Edit control and first invalid field or exact ownership reason in Time object detail — Undo Unavailable. Dynamic Type stacks fields and recurrence choices. The announcement first communicates: This change cannot be reversed here, and the reason stays visible."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-UNDO-UNAVAILABLE-001"
label = "Edit"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["The command is exposed only for an Ambitions-owned item; external candidates hand off to import review and linked external sources hand off to source inspection", "The current revision, stable object identity, source ownership, and permission have been revalidated", "The object class is resolved as Ambitions-owned Event, Reminder, Step placement, external candidate, or linked external source"]
destination = "the owner-specific native editor for the selected Time object from Time object detail — Undo Unavailable"
destination_id = "DEST-TIME-DETAIL-UNDO-UNAVAILABLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Edit opens a draft separate from the saved object. External candidates and linked external sources route to import review or source inspection instead of native editing. Visible evidence remains: This change cannot be reversed here, and the reason stays visible."
success_focus = "the Edit result heading or selected object in Time object detail — Undo Unavailable"
success_focus_id = "FOCUS-TIME-DETAIL-UNDO-UNAVAILABLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Edit control and first invalid field or exact ownership reason in Time object detail — Undo Unavailable"
failure_focus_id = "FOCUS-TIME-DETAIL-UNDO-UNAVAILABLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: opening an owner-specific edit draft completes without a canonical commit."
rollback_undo = "No Undo is required; dismissing the editor restores focus to the unchanged saved object, and invalid edits retain the draft while focusing the first invalid field."
recovery_id = "RECOVERY-TIME-DETAIL-UNDO-UNAVAILABLE-001"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "Native detail and history remain local; source inspection exposes only approved lineage, and any explicit external handoff sends no private life graph context."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-DETAIL-VIEWING"
requirement_id = "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Edit => destination: the owner-specific native editor for the selected Time object from Time object detail — Viewing; effect: No durable mutation occurs and no Receipt is created; Edit opens a draft separate from the saved object. External candidates and linked external sources route to import review or source inspection instead of native editing. Visible evidence remains: The selected time item shows its current saved details without edit controls.; focus: the Edit result heading or selected object in Time object detail — Viewing.\nMove to Trash => destination: the exact-scope Trash confirmation, then the Time Trash result for Viewing; effect: A typed Move to Trash Command validates current revision, resolved object ownership, and recurrence scope; it appends an Event, updates the Time and Trash Projection, and creates a Receipt and History entry without changing any external source. The object remains recoverable. Visible evidence before confirmation remains: The selected time item shows its current saved details without edit controls.; focus: the Move to Trash result heading or selected object in Time object detail — Viewing.\nDelete Permanently => destination: the permanent-deletion result and exact destroyed-scope Receipt; effect: The typed Delete Permanently command appends one Event, updates the owning Projection, records a Receipt, and preserves History; only the confirmed trashed object scope is destroyed and its destruction Receipt remains inspectable; focus: the permanent-deletion result and destroyed-scope Receipt.\nImport into Ambitions => destination: the external-calendar import review with Import into Ambitions preselected; effect: No durable mutation occurs and no Receipt is created; Time detail hands off to import review and performs no import or source write; focus: the import review heading and first consequence.\nKeep external but reserve time => destination: the external-calendar import review with reserve-time outcome preselected; effect: No durable mutation occurs and no Receipt is created; Time detail hands off to reviewed capacity selection, creates no reservation itself, and preserves current canonical state; focus: the reserve-time consequence preview.\nLink => destination: the external-calendar import review with Link preselected; effect: No durable mutation occurs and no Receipt is created; Time detail hands off to link review and creates no link itself; focus: the link consequence preview.\nOpen in Calendar => destination: the selected record in Apple Calendar; effect: The Open in Calendar external result causes no local canonical mutation; the external handoff cannot edit, import, link, reserve, or mutate local state; focus: the selected event in Apple Calendar.\nRestore => destination: the restored owner detail with updated placement and notification consequences; effect: The typed Restore command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the exact trashed object scope returns to its owning lifecycle without erasing Trash History; focus: the restored object heading and changed schedule consequence."
durable_effect = "Exact Time detail consequences: Edit: No durable mutation occurs and no Receipt is created; Edit opens a draft separate from the saved object. External candidates and linked external sources route to import review or source inspection instead of native editing. Visible evidence remains: The selected time item shows its current saved details without edit controls. | Move to Trash: A typed Move to Trash Command validates current revision, resolved object ownership, and recurrence scope; it appends an Event, updates the Time and Trash Projection, and creates a Receipt and History entry without changing any external source. The object remains recoverable. Visible evidence before confirmation remains: The selected time item shows its current saved details without edit controls. External candidates stay source-owned; linked sources hand off explicitly; native local commit precedes external write. Current visible status: The selected time item shows its current saved details without edit controls."
recovery_rollback = "Exact draft, Trash, restore, permanent-deletion, and external-failure recovery: Edit: No Undo is required; dismissing the editor restores focus to the unchanged saved object, and invalid edits retain the draft while focusing the first invalid field. | Move to Trash: Before commit, cancellation changes nothing; after commit, Restore is a separate typed command that revalidates recurrence, placement, capacity, and notification effects. Delete Permanently exists only in Trash behind separate irreversible exact-scope confirmation. Restore revalidates recurrence, placement, capacity, and notifications; permanent deletion is available only from Trash after a separate exact-scope confirmation. Recovery preserves: The selected time item shows its current saved details without edit controls."
offline_behavior = "Ambitions-owned detail, edit, Save, Trash, Restore, History, and Receipts remain local and usable offline. External reads, handoffs, or writes wait; failure cannot roll back accepted local truth. Offline evidence remains: The selected time item shows its current saved details without edit controls."
accessibility_focus = "VoiceOver identifies object class, source ownership, recurrence scope, consequence, and recovery without color dependence: Edit announces object class and consequence; success focuses the Edit result heading or selected object in Time object detail — Viewing; rejection focuses the Edit control and first invalid field or exact ownership reason in Time object detail — Viewing | Move to Trash announces object class and consequence; success focuses the Move to Trash result heading or selected object in Time object detail — Viewing; rejection focuses the Move to Trash control and first invalid field or exact ownership reason in Time object detail — Viewing. Dynamic Type stacks fields and recurrence choices. The announcement first communicates: The selected time item shows its current saved details without edit controls."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-VIEWING-001"
label = "Edit"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["The command is exposed only for an Ambitions-owned item; external candidates hand off to import review and linked external sources hand off to source inspection", "The current revision, stable object identity, source ownership, and permission have been revalidated", "The object class is resolved as Ambitions-owned Event, Reminder, Step placement, external candidate, or linked external source"]
destination = "the owner-specific native editor for the selected Time object from Time object detail — Viewing"
destination_id = "DEST-TIME-DETAIL-VIEWING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Edit opens a draft separate from the saved object. External candidates and linked external sources route to import review or source inspection instead of native editing. Visible evidence remains: The selected time item shows its current saved details without edit controls."
success_focus = "the Edit result heading or selected object in Time object detail — Viewing"
success_focus_id = "FOCUS-TIME-DETAIL-VIEWING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Edit control and first invalid field or exact ownership reason in Time object detail — Viewing"
failure_focus_id = "FOCUS-TIME-DETAIL-VIEWING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: opening an owner-specific edit draft completes without a canonical commit."
rollback_undo = "No Undo is required; dismissing the editor restores focus to the unchanged saved object, and invalid edits retain the draft while focusing the first invalid field."
recovery_id = "RECOVERY-TIME-DETAIL-VIEWING-001"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "Native detail and history remain local; source inspection exposes only approved lineage, and any explicit external handoff sends no private life graph context."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-VIEWING-002"
label = "Move to Trash"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["The command is exposed only for an Ambitions-owned item; external candidates hand off to import review and linked external sources hand off to source inspection", "The current revision, stable object identity, source ownership, and permission have been revalidated", "The exact affected object or recurrence scope and schedule consequences are confirmed", "The item is not an external candidate or externally owned source record", "The object class is resolved as Ambitions-owned Event, Reminder, Step placement, external candidate, or linked external source"]
destination = "the exact-scope Trash confirmation, then the Time Trash result for Viewing"
destination_id = "DEST-TIME-DETAIL-VIEWING-002"
destination_posture = "current"
effect = "A typed Move to Trash Command validates current revision, resolved object ownership, and recurrence scope; it appends an Event, updates the Time and Trash Projection, and creates a Receipt and History entry without changing any external source. The object remains recoverable. Visible evidence before confirmation remains: The selected time item shows its current saved details without edit controls."
success_focus = "the Move to Trash result heading or selected object in Time object detail — Viewing"
success_focus_id = "FOCUS-TIME-DETAIL-VIEWING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move to Trash control and first invalid field or exact ownership reason in Time object detail — Viewing"
failure_focus_id = "FOCUS-TIME-DETAIL-VIEWING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: Move to Trash commits only after exact-scope confirmation through Event, Projection, Receipt, History, and replay-safe ownership."
rollback_undo = "Before commit, cancellation changes nothing; after commit, Restore is a separate typed command that revalidates recurrence, placement, capacity, and notification effects. Delete Permanently exists only in Trash behind separate irreversible exact-scope confirmation."
recovery_id = "RECOVERY-TIME-DETAIL-VIEWING-002"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "Native detail and history remain local; source inspection exposes only approved lineage, and any explicit external handoff sends no private life graph context."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-TIME-DETAIL-VIEWING-002-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-DETAIL-VIEWING-002"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-TIME-DETAIL-VIEWING-002"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-TIME-DETAIL-VIEWING-002-INVERSE"
label = "Restore trashed time item"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["CMD-TIME-DETAIL-VIEWING-002 is the exact trigger command and its exact trigger Receipt is current", "The trashed object revision, prior owner/lifecycle, recurrence scope, placement/capacity dependencies, and notification effects are current"]
destination = "Time detail for the exact restored object at its prior lifecycle and recurrence scope, with Trash and placement History visible"
destination_id = "DEST-TIME-DETAIL-VIEWING-002-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it restores the exact time object from Trash to its prior owning lifecycle and recurrence scope, revalidates placement, capacity, and notification effects, appends a reversing Event, updates the Time and Trash Projection, and creates a new inverse Receipt and History entry while the deletion Receipt and Trash History remain intact."
success_focus = "the restored time-item heading followed by its recurrence/placement status and new inverse Receipt"
success_focus_id = "FOCUS-TIME-DETAIL-VIEWING-002-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Restore trashed time item control and exact unsafe, stale, or dependency-invalid lifecycle/recurrence/placement reason; the Trash row and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-DETAIL-VIEWING-002-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-TIME-DETAIL-VIEWING-002-INVERSE"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-VIEWING-003"
label = "Delete Permanently"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["A separate exact-scope irreversible confirmation has been accepted", "The current object revision and exact recurrence scope remain valid", "The selected Ambitions-owned object is already in Trash"]
destination = "the permanent-deletion result and exact destroyed-scope Receipt"
destination_id = "DEST-TIME-DETAIL-VIEWING-003"
destination_posture = "current"
effect = "The typed Delete Permanently command appends one Event, updates the owning Projection, records a Receipt, and preserves History; only the confirmed trashed object scope is destroyed and its destruction Receipt remains inspectable"
success_focus = "the permanent-deletion result and destroyed-scope Receipt"
success_focus_id = "FOCUS-TIME-DETAIL-VIEWING-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Delete Permanently control and exact failed scope or revision"
failure_focus_id = "FOCUS-TIME-DETAIL-VIEWING-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "After the confirmed irreversible boundary no inverse is promised; the destruction Receipt preserves the exact destroyed scope and rollback reference."
recovery_id = "RECOVERY-TIME-DETAIL-VIEWING-003"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "No egress occurs; private object content, History, Proof, and Receipts remain local."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "confirmed_irreversible"
irreversible_confirmation_id = "CONFIRMATION-TIME-DETAIL-VIEWING-003"
irreversible_receipt_id = "RECEIPT-TIME-DETAIL-VIEWING-003"

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-VIEWING-004"
label = "Import into Ambitions"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["The confirmed source identity, fingerprint, and visible revision remain valid", "The selected record is an external candidate or linked source"]
destination = "the external-calendar import review with Import into Ambitions preselected"
destination_id = "DEST-TIME-DETAIL-VIEWING-004"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Time detail hands off to import review and performs no import or source write"
success_focus = "the import review heading and first consequence"
success_focus_id = "FOCUS-TIME-DETAIL-VIEWING-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Import into Ambitions control and exact source-identity reason"
failure_focus_id = "FOCUS-TIME-DETAIL-VIEWING-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-TIME-DETAIL-VIEWING-004"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "No external write occurs; only the selected source identity enters local import review."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-VIEWING-005"
label = "Keep external but reserve time"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["The confirmed source identity, fingerprint, and visible revision remain valid", "The selected record remains external-owned"]
destination = "the external-calendar import review with reserve-time outcome preselected"
destination_id = "DEST-TIME-DETAIL-VIEWING-005"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Time detail hands off to reviewed capacity selection, creates no reservation itself, and preserves current canonical state"
success_focus = "the reserve-time consequence preview"
success_focus_id = "FOCUS-TIME-DETAIL-VIEWING-005-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep external but reserve time control and exact source reason"
failure_focus_id = "FOCUS-TIME-DETAIL-VIEWING-005-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-TIME-DETAIL-VIEWING-005"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "No external write occurs and no private Ambitions context leaves the device."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-VIEWING-006"
label = "Link"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["The confirmed source identity, fingerprint, and visible revision remain valid", "The selected record is an eligible external or duplicate link candidate"]
destination = "the external-calendar import review with Link preselected"
destination_id = "DEST-TIME-DETAIL-VIEWING-006"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Time detail hands off to link review and creates no link itself"
success_focus = "the link consequence preview"
success_focus_id = "FOCUS-TIME-DETAIL-VIEWING-006-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Link control and exact identity or lineage reason"
failure_focus_id = "FOCUS-TIME-DETAIL-VIEWING-006-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-TIME-DETAIL-VIEWING-006"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "No external write occurs; source lineage remains local until a separate confirmed command."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-VIEWING-007"
label = "Open in Calendar"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["The handoff can disclose only the selected external identity", "The selected record has a current allowlisted external Calendar identity"]
destination = "the selected record in Apple Calendar"
destination_id = "DEST-TIME-DETAIL-VIEWING-007"
destination_posture = "current"
effect = "The Open in Calendar external result causes no local canonical mutation; the external handoff cannot edit, import, link, reserve, or mutate local state"
success_focus = "the selected event in Apple Calendar"
success_focus_id = "FOCUS-TIME-DETAIL-VIEWING-007-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open in Calendar control and exact unavailable-handoff reason"
failure_focus_id = "FOCUS-TIME-DETAIL-VIEWING-007-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: the external or protected-system result is revalidated before any separately authorized local command."
rollback_undo = "No Undo is required; cancellation or external failure preserves the prior verified local state."
recovery_id = "RECOVERY-TIME-DETAIL-VIEWING-007"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "Only the selected external Calendar identity reaches EventKit; no private graph context is attached."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-DETAIL-VIEWING-008"
label = "Restore"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["Placement, capacity, and notification consequences have been revalidated", "The current object revision and selected recurrence scope remain valid", "The selected Ambitions-owned object is in Trash"]
destination = "the restored owner detail with updated placement and notification consequences"
destination_id = "DEST-TIME-DETAIL-VIEWING-008"
destination_posture = "current"
effect = "The typed Restore command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the exact trashed object scope returns to its owning lifecycle without erasing Trash History"
success_focus = "the restored object heading and changed schedule consequence"
success_focus_id = "FOCUS-TIME-DETAIL-VIEWING-008-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Restore control and first invalid recurrence, placement, capacity, or notification fact"
failure_focus_id = "FOCUS-TIME-DETAIL-VIEWING-008-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "Move to Trash is the typed inverse command when the restored revision remains current; History preserves both lifecycle events."
recovery_id = "RECOVERY-TIME-DETAIL-VIEWING-008"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "No egress occurs; private object content, History, Proof, and Receipts remain local."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-TIME-DETAIL-VIEWING-008-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-DETAIL-VIEWING-008"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-TIME-DETAIL-VIEWING-008"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-TIME-DETAIL-VIEWING-008-INVERSE"
label = "Return time item to Trash"
canonical_owner = "surface.time.detail-command-contract"
preconditions = ["CMD-TIME-DETAIL-VIEWING-008 is the exact trigger command and its exact trigger Receipt is current", "The restored object revision, restored owner/lifecycle, original Trash identity, recurrence scope, and dependent projections are current"]
destination = "Trash with the exact time object returned under its original Trash identity, deletion date, retention posture, and complete lifecycle History"
destination_id = "DEST-TIME-DETAIL-VIEWING-008-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it returns the exact restored time object to Trash under its original Trash identity and recurrence scope, removes it from active Time placement, appends a reversing Event, updates the Time and Trash Projection, and creates a new inverse Receipt and History entry while both lifecycle Receipts and prior History remain intact."
success_focus = "the returned time-item row in Trash followed by its retention posture and new inverse Receipt"
success_focus_id = "FOCUS-TIME-DETAIL-VIEWING-008-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Return time item to Trash control and exact unsafe, stale, or dependency-invalid lifecycle/recurrence reason; the restored object and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-DETAIL-VIEWING-008-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-TIME-DETAIL-VIEWING-008-INVERSE"
recovery_posture = "current"
recovery_owner = "surface.time.detail-command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-LIST-CONFLICTING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Adjust plan => destination: the multi-item Time adjustment review. The handoff starts from Time List explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Conflicting reports the outcome from this visible condition: The chronological list names the overlapping items and protected boundary before any reschedule; focus: the affected object and proposed placement consequence within Time List explicit state contract / Conflicting.\nChange duration => destination: the duration-boundary placement preview. The handoff starts from Time List explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Conflicting reports the outcome from this visible condition: The chronological list names the overlapping items and protected boundary before any reschedule; focus: the affected object and proposed placement consequence within Time List explicit state contract / Conflicting.\nChange start => destination: the start-boundary placement preview. The handoff starts from Time List explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Conflicting reports the outcome from this visible condition: The chronological list names the overlapping items and protected boundary before any reschedule; focus: the affected object and proposed placement consequence within Time List explicit state contract / Conflicting.\nKeep current => destination: the unchanged Time List object and current placement. The handoff starts from Time List explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time List explicit state contract / Conflicting reports the outcome from this visible condition: The chronological list names the overlapping items and protected boundary before any reschedule; this command preserves accepted product state; focus: the unchanged object and placement status within Time List explicit state contract / Conflicting.\nMove => destination: the object-scoped placement preview. The handoff starts from Time List explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Conflicting reports the outcome from this visible condition: The chronological list names the overlapping items and protected boundary before any reschedule; focus: the affected object and proposed placement consequence within Time List explicit state contract / Conflicting.\nResolve conflict => destination: the revision-bound Time conflict comparison. The handoff starts from Time List explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed; Time List explicit state contract / Conflicting reports the outcome from this visible condition: The chronological list names the overlapping items and protected boundary before any reschedule; focus: the affected object and proposed placement consequence within Time List explicit state contract / Conflicting."
durable_effect = "Exact command consequences: Adjust plan: No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change duration: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change start: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Keep current: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Resolve conflict: No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed. The durable boundary is specific to this visible evidence: The chronological list names the overlapping items and protected boundary before any reschedule."
recovery_rollback = "Exact rollback and recovery: Adjust plan: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change duration: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change start: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Keep current: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Resolve conflict: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The chronological list names the overlapping items and protected boundary before any reschedule."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The chronological list names the overlapping items and protected boundary before any reschedule."
accessibility_focus = "VoiceOver focus contract: Adjust plan announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Adjust plan control and exact invalid field or boundary | Change duration announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change duration control and exact invalid field or boundary | Change start announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change start control and exact invalid field or boundary | Keep current announces its consequence, then success focuses the unchanged object and placement status; rejection focuses the Keep current control | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary | Resolve conflict announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Resolve conflict control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: The chronological list names the overlapping items and protected boundary before any reschedule."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-CONFLICTING-001"
label = "Adjust plan"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the multi-item Time adjustment review. The handoff starts from Time List explicit state contract / Conflicting"
destination_id = "DEST-TIME-LIST-CONFLICTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Conflicting reports the outcome from this visible condition: The chronological list names the overlapping items and protected boundary before any reschedule"
success_focus = "the affected object and proposed placement consequence within Time List explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-LIST-CONFLICTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Adjust plan control and exact invalid field or boundary while Time List explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-LIST-CONFLICTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-CONFLICTING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-CONFLICTING-002"
label = "Change duration"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the duration-boundary placement preview. The handoff starts from Time List explicit state contract / Conflicting"
destination_id = "DEST-TIME-LIST-CONFLICTING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Conflicting reports the outcome from this visible condition: The chronological list names the overlapping items and protected boundary before any reschedule"
success_focus = "the affected object and proposed placement consequence within Time List explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-LIST-CONFLICTING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change duration control and exact invalid field or boundary while Time List explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-LIST-CONFLICTING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-CONFLICTING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-CONFLICTING-003"
label = "Change start"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the start-boundary placement preview. The handoff starts from Time List explicit state contract / Conflicting"
destination_id = "DEST-TIME-LIST-CONFLICTING-003"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Conflicting reports the outcome from this visible condition: The chronological list names the overlapping items and protected boundary before any reschedule"
success_focus = "the affected object and proposed placement consequence within Time List explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-LIST-CONFLICTING-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change start control and exact invalid field or boundary while Time List explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-LIST-CONFLICTING-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-CONFLICTING-003"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-CONFLICTING-004"
label = "Keep current"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["A placement or conflict proposal is open and the current placement revision remains valid"]
destination = "the unchanged Time List object and current placement. The handoff starts from Time List explicit state contract / Conflicting"
destination_id = "DEST-TIME-LIST-CONFLICTING-004"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time List explicit state contract / Conflicting reports the outcome from this visible condition: The chronological list names the overlapping items and protected boundary before any reschedule; this command preserves accepted product state"
success_focus = "the unchanged object and placement status within Time List explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-LIST-CONFLICTING-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep current control while Time List explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-LIST-CONFLICTING-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-CONFLICTING-004"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-CONFLICTING-005"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time List explicit state contract / Conflicting"
destination_id = "DEST-TIME-LIST-CONFLICTING-005"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Conflicting reports the outcome from this visible condition: The chronological list names the overlapping items and protected boundary before any reschedule"
success_focus = "the affected object and proposed placement consequence within Time List explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-LIST-CONFLICTING-005-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time List explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-LIST-CONFLICTING-005-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-CONFLICTING-005"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-CONFLICTING-006"
label = "Resolve conflict"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the revision-bound Time conflict comparison. The handoff starts from Time List explicit state contract / Conflicting"
destination_id = "DEST-TIME-LIST-CONFLICTING-006"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed; Time List explicit state contract / Conflicting reports the outcome from this visible condition: The chronological list names the overlapping items and protected boundary before any reschedule"
success_focus = "the affected object and proposed placement consequence within Time List explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-LIST-CONFLICTING-006-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Resolve conflict control and exact invalid field or boundary while Time List explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-LIST-CONFLICTING-006-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-CONFLICTING-006"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-LIST-DENSE"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in List. The handoff starts from Time List explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time List explicit state contract / Dense reports the outcome from this visible condition: The chronological list groups a busy range by date while keeping protected items and types readable; focus: the selected object heading or selected date heading within Time List explicit state contract / Dense."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The chronological list groups a busy range by date while keeping protected items and types readable."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The chronological list groups a busy range by date while keeping protected items and types readable."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The chronological list groups a busy range by date while keeping protected items and types readable."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating List object/date control. The announcement includes this user-facing evidence before focus moves: The chronological list groups a busy range by date while keeping protected items and types readable."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-DENSE-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The List range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in List. The handoff starts from Time List explicit state contract / Dense"
destination_id = "DEST-TIME-LIST-DENSE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time List explicit state contract / Dense reports the outcome from this visible condition: The chronological list groups a busy range by date while keeping protected items and types readable"
success_focus = "the selected object heading or selected date heading within Time List explicit state contract / Dense"
success_focus_id = "FOCUS-TIME-LIST-DENSE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating List object/date control while Time List explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-TIME-LIST-DENSE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-DENSE-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-LIST-EDITING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Change duration => destination: the duration-boundary placement preview. The handoff starts from Time List explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Editing reports the outcome from this visible condition: The selected list row keeps original and proposed values together until the user saves or cancels; focus: the affected object and proposed placement consequence within Time List explicit state contract / Editing.\nChange start => destination: the start-boundary placement preview. The handoff starts from Time List explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Editing reports the outcome from this visible condition: The selected list row keeps original and proposed values together until the user saves or cancels; focus: the affected object and proposed placement consequence within Time List explicit state contract / Editing.\nEdit => destination: compact canonical object edit detail. The handoff starts from Time List explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; the editable object fields is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Editing reports the outcome from this visible condition: The selected list row keeps original and proposed values together until the user saves or cancels; focus: the affected object and proposed placement consequence within Time List explicit state contract / Editing.\nMove => destination: the object-scoped placement preview. The handoff starts from Time List explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Editing reports the outcome from this visible condition: The selected list row keeps original and proposed values together until the user saves or cancels; focus: the affected object and proposed placement consequence within Time List explicit state contract / Editing."
durable_effect = "Exact command consequences: Change duration: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change start: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Edit: No durable mutation occurs and no Receipt is created; the editable object fields is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. The durable boundary is specific to this visible evidence: The selected list row keeps original and proposed values together until the user saves or cancels."
recovery_rollback = "Exact rollback and recovery: Change duration: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change start: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Edit: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The selected list row keeps original and proposed values together until the user saves or cancels."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The selected list row keeps original and proposed values together until the user saves or cancels."
accessibility_focus = "VoiceOver focus contract: Change duration announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change duration control and exact invalid field or boundary | Change start announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change start control and exact invalid field or boundary | Edit announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Edit control and exact invalid field or boundary | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: The selected list row keeps original and proposed values together until the user saves or cancels."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-EDITING-001"
label = "Change duration"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the duration-boundary placement preview. The handoff starts from Time List explicit state contract / Editing"
destination_id = "DEST-TIME-LIST-EDITING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Editing reports the outcome from this visible condition: The selected list row keeps original and proposed values together until the user saves or cancels"
success_focus = "the affected object and proposed placement consequence within Time List explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-LIST-EDITING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change duration control and exact invalid field or boundary while Time List explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-LIST-EDITING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-EDITING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-EDITING-002"
label = "Change start"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the start-boundary placement preview. The handoff starts from Time List explicit state contract / Editing"
destination_id = "DEST-TIME-LIST-EDITING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Editing reports the outcome from this visible condition: The selected list row keeps original and proposed values together until the user saves or cancels"
success_focus = "the affected object and proposed placement consequence within Time List explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-LIST-EDITING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change start control and exact invalid field or boundary while Time List explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-LIST-EDITING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-EDITING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-EDITING-003"
label = "Edit"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "compact canonical object edit detail. The handoff starts from Time List explicit state contract / Editing"
destination_id = "DEST-TIME-LIST-EDITING-003"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the editable object fields is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Editing reports the outcome from this visible condition: The selected list row keeps original and proposed values together until the user saves or cancels"
success_focus = "the affected object and proposed placement consequence within Time List explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-LIST-EDITING-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Edit control and exact invalid field or boundary while Time List explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-LIST-EDITING-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-EDITING-003"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-EDITING-004"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time List explicit state contract / Editing"
destination_id = "DEST-TIME-LIST-EDITING-004"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Editing reports the outcome from this visible condition: The selected list row keeps original and proposed values together until the user saves or cancels"
success_focus = "the affected object and proposed placement consequence within Time List explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-LIST-EDITING-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time List explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-LIST-EDITING-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-EDITING-004"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-LIST-EMPTY"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Today => destination: the current local date in Time List. The handoff starts from Time List explicit state contract / Empty; effect: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time List explicit state contract / Empty reports the outcome from this visible condition: No Ambitions-owned time items match the current chronological list range; focus: the current-period date heading within Time List explicit state contract / Empty."
durable_effect = "Exact command consequences: Today: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts. The durable boundary is specific to this visible evidence: No Ambitions-owned time items match the current chronological list range."
recovery_rollback = "Exact rollback and recovery: Today: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: No Ambitions-owned time items match the current chronological list range."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: No Ambitions-owned time items match the current chronological list range."
accessibility_focus = "VoiceOver focus contract: Today announces its consequence, then success focuses the current-period date heading; rejection focuses the Today control and retained prior range. The announcement includes this user-facing evidence before focus moves: No Ambitions-owned time items match the current chronological list range."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-EMPTY-001"
label = "Today"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The preferred List view and current local date are available"]
destination = "the current local date in Time List. The handoff starts from Time List explicit state contract / Empty"
destination_id = "DEST-TIME-LIST-EMPTY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time List explicit state contract / Empty reports the outcome from this visible condition: No Ambitions-owned time items match the current chronological list range"
success_focus = "the current-period date heading within Time List explicit state contract / Empty"
success_focus_id = "FOCUS-TIME-LIST-EMPTY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Today control and retained prior range while Time List explicit state contract / Empty remains visible"
failure_focus_id = "FOCUS-TIME-LIST-EMPTY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-EMPTY-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-LIST-EXTERNAL-HIDDEN-CAPACITY"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in List. The handoff starts from Time List explicit state contract / External Hidden Capacity; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time List explicit state contract / External Hidden Capacity reports the outcome from this visible condition: External details hidden. List shows capacity-only occupied rows with no external event text; focus: the selected object heading or selected date heading within Time List explicit state contract / External Hidden Capacity."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: External details hidden. List shows capacity-only occupied rows with no external event text."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: External details hidden. List shows capacity-only occupied rows with no external event text."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: External details hidden. List shows capacity-only occupied rows with no external event text."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating List object/date control. The announcement includes this user-facing evidence before focus moves: External details hidden. List shows capacity-only occupied rows with no external event text."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-EXTERNAL-HIDDEN-CAPACITY-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The List range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in List. The handoff starts from Time List explicit state contract / External Hidden Capacity"
destination_id = "DEST-TIME-LIST-EXTERNAL-HIDDEN-CAPACITY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time List explicit state contract / External Hidden Capacity reports the outcome from this visible condition: External details hidden. List shows capacity-only occupied rows with no external event text"
success_focus = "the selected object heading or selected date heading within Time List explicit state contract / External Hidden Capacity"
success_focus_id = "FOCUS-TIME-LIST-EXTERNAL-HIDDEN-CAPACITY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating List object/date control while Time List explicit state contract / External Hidden Capacity remains visible"
failure_focus_id = "FOCUS-TIME-LIST-EXTERNAL-HIDDEN-CAPACITY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-EXTERNAL-HIDDEN-CAPACITY-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-LIST-IMPORTING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained Time List range and pending import summary. The handoff starts from Time List explicit state contract / Importing; effect: No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt; Time List explicit state contract / Importing reports the outcome from this visible condition: Outside calendar items are being compared before any row appears as an Ambitions-owned copy; this command preserves accepted product state; focus: the initiating List import control or date heading within Time List explicit state contract / Importing."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt. The durable boundary is specific to this visible evidence: Outside calendar items are being compared before any row appears as an Ambitions-owned copy."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Outside calendar items are being compared before any row appears as an Ambitions-owned copy."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Outside calendar items are being compared before any row appears as an Ambitions-owned copy."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating List import control or date heading; rejection focuses the import progress status and Cancel control. The announcement includes this user-facing evidence before focus moves: Outside calendar items are being compared before any row appears as an Ambitions-owned copy."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-IMPORTING-001"
label = "Cancel"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Any accepted import and Receipt are identified separately", "Only pending import comparison or optional loading remains uncommitted"]
destination = "the retained Time List range and pending import summary. The handoff starts from Time List explicit state contract / Importing"
destination_id = "DEST-TIME-LIST-IMPORTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt; Time List explicit state contract / Importing reports the outcome from this visible condition: Outside calendar items are being compared before any row appears as an Ambitions-owned copy; this command preserves accepted product state"
success_focus = "the initiating List import control or date heading within Time List explicit state contract / Importing"
success_focus_id = "FOCUS-TIME-LIST-IMPORTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the import progress status and Cancel control while Time List explicit state contract / Importing remains visible"
failure_focus_id = "FOCUS-TIME-LIST-IMPORTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-IMPORTING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-LIST-NOW-ANCHORED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Today => destination: the current local date in Time List. The handoff starts from Time List explicit state contract / Now Anchored; effect: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time List explicit state contract / Now Anchored reports the outcome from this visible condition: Today is visible in the list without a false minute marker; focus: the current-period date heading within Time List explicit state contract / Now Anchored."
durable_effect = "Exact command consequences: Today: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts. The durable boundary is specific to this visible evidence: Today is visible in the list without a false minute marker."
recovery_rollback = "Exact rollback and recovery: Today: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Today is visible in the list without a false minute marker."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Today is visible in the list without a false minute marker."
accessibility_focus = "VoiceOver focus contract: Today announces its consequence, then success focuses the current-period date heading; rejection focuses the Today control and retained prior range. The announcement includes this user-facing evidence before focus moves: Today is visible in the list without a false minute marker."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-NOW-ANCHORED-001"
label = "Today"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The preferred List view and current local date are available"]
destination = "the current local date in Time List. The handoff starts from Time List explicit state contract / Now Anchored"
destination_id = "DEST-TIME-LIST-NOW-ANCHORED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time List explicit state contract / Now Anchored reports the outcome from this visible condition: Today is visible in the list without a false minute marker"
success_focus = "the current-period date heading within Time List explicit state contract / Now Anchored"
success_focus_id = "FOCUS-TIME-LIST-NOW-ANCHORED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Today control and retained prior range while Time List explicit state contract / Now Anchored remains visible"
failure_focus_id = "FOCUS-TIME-LIST-NOW-ANCHORED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-NOW-ANCHORED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-LIST-POPULATED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in List. The handoff starts from Time List explicit state contract / Populated; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time List explicit state contract / Populated reports the outcome from this visible condition: The chronological list orders saved time items by date and time with their types clearly named; focus: the selected object heading or selected date heading within Time List explicit state contract / Populated."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The chronological list orders saved time items by date and time with their types clearly named."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The chronological list orders saved time items by date and time with their types clearly named."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The chronological list orders saved time items by date and time with their types clearly named."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating List object/date control. The announcement includes this user-facing evidence before focus moves: The chronological list orders saved time items by date and time with their types clearly named."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-POPULATED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The List range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in List. The handoff starts from Time List explicit state contract / Populated"
destination_id = "DEST-TIME-LIST-POPULATED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time List explicit state contract / Populated reports the outcome from this visible condition: The chronological list orders saved time items by date and time with their types clearly named"
success_focus = "the selected object heading or selected date heading within Time List explicit state contract / Populated"
success_focus_id = "FOCUS-TIME-LIST-POPULATED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating List object/date control while Time List explicit state contract / Populated remains visible"
failure_focus_id = "FOCUS-TIME-LIST-POPULATED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-POPULATED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-LIST-PREVIEWING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Keep current => destination: the unchanged Time List object and current placement. The handoff starts from Time List explicit state contract / Previewing; effect: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time List explicit state contract / Previewing reports the outcome from this visible condition: The list shows proposed rows separately from current saved rows before confirmation; this command preserves accepted product state; focus: the unchanged object and placement status within Time List explicit state contract / Previewing.\nMove => destination: the object-scoped placement preview. The handoff starts from Time List explicit state contract / Previewing; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Previewing reports the outcome from this visible condition: The list shows proposed rows separately from current saved rows before confirmation; focus: the affected object and proposed placement consequence within Time List explicit state contract / Previewing."
durable_effect = "Exact command consequences: Keep current: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. The durable boundary is specific to this visible evidence: The list shows proposed rows separately from current saved rows before confirmation."
recovery_rollback = "Exact rollback and recovery: Keep current: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The list shows proposed rows separately from current saved rows before confirmation."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The list shows proposed rows separately from current saved rows before confirmation."
accessibility_focus = "VoiceOver focus contract: Keep current announces its consequence, then success focuses the unchanged object and placement status; rejection focuses the Keep current control | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: The list shows proposed rows separately from current saved rows before confirmation."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-PREVIEWING-001"
label = "Keep current"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["A placement or conflict proposal is open and the current placement revision remains valid"]
destination = "the unchanged Time List object and current placement. The handoff starts from Time List explicit state contract / Previewing"
destination_id = "DEST-TIME-LIST-PREVIEWING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time List explicit state contract / Previewing reports the outcome from this visible condition: The list shows proposed rows separately from current saved rows before confirmation; this command preserves accepted product state"
success_focus = "the unchanged object and placement status within Time List explicit state contract / Previewing"
success_focus_id = "FOCUS-TIME-LIST-PREVIEWING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep current control while Time List explicit state contract / Previewing remains visible"
failure_focus_id = "FOCUS-TIME-LIST-PREVIEWING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-PREVIEWING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-PREVIEWING-002"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time List explicit state contract / Previewing"
destination_id = "DEST-TIME-LIST-PREVIEWING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time List explicit state contract / Previewing reports the outcome from this visible condition: The list shows proposed rows separately from current saved rows before confirmation"
success_focus = "the affected object and proposed placement consequence within Time List explicit state contract / Previewing"
success_focus_id = "FOCUS-TIME-LIST-PREVIEWING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time List explicit state contract / Previewing remains visible"
failure_focus_id = "FOCUS-TIME-LIST-PREVIEWING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-PREVIEWING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-LIST-RESTORED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in List. The handoff starts from Time List explicit state contract / Restored; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time List explicit state contract / Restored reports the outcome from this visible condition: The prior list range, scroll position, and selected row return after current local facts are checked; focus: the selected object heading or selected date heading within Time List explicit state contract / Restored."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The prior list range, scroll position, and selected row return after current local facts are checked."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The prior list range, scroll position, and selected row return after current local facts are checked."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The prior list range, scroll position, and selected row return after current local facts are checked."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating List object/date control. The announcement includes this user-facing evidence before focus moves: The prior list range, scroll position, and selected row return after current local facts are checked."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-RESTORED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The List range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in List. The handoff starts from Time List explicit state contract / Restored"
destination_id = "DEST-TIME-LIST-RESTORED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time List explicit state contract / Restored reports the outcome from this visible condition: The prior list range, scroll position, and selected row return after current local facts are checked"
success_focus = "the selected object heading or selected date heading within Time List explicit state contract / Restored"
success_focus_id = "FOCUS-TIME-LIST-RESTORED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating List object/date control while Time List explicit state contract / Restored remains visible"
failure_focus_id = "FOCUS-TIME-LIST-RESTORED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-RESTORED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-LIST-SELECTED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in List. The handoff starts from Time List explicit state contract / Selected; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time List explicit state contract / Selected reports the outcome from this visible condition: The selected list row shows its saved time details; focus: the selected object heading or selected date heading within Time List explicit state contract / Selected."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The selected list row shows its saved time details."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The selected list row shows its saved time details."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The selected list row shows its saved time details."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating List object/date control. The announcement includes this user-facing evidence before focus moves: The selected list row shows its saved time details."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-LIST-SELECTED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The List range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in List. The handoff starts from Time List explicit state contract / Selected"
destination_id = "DEST-TIME-LIST-SELECTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time List explicit state contract / Selected reports the outcome from this visible condition: The selected list row shows its saved time details"
success_focus = "the selected object heading or selected date heading within Time List explicit state contract / Selected"
success_focus_id = "FOCUS-TIME-LIST-SELECTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating List object/date control while Time List explicit state contract / Selected remains visible"
failure_focus_id = "FOCUS-TIME-LIST-SELECTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-LIST-SELECTED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-MONTH-CONFLICTING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Adjust plan => destination: the multi-item Time adjustment review. The handoff starts from Time Month explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Conflicting reports the outcome from this visible condition: The month grid marks each date containing a protected conflict without moving either item; focus: the affected object and proposed placement consequence within Time Month explicit state contract / Conflicting.\nChange duration => destination: the duration-boundary placement preview. The handoff starts from Time Month explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Conflicting reports the outcome from this visible condition: The month grid marks each date containing a protected conflict without moving either item; focus: the affected object and proposed placement consequence within Time Month explicit state contract / Conflicting.\nChange start => destination: the start-boundary placement preview. The handoff starts from Time Month explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Conflicting reports the outcome from this visible condition: The month grid marks each date containing a protected conflict without moving either item; focus: the affected object and proposed placement consequence within Time Month explicit state contract / Conflicting.\nKeep current => destination: the unchanged Time Month object and current placement. The handoff starts from Time Month explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Month explicit state contract / Conflicting reports the outcome from this visible condition: The month grid marks each date containing a protected conflict without moving either item; this command preserves accepted product state; focus: the unchanged object and placement status within Time Month explicit state contract / Conflicting.\nMove => destination: the object-scoped placement preview. The handoff starts from Time Month explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Conflicting reports the outcome from this visible condition: The month grid marks each date containing a protected conflict without moving either item; focus: the affected object and proposed placement consequence within Time Month explicit state contract / Conflicting.\nResolve conflict => destination: the revision-bound Time conflict comparison. The handoff starts from Time Month explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed; Time Month explicit state contract / Conflicting reports the outcome from this visible condition: The month grid marks each date containing a protected conflict without moving either item; focus: the affected object and proposed placement consequence within Time Month explicit state contract / Conflicting."
durable_effect = "Exact command consequences: Adjust plan: No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change duration: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change start: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Keep current: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Resolve conflict: No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed. The durable boundary is specific to this visible evidence: The month grid marks each date containing a protected conflict without moving either item."
recovery_rollback = "Exact rollback and recovery: Adjust plan: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change duration: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change start: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Keep current: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Resolve conflict: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The month grid marks each date containing a protected conflict without moving either item."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The month grid marks each date containing a protected conflict without moving either item."
accessibility_focus = "VoiceOver focus contract: Adjust plan announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Adjust plan control and exact invalid field or boundary | Change duration announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change duration control and exact invalid field or boundary | Change start announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change start control and exact invalid field or boundary | Keep current announces its consequence, then success focuses the unchanged object and placement status; rejection focuses the Keep current control | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary | Resolve conflict announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Resolve conflict control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: The month grid marks each date containing a protected conflict without moving either item."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-CONFLICTING-001"
label = "Adjust plan"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the multi-item Time adjustment review. The handoff starts from Time Month explicit state contract / Conflicting"
destination_id = "DEST-TIME-MONTH-CONFLICTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Conflicting reports the outcome from this visible condition: The month grid marks each date containing a protected conflict without moving either item"
success_focus = "the affected object and proposed placement consequence within Time Month explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-MONTH-CONFLICTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Adjust plan control and exact invalid field or boundary while Time Month explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-CONFLICTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-CONFLICTING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-CONFLICTING-002"
label = "Change duration"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the duration-boundary placement preview. The handoff starts from Time Month explicit state contract / Conflicting"
destination_id = "DEST-TIME-MONTH-CONFLICTING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Conflicting reports the outcome from this visible condition: The month grid marks each date containing a protected conflict without moving either item"
success_focus = "the affected object and proposed placement consequence within Time Month explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-MONTH-CONFLICTING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change duration control and exact invalid field or boundary while Time Month explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-CONFLICTING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-CONFLICTING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-CONFLICTING-003"
label = "Change start"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the start-boundary placement preview. The handoff starts from Time Month explicit state contract / Conflicting"
destination_id = "DEST-TIME-MONTH-CONFLICTING-003"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Conflicting reports the outcome from this visible condition: The month grid marks each date containing a protected conflict without moving either item"
success_focus = "the affected object and proposed placement consequence within Time Month explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-MONTH-CONFLICTING-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change start control and exact invalid field or boundary while Time Month explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-CONFLICTING-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-CONFLICTING-003"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-CONFLICTING-004"
label = "Keep current"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["A placement or conflict proposal is open and the current placement revision remains valid"]
destination = "the unchanged Time Month object and current placement. The handoff starts from Time Month explicit state contract / Conflicting"
destination_id = "DEST-TIME-MONTH-CONFLICTING-004"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Month explicit state contract / Conflicting reports the outcome from this visible condition: The month grid marks each date containing a protected conflict without moving either item; this command preserves accepted product state"
success_focus = "the unchanged object and placement status within Time Month explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-MONTH-CONFLICTING-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep current control while Time Month explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-CONFLICTING-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-CONFLICTING-004"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-CONFLICTING-005"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time Month explicit state contract / Conflicting"
destination_id = "DEST-TIME-MONTH-CONFLICTING-005"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Conflicting reports the outcome from this visible condition: The month grid marks each date containing a protected conflict without moving either item"
success_focus = "the affected object and proposed placement consequence within Time Month explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-MONTH-CONFLICTING-005-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time Month explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-CONFLICTING-005-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-CONFLICTING-005"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-CONFLICTING-006"
label = "Resolve conflict"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the revision-bound Time conflict comparison. The handoff starts from Time Month explicit state contract / Conflicting"
destination_id = "DEST-TIME-MONTH-CONFLICTING-006"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed; Time Month explicit state contract / Conflicting reports the outcome from this visible condition: The month grid marks each date containing a protected conflict without moving either item"
success_focus = "the affected object and proposed placement consequence within Time Month explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-MONTH-CONFLICTING-006-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Resolve conflict control and exact invalid field or boundary while Time Month explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-CONFLICTING-006-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-CONFLICTING-006"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-MONTH-DENSE"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Month. The handoff starts from Time Month explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Month explicit state contract / Dense reports the outcome from this visible condition: The month grid shows busy dates while keeping protected time visible; focus: the selected object heading or selected date heading within Time Month explicit state contract / Dense."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The month grid shows busy dates while keeping protected time visible."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The month grid shows busy dates while keeping protected time visible."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The month grid shows busy dates while keeping protected time visible."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Month object/date control. The announcement includes this user-facing evidence before focus moves: The month grid shows busy dates while keeping protected time visible."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-DENSE-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Month range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Month. The handoff starts from Time Month explicit state contract / Dense"
destination_id = "DEST-TIME-MONTH-DENSE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Month explicit state contract / Dense reports the outcome from this visible condition: The month grid shows busy dates while keeping protected time visible"
success_focus = "the selected object heading or selected date heading within Time Month explicit state contract / Dense"
success_focus_id = "FOCUS-TIME-MONTH-DENSE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Month object/date control while Time Month explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-DENSE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-DENSE-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-MONTH-EDITING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Change duration => destination: the duration-boundary placement preview. The handoff starts from Time Month explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Editing reports the outcome from this visible condition: The month keeps the original date visible while the proposed item change is reviewed; focus: the affected object and proposed placement consequence within Time Month explicit state contract / Editing.\nChange start => destination: the start-boundary placement preview. The handoff starts from Time Month explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Editing reports the outcome from this visible condition: The month keeps the original date visible while the proposed item change is reviewed; focus: the affected object and proposed placement consequence within Time Month explicit state contract / Editing.\nEdit => destination: compact canonical object edit detail. The handoff starts from Time Month explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; the editable object fields is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Editing reports the outcome from this visible condition: The month keeps the original date visible while the proposed item change is reviewed; focus: the affected object and proposed placement consequence within Time Month explicit state contract / Editing.\nMove => destination: the object-scoped placement preview. The handoff starts from Time Month explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Editing reports the outcome from this visible condition: The month keeps the original date visible while the proposed item change is reviewed; focus: the affected object and proposed placement consequence within Time Month explicit state contract / Editing."
durable_effect = "Exact command consequences: Change duration: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change start: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Edit: No durable mutation occurs and no Receipt is created; the editable object fields is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. The durable boundary is specific to this visible evidence: The month keeps the original date visible while the proposed item change is reviewed."
recovery_rollback = "Exact rollback and recovery: Change duration: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change start: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Edit: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The month keeps the original date visible while the proposed item change is reviewed."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The month keeps the original date visible while the proposed item change is reviewed."
accessibility_focus = "VoiceOver focus contract: Change duration announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change duration control and exact invalid field or boundary | Change start announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change start control and exact invalid field or boundary | Edit announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Edit control and exact invalid field or boundary | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: The month keeps the original date visible while the proposed item change is reviewed."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-EDITING-001"
label = "Change duration"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the duration-boundary placement preview. The handoff starts from Time Month explicit state contract / Editing"
destination_id = "DEST-TIME-MONTH-EDITING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Editing reports the outcome from this visible condition: The month keeps the original date visible while the proposed item change is reviewed"
success_focus = "the affected object and proposed placement consequence within Time Month explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-MONTH-EDITING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change duration control and exact invalid field or boundary while Time Month explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-EDITING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-EDITING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-EDITING-002"
label = "Change start"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the start-boundary placement preview. The handoff starts from Time Month explicit state contract / Editing"
destination_id = "DEST-TIME-MONTH-EDITING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Editing reports the outcome from this visible condition: The month keeps the original date visible while the proposed item change is reviewed"
success_focus = "the affected object and proposed placement consequence within Time Month explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-MONTH-EDITING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change start control and exact invalid field or boundary while Time Month explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-EDITING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-EDITING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-EDITING-003"
label = "Edit"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "compact canonical object edit detail. The handoff starts from Time Month explicit state contract / Editing"
destination_id = "DEST-TIME-MONTH-EDITING-003"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the editable object fields is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Editing reports the outcome from this visible condition: The month keeps the original date visible while the proposed item change is reviewed"
success_focus = "the affected object and proposed placement consequence within Time Month explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-MONTH-EDITING-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Edit control and exact invalid field or boundary while Time Month explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-EDITING-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-EDITING-003"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-EDITING-004"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time Month explicit state contract / Editing"
destination_id = "DEST-TIME-MONTH-EDITING-004"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Editing reports the outcome from this visible condition: The month keeps the original date visible while the proposed item change is reviewed"
success_focus = "the affected object and proposed placement consequence within Time Month explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-MONTH-EDITING-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time Month explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-EDITING-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-EDITING-004"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-MONTH-EMPTY"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Today => destination: the current local date in Time Month. The handoff starts from Time Month explicit state contract / Empty; effect: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Month explicit state contract / Empty reports the outcome from this visible condition: The current month contains no Ambitions-owned time items; focus: the current-period date heading within Time Month explicit state contract / Empty."
durable_effect = "Exact command consequences: Today: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts. The durable boundary is specific to this visible evidence: The current month contains no Ambitions-owned time items."
recovery_rollback = "Exact rollback and recovery: Today: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The current month contains no Ambitions-owned time items."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The current month contains no Ambitions-owned time items."
accessibility_focus = "VoiceOver focus contract: Today announces its consequence, then success focuses the current-period date heading; rejection focuses the Today control and retained prior range. The announcement includes this user-facing evidence before focus moves: The current month contains no Ambitions-owned time items."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-EMPTY-001"
label = "Today"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The preferred Month view and current local date are available"]
destination = "the current local date in Time Month. The handoff starts from Time Month explicit state contract / Empty"
destination_id = "DEST-TIME-MONTH-EMPTY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Month explicit state contract / Empty reports the outcome from this visible condition: The current month contains no Ambitions-owned time items"
success_focus = "the current-period date heading within Time Month explicit state contract / Empty"
success_focus_id = "FOCUS-TIME-MONTH-EMPTY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Today control and retained prior range while Time Month explicit state contract / Empty remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-EMPTY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-EMPTY-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-MONTH-EXTERNAL-HIDDEN-CAPACITY"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Month. The handoff starts from Time Month explicit state contract / External Hidden Capacity; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Month explicit state contract / External Hidden Capacity reports the outcome from this visible condition: External details hidden. Month shows day-level capacity pressure without external item detail; focus: the selected object heading or selected date heading within Time Month explicit state contract / External Hidden Capacity."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: External details hidden. Month shows day-level capacity pressure without external item detail."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: External details hidden. Month shows day-level capacity pressure without external item detail."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: External details hidden. Month shows day-level capacity pressure without external item detail."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Month object/date control. The announcement includes this user-facing evidence before focus moves: External details hidden. Month shows day-level capacity pressure without external item detail."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-EXTERNAL-HIDDEN-CAPACITY-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Month range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Month. The handoff starts from Time Month explicit state contract / External Hidden Capacity"
destination_id = "DEST-TIME-MONTH-EXTERNAL-HIDDEN-CAPACITY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Month explicit state contract / External Hidden Capacity reports the outcome from this visible condition: External details hidden. Month shows day-level capacity pressure without external item detail"
success_focus = "the selected object heading or selected date heading within Time Month explicit state contract / External Hidden Capacity"
success_focus_id = "FOCUS-TIME-MONTH-EXTERNAL-HIDDEN-CAPACITY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Month object/date control while Time Month explicit state contract / External Hidden Capacity remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-EXTERNAL-HIDDEN-CAPACITY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-EXTERNAL-HIDDEN-CAPACITY-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-MONTH-IMPORTING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained Time Month range and pending import summary. The handoff starts from Time Month explicit state contract / Importing; effect: No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt; Time Month explicit state contract / Importing reports the outcome from this visible condition: Outside calendar dates are being compared before imported items enter the month grid; this command preserves accepted product state; focus: the initiating Month import control or date heading within Time Month explicit state contract / Importing."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt. The durable boundary is specific to this visible evidence: Outside calendar dates are being compared before imported items enter the month grid."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Outside calendar dates are being compared before imported items enter the month grid."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Outside calendar dates are being compared before imported items enter the month grid."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating Month import control or date heading; rejection focuses the import progress status and Cancel control. The announcement includes this user-facing evidence before focus moves: Outside calendar dates are being compared before imported items enter the month grid."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-IMPORTING-001"
label = "Cancel"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Any accepted import and Receipt are identified separately", "Only pending import comparison or optional loading remains uncommitted"]
destination = "the retained Time Month range and pending import summary. The handoff starts from Time Month explicit state contract / Importing"
destination_id = "DEST-TIME-MONTH-IMPORTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt; Time Month explicit state contract / Importing reports the outcome from this visible condition: Outside calendar dates are being compared before imported items enter the month grid; this command preserves accepted product state"
success_focus = "the initiating Month import control or date heading within Time Month explicit state contract / Importing"
success_focus_id = "FOCUS-TIME-MONTH-IMPORTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the import progress status and Cancel control while Time Month explicit state contract / Importing remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-IMPORTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-IMPORTING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-MONTH-NOW-ANCHORED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Today => destination: the current local date in Time Month. The handoff starts from Time Month explicit state contract / Now Anchored; effect: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Month explicit state contract / Now Anchored reports the outcome from this visible condition: Today is marked in the month grid; a minute-level Now marker is not shown; focus: the current-period date heading within Time Month explicit state contract / Now Anchored."
durable_effect = "Exact command consequences: Today: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts. The durable boundary is specific to this visible evidence: Today is marked in the month grid; a minute-level Now marker is not shown."
recovery_rollback = "Exact rollback and recovery: Today: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Today is marked in the month grid; a minute-level Now marker is not shown."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Today is marked in the month grid; a minute-level Now marker is not shown."
accessibility_focus = "VoiceOver focus contract: Today announces its consequence, then success focuses the current-period date heading; rejection focuses the Today control and retained prior range. The announcement includes this user-facing evidence before focus moves: Today is marked in the month grid; a minute-level Now marker is not shown."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-NOW-ANCHORED-001"
label = "Today"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The preferred Month view and current local date are available"]
destination = "the current local date in Time Month. The handoff starts from Time Month explicit state contract / Now Anchored"
destination_id = "DEST-TIME-MONTH-NOW-ANCHORED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Month explicit state contract / Now Anchored reports the outcome from this visible condition: Today is marked in the month grid; a minute-level Now marker is not shown"
success_focus = "the current-period date heading within Time Month explicit state contract / Now Anchored"
success_focus_id = "FOCUS-TIME-MONTH-NOW-ANCHORED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Today control and retained prior range while Time Month explicit state contract / Now Anchored remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-NOW-ANCHORED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-NOW-ANCHORED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-MONTH-POPULATED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Month. The handoff starts from Time Month explicit state contract / Populated; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Month explicit state contract / Populated reports the outcome from this visible condition: The month grid places saved items on their truthful dates and keeps item types distinguishable; focus: the selected object heading or selected date heading within Time Month explicit state contract / Populated."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The month grid places saved items on their truthful dates and keeps item types distinguishable."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The month grid places saved items on their truthful dates and keeps item types distinguishable."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The month grid places saved items on their truthful dates and keeps item types distinguishable."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Month object/date control. The announcement includes this user-facing evidence before focus moves: The month grid places saved items on their truthful dates and keeps item types distinguishable."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-POPULATED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Month range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Month. The handoff starts from Time Month explicit state contract / Populated"
destination_id = "DEST-TIME-MONTH-POPULATED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Month explicit state contract / Populated reports the outcome from this visible condition: The month grid places saved items on their truthful dates and keeps item types distinguishable"
success_focus = "the selected object heading or selected date heading within Time Month explicit state contract / Populated"
success_focus_id = "FOCUS-TIME-MONTH-POPULATED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Month object/date control while Time Month explicit state contract / Populated remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-POPULATED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-POPULATED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-MONTH-PREVIEWING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Keep current => destination: the unchanged Time Month object and current placement. The handoff starts from Time Month explicit state contract / Previewing; effect: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Month explicit state contract / Previewing reports the outcome from this visible condition: The month grid distinguishes proposed date changes from current saved placement before confirmation; this command preserves accepted product state; focus: the unchanged object and placement status within Time Month explicit state contract / Previewing.\nMove => destination: the object-scoped placement preview. The handoff starts from Time Month explicit state contract / Previewing; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Previewing reports the outcome from this visible condition: The month grid distinguishes proposed date changes from current saved placement before confirmation; focus: the affected object and proposed placement consequence within Time Month explicit state contract / Previewing."
durable_effect = "Exact command consequences: Keep current: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. The durable boundary is specific to this visible evidence: The month grid distinguishes proposed date changes from current saved placement before confirmation."
recovery_rollback = "Exact rollback and recovery: Keep current: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The month grid distinguishes proposed date changes from current saved placement before confirmation."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The month grid distinguishes proposed date changes from current saved placement before confirmation."
accessibility_focus = "VoiceOver focus contract: Keep current announces its consequence, then success focuses the unchanged object and placement status; rejection focuses the Keep current control | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: The month grid distinguishes proposed date changes from current saved placement before confirmation."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-PREVIEWING-001"
label = "Keep current"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["A placement or conflict proposal is open and the current placement revision remains valid"]
destination = "the unchanged Time Month object and current placement. The handoff starts from Time Month explicit state contract / Previewing"
destination_id = "DEST-TIME-MONTH-PREVIEWING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Month explicit state contract / Previewing reports the outcome from this visible condition: The month grid distinguishes proposed date changes from current saved placement before confirmation; this command preserves accepted product state"
success_focus = "the unchanged object and placement status within Time Month explicit state contract / Previewing"
success_focus_id = "FOCUS-TIME-MONTH-PREVIEWING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep current control while Time Month explicit state contract / Previewing remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-PREVIEWING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-PREVIEWING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-PREVIEWING-002"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time Month explicit state contract / Previewing"
destination_id = "DEST-TIME-MONTH-PREVIEWING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Month explicit state contract / Previewing reports the outcome from this visible condition: The month grid distinguishes proposed date changes from current saved placement before confirmation"
success_focus = "the affected object and proposed placement consequence within Time Month explicit state contract / Previewing"
success_focus_id = "FOCUS-TIME-MONTH-PREVIEWING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time Month explicit state contract / Previewing remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-PREVIEWING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-PREVIEWING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-MONTH-RESTORED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Month. The handoff starts from Time Month explicit state contract / Restored; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Month explicit state contract / Restored reports the outcome from this visible condition: The prior month and selected date return after saved items are rechecked; focus: the selected object heading or selected date heading within Time Month explicit state contract / Restored."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The prior month and selected date return after saved items are rechecked."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The prior month and selected date return after saved items are rechecked."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The prior month and selected date return after saved items are rechecked."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Month object/date control. The announcement includes this user-facing evidence before focus moves: The prior month and selected date return after saved items are rechecked."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-RESTORED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Month range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Month. The handoff starts from Time Month explicit state contract / Restored"
destination_id = "DEST-TIME-MONTH-RESTORED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Month explicit state contract / Restored reports the outcome from this visible condition: The prior month and selected date return after saved items are rechecked"
success_focus = "the selected object heading or selected date heading within Time Month explicit state contract / Restored"
success_focus_id = "FOCUS-TIME-MONTH-RESTORED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Month object/date control while Time Month explicit state contract / Restored remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-RESTORED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-RESTORED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-MONTH-SELECTED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Month. The handoff starts from Time Month explicit state contract / Selected; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Month explicit state contract / Selected reports the outcome from this visible condition: The chosen month item opens with its date and saved details while the month context stays visible; focus: the selected object heading or selected date heading within Time Month explicit state contract / Selected."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The chosen month item opens with its date and saved details while the month context stays visible."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The chosen month item opens with its date and saved details while the month context stays visible."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The chosen month item opens with its date and saved details while the month context stays visible."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Month object/date control. The announcement includes this user-facing evidence before focus moves: The chosen month item opens with its date and saved details while the month context stays visible."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-MONTH-SELECTED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Month range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Month. The handoff starts from Time Month explicit state contract / Selected"
destination_id = "DEST-TIME-MONTH-SELECTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Month explicit state contract / Selected reports the outcome from this visible condition: The chosen month item opens with its date and saved details while the month context stays visible"
success_focus = "the selected object heading or selected date heading within Time Month explicit state contract / Selected"
success_focus_id = "FOCUS-TIME-MONTH-SELECTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Month object/date control while Time Month explicit state contract / Selected remains visible"
failure_focus_id = "FOCUS-TIME-MONTH-SELECTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-MONTH-SELECTED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-WEEK-CONFLICTING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Adjust plan => destination: the multi-item Time adjustment review. The handoff starts from Time Week explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Conflicting reports the outcome from this visible condition: The weekly layout shows the overlap in its actual day and time without crossing protected time; focus: the affected object and proposed placement consequence within Time Week explicit state contract / Conflicting.\nChange duration => destination: the duration-boundary placement preview. The handoff starts from Time Week explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Conflicting reports the outcome from this visible condition: The weekly layout shows the overlap in its actual day and time without crossing protected time; focus: the affected object and proposed placement consequence within Time Week explicit state contract / Conflicting.\nChange start => destination: the start-boundary placement preview. The handoff starts from Time Week explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Conflicting reports the outcome from this visible condition: The weekly layout shows the overlap in its actual day and time without crossing protected time; focus: the affected object and proposed placement consequence within Time Week explicit state contract / Conflicting.\nKeep current => destination: the unchanged Time Week object and current placement. The handoff starts from Time Week explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Week explicit state contract / Conflicting reports the outcome from this visible condition: The weekly layout shows the overlap in its actual day and time without crossing protected time; this command preserves accepted product state; focus: the unchanged object and placement status within Time Week explicit state contract / Conflicting.\nMove => destination: the object-scoped placement preview. The handoff starts from Time Week explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Conflicting reports the outcome from this visible condition: The weekly layout shows the overlap in its actual day and time without crossing protected time; focus: the affected object and proposed placement consequence within Time Week explicit state contract / Conflicting.\nResolve conflict => destination: the revision-bound Time conflict comparison. The handoff starts from Time Week explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed; Time Week explicit state contract / Conflicting reports the outcome from this visible condition: The weekly layout shows the overlap in its actual day and time without crossing protected time; focus: the affected object and proposed placement consequence within Time Week explicit state contract / Conflicting."
durable_effect = "Exact command consequences: Adjust plan: No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change duration: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change start: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Keep current: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Resolve conflict: No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed. The durable boundary is specific to this visible evidence: The weekly layout shows the overlap in its actual day and time without crossing protected time."
recovery_rollback = "Exact rollback and recovery: Adjust plan: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change duration: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change start: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Keep current: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Resolve conflict: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The weekly layout shows the overlap in its actual day and time without crossing protected time."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The weekly layout shows the overlap in its actual day and time without crossing protected time."
accessibility_focus = "VoiceOver focus contract: Adjust plan announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Adjust plan control and exact invalid field or boundary | Change duration announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change duration control and exact invalid field or boundary | Change start announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change start control and exact invalid field or boundary | Keep current announces its consequence, then success focuses the unchanged object and placement status; rejection focuses the Keep current control | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary | Resolve conflict announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Resolve conflict control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: The weekly layout shows the overlap in its actual day and time without crossing protected time."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-CONFLICTING-001"
label = "Adjust plan"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the multi-item Time adjustment review. The handoff starts from Time Week explicit state contract / Conflicting"
destination_id = "DEST-TIME-WEEK-CONFLICTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Conflicting reports the outcome from this visible condition: The weekly layout shows the overlap in its actual day and time without crossing protected time"
success_focus = "the affected object and proposed placement consequence within Time Week explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-WEEK-CONFLICTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Adjust plan control and exact invalid field or boundary while Time Week explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-CONFLICTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-CONFLICTING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-CONFLICTING-002"
label = "Change duration"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the duration-boundary placement preview. The handoff starts from Time Week explicit state contract / Conflicting"
destination_id = "DEST-TIME-WEEK-CONFLICTING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Conflicting reports the outcome from this visible condition: The weekly layout shows the overlap in its actual day and time without crossing protected time"
success_focus = "the affected object and proposed placement consequence within Time Week explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-WEEK-CONFLICTING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change duration control and exact invalid field or boundary while Time Week explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-CONFLICTING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-CONFLICTING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-CONFLICTING-003"
label = "Change start"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the start-boundary placement preview. The handoff starts from Time Week explicit state contract / Conflicting"
destination_id = "DEST-TIME-WEEK-CONFLICTING-003"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Conflicting reports the outcome from this visible condition: The weekly layout shows the overlap in its actual day and time without crossing protected time"
success_focus = "the affected object and proposed placement consequence within Time Week explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-WEEK-CONFLICTING-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change start control and exact invalid field or boundary while Time Week explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-CONFLICTING-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-CONFLICTING-003"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-CONFLICTING-004"
label = "Keep current"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["A placement or conflict proposal is open and the current placement revision remains valid"]
destination = "the unchanged Time Week object and current placement. The handoff starts from Time Week explicit state contract / Conflicting"
destination_id = "DEST-TIME-WEEK-CONFLICTING-004"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Week explicit state contract / Conflicting reports the outcome from this visible condition: The weekly layout shows the overlap in its actual day and time without crossing protected time; this command preserves accepted product state"
success_focus = "the unchanged object and placement status within Time Week explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-WEEK-CONFLICTING-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep current control while Time Week explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-CONFLICTING-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-CONFLICTING-004"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-CONFLICTING-005"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time Week explicit state contract / Conflicting"
destination_id = "DEST-TIME-WEEK-CONFLICTING-005"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Conflicting reports the outcome from this visible condition: The weekly layout shows the overlap in its actual day and time without crossing protected time"
success_focus = "the affected object and proposed placement consequence within Time Week explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-WEEK-CONFLICTING-005-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time Week explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-CONFLICTING-005-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-CONFLICTING-005"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-CONFLICTING-006"
label = "Resolve conflict"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the revision-bound Time conflict comparison. The handoff starts from Time Week explicit state contract / Conflicting"
destination_id = "DEST-TIME-WEEK-CONFLICTING-006"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed; Time Week explicit state contract / Conflicting reports the outcome from this visible condition: The weekly layout shows the overlap in its actual day and time without crossing protected time"
success_focus = "the affected object and proposed placement consequence within Time Week explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-WEEK-CONFLICTING-006-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Resolve conflict control and exact invalid field or boundary while Time Week explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-CONFLICTING-006-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-CONFLICTING-006"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-WEEK-DENSE"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Week. The handoff starts from Time Week explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Week explicit state contract / Dense reports the outcome from this visible condition: The weekly layout compresses crowded hours while preserving chronological order and fixed boundaries; focus: the selected object heading or selected date heading within Time Week explicit state contract / Dense."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The weekly layout compresses crowded hours while preserving chronological order and fixed boundaries."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The weekly layout compresses crowded hours while preserving chronological order and fixed boundaries."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The weekly layout compresses crowded hours while preserving chronological order and fixed boundaries."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Week object/date control. The announcement includes this user-facing evidence before focus moves: The weekly layout compresses crowded hours while preserving chronological order and fixed boundaries."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-DENSE-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Week range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Week. The handoff starts from Time Week explicit state contract / Dense"
destination_id = "DEST-TIME-WEEK-DENSE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Week explicit state contract / Dense reports the outcome from this visible condition: The weekly layout compresses crowded hours while preserving chronological order and fixed boundaries"
success_focus = "the selected object heading or selected date heading within Time Week explicit state contract / Dense"
success_focus_id = "FOCUS-TIME-WEEK-DENSE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Week object/date control while Time Week explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-DENSE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-DENSE-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-WEEK-EDITING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Change duration => destination: the duration-boundary placement preview. The handoff starts from Time Week explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Editing reports the outcome from this visible condition: The weekly layout shows the original block beside its proposed time until confirmation; focus: the affected object and proposed placement consequence within Time Week explicit state contract / Editing.\nChange start => destination: the start-boundary placement preview. The handoff starts from Time Week explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Editing reports the outcome from this visible condition: The weekly layout shows the original block beside its proposed time until confirmation; focus: the affected object and proposed placement consequence within Time Week explicit state contract / Editing.\nEdit => destination: compact canonical object edit detail. The handoff starts from Time Week explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; the editable object fields is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Editing reports the outcome from this visible condition: The weekly layout shows the original block beside its proposed time until confirmation; focus: the affected object and proposed placement consequence within Time Week explicit state contract / Editing.\nMove => destination: the object-scoped placement preview. The handoff starts from Time Week explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Editing reports the outcome from this visible condition: The weekly layout shows the original block beside its proposed time until confirmation; focus: the affected object and proposed placement consequence within Time Week explicit state contract / Editing."
durable_effect = "Exact command consequences: Change duration: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change start: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Edit: No durable mutation occurs and no Receipt is created; the editable object fields is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. The durable boundary is specific to this visible evidence: The weekly layout shows the original block beside its proposed time until confirmation."
recovery_rollback = "Exact rollback and recovery: Change duration: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change start: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Edit: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The weekly layout shows the original block beside its proposed time until confirmation."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The weekly layout shows the original block beside its proposed time until confirmation."
accessibility_focus = "VoiceOver focus contract: Change duration announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change duration control and exact invalid field or boundary | Change start announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change start control and exact invalid field or boundary | Edit announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Edit control and exact invalid field or boundary | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: The weekly layout shows the original block beside its proposed time until confirmation."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-EDITING-001"
label = "Change duration"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the duration-boundary placement preview. The handoff starts from Time Week explicit state contract / Editing"
destination_id = "DEST-TIME-WEEK-EDITING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Editing reports the outcome from this visible condition: The weekly layout shows the original block beside its proposed time until confirmation"
success_focus = "the affected object and proposed placement consequence within Time Week explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-WEEK-EDITING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change duration control and exact invalid field or boundary while Time Week explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-EDITING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-EDITING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-EDITING-002"
label = "Change start"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the start-boundary placement preview. The handoff starts from Time Week explicit state contract / Editing"
destination_id = "DEST-TIME-WEEK-EDITING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Editing reports the outcome from this visible condition: The weekly layout shows the original block beside its proposed time until confirmation"
success_focus = "the affected object and proposed placement consequence within Time Week explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-WEEK-EDITING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change start control and exact invalid field or boundary while Time Week explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-EDITING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-EDITING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-EDITING-003"
label = "Edit"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "compact canonical object edit detail. The handoff starts from Time Week explicit state contract / Editing"
destination_id = "DEST-TIME-WEEK-EDITING-003"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the editable object fields is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Editing reports the outcome from this visible condition: The weekly layout shows the original block beside its proposed time until confirmation"
success_focus = "the affected object and proposed placement consequence within Time Week explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-WEEK-EDITING-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Edit control and exact invalid field or boundary while Time Week explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-EDITING-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-EDITING-003"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-EDITING-004"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time Week explicit state contract / Editing"
destination_id = "DEST-TIME-WEEK-EDITING-004"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Editing reports the outcome from this visible condition: The weekly layout shows the original block beside its proposed time until confirmation"
success_focus = "the affected object and proposed placement consequence within Time Week explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-WEEK-EDITING-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time Week explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-EDITING-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-EDITING-004"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-WEEK-EMPTY"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Today => destination: the current local date in Time Week. The handoff starts from Time Week explicit state contract / Empty; effect: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Week explicit state contract / Empty reports the outcome from this visible condition: The current week contains no Ambitions-owned time items in its day columns; focus: the current-period date heading within Time Week explicit state contract / Empty."
durable_effect = "Exact command consequences: Today: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts. The durable boundary is specific to this visible evidence: The current week contains no Ambitions-owned time items in its day columns."
recovery_rollback = "Exact rollback and recovery: Today: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The current week contains no Ambitions-owned time items in its day columns."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The current week contains no Ambitions-owned time items in its day columns."
accessibility_focus = "VoiceOver focus contract: Today announces its consequence, then success focuses the current-period date heading; rejection focuses the Today control and retained prior range. The announcement includes this user-facing evidence before focus moves: The current week contains no Ambitions-owned time items in its day columns."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-EMPTY-001"
label = "Today"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The preferred Week view and current local date are available"]
destination = "the current local date in Time Week. The handoff starts from Time Week explicit state contract / Empty"
destination_id = "DEST-TIME-WEEK-EMPTY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Week explicit state contract / Empty reports the outcome from this visible condition: The current week contains no Ambitions-owned time items in its day columns"
success_focus = "the current-period date heading within Time Week explicit state contract / Empty"
success_focus_id = "FOCUS-TIME-WEEK-EMPTY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Today control and retained prior range while Time Week explicit state contract / Empty remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-EMPTY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-EMPTY-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-WEEK-EXTERNAL-HIDDEN-CAPACITY"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Week. The handoff starts from Time Week explicit state contract / External Hidden Capacity; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Week explicit state contract / External Hidden Capacity reports the outcome from this visible condition: External details hidden. Week shows anonymous busy spans across day columns without event identity; focus: the selected object heading or selected date heading within Time Week explicit state contract / External Hidden Capacity."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: External details hidden. Week shows anonymous busy spans across day columns without event identity."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: External details hidden. Week shows anonymous busy spans across day columns without event identity."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: External details hidden. Week shows anonymous busy spans across day columns without event identity."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Week object/date control. The announcement includes this user-facing evidence before focus moves: External details hidden. Week shows anonymous busy spans across day columns without event identity."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-EXTERNAL-HIDDEN-CAPACITY-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Week range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Week. The handoff starts from Time Week explicit state contract / External Hidden Capacity"
destination_id = "DEST-TIME-WEEK-EXTERNAL-HIDDEN-CAPACITY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Week explicit state contract / External Hidden Capacity reports the outcome from this visible condition: External details hidden. Week shows anonymous busy spans across day columns without event identity"
success_focus = "the selected object heading or selected date heading within Time Week explicit state contract / External Hidden Capacity"
success_focus_id = "FOCUS-TIME-WEEK-EXTERNAL-HIDDEN-CAPACITY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Week object/date control while Time Week explicit state contract / External Hidden Capacity remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-EXTERNAL-HIDDEN-CAPACITY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-EXTERNAL-HIDDEN-CAPACITY-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-WEEK-IMPORTING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained Time Week range and pending import summary. The handoff starts from Time Week explicit state contract / Importing; effect: No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt; Time Week explicit state contract / Importing reports the outcome from this visible condition: Outside calendar intervals are being compared before imported items enter the weekly layout; this command preserves accepted product state; focus: the initiating Week import control or date heading within Time Week explicit state contract / Importing."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt. The durable boundary is specific to this visible evidence: Outside calendar intervals are being compared before imported items enter the weekly layout."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Outside calendar intervals are being compared before imported items enter the weekly layout."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Outside calendar intervals are being compared before imported items enter the weekly layout."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating Week import control or date heading; rejection focuses the import progress status and Cancel control. The announcement includes this user-facing evidence before focus moves: Outside calendar intervals are being compared before imported items enter the weekly layout."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-IMPORTING-001"
label = "Cancel"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Any accepted import and Receipt are identified separately", "Only pending import comparison or optional loading remains uncommitted"]
destination = "the retained Time Week range and pending import summary. The handoff starts from Time Week explicit state contract / Importing"
destination_id = "DEST-TIME-WEEK-IMPORTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt; Time Week explicit state contract / Importing reports the outcome from this visible condition: Outside calendar intervals are being compared before imported items enter the weekly layout; this command preserves accepted product state"
success_focus = "the initiating Week import control or date heading within Time Week explicit state contract / Importing"
success_focus_id = "FOCUS-TIME-WEEK-IMPORTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the import progress status and Cancel control while Time Week explicit state contract / Importing remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-IMPORTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-IMPORTING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-WEEK-NOW-ANCHORED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Today => destination: the current local date in Time Week. The handoff starts from Time Week explicit state contract / Now Anchored; effect: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Week explicit state contract / Now Anchored reports the outcome from this visible condition: Today and the current time line anchor the week to chronological reality; focus: the current-period date heading within Time Week explicit state contract / Now Anchored."
durable_effect = "Exact command consequences: Today: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts. The durable boundary is specific to this visible evidence: Today and the current time line anchor the week to chronological reality."
recovery_rollback = "Exact rollback and recovery: Today: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Today and the current time line anchor the week to chronological reality."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Today and the current time line anchor the week to chronological reality."
accessibility_focus = "VoiceOver focus contract: Today announces its consequence, then success focuses the current-period date heading; rejection focuses the Today control and retained prior range. The announcement includes this user-facing evidence before focus moves: Today and the current time line anchor the week to chronological reality."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-NOW-ANCHORED-001"
label = "Today"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The preferred Week view and current local date are available"]
destination = "the current local date in Time Week. The handoff starts from Time Week explicit state contract / Now Anchored"
destination_id = "DEST-TIME-WEEK-NOW-ANCHORED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Week explicit state contract / Now Anchored reports the outcome from this visible condition: Today and the current time line anchor the week to chronological reality"
success_focus = "the current-period date heading within Time Week explicit state contract / Now Anchored"
success_focus_id = "FOCUS-TIME-WEEK-NOW-ANCHORED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Today control and retained prior range while Time Week explicit state contract / Now Anchored remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-NOW-ANCHORED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-NOW-ANCHORED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-WEEK-POPULATED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Week. The handoff starts from Time Week explicit state contract / Populated; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Week explicit state contract / Populated reports the outcome from this visible condition: The weekly layout places saved items at their truthful days and times with protected time intact; focus: the selected object heading or selected date heading within Time Week explicit state contract / Populated."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The weekly layout places saved items at their truthful days and times with protected time intact."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The weekly layout places saved items at their truthful days and times with protected time intact."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The weekly layout places saved items at their truthful days and times with protected time intact."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Week object/date control. The announcement includes this user-facing evidence before focus moves: The weekly layout places saved items at their truthful days and times with protected time intact."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-POPULATED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Week range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Week. The handoff starts from Time Week explicit state contract / Populated"
destination_id = "DEST-TIME-WEEK-POPULATED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Week explicit state contract / Populated reports the outcome from this visible condition: The weekly layout places saved items at their truthful days and times with protected time intact"
success_focus = "the selected object heading or selected date heading within Time Week explicit state contract / Populated"
success_focus_id = "FOCUS-TIME-WEEK-POPULATED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Week object/date control while Time Week explicit state contract / Populated remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-POPULATED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-POPULATED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-WEEK-PREVIEWING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Keep current => destination: the unchanged Time Week object and current placement. The handoff starts from Time Week explicit state contract / Previewing; effect: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Week explicit state contract / Previewing reports the outcome from this visible condition: The weekly layout overlays a proposed time without replacing the current block before confirmation; this command preserves accepted product state; focus: the unchanged object and placement status within Time Week explicit state contract / Previewing.\nMove => destination: the object-scoped placement preview. The handoff starts from Time Week explicit state contract / Previewing; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Previewing reports the outcome from this visible condition: The weekly layout overlays a proposed time without replacing the current block before confirmation; focus: the affected object and proposed placement consequence within Time Week explicit state contract / Previewing."
durable_effect = "Exact command consequences: Keep current: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. The durable boundary is specific to this visible evidence: The weekly layout overlays a proposed time without replacing the current block before confirmation."
recovery_rollback = "Exact rollback and recovery: Keep current: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The weekly layout overlays a proposed time without replacing the current block before confirmation."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The weekly layout overlays a proposed time without replacing the current block before confirmation."
accessibility_focus = "VoiceOver focus contract: Keep current announces its consequence, then success focuses the unchanged object and placement status; rejection focuses the Keep current control | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: The weekly layout overlays a proposed time without replacing the current block before confirmation."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-PREVIEWING-001"
label = "Keep current"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["A placement or conflict proposal is open and the current placement revision remains valid"]
destination = "the unchanged Time Week object and current placement. The handoff starts from Time Week explicit state contract / Previewing"
destination_id = "DEST-TIME-WEEK-PREVIEWING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Week explicit state contract / Previewing reports the outcome from this visible condition: The weekly layout overlays a proposed time without replacing the current block before confirmation; this command preserves accepted product state"
success_focus = "the unchanged object and placement status within Time Week explicit state contract / Previewing"
success_focus_id = "FOCUS-TIME-WEEK-PREVIEWING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep current control while Time Week explicit state contract / Previewing remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-PREVIEWING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-PREVIEWING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-PREVIEWING-002"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time Week explicit state contract / Previewing"
destination_id = "DEST-TIME-WEEK-PREVIEWING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Week explicit state contract / Previewing reports the outcome from this visible condition: The weekly layout overlays a proposed time without replacing the current block before confirmation"
success_focus = "the affected object and proposed placement consequence within Time Week explicit state contract / Previewing"
success_focus_id = "FOCUS-TIME-WEEK-PREVIEWING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time Week explicit state contract / Previewing remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-PREVIEWING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-PREVIEWING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-WEEK-RESTORED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Week. The handoff starts from Time Week explicit state contract / Restored; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Week explicit state contract / Restored reports the outcome from this visible condition: The prior week, vertical position, and focus return after current local time items are checked; focus: the selected object heading or selected date heading within Time Week explicit state contract / Restored."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The prior week, vertical position, and focus return after current local time items are checked."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The prior week, vertical position, and focus return after current local time items are checked."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The prior week, vertical position, and focus return after current local time items are checked."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Week object/date control. The announcement includes this user-facing evidence before focus moves: The prior week, vertical position, and focus return after current local time items are checked."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-RESTORED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Week range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Week. The handoff starts from Time Week explicit state contract / Restored"
destination_id = "DEST-TIME-WEEK-RESTORED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Week explicit state contract / Restored reports the outcome from this visible condition: The prior week, vertical position, and focus return after current local time items are checked"
success_focus = "the selected object heading or selected date heading within Time Week explicit state contract / Restored"
success_focus_id = "FOCUS-TIME-WEEK-RESTORED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Week object/date control while Time Week explicit state contract / Restored remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-RESTORED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-RESTORED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-WEEK-SELECTED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: compact detail for the selected canonical Time object in Week. The handoff starts from Time Week explicit state contract / Selected; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Week explicit state contract / Selected reports the outcome from this visible condition: The chosen weekly block shows its saved details at the actual day and time; focus: the selected object heading or selected date heading within Time Week explicit state contract / Selected."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The chosen weekly block shows its saved details at the actual day and time."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The chosen weekly block shows its saved details at the actual day and time."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The chosen weekly block shows its saved details at the actual day and time."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Week object/date control. The announcement includes this user-facing evidence before focus moves: The chosen weekly block shows its saved details at the actual day and time."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-WEEK-SELECTED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Week range and selected stable object or date identity are current"]
destination = "compact detail for the selected canonical Time object in Week. The handoff starts from Time Week explicit state contract / Selected"
destination_id = "DEST-TIME-WEEK-SELECTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Week explicit state contract / Selected reports the outcome from this visible condition: The chosen weekly block shows its saved details at the actual day and time"
success_focus = "the selected object heading or selected date heading within Time Week explicit state contract / Selected"
success_focus_id = "FOCUS-TIME-WEEK-SELECTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Week object/date control while Time Week explicit state contract / Selected remains visible"
failure_focus_id = "FOCUS-TIME-WEEK-SELECTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-WEEK-SELECTED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-YEAR-CONFLICTING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Adjust plan => destination: the multi-item Time adjustment review. The handoff starts from Time Year explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Year explicit state contract / Conflicting reports the outcome from this visible condition: At least one month contains a protected-time conflict. Individual Event details remain hidden; focus: the affected object and proposed placement consequence within Time Year explicit state contract / Conflicting.\nChange duration => destination: the duration-boundary placement preview. The handoff starts from Time Year explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Year explicit state contract / Conflicting reports the outcome from this visible condition: At least one month contains a protected-time conflict. Individual Event details remain hidden; focus: the affected object and proposed placement consequence within Time Year explicit state contract / Conflicting.\nChange start => destination: the start-boundary placement preview. The handoff starts from Time Year explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Year explicit state contract / Conflicting reports the outcome from this visible condition: At least one month contains a protected-time conflict. Individual Event details remain hidden; focus: the affected object and proposed placement consequence within Time Year explicit state contract / Conflicting.\nKeep current => destination: the unchanged Time Year object and current placement. The handoff starts from Time Year explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Year explicit state contract / Conflicting reports the outcome from this visible condition: At least one month contains a protected-time conflict. Individual Event details remain hidden; this command preserves accepted product state; focus: the unchanged object and placement status within Time Year explicit state contract / Conflicting.\nMove => destination: the object-scoped placement preview. The handoff starts from Time Year explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Year explicit state contract / Conflicting reports the outcome from this visible condition: At least one month contains a protected-time conflict. Individual Event details remain hidden; focus: the affected object and proposed placement consequence within Time Year explicit state contract / Conflicting.\nResolve conflict => destination: the revision-bound Time conflict comparison. The handoff starts from Time Year explicit state contract / Conflicting; effect: No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed; Time Year explicit state contract / Conflicting reports the outcome from this visible condition: At least one month contains a protected-time conflict. Individual Event details remain hidden; focus: the affected object and proposed placement consequence within Time Year explicit state contract / Conflicting."
durable_effect = "Exact command consequences: Adjust plan: No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change duration: No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Change start: No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Keep current: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. | Resolve conflict: No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed. The durable boundary is specific to this visible evidence: At least one month contains a protected-time conflict. Individual Event details remain hidden."
recovery_rollback = "Exact rollback and recovery: Adjust plan: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change duration: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Change start: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Keep current: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Resolve conflict: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: At least one month contains a protected-time conflict. Individual Event details remain hidden."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: At least one month contains a protected-time conflict. Individual Event details remain hidden."
accessibility_focus = "VoiceOver focus contract: Adjust plan announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Adjust plan control and exact invalid field or boundary | Change duration announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change duration control and exact invalid field or boundary | Change start announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Change start control and exact invalid field or boundary | Keep current announces its consequence, then success focuses the unchanged object and placement status; rejection focuses the Keep current control | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary | Resolve conflict announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Resolve conflict control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: At least one month contains a protected-time conflict. Individual Event details remain hidden."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-CONFLICTING-001"
label = "Adjust plan"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the multi-item Time adjustment review. The handoff starts from Time Year explicit state contract / Conflicting"
destination_id = "DEST-TIME-YEAR-CONFLICTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the affected placements and plan constraints is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Year explicit state contract / Conflicting reports the outcome from this visible condition: At least one month contains a protected-time conflict. Individual Event details remain hidden"
success_focus = "the affected object and proposed placement consequence within Time Year explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-YEAR-CONFLICTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Adjust plan control and exact invalid field or boundary while Time Year explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-CONFLICTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-CONFLICTING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-CONFLICTING-002"
label = "Change duration"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the duration-boundary placement preview. The handoff starts from Time Year explicit state contract / Conflicting"
destination_id = "DEST-TIME-YEAR-CONFLICTING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed duration boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Year explicit state contract / Conflicting reports the outcome from this visible condition: At least one month contains a protected-time conflict. Individual Event details remain hidden"
success_focus = "the affected object and proposed placement consequence within Time Year explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-YEAR-CONFLICTING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change duration control and exact invalid field or boundary while Time Year explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-CONFLICTING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-CONFLICTING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-CONFLICTING-003"
label = "Change start"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the start-boundary placement preview. The handoff starts from Time Year explicit state contract / Conflicting"
destination_id = "DEST-TIME-YEAR-CONFLICTING-003"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed start boundary is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Year explicit state contract / Conflicting reports the outcome from this visible condition: At least one month contains a protected-time conflict. Individual Event details remain hidden"
success_focus = "the affected object and proposed placement consequence within Time Year explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-YEAR-CONFLICTING-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Change start control and exact invalid field or boundary while Time Year explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-CONFLICTING-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-CONFLICTING-003"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-CONFLICTING-004"
label = "Keep current"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["A placement or conflict proposal is open and the current placement revision remains valid"]
destination = "the unchanged Time Year object and current placement. The handoff starts from Time Year explicit state contract / Conflicting"
destination_id = "DEST-TIME-YEAR-CONFLICTING-004"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Year explicit state contract / Conflicting reports the outcome from this visible condition: At least one month contains a protected-time conflict. Individual Event details remain hidden; this command preserves accepted product state"
success_focus = "the unchanged object and placement status within Time Year explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-YEAR-CONFLICTING-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep current control while Time Year explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-CONFLICTING-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-CONFLICTING-004"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-CONFLICTING-005"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time Year explicit state contract / Conflicting"
destination_id = "DEST-TIME-YEAR-CONFLICTING-005"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Year explicit state contract / Conflicting reports the outcome from this visible condition: At least one month contains a protected-time conflict. Individual Event details remain hidden"
success_focus = "the affected object and proposed placement consequence within Time Year explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-YEAR-CONFLICTING-005-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time Year explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-CONFLICTING-005-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-CONFLICTING-005"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-CONFLICTING-006"
label = "Resolve conflict"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the revision-bound Time conflict comparison. The handoff starts from Time Year explicit state contract / Conflicting"
destination_id = "DEST-TIME-YEAR-CONFLICTING-006"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Move, Change start, Change duration, Adjust plan, and Keep current choices filtered by object type, recurrence, and authority is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. Protected, Fixed, recurrence, and external authority boundaries are disclosed; Time Year explicit state contract / Conflicting reports the outcome from this visible condition: At least one month contains a protected-time conflict. Individual Event details remain hidden"
success_focus = "the affected object and proposed placement consequence within Time Year explicit state contract / Conflicting"
success_focus_id = "FOCUS-TIME-YEAR-CONFLICTING-006-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Resolve conflict control and exact invalid field or boundary while Time Year explicit state contract / Conflicting remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-CONFLICTING-006-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-CONFLICTING-006"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-YEAR-DENSE"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: the selected month in Time Month. The handoff starts from Time Year explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Year explicit state contract / Dense reports the outcome from this visible condition: Busy months remain grouped across the year. Individual Event details stay hidden; focus: the selected object heading or selected date heading within Time Year explicit state contract / Dense."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: Busy months remain grouped across the year. Individual Event details stay hidden."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Busy months remain grouped across the year. Individual Event details stay hidden."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Busy months remain grouped across the year. Individual Event details stay hidden."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Year object/date control. The announcement includes this user-facing evidence before focus moves: Busy months remain grouped across the year. Individual Event details stay hidden."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-DENSE-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Year range and selected stable object or date identity are current"]
destination = "the selected month in Time Month. The handoff starts from Time Year explicit state contract / Dense"
destination_id = "DEST-TIME-YEAR-DENSE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Year explicit state contract / Dense reports the outcome from this visible condition: Busy months remain grouped across the year. Individual Event details stay hidden"
success_focus = "the selected object heading or selected date heading within Time Year explicit state contract / Dense"
success_focus_id = "FOCUS-TIME-YEAR-DENSE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Year object/date control while Time Year explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-DENSE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-DENSE-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-YEAR-EDITING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: the selected month in Time Month. The handoff starts from Time Year explicit state contract / Editing; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Year explicit state contract / Editing reports the outcome from this visible condition: Year view does not edit individual Events. The selected month remains visible; focus: the selected object heading or selected date heading within Time Year explicit state contract / Editing."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: Year view does not edit individual Events. The selected month remains visible."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Year view does not edit individual Events. The selected month remains visible."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Year view does not edit individual Events. The selected month remains visible."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Year object/date control. The announcement includes this user-facing evidence before focus moves: Year view does not edit individual Events. The selected month remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-EDITING-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Year range and selected stable object or date identity are current"]
destination = "the selected month in Time Month. The handoff starts from Time Year explicit state contract / Editing"
destination_id = "DEST-TIME-YEAR-EDITING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Year explicit state contract / Editing reports the outcome from this visible condition: Year view does not edit individual Events. The selected month remains visible"
success_focus = "the selected object heading or selected date heading within Time Year explicit state contract / Editing"
success_focus_id = "FOCUS-TIME-YEAR-EDITING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Year object/date control while Time Year explicit state contract / Editing remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-EDITING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-EDITING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-YEAR-EMPTY"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Today => destination: the current local date in Time Year. The handoff starts from Time Year explicit state contract / Empty; effect: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Year explicit state contract / Empty reports the outcome from this visible condition: No Ambitions Events, Reminders, or protected blocks appear in this year. All twelve months remain visible; focus: the current-period date heading within Time Year explicit state contract / Empty."
durable_effect = "Exact command consequences: Today: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts. The durable boundary is specific to this visible evidence: No Ambitions Events, Reminders, or protected blocks appear in this year. All twelve months remain visible."
recovery_rollback = "Exact rollback and recovery: Today: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: No Ambitions Events, Reminders, or protected blocks appear in this year. All twelve months remain visible."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: No Ambitions Events, Reminders, or protected blocks appear in this year. All twelve months remain visible."
accessibility_focus = "VoiceOver focus contract: Today announces its consequence, then success focuses the current-period date heading; rejection focuses the Today control and retained prior range. The announcement includes this user-facing evidence before focus moves: No Ambitions Events, Reminders, or protected blocks appear in this year. All twelve months remain visible."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-EMPTY-001"
label = "Today"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The preferred Year view and current local date are available"]
destination = "the current local date in Time Year. The handoff starts from Time Year explicit state contract / Empty"
destination_id = "DEST-TIME-YEAR-EMPTY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Year explicit state contract / Empty reports the outcome from this visible condition: No Ambitions Events, Reminders, or protected blocks appear in this year. All twelve months remain visible"
success_focus = "the current-period date heading within Time Year explicit state contract / Empty"
success_focus_id = "FOCUS-TIME-YEAR-EMPTY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Today control and retained prior range while Time Year explicit state contract / Empty remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-EMPTY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-EMPTY-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-YEAR-EXTERNAL-HIDDEN-CAPACITY"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: the selected month in Time Month. The handoff starts from Time Year explicit state contract / External Hidden Capacity; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Year explicit state contract / External Hidden Capacity reports the outcome from this visible condition: Outside calendar details remain hidden. Each month shows only its overall available time; focus: the selected object heading or selected date heading within Time Year explicit state contract / External Hidden Capacity."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: Outside calendar details remain hidden. Each month shows only its overall available time."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Outside calendar details remain hidden. Each month shows only its overall available time."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Outside calendar details remain hidden. Each month shows only its overall available time."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Year object/date control. The announcement includes this user-facing evidence before focus moves: Outside calendar details remain hidden. Each month shows only its overall available time."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-EXTERNAL-HIDDEN-CAPACITY-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Year range and selected stable object or date identity are current"]
destination = "the selected month in Time Month. The handoff starts from Time Year explicit state contract / External Hidden Capacity"
destination_id = "DEST-TIME-YEAR-EXTERNAL-HIDDEN-CAPACITY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Year explicit state contract / External Hidden Capacity reports the outcome from this visible condition: Outside calendar details remain hidden. Each month shows only its overall available time"
success_focus = "the selected object heading or selected date heading within Time Year explicit state contract / External Hidden Capacity"
success_focus_id = "FOCUS-TIME-YEAR-EXTERNAL-HIDDEN-CAPACITY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Year object/date control while Time Year explicit state contract / External Hidden Capacity remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-EXTERNAL-HIDDEN-CAPACITY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-EXTERNAL-HIDDEN-CAPACITY-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-YEAR-IMPORTING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained Time Year range and pending import summary. The handoff starts from Time Year explicit state contract / Importing; effect: No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt; Time Year explicit state contract / Importing reports the outcome from this visible condition: Import progress is grouped by month. Individual imported Event details remain hidden; this command preserves accepted product state; focus: the initiating Year import control or date heading within Time Year explicit state contract / Importing."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt. The durable boundary is specific to this visible evidence: Import progress is grouped by month. Individual imported Event details remain hidden."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Import progress is grouped by month. Individual imported Event details remain hidden."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Import progress is grouped by month. Individual imported Event details remain hidden."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating Year import control or date heading; rejection focuses the import progress status and Cancel control. The announcement includes this user-facing evidence before focus moves: Import progress is grouped by month. Individual imported Event details remain hidden."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-IMPORTING-001"
label = "Cancel"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Any accepted import and Receipt are identified separately", "Only pending import comparison or optional loading remains uncommitted"]
destination = "the retained Time Year range and pending import summary. The handoff starts from Time Year explicit state contract / Importing"
destination_id = "DEST-TIME-YEAR-IMPORTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; pending import review stops without discarding the diff; an accepted import is not cancelled and remains visible in History and its Receipt; Time Year explicit state contract / Importing reports the outcome from this visible condition: Import progress is grouped by month. Individual imported Event details remain hidden; this command preserves accepted product state"
success_focus = "the initiating Year import control or date heading within Time Year explicit state contract / Importing"
success_focus_id = "FOCUS-TIME-YEAR-IMPORTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the import progress status and Cancel control while Time Year explicit state contract / Importing remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-IMPORTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-IMPORTING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-YEAR-NOW-ANCHORED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Today => destination: the current local date in Time Year. The handoff starts from Time Year explicit state contract / Now Anchored; effect: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Year explicit state contract / Now Anchored reports the outcome from this visible condition: The current year and month are marked without showing a day-level Now line; focus: the current-period date heading within Time Year explicit state contract / Now Anchored."
durable_effect = "Exact command consequences: Today: No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts. The durable boundary is specific to this visible evidence: The current year and month are marked without showing a day-level Now line."
recovery_rollback = "Exact rollback and recovery: Today: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The current year and month are marked without showing a day-level Now line."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The current year and month are marked without showing a day-level Now line."
accessibility_focus = "VoiceOver focus contract: Today announces its consequence, then success focuses the current-period date heading; rejection focuses the Today control and retained prior range. The announcement includes this user-facing evidence before focus moves: The current year and month are marked without showing a day-level Now line."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-NOW-ANCHORED-001"
label = "Today"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The preferred Year view and current local date are available"]
destination = "the current local date in Time Year. The handoff starts from Time Year explicit state contract / Now Anchored"
destination_id = "DEST-TIME-YEAR-NOW-ANCHORED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the intentional range moves to the current period without changing the preferred view, objects, placements, or Receipts; Time Year explicit state contract / Now Anchored reports the outcome from this visible condition: The current year and month are marked without showing a day-level Now line"
success_focus = "the current-period date heading within Time Year explicit state contract / Now Anchored"
success_focus_id = "FOCUS-TIME-YEAR-NOW-ANCHORED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Today control and retained prior range while Time Year explicit state contract / Now Anchored remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-NOW-ANCHORED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-NOW-ANCHORED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-YEAR-POPULATED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: the selected month in Time Month. The handoff starts from Time Year explicit state contract / Populated; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Year explicit state contract / Populated reports the outcome from this visible condition: Month summaries show the year’s rhythm without showing individual Events; focus: the selected object heading or selected date heading within Time Year explicit state contract / Populated."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: Month summaries show the year’s rhythm without showing individual Events."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Month summaries show the year’s rhythm without showing individual Events."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Month summaries show the year’s rhythm without showing individual Events."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Year object/date control. The announcement includes this user-facing evidence before focus moves: Month summaries show the year’s rhythm without showing individual Events."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-POPULATED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Year range and selected stable object or date identity are current"]
destination = "the selected month in Time Month. The handoff starts from Time Year explicit state contract / Populated"
destination_id = "DEST-TIME-YEAR-POPULATED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Year explicit state contract / Populated reports the outcome from this visible condition: Month summaries show the year’s rhythm without showing individual Events"
success_focus = "the selected object heading or selected date heading within Time Year explicit state contract / Populated"
success_focus_id = "FOCUS-TIME-YEAR-POPULATED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Year object/date control while Time Year explicit state contract / Populated remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-POPULATED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-POPULATED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-YEAR-PREVIEWING"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Keep current => destination: the unchanged Time Year object and current placement. The handoff starts from Time Year explicit state contract / Previewing; effect: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Year explicit state contract / Previewing reports the outcome from this visible condition: Proposed time changes are grouped by month. Individual consequences remain hidden; this command preserves accepted product state; focus: the unchanged object and placement status within Time Year explicit state contract / Previewing.\nMove => destination: the object-scoped placement preview. The handoff starts from Time Year explicit state contract / Previewing; effect: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Year explicit state contract / Previewing reports the outcome from this visible condition: Proposed time changes are grouped by month. Individual consequences remain hidden; focus: the affected object and proposed placement consequence within Time Year explicit state contract / Previewing."
durable_effect = "Exact command consequences: Keep current: No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged | Move: No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation. The durable boundary is specific to this visible evidence: Proposed time changes are grouped by month. Individual consequences remain hidden."
recovery_rollback = "Exact rollback and recovery: Keep current: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Move: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Proposed time changes are grouped by month. Individual consequences remain hidden."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: Proposed time changes are grouped by month. Individual consequences remain hidden."
accessibility_focus = "VoiceOver focus contract: Keep current announces its consequence, then success focuses the unchanged object and placement status; rejection focuses the Keep current control | Move announces its consequence, then success focuses the affected object and proposed placement consequence; rejection focuses the Move control and exact invalid field or boundary. The announcement includes this user-facing evidence before focus moves: Proposed time changes are grouped by month. Individual consequences remain hidden."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-PREVIEWING-001"
label = "Keep current"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["A placement or conflict proposal is open and the current placement revision remains valid"]
destination = "the unchanged Time Year object and current placement. The handoff starts from Time Year explicit state contract / Previewing"
destination_id = "DEST-TIME-YEAR-PREVIEWING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposal is rejected and the current placement, schedule, Proof, and History remain unchanged; Time Year explicit state contract / Previewing reports the outcome from this visible condition: Proposed time changes are grouped by month. Individual consequences remain hidden; this command preserves accepted product state"
success_focus = "the unchanged object and placement status within Time Year explicit state contract / Previewing"
success_focus_id = "FOCUS-TIME-YEAR-PREVIEWING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep current control while Time Year explicit state contract / Previewing remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-PREVIEWING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-PREVIEWING-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-PREVIEWING-002"
label = "Move"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["Protected, Fixed, recurrence, and external authority are known", "The canonical object identity, schedule placement ID, current revision, and return anchor exist"]
destination = "the object-scoped placement preview. The handoff starts from Time Year explicit state contract / Previewing"
destination_id = "DEST-TIME-YEAR-PREVIEWING-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a proposed destination placement is previewed with schedule and Proof consequences; no drag release or named action commits before explicit confirmation; Time Year explicit state contract / Previewing reports the outcome from this visible condition: Proposed time changes are grouped by month. Individual consequences remain hidden"
success_focus = "the affected object and proposed placement consequence within Time Year explicit state contract / Previewing"
success_focus_id = "FOCUS-TIME-YEAR-PREVIEWING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Move control and exact invalid field or boundary while Time Year explicit state contract / Previewing remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-PREVIEWING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-PREVIEWING-002"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-YEAR-RESTORED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: the selected month in Time Month. The handoff starts from Time Year explicit state contract / Restored; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Year explicit state contract / Restored reports the outcome from this visible condition: The saved year and month are visible again. No Event detail is open; focus: the selected object heading or selected date heading within Time Year explicit state contract / Restored."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: The saved year and month are visible again. No Event detail is open."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The saved year and month are visible again. No Event detail is open."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: The saved year and month are visible again. No Event detail is open."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Year object/date control. The announcement includes this user-facing evidence before focus moves: The saved year and month are visible again. No Event detail is open."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-RESTORED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Year range and selected stable object or date identity are current"]
destination = "the selected month in Time Month. The handoff starts from Time Year explicit state contract / Restored"
destination_id = "DEST-TIME-YEAR-RESTORED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Year explicit state contract / Restored reports the outcome from this visible condition: The saved year and month are visible again. No Event detail is open"
success_focus = "the selected object heading or selected date heading within Time Year explicit state contract / Restored"
success_focus_id = "FOCUS-TIME-YEAR-RESTORED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Year object/date control while Time Year explicit state contract / Restored remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-RESTORED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-RESTORED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-YEAR-SELECTED"
requirement_id = "SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Select => destination: the selected month in Time Month. The handoff starts from Time Year explicit state contract / Selected; effect: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Year explicit state contract / Selected reports the outcome from this visible condition: One month is selected. Individual Event editing remains unavailable; focus: the selected object heading or selected date heading within Time Year explicit state contract / Selected."
durable_effect = "Exact command consequences: Select: No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created. The durable boundary is specific to this visible evidence: One month is selected. Individual Event editing remains unavailable."
recovery_rollback = "Exact rollback and recovery: Select: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: One month is selected. Individual Event editing remains unavailable."
offline_behavior = "Time views, selection, range navigation, placement previews, and conflict review use local canonical state without an account or network; external results remain separate. Offline rendering retains this state evidence: One month is selected. Individual Event editing remains unavailable."
accessibility_focus = "VoiceOver focus contract: Select announces its consequence, then success focuses the selected object heading or selected date heading; rejection focuses the initiating Year object/date control. The announcement includes this user-facing evidence before focus moves: One month is selected. Individual Event editing remains unavailable."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-YEAR-SELECTED-001"
label = "Select"
canonical_owner = "surface.time.view-command-contract"
preconditions = ["The Year range and selected stable object or date identity are current"]
destination = "the selected month in Time Month. The handoff starts from Time Year explicit state contract / Selected"
destination_id = "DEST-TIME-YEAR-SELECTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; ephemeral selection is retained only while the object remains in range; no durable mutation occurs and no Receipt is created; Time Year explicit state contract / Selected reports the outcome from this visible condition: One month is selected. Individual Event editing remains unavailable"
success_focus = "the selected object heading or selected date heading within Time Year explicit state contract / Selected"
success_focus_id = "FOCUS-TIME-YEAR-SELECTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Year object/date control while Time Year explicit state contract / Selected remains visible"
failure_focus_id = "FOCUS-TIME-YEAR-SELECTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-TIME-YEAR-SELECTED-001"
recovery_posture = "current"
recovery_owner = "surface.time.view-command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001"]
+++

# Time

This specification defines Time as the intended first-class temporal operating surface.

## SPEC-SURFACE-TIME-PRIMARY-IDENTITY-001 — First-class Life Calendar target

- **Concept:** `surface.time.primary-identity`
- **Modality:** `MUST`
- **Scope:** Time root and temporal depth
- **Status:** `normative`
- **Verification:** `PROOF-CALENDAR-GRADE-001`
- **Supersedes:** none

Time MUST target first-class replacement of ordinary personal calendar planning while expressing Protected, Fixed, Flexible, and Suggested time, capacity, conflict, and adjustment. It is neither an anti-calendar nor a calendar clone.

Time MUST provide first-class native calendar behavior and a complete temporal operating surface.

Time MUST provide continuous temporal zoom and a practical scheduled-reflow review mode.

Time MUST preserve native calendar comprehension while adding Ambitions scheduling, capacity, reflow, and recovery semantics.

Time MUST distinguish Protected, Fixed, flexible, capacity, and reflow states while preserving native calendar comprehension.

## SPEC-SURFACE-TIME-VIEWS-001 — Calendar-grade view family

- **Concept:** `surface.time.views`
- **Modality:** `MUST`
- **Scope:** Day, Week, Month, Year, and List
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-VIEWS-001`, `A11Y-TIME-LIST-PARITY-001`
- **Supersedes:** none

Time view-family behavior MUST be owned by the separate switching, Day, Week, Month, Year, List, Today-control, and reduced-effects contracts and MUST preserve their independent verification boundaries.

## SPEC-SURFACE-TIME-DAY-001 — Direct, inspectable day planning

- **Concept:** `surface.time.day`
- **Modality:** `MUST`
- **Scope:** Day view and temporal object manipulation
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-DAY-001`, `A11Y-TIME-EDIT-ACTIONS-001`
- **Supersedes:** none

Day MUST show the current-time marker, all-day rail, Events, Steps, Reminders, time-authority semantics, Goal context, and relevant proof or adjustment markers. Drag and resize MUST have explicit Move, Change start, Change duration, and typed edit alternatives with the same conflict preview, consequence summary, confirmation, focus return, and receipt.

Events MUST use time-range blocks.

When the user taps an object in Time, Ambitions MUST open a compact native detail sheet with title, time, calendar/source, notes, recurrence, alerts, schedule state, goal link, proof/reflow markers, and edit actions.

## SPEC-SURFACE-TIME-FIRST-VIEWPORT-001 — Temporal reality before controls

- **Concept:** `surface.time.first-viewport`
- **Modality:** `MUST`
- **Scope:** Time first visible and semantic viewport
- **Status:** `normative`
- **Verification:** `PROOF-TIME-FIRST-VIEWPORT-001`
- **Supersedes:** none

The first viewport MUST foreground the selected range, Now or Today anchor, protected and fixed reality, flexible capacity, visible conflicts, and the next meaningful temporal object. View switching, search/filter, external-diff review, and creation remain discoverable but subordinate to temporal reality.

Ambitions Time semantics MUST alter weight, material, edge treatment, and line treatment without reducing basic calendar comprehensibility.

## SPEC-SURFACE-TIME-PURPOSE-001 — Fit, consequence, and user authority

- **Concept:** `surface.time.purpose`
- **Modality:** `MUST`
- **Scope:** Placement, creation, conflict, adjustment, and import review
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-FIT-001`
- **Supersedes:** none

Time MUST answer how time is arranged, what is protected or fixed, what can move, and what happens when reality changes. It previews conflict, recurrence, deadline, external-write, and adjustment consequences before material commit. External visibility and capacity reservation remain separate; an unreviewed external candidate never appears as an Ambitions Event.

Time MUST own schedule reality, capacity, conflicts, and planning changes.

Apple Calendar bridge, routing, and external-diff failures MUST affect only their related controls and MUST NOT block Ambitions-native calendar use.

## SPEC-SURFACE-TIME-VISUAL-AUTHORITY-001 — Approved Time package, separate implementation proof

- **Concept:** `surface.time.visual-authority`
- **Modality:** `MUST`
- **Scope:** Time grid, list, and direct-manipulation visual authority
- **Status:** `normative`
- **Verification:** `PROOF-TIME-VISUAL-MAPPING-001`
- **Supersedes:** none

Visual references MUST use stable external IDs and keep the selected package direction distinct from current implementation behavior. Selected VSP-04 package `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:202:93` is the Time visual target. Candidate naming does not change the selected product direction. The package does not demonstrate current calendar parity, direct-manipulation, SwiftUI, accessibility, device, or runtime behavior.

## SPEC-SURFACE-TIME-TODAY-CONTROL-001 — Return to current temporal context
- **Concept:** `surface.time.today-control`
- **Modality:** `MUST`
- **Scope:** Day, Week, Month, Year, and List navigation away from now
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-TODAY-CONTROL-001`
- **Supersedes:** none

Time MUST expose a Today control when the selected range is away from the current context. It returns Day or List to today, Week to the current week, Month toward the current day, and Year toward the current month without discarding the user's preferred view.

Time MUST show the Now marker in Day and Week and MUST provide a current-period return control in Month, Year, and List.

## SPEC-SURFACE-TIME-CREATION-ROUTES-001 — Creation begins in temporal context
- **Concept:** `surface.time.creation-routes`
- **Modality:** `SHOULD`
- **Scope:** Top action and direct creation from a Time position
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-CREATION-ROUTES-001`
- **Supersedes:** none

Time SHOULD provide a top creation action biased to Event, Reminder, or Step and a direct time-position creation path where native interaction permits. Both routes preserve the selected temporal context and enter the canonical Capture proposal flow rather than committing from the view.

Time MUST have top-right create that opens Capture biased to Event/Reminder/Step.

Time creation MUST use a compact native sheet and MUST route through the same object model as Capture.

When the user taps an empty Time slot, the creation sheet defaults to Event because Time MUST be calendar-native.

## SPEC-SURFACE-TIME-STEP-MEMBERSHIP-001 — Only accepted placements are scheduled work
- **Concept:** `surface.time.step-membership`
- **Modality:** `MUST`
- **Scope:** Goal-linked Steps in Time
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-STEP-MEMBERSHIP-001`
- **Supersedes:** none

Time MUST present scheduled Goal Steps as placed temporal objects. An unscheduled Step may appear only as a clearly non-durable fit or reflow proposal until the user accepts a placement; proposal visibility never implies schedule commitment.

Goal-related scheduled items MUST appear in Goals.

Unscheduled goal steps MUST NOT appear as placed work unless accepted.

## SPEC-SURFACE-TIME-VISUAL-GEOMETRY-001 — Time visual geometry

- **Concept:** `surface.time.visual-geometry`
- **Modality:** `MUST`
- **Scope:** Time grids and temporal objects
- **Status:** `normative`
- **Verification:** `REVIEW-TIME-VISUAL-GEOMETRY-001`
- **Supersedes:** none

Time visual geometry MUST preserve calendar comprehension while distinguishing temporal authority, capacity, conflict, reflow, Proof, and Goal context.

## SPEC-SURFACE-TIME-IMPORTED-SOURCE-001 — Imported source distinction

- **Concept:** `surface.time.imported-source`
- **Modality:** `MUST`
- **Scope:** Imported temporal records
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-IMPORTED-SOURCE-001`
- **Supersedes:** none

Time MUST distinguish external source facts, local candidates, accepted Ambitions Events, and pending outbound changes.

## SPEC-SURFACE-TIME-SEARCH-001 — Time search

- **Concept:** `surface.time.search`
- **Modality:** `MUST`
- **Scope:** Temporal search
- **Status:** `normative`
- **Verification:** `TEST-TIME-SEARCH-001`
- **Supersedes:** none

Time search MUST be local and object-first and MUST preserve selected temporal context when opening a result.

## SPEC-SURFACE-TIME-VIEW-SWITCHING-001 — Time view switching

- **Concept:** `surface.time.view-switching`
- **Modality:** `MUST`
- **Scope:** Day, Week, Month, Year, and List navigation
- **Status:** `normative`
- **Verification:** `A11Y-TIME-VIEW-SWITCHING-001`
- **Supersedes:** none

Time MUST expose visible, discoverable, accessible Day, Week, Month, Year, and List switching, remember the last-used view, preserve intentional range context, and keep gestures optional accelerators.

## SPEC-SURFACE-TIME-WEEK-001 — Week view

- **Concept:** `surface.time.week`
- **Modality:** `MUST`
- **Scope:** Time Week view
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-WEEK-001`
- **Supersedes:** none

Week MUST remain familiar and scannable while showing protected, fixed, flexible, suggested, Goal-linked, conflict, recovery, capacity, reflow, and Proof semantics.

## SPEC-SURFACE-TIME-MONTH-001 — Month view

- **Concept:** `surface.time.month`
- **Modality:** `MUST`
- **Scope:** Time Month view
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-MONTH-001`
- **Supersedes:** none

Month MUST remain a scannable calendar grid with semantic summaries for density, protected time, Goal movement, recovery, Proof, conflicts, and scheduled Steps without illegible object density.

## SPEC-SURFACE-TIME-YEAR-001 — Year view

- **Concept:** `surface.time.year`
- **Modality:** `MUST`
- **Scope:** Time Year view
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-YEAR-001`
- **Supersedes:** none

Year MUST remain a high-level navigational overview of monthly density, protected seasons, Goal movement, recovery, Proof, and conflict pressure, revealing granular objects only after drilldown.

## SPEC-SURFACE-TIME-LIST-001 — List view

- **Concept:** `surface.time.list`
- **Modality:** `MUST`
- **Scope:** Time chronological list
- **Status:** `normative`
- **Verification:** `A11Y-TIME-LIST-001`
- **Supersedes:** none

List MUST be the chronological, semantic, screen-reader-friendly counterpart to grids and preserve temporal authority, Goal context, due, recovery, Proof, conflict, and reflow markers.

## SPEC-SURFACE-TIME-OBJECT-DETAIL-001 — Time object detail

- **Concept:** `surface.time.object-detail`
- **Modality:** `MUST`
- **Scope:** Temporal object detail
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-OBJECT-DETAIL-001`
- **Supersedes:** none

Selecting a Time object MUST open compact native detail with identity, time, source, notes, recurrence, alerts, schedule state, Goal link, Proof or reflow markers, and canonical edit actions.

## SPEC-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001 — Exact state command ownership

- **Concept:** `surface.time.view-command-contract`
- **Modality:** `MUST`
- **Scope:** Structured state command contracts for this specification
- **Status:** `normative`
- **Verification:** `SCENARIO-SURFACE-TIME-VIEW-COMMAND-CONTRACT-001`
- **Supersedes:** none

The owning specification MUST authorize only the state-bound command labels `Adjust plan`, `Cancel`, `Change duration`, `Change start`, `Edit`, `Keep current`, `Move`, `Resolve conflict`, `Select`, `Today` for the structured states declared in this file. Every command MUST bind stable state and object identity, current revision, canonical owner, preconditions, destination, exact effect and focus targets; navigation, inspection, selection, preview, refresh, and cancellation remain non-mutating. A durable mutation MUST commit only after current-revision validation and required confirmation through Command -> Event -> Projection -> Receipt -> Replay; cancellation or rejection preserves accepted input, and rollback or Undo uses an owning typed command without rewriting history. Local canonical behavior MUST remain available offline without an account; external results remain separate and retryable without replaying the local commit. Sensitive content MUST remain local unless explicit minimum-field egress review passes. VoiceOver MUST announce object, accepted or rejected outcome, consequence, recovery or Undo availability, and destination focus; no color, motion, gesture, or position may carry command meaning alone. Verification MUST prove every declared state, command, transition, commit boundary, durable effect, rollback, offline, privacy, accessibility, and focus mapping against the structured contract.

## SPEC-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001 — Exact state command ownership

- **Concept:** `surface.time.degraded-command-contract`
- **Modality:** `MUST`
- **Scope:** Structured state command contracts for this specification
- **Status:** `normative`
- **Verification:** `SCENARIO-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001`
- **Supersedes:** none

The owning specification MUST authorize only the state-bound command labels `Open Settings`, `Open diagnostics`, `Refresh source`, `Retry external update`, `Retry failed items`, `Retry local store`, `Review calendar access`, `Review changes`, `Review conflict`, `Review continuity status`, `Review details`, `Review partial import`, `Review source` for the structured states declared in this file. Every command MUST bind stable state and object identity, current revision, canonical owner, preconditions, destination, exact effect and focus targets; navigation, inspection, selection, preview, refresh, and cancellation remain non-mutating. A durable mutation MUST commit only after current-revision validation and required confirmation through Command -> Event -> Projection -> Receipt -> Replay; cancellation or rejection preserves accepted input, and rollback or Undo uses an owning typed command without rewriting history. Local canonical behavior MUST remain available offline without an account; external results remain separate and retryable without replaying the local commit. Sensitive content MUST remain local unless explicit minimum-field egress review passes. VoiceOver MUST announce object, accepted or rejected outcome, consequence, recovery or Undo availability, and destination focus; no color, motion, gesture, or position may carry command meaning alone. Verification MUST prove every declared state, command, transition, commit boundary, durable effect, rollback, offline, privacy, accessibility, and focus mapping against the structured contract.

## SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001 — Time detail commands preserve object and source ownership

- **Concept:** `surface.time.detail-command-contract`
- **Modality:** `MUST`
- **Scope:** Time object detail, edit, recurrence scope, Trash, restore, permanent deletion, source handoff, external failure, focus, offline use, and rollback
- **Status:** `normative`
- **Verification:** `SCENARIO-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001`
- **Supersedes:** none

Time object detail MUST distinguish Ambitions-owned Event, Reminder, Step placement, external candidate, linked external source, and recurrence ownership before enabling commands.

Allowed commands are `Edit`, `Save`, `Cancel`, `Move to Trash`, `Restore`, and—only from Trash—`Delete Permanently`. Recurring edit, move, Trash, or restore MUST first choose `This Occurrence`, `This and Following`, or `Entire Series`, with affected objects and schedule consequences previewed.

External candidates remain source-owned and route to the import review. They cannot be edited as native Events. Linked/external-owned records route to source inspection or the existing `Import into Ambitions`, `Link`, or `Keep external but reserve time` choices. `Open in Calendar` is an explicit external handoff. No local command silently changes the external source.

Save requires stable identity, current revision, valid fields, ownership, permission, and recurrence scope. Invalid edits keep the draft, commit nothing, and focus the first invalid field. Local commit precedes optional external write; external failure preserves local truth and routes to Time degraded reconciliation.

`Move to Trash` is recoverable and creates History/Receipt. Restore revalidates recurrence, placement, capacity, and notification consequences. Permanent deletion is a separate exact-scope confirmation.

## Completeness contract

<!-- canon-section: purpose-user-question -->
Time answers where commitments and Steps live, what capacity remains, what can move, and the inspectable consequences of making reality fit.

<!-- canon-section: entry-exit -->
Entry is root selection, Today/Goal handoff, Search, Capture placement, restoration, deep link, or external-diff review. Exit preserves range, view, selection, scroll anchor, edit draft, and focus through native back or root/overlay handoff.

<!-- canon-section: routes-presentation -->
Day, Week, Month, Year, and List live under the Time root. Object detail is compact where sufficient; complex recurrence, grouped adjustment, import review, and export use focused native review. No view becomes a root.

<!-- canon-section: displayed-objects -->
Canonical identity connects each temporal object to its owning record and receipt chain.
Time projects canonical Events, Steps, Reminders, Future Steps, all-day/multi-day spans, placements, protected blocks, conflicts, recovery windows, proof markers, and reviewed provenance. Unreviewed candidates remain review records, not native Events.

<!-- canon-section: resting-states -->
Required states include each view at empty, populated, dense, selected, editing, previewing, conflicting, importing, restored, and today/now anchored conditions, plus external-hidden-capacity-reserved state.

<!-- canon-section: loading-transitional -->
Range load, recurrence expansion, view switch, drag/resize preview, conflict simulation, import scan, commit, external reconciliation, undo, and restoration keep last valid local content until deterministic replacement is ready.

<!-- canon-section: empty-degraded -->
Time distinguishes genuinely empty, permission denied, stale source, pending external diff, partial import, external-write failure, sync pending/conflict, offline healthy, and local-store degradation. Ambitions-owned Time remains usable; failures preserve drafts and accepted local intent.

<!-- canon-section: commands-actions -->
Create Event/Step/Reminder, select, edit, move, resize, schedule, reschedule, change authority/rule, scope recurrence, delete/Trash/restore, import/link/reserve/ignore/reject, export, review conflict, and undo all route through canonical commands. Every spatial action has named controls and List access.

<!-- canon-section: durable-effects -->
Accepted creation, placement, recurrence, import, adjustment, deletion, restore, notification, export, and external write produce canonical events, projections, receipts, replay state, and outbox/reconciliation state where external effects apply.

<!-- canon-section: failure-rollback -->
Invalid placement does not commit. Partial external failure keeps local commit and durable result state. Recurrence and grouped changes retain scope preview and rollback context. Retry is idempotent; undo restores the prior valid placement without erasing receipt history.

<!-- canon-section: offline -->
All Ambitions-owned views, objects, placement, conflict preview, local search/filter, edit, receipts, and replay work without account or network. Optional source unavailability does not hide or corrupt local calendar reality.

<!-- canon-section: privacy-data-classification -->
Calendar contents, attendees, location, schedule assumptions, capacity, Goal links, proof, and history are private local data. Import/export and external writes use minimum payload, contextual consent, redaction, preview, receipt, and recovery. R2 and Account never receive private temporal context.

<!-- canon-section: accessibility-reading-order -->
Each grid exposes ordered date/time headings, object labels/values/actions, conflict and preview summaries, and jump controls. List supplies full range navigation and action parity. Month/Year provide verbal summaries; drag/resize has explicit alternatives; focus returns to the changed object.

<!-- canon-section: dynamic-type -->
At larger sizes controls and object detail reflow, grids retain meaningful minimum geometry, and List becomes the complete alternative without losing recurrence, time authority, conflict, provenance, or action capability.

<!-- canon-section: reduce-motion -->
Drag ghosts, range transitions, adjustment previews, and object moves become static outlines, verbal summaries, or immediate updates while keeping consequence, focus, and receipt semantics.

<!-- canon-section: reduce-transparency -->
Grid layers, overlays, and materials become opaque semantic surfaces with equivalent boundaries, current-time visibility, conflict distinction, selection, and contrast.

<!-- canon-section: copy-state-language -->
Use Event, Step, Reminder, Protected, Fixed, Flexible, Suggested, Move it, Review, and Undo. Translate internal reflow language into Adjust plan, Make this fit, or Resolve conflict. Avoid parity, readiness, shame, density scoring, or runtime vocabulary.

<!-- canon-section: visual-authority -->
The named package controls geometry, hierarchy, composition, states, and adaptive layout.
Stable package ID `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:202:93` supplies approved Time design authority. Calendar behavior, source rendering, accessibility/device evidence, implementation parity, replacement readiness, and release proof remain separate.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Surfaces/Time/` owns presentation; `Core/Time/` owns temporal primitives; `Core/LocalRuntimeOS/Scheduling/`, `ExternalWrites/`, `Continuity/`, and `Inspection/` own behavior and facts; `Quality/` owns proof.

<!-- canon-section: tests -->
Tests cover five views, recurrence/exceptions, time zones/DST, all-day/multi-day, authority/rules, drag and named alternatives, conflict/adjustment, creation/edit/delete/restore, import outcomes, external failures, search/filter/export, notifications, offline/replay, scale, VoiceOver/List parity, Dynamic Type, reduced effects, contrast, and focus.

<!-- canon-section: proof -->
Calendar replacement claims require current calendar-grade scenario, migration, receipt/replay, device performance, screenshot/video, semantic parity, accessibility, privacy, failure/recovery, and owner-accepted visual evidence. This spec and a successful compiler build provide none of that readiness proof.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Time range loading, recurrence expansion, scrolling, direct manipulation, named-edit preview, and List search MUST remain bounded and cancellable, perform no interaction-path network gating or synchronous disk I/O, use no polling or unbounded background loop, and preserve foreground responsiveness under Low Power Mode, thermal pressure, protected-data unavailability, and storage pressure. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. The implementation must define and test a performance-budget record declaring device floor, OS, build configuration, representative temporal/recurrence data scale, warm/cold state, measurement tool, percentile/maximum, frame/scroll metric, and regression threshold.

## SPEC-SURFACE-TIME-CEBR-FIT-001 — Time shows fit consequences

- **Concept:** `surface.time.cebr-fit`
- **Modality:** `MUST`
- **Scope:** Branch placement, capacity, protected boundaries, and conflict review
- **Status:** `normative`
- **Verification:** `SCENARIO-SURFACE-TIME-CEBR-FIT-001`
- **Supersedes:** none

Time MAY present branch placement and capacity consequences in the existing
reflow/conflict review. It MUST retain canonical placement identity, recurrence
scope, protected/fixed boundaries, and named alternatives; a candidate preview
is non-durable and cannot mutate the calendar grid without the owning command,
confirmation, and local receipt sequence.
