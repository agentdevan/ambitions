+++
spec_id = "SURFACE-GOALS"
title = "Goals"
kind = "surface"
status = "normative"
owner_domain = "surface-goals"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "surface.goal-detail.viewport",
  "surface.goals.anti-patterns",
  "surface.goals.closure",
  "surface.goals.command-contract",
  "surface.goals.cebr-branch",
  "surface.goals.detail",
  "surface.goals.execution-stack",
  "surface.goals.first-viewport",
  "surface.goals.identity",
  "surface.goals.path-interaction",
  "surface.goals.path-visual",
  "surface.goals.purpose",
  "surface.goals.reviews",
  "surface.goals.root-viewport",
  "surface.goals.screen-inventory",
  "surface.goals.visual-authority",
]
inherits = [
  "CONST-IA-ROOT-001",
  "OBJECT-CANONICAL-GRAPH-001",
  "OBJECT-GOAL-LIFECYCLE-001",
  "CONTROL-MATERIAL-CONFIRMATION-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION"]
source_owners = [
  "Native/Ambitions/Surfaces/Goals/",
  "Native/Ambitions/Core/Domain/",
  "Native/Ambitions/Core/LocalRuntimeOS/Planning/",
  "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/",
  "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/",
  "Native/Ambitions/Core/LocalRuntimeOS/Inspection/",
  "Native/Ambitions/Quality/",
]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-CLOSURE-COMPLETED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal closure explicit state contract / Completed; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal closure explicit state contract / Completed reports the outcome from this visible condition: The Goal outcome is complete, with its final Proof and receipt available; focus: the Goal identity and lifecycle status within Goal closure explicit state contract / Completed."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: The Goal outcome is complete, with its final Proof and receipt available."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The Goal outcome is complete, with its final Proof and receipt available."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: The Goal outcome is complete, with its final Proof and receipt available."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: The Goal outcome is complete, with its final Proof and receipt available."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-CLOSURE-COMPLETED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal closure explicit state contract / Completed"
destination_id = "DEST-GOALS-CLOSURE-COMPLETED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal closure explicit state contract / Completed reports the outcome from this visible condition: The Goal outcome is complete, with its final Proof and receipt available"
success_focus = "the Goal identity and lifecycle status within Goal closure explicit state contract / Completed"
success_focus_id = "FOCUS-GOALS-CLOSURE-COMPLETED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal closure explicit state contract / Completed remains visible"
failure_focus_id = "FOCUS-GOALS-CLOSURE-COMPLETED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-CLOSURE-COMPLETED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-CLOSURE-ENDED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal closure explicit state contract / Ended; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal closure explicit state contract / Ended reports the outcome from this visible condition: The Goal has ended without a completion claim; its reason and history remain visible; focus: the Goal identity and lifecycle status within Goal closure explicit state contract / Ended."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: The Goal has ended without a completion claim; its reason and history remain visible."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The Goal has ended without a completion claim; its reason and history remain visible."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: The Goal has ended without a completion claim; its reason and history remain visible."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: The Goal has ended without a completion claim; its reason and history remain visible."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-CLOSURE-ENDED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal closure explicit state contract / Ended"
destination_id = "DEST-GOALS-CLOSURE-ENDED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal closure explicit state contract / Ended reports the outcome from this visible condition: The Goal has ended without a completion claim; its reason and history remain visible"
success_focus = "the Goal identity and lifecycle status within Goal closure explicit state contract / Ended"
success_focus_id = "FOCUS-GOALS-CLOSURE-ENDED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal closure explicit state contract / Ended remains visible"
failure_focus_id = "FOCUS-GOALS-CLOSURE-ENDED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-CLOSURE-ENDED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-CLOSURE-NEEDS-ATTENTION"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the object-scoped Goal recovery review. The handoff starts from Goal closure explicit state contract / Needs Attention; effect: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal closure explicit state contract / Needs Attention reports the outcome from this visible condition: The outcome, remaining work, or Proof is unresolved. The Goal remains unchanged; focus: the Goal status and first valid repair action within Goal closure explicit state contract / Needs Attention."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs. The durable boundary is specific to this visible evidence: The outcome, remaining work, or Proof is unresolved. The Goal remains unchanged."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The outcome, remaining work, or Proof is unresolved. The Goal remains unchanged."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: The outcome, remaining work, or Proof is unresolved. The Goal remains unchanged."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the Goal status and first valid repair action; rejection focuses the Review recovery control and failure reason. The announcement includes this user-facing evidence before focus moves: The outcome, remaining work, or Proof is unresolved. The Goal remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-CLOSURE-NEEDS-ATTENTION-001"
label = "Review recovery"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The Goal identity, retained Goal/path revision, and failure class are available"]
destination = "the object-scoped Goal recovery review. The handoff starts from Goal closure explicit state contract / Needs Attention"
destination_id = "DEST-GOALS-CLOSURE-NEEDS-ATTENTION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal closure explicit state contract / Needs Attention reports the outcome from this visible condition: The outcome, remaining work, or Proof is unresolved. The Goal remains unchanged"
success_focus = "the Goal status and first valid repair action within Goal closure explicit state contract / Needs Attention"
success_focus_id = "FOCUS-GOALS-CLOSURE-NEEDS-ATTENTION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review recovery control and failure reason while Goal closure explicit state contract / Needs Attention remains visible"
failure_focus_id = "FOCUS-GOALS-CLOSURE-NEEDS-ATTENTION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-CLOSURE-NEEDS-ATTENTION-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-ACTIVATING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review activation => destination: the revision-bound Goal activation review. The handoff starts from Goal detail explicit state contract / Activating; effect: No durable mutation occurs and no Receipt is created; the Life Area, initial path, next Step, proof rule, schedule consequences, automation level, and unresolved assumptions are shown; Activate Goal remains a separate confirmed mutation; Goal detail explicit state contract / Activating reports the outcome from this visible condition: Goal activation is in progress. The saved draft remains visible; focus: the activation review heading and first unresolved assumption within Goal detail explicit state contract / Activating."
durable_effect = "Exact command consequences: Review activation: No durable mutation occurs and no Receipt is created; the Life Area, initial path, next Step, proof rule, schedule consequences, automation level, and unresolved assumptions are shown; Activate Goal remains a separate confirmed mutation. The durable boundary is specific to this visible evidence: Goal activation is in progress. The saved draft remains visible."
recovery_rollback = "Exact rollback and recovery: Review activation: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Goal activation is in progress. The saved draft remains visible."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: Goal activation is in progress. The saved draft remains visible."
accessibility_focus = "VoiceOver focus contract: Review activation announces its consequence, then success focuses the activation review heading and first unresolved assumption; rejection focuses the Review activation control and retained Goal status. The announcement includes this user-facing evidence before focus moves: Goal activation is in progress. The saved draft remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-ACTIVATING-001"
label = "Review activation"
canonical_owner = "surface.goals.command-contract"
preconditions = ["Clarification is sufficient for an activation preview", "The Goal identity and current reviewed revision exist"]
destination = "the revision-bound Goal activation review. The handoff starts from Goal detail explicit state contract / Activating"
destination_id = "DEST-GOALS-DETAIL-ACTIVATING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Life Area, initial path, next Step, proof rule, schedule consequences, automation level, and unresolved assumptions are shown; Activate Goal remains a separate confirmed mutation; Goal detail explicit state contract / Activating reports the outcome from this visible condition: Goal activation is in progress. The saved draft remains visible"
success_focus = "the activation review heading and first unresolved assumption within Goal detail explicit state contract / Activating"
success_focus_id = "FOCUS-GOALS-DETAIL-ACTIVATING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review activation control and retained Goal status while Goal detail explicit state contract / Activating remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-ACTIVATING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-ACTIVATING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-ACTIVE"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Active; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Active reports the outcome from this visible condition: This Goal is active, with its direction, next Step, and current path health visible; focus: the Goal identity and lifecycle status within Goal detail explicit state contract / Active."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Goal is active, with its direction, next Step, and current path health visible."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal is active, with its direction, next Step, and current path health visible."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal is active, with its direction, next Step, and current path health visible."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Goal is active, with its direction, next Step, and current path health visible."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-ACTIVE-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Active"
destination_id = "DEST-GOALS-DETAIL-ACTIVE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Active reports the outcome from this visible condition: This Goal is active, with its direction, next Step, and current path health visible"
success_focus = "the Goal identity and lifecycle status within Goal detail explicit state contract / Active"
success_focus_id = "FOCUS-GOALS-DETAIL-ACTIVE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal detail explicit state contract / Active remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-ACTIVE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-ACTIVE-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-ARCHIVED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open archive => destination: the archived Goal detail and History. The handoff starts from Goal detail explicit state contract / Archived; effect: No durable mutation occurs and no Receipt is created; the archived Goal, path, Proof, Receipts, and linked work are inspected without restoring or deleting them; Goal detail explicit state contract / Archived reports the outcome from this visible condition: This Goal is outside active planning but remains available with its history; focus: the archived Goal lifecycle status within Goal detail explicit state contract / Archived."
durable_effect = "Exact command consequences: Open archive: No durable mutation occurs and no Receipt is created; the archived Goal, path, Proof, Receipts, and linked work are inspected without restoring or deleting them. The durable boundary is specific to this visible evidence: This Goal is outside active planning but remains available with its history."
recovery_rollback = "Exact rollback and recovery: Open archive: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal is outside active planning but remains available with its history."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal is outside active planning but remains available with its history."
accessibility_focus = "VoiceOver focus contract: Open archive announces its consequence, then success focuses the archived Goal lifecycle status; rejection focuses the Open archive control. The announcement includes this user-facing evidence before focus moves: This Goal is outside active planning but remains available with its history."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-ARCHIVED-001"
label = "Open archive"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The archived Goal identity and History lineage exist"]
destination = "the archived Goal detail and History. The handoff starts from Goal detail explicit state contract / Archived"
destination_id = "DEST-GOALS-DETAIL-ARCHIVED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the archived Goal, path, Proof, Receipts, and linked work are inspected without restoring or deleting them; Goal detail explicit state contract / Archived reports the outcome from this visible condition: This Goal is outside active planning but remains available with its history"
success_focus = "the archived Goal lifecycle status within Goal detail explicit state contract / Archived"
success_focus_id = "FOCUS-GOALS-DETAIL-ARCHIVED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open archive control while Goal detail explicit state contract / Archived remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-ARCHIVED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-ARCHIVED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-BLOCKED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Blocked; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Blocked reports the outcome from this visible condition: A named condition blocks this Goal’s next safe Step without erasing progress; focus: the Goal identity and lifecycle status within Goal detail explicit state contract / Blocked."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: A named condition blocks this Goal’s next safe Step without erasing progress."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A named condition blocks this Goal’s next safe Step without erasing progress."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: A named condition blocks this Goal’s next safe Step without erasing progress."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: A named condition blocks this Goal’s next safe Step without erasing progress."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-BLOCKED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Blocked"
destination_id = "DEST-GOALS-DETAIL-BLOCKED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Blocked reports the outcome from this visible condition: A named condition blocks this Goal’s next safe Step without erasing progress"
success_focus = "the Goal identity and lifecycle status within Goal detail explicit state contract / Blocked"
success_focus_id = "FOCUS-GOALS-DETAIL-BLOCKED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal detail explicit state contract / Blocked remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-BLOCKED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-BLOCKED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-CLARIFYING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Clarifying; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Clarifying reports the outcome from this visible condition: A missing Goal decision is being clarified before a path or schedule can change; focus: the Goal identity and lifecycle status within Goal detail explicit state contract / Clarifying."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: A missing Goal decision is being clarified before a path or schedule can change."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A missing Goal decision is being clarified before a path or schedule can change."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: A missing Goal decision is being clarified before a path or schedule can change."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: A missing Goal decision is being clarified before a path or schedule can change."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-CLARIFYING-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Clarifying"
destination_id = "DEST-GOALS-DETAIL-CLARIFYING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Clarifying reports the outcome from this visible condition: A missing Goal decision is being clarified before a path or schedule can change"
success_focus = "the Goal identity and lifecycle status within Goal detail explicit state contract / Clarifying"
success_focus_id = "FOCUS-GOALS-DETAIL-CLARIFYING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal detail explicit state contract / Clarifying remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-CLARIFYING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-CLARIFYING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-COMPLETED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Completed; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Completed reports the outcome from this visible condition: This Goal reached its intended outcome. Proof and remaining Steps stay separate and visible; focus: the Goal identity and lifecycle status within Goal detail explicit state contract / Completed."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Goal reached its intended outcome. Proof and remaining Steps stay separate and visible."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal reached its intended outcome. Proof and remaining Steps stay separate and visible."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal reached its intended outcome. Proof and remaining Steps stay separate and visible."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Goal reached its intended outcome. Proof and remaining Steps stay separate and visible."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-COMPLETED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Completed"
destination_id = "DEST-GOALS-DETAIL-COMPLETED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Completed reports the outcome from this visible condition: This Goal reached its intended outcome. Proof and remaining Steps stay separate and visible"
success_focus = "the Goal identity and lifecycle status within Goal detail explicit state contract / Completed"
success_focus_id = "FOCUS-GOALS-DETAIL-COMPLETED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal detail explicit state contract / Completed remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-COMPLETED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-COMPLETED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-DENSE"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Filter => destination: the Goal Detail filter sheet, then the same collection with an ephemeral filter applied. The handoff starts from Goal detail explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; only visible ordering and inclusion change; Goal, path, lifecycle, Proof, and schedule data remain unchanged; Goal detail explicit state contract / Dense reports the outcome from this visible condition: This Goal has more detail than fits at once; its direction and next Step remain first; focus: the filtered collection heading and first matching object within Goal detail explicit state contract / Dense.\nOpen Goal => destination: the selected Goal section row, then Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Dense reports the outcome from this visible condition: This Goal has more detail than fits at once; its direction and next Step remain first; focus: the Goal identity and lifecycle status within Goal detail explicit state contract / Dense."
durable_effect = "Exact command consequences: Filter: No durable mutation occurs and no Receipt is created; only visible ordering and inclusion change; Goal, path, lifecycle, Proof, and schedule data remain unchanged | Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Goal has more detail than fits at once; its direction and next Step remain first."
recovery_rollback = "Exact rollback and recovery: Filter: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal has more detail than fits at once; its direction and next Step remain first."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal has more detail than fits at once; its direction and next Step remain first."
accessibility_focus = "VoiceOver focus contract: Filter announces its consequence, then success focuses the filtered collection heading and first matching object; rejection focuses the Filter control | Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Goal has more detail than fits at once; its direction and next Step remain first."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-DENSE-001"
label = "Filter"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The current Goal/Life Area/path collection and filter options are available"]
destination = "the Goal Detail filter sheet, then the same collection with an ephemeral filter applied. The handoff starts from Goal detail explicit state contract / Dense"
destination_id = "DEST-GOALS-DETAIL-DENSE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; only visible ordering and inclusion change; Goal, path, lifecycle, Proof, and schedule data remain unchanged; Goal detail explicit state contract / Dense reports the outcome from this visible condition: This Goal has more detail than fits at once; its direction and next Step remain first"
success_focus = "the filtered collection heading and first matching object within Goal detail explicit state contract / Dense"
success_focus_id = "FOCUS-GOALS-DETAIL-DENSE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Filter control while Goal detail explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-DENSE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-DENSE-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-DENSE-002"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal section row, then Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Dense"
destination_id = "DEST-GOALS-DETAIL-DENSE-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Dense reports the outcome from this visible condition: This Goal has more detail than fits at once; its direction and next Step remain first"
success_focus = "the Goal identity and lifecycle status within Goal detail explicit state contract / Dense"
success_focus_id = "FOCUS-GOALS-DETAIL-DENSE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal detail explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-DENSE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-DENSE-002"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-DRAFT"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Draft; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Draft reports the outcome from this visible condition: This Goal is a draft. Its direction is saved, but it has not been activated; focus: the Goal identity and lifecycle status within Goal detail explicit state contract / Draft."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Goal is a draft. Its direction is saved, but it has not been activated."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal is a draft. Its direction is saved, but it has not been activated."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal is a draft. Its direction is saved, but it has not been activated."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Goal is a draft. Its direction is saved, but it has not been activated."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-DRAFT-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Draft"
destination_id = "DEST-GOALS-DETAIL-DRAFT-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Draft reports the outcome from this visible condition: This Goal is a draft. Its direction is saved, but it has not been activated"
success_focus = "the Goal identity and lifecycle status within Goal detail explicit state contract / Draft"
success_focus_id = "FOCUS-GOALS-DETAIL-DRAFT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal detail explicit state contract / Draft remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-DRAFT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-DRAFT-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-ENDED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Ended; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Ended reports the outcome from this visible condition: This Goal ended without being marked complete; its history and reason remain available; focus: the Goal identity and lifecycle status within Goal detail explicit state contract / Ended."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Goal ended without being marked complete; its history and reason remain available."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal ended without being marked complete; its history and reason remain available."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal ended without being marked complete; its history and reason remain available."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Goal ended without being marked complete; its history and reason remain available."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-ENDED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Ended"
destination_id = "DEST-GOALS-DETAIL-ENDED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Ended reports the outcome from this visible condition: This Goal ended without being marked complete; its history and reason remain available"
success_focus = "the Goal identity and lifecycle status within Goal detail explicit state contract / Ended"
success_focus_id = "FOCUS-GOALS-DETAIL-ENDED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal detail explicit state contract / Ended remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-ENDED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-ENDED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-GENERATION-FAILED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the object-scoped Goal recovery review. The handoff starts from Goal detail explicit state contract / Generation Failed; effect: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal detail explicit state contract / Generation Failed reports the outcome from this visible condition: A Goal Path could not be generated. The Goal and its original direction remain saved; focus: the Goal status and first valid repair action within Goal detail explicit state contract / Generation Failed."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs. The durable boundary is specific to this visible evidence: A Goal Path could not be generated. The Goal and its original direction remain saved."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A Goal Path could not be generated. The Goal and its original direction remain saved."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: A Goal Path could not be generated. The Goal and its original direction remain saved."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the Goal status and first valid repair action; rejection focuses the Review recovery control and failure reason. The announcement includes this user-facing evidence before focus moves: A Goal Path could not be generated. The Goal and its original direction remain saved."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-GENERATION-FAILED-001"
label = "Review recovery"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The Goal identity, retained Goal/path revision, and failure class are available"]
destination = "the object-scoped Goal recovery review. The handoff starts from Goal detail explicit state contract / Generation Failed"
destination_id = "DEST-GOALS-DETAIL-GENERATION-FAILED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal detail explicit state contract / Generation Failed reports the outcome from this visible condition: A Goal Path could not be generated. The Goal and its original direction remain saved"
success_focus = "the Goal status and first valid repair action within Goal detail explicit state contract / Generation Failed"
success_focus_id = "FOCUS-GOALS-DETAIL-GENERATION-FAILED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review recovery control and failure reason while Goal detail explicit state contract / Generation Failed remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-GENERATION-FAILED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-GENERATION-FAILED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-NEEDS-ATTENTION"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the object-scoped Goal recovery review. The handoff starts from Goal detail explicit state contract / Needs Attention; effect: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal detail explicit state contract / Needs Attention reports the outcome from this visible condition: A Goal Path, schedule, Source, or Proof condition has changed. The Goal remains unchanged; focus: the Goal status and first valid repair action within Goal detail explicit state contract / Needs Attention."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs. The durable boundary is specific to this visible evidence: A Goal Path, schedule, Source, or Proof condition has changed. The Goal remains unchanged."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A Goal Path, schedule, Source, or Proof condition has changed. The Goal remains unchanged."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: A Goal Path, schedule, Source, or Proof condition has changed. The Goal remains unchanged."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the Goal status and first valid repair action; rejection focuses the Review recovery control and failure reason. The announcement includes this user-facing evidence before focus moves: A Goal Path, schedule, Source, or Proof condition has changed. The Goal remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-NEEDS-ATTENTION-001"
label = "Review recovery"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The Goal identity, retained Goal/path revision, and failure class are available"]
destination = "the object-scoped Goal recovery review. The handoff starts from Goal detail explicit state contract / Needs Attention"
destination_id = "DEST-GOALS-DETAIL-NEEDS-ATTENTION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal detail explicit state contract / Needs Attention reports the outcome from this visible condition: A Goal Path, schedule, Source, or Proof condition has changed. The Goal remains unchanged"
success_focus = "the Goal status and first valid repair action within Goal detail explicit state contract / Needs Attention"
success_focus_id = "FOCUS-GOALS-DETAIL-NEEDS-ATTENTION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review recovery control and failure reason while Goal detail explicit state contract / Needs Attention remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-NEEDS-ATTENTION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-NEEDS-ATTENTION-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-PAUSED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Paused; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Paused reports the outcome from this visible condition: This Goal is paused. Its Path, Proof, history, and future Steps remain intact; focus: the Goal identity and lifecycle status within Goal detail explicit state contract / Paused."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Goal is paused. Its Path, Proof, history, and future Steps remain intact."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal is paused. Its Path, Proof, history, and future Steps remain intact."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal is paused. Its Path, Proof, history, and future Steps remain intact."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Goal is paused. Its Path, Proof, history, and future Steps remain intact."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-PAUSED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Paused"
destination_id = "DEST-GOALS-DETAIL-PAUSED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Paused reports the outcome from this visible condition: This Goal is paused. Its Path, Proof, history, and future Steps remain intact"
success_focus = "the Goal identity and lifecycle status within Goal detail explicit state contract / Paused"
success_focus_id = "FOCUS-GOALS-DETAIL-PAUSED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal detail explicit state contract / Paused remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-PAUSED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-PAUSED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-PREVIEW-REJECTED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Preview Rejected; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Preview Rejected reports the outcome from this visible condition: The proposed Goal change was not accepted; the current Goal remains as it was; focus: the Goal identity and lifecycle status within Goal detail explicit state contract / Preview Rejected."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: The proposed Goal change was not accepted; the current Goal remains as it was."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The proposed Goal change was not accepted; the current Goal remains as it was."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: The proposed Goal change was not accepted; the current Goal remains as it was."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: The proposed Goal change was not accepted; the current Goal remains as it was."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-PREVIEW-REJECTED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Preview Rejected"
destination_id = "DEST-GOALS-DETAIL-PREVIEW-REJECTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Preview Rejected reports the outcome from this visible condition: The proposed Goal change was not accepted; the current Goal remains as it was"
success_focus = "the Goal identity and lifecycle status within Goal detail explicit state contract / Preview Rejected"
success_focus_id = "FOCUS-GOALS-DETAIL-PREVIEW-REJECTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal detail explicit state contract / Preview Rejected remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-PREVIEW-REJECTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-PREVIEW-REJECTED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-READY-TO-ACTIVATE"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review activation => destination: the revision-bound Goal activation review. The handoff starts from Goal detail explicit state contract / Ready To Activate; effect: No durable mutation occurs and no Receipt is created; the Life Area, initial path, next Step, proof rule, schedule consequences, automation level, and unresolved assumptions are shown; Activate Goal remains a separate confirmed mutation; Goal detail explicit state contract / Ready To Activate reports the outcome from this visible condition: This Goal is not active yet. Its saved draft remains unchanged; focus: the activation review heading and first unresolved assumption within Goal detail explicit state contract / Ready To Activate."
durable_effect = "Exact command consequences: Review activation: No durable mutation occurs and no Receipt is created; the Life Area, initial path, next Step, proof rule, schedule consequences, automation level, and unresolved assumptions are shown; Activate Goal remains a separate confirmed mutation. The durable boundary is specific to this visible evidence: This Goal is not active yet. Its saved draft remains unchanged."
recovery_rollback = "Exact rollback and recovery: Review activation: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal is not active yet. Its saved draft remains unchanged."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal is not active yet. Its saved draft remains unchanged."
accessibility_focus = "VoiceOver focus contract: Review activation announces its consequence, then success focuses the activation review heading and first unresolved assumption; rejection focuses the Review activation control and retained Goal status. The announcement includes this user-facing evidence before focus moves: This Goal is not active yet. Its saved draft remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-READY-TO-ACTIVATE-001"
label = "Review activation"
canonical_owner = "surface.goals.command-contract"
preconditions = ["Clarification is sufficient for an activation preview", "The Goal identity and current reviewed revision exist"]
destination = "the revision-bound Goal activation review. The handoff starts from Goal detail explicit state contract / Ready To Activate"
destination_id = "DEST-GOALS-DETAIL-READY-TO-ACTIVATE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Life Area, initial path, next Step, proof rule, schedule consequences, automation level, and unresolved assumptions are shown; Activate Goal remains a separate confirmed mutation; Goal detail explicit state contract / Ready To Activate reports the outcome from this visible condition: This Goal is not active yet. Its saved draft remains unchanged"
success_focus = "the activation review heading and first unresolved assumption within Goal detail explicit state contract / Ready To Activate"
success_focus_id = "FOCUS-GOALS-DETAIL-READY-TO-ACTIVATE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review activation control and retained Goal status while Goal detail explicit state contract / Ready To Activate remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-READY-TO-ACTIVATE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-READY-TO-ACTIVATE-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-RECOVERING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the object-scoped Goal recovery review. The handoff starts from Goal detail explicit state contract / Recovering; effect: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal detail explicit state contract / Recovering reports the outcome from this visible condition: This Goal’s accepted direction remains visible. No saved Goal information has changed; focus: the Goal status and first valid repair action within Goal detail explicit state contract / Recovering."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs. The durable boundary is specific to this visible evidence: This Goal’s accepted direction remains visible. No saved Goal information has changed."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal’s accepted direction remains visible. No saved Goal information has changed."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal’s accepted direction remains visible. No saved Goal information has changed."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the Goal status and first valid repair action; rejection focuses the Review recovery control and failure reason. The announcement includes this user-facing evidence before focus moves: This Goal’s accepted direction remains visible. No saved Goal information has changed."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-RECOVERING-001"
label = "Review recovery"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The Goal identity, retained Goal/path revision, and failure class are available"]
destination = "the object-scoped Goal recovery review. The handoff starts from Goal detail explicit state contract / Recovering"
destination_id = "DEST-GOALS-DETAIL-RECOVERING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal detail explicit state contract / Recovering reports the outcome from this visible condition: This Goal’s accepted direction remains visible. No saved Goal information has changed"
success_focus = "the Goal status and first valid repair action within Goal detail explicit state contract / Recovering"
success_focus_id = "FOCUS-GOALS-DETAIL-RECOVERING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review recovery control and failure reason while Goal detail explicit state contract / Recovering remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-RECOVERING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-RECOVERING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-DETAIL-WAITING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Waiting; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Waiting reports the outcome from this visible condition: This Goal is waiting on a person, date, or condition; the next review point remains visible; focus: the Goal identity and lifecycle status within Goal detail explicit state contract / Waiting."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Goal is waiting on a person, date, or condition; the next review point remains visible."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal is waiting on a person, date, or condition; the next review point remains visible."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal is waiting on a person, date, or condition; the next review point remains visible."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Goal is waiting on a person, date, or condition; the next review point remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-DETAIL-WAITING-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal detail explicit state contract / Waiting"
destination_id = "DEST-GOALS-DETAIL-WAITING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal detail explicit state contract / Waiting reports the outcome from this visible condition: This Goal is waiting on a person, date, or condition; the next review point remains visible"
success_focus = "the Goal identity and lifecycle status within Goal detail explicit state contract / Waiting"
success_focus_id = "FOCUS-GOALS-DETAIL-WAITING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal detail explicit state contract / Waiting remains visible"
failure_focus_id = "FOCUS-GOALS-DETAIL-WAITING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-DETAIL-WAITING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-LIFE-AREA-DENSE"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Filter => destination: the Life Area Goal filter sheet, then the same collection with an ephemeral filter applied. The handoff starts from Life Area detail explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; only visible ordering and inclusion change; Goal, path, lifecycle, Proof, and schedule data remain unchanged; Life Area detail explicit state contract / Dense reports the outcome from this visible condition: This Life Area contains many Goals; direction and active Goals remain ahead of secondary detail; focus: the filtered collection heading and first matching object within Life Area detail explicit state contract / Dense.\nOpen Goal => destination: the selected Goal row in that Life Area, then Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Life Area detail explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Life Area detail explicit state contract / Dense reports the outcome from this visible condition: This Life Area contains many Goals; direction and active Goals remain ahead of secondary detail; focus: the Goal identity and lifecycle status within Life Area detail explicit state contract / Dense."
durable_effect = "Exact command consequences: Filter: No durable mutation occurs and no Receipt is created; only visible ordering and inclusion change; Goal, path, lifecycle, Proof, and schedule data remain unchanged | Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Life Area contains many Goals; direction and active Goals remain ahead of secondary detail."
recovery_rollback = "Exact rollback and recovery: Filter: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Life Area contains many Goals; direction and active Goals remain ahead of secondary detail."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Life Area contains many Goals; direction and active Goals remain ahead of secondary detail."
accessibility_focus = "VoiceOver focus contract: Filter announces its consequence, then success focuses the filtered collection heading and first matching object; rejection focuses the Filter control | Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Life Area contains many Goals; direction and active Goals remain ahead of secondary detail."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-LIFE-AREA-DENSE-001"
label = "Filter"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The current Goal/Life Area/path collection and filter options are available"]
destination = "the Life Area Goal filter sheet, then the same collection with an ephemeral filter applied. The handoff starts from Life Area detail explicit state contract / Dense"
destination_id = "DEST-GOALS-LIFE-AREA-DENSE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; only visible ordering and inclusion change; Goal, path, lifecycle, Proof, and schedule data remain unchanged; Life Area detail explicit state contract / Dense reports the outcome from this visible condition: This Life Area contains many Goals; direction and active Goals remain ahead of secondary detail"
success_focus = "the filtered collection heading and first matching object within Life Area detail explicit state contract / Dense"
success_focus_id = "FOCUS-GOALS-LIFE-AREA-DENSE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Filter control while Life Area detail explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-GOALS-LIFE-AREA-DENSE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-LIFE-AREA-DENSE-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-LIFE-AREA-DENSE-002"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal row in that Life Area, then Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Life Area detail explicit state contract / Dense"
destination_id = "DEST-GOALS-LIFE-AREA-DENSE-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Life Area detail explicit state contract / Dense reports the outcome from this visible condition: This Life Area contains many Goals; direction and active Goals remain ahead of secondary detail"
success_focus = "the Goal identity and lifecycle status within Life Area detail explicit state contract / Dense"
success_focus_id = "FOCUS-GOALS-LIFE-AREA-DENSE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Life Area detail explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-GOALS-LIFE-AREA-DENSE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-LIFE-AREA-DENSE-002"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-LIFE-AREA-EMPTY-DIRECTION"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Life Area detail explicit state contract / Empty Direction; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Life Area detail explicit state contract / Empty Direction reports the outcome from this visible condition: This Life Area has no active direction yet; no Goal is implied; focus: the Goal identity and lifecycle status within Life Area detail explicit state contract / Empty Direction."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Life Area has no active direction yet; no Goal is implied."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Life Area has no active direction yet; no Goal is implied."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Life Area has no active direction yet; no Goal is implied."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Life Area has no active direction yet; no Goal is implied."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-LIFE-AREA-EMPTY-DIRECTION-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Life Area detail explicit state contract / Empty Direction"
destination_id = "DEST-GOALS-LIFE-AREA-EMPTY-DIRECTION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Life Area detail explicit state contract / Empty Direction reports the outcome from this visible condition: This Life Area has no active direction yet; no Goal is implied"
success_focus = "the Goal identity and lifecycle status within Life Area detail explicit state contract / Empty Direction"
success_focus_id = "FOCUS-GOALS-LIFE-AREA-EMPTY-DIRECTION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Life Area detail explicit state contract / Empty Direction remains visible"
failure_focus_id = "FOCUS-GOALS-LIFE-AREA-EMPTY-DIRECTION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-LIFE-AREA-EMPTY-DIRECTION-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-LIFE-AREA-NEEDS-ATTENTION"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the object-scoped Goal recovery review. The handoff starts from Life Area detail explicit state contract / Needs Attention; effect: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Life Area detail explicit state contract / Needs Attention reports the outcome from this visible condition: A Goal in this Life Area has an unresolved change. The Life Area direction remains visible; focus: the Goal status and first valid repair action within Life Area detail explicit state contract / Needs Attention."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs. The durable boundary is specific to this visible evidence: A Goal in this Life Area has an unresolved change. The Life Area direction remains visible."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A Goal in this Life Area has an unresolved change. The Life Area direction remains visible."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: A Goal in this Life Area has an unresolved change. The Life Area direction remains visible."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the Goal status and first valid repair action; rejection focuses the Review recovery control and failure reason. The announcement includes this user-facing evidence before focus moves: A Goal in this Life Area has an unresolved change. The Life Area direction remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-LIFE-AREA-NEEDS-ATTENTION-001"
label = "Review recovery"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The Goal identity, retained Goal/path revision, and failure class are available"]
destination = "the object-scoped Goal recovery review. The handoff starts from Life Area detail explicit state contract / Needs Attention"
destination_id = "DEST-GOALS-LIFE-AREA-NEEDS-ATTENTION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Life Area detail explicit state contract / Needs Attention reports the outcome from this visible condition: A Goal in this Life Area has an unresolved change. The Life Area direction remains visible"
success_focus = "the Goal status and first valid repair action within Life Area detail explicit state contract / Needs Attention"
success_focus_id = "FOCUS-GOALS-LIFE-AREA-NEEDS-ATTENTION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review recovery control and failure reason while Life Area detail explicit state contract / Needs Attention remains visible"
failure_focus_id = "FOCUS-GOALS-LIFE-AREA-NEEDS-ATTENTION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-LIFE-AREA-NEEDS-ATTENTION-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-LIFE-AREA-POPULATED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Life Area detail explicit state contract / Populated; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Life Area detail explicit state contract / Populated reports the outcome from this visible condition: This Life Area shows its current Goals and how each supports the chosen direction; focus: the Goal identity and lifecycle status within Life Area detail explicit state contract / Populated."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Life Area shows its current Goals and how each supports the chosen direction."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Life Area shows its current Goals and how each supports the chosen direction."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Life Area shows its current Goals and how each supports the chosen direction."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Life Area shows its current Goals and how each supports the chosen direction."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-LIFE-AREA-POPULATED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Life Area detail explicit state contract / Populated"
destination_id = "DEST-GOALS-LIFE-AREA-POPULATED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Life Area detail explicit state contract / Populated reports the outcome from this visible condition: This Life Area shows its current Goals and how each supports the chosen direction"
success_focus = "the Goal identity and lifecycle status within Life Area detail explicit state contract / Populated"
success_focus_id = "FOCUS-GOALS-LIFE-AREA-POPULATED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Life Area detail explicit state contract / Populated remains visible"
failure_focus_id = "FOCUS-GOALS-LIFE-AREA-POPULATED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-LIFE-AREA-POPULATED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-ACTIVE"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Active; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Active reports the outcome from this visible condition: This Goal Path is active, with its current route and next Step visible; focus: the Goal identity and lifecycle status within Full Goal Path explicit state contract / Active."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Goal Path is active, with its current route and next Step visible."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal Path is active, with its current route and next Step visible."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal Path is active, with its current route and next Step visible."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Goal Path is active, with its current route and next Step visible."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-ACTIVE-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Active"
destination_id = "DEST-GOALS-PATH-ACTIVE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Active reports the outcome from this visible condition: This Goal Path is active, with its current route and next Step visible"
success_focus = "the Goal identity and lifecycle status within Full Goal Path explicit state contract / Active"
success_focus_id = "FOCUS-GOALS-PATH-ACTIVE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Full Goal Path explicit state contract / Active remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-ACTIVE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-ACTIVE-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-BLOCKED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Blocked; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Blocked reports the outcome from this visible condition: A named condition blocks the next Path Step; completed progress remains intact; focus: the Goal identity and lifecycle status within Full Goal Path explicit state contract / Blocked."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: A named condition blocks the next Path Step; completed progress remains intact."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A named condition blocks the next Path Step; completed progress remains intact."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: A named condition blocks the next Path Step; completed progress remains intact."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: A named condition blocks the next Path Step; completed progress remains intact."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-BLOCKED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Blocked"
destination_id = "DEST-GOALS-PATH-BLOCKED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Blocked reports the outcome from this visible condition: A named condition blocks the next Path Step; completed progress remains intact"
success_focus = "the Goal identity and lifecycle status within Full Goal Path explicit state contract / Blocked"
success_focus_id = "FOCUS-GOALS-PATH-BLOCKED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Full Goal Path explicit state contract / Blocked remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-BLOCKED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-BLOCKED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-COMPLETED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Completed; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Completed reports the outcome from this visible condition: This Goal Path is complete, and its progress and Proof remain available; focus: the Goal identity and lifecycle status within Full Goal Path explicit state contract / Completed."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Goal Path is complete, and its progress and Proof remain available."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal Path is complete, and its progress and Proof remain available."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal Path is complete, and its progress and Proof remain available."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Goal Path is complete, and its progress and Proof remain available."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-COMPLETED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Completed"
destination_id = "DEST-GOALS-PATH-COMPLETED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Completed reports the outcome from this visible condition: This Goal Path is complete, and its progress and Proof remain available"
success_focus = "the Goal identity and lifecycle status within Full Goal Path explicit state contract / Completed"
success_focus_id = "FOCUS-GOALS-PATH-COMPLETED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Full Goal Path explicit state contract / Completed remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-COMPLETED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-COMPLETED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-DENSE"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Filter => destination: the Goal Path node filter sheet, then the same collection with an ephemeral filter applied. The handoff starts from Full Goal Path explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; only visible ordering and inclusion change; Goal, path, lifecycle, Proof, and schedule data remain unchanged; Full Goal Path explicit state contract / Dense reports the outcome from this visible condition: This Goal Path has more points than fit at once; the current route and next Step remain prominent; focus: the filtered collection heading and first matching object within Full Goal Path explicit state contract / Dense.\nOpen step => destination: the selected Path node detail, then the selected Step detail within its Goal Path context. The handoff starts from Full Goal Path explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; the Step and path open for inspection without changing lifecycle, order, schedule, or Proof; Full Goal Path explicit state contract / Dense reports the outcome from this visible condition: This Goal Path has more points than fit at once; the current route and next Step remain prominent; focus: the selected Step heading within Full Goal Path explicit state contract / Dense."
durable_effect = "Exact command consequences: Filter: No durable mutation occurs and no Receipt is created; only visible ordering and inclusion change; Goal, path, lifecycle, Proof, and schedule data remain unchanged | Open step: No durable mutation occurs and no Receipt is created; the Step and path open for inspection without changing lifecycle, order, schedule, or Proof. The durable boundary is specific to this visible evidence: This Goal Path has more points than fit at once; the current route and next Step remain prominent."
recovery_rollback = "Exact rollback and recovery: Filter: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal Path has more points than fit at once; the current route and next Step remain prominent."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal Path has more points than fit at once; the current route and next Step remain prominent."
accessibility_focus = "VoiceOver focus contract: Filter announces its consequence, then success focuses the filtered collection heading and first matching object; rejection focuses the Filter control | Open step announces its consequence, then success focuses the selected Step heading; rejection focuses the initiating path node or row. The announcement includes this user-facing evidence before focus moves: This Goal Path has more points than fit at once; the current route and next Step remain prominent."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-DENSE-001"
label = "Filter"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The current Goal/Life Area/path collection and filter options are available"]
destination = "the Goal Path node filter sheet, then the same collection with an ephemeral filter applied. The handoff starts from Full Goal Path explicit state contract / Dense"
destination_id = "DEST-GOALS-PATH-DENSE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; only visible ordering and inclusion change; Goal, path, lifecycle, Proof, and schedule data remain unchanged; Full Goal Path explicit state contract / Dense reports the outcome from this visible condition: This Goal Path has more points than fit at once; the current route and next Step remain prominent"
success_focus = "the filtered collection heading and first matching object within Full Goal Path explicit state contract / Dense"
success_focus_id = "FOCUS-GOALS-PATH-DENSE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Filter control while Full Goal Path explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-DENSE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-DENSE-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-DENSE-002"
label = "Open step"
canonical_owner = "surface.goals.command-contract"
preconditions = ["A stable path-node Step identity and current Goal revision exist"]
destination = "the selected Path node detail, then the selected Step detail within its Goal Path context. The handoff starts from Full Goal Path explicit state contract / Dense"
destination_id = "DEST-GOALS-PATH-DENSE-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Step and path open for inspection without changing lifecycle, order, schedule, or Proof; Full Goal Path explicit state contract / Dense reports the outcome from this visible condition: This Goal Path has more points than fit at once; the current route and next Step remain prominent"
success_focus = "the selected Step heading within Full Goal Path explicit state contract / Dense"
success_focus_id = "FOCUS-GOALS-PATH-DENSE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating path node or row while Full Goal Path explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-DENSE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-DENSE-002"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-DRAFT"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Draft; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Draft reports the outcome from this visible condition: This Goal Path is a draft. Nothing is scheduled; focus: the Goal identity and lifecycle status within Full Goal Path explicit state contract / Draft."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Goal Path is a draft. Nothing is scheduled."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal Path is a draft. Nothing is scheduled."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal Path is a draft. Nothing is scheduled."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Goal Path is a draft. Nothing is scheduled."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-DRAFT-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Draft"
destination_id = "DEST-GOALS-PATH-DRAFT-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Draft reports the outcome from this visible condition: This Goal Path is a draft. Nothing is scheduled"
success_focus = "the Goal identity and lifecycle status within Full Goal Path explicit state contract / Draft"
success_focus_id = "FOCUS-GOALS-PATH-DRAFT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Full Goal Path explicit state contract / Draft remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-DRAFT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-DRAFT-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-MISSING-REFERENCE-CONTEXT"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Missing Reference Context; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Missing Reference Context reports the outcome from this visible condition: A Source or related item for this Goal Path is unavailable. The saved path remains visible; focus: the Goal identity and lifecycle status within Full Goal Path explicit state contract / Missing Reference Context."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: A Source or related item for this Goal Path is unavailable. The saved path remains visible."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A Source or related item for this Goal Path is unavailable. The saved path remains visible."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: A Source or related item for this Goal Path is unavailable. The saved path remains visible."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: A Source or related item for this Goal Path is unavailable. The saved path remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-MISSING-REFERENCE-CONTEXT-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Missing Reference Context"
destination_id = "DEST-GOALS-PATH-MISSING-REFERENCE-CONTEXT-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Missing Reference Context reports the outcome from this visible condition: A Source or related item for this Goal Path is unavailable. The saved path remains visible"
success_focus = "the Goal identity and lifecycle status within Full Goal Path explicit state contract / Missing Reference Context"
success_focus_id = "FOCUS-GOALS-PATH-MISSING-REFERENCE-CONTEXT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Full Goal Path explicit state contract / Missing Reference Context remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-MISSING-REFERENCE-CONTEXT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-MISSING-REFERENCE-CONTEXT-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-NEEDS-ATTENTION"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the Goal Path recovery review. The handoff starts from Full Goal Path explicit state contract / Needs Attention; effect: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Keep unresolved, or Restore previous path; no choice rewrites prior path History; Full Goal Path explicit state contract / Needs Attention reports the outcome from this visible condition: A Proof, schedule fit, Source, or path condition has changed. The Goal Path remains unchanged; focus: the affected current path node and first valid recovery action within Full Goal Path explicit state contract / Needs Attention."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Keep unresolved, or Restore previous path; no choice rewrites prior path History. The durable boundary is specific to this visible evidence: A Proof, schedule fit, Source, or path condition has changed. The Goal Path remains unchanged."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A Proof, schedule fit, Source, or path condition has changed. The Goal Path remains unchanged."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: A Proof, schedule fit, Source, or path condition has changed. The Goal Path remains unchanged."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the affected current path node and first valid recovery action; rejection focuses the Review recovery control and retained path status. The announcement includes this user-facing evidence before focus moves: A Proof, schedule fit, Source, or path condition has changed. The Goal Path remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-NEEDS-ATTENTION-001"
label = "Review recovery"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The Goal identity, retained path revision, and failure class are available"]
destination = "the Goal Path recovery review. The handoff starts from Full Goal Path explicit state contract / Needs Attention"
destination_id = "DEST-GOALS-PATH-NEEDS-ATTENTION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Keep unresolved, or Restore previous path; no choice rewrites prior path History; Full Goal Path explicit state contract / Needs Attention reports the outcome from this visible condition: A Proof, schedule fit, Source, or path condition has changed. The Goal Path remains unchanged"
success_focus = "the affected current path node and first valid recovery action within Full Goal Path explicit state contract / Needs Attention"
success_focus_id = "FOCUS-GOALS-PATH-NEEDS-ATTENTION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review recovery control and retained path status while Full Goal Path explicit state contract / Needs Attention remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-NEEDS-ATTENTION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-NEEDS-ATTENTION-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-PARTIAL-SIMULATION"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained current Goal Path and initiating node. The handoff starts from Full Goal Path explicit state contract / Partial Simulation; effect: No durable mutation occurs and no Receipt is created; the proposed version is rejected; the active path, Steps, schedule, Proof, and History remain unchanged; Full Goal Path explicit state contract / Partial Simulation reports the outcome from this visible condition: Only part of the proposed Path could be tested; untested sections remain clearly marked; this command preserves accepted product state; focus: the initiating path action or current path node within Full Goal Path explicit state contract / Partial Simulation."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; the proposed version is rejected; the active path, Steps, schedule, Proof, and History remain unchanged. The durable boundary is specific to this visible evidence: Only part of the proposed Path could be tested; untested sections remain clearly marked."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Only part of the proposed Path could be tested; untested sections remain clearly marked."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: Only part of the proposed Path could be tested; untested sections remain clearly marked."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating path action or current path node; rejection focuses the in-progress path status and Cancel control. The announcement includes this user-facing evidence before focus moves: Only part of the proposed Path could be tested; untested sections remain clearly marked."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-PARTIAL-SIMULATION-001"
label = "Cancel"
canonical_owner = "surface.goals.command-contract"
preconditions = ["Only route generation, simulation, or path-change preview remains uncommitted"]
destination = "the retained current Goal Path and initiating node. The handoff starts from Full Goal Path explicit state contract / Partial Simulation"
destination_id = "DEST-GOALS-PATH-PARTIAL-SIMULATION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposed version is rejected; the active path, Steps, schedule, Proof, and History remain unchanged; Full Goal Path explicit state contract / Partial Simulation reports the outcome from this visible condition: Only part of the proposed Path could be tested; untested sections remain clearly marked; this command preserves accepted product state"
success_focus = "the initiating path action or current path node within Full Goal Path explicit state contract / Partial Simulation"
success_focus_id = "FOCUS-GOALS-PATH-PARTIAL-SIMULATION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the in-progress path status and Cancel control while Full Goal Path explicit state contract / Partial Simulation remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-PARTIAL-SIMULATION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-PARTIAL-SIMULATION-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-PATH-ADJUSTING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained current Goal Path and initiating node. The handoff starts from Full Goal Path explicit state contract / Path Adjusting; effect: No durable mutation occurs and no Receipt is created; the proposed version is rejected; the active path, Steps, schedule, Proof, and History remain unchanged; Full Goal Path explicit state contract / Path Adjusting reports the outcome from this visible condition: A proposed Path adjustment is being prepared while the current route remains visible; this command preserves accepted product state; focus: the initiating path action or current path node within Full Goal Path explicit state contract / Path Adjusting."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; the proposed version is rejected; the active path, Steps, schedule, Proof, and History remain unchanged. The durable boundary is specific to this visible evidence: A proposed Path adjustment is being prepared while the current route remains visible."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A proposed Path adjustment is being prepared while the current route remains visible."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: A proposed Path adjustment is being prepared while the current route remains visible."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating path action or current path node; rejection focuses the in-progress path status and Cancel control. The announcement includes this user-facing evidence before focus moves: A proposed Path adjustment is being prepared while the current route remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-PATH-ADJUSTING-001"
label = "Cancel"
canonical_owner = "surface.goals.command-contract"
preconditions = ["Only route generation, simulation, or path-change preview remains uncommitted"]
destination = "the retained current Goal Path and initiating node. The handoff starts from Full Goal Path explicit state contract / Path Adjusting"
destination_id = "DEST-GOALS-PATH-PATH-ADJUSTING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposed version is rejected; the active path, Steps, schedule, Proof, and History remain unchanged; Full Goal Path explicit state contract / Path Adjusting reports the outcome from this visible condition: A proposed Path adjustment is being prepared while the current route remains visible; this command preserves accepted product state"
success_focus = "the initiating path action or current path node within Full Goal Path explicit state contract / Path Adjusting"
success_focus_id = "FOCUS-GOALS-PATH-PATH-ADJUSTING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the in-progress path status and Cancel control while Full Goal Path explicit state contract / Path Adjusting remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-PATH-ADJUSTING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-PATH-ADJUSTING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-PATH-GENERATION-UNCERTAIN"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Path Generation Uncertain; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Path Generation Uncertain reports the outcome from this visible condition: The proposed route is uncertain; the Goal remains saved without an invented next Step; focus: the Goal identity and lifecycle status within Full Goal Path explicit state contract / Path Generation Uncertain."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: The proposed route is uncertain; the Goal remains saved without an invented next Step."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The proposed route is uncertain; the Goal remains saved without an invented next Step."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: The proposed route is uncertain; the Goal remains saved without an invented next Step."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: The proposed route is uncertain; the Goal remains saved without an invented next Step."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-PATH-GENERATION-UNCERTAIN-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Path Generation Uncertain"
destination_id = "DEST-GOALS-PATH-PATH-GENERATION-UNCERTAIN-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Path Generation Uncertain reports the outcome from this visible condition: The proposed route is uncertain; the Goal remains saved without an invented next Step"
success_focus = "the Goal identity and lifecycle status within Full Goal Path explicit state contract / Path Generation Uncertain"
success_focus_id = "FOCUS-GOALS-PATH-PATH-GENERATION-UNCERTAIN-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Full Goal Path explicit state contract / Path Generation Uncertain remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-PATH-GENERATION-UNCERTAIN-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-PATH-GENERATION-UNCERTAIN-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-PAUSED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Paused; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Paused reports the outcome from this visible condition: This Goal Path is paused. Its route, progress, and Proof remain saved for return; focus: the Goal identity and lifecycle status within Full Goal Path explicit state contract / Paused."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Goal Path is paused. Its route, progress, and Proof remain saved for return."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal Path is paused. Its route, progress, and Proof remain saved for return."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal Path is paused. Its route, progress, and Proof remain saved for return."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Goal Path is paused. Its route, progress, and Proof remain saved for return."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-PAUSED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Paused"
destination_id = "DEST-GOALS-PATH-PAUSED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Paused reports the outcome from this visible condition: This Goal Path is paused. Its route, progress, and Proof remain saved for return"
success_focus = "the Goal identity and lifecycle status within Full Goal Path explicit state contract / Paused"
success_focus_id = "FOCUS-GOALS-PATH-PAUSED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Full Goal Path explicit state contract / Paused remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-PAUSED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-PAUSED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-READY-TO-ACTIVATE"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review activation => destination: the revision-bound Goal activation review. The handoff starts from Full Goal Path explicit state contract / Ready To Activate; effect: No durable mutation occurs and no Receipt is created; the Life Area, initial path, next Step, proof rule, schedule consequences, automation level, and unresolved assumptions are shown; Activate Goal remains a separate confirmed mutation; Full Goal Path explicit state contract / Ready To Activate reports the outcome from this visible condition: This Goal Path is still a draft. The active Goal remains unchanged; focus: the activation review heading and first unresolved assumption within Full Goal Path explicit state contract / Ready To Activate."
durable_effect = "Exact command consequences: Review activation: No durable mutation occurs and no Receipt is created; the Life Area, initial path, next Step, proof rule, schedule consequences, automation level, and unresolved assumptions are shown; Activate Goal remains a separate confirmed mutation. The durable boundary is specific to this visible evidence: This Goal Path is still a draft. The active Goal remains unchanged."
recovery_rollback = "Exact rollback and recovery: Review activation: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal Path is still a draft. The active Goal remains unchanged."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal Path is still a draft. The active Goal remains unchanged."
accessibility_focus = "VoiceOver focus contract: Review activation announces its consequence, then success focuses the activation review heading and first unresolved assumption; rejection focuses the Review activation control and retained Goal status. The announcement includes this user-facing evidence before focus moves: This Goal Path is still a draft. The active Goal remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-READY-TO-ACTIVATE-001"
label = "Review activation"
canonical_owner = "surface.goals.command-contract"
preconditions = ["Clarification is sufficient for an activation preview", "The Goal identity and current reviewed revision exist"]
destination = "the revision-bound Goal activation review. The handoff starts from Full Goal Path explicit state contract / Ready To Activate"
destination_id = "DEST-GOALS-PATH-READY-TO-ACTIVATE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Life Area, initial path, next Step, proof rule, schedule consequences, automation level, and unresolved assumptions are shown; Activate Goal remains a separate confirmed mutation; Full Goal Path explicit state contract / Ready To Activate reports the outcome from this visible condition: This Goal Path is still a draft. The active Goal remains unchanged"
success_focus = "the activation review heading and first unresolved assumption within Full Goal Path explicit state contract / Ready To Activate"
success_focus_id = "FOCUS-GOALS-PATH-READY-TO-ACTIVATE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review activation control and retained Goal status while Full Goal Path explicit state contract / Ready To Activate remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-READY-TO-ACTIVATE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-READY-TO-ACTIVATE-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-RECOVERING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the Goal Path recovery review. The handoff starts from Full Goal Path explicit state contract / Recovering; effect: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Keep unresolved, or Restore previous path; no choice rewrites prior path History; Full Goal Path explicit state contract / Recovering reports the outcome from this visible condition: The accepted Goal Path stays visible while a bounded recovery is considered; focus: the affected current path node and first valid recovery action within Full Goal Path explicit state contract / Recovering."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Keep unresolved, or Restore previous path; no choice rewrites prior path History. The durable boundary is specific to this visible evidence: The accepted Goal Path stays visible while a bounded recovery is considered."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The accepted Goal Path stays visible while a bounded recovery is considered."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: The accepted Goal Path stays visible while a bounded recovery is considered."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the affected current path node and first valid recovery action; rejection focuses the Review recovery control and retained path status. The announcement includes this user-facing evidence before focus moves: The accepted Goal Path stays visible while a bounded recovery is considered."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-RECOVERING-001"
label = "Review recovery"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The Goal identity, retained path revision, and failure class are available"]
destination = "the Goal Path recovery review. The handoff starts from Full Goal Path explicit state contract / Recovering"
destination_id = "DEST-GOALS-PATH-RECOVERING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Keep unresolved, or Restore previous path; no choice rewrites prior path History; Full Goal Path explicit state contract / Recovering reports the outcome from this visible condition: The accepted Goal Path stays visible while a bounded recovery is considered"
success_focus = "the affected current path node and first valid recovery action within Full Goal Path explicit state contract / Recovering"
success_focus_id = "FOCUS-GOALS-PATH-RECOVERING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review recovery control and retained path status while Full Goal Path explicit state contract / Recovering remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-RECOVERING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-RECOVERING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-RESTORING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Restoring; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Restoring reports the outcome from this visible condition: The last accepted Goal Path is being restored with its history and Proof intact; focus: the Goal identity and lifecycle status within Full Goal Path explicit state contract / Restoring."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: The last accepted Goal Path is being restored with its history and Proof intact."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The last accepted Goal Path is being restored with its history and Proof intact."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: The last accepted Goal Path is being restored with its history and Proof intact."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: The last accepted Goal Path is being restored with its history and Proof intact."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-RESTORING-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Restoring"
destination_id = "DEST-GOALS-PATH-RESTORING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Restoring reports the outcome from this visible condition: The last accepted Goal Path is being restored with its history and Proof intact"
success_focus = "the Goal identity and lifecycle status within Full Goal Path explicit state contract / Restoring"
success_focus_id = "FOCUS-GOALS-PATH-RESTORING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Full Goal Path explicit state contract / Restoring remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-RESTORING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-RESTORING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-ROLLED-BACK"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Rolled Back; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Rolled Back reports the outcome from this visible condition: The prior Goal Path has been restored, with the reversal recorded in history; focus: the Goal identity and lifecycle status within Full Goal Path explicit state contract / Rolled Back."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: The prior Goal Path has been restored, with the reversal recorded in history."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The prior Goal Path has been restored, with the reversal recorded in history."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: The prior Goal Path has been restored, with the reversal recorded in history."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: The prior Goal Path has been restored, with the reversal recorded in history."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-ROLLED-BACK-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Rolled Back"
destination_id = "DEST-GOALS-PATH-ROLLED-BACK-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Rolled Back reports the outcome from this visible condition: The prior Goal Path has been restored, with the reversal recorded in history"
success_focus = "the Goal identity and lifecycle status within Full Goal Path explicit state contract / Rolled Back"
success_focus_id = "FOCUS-GOALS-PATH-ROLLED-BACK-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Full Goal Path explicit state contract / Rolled Back remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-ROLLED-BACK-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-ROLLED-BACK-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-ROUTE-GENERATING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained current Goal Path and initiating node. The handoff starts from Full Goal Path explicit state contract / Route Generating; effect: No durable mutation occurs and no Receipt is created; the proposed version is rejected; the active path, Steps, schedule, Proof, and History remain unchanged; Full Goal Path explicit state contract / Route Generating reports the outcome from this visible condition: A possible route is being prepared from the Goal’s current direction; nothing is active yet; this command preserves accepted product state; focus: the initiating path action or current path node within Full Goal Path explicit state contract / Route Generating."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; the proposed version is rejected; the active path, Steps, schedule, Proof, and History remain unchanged. The durable boundary is specific to this visible evidence: A possible route is being prepared from the Goal’s current direction; nothing is active yet."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A possible route is being prepared from the Goal’s current direction; nothing is active yet."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: A possible route is being prepared from the Goal’s current direction; nothing is active yet."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating path action or current path node; rejection focuses the in-progress path status and Cancel control. The announcement includes this user-facing evidence before focus moves: A possible route is being prepared from the Goal’s current direction; nothing is active yet."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-ROUTE-GENERATING-001"
label = "Cancel"
canonical_owner = "surface.goals.command-contract"
preconditions = ["Only route generation, simulation, or path-change preview remains uncommitted"]
destination = "the retained current Goal Path and initiating node. The handoff starts from Full Goal Path explicit state contract / Route Generating"
destination_id = "DEST-GOALS-PATH-ROUTE-GENERATING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the proposed version is rejected; the active path, Steps, schedule, Proof, and History remain unchanged; Full Goal Path explicit state contract / Route Generating reports the outcome from this visible condition: A possible route is being prepared from the Goal’s current direction; nothing is active yet; this command preserves accepted product state"
success_focus = "the initiating path action or current path node within Full Goal Path explicit state contract / Route Generating"
success_focus_id = "FOCUS-GOALS-PATH-ROUTE-GENERATING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the in-progress path status and Cancel control while Full Goal Path explicit state contract / Route Generating remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-ROUTE-GENERATING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-ROUTE-GENERATING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-SELECTED-NODE"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open step => destination: the selected Step detail within its Goal Path context. The handoff starts from Full Goal Path explicit state contract / Selected Node; effect: No durable mutation occurs and no Receipt is created; the Step and path open for inspection without changing lifecycle, order, schedule, or Proof; Full Goal Path explicit state contract / Selected Node reports the outcome from this visible condition: The selected Path point shows its position, reason, Proof, and schedule consequence; focus: the selected Step heading within Full Goal Path explicit state contract / Selected Node."
durable_effect = "Exact command consequences: Open step: No durable mutation occurs and no Receipt is created; the Step and path open for inspection without changing lifecycle, order, schedule, or Proof. The durable boundary is specific to this visible evidence: The selected Path point shows its position, reason, Proof, and schedule consequence."
recovery_rollback = "Exact rollback and recovery: Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The selected Path point shows its position, reason, Proof, and schedule consequence."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: The selected Path point shows its position, reason, Proof, and schedule consequence."
accessibility_focus = "VoiceOver focus contract: Open step announces its consequence, then success focuses the selected Step heading; rejection focuses the initiating path node or row. The announcement includes this user-facing evidence before focus moves: The selected Path point shows its position, reason, Proof, and schedule consequence."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-SELECTED-NODE-001"
label = "Open step"
canonical_owner = "surface.goals.command-contract"
preconditions = ["A stable path-node Step identity and current Goal revision exist"]
destination = "the selected Step detail within its Goal Path context. The handoff starts from Full Goal Path explicit state contract / Selected Node"
destination_id = "DEST-GOALS-PATH-SELECTED-NODE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Step and path open for inspection without changing lifecycle, order, schedule, or Proof; Full Goal Path explicit state contract / Selected Node reports the outcome from this visible condition: The selected Path point shows its position, reason, Proof, and schedule consequence"
success_focus = "the selected Step heading within Full Goal Path explicit state contract / Selected Node"
success_focus_id = "FOCUS-GOALS-PATH-SELECTED-NODE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating path node or row while Full Goal Path explicit state contract / Selected Node remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-SELECTED-NODE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-SELECTED-NODE-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-SIMULATING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Simulating; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Simulating reports the outcome from this visible condition: A possible Goal Path is being tested without changing the active route; focus: the Goal identity and lifecycle status within Full Goal Path explicit state contract / Simulating."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: A possible Goal Path is being tested without changing the active route."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A possible Goal Path is being tested without changing the active route."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: A possible Goal Path is being tested without changing the active route."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: A possible Goal Path is being tested without changing the active route."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-SIMULATING-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Simulating"
destination_id = "DEST-GOALS-PATH-SIMULATING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Simulating reports the outcome from this visible condition: A possible Goal Path is being tested without changing the active route"
success_focus = "the Goal identity and lifecycle status within Full Goal Path explicit state contract / Simulating"
success_focus_id = "FOCUS-GOALS-PATH-SIMULATING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Full Goal Path explicit state contract / Simulating remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-SIMULATING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-SIMULATING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-PATH-WAITING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Waiting; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Waiting reports the outcome from this visible condition: This Goal Path is waiting on a named condition. Its saved Steps remain unchanged; focus: the Goal identity and lifecycle status within Full Goal Path explicit state contract / Waiting."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: This Goal Path is waiting on a named condition. Its saved Steps remain unchanged."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Goal Path is waiting on a named condition. Its saved Steps remain unchanged."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: This Goal Path is waiting on a named condition. Its saved Steps remain unchanged."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: This Goal Path is waiting on a named condition. Its saved Steps remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-PATH-WAITING-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Full Goal Path explicit state contract / Waiting"
destination_id = "DEST-GOALS-PATH-WAITING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Full Goal Path explicit state contract / Waiting reports the outcome from this visible condition: This Goal Path is waiting on a named condition. Its saved Steps remain unchanged"
success_focus = "the Goal identity and lifecycle status within Full Goal Path explicit state contract / Waiting"
success_focus_id = "FOCUS-GOALS-PATH-WAITING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Full Goal Path explicit state contract / Waiting remains visible"
failure_focus_id = "FOCUS-GOALS-PATH-WAITING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-PATH-WAITING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-RECOVERY-BLOCKED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal recovery packet explicit state contract / Blocked; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal recovery packet explicit state contract / Blocked reports the outcome from this visible condition: Recovery cannot continue until the named blocking condition changes; focus: the Goal identity and lifecycle status within Goal recovery packet explicit state contract / Blocked."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: Recovery cannot continue until the named blocking condition changes."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Recovery cannot continue until the named blocking condition changes."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: Recovery cannot continue until the named blocking condition changes."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: Recovery cannot continue until the named blocking condition changes."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-RECOVERY-BLOCKED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal recovery packet explicit state contract / Blocked"
destination_id = "DEST-GOALS-RECOVERY-BLOCKED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal recovery packet explicit state contract / Blocked reports the outcome from this visible condition: Recovery cannot continue until the named blocking condition changes"
success_focus = "the Goal identity and lifecycle status within Goal recovery packet explicit state contract / Blocked"
success_focus_id = "FOCUS-GOALS-RECOVERY-BLOCKED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal recovery packet explicit state contract / Blocked remains visible"
failure_focus_id = "FOCUS-GOALS-RECOVERY-BLOCKED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-RECOVERY-BLOCKED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-RECOVERY-LOCAL-STORE-DEGRADED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the object-scoped Goal recovery review. The handoff starts from Goal recovery packet explicit state contract / Local Store Degraded; effect: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal recovery packet explicit state contract / Local Store Degraded reports the outcome from this visible condition: Some saved Goal information is unavailable; recovery stays limited to verified local facts; focus: the Goal status and first valid repair action within Goal recovery packet explicit state contract / Local Store Degraded."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs. The durable boundary is specific to this visible evidence: Some saved Goal information is unavailable; recovery stays limited to verified local facts."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Some saved Goal information is unavailable; recovery stays limited to verified local facts."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: Some saved Goal information is unavailable; recovery stays limited to verified local facts."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the Goal status and first valid repair action; rejection focuses the Review recovery control and failure reason. The announcement includes this user-facing evidence before focus moves: Some saved Goal information is unavailable; recovery stays limited to verified local facts."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-RECOVERY-LOCAL-STORE-DEGRADED-001"
label = "Review recovery"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The Goal identity, retained Goal/path revision, and failure class are available"]
destination = "the object-scoped Goal recovery review. The handoff starts from Goal recovery packet explicit state contract / Local Store Degraded"
destination_id = "DEST-GOALS-RECOVERY-LOCAL-STORE-DEGRADED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal recovery packet explicit state contract / Local Store Degraded reports the outcome from this visible condition: Some saved Goal information is unavailable; recovery stays limited to verified local facts"
success_focus = "the Goal status and first valid repair action within Goal recovery packet explicit state contract / Local Store Degraded"
success_focus_id = "FOCUS-GOALS-RECOVERY-LOCAL-STORE-DEGRADED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review recovery control and failure reason while Goal recovery packet explicit state contract / Local Store Degraded remains visible"
failure_focus_id = "FOCUS-GOALS-RECOVERY-LOCAL-STORE-DEGRADED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-RECOVERY-LOCAL-STORE-DEGRADED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-RECOVERY-NEEDS-ATTENTION"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the object-scoped Goal recovery review. The handoff starts from Goal recovery packet explicit state contract / Needs Attention; effect: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal recovery packet explicit state contract / Needs Attention reports the outcome from this visible condition: The proposed recovery consequence is material or uncertain. The Goal remains unchanged; focus: the Goal status and first valid repair action within Goal recovery packet explicit state contract / Needs Attention."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs. The durable boundary is specific to this visible evidence: The proposed recovery consequence is material or uncertain. The Goal remains unchanged."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The proposed recovery consequence is material or uncertain. The Goal remains unchanged."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: The proposed recovery consequence is material or uncertain. The Goal remains unchanged."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the Goal status and first valid repair action; rejection focuses the Review recovery control and failure reason. The announcement includes this user-facing evidence before focus moves: The proposed recovery consequence is material or uncertain. The Goal remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-RECOVERY-NEEDS-ATTENTION-001"
label = "Review recovery"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The Goal identity, retained Goal/path revision, and failure class are available"]
destination = "the object-scoped Goal recovery review. The handoff starts from Goal recovery packet explicit state contract / Needs Attention"
destination_id = "DEST-GOALS-RECOVERY-NEEDS-ATTENTION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal recovery packet explicit state contract / Needs Attention reports the outcome from this visible condition: The proposed recovery consequence is material or uncertain. The Goal remains unchanged"
success_focus = "the Goal status and first valid repair action within Goal recovery packet explicit state contract / Needs Attention"
success_focus_id = "FOCUS-GOALS-RECOVERY-NEEDS-ATTENTION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review recovery control and failure reason while Goal recovery packet explicit state contract / Needs Attention remains visible"
failure_focus_id = "FOCUS-GOALS-RECOVERY-NEEDS-ATTENTION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-RECOVERY-NEEDS-ATTENTION-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-RECOVERY-OFFLINE-HEALTHY"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal recovery packet explicit state contract / Offline Healthy; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal recovery packet explicit state contract / Offline Healthy reports the outcome from this visible condition: Goal recovery remains available from saved local information without a connection; focus: the Goal identity and lifecycle status within Goal recovery packet explicit state contract / Offline Healthy."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: Goal recovery remains available from saved local information without a connection."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Goal recovery remains available from saved local information without a connection."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: Goal recovery remains available from saved local information without a connection."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: Goal recovery remains available from saved local information without a connection."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-RECOVERY-OFFLINE-HEALTHY-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal recovery packet explicit state contract / Offline Healthy"
destination_id = "DEST-GOALS-RECOVERY-OFFLINE-HEALTHY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal recovery packet explicit state contract / Offline Healthy reports the outcome from this visible condition: Goal recovery remains available from saved local information without a connection"
success_focus = "the Goal identity and lifecycle status within Goal recovery packet explicit state contract / Offline Healthy"
success_focus_id = "FOCUS-GOALS-RECOVERY-OFFLINE-HEALTHY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal recovery packet explicit state contract / Offline Healthy remains visible"
failure_focus_id = "FOCUS-GOALS-RECOVERY-OFFLINE-HEALTHY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-RECOVERY-OFFLINE-HEALTHY-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-RECOVERY-PARTIAL-SCHEDULE-FAILURE"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal recovery packet explicit state contract / Partial Schedule Failure; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal recovery packet explicit state contract / Partial Schedule Failure reports the outcome from this visible condition: Only part of the recovery schedule change succeeded; completed and pending parts stay distinct; focus: the Goal identity and lifecycle status within Goal recovery packet explicit state contract / Partial Schedule Failure."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: Only part of the recovery schedule change succeeded; completed and pending parts stay distinct."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Only part of the recovery schedule change succeeded; completed and pending parts stay distinct."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: Only part of the recovery schedule change succeeded; completed and pending parts stay distinct."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: Only part of the recovery schedule change succeeded; completed and pending parts stay distinct."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-RECOVERY-PARTIAL-SCHEDULE-FAILURE-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal recovery packet explicit state contract / Partial Schedule Failure"
destination_id = "DEST-GOALS-RECOVERY-PARTIAL-SCHEDULE-FAILURE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal recovery packet explicit state contract / Partial Schedule Failure reports the outcome from this visible condition: Only part of the recovery schedule change succeeded; completed and pending parts stay distinct"
success_focus = "the Goal identity and lifecycle status within Goal recovery packet explicit state contract / Partial Schedule Failure"
success_focus_id = "FOCUS-GOALS-RECOVERY-PARTIAL-SCHEDULE-FAILURE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal recovery packet explicit state contract / Partial Schedule Failure remains visible"
failure_focus_id = "FOCUS-GOALS-RECOVERY-PARTIAL-SCHEDULE-FAILURE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-RECOVERY-PARTIAL-SCHEDULE-FAILURE-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-RECOVERY-PROOF-TRANSFERRING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the Goal Proof transfer review. The handoff starts from Goal recovery packet explicit state contract / Proof Transferring; effect: No durable mutation occurs and no Receipt is created; the same Proof identity, relevance, target relationship, and planning consequence are shown; inspection never duplicates evidence or marks target work complete; Goal recovery packet explicit state contract / Proof Transferring reports the outcome from this visible condition: Relevant Proof is being carried into the recovery view without changing its meaning; focus: the original Proof status and proposed target relationship within Goal recovery packet explicit state contract / Proof Transferring."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the same Proof identity, relevance, target relationship, and planning consequence are shown; inspection never duplicates evidence or marks target work complete. The durable boundary is specific to this visible evidence: Relevant Proof is being carried into the recovery view without changing its meaning."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Relevant Proof is being carried into the recovery view without changing its meaning."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: Relevant Proof is being carried into the recovery view without changing its meaning."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the original Proof status and proposed target relationship; rejection focuses the Proof transfer status and Open Goal control. The announcement includes this user-facing evidence before focus moves: Relevant Proof is being carried into the recovery view without changing its meaning."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-RECOVERY-PROOF-TRANSFERRING-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The original Proof identity, source Goal/Step/Closure, proposed target, and current revisions exist"]
destination = "the Goal Proof transfer review. The handoff starts from Goal recovery packet explicit state contract / Proof Transferring"
destination_id = "DEST-GOALS-RECOVERY-PROOF-TRANSFERRING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the same Proof identity, relevance, target relationship, and planning consequence are shown; inspection never duplicates evidence or marks target work complete; Goal recovery packet explicit state contract / Proof Transferring reports the outcome from this visible condition: Relevant Proof is being carried into the recovery view without changing its meaning"
success_focus = "the original Proof status and proposed target relationship within Goal recovery packet explicit state contract / Proof Transferring"
success_focus_id = "FOCUS-GOALS-RECOVERY-PROOF-TRANSFERRING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Proof transfer status and Open Goal control while Goal recovery packet explicit state contract / Proof Transferring remains visible"
failure_focus_id = "FOCUS-GOALS-RECOVERY-PROOF-TRANSFERRING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged; inspection never duplicates evidence or marks target work complete."
recovery_id = "RECOVERY-GOALS-RECOVERY-PROOF-TRANSFERRING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-RECOVERY-RECOVERING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the object-scoped Goal recovery review. The handoff starts from Goal recovery packet explicit state contract / Recovering; effect: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal recovery packet explicit state contract / Recovering reports the outcome from this visible condition: The Goal and Path remain visible while a bounded recovery is prepared; focus: the Goal status and first valid repair action within Goal recovery packet explicit state contract / Recovering."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs. The durable boundary is specific to this visible evidence: The Goal and Path remain visible while a bounded recovery is prepared."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The Goal and Path remain visible while a bounded recovery is prepared."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: The Goal and Path remain visible while a bounded recovery is prepared."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the Goal status and first valid repair action; rejection focuses the Review recovery control and failure reason. The announcement includes this user-facing evidence before focus moves: The Goal and Path remain visible while a bounded recovery is prepared."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-RECOVERY-RECOVERING-001"
label = "Review recovery"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The Goal identity, retained Goal/path revision, and failure class are available"]
destination = "the object-scoped Goal recovery review. The handoff starts from Goal recovery packet explicit state contract / Recovering"
destination_id = "DEST-GOALS-RECOVERY-RECOVERING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goal recovery packet explicit state contract / Recovering reports the outcome from this visible condition: The Goal and Path remain visible while a bounded recovery is prepared"
success_focus = "the Goal status and first valid repair action within Goal recovery packet explicit state contract / Recovering"
success_focus_id = "FOCUS-GOALS-RECOVERY-RECOVERING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review recovery control and failure reason while Goal recovery packet explicit state contract / Recovering remains visible"
failure_focus_id = "FOCUS-GOALS-RECOVERY-RECOVERING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-RECOVERY-RECOVERING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-RECOVERY-SCHEDULE-CONFLICT"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review conflict => destination: the object-scoped Time schedule conflict review. The handoff starts from Goal recovery packet explicit state contract / Schedule Conflict; effect: No durable mutation occurs and no Receipt is created; the schedule placement conflict is shown without moving, completing, pausing, or ending the Goal; Goal recovery packet explicit state contract / Schedule Conflict reports the outcome from this visible condition: The recovery proposal conflicts with protected or fixed time. The saved schedule remains unchanged; focus: the Time conflict heading and affected schedule placement within Goal recovery packet explicit state contract / Schedule Conflict."
durable_effect = "Exact command consequences: Review conflict: No durable mutation occurs and no Receipt is created; the schedule placement conflict is shown without moving, completing, pausing, or ending the Goal. The durable boundary is specific to this visible evidence: The recovery proposal conflicts with protected or fixed time. The saved schedule remains unchanged."
recovery_rollback = "Exact rollback and recovery: Review conflict: No Undo is required; dismissal follows the Goal return anchor with the schedule placement unchanged. Recovery preserves or restores the interface evidence that says: The recovery proposal conflicts with protected or fixed time. The saved schedule remains unchanged."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: The recovery proposal conflicts with protected or fixed time. The saved schedule remains unchanged."
accessibility_focus = "VoiceOver focus contract: Review conflict announces its consequence, then success focuses the Time conflict heading and affected schedule placement; rejection focuses the Goal recovery status and Review conflict control. The announcement includes this user-facing evidence before focus moves: The recovery proposal conflicts with protected or fixed time. The saved schedule remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-RECOVERY-SCHEDULE-CONFLICT-001"
label = "Review conflict"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The Goal, affected schedule placement, revision, and Goal return anchor are retained"]
destination = "the object-scoped Time schedule conflict review. The handoff starts from Goal recovery packet explicit state contract / Schedule Conflict"
destination_id = "DEST-GOALS-RECOVERY-SCHEDULE-CONFLICT-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the schedule placement conflict is shown without moving, completing, pausing, or ending the Goal; Goal recovery packet explicit state contract / Schedule Conflict reports the outcome from this visible condition: The recovery proposal conflicts with protected or fixed time. The saved schedule remains unchanged"
success_focus = "the Time conflict heading and affected schedule placement within Goal recovery packet explicit state contract / Schedule Conflict"
success_focus_id = "FOCUS-GOALS-RECOVERY-SCHEDULE-CONFLICT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Goal recovery status and Review conflict control while Goal recovery packet explicit state contract / Schedule Conflict remains visible"
failure_focus_id = "FOCUS-GOALS-RECOVERY-SCHEDULE-CONFLICT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal follows the Goal return anchor with the schedule placement unchanged."
recovery_id = "RECOVERY-GOALS-RECOVERY-SCHEDULE-CONFLICT-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-RECOVERY-WAITING"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal recovery packet explicit state contract / Waiting; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal recovery packet explicit state contract / Waiting reports the outcome from this visible condition: Recovery is waiting on a named condition; the accepted Goal and Path remain visible; focus: the Goal identity and lifecycle status within Goal recovery packet explicit state contract / Waiting."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: Recovery is waiting on a named condition; the accepted Goal and Path remain visible."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Recovery is waiting on a named condition; the accepted Goal and Path remain visible."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: Recovery is waiting on a named condition; the accepted Goal and Path remain visible."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: Recovery is waiting on a named condition; the accepted Goal and Path remain visible."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-RECOVERY-WAITING-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goal recovery packet explicit state contract / Waiting"
destination_id = "DEST-GOALS-RECOVERY-WAITING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goal recovery packet explicit state contract / Waiting reports the outcome from this visible condition: Recovery is waiting on a named condition; the accepted Goal and Path remain visible"
success_focus = "the Goal identity and lifecycle status within Goal recovery packet explicit state contract / Waiting"
success_focus_id = "FOCUS-GOALS-RECOVERY-WAITING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goal recovery packet explicit state contract / Waiting remains visible"
failure_focus_id = "FOCUS-GOALS-RECOVERY-WAITING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-RECOVERY-WAITING-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-ROOT-DENSE"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Filter => destination: the Goals Root Life Area and Goal filter sheet, then the same collection with an ephemeral filter applied. The handoff starts from Goals root explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; only visible ordering and inclusion change; Goal, path, lifecycle, Proof, and schedule data remain unchanged; Goals root explicit state contract / Dense reports the outcome from this visible condition: Goals contains more active material than fits at once; direction and active Goals remain first; focus: the filtered collection heading and first matching object within Goals root explicit state contract / Dense.\nOpen Goal => destination: the typed Goals Root result resolved by stable result kind, then Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goals root explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goals root explicit state contract / Dense reports the outcome from this visible condition: Goals contains more active material than fits at once; direction and active Goals remain first; focus: the Goal identity and lifecycle status within Goals root explicit state contract / Dense."
durable_effect = "Exact command consequences: Filter: No durable mutation occurs and no Receipt is created; only visible ordering and inclusion change; Goal, path, lifecycle, Proof, and schedule data remain unchanged | Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: Goals contains more active material than fits at once; direction and active Goals remain first."
recovery_rollback = "Exact rollback and recovery: Filter: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Goals contains more active material than fits at once; direction and active Goals remain first."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: Goals contains more active material than fits at once; direction and active Goals remain first."
accessibility_focus = "VoiceOver focus contract: Filter announces its consequence, then success focuses the filtered collection heading and first matching object; rejection focuses the Filter control | Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: Goals contains more active material than fits at once; direction and active Goals remain first."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-ROOT-DENSE-001"
label = "Filter"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The current Goal/Life Area/path collection and filter options are available"]
destination = "the Goals Root Life Area and Goal filter sheet, then the same collection with an ephemeral filter applied. The handoff starts from Goals root explicit state contract / Dense"
destination_id = "DEST-GOALS-ROOT-DENSE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; only visible ordering and inclusion change; Goal, path, lifecycle, Proof, and schedule data remain unchanged; Goals root explicit state contract / Dense reports the outcome from this visible condition: Goals contains more active material than fits at once; direction and active Goals remain first"
success_focus = "the filtered collection heading and first matching object within Goals root explicit state contract / Dense"
success_focus_id = "FOCUS-GOALS-ROOT-DENSE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Filter control while Goals root explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-GOALS-ROOT-DENSE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-ROOT-DENSE-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-ROOT-DENSE-002"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the typed Goals Root result resolved by stable result kind, then Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goals root explicit state contract / Dense"
destination_id = "DEST-GOALS-ROOT-DENSE-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goals root explicit state contract / Dense reports the outcome from this visible condition: Goals contains more active material than fits at once; direction and active Goals remain first"
success_focus = "the Goal identity and lifecycle status within Goals root explicit state contract / Dense"
success_focus_id = "FOCUS-GOALS-ROOT-DENSE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goals root explicit state contract / Dense remains visible"
failure_focus_id = "FOCUS-GOALS-ROOT-DENSE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-ROOT-DENSE-002"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-ROOT-EMPTY-DIRECTION"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goals root explicit state contract / Empty Direction; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goals root explicit state contract / Empty Direction reports the outcome from this visible condition: No active Goal direction is shown yet; the view does not invent one; focus: the Goal identity and lifecycle status within Goals root explicit state contract / Empty Direction."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: No active Goal direction is shown yet; the view does not invent one."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: No active Goal direction is shown yet; the view does not invent one."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: No active Goal direction is shown yet; the view does not invent one."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: No active Goal direction is shown yet; the view does not invent one."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-ROOT-EMPTY-DIRECTION-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goals root explicit state contract / Empty Direction"
destination_id = "DEST-GOALS-ROOT-EMPTY-DIRECTION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goals root explicit state contract / Empty Direction reports the outcome from this visible condition: No active Goal direction is shown yet; the view does not invent one"
success_focus = "the Goal identity and lifecycle status within Goals root explicit state contract / Empty Direction"
success_focus_id = "FOCUS-GOALS-ROOT-EMPTY-DIRECTION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goals root explicit state contract / Empty Direction remains visible"
failure_focus_id = "FOCUS-GOALS-ROOT-EMPTY-DIRECTION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-ROOT-EMPTY-DIRECTION-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-ROOT-NEEDS-ATTENTION"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the object-scoped Goal recovery review. The handoff starts from Goals root explicit state contract / Needs Attention; effect: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goals root explicit state contract / Needs Attention reports the outcome from this visible condition: One or more Goals have an unresolved change. The reason is shown without urgency or score pressure; focus: the Goal status and first valid repair action within Goals root explicit state contract / Needs Attention."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs. The durable boundary is specific to this visible evidence: One or more Goals have an unresolved change. The reason is shown without urgency or score pressure."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: One or more Goals have an unresolved change. The reason is shown without urgency or score pressure."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: One or more Goals have an unresolved change. The reason is shown without urgency or score pressure."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the Goal status and first valid repair action; rejection focuses the Review recovery control and failure reason. The announcement includes this user-facing evidence before focus moves: One or more Goals have an unresolved change. The reason is shown without urgency or score pressure."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-ROOT-NEEDS-ATTENTION-001"
label = "Review recovery"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The Goal identity, retained Goal/path revision, and failure class are available"]
destination = "the object-scoped Goal recovery review. The handoff starts from Goals root explicit state contract / Needs Attention"
destination_id = "DEST-GOALS-ROOT-NEEDS-ATTENTION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; valid choices are Clarify, Retry path, Edit manually, Resolve conflict in Time, Keep unresolved, or Restore previous path; no automatic lifecycle change occurs; Goals root explicit state contract / Needs Attention reports the outcome from this visible condition: One or more Goals have an unresolved change. The reason is shown without urgency or score pressure"
success_focus = "the Goal status and first valid repair action within Goals root explicit state contract / Needs Attention"
success_focus_id = "FOCUS-GOALS-ROOT-NEEDS-ATTENTION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review recovery control and failure reason while Goals root explicit state contract / Needs Attention remains visible"
failure_focus_id = "FOCUS-GOALS-ROOT-NEEDS-ATTENTION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-ROOT-NEEDS-ATTENTION-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-GOALS-ROOT-POPULATED"
requirement_id = "SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Goal => destination: the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goals root explicit state contract / Populated; effect: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goals root explicit state contract / Populated reports the outcome from this visible condition: Goals shows current Life Areas, active Goals, and the next meaningful Step; focus: the Goal identity and lifecycle status within Goals root explicit state contract / Populated."
durable_effect = "Exact command consequences: Open Goal: No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands. The durable boundary is specific to this visible evidence: Goals shows current Life Areas, active Goals, and the next meaningful Step."
recovery_rollback = "Exact rollback and recovery: Open Goal: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Goals shows current Life Areas, active Goals, and the next meaningful Step."
offline_behavior = "Goal, Path, Step, Proof, lifecycle, recovery, and History inspection use local canonical state without an account or network. Offline rendering retains this state evidence: Goals shows current Life Areas, active Goals, and the next meaningful Step."
accessibility_focus = "VoiceOver focus contract: Open Goal announces its consequence, then success focuses the Goal identity and lifecycle status; rejection focuses the initiating Goal row or path node. The announcement includes this user-facing evidence before focus moves: Goals shows current Life Areas, active Goals, and the next meaningful Step."

