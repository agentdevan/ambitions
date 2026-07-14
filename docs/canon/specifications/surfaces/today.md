+++
spec_id = "SURFACE-TODAY"
title = "Today"
kind = "surface"
status = "normative"
owner_domain = "surface-today"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "surface.today.command-contract",
  "surface.today.eligibility",
  "surface.today.first-viewport",
  "surface.today.missed-placement-continuity",
  "surface.today.object-row",
  "surface.today.purpose",
  "surface.today.screen-inventory",
  "surface.today.states",
  "surface.today.temporal-rail",
  "surface.today.visual-authority",
]
inherits = [
  "CONST-IA-ROOT-001",
  "SURFACE-TODAY-IDENTITY-001",
  "CONTROL-FORCE-NOTHING-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
  "CONST-PROOF-EVIDENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION"]
source_owners = [
  "Native/Ambitions/Surfaces/Today/",
  "Native/Ambitions/Stage/",
  "Native/Ambitions/DesignSystem/",
  "Native/Ambitions/Core/LocalRuntimeOS/Projections/",
  "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/",
  "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/",
  "Native/Ambitions/Quality/",
]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-DETAIL-ACTIVE-EXECUTION"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open step => destination: the selected stable Step detail. The handoff starts from Today object detail explicit state contract / Active Execution; effect: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today object detail explicit state contract / Active Execution reports the outcome from this visible condition: This Step is in progress. Still counts, Move it, Blocked, Waiting, and Not needed keep its real outcome visible; focus: the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today object detail explicit state contract / Active Execution."
durable_effect = "Exact command consequences: Open step: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged. The durable boundary is specific to this visible evidence: This Step is in progress. Still counts, Move it, Blocked, Waiting, and Not needed keep its real outcome visible."
recovery_rollback = "Exact rollback and recovery: Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Step is in progress. Still counts, Move it, Blocked, Waiting, and Not needed keep its real outcome visible."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: This Step is in progress. Still counts, Move it, Blocked, Waiting, and Not needed keep its real outcome visible."
accessibility_focus = "VoiceOver focus contract: Open step announces its consequence, then success focuses the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading; rejection focuses the initiating Today row or Start here control with a concise reason. The announcement includes this user-facing evidence before focus moves: This Step is in progress. Still counts, Move it, Blocked, Waiting, and Not needed keep its real outcome visible."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-DETAIL-ACTIVE-EXECUTION-001"
label = "Open step"
canonical_owner = "surface.today.command-contract"
preconditions = ["A stable Step identity is present", "The Step revision and Today projection are current"]
destination = "the selected stable Step detail. The handoff starts from Today object detail explicit state contract / Active Execution"
effect = "No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today object detail explicit state contract / Active Execution reports the outcome from this visible condition: This Step is in progress. Still counts, Move it, Blocked, Waiting, and Not needed keep its real outcome visible"
success_focus = "the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today object detail explicit state contract / Active Execution"
failure_focus = "the initiating Today row or Start here control with a concise reason while Today object detail explicit state contract / Active Execution remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-DETAIL-CLOSURE-REVIEW"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Still counts => destination: the Step closure result and proportional Receipt. The handoff starts from Today object detail explicit state contract / Closure Review; effect: The typed Step closure command appends an Event, updates the Projection, and creates a Receipt and History; the Step records the Still counts outcome without score, streak, shame, or  fabricated completion; Today object detail explicit state contract / Closure Review reports the outcome from this visible condition: The selected outcome, any required Proof, and the resulting History entry are visible before Confirm Closure; focus: the resulting Step closure status and Receipt within Today object detail explicit state contract / Closure Review."
durable_effect = "Exact command consequences: Still counts: The typed Step closure command appends an Event, updates the Projection, and creates a Receipt and History; the Step records the Still counts outcome without score, streak, shame, or fabricated completion. The durable boundary is specific to this visible evidence: The selected outcome, any required Proof, and the resulting History entry are visible before Confirm Closure."
recovery_rollback = "Exact rollback and recovery: Still counts: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: The selected outcome, any required Proof, and the resulting History entry are visible before Confirm Closure."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: The selected outcome, any required Proof, and the resulting History entry are visible before Confirm Closure."
accessibility_focus = "VoiceOver focus contract: Still counts announces its consequence, then success focuses the resulting Step closure status and Receipt; rejection focuses the Still counts control and unresolved Proof or validation reason. The announcement includes this user-facing evidence before focus moves: The selected outcome, any required Proof, and the resulting History entry are visible before Confirm Closure."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-DETAIL-CLOSURE-REVIEW-001"
label = "Still counts"
canonical_owner = "surface.today.command-contract"
preconditions = ["Still counts is a valid closure outcome and required Proof is satisfied", "The Step identity and revision are current"]
destination = "the Step closure result and proportional Receipt. The handoff starts from Today object detail explicit state contract / Closure Review"
effect = "The typed Step closure command appends an Event, updates the Projection, and creates a Receipt and History; the Step records the Still counts outcome without score, streak, shame, or  fabricated completion; Today object detail explicit state contract / Closure Review reports the outcome from this visible condition: The selected outcome, any required Proof, and the resulting History entry are visible before Confirm Closure"
success_focus = "the resulting Step closure status and Receipt within Today object detail explicit state contract / Closure Review"
failure_focus = "the Still counts control and unresolved Proof or validation reason while Today object detail explicit state contract / Closure Review remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-DETAIL-RECOVERY"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the object-scoped Today recovery sheet. The handoff starts from Today object detail explicit state contract / Recovery; effect: No durable mutation occurs and no Receipt is created; valid choices are filtered to Move it, Blocked, Waiting, Still counts, Not needed, or  Open step; choosing none preserves the Step; Today object detail explicit state contract / Recovery reports the outcome from this visible condition: The Step was interrupted. Its last saved progress remains visible; focus: the first valid recovery choice for the affected Step within Today object detail explicit state contract / Recovery."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are filtered to Move it, Blocked, Waiting, Still counts, Not needed, or Open step; choosing none preserves the Step. The durable boundary is specific to this visible evidence: The Step was interrupted. Its last saved progress remains visible."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The Step was interrupted. Its last saved progress remains visible."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: The Step was interrupted. Its last saved progress remains visible."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the first valid recovery choice for the affected Step; rejection focuses the initiating recovery control and retained Step status. The announcement includes this user-facing evidence before focus moves: The Step was interrupted. Its last saved progress remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-DETAIL-RECOVERY-001"
label = "Review recovery"
canonical_owner = "surface.today.command-contract"
preconditions = ["The affected Step identity and current recovery reason are available"]
destination = "the object-scoped Today recovery sheet. The handoff starts from Today object detail explicit state contract / Recovery"
effect = "No durable mutation occurs and no Receipt is created; valid choices are filtered to Move it, Blocked, Waiting, Still counts, Not needed, or  Open step; choosing none preserves the Step; Today object detail explicit state contract / Recovery reports the outcome from this visible condition: The Step was interrupted. Its last saved progress remains visible"
success_focus = "the first valid recovery choice for the affected Step within Today object detail explicit state contract / Recovery"
failure_focus = "the initiating recovery control and retained Step status while Today object detail explicit state contract / Recovery remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-DETAIL-STALE-EXTERNAL-CONTEXT"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open step => destination: the selected stable Step detail. The handoff starts from Today object detail explicit state contract / Stale External Context; effect: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today object detail explicit state contract / Stale External Context reports the outcome from this visible condition: Outside context for this Step may be out of date; the saved Step and local plan remain available; focus: the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today object detail explicit state contract / Stale External Context."
durable_effect = "Exact command consequences: Open step: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged. The durable boundary is specific to this visible evidence: Outside context for this Step may be out of date; the saved Step and local plan remain available."
recovery_rollback = "Exact rollback and recovery: Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Outside context for this Step may be out of date; the saved Step and local plan remain available."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: Outside context for this Step may be out of date; the saved Step and local plan remain available."
accessibility_focus = "VoiceOver focus contract: Open step announces its consequence, then success focuses the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading; rejection focuses the initiating Today row or Start here control with a concise reason. The announcement includes this user-facing evidence before focus moves: Outside context for this Step may be out of date; the saved Step and local plan remain available."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-DETAIL-STALE-EXTERNAL-CONTEXT-001"
label = "Open step"
canonical_owner = "surface.today.command-contract"
preconditions = ["A stable Step identity is present", "The Step revision and Today projection are current"]
destination = "the selected stable Step detail. The handoff starts from Today object detail explicit state contract / Stale External Context"
effect = "No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today object detail explicit state contract / Stale External Context reports the outcome from this visible condition: Outside context for this Step may be out of date; the saved Step and local plan remain available"
success_focus = "the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today object detail explicit state contract / Stale External Context"
failure_focus = "the initiating Today row or Start here control with a concise reason while Today object detail explicit state contract / Stale External Context remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-DETAIL-VIEWING"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open step => destination: the selected stable Step detail. The handoff starts from Today object detail explicit state contract / Viewing; effect: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today object detail explicit state contract / Viewing reports the outcome from this visible condition: The Step detail shows why it fits, its saved status, and its time context; focus: the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today object detail explicit state contract / Viewing."
durable_effect = "Exact command consequences: Open step: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged. The durable boundary is specific to this visible evidence: The Step detail shows why it fits, its saved status, and its time context."
recovery_rollback = "Exact rollback and recovery: Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: The Step detail shows why it fits, its saved status, and its time context."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: The Step detail shows why it fits, its saved status, and its time context."
accessibility_focus = "VoiceOver focus contract: Open step announces its consequence, then success focuses the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading; rejection focuses the initiating Today row or Start here control with a concise reason. The announcement includes this user-facing evidence before focus moves: The Step detail shows why it fits, its saved status, and its time context."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-DETAIL-VIEWING-001"
label = "Open step"
canonical_owner = "surface.today.command-contract"
preconditions = ["A stable Step identity is present", "The Step revision and Today projection are current"]
destination = "the selected stable Step detail. The handoff starts from Today object detail explicit state contract / Viewing"
effect = "No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today object detail explicit state contract / Viewing reports the outcome from this visible condition: The Step detail shows why it fits, its saved status, and its time context"
success_focus = "the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today object detail explicit state contract / Viewing"
failure_focus = "the initiating Today row or Start here control with a concise reason while Today object detail explicit state contract / Viewing remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-CONFLICT"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: the object-scoped Time conflict review. The handoff starts from Today Reality Window explicit state contract / Conflict; effect: No durable mutation occurs and no Receipt is created; the placement conflict and protected/fixed/external consequences are shown without moving anything; Today Reality Window explicit state contract / Conflict reports the outcome from this visible condition: A protected, fixed, or  user-owned boundary conflicts with a proposal; no silent move occurs; focus: the Time conflict heading and affected placement within Today Reality Window explicit state contract / Conflict."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; the placement conflict and protected/fixed/external consequences are shown without moving anything. The durable boundary is specific to this visible evidence: A protected, fixed, or user-owned boundary conflicts with a proposal; no silent move occurs."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns through the Today return anchor with the placement unchanged. Recovery preserves or restores the interface evidence that says: A protected, fixed, or user-owned boundary conflicts with a proposal; no silent move occurs."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: A protected, fixed, or user-owned boundary conflicts with a proposal; no silent move occurs."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the Time conflict heading and affected placement; rejection focuses the Today conflict status and Review control. The announcement includes this user-facing evidence before focus moves: A protected, fixed, or user-owned boundary conflicts with a proposal; no silent move occurs."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-CONFLICT-001"
label = "Review"
canonical_owner = "surface.today.command-contract"
preconditions = ["The Step or temporal object identity, placement ID, revision, and Today return anchor are retained"]
destination = "the object-scoped Time conflict review. The handoff starts from Today Reality Window explicit state contract / Conflict"
effect = "No durable mutation occurs and no Receipt is created; the placement conflict and protected/fixed/external consequences are shown without moving anything; Today Reality Window explicit state contract / Conflict reports the outcome from this visible condition: A protected, fixed, or  user-owned boundary conflicts with a proposal; no silent move occurs"
success_focus = "the Time conflict heading and affected placement within Today Reality Window explicit state contract / Conflict"
failure_focus = "the Today conflict status and Review control while Today Reality Window explicit state contract / Conflict remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns through the Today return anchor with the placement unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-DENSE"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open step => destination: the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Dense; effect: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Dense reports the outcome from this visible condition: Today is dense. Protected and fixed reality stays visible; Ambitions does not create urgency / silently move it; focus: the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Dense."
durable_effect = "Exact command consequences: Open step: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged. The durable boundary is specific to this visible evidence: Today is dense. Protected and fixed reality stays visible; Ambitions does not create urgency or silently move it."
recovery_rollback = "Exact rollback and recovery: Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Today is dense. Protected and fixed reality stays visible; Ambitions does not create urgency or silently move it."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: Today is dense. Protected and fixed reality stays visible; Ambitions does not create urgency or silently move it."
accessibility_focus = "VoiceOver focus contract: Open step announces its consequence, then success focuses the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading; rejection focuses the initiating Today row or Start here control with a concise reason. The announcement includes this user-facing evidence before focus moves: Today is dense. Protected and fixed reality stays visible; Ambitions does not create urgency or silently move it."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-DENSE-001"
label = "Open step"
canonical_owner = "surface.today.command-contract"
preconditions = ["A stable Step identity is present", "The Step revision and Today projection are current"]
destination = "the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Dense"
effect = "No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Dense reports the outcome from this visible condition: Today is dense. Protected and fixed reality stays visible; Ambitions does not create urgency / silently move it"
success_focus = "the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Dense"
failure_focus = "the initiating Today row or Start here control with a concise reason while Today Reality Window explicit state contract / Dense remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-DESTRUCTIVE-CONFIRMATION"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Not needed => destination: the surviving Today context with the Step closure result. The handoff starts from Today Reality Window explicit state contract / Destructive Confirmation; effect: The typed Step closure command appends an Event, updates the Projection, and creates a Receipt and History; the Step records Not needed as an honest closure outcome, preserves Goal/History lineage, and does not archive / delete the object; Today Reality Window explicit state contract / Destructive Confirmation reports the outcome from this visible condition: A permanent consequence is displayed for the selected item. The saved item is unchanged; focus: the resulting Step closure status and Receipt within Today Reality Window explicit state contract / Destructive Confirmation."
durable_effect = "Exact command consequences: Not needed: The typed Step closure command appends an Event, updates the Projection, and creates a Receipt and History; the Step records Not needed as an honest closure outcome, preserves Goal/History lineage, and does not archive or delete the object. The durable boundary is specific to this visible evidence: A permanent consequence is displayed for the selected item. The saved item is unchanged."
recovery_rollback = "Exact rollback and recovery: Not needed: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: A permanent consequence is displayed for the selected item. The saved item is unchanged."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: A permanent consequence is displayed for the selected item. The saved item is unchanged."
accessibility_focus = "VoiceOver focus contract: Not needed announces its consequence, then success focuses the resulting Step closure status and Receipt; rejection focuses the Not needed confirmation control and rejection reason. The announcement includes this user-facing evidence before focus moves: A permanent consequence is displayed for the selected item. The saved item is unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-DESTRUCTIVE-CONFIRMATION-001"
label = "Not needed"
canonical_owner = "surface.today.command-contract"
preconditions = ["The Step identity and revision are current", "The exact Not needed consequence has explicit confirmation"]
destination = "the surviving Today context with the Step closure result. The handoff starts from Today Reality Window explicit state contract / Destructive Confirmation"
effect = "The typed Step closure command appends an Event, updates the Projection, and creates a Receipt and History; the Step records Not needed as an honest closure outcome, preserves Goal/History lineage, and does not archive / delete the object; Today Reality Window explicit state contract / Destructive Confirmation reports the outcome from this visible condition: A permanent consequence is displayed for the selected item. The saved item is unchanged"
success_focus = "the resulting Step closure status and Receipt within Today Reality Window explicit state contract / Destructive Confirmation"
failure_focus = "the Not needed confirmation control and rejection reason while Today Reality Window explicit state contract / Destructive Confirmation remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-EMPTY"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open step => destination: the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Empty; effect: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Empty reports the outcome from this visible condition: Nothing fits Start here right now. Ambitions will not invent a Step; Capture, Goals, and Time remain available; focus: the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Empty."
durable_effect = "Exact command consequences: Open step: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged. The durable boundary is specific to this visible evidence: Nothing fits Start here right now. Ambitions will not invent a Step; Capture, Goals, and Time remain available."
recovery_rollback = "Exact rollback and recovery: Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Nothing fits Start here right now. Ambitions will not invent a Step; Capture, Goals, and Time remain available."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: Nothing fits Start here right now. Ambitions will not invent a Step; Capture, Goals, and Time remain available."
accessibility_focus = "VoiceOver focus contract: Open step announces its consequence, then success focuses the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading; rejection focuses the initiating Today row or Start here control with a concise reason. The announcement includes this user-facing evidence before focus moves: Nothing fits Start here right now. Ambitions will not invent a Step; Capture, Goals, and Time remain available."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-EMPTY-001"
label = "Open step"
canonical_owner = "surface.today.command-contract"
preconditions = ["A stable Step identity is present", "The Step revision and Today projection are current"]
destination = "the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Empty"
effect = "No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Empty reports the outcome from this visible condition: Nothing fits Start here right now. Ambitions will not invent a Step; Capture, Goals, and Time remain available"
success_focus = "the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Empty"
failure_focus = "the initiating Today row or Start here control with a concise reason while Today Reality Window explicit state contract / Empty remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-LOADING"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the retained Today projection and initiating focus. The handoff starts from Today Reality Window explicit state contract / Loading; effect: No durable mutation occurs and no Receipt is created; optional loading stops; an accepted mutation continues to its pending Receipt and is never cancelled / hidden; Today Reality Window explicit state contract / Loading reports the outcome from this visible condition: Today is preparing current local reality; the last usable view remains visible; this command preserves accepted product state; focus: the initiating control in the retained projection within Today Reality Window explicit state contract / Loading."
durable_effect = "Exact command consequences: Cancel: No durable mutation occurs and no Receipt is created; optional loading stops; an accepted mutation continues to its pending Receipt and is never cancelled or hidden. The durable boundary is specific to this visible evidence: Today is preparing current local reality; the last usable view remains visible."
recovery_rollback = "Exact rollback and recovery: Cancel: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Today is preparing current local reality; the last usable view remains visible."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: Today is preparing current local reality; the last usable view remains visible."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence, then success focuses the initiating control in the retained projection; rejection focuses the loading status and Cancel control. The announcement includes this user-facing evidence before focus moves: Today is preparing current local reality; the last usable view remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-LOADING-001"
label = "Cancel"
canonical_owner = "surface.today.command-contract"
preconditions = ["Any accepted mutation and pending Receipt are identified separately", "Only optional refresh, simulation, or Proof loading remains cancellable"]
destination = "the retained Today projection and initiating focus. The handoff starts from Today Reality Window explicit state contract / Loading"
effect = "No durable mutation occurs and no Receipt is created; optional loading stops; an accepted mutation continues to its pending Receipt and is never cancelled / hidden; Today Reality Window explicit state contract / Loading reports the outcome from this visible condition: Today is preparing current local reality; the last usable view remains visible; this command preserves accepted product state"
success_focus = "the initiating control in the retained projection within Today Reality Window explicit state contract / Loading"
failure_focus = "the loading status and Cancel control while Today Reality Window explicit state contract / Loading remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-LOW-DENSITY"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open step => destination: the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Low Density; effect: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Low Density reports the outcome from this visible condition: Today has room. Start here remains a humane fit suggestion, not pressure to fill every open space; focus: the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Low Density."
durable_effect = "Exact command consequences: Open step: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged. The durable boundary is specific to this visible evidence: Today has room. Start here remains a humane fit suggestion, not pressure to fill every open space."
recovery_rollback = "Exact rollback and recovery: Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Today has room. Start here remains a humane fit suggestion, not pressure to fill every open space."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: Today has room. Start here remains a humane fit suggestion, not pressure to fill every open space."
accessibility_focus = "VoiceOver focus contract: Open step announces its consequence, then success focuses the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading; rejection focuses the initiating Today row or Start here control with a concise reason. The announcement includes this user-facing evidence before focus moves: Today has room. Start here remains a humane fit suggestion, not pressure to fill every open space."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-LOW-DENSITY-001"
label = "Open step"
canonical_owner = "surface.today.command-contract"
preconditions = ["A stable Step identity is present", "The Step revision and Today projection are current"]
destination = "the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Low Density"
effect = "No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Low Density reports the outcome from this visible condition: Today has room. Start here remains a humane fit suggestion, not pressure to fill every open space"
success_focus = "the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Low Density"
failure_focus = "the initiating Today row or Start here control with a concise reason while Today Reality Window explicit state contract / Low Density remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-OFFLINE-HEALTHY"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open step => destination: the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Offline Healthy; effect: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Offline Healthy reports the outcome from this visible condition: Today remains fully useful from saved local information without a connection; focus: the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Offline Healthy."
durable_effect = "Exact command consequences: Open step: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged. The durable boundary is specific to this visible evidence: Today remains fully useful from saved local information without a connection."
recovery_rollback = "Exact rollback and recovery: Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Today remains fully useful from saved local information without a connection."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: Today remains fully useful from saved local information without a connection."
accessibility_focus = "VoiceOver focus contract: Open step announces its consequence, then success focuses the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading; rejection focuses the initiating Today row or Start here control with a concise reason. The announcement includes this user-facing evidence before focus moves: Today remains fully useful from saved local information without a connection."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-OFFLINE-HEALTHY-001"
label = "Open step"
canonical_owner = "surface.today.command-contract"
preconditions = ["A stable Step identity is present", "The Step revision and Today projection are current"]
destination = "the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Offline Healthy"
effect = "No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Offline Healthy reports the outcome from this visible condition: Today remains fully useful from saved local information without a connection"
success_focus = "the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Offline Healthy"
failure_focus = "the initiating Today row or Start here control with a concise reason while Today Reality Window explicit state contract / Offline Healthy remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-PARTIAL-FAILURE"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review => destination: the narrow object-scoped Today failure review. The handoff starts from Today Reality Window explicit state contract / Partial Failure; effect: No durable mutation occurs and no Receipt is created; the last usable projection remains visible and no unrelated object is changed; Today Reality Window explicit state contract / Partial Failure reports the outcome from this visible condition: Part of Today could not load. Available local facts remain usable; the failed component is named and not fabricated; focus: the affected object failure status within Today Reality Window explicit state contract / Partial Failure."
durable_effect = "Exact command consequences: Review: No durable mutation occurs and no Receipt is created; the last usable projection remains visible and no unrelated object is changed. The durable boundary is specific to this visible evidence: Part of Today could not load. Available local facts remain usable; the failed component is named and not fabricated."
recovery_rollback = "Exact rollback and recovery: Review: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Part of Today could not load. Available local facts remain usable; the failed component is named and not fabricated."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: Part of Today could not load. Available local facts remain usable; the failed component is named and not fabricated."
accessibility_focus = "VoiceOver focus contract: Review announces its consequence, then success focuses the affected object failure status; rejection focuses the Review control and failure reason. The announcement includes this user-facing evidence before focus moves: Part of Today could not load. Available local facts remain usable; the failed component is named and not fabricated."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-PARTIAL-FAILURE-001"
label = "Review"
canonical_owner = "surface.today.command-contract"
preconditions = ["The failed Today projection portion and affected object identity are retained"]
destination = "the narrow object-scoped Today failure review. The handoff starts from Today Reality Window explicit state contract / Partial Failure"
effect = "No durable mutation occurs and no Receipt is created; the last usable projection remains visible and no unrelated object is changed; Today Reality Window explicit state contract / Partial Failure reports the outcome from this visible condition: Part of Today could not load. Available local facts remain usable; the failed component is named and not fabricated"
success_focus = "the affected object failure status within Today Reality Window explicit state contract / Partial Failure"
failure_focus = "the Review control and failure reason while Today Reality Window explicit state contract / Partial Failure remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-PERMISSION-DENIED"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Settings => destination: system Settings for Calendar access. The handoff starts from Today Reality Window explicit state contract / Permission Denied; effect: No durable mutation occurs and no Receipt is created; the app yields to system Settings without changing local Steps / permission state itself; Today Reality Window explicit state contract / Permission Denied reports the outcome from this visible condition: Outside calendar details are unavailable; Today still shows Ambitions-owned reality; focus: the affected Today status after returning from system Settings within Today Reality Window explicit state contract / Permission Denied.\nReview calendar access => destination: the contextual Calendar permission explanation. The handoff starts from Today Reality Window explicit state contract / Permission Denied; effect: No durable mutation occurs and no Receipt is created; the local capability, affected fields, and current calendar permission are shown while Ambitions-owned Steps remain available; Today Reality Window explicit state contract / Permission Denied reports the outcome from this visible condition: Outside calendar details are unavailable; Today still shows Ambitions-owned reality; focus: the calendar permission status within Today Reality Window explicit state contract / Permission Denied."
durable_effect = "Exact command consequences: Open Settings: No durable mutation occurs and no Receipt is created; the app yields to system Settings without changing local Steps or permission state itself | Review calendar access: No durable mutation occurs and no Receipt is created; the local capability, affected fields, and current calendar permission are shown while Ambitions-owned Steps remain available. The durable boundary is specific to this visible evidence: Outside calendar details are unavailable; Today still shows Ambitions-owned reality."
recovery_rollback = "Exact rollback and recovery: Open Settings: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. | Review calendar access: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Outside calendar details are unavailable; Today still shows Ambitions-owned reality."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: Outside calendar details are unavailable; Today still shows Ambitions-owned reality."
accessibility_focus = "VoiceOver focus contract: Open Settings announces its consequence, then success focuses the affected Today status after returning from system Settings; rejection focuses the Open Settings control and current permission explanation | Review calendar access announces its consequence, then success focuses the calendar permission status; rejection focuses the affected Today status and Review calendar access control. The announcement includes this user-facing evidence before focus moves: Outside calendar details are unavailable; Today still shows Ambitions-owned reality."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-PERMISSION-DENIED-001"
label = "Open Settings"
canonical_owner = "surface.today.command-contract"
preconditions = ["Calendar access is denied or restricted", "The user has chosen the system handoff"]
destination = "system Settings for Calendar access. The handoff starts from Today Reality Window explicit state contract / Permission Denied"
effect = "No durable mutation occurs and no Receipt is created; the app yields to system Settings without changing local Steps / permission state itself; Today Reality Window explicit state contract / Permission Denied reports the outcome from this visible condition: Outside calendar details are unavailable; Today still shows Ambitions-owned reality"
success_focus = "the affected Today status after returning from system Settings within Today Reality Window explicit state contract / Permission Denied"
failure_focus = "the Open Settings control and current permission explanation while Today Reality Window explicit state contract / Permission Denied remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "No private Today content is sent; only the system Settings route is opened."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-PERMISSION-DENIED-002"
label = "Review calendar access"
canonical_owner = "surface.today.command-contract"
preconditions = ["Calendar permission status and affected Today fields are known"]
destination = "the contextual Calendar permission explanation. The handoff starts from Today Reality Window explicit state contract / Permission Denied"
effect = "No durable mutation occurs and no Receipt is created; the local capability, affected fields, and current calendar permission are shown while Ambitions-owned Steps remain available; Today Reality Window explicit state contract / Permission Denied reports the outcome from this visible condition: Outside calendar details are unavailable; Today still shows Ambitions-owned reality"
success_focus = "the calendar permission status within Today Reality Window explicit state contract / Permission Denied"
failure_focus = "the affected Today status and Review calendar access control while Today Reality Window explicit state contract / Permission Denied remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-POPULATED"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open step => destination: the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Populated; effect: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Populated reports the outcome from this visible condition: Today shows Start here, current time reality, and the next meaningful Step; focus: the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Populated."
durable_effect = "Exact command consequences: Open step: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged. The durable boundary is specific to this visible evidence: Today shows Start here, current time reality, and the next meaningful Step."
recovery_rollback = "Exact rollback and recovery: Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Today shows Start here, current time reality, and the next meaningful Step."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: Today shows Start here, current time reality, and the next meaningful Step."
accessibility_focus = "VoiceOver focus contract: Open step announces its consequence, then success focuses the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading; rejection focuses the initiating Today row or Start here control with a concise reason. The announcement includes this user-facing evidence before focus moves: Today shows Start here, current time reality, and the next meaningful Step."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-POPULATED-001"
label = "Open step"
canonical_owner = "surface.today.command-contract"
preconditions = ["A stable Step identity is present", "The Step revision and Today projection are current"]
destination = "the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Populated"
effect = "No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Populated reports the outcome from this visible condition: Today shows Start here, current time reality, and the next meaningful Step"
success_focus = "the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Populated"
failure_focus = "the initiating Today row or Start here control with a concise reason while Today Reality Window explicit state contract / Populated remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-RECOVERY"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the object-scoped Today recovery sheet. The handoff starts from Today Reality Window explicit state contract / Recovery; effect: No durable mutation occurs and no Receipt is created; valid choices are filtered to Move it, Blocked, Waiting, Still counts, Not needed, or  Open step; choosing none preserves the Step; Today Reality Window explicit state contract / Recovery reports the outcome from this visible condition: Today preserves the last honest plan while a humane recovery is considered; focus: the first valid recovery choice for the affected Step within Today Reality Window explicit state contract / Recovery."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are filtered to Move it, Blocked, Waiting, Still counts, Not needed, or Open step; choosing none preserves the Step. The durable boundary is specific to this visible evidence: Today preserves the last honest plan while a humane recovery is considered."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Today preserves the last honest plan while a humane recovery is considered."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: Today preserves the last honest plan while a humane recovery is considered."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the first valid recovery choice for the affected Step; rejection focuses the initiating recovery control and retained Step status. The announcement includes this user-facing evidence before focus moves: Today preserves the last honest plan while a humane recovery is considered."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-RECOVERY-001"
label = "Review recovery"
canonical_owner = "surface.today.command-contract"
preconditions = ["The affected Step identity and current recovery reason are available"]
destination = "the object-scoped Today recovery sheet. The handoff starts from Today Reality Window explicit state contract / Recovery"
effect = "No durable mutation occurs and no Receipt is created; valid choices are filtered to Move it, Blocked, Waiting, Still counts, Not needed, or  Open step; choosing none preserves the Step; Today Reality Window explicit state contract / Recovery reports the outcome from this visible condition: Today preserves the last honest plan while a humane recovery is considered"
success_focus = "the first valid recovery choice for the affected Step within Today Reality Window explicit state contract / Recovery"
failure_focus = "the initiating recovery control and retained Step status while Today Reality Window explicit state contract / Recovery remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-RESTORED"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open step => destination: the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Restored; effect: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Restored reports the outcome from this visible condition: Today context restored after interruption and checked against current local reality; focus: the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Restored."
durable_effect = "Exact command consequences: Open step: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged. The durable boundary is specific to this visible evidence: Today context restored after interruption and checked against current local reality."
recovery_rollback = "Exact rollback and recovery: Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Today context restored after interruption and checked against current local reality."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: Today context restored after interruption and checked against current local reality."
accessibility_focus = "VoiceOver focus contract: Open step announces its consequence, then success focuses the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading; rejection focuses the initiating Today row or Start here control with a concise reason. The announcement includes this user-facing evidence before focus moves: Today context restored after interruption and checked against current local reality."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-RESTORED-001"
label = "Open step"
canonical_owner = "surface.today.command-contract"
preconditions = ["A stable Step identity is present", "The Step revision and Today projection are current"]
destination = "the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Restored"
effect = "No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Restored reports the outcome from this visible condition: Today context restored after interruption and checked against current local reality"
success_focus = "the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Restored"
failure_focus = "the initiating Today row or Start here control with a concise reason while Today Reality Window explicit state contract / Restored remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-ROOT-STALE-EXTERNAL-CONTEXT"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open step => destination: the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Stale External Context; effect: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Stale External Context reports the outcome from this visible condition: Outside calendar context may be out of date; local Steps and protected time remain visible; focus: the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Stale External Context."
durable_effect = "Exact command consequences: Open step: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged. The durable boundary is specific to this visible evidence: Outside calendar context may be out of date; local Steps and protected time remain visible."
recovery_rollback = "Exact rollback and recovery: Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: Outside calendar context may be out of date; local Steps and protected time remain visible."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: Outside calendar context may be out of date; local Steps and protected time remain visible."
accessibility_focus = "VoiceOver focus contract: Open step announces its consequence, then success focuses the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading; rejection focuses the initiating Today row or Start here control with a concise reason. The announcement includes this user-facing evidence before focus moves: Outside calendar context may be out of date; local Steps and protected time remain visible."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-ROOT-STALE-EXTERNAL-CONTEXT-001"
label = "Open step"
canonical_owner = "surface.today.command-contract"
preconditions = ["A stable Step identity is present", "The Step revision and Today projection are current"]
destination = "the selected stable Step detail. The handoff starts from Today Reality Window explicit state contract / Stale External Context"
effect = "No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Today Reality Window explicit state contract / Stale External Context reports the outcome from this visible condition: Outside calendar context may be out of date; local Steps and protected time remain visible"
success_focus = "the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Today Reality Window explicit state contract / Stale External Context"
failure_focus = "the initiating Today row or Start here control with a concise reason while Today Reality Window explicit state contract / Stale External Context remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-START-HERE-ACTIVE-EXECUTION"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open step => destination: the selected stable Step detail. The handoff starts from Start here explicit state contract / Active Execution; effect: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Start here explicit state contract / Active Execution reports the outcome from this visible condition: This Step is in progress. Still counts, Move it, Blocked, Waiting, and Not needed describe what happened without score / shame; focus: the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Start here explicit state contract / Active Execution."
durable_effect = "Exact command consequences: Open step: No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged. The durable boundary is specific to this visible evidence: This Step is in progress. Still counts, Move it, Blocked, Waiting, and Not needed describe what happened without score or shame."
recovery_rollback = "Exact rollback and recovery: Open step: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: This Step is in progress. Still counts, Move it, Blocked, Waiting, and Not needed describe what happened without score or shame."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: This Step is in progress. Still counts, Move it, Blocked, Waiting, and Not needed describe what happened without score or shame."
accessibility_focus = "VoiceOver focus contract: Open step announces its consequence, then success focuses the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading; rejection focuses the initiating Today row or Start here control with a concise reason. The announcement includes this user-facing evidence before focus moves: This Step is in progress. Still counts, Move it, Blocked, Waiting, and Not needed describe what happened without score or shame."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-START-HERE-ACTIVE-EXECUTION-001"
label = "Open step"
canonical_owner = "surface.today.command-contract"
preconditions = ["A stable Step identity is present", "The Step revision and Today projection are current"]
destination = "the selected stable Step detail. The handoff starts from Start here explicit state contract / Active Execution"
effect = "No durable mutation occurs and no Receipt is created; the Step opens for inspection and Today, schedule, closure, and Proof data remain unchanged; Start here explicit state contract / Active Execution reports the outcome from this visible condition: This Step is in progress. Still counts, Move it, Blocked, Waiting, and Not needed describe what happened without score / shame"
success_focus = "the Step heading; if the Step vanished, the same Step status near Now, then Start here, then the Now heading within Start here explicit state contract / Active Execution"
failure_focus = "the initiating Today row or Start here control with a concise reason while Start here explicit state contract / Active Execution remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-START-HERE-CLOSURE-READY"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Still counts => destination: the Step closure result and proportional Receipt. The handoff starts from Start here explicit state contract / Closure Ready; effect: The typed Step closure command appends an Event, updates the Projection, and creates a Receipt and History; the Step records the Still counts outcome without score, streak, shame, or  fabricated completion; Start here explicit state contract / Closure Ready reports the outcome from this visible condition: This Step is ready to close. Its closure meaning and any required Proof are visible before Confirm Closure; focus: the resulting Step closure status and Receipt within Start here explicit state contract / Closure Ready."
durable_effect = "Exact command consequences: Still counts: The typed Step closure command appends an Event, updates the Projection, and creates a Receipt and History; the Step records the Still counts outcome without score, streak, shame, or fabricated completion. The durable boundary is specific to this visible evidence: This Step is ready to close. Its closure meaning and any required Proof are visible before Confirm Closure."
recovery_rollback = "Exact rollback and recovery: Still counts: Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact. Recovery preserves or restores the interface evidence that says: This Step is ready to close. Its closure meaning and any required Proof are visible before Confirm Closure."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: This Step is ready to close. Its closure meaning and any required Proof are visible before Confirm Closure."
accessibility_focus = "VoiceOver focus contract: Still counts announces its consequence, then success focuses the resulting Step closure status and Receipt; rejection focuses the Still counts control and unresolved Proof or validation reason. The announcement includes this user-facing evidence before focus moves: This Step is ready to close. Its closure meaning and any required Proof are visible before Confirm Closure."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-START-HERE-CLOSURE-READY-001"
label = "Still counts"
canonical_owner = "surface.today.command-contract"
preconditions = ["Still counts is a valid closure outcome and required Proof is satisfied", "The Step identity and revision are current"]
destination = "the Step closure result and proportional Receipt. The handoff starts from Start here explicit state contract / Closure Ready"
effect = "The typed Step closure command appends an Event, updates the Projection, and creates a Receipt and History; the Step records the Still counts outcome without score, streak, shame, or  fabricated completion; Start here explicit state contract / Closure Ready reports the outcome from this visible condition: This Step is ready to close. Its closure meaning and any required Proof are visible before Confirm Closure"
success_focus = "the resulting Step closure status and Receipt within Start here explicit state contract / Closure Ready"
failure_focus = "the Still counts control and unresolved Proof or validation reason while Start here explicit state contract / Closure Ready remains visible"
commit_boundary = "Mutation: the typed command commits only after current-revision validation, exact consequence review, and any required explicit confirmation."
rollback_undo = "Cancellation before commit changes nothing; after commit, only the named typed Undo or recovery command may append a reversing Event while History remains intact."
privacy_egress = "The mutation remains local and sends no private content off device; any external side effect requires a separate minimum-field egress review under SYSTEM-PRIVACY-EGRESS-001."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TODAY-START-HERE-RECOVERY-NEEDED"
requirement_id = "SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review recovery => destination: the object-scoped Today recovery sheet. The handoff starts from Start here explicit state contract / Recovery Needed; effect: No durable mutation occurs and no Receipt is created; valid choices are filtered to Move it, Blocked, Waiting, Still counts, Not needed, or  Open step; choosing none preserves the Step; Start here explicit state contract / Recovery Needed reports the outcome from this visible condition: A started Step was interrupted. Its last saved progress remains visible while recovery choices are shown; focus: the first valid recovery choice for the affected Step within Start here explicit state contract / Recovery Needed."
durable_effect = "Exact command consequences: Review recovery: No durable mutation occurs and no Receipt is created; valid choices are filtered to Move it, Blocked, Waiting, Still counts, Not needed, or Open step; choosing none preserves the Step. The durable boundary is specific to this visible evidence: A started Step was interrupted. Its last saved progress remains visible while recovery choices are shown."
recovery_rollback = "Exact rollback and recovery: Review recovery: No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged. Recovery preserves or restores the interface evidence that says: A started Step was interrupted. Its last saved progress remains visible while recovery choices are shown."
offline_behavior = "Today and Step inspection, closure, recovery, and retained projections remain available from local canonical state without an account or network; external facts stay separately labeled. Offline rendering retains this state evidence: A started Step was interrupted. Its last saved progress remains visible while recovery choices are shown."
accessibility_focus = "VoiceOver focus contract: Review recovery announces its consequence, then success focuses the first valid recovery choice for the affected Step; rejection focuses the initiating recovery control and retained Step status. The announcement includes this user-facing evidence before focus moves: A started Step was interrupted. Its last saved progress remains visible while recovery choices are shown."