[[state_command_contracts.commands]]
command_id = "CMD-GOALS-ROOT-POPULATED-001"
label = "Open Goal"
canonical_owner = "surface.goals.command-contract"
preconditions = ["The stable Goal identity and current revision exist"]
destination = "the selected Goal detail with lifecycle, path, Steps, Proof, schedule, Closure, Archive, Trash, and History context. The handoff starts from Goals root explicit state contract / Populated"
destination_id = "DEST-GOALS-ROOT-POPULATED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the Goal opens for inspection; Pause, Resume, End Goal, Archive Goal, Move to Trash, path update, and Proof transfer remain separate consequence-reviewed commands; Goals root explicit state contract / Populated reports the outcome from this visible condition: Goals shows current Life Areas, active Goals, and the next meaningful Step"
success_focus = "the Goal identity and lifecycle status within Goals root explicit state contract / Populated"
success_focus_id = "FOCUS-GOALS-ROOT-POPULATED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the initiating Goal row or path node while Goals root explicit state contract / Populated remains visible"
failure_focus_id = "FOCUS-GOALS-ROOT-POPULATED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
recovery_id = "RECOVERY-GOALS-ROOT-POPULATED-001"
recovery_posture = "current"
recovery_owner = "surface.goals.command-contract"
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001"]
+++