[[state_command_contracts.commands]]
command_id = "CMD-TODAY-START-HERE-RECOVERY-NEEDED-001"
label = "Review recovery"
canonical_owner = "surface.today.command-contract"
preconditions = ["The affected Step identity and current recovery reason are available"]
destination = "the object-scoped Today recovery sheet. The handoff starts from Start here explicit state contract / Recovery Needed"
effect = "No durable mutation occurs and no Receipt is created; valid choices are filtered to Move it, Blocked, Waiting, Still counts, Not needed, or  Open step; choosing none preserves the Step; Start here explicit state contract / Recovery Needed reports the outcome from this visible condition: A started Step was interrupted. Its last saved progress remains visible while recovery choices are shown"
success_focus = "the first valid recovery choice for the affected Step within Start here explicit state contract / Recovery Needed"
failure_focus = "the initiating recovery control and retained Step status while Start here explicit state contract / Recovery Needed remains visible"
commit_boundary = "Non-mutating: the route, inspection, selection, preview, refresh, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal returns to the initiating object or control with accepted data unchanged."
privacy_egress = "The operation reads only local canonical data and sends no private content off device."
verification_ids = ["SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001"]
+++

# Today

This shadow specification defines the intended Today surface.

## SPEC-SURFACE-TODAY-PURPOSE-001 — Reality around now

- **Concept:** `surface.today.purpose`
- **Modality:** `MUST`
- **Scope:** Today root identity
- **Status:** `normative`
- **Verification:** `SCENARIO-TODAY-REALITY-001`
- **Supersedes:** none

Today MUST remain an object-led reality surface answering what reality can hold around now and what the user should act on next. It must not become a generic agenda, task backlog, dashboard, recommendation feed, full calendar, or CTA stack. The temporal rail supports this identity; it does not replace it.

Today’s temporal rail MUST NOT replace the object-led current-reality viewport as the primary product identity.



Today SHOULD show today’s schedule and current operating reality.

Today MUST present reality around now rather than a task list or dashboard.

## SPEC-SURFACE-TODAY-TEMPORAL-RAIL-001 — Supporting temporal anatomy

- **Concept:** `surface.today.temporal-rail`
- **Modality:** `MUST`
- **Scope:** Rolling prior and upcoming context
- **Status:** `normative`
- **Verification:** `SCENARIO-TODAY-TEMPORAL-RAIL-001`, `A11Y-TODAY-TEMPORAL-LIST-001`
- **Supersedes:** none

The supporting rail MUST provide a rolling plus-or-minus twenty-four-hour context anchored on Now, expanding meaningful periods and compressing empty stretches. Now is semantically strongest and Next is secondary. Ordered list navigation, date/time headings, jump-to-Now, and explicit object actions MUST provide complete non-spatial access without requiring rail position, drag, or visual distance.