# Goals



## SPEC-SURFACE-GOALS-IDENTITY-001 — Life-area-first direction and path

- **Concept:** `surface.goals.identity`
- **Modality:** `MUST`
- **Scope:** Goals root and Goal depth
- **Status:** `normative`
- **Verification:** `SCENARIO-GOALS-DIRECTION-001`
- **Supersedes:** none

Goals MUST organize direction through editable Life Areas and living Goal Paths, answering what the user is building, where they are on the path, and the next meaningful movement. It must preserve proof, recovery, Future Steps, schedule fit, and closure without exposing runtime architecture.

Goals MUST begin with a living editable Life Area index, open a selected Life
Area, present stable Goal identities within it, reveal an inline Linked Goal
Lens beneath the selected Goal, and then enter a focused continuous pursuit
timeline. The lens preserves Goal ownership and shows at most one consequential
relationship at overview depth. It cannot become a separate root, object owner,
or decorative constellation.

## SPEC-SURFACE-GOALS-ANTI-PATTERNS-001 — No dashboard or project board drift

- **Concept:** `surface.goals.anti-patterns`
- **Modality:** `MUST NOT`
- **Scope:** Goals root, detail, and path presentation
- **Status:** `normative`
- **Verification:** `AUDIT-GOALS-ANTI-DRIFT-001`
- **Supersedes:** none

Goals MUST NOT become a metrics dashboard, project-management board, generic list of projects, Gantt chart, gamified quest, score, streak, badge, or productivity report. Quiet path health may inform an object; it cannot replace the Life Area, Goal, or path.

## SPEC-SURFACE-GOALS-SCREEN-INVENTORY-001 — Owned Goal experience

- **Concept:** `surface.goals.screen-inventory`
- **Modality:** `MUST`
- **Scope:** Goals root and owned drilldowns
- **Status:** `normative`
- **Verification:** `AUDIT-GOALS-ROUTES-001`
- **Supersedes:** none

Goals owns the Life Area index and editing, Life Area detail and Goal membership,
Goal creation/review/activation, Goal detail, inline Linked Goal Lens, full Goal
Path/pursuit timeline, recovery packet, and Goal closure. Time owns calendar and
placement editing; Today owns the day admission/execution projection; Trust owns
contextual Receipt/source/privacy/history inspection; Capture owns global intake.

Goal detail MUST combine native task metadata with Ambitions direction, Proof, and current-Step layers.

The full Goal Path SHOULD use a continuous, scrollable pursuit timeline with an
ordered semantic equivalent.

The horizontal Goal Path MUST snap to nodes, anchor on the current position by default, provide haptic selection feedback, support semantic node types, show selected-node detail, and provide a compact jump control for Start, Now, Next, and Finish.