Today’s temporal rail MUST span a rolling 48-hour window, with upward scrolling revealing the prior 24 hours and downward scrolling revealing the next 24 hours.

Today’s rolling `±24-hour` rail MUST remain supporting temporal anatomy and MUST NOT become the primary product identity.

Time order MUST remain the temporal rail’s legibility law.

## SPEC-SURFACE-TODAY-ELIGIBILITY-001 — Execution-relevant projection only

- **Concept:** `surface.today.eligibility`
- **Modality:** `MUST`
- **Scope:** Today projection membership
- **Status:** `normative`
- **Verification:** `TEST-TODAY-ELIGIBILITY-001`, `TEST-TODAY-NO-BACKLOG-001`
- **Supersedes:** none

Today MUST project only execution-relevant scheduled Steps, Reminders, Events, all-day or due items, recovery-eligible flexible work, and at most one earned fit suggestion. It MUST exclude broad backlog, unscheduled Goal inventory, Saved for Later inventory, and unreviewed external candidates.

Today MUST contain only execution-relevant objects, not broad backlog or project inventory.

Today MUST NOT show broad backlog, unscheduled goal inventory, future project lists, or Saved for Later.

## SPEC-SURFACE-TODAY-SCREEN-INVENTORY-001 — Root and owned depth

- **Concept:** `surface.today.screen-inventory`
- **Modality:** `MUST`
- **Scope:** Today root and contextual depth
- **Status:** `normative`
- **Verification:** `AUDIT-TODAY-ROUTES-001`
- **Supersedes:** none

Today owns its root Reality Window, Start here object presentation, supporting temporal rail, compact closure/recovery affordances, and Today-specific empty or degraded states. Object detail, complex rescheduling, recurrence, multi-item adjustment, and long-range editing hand off to their canonical object, Time, Motion, or Trust owners; they do not become duplicate Today stores or routes.

Each Today row MUST have an explicit primary action.

Today MUST use a compact reschedule sheet offering later today, tomorrow, pick time, flexible or Fixed state, and a suggested slot for low-risk single-object changes.

## SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001 — Start here dominates

- **Concept:** `surface.today.first-viewport`
- **Modality:** `MUST`
- **Scope:** First visible and semantic viewport
- **Status:** `normative`
- **Verification:** `PROOF-TODAY-FIRST-VIEWPORT-001`, `A11Y-TODAY-ORDER-001`
- **Supersedes:** none

When available, the first viewport MUST communicate Now, usable capacity, one dominant `Start here` Step or action, protected boundaries, the next fixed point, why the Step fits, and current closure, proof, or recovery state. `Start here` is a real best executable fit, not an enlarged task row. The semantic order presents context, Start here identity and reason, primary action, boundaries, next fixed point, then supporting rail.

Today MUST present one object-led current-reality viewport centered on `Start here`.

Today’s first viewport MUST NOT show a broad backlog, motivational paragraph, score, or multiple suggestion cards.