When a goal reaches completion, Ambitions MUST show a first-class closure surface with final status, completed path, proof moments, recovery segments, remaining open items, schedule cleanup, final receipt, optional reflection, and next suggested direction.

Reviews MUST be both reflective and operational.

## SPEC-SURFACE-GOALS-FIRST-VIEWPORT-001 — Direction before metadata

- **Concept:** `surface.goals.first-viewport`
- **Modality:** `MUST`
- **Scope:** Goals root and Goal detail first viewport
- **Status:** `normative`
- **Verification:** `PROOF-GOALS-FIRST-VIEWPORT-001`
- **Supersedes:** none

Goals first-viewport behavior MUST be owned by the separate root, Goal-detail, and Goal-Path interaction contracts and MUST NOT collapse their independently verifiable states.

## SPEC-SURFACE-GOALS-PURPOSE-001 — Full path that adapts without forcing

- **Concept:** `surface.goals.purpose`
- **Modality:** `MUST`
- **Scope:** Path generation, activation, adaptation, recovery, and closure
- **Status:** `normative`
- **Verification:** `SCENARIO-GOAL-PATH-LIFECYCLE-001`
- **Supersedes:** none

A Goal MUST carry an inspectable route from current reality to closure, including planned and completed Steps, Future Steps, proof, recovery, schedule changes, assumptions, and review points. Vague intent preserves a provisional shell and requests clarification. Material scheduling or path changes require preview and confirmation; no fake confident path or forced choice is allowed.