Today fit suggestions SHOULD be executable and object-aware.

Today SHOULD use one shared object-row system exposing time, object title, primary action, status marker, relevant trust marker, and optional Goal or source context.

## SPEC-SURFACE-TODAY-STATES-001 — Calm complete state set

- **Concept:** `surface.today.states`
- **Modality:** `MUST`
- **Scope:** Resting, transitional, degraded, and recovery states
- **Status:** `normative`
- **Verification:** `SCENARIO-TODAY-STATES-001`
- **Supersedes:** none

Today MUST distinguish loading, low-density, empty, populated, dense, stale external context, offline-healthy, permission denied, conflict, partial failure, recovery, destructive confirmation, and restored state. Empty space remains calm and may offer Capture, View Time, or Review Goals; it MUST NOT be filled with backlog or low-confidence suggestions.

## SPEC-SURFACE-TODAY-VISUAL-AUTHORITY-001 — Approved Today package, separate implementation proof

- **Concept:** `surface.today.visual-authority`
- **Modality:** `MUST`
- **Scope:** Today visual direction, final target, and implementation evidence
- **Status:** `normative`
- **Verification:** `PROOF-TODAY-VISUAL-MAPPING-001`
- **Supersedes:** none

Today visual review MUST use stable external reference IDs and preserve the difference between approved direction, approved final package, and implementation proof. Owner-approved VSP-02 package `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:160:93` is the Today visual target.