Goals SHOULD show direction, goal paths, Life Capital relevance, proof, milestones, and progress.

Onboarding progress SHOULD show as a percentage.

## SPEC-SURFACE-GOALS-VISUAL-AUTHORITY-001 — Provisional Goals branch, separate implementation proof

- **Concept:** `surface.goals.visual-authority`
- **Modality:** `MUST`
- **Scope:** Goals and Goal Path visual authority
- **Status:** `normative`
- **Verification:** `PROOF-GOALS-VISUAL-MAPPING-001`
- **Supersedes:** none

Visual mapping MUST use stable direction IDs and distinguish owner-authorized
provisional direction from current implementation behavior and future Figma
authorization. `AVF-GOALS-S08-R00 — Life Area Linked Goal Lens` is the current
provisional structural branch. The earlier VSP-03 package and
`AVF-GOALS-S07-R01` remain historical provenance and do not demonstrate current
SwiftUI, accessibility, device, runtime, Figma, or implementation approval.

The horizontal Goal Path MUST communicate meaning through restrained shape, weight, material, micro-symbol, and line treatment.

## SPEC-SURFACE-GOALS-PATH-VISUAL-001 — Goal Path visual contract

- **Concept:** `surface.goals.path-visual`
- **Modality:** `MUST`
- **Scope:** Goal Path presentation
- **Status:** `normative`
- **Verification:** `REVIEW-GOAL-PATH-VISUAL-001`
- **Supersedes:** none