## SPEC-SURFACE-TODAY-MISSED-CONTINUITY-001 — Missed time preserves history and current status
- **Concept:** `surface.today.missed-placement-continuity`
- **Modality:** `MUST`
- **Scope:** A Today item that did not happen at its planned time
- **Status:** `normative`
- **Verification:** `SCENARIO-TODAY-MISSED-CONTINUITY-001`
- **Supersedes:** none

Today MUST retain the original placement in inspection, present the object's current status near Now, and offer at most one new-placement suggestion only when the complete fit threshold passes. Missing a time never silently moves the object or erases its prior schedule truth.

## SPEC-SURFACE-TODAY-ROW-001 — Today object row

- **Concept:** `surface.today.object-row`
- **Modality:** `MUST`
- **Scope:** Today object rows
- **Status:** `normative`
- **Verification:** `A11Y-TODAY-ROW-001`
- **Supersedes:** none

A Today object row MUST expose object identity, relevant context and state, primary action, secondary controls, and nonvisual semantics without duplicating Start here authority.

## SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001 — Exact state command ownership

- **Concept:** `surface.today.command-contract`
- **Modality:** `MUST`
- **Scope:** Structured state command contracts for this specification
- **Status:** `normative`
- **Verification:** `SCENARIO-SURFACE-TODAY-COMMAND-CONTRACT-001`
- **Supersedes:** none

The owning specification MUST authorize only the state-bound command labels `Cancel`, `Not needed`, `Open Settings`, `Open step`, `Review`, `Review calendar access`, `Review recovery`, `Still counts` for the structured states declared in this file. Every command MUST bind stable state and object identity, current revision, canonical owner, preconditions, destination, exact effect and focus targets; navigation, inspection, selection, preview, refresh, and cancellation remain non-mutating. A durable mutation MUST commit only after current-revision validation and required confirmation through Command -> Event -> Projection -> Receipt -> Replay; cancellation or rejection preserves accepted input, and rollback or Undo uses an owning typed command without rewriting history. Local canonical behavior MUST remain available offline without an account; external results remain separate and retryable without replaying the local commit. Sensitive content MUST remain local unless explicit minimum-field egress review passes. VoiceOver MUST announce object, accepted or rejected outcome, consequence, recovery or Undo availability, and destination focus; no color, motion, gesture, or position may carry command meaning alone. Verification MUST prove every declared state, command, transition, commit boundary, durable effect, rollback, offline, privacy, accessibility, and focus mapping against the structured contract.

## Completeness contract

<!-- canon-section: purpose-user-question -->
Today answers what reality can hold around now and what to act on next, preserving Intent through Action without becoming a backlog or calendar clone.

<!-- canon-section: entry-exit -->
Entry is root selection, restoration, deep-link handoff, or post-action return. Exit uses another root, native object depth, full-screen Capture/Search, Time handoff, or contextual Trust inspection; return restores Now, selection, and focus.

<!-- canon-section: routes-presentation -->
Today presents at Stage root. Compact reversible actions remain contextual; object depth uses native navigation; complex temporal editing goes to Time; Capture/Search are overlays, never Today children or roots.

<!-- canon-section: displayed-objects -->
Displayed objects retain canonical identity and show time, title, primary action, placement/lifecycle summary, Goal context, and a trust marker only when relevant. Protected and Fixed are anchored; Flexible, Suggested, and recovery states are lighter without using color alone.

<!-- canon-section: resting-states -->
Resting states are empty, low-density, normal, dense, active execution, closure-ready, and recovery-needed, with Now and Start here dominant whenever eligible.

<!-- canon-section: loading-transitional -->
Projection refresh, start, completion, proof handoff, undo, reschedule preview, and restoration preserve the prior usable projection until a validated replacement is ready and announce accepted state changes.

<!-- canon-section: empty-degraded -->
Offline local Today remains usable. Stale external facts are disclosed only when interpretation changes. Permission or projection failure preserves local objects and offers retry, Time, Capture, or diagnostics without fabricating a recommendation.

<!-- canon-section: commands-actions -->
Primary actions adapt to the object and use locked language such as `Start now` and `Open step`. Complete, Still counts, Move it, Blocked, Waiting, Not needed, Protected, Review, and Undo route through canonical commands. Drag has explicit Move/Edit alternatives.

<!-- canon-section: durable-effects -->
Accepted start, placement, completion, closure, proof, recovery, and undo operations follow Command to Event to Projection to Receipt to Replay and update linked Goal Path and Time projections without duplicate identity.

<!-- canon-section: failure-rollback -->
Rejected validation leaves state unchanged and explains the next safe action. Partial or external failure preserves the accepted local intent, exposes receipt status, and offers idempotent retry, undo, or Time-based repair; projection failure falls back to the last valid local state.

<!-- canon-section: offline -->
Eligibility, Start here, start/complete, local proof/closure, receipts, history, and replay work without account or network. Optional external freshness cannot gate local execution.

<!-- canon-section: privacy-data-classification -->
Today uses private local schedule, Goal, proof, recovery, and learned-fit context. Shell, logs, notifications, and visual proof redact sensitive titles and rationale by default; no private graph data goes to Account, R2, Source Atlas, or hosted AI.

<!-- canon-section: accessibility-reading-order -->
VoiceOver exposes ordered Now, Start here reason/state/actions, boundaries, next fixed point, then chronological objects. The rail has list-equivalent navigation, headings, jump controls, custom actions, and verbal adjustment summaries; no spatial-only meaning or action is permitted.

<!-- canon-section: dynamic-type -->
At every supported size, Start here identity/action remains first, rows reflow vertically, reasons and state do not truncate into ambiguity, and the rail may switch to its semantic list without hiding capability.

<!-- canon-section: reduce-motion -->
Object continuity, completion, and rail transitions become restrained fades or immediate state changes while retaining announcements, focus, receipt, and undo semantics.

<!-- canon-section: reduce-transparency -->
Atmosphere and materials resolve to opaque semantic surfaces with equivalent hierarchy, contrast, boundaries, and non-color state encoding.

<!-- canon-section: copy-state-language -->
Use `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, and the locked humane closure vocabulary. Do not expose runtime terms, shame, overdue pressure, AI branding, or productivity scoring.

<!-- canon-section: visual-authority -->
The named package controls geometry, hierarchy, composition, states, and adaptive layout.
Stable package ID `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:160:93` supplies approved Today design authority. It remains distinct from source rendering, accessibility/device evidence, implementation parity, and release proof.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Surfaces/Today/` owns presentation; `Core/LocalRuntimeOS/Projections/`, `PrivateLifeRuntimeKernel/`, and `Scheduling/` own local facts and fit; `Quality/` owns proof.

<!-- canon-section: tests -->
Tests cover eligibility and exclusion, one-suggestion threshold, state matrix, Start here actions, completion/proof/undo/replay, restoration, dense data, offline, stale external facts, VoiceOver order/actions, list equivalence, Dynamic Type, Reduce Motion/Transparency, contrast, and focus.

<!-- canon-section: proof -->
Evidence artifacts bind executed scenarios to exact source revisions and environments.
Required proof includes current-revision scenario logs, receipts/replay evidence, density and accessibility screenshot matrices, semantic action output, focus restoration, independent visual mapping/acceptance, exact commands and exits, and explicit skipped checks. This spec itself proves none of them.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Today projection, refresh, and primary-action work MUST remain bounded and cancellable, perform no interaction-path network gating or synchronous disk I/O, use no polling or unbounded background loop, and preserve foreground responsiveness under Low Power Mode, thermal pressure, protected-data unavailability, and storage pressure. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. Implementation authorization requires an owner-approved performance-registry record declaring device floor, OS, build configuration, representative Today data scale, warm/cold state, measurement tool, percentile/maximum, and regression threshold.