Goal Path presentation MUST keep current route and next Step legible at rest and reveal chronology, Proof, recovery, schedule change, and adaptation on drilldown.

## SPEC-SURFACE-GOALS-CLOSURE-001 — Goal closure presentation

- **Concept:** `surface.goals.closure`
- **Modality:** `MUST`
- **Scope:** Goals closure controls
- **Status:** `normative`
- **Verification:** `SCENARIO-GOALS-CLOSURE-001`
- **Supersedes:** none

Goals MUST present explicit closure outcomes, consequence preview, Proof requirement or status, rollback, and History without collapsing them into completion.

## SPEC-SURFACE-GOALS-DETAIL-001 — Goals detail

- **Concept:** `surface.goals.detail`
- **Modality:** `MUST`
- **Scope:** Life Area and Goal detail
- **Status:** `normative`
- **Verification:** `SCENARIO-GOALS-DETAIL-001`
- **Supersedes:** none

Goals detail MUST present the selected object, current direction, active relationships, next meaningful Step, Proof or recovery state, path health, and contextual actions.

## SPEC-SURFACE-GOALS-PATH-INTERACTION-001 — Goal Path interaction

- **Concept:** `surface.goals.path-interaction`
- **Modality:** `MUST`
- **Scope:** Goal Path at rest and drilldown
- **Status:** `normative`
- **Verification:** `SCENARIO-GOALS-PATH-INTERACTION-001`
- **Supersedes:** none

Goal Path MUST be useful at rest through current route and next Step, while drilldown reveals chronology, Proof, recovery, schedule change, and adaptation.

## SPEC-SURFACE-GOALS-REVIEWS-001 — Goals reviews

- **Concept:** `surface.goals.reviews`
- **Modality:** `MUST`
- **Scope:** Goal review states
- **Status:** `normative`
- **Verification:** `SCENARIO-GOALS-REVIEWS-001`
- **Supersedes:** none

Goals reviews MUST present due context, affected Goal and path state, recommended user-controlled choices, consequences, deferral, rollback, and History.

## SPEC-SURFACE-GOALS-ROOT-VIEWPORT-001 — Goals root viewport

- **Concept:** `surface.goals.root-viewport`
- **Modality:** `MUST`
- **Scope:** Goals root first viewport
- **Status:** `normative`
- **Verification:** `PROOF-GOALS-ROOT-VIEWPORT-001`
- **Supersedes:** none

The Goals root first viewport MUST foreground the editable Life Area index and
current direction. Selected Life Area depth foregrounds Goal identities; Goal
selection reveals the inline Linked Goal Lens; focused depth foregrounds active,
planned, completed, uncertain, conflict, dense, and very dense pursuit
continuity without converting status into a dashboard.

## SPEC-SURFACE-GOAL-DETAIL-VIEWPORT-001 — Goal detail viewport

- **Concept:** `surface.goal-detail.viewport`
- **Modality:** `MUST`
- **Scope:** Goal detail first viewport
- **Status:** `normative`
- **Verification:** `PROOF-GOAL-DETAIL-VIEWPORT-001`
- **Supersedes:** none

Goal detail first viewport MUST foreground Goal identity before status, Life
Area membership, active Step or multiple active Steps, current route, planned
uncertainty, next movement, Proof or settled completion, schedule fit, and an
inline Linked Goal Lens. Editing remains Goals-owned; Today and Time projections
retain the Goal/Step ID and route back to this owner.

## SPEC-SURFACE-GOALS-COMMAND-CONTRACT-001 — Exact state command ownership

- **Concept:** `surface.goals.command-contract`
- **Modality:** `MUST`
- **Scope:** Structured state command contracts for this specification
- **Status:** `normative`
- **Verification:** `SCENARIO-SURFACE-GOALS-COMMAND-CONTRACT-001`
- **Supersedes:** none

The owning specification MUST authorize only the state-bound command labels `Cancel`, `Filter`, `Open Goal`, `Open archive`, `Open step`, `Review activation`, `Review conflict`, `Review recovery` for the structured states declared in this file. Every command MUST bind stable state and object identity, current revision, canonical owner, preconditions, destination, exact effect and focus targets; navigation, inspection, selection, preview, refresh, and cancellation remain non-mutating. A durable mutation MUST commit only after current-revision validation and required confirmation through Command -> Event -> Projection -> Receipt -> Replay; cancellation or rejection preserves accepted input, and rollback or Undo uses an owning typed command without rewriting history. Local canonical behavior MUST remain available offline without an account; external results remain separate and retryable without replaying the local commit. Sensitive content MUST remain local unless explicit minimum-field egress review passes. VoiceOver MUST announce object, accepted or rejected outcome, consequence, recovery or Undo availability, and destination focus; no color, motion, gesture, or position may carry command meaning alone. Verification MUST prove every declared state, command, transition, commit boundary, durable effect, rollback, offline, privacy, accessibility, and focus mapping against the structured contract.

## Completeness contract

<!-- canon-section: purpose-user-question -->
Goals answers what the user is building, the living path, current position, next meaningful movement, and what proof or recovery still matters.

<!-- canon-section: entry-exit -->
Entry is root selection, Search, Today/Time context, Capture activation, restoration, or deep link. Exit uses root switch, Time handoff, Today handoff, contextual Trust inspection, or native back while preserving selected Life Area, Goal, path node, and focus.

<!-- canon-section: routes-presentation -->
The root is a native Life Area index. Life Area, Goal, path, generated-route review, recovery, and closure use native depth or a focused review presentation. Path selection never creates a parallel root.

<!-- canon-section: displayed-objects -->
Life Areas, Goals, Steps, Future Steps, path nodes, Proof Moments, schedule/adaptive changes, recovery segments, and closure moments are projections of canonical identity. Shape, label, order, and line treatment carry meaning without color alone.

<!-- canon-section: resting-states -->
Required states include empty direction, draft, ready to activate, active, paused, completed, archived, ended, needs attention, recovering, waiting, blocked, populated, dense, and selected-path-node states.

<!-- canon-section: loading-transitional -->
Transition records capture phase, retained Goal/path snapshot, progress, cancellation, and restoration target.
Clarification, route generation, simulation, activation, path adjustment, proof transfer, recovery, closure, and restoration preserve accepted state and expose progress/cancellation where work is not immediate.

<!-- canon-section: empty-degraded -->
Empty Goals invites creation or Capture without fabricated examples. Missing reference context, offline operation, path-generation uncertainty, schedule conflict, partial simulation, or local-store degradation preserves the Goal/draft and offers clarification, retry, manual editing, export, or safe unresolved state.

<!-- canon-section: commands-actions -->
Create, clarify, review, activate, edit, pause, resume, schedule, add proof, recover, close, archive, end, Trash, restore, and inspect route through canonical commands. Horizontal path interaction has ordered node list, jump controls, and explicit actions.

<!-- canon-section: durable-effects -->
Activation, path mutation, schedule placement, proof, recovery, closure, archive, Trash, and restore produce canonical events, projections, receipts, and replay-safe state. Progress transfer preserves context without false completion.

<!-- canon-section: failure-rollback -->
Generation failure keeps original intent and a provisional Goal shell. Material preview rejection leaves state unchanged. Partial schedule failure keeps accepted Goal/path state with visible conflict and recovery. Undo or rollback restores prior path/placement while retaining audit history.

<!-- canon-section: offline -->
Life Areas, Goals, local pathing at available capability, edits, proof, closure, recovery, receipts, history, and replay remain usable without account or network. Missing Source Atlas context cannot trigger private upload or block manual/local planning.

<!-- canon-section: privacy-data-classification -->
Goal intent, path, proof, resources, constraints, schedule fit, Life Capital links, and learning are private local graph data. Minimum-necessary redacted metadata may cross an explicitly approved export/sync boundary; Account and R2 never own the private graph.

<!-- canon-section: accessibility-reading-order -->
The semantic sequence is direction, lifecycle, next movement, proof, schedule fit, path position, and object actions.
VoiceOver orders Life Areas and Goal detail by direction, state, next movement, proof, schedule fit, then path. Goal Path provides an ordered node list with current position, state, rationale, actions, Start/Now/Next/Finish jumps, and filters without requiring horizontal spatial interpretation.

<!-- canon-section: dynamic-type -->
Life Area and Goal content reflows into one-column object-led layouts. Path switches to ordered semantic list where necessary; no node label, action, proof requirement, or consequence is lost.

<!-- canon-section: reduce-motion -->
Path travel, node transforms, activation, recovery, and closure use restrained crossfades or immediate updates while retaining selection, announcements, focus, and continuity semantics.

<!-- canon-section: reduce-transparency -->
Materials become opaque semantic surfaces with equivalent path hierarchy, connection treatment, selection, contrast, and state encoding.

<!-- canon-section: copy-state-language -->
Primary vocabulary presents personal direction and action in calm object terms.
Use plain Goal, Path, Step, Future Step, Proof, Still counts, Waiting, Blocked, Review, and Undo language. Do not expose graph/runtime taxonomy, shame, quest terms, points, levels, AI claims, or productivity scoring.

<!-- canon-section: visual-authority -->
The named package controls geometry, hierarchy, composition, states, and adaptive layout.
Stable package ID `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:177:93` supplies approved Goals design authority. Source rendering, semantic behavior, accessibility/device evidence, implementation parity, and release proof remain separate.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Surfaces/Goals/` owns presentation; `Core/Domain/`, `Core/LocalRuntimeOS/Planning/`, `PrivateLifeRuntimeKernel/`, `Scheduling/`, and `Inspection/` own canonical behavior; `Quality/` owns proof.

<!-- canon-section: tests -->
Tests cover Life Area organization, path generation/clarification, material confirmation, activation, Future Steps, conflict, priority override, proof transfer, recovery, closure, archive/Trash/restore, replay, offline, Goal Path semantic list/actions, Dynamic Type, reduced effects, focus, and non-color encoding.

<!-- canon-section: proof -->
Applicable validation includes path and lifecycle scenarios, receipts/replay, rendered-state matrices for root/detail/path/recovery/closure, VoiceOver behavior, semantic parity, current visual comparison, and rollback.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Goals root, path materialization, selection, and semantic-node lookup MUST remain bounded, cancellable, and deterministically paged; perform no interaction-path network gating or synchronous disk I/O; use no polling or unbounded background loop; and preserve foreground responsiveness under Low Power Mode, thermal pressure, protected-data unavailability, and storage pressure. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. The implementation must define and test a performance-budget record declaring device floor, OS, build configuration, representative Life Area/Goal/path data scale, warm/cold state, measurement tool, percentile/maximum, and regression threshold.

## SPEC-SURFACE-GOALS-EXECUTION-STACK-001 — Goal execution stack

- **Concept:** `surface.goals.execution-stack`
- **Modality:** `MUST`
- **Scope:** Goal execution stack
- **Status:** `normative`
- **Verification:** `REVIEW-SPEC-SURFACE-GOALS-EXECUTION-STACK-001`
- **Supersedes:** none

Goal detail MUST expose current, next scheduled, and unscheduled upcoming Steps, Substep groups, Proof, schedule and recovery state, and actions to inspect, schedule, complete, or revise work linked to the Goal Path.

## SPEC-SURFACE-GOALS-CEBR-BRANCH-001 — Goals explains ways forward

- **Concept:** `surface.goals.cebr-branch`
- **Modality:** `MUST`
- **Scope:** Branch candidates, protections, tradeoffs, and lineage
- **Status:** `normative`
- **Verification:** `SCENARIO-SURFACE-GOALS-CEBR-BRANCH-001`
- **Supersedes:** none

Goals MAY present a branch review inside the owning Goal/Path context. It MUST
show complete candidate consequences, protected and sacrificed conditions,
proof/recovery impact, and lineage while preserving Goal and Goal Path
identity. Candidate review remains non-durable until the user confirms a
canonical command; Goals does not own certificate computation or branch
mutation.
