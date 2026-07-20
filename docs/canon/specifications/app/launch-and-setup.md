+++
spec_id = "APP-LAUNCH-SETUP"
title = "Launch and Progressive Setup"
kind = "app"
status = "normative"
owner_domain = "app-launch-setup"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "account.command-contract",
  "account.launch-commitment",
  "app.launch-setup.command-contract",
  "app.launch.readiness",
  "app.launch.recovery",
  "app.setup.interruption-resume",
  "app.setup.progress",
  "app.setup.progressive-first-use",
  "app.setup.state",
]
inherits = [
  "MISSION-LAUNCH-BAR-001",
  "LAW-OFFLINE-NO-ACCOUNT-001",
  "LAW-ACCOUNT-BOUNDARY-001",
  "CONTROL-FORCE-NOTHING-001",
  "LAW-RUNTIME-DURABLE-SUCCESS-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
  "CONST-PROOF-EVIDENCE-001",
]
depends_on = ["CONSTITUTION", "APP-NAVIGATION"]
source_owners = [
  "Native/Ambitions/App/",
  "Native/Ambitions/DesignSystem/StagePrimitives/SharedUI/",
  "Native/Ambitions/Core/LocalRuntimeOS/Boundary/",
  "Native/Ambitions/Core/LocalRuntimeOS/Repair/",
  "Native/Ambitions/Surfaces/You/",
  "Native/Ambitions/Quality/",
]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the originating Account, launch, or setup context from Account and continuity boundary — Account Identity Only; effect: No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Account Identity Only — An optional account owns identity and entitlement only; private life data remains local.; focus: the Account Identity Only result heading in Account and continuity boundary."
durable_effect = "Exact state consequences: Done: No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Account Identity Only — An optional account owns identity and entitlement only; private life data remains local. Current visible status: Account Identity Only — An optional account owns identity and entitlement only; private life data remains local."
recovery_rollback = "Exact recovery and rollback: Done: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Account Identity Only — An optional account owns identity and entitlement only; private life data remains local."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Account Identity Only — An optional account owns identity and entitlement only; private life data remains local."
accessibility_focus = "VoiceOver focus contract: Done announces its consequence; success focuses the Account Identity Only result heading in Account and continuity boundary; rejection focuses the Done control and exact failed field in Account and continuity boundary — Account Identity Only. The announcement first communicates: Account Identity Only — An optional account owns identity and entitlement only; private life data remains local."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY-001"
label = "Done"
canonical_owner = "account.command-contract"
preconditions = ["The Account and continuity boundary route and Account Identity Only presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the originating Account, launch, or setup context from Account and continuity boundary — Account Identity Only"
destination_id = "DEST-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Account Identity Only — An optional account owns identity and entitlement only; private life data remains local."
success_focus = "the Account Identity Only result heading in Account and continuity boundary"
success_focus_id = "FOCUS-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and exact failed field in Account and continuity boundary — Account Identity Only"
failure_focus_id = "FOCUS-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-BOUNDARY-CONTINUITY-CONFLICTED"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Done => destination: the originating Account, launch, or setup context from Account and continuity boundary — Continuity Conflicted; effect: No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Two continuity copies disagree on some saved fields. This device keeps its saved information unchanged while the difference is shown.; focus: the Continuity Conflicted result heading in Account and continuity boundary."
durable_effect = "Exact state consequences: Done: No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Two continuity copies disagree on some saved fields. This device keeps its saved information unchanged while the difference is shown. Current visible status: Two continuity copies disagree on some saved fields. This device keeps its saved information unchanged while the difference is shown."
recovery_rollback = "Exact recovery and rollback: Done: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Two continuity copies disagree on some saved fields. This device keeps its saved information unchanged while the difference is shown."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Two continuity copies disagree on some saved fields. This device keeps its saved information unchanged while the difference is shown."
accessibility_focus = "VoiceOver focus contract: Done announces its consequence; success focuses the Continuity Conflicted result heading in Account and continuity boundary; rejection focuses the Done control and exact failed field in Account and continuity boundary — Continuity Conflicted. The announcement first communicates: Two continuity copies disagree on some saved fields. This device keeps its saved information unchanged while the difference is shown."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-BOUNDARY-CONTINUITY-CONFLICTED-001"
label = "Done"
canonical_owner = "account.command-contract"
preconditions = ["The Account and continuity boundary route and Continuity Conflicted presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the originating Account, launch, or setup context from Account and continuity boundary — Continuity Conflicted"
destination_id = "DEST-ACCOUNT-BOUNDARY-CONTINUITY-CONFLICTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Two continuity copies disagree on some saved fields. This device keeps its saved information unchanged while the difference is shown."
success_focus = "the Continuity Conflicted result heading in Account and continuity boundary"
success_focus_id = "FOCUS-ACCOUNT-BOUNDARY-CONTINUITY-CONFLICTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and exact failed field in Account and continuity boundary — Continuity Conflicted"
failure_focus_id = "FOCUS-ACCOUNT-BOUNDARY-CONTINUITY-CONFLICTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-ACCOUNT-BOUNDARY-CONTINUITY-CONFLICTED-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-BOUNDARY-CONTINUITY-DISABLED"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the originating Account, launch, or setup context from Account and continuity boundary — Continuity Disabled; effect: No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Continuity is off. This device keeps the latest saved information available.; focus: the Continuity Disabled result heading in Account and continuity boundary."
durable_effect = "Exact state consequences: Done: No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Continuity is off. This device keeps the latest saved information available. Current visible status: Continuity is off. This device keeps the latest saved information available."
recovery_rollback = "Exact recovery and rollback: Done: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Continuity is off. This device keeps the latest saved information available."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Continuity is off. This device keeps the latest saved information available."
accessibility_focus = "VoiceOver focus contract: Done announces its consequence; success focuses the Continuity Disabled result heading in Account and continuity boundary; rejection focuses the Done control and exact failed field in Account and continuity boundary — Continuity Disabled. The announcement first communicates: Continuity is off. This device keeps the latest saved information available."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-BOUNDARY-CONTINUITY-DISABLED-001"
label = "Done"
canonical_owner = "account.command-contract"
preconditions = ["The Account and continuity boundary route and Continuity Disabled presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the originating Account, launch, or setup context from Account and continuity boundary — Continuity Disabled"
destination_id = "DEST-ACCOUNT-BOUNDARY-CONTINUITY-DISABLED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Continuity is off. This device keeps the latest saved information available."
success_focus = "the Continuity Disabled result heading in Account and continuity boundary"
success_focus_id = "FOCUS-ACCOUNT-BOUNDARY-CONTINUITY-DISABLED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and exact failed field in Account and continuity boundary — Continuity Disabled"
failure_focus_id = "FOCUS-ACCOUNT-BOUNDARY-CONTINUITY-DISABLED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-ACCOUNT-BOUNDARY-CONTINUITY-DISABLED-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-BOUNDARY-LOCAL-ONLY"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue Without an Account => destination: the usable local Ambitions core from Account and continuity boundary — Local Only; effect: No durable mutation occurs and no Receipt is created; Continue Without an Account changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Ambitions works without an account. Goals, Captures, time, and preferences stay on this device.; focus: the Local Only result heading in Account and continuity boundary."
durable_effect = "Exact state consequences: Continue Without an Account: No durable mutation occurs and no Receipt is created; Continue Without an Account changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Ambitions works without an account. Goals, Captures, time, and preferences stay on this device. Current visible status: Ambitions works without an account. Goals, Captures, time, and preferences stay on this device."
recovery_rollback = "Exact recovery and rollback: Continue Without an Account: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Ambitions works without an account. Goals, Captures, time, and preferences stay on this device."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Ambitions works without an account. Goals, Captures, time, and preferences stay on this device."
accessibility_focus = "VoiceOver focus contract: Continue Without an Account announces its consequence; success focuses the Local Only result heading in Account and continuity boundary; rejection focuses the Continue Without an Account control and exact failed field in Account and continuity boundary — Local Only. The announcement first communicates: Ambitions works without an account. Goals, Captures, time, and preferences stay on this device."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-BOUNDARY-LOCAL-ONLY-001"
label = "Continue Without an Account"
canonical_owner = "account.command-contract"
preconditions = ["The Account and continuity boundary route and Local Only presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the usable local Ambitions core from Account and continuity boundary — Local Only"
destination_id = "DEST-ACCOUNT-BOUNDARY-LOCAL-ONLY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Continue Without an Account changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Ambitions works without an account. Goals, Captures, time, and preferences stay on this device."
success_focus = "the Local Only result heading in Account and continuity boundary"
success_focus_id = "FOCUS-ACCOUNT-BOUNDARY-LOCAL-ONLY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue Without an Account control and exact failed field in Account and continuity boundary — Local Only"
failure_focus_id = "FOCUS-ACCOUNT-BOUNDARY-LOCAL-ONLY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-ACCOUNT-BOUNDARY-LOCAL-ONLY-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-SIGN-IN-APPLE-IN-PROGRESS"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the unchanged provider or setup choice from Optional sign in — Apple In Progress; effect: No durable mutation occurs and no Receipt is created; Cancel preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Sign in with Apple is in progress. Information saved on this device remains unchanged.; focus: the Apple In Progress result heading in Optional sign in."
durable_effect = "Exact state consequences: Cancel: No durable mutation occurs and no Receipt is created; Cancel preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Sign in with Apple is in progress. Information saved on this device remains unchanged. Current visible status: Sign in with Apple is in progress. Information saved on this device remains unchanged."
recovery_rollback = "Exact recovery and rollback: Cancel: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Sign in with Apple is in progress. Information saved on this device remains unchanged."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Sign in with Apple is in progress. Information saved on this device remains unchanged."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence; success focuses the Apple In Progress result heading in Optional sign in; rejection focuses the Cancel control and exact failed field in Optional sign in — Apple In Progress. The announcement first communicates: Sign in with Apple is in progress. Information saved on this device remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-SIGN-IN-APPLE-IN-PROGRESS-001"
label = "Cancel"
canonical_owner = "account.command-contract"
preconditions = ["The Optional sign in route and Apple In Progress presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the unchanged provider or setup choice from Optional sign in — Apple In Progress"
destination_id = "DEST-ACCOUNT-SIGN-IN-APPLE-IN-PROGRESS-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Cancel preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Sign in with Apple is in progress. Information saved on this device remains unchanged."
success_focus = "the Apple In Progress result heading in Optional sign in"
success_focus_id = "FOCUS-ACCOUNT-SIGN-IN-APPLE-IN-PROGRESS-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Cancel control and exact failed field in Optional sign in — Apple In Progress"
failure_focus_id = "FOCUS-ACCOUNT-SIGN-IN-APPLE-IN-PROGRESS-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-ACCOUNT-SIGN-IN-APPLE-IN-PROGRESS-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-SIGN-IN-CANCELLED"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Try Again => destination: the exact failed provider or launch readiness operation from Optional sign in — Cancelled; effect: The external Try Again result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Sign-in was cancelled. Saved Goals, Captures, time, and settings remain available.; focus: the Cancelled result heading in Optional sign in."
durable_effect = "Exact state consequences: Try Again: The external Try Again result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Sign-in was cancelled. Saved Goals, Captures, time, and settings remain available. Current visible status: Sign-in was cancelled. Saved Goals, Captures, time, and settings remain available."
recovery_rollback = "Exact recovery and rollback: Try Again: Cancellation or rejection preserves the last confirmed local state; retry cannot replay an accepted local Event or duplicate provider identity. Recovery preserves this user-visible evidence: Sign-in was cancelled. Saved Goals, Captures, time, and settings remain available."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Sign-in was cancelled. Saved Goals, Captures, time, and settings remain available."
accessibility_focus = "VoiceOver focus contract: Try Again announces its consequence; success focuses the Cancelled result heading in Optional sign in; rejection focuses the Try Again control and exact failed field in Optional sign in — Cancelled. The announcement first communicates: Sign-in was cancelled. Saved Goals, Captures, time, and settings remain available."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-SIGN-IN-CANCELLED-001"
label = "Try Again"
canonical_owner = "account.command-contract"
preconditions = ["The Optional sign in route and Cancelled presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated", "The user explicitly selected the named identity provider"]
destination = "the exact failed provider or launch readiness operation from Optional sign in — Cancelled"
destination_id = "DEST-ACCOUNT-SIGN-IN-CANCELLED-001"
destination_posture = "current"
effect = "The external Try Again result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Sign-in was cancelled. Saved Goals, Captures, time, and settings remain available."
success_focus = "the Cancelled result heading in Optional sign in"
success_focus_id = "FOCUS-ACCOUNT-SIGN-IN-CANCELLED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Try Again control and exact failed field in Optional sign in — Cancelled"
failure_focus_id = "FOCUS-ACCOUNT-SIGN-IN-CANCELLED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: provider or system work completes outside the canonical mutation boundary and must be revalidated before any later local commit."
rollback_undo = "Cancellation or rejection preserves the last confirmed local state; retry cannot replay an accepted local Event or duplicate provider identity."
recovery_id = "RECOVERY-ACCOUNT-SIGN-IN-CANCELLED-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "Provider egress is limited to minimum identity and authentication fields; the private life graph never leaves the device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-SIGN-IN-FAILED"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Try Again => destination: the exact failed provider or launch readiness operation from Optional sign in — Failed; effect: The external Try Again result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Failed — Provider sign-in failed without creating an account or changing local private data.; focus: the Failed result heading in Optional sign in."
durable_effect = "Exact state consequences: Try Again: The external Try Again result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Failed — Provider sign-in failed without creating an account or changing local private data. Current visible status: Failed — Provider sign-in failed without creating an account or changing local private data."
recovery_rollback = "Exact recovery and rollback: Try Again: Cancellation or rejection preserves the last confirmed local state; retry cannot replay an accepted local Event or duplicate provider identity. Recovery preserves this user-visible evidence: Failed — Provider sign-in failed without creating an account or changing local private data."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Failed — Provider sign-in failed without creating an account or changing local private data."
accessibility_focus = "VoiceOver focus contract: Try Again announces its consequence; success focuses the Failed result heading in Optional sign in; rejection focuses the Try Again control and exact failed field in Optional sign in — Failed. The announcement first communicates: Failed — Provider sign-in failed without creating an account or changing local private data."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-SIGN-IN-FAILED-001"
label = "Try Again"
canonical_owner = "account.command-contract"
preconditions = ["The Optional sign in route and Failed presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated", "The user explicitly selected the named identity provider"]
destination = "the exact failed provider or launch readiness operation from Optional sign in — Failed"
destination_id = "DEST-ACCOUNT-SIGN-IN-FAILED-001"
destination_posture = "current"
effect = "The external Try Again result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Failed — Provider sign-in failed without creating an account or changing local private data."
success_focus = "the Failed result heading in Optional sign in"
success_focus_id = "FOCUS-ACCOUNT-SIGN-IN-FAILED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Try Again control and exact failed field in Optional sign in — Failed"
failure_focus_id = "FOCUS-ACCOUNT-SIGN-IN-FAILED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: provider or system work completes outside the canonical mutation boundary and must be revalidated before any later local commit."
rollback_undo = "Cancellation or rejection preserves the last confirmed local state; retry cannot replay an accepted local Event or duplicate provider identity."
recovery_id = "RECOVERY-ACCOUNT-SIGN-IN-FAILED-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "Provider egress is limited to minimum identity and authentication fields; the private life graph never leaves the device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-SIGN-IN-GOOGLE-IN-PROGRESS"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the unchanged provider or setup choice from Optional sign in — Google In Progress; effect: No durable mutation occurs and no Receipt is created; Cancel preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Google sign-in is in progress. Information saved on this device remains unchanged.; focus: the Google In Progress result heading in Optional sign in."
durable_effect = "Exact state consequences: Cancel: No durable mutation occurs and no Receipt is created; Cancel preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Google sign-in is in progress. Information saved on this device remains unchanged. Current visible status: Google sign-in is in progress. Information saved on this device remains unchanged."
recovery_rollback = "Exact recovery and rollback: Cancel: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Google sign-in is in progress. Information saved on this device remains unchanged."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Google sign-in is in progress. Information saved on this device remains unchanged."
accessibility_focus = "VoiceOver focus contract: Cancel announces its consequence; success focuses the Google In Progress result heading in Optional sign in; rejection focuses the Cancel control and exact failed field in Optional sign in — Google In Progress. The announcement first communicates: Google sign-in is in progress. Information saved on this device remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-SIGN-IN-GOOGLE-IN-PROGRESS-001"
label = "Cancel"
canonical_owner = "account.command-contract"
preconditions = ["The Optional sign in route and Google In Progress presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the unchanged provider or setup choice from Optional sign in — Google In Progress"
destination_id = "DEST-ACCOUNT-SIGN-IN-GOOGLE-IN-PROGRESS-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Cancel preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Google sign-in is in progress. Information saved on this device remains unchanged."
success_focus = "the Google In Progress result heading in Optional sign in"
success_focus_id = "FOCUS-ACCOUNT-SIGN-IN-GOOGLE-IN-PROGRESS-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Cancel control and exact failed field in Optional sign in — Google In Progress"
failure_focus_id = "FOCUS-ACCOUNT-SIGN-IN-GOOGLE-IN-PROGRESS-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-ACCOUNT-SIGN-IN-GOOGLE-IN-PROGRESS-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-SIGN-IN-PROVIDER-CHOICE"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Sign in with Apple => destination: the native Sign in with Apple provider sheet from Optional sign in — Provider Choice; effect: The external Sign in with Apple result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Apple and Google sign-in choices are shown. Saved information remains available without an account.; focus: the Provider Choice result heading in Optional sign in.\nSign in with Google => destination: the native Google sign-in provider sheet from Optional sign in — Provider Choice; effect: The external Sign in with Google result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Apple and Google sign-in choices are shown. Saved information remains available without an account.; focus: the Provider Choice result heading in Optional sign in."
durable_effect = "Exact state consequences: Sign in with Apple: The external Sign in with Apple result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Apple and Google sign-in choices are shown. Saved information remains available without an account. | Sign in with Google: The external Sign in with Google result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Apple and Google sign-in choices are shown. Saved information remains available without an account. Current visible status: Apple and Google sign-in choices are shown. Saved information remains available without an account."
recovery_rollback = "Exact recovery and rollback: Sign in with Apple: Cancellation or rejection preserves the last confirmed local state; retry cannot replay an accepted local Event or duplicate provider identity. | Sign in with Google: Cancellation or rejection preserves the last confirmed local state; retry cannot replay an accepted local Event or duplicate provider identity. Recovery preserves this user-visible evidence: Apple and Google sign-in choices are shown. Saved information remains available without an account."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Apple and Google sign-in choices are shown. Saved information remains available without an account."
accessibility_focus = "VoiceOver focus contract: Sign in with Apple announces its consequence; success focuses the Provider Choice result heading in Optional sign in; rejection focuses the Sign in with Apple control and exact failed field in Optional sign in — Provider Choice | Sign in with Google announces its consequence; success focuses the Provider Choice result heading in Optional sign in; rejection focuses the Sign in with Google control and exact failed field in Optional sign in — Provider Choice. The announcement first communicates: Apple and Google sign-in choices are shown. Saved information remains available without an account."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-SIGN-IN-PROVIDER-CHOICE-001"
label = "Sign in with Apple"
canonical_owner = "account.command-contract"
preconditions = ["The Optional sign in route and Provider Choice presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated", "The user explicitly selected the named identity provider"]
destination = "the native Sign in with Apple provider sheet from Optional sign in — Provider Choice"
destination_id = "DEST-ACCOUNT-SIGN-IN-PROVIDER-CHOICE-001"
destination_posture = "current"
effect = "The external Sign in with Apple result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Apple and Google sign-in choices are shown. Saved information remains available without an account."
success_focus = "the Provider Choice result heading in Optional sign in"
success_focus_id = "FOCUS-ACCOUNT-SIGN-IN-PROVIDER-CHOICE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Sign in with Apple control and exact failed field in Optional sign in — Provider Choice"
failure_focus_id = "FOCUS-ACCOUNT-SIGN-IN-PROVIDER-CHOICE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: provider or system work completes outside the canonical mutation boundary and must be revalidated before any later local commit."
rollback_undo = "Cancellation or rejection preserves the last confirmed local state; retry cannot replay an accepted local Event or duplicate provider identity."
recovery_id = "RECOVERY-ACCOUNT-SIGN-IN-PROVIDER-CHOICE-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "Provider egress is limited to minimum identity and authentication fields; the private life graph never leaves the device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-SIGN-IN-PROVIDER-CHOICE-002"
label = "Sign in with Google"
canonical_owner = "account.command-contract"
preconditions = ["The Optional sign in route and Provider Choice presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated", "The user explicitly selected the named identity provider"]
destination = "the native Google sign-in provider sheet from Optional sign in — Provider Choice"
destination_id = "DEST-ACCOUNT-SIGN-IN-PROVIDER-CHOICE-002"
destination_posture = "current"
effect = "The external Sign in with Google result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Apple and Google sign-in choices are shown. Saved information remains available without an account."
success_focus = "the Provider Choice result heading in Optional sign in"
success_focus_id = "FOCUS-ACCOUNT-SIGN-IN-PROVIDER-CHOICE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Sign in with Google control and exact failed field in Optional sign in — Provider Choice"
failure_focus_id = "FOCUS-ACCOUNT-SIGN-IN-PROVIDER-CHOICE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: provider or system work completes outside the canonical mutation boundary and must be revalidated before any later local commit."
rollback_undo = "Cancellation or rejection preserves the last confirmed local state; retry cannot replay an accepted local Event or duplicate provider identity."
recovery_id = "RECOVERY-ACCOUNT-SIGN-IN-PROVIDER-CHOICE-002"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "Provider egress is limited to minimum identity and authentication fields; the private life graph never leaves the device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-SIGN-IN-SIGNED-IN"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the originating Account, launch, or setup context from Optional sign in — Signed In; effect: No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Signed In — Optional account identity is active and its approved boundary is explicit.; focus: the Signed In result heading in Optional sign in."
durable_effect = "Exact state consequences: Done: No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Signed In — Optional account identity is active and its approved boundary is explicit. Current visible status: Signed In — Optional account identity is active and its approved boundary is explicit."
recovery_rollback = "Exact recovery and rollback: Done: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Signed In — Optional account identity is active and its approved boundary is explicit."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Signed In — Optional account identity is active and its approved boundary is explicit."
accessibility_focus = "VoiceOver focus contract: Done announces its consequence; success focuses the Signed In result heading in Optional sign in; rejection focuses the Done control and exact failed field in Optional sign in — Signed In. The announcement first communicates: Signed In — Optional account identity is active and its approved boundary is explicit."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-SIGN-IN-SIGNED-IN-001"
label = "Done"
canonical_owner = "account.command-contract"
preconditions = ["The Optional sign in route and Signed In presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the originating Account, launch, or setup context from Optional sign in — Signed In"
destination_id = "DEST-ACCOUNT-SIGN-IN-SIGNED-IN-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Signed In — Optional account identity is active and its approved boundary is explicit."
success_focus = "the Signed In result heading in Optional sign in"
success_focus_id = "FOCUS-ACCOUNT-SIGN-IN-SIGNED-IN-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and exact failed field in Optional sign in — Signed In"
failure_focus_id = "FOCUS-ACCOUNT-SIGN-IN-SIGNED-IN-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-ACCOUNT-SIGN-IN-SIGNED-IN-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-STATUS-CONTINUITY-DISABLED"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the originating Account, launch, or setup context from Account and Sync status — Continuity Disabled; effect: No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Continuity is off. Signed-in account details and information saved on this device remain available.; focus: the Continuity Disabled result heading in Account and Sync status."
durable_effect = "Exact state consequences: Done: No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Continuity is off. Signed-in account details and information saved on this device remain available. Current visible status: Continuity is off. Signed-in account details and information saved on this device remain available."
recovery_rollback = "Exact recovery and rollback: Done: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Continuity is off. Signed-in account details and information saved on this device remain available."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Continuity is off. Signed-in account details and information saved on this device remain available."
accessibility_focus = "VoiceOver focus contract: Done announces its consequence; success focuses the Continuity Disabled result heading in Account and Sync status; rejection focuses the Done control and exact failed field in Account and Sync status — Continuity Disabled. The announcement first communicates: Continuity is off. Signed-in account details and information saved on this device remain available."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-STATUS-CONTINUITY-DISABLED-001"
label = "Done"
canonical_owner = "account.command-contract"
preconditions = ["The Account and Sync status route and Continuity Disabled presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the originating Account, launch, or setup context from Account and Sync status — Continuity Disabled"
destination_id = "DEST-ACCOUNT-STATUS-CONTINUITY-DISABLED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Continuity is off. Signed-in account details and information saved on this device remain available."
success_focus = "the Continuity Disabled result heading in Account and Sync status"
success_focus_id = "FOCUS-ACCOUNT-STATUS-CONTINUITY-DISABLED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and exact failed field in Account and Sync status — Continuity Disabled"
failure_focus_id = "FOCUS-ACCOUNT-STATUS-CONTINUITY-DISABLED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-ACCOUNT-STATUS-CONTINUITY-DISABLED-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-STATUS-SIGNED-IN"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Sign Out => destination: the signed-out Local Only account status from Account and Sync status — Signed In; effect: A typed Sign Out Command validates the current account revision, appends an Event, updates the account Projection, and creates a Receipt and History entry; local Goals, Captures, Time, settings, Proof, and Receipts remain retained. Visible evidence remains: You are signed in. Your account details are current, and saved personal information remains available on this device.; focus: the Signed In result heading in Account and Sync status."
durable_effect = "Exact state consequences: Sign Out: A typed Sign Out Command validates the current account revision, appends an Event, updates the account Projection, and creates a Receipt and History entry; local Goals, Captures, Time, settings, Proof, and Receipts remain retained. Visible evidence remains: You are signed in. Your account details are current, and saved personal information remains available on this device. Current visible status: You are signed in. Your account details are current, and saved personal information remains available on this device."
recovery_rollback = "Exact recovery and rollback: Sign Out: Before commit, cancellation changes nothing; after commit, account recovery uses a separately authorized typed command and Receipt, while sign-out never deletes local data. Recovery preserves this user-visible evidence: You are signed in. Your account details are current, and saved personal information remains available on this device."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: You are signed in. Your account details are current, and saved personal information remains available on this device."
accessibility_focus = "VoiceOver focus contract: Sign Out announces its consequence; success focuses the Signed In result heading in Account and Sync status; rejection focuses the Sign Out control and exact failed field in Account and Sync status — Signed In. The announcement first communicates: You are signed in. Your account details are current, and saved personal information remains available on this device."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-STATUS-SIGNED-IN-001"
label = "Sign Out"
canonical_owner = "account.command-contract"
preconditions = ["The Account and Sync status route and Signed In presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the signed-out Local Only account status from Account and Sync status — Signed In"
destination_id = "DEST-ACCOUNT-STATUS-SIGNED-IN-001"
destination_posture = "current"
effect = "A typed Sign Out Command validates the current account revision, appends an Event, updates the account Projection, and creates a Receipt and History entry; local Goals, Captures, Time, settings, Proof, and Receipts remain retained. Visible evidence remains: You are signed in. Your account details are current, and saved personal information remains available on this device."
success_focus = "the Signed In result heading in Account and Sync status"
success_focus_id = "FOCUS-ACCOUNT-STATUS-SIGNED-IN-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Sign Out control and exact failed field in Account and Sync status — Signed In"
failure_focus_id = "FOCUS-ACCOUNT-STATUS-SIGNED-IN-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the typed Command commits only after current-revision validation through Event, Projection, Receipt, History, and replay-safe ownership."
rollback_undo = "Before commit, cancellation changes nothing; after commit, account recovery uses a separately authorized typed command and Receipt, while sign-out never deletes local data."
recovery_id = "RECOVERY-ACCOUNT-STATUS-SIGNED-IN-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "owner_recovery_handoff"
recovery_handoff_command_id = "CMD-ACCOUNT-STATUS-SIGNED-IN-001-RECOVERY-HANDOFF"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-ACCOUNT-STATUS-SIGNED-IN-001"
mechanism_kind = "recovery_handoff_command"
command_id = "CMD-ACCOUNT-STATUS-SIGNED-IN-001-RECOVERY-HANDOFF"
label = "Review recovery"
canonical_owner = "account.command-contract"
preconditions = ["CMD-ACCOUNT-STATUS-SIGNED-IN-001 is the exact trigger command and its exact trigger Receipt is current", "The signed-out account revision, retained local-data inventory, and failed recovery scope are current"]
destination = "Account and Sync status with the signed-out revision, retained local-data inventory, and exact Sign Out Receipt visible for account recovery review"
destination_id = "DEST-ACCOUNT-STATUS-SIGNED-IN-001-RECOVERY-HANDOFF"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the exact trigger Receipt and scope route only to account.command-contract for Sign Out recovery review, with the signed-out account posture and retained local Goals, Captures, Time, settings, Proof, and Receipts unchanged."
success_focus = "the Sign Out recovery heading followed by the retained local-data summary and first separately authorized account-recovery action"
success_focus_id = "FOCUS-ACCOUNT-STATUS-SIGNED-IN-001-RECOVERY-HANDOFF-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Sign Out recovery control and exact account-route failure; the exact trigger Receipt and scope remain visible and unchanged"
failure_focus_id = "FOCUS-ACCOUNT-STATUS-SIGNED-IN-001-RECOVERY-HANDOFF-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: routing and inspection complete without a canonical Event, Projection change, or new Receipt."
rollback_undo = "No Undo is required; dismissal returns to the exact trigger result with canonical state, Receipt, and History unchanged."
recovery_id = "RECOVERY-ACCOUNT-STATUS-SIGNED-IN-001-RECOVERY-HANDOFF"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "The handoff reads only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-ACCOUNT-STATUS-SIGNED-OUT"
requirement_id = "APP-ACCOUNT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the originating Account, launch, or setup context from Account and Sync status — Signed Out; effect: No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: No account is signed in. Saved Goals, Captures, time, and settings remain available.; focus: the Signed Out result heading in Account and Sync status."
durable_effect = "Exact state consequences: Done: No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: No account is signed in. Saved Goals, Captures, time, and settings remain available. Current visible status: No account is signed in. Saved Goals, Captures, time, and settings remain available."
recovery_rollback = "Exact recovery and rollback: Done: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: No account is signed in. Saved Goals, Captures, time, and settings remain available."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: No account is signed in. Saved Goals, Captures, time, and settings remain available."
accessibility_focus = "VoiceOver focus contract: Done announces its consequence; success focuses the Signed Out result heading in Account and Sync status; rejection focuses the Done control and exact failed field in Account and Sync status — Signed Out. The announcement first communicates: No account is signed in. Saved Goals, Captures, time, and settings remain available."

[[state_command_contracts.commands]]
command_id = "CMD-ACCOUNT-STATUS-SIGNED-OUT-001"
label = "Done"
canonical_owner = "account.command-contract"
preconditions = ["The Account and Sync status route and Signed Out presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the originating Account, launch, or setup context from Account and Sync status — Signed Out"
destination_id = "DEST-ACCOUNT-STATUS-SIGNED-OUT-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done preserves accepted canonical state and changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: No account is signed in. Saved Goals, Captures, time, and settings remain available."
success_focus = "the Signed Out result heading in Account and Sync status"
success_focus_id = "FOCUS-ACCOUNT-STATUS-SIGNED-OUT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and exact failed field in Account and Sync status — Signed Out"
failure_focus_id = "FOCUS-ACCOUNT-STATUS-SIGNED-OUT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-ACCOUNT-STATUS-SIGNED-OUT-001"
recovery_posture = "current"
recovery_owner = "account.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-LAUNCH-GATE-CHECKING-LOCAL-READINESS"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Diagnostics => destination: the redacted local Diagnostics inspection from Application launch readiness gate — Checking Local Readiness; effect: No durable mutation occurs and no Receipt is created; Open Diagnostics changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Ambitions is checking saved local information before opening the app.; focus: the Checking Local Readiness result heading in Application launch readiness gate."
durable_effect = "Exact state consequences: Open Diagnostics: No durable mutation occurs and no Receipt is created; Open Diagnostics changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Ambitions is checking saved local information before opening the app. Current visible status: Ambitions is checking saved local information before opening the app."
recovery_rollback = "Exact recovery and rollback: Open Diagnostics: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Ambitions is checking saved local information before opening the app."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Ambitions is checking saved local information before opening the app."
accessibility_focus = "VoiceOver focus contract: Open Diagnostics announces its consequence; success focuses the Checking Local Readiness result heading in Application launch readiness gate; rejection focuses the Open Diagnostics control and exact failed field in Application launch readiness gate — Checking Local Readiness. The announcement first communicates: Ambitions is checking saved local information before opening the app."

[[state_command_contracts.commands]]
command_id = "CMD-APP-LAUNCH-GATE-CHECKING-LOCAL-READINESS-001"
label = "Open Diagnostics"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Application launch readiness gate route and Checking Local Readiness presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the redacted local Diagnostics inspection from Application launch readiness gate — Checking Local Readiness"
destination_id = "DEST-APP-LAUNCH-GATE-CHECKING-LOCAL-READINESS-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Open Diagnostics changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Ambitions is checking saved local information before opening the app."
success_focus = "the Checking Local Readiness result heading in Application launch readiness gate"
success_focus_id = "FOCUS-APP-LAUNCH-GATE-CHECKING-LOCAL-READINESS-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open Diagnostics control and exact failed field in Application launch readiness gate — Checking Local Readiness"
failure_focus_id = "FOCUS-APP-LAUNCH-GATE-CHECKING-LOCAL-READINESS-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-APP-LAUNCH-GATE-CHECKING-LOCAL-READINESS-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-LAUNCH-GATE-QUARANTINED"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Diagnostics => destination: the redacted local Diagnostics inspection from Application launch readiness gate — Quarantined; effect: No durable mutation occurs and no Receipt is created; Open Diagnostics changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Some local information cannot be used safely. Other saved information remains available and unchanged.; focus: the Quarantined result heading in Application launch readiness gate."
durable_effect = "Exact state consequences: Open Diagnostics: No durable mutation occurs and no Receipt is created; Open Diagnostics changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Some local information cannot be used safely. Other saved information remains available and unchanged. Current visible status: Some local information cannot be used safely. Other saved information remains available and unchanged."
recovery_rollback = "Exact recovery and rollback: Open Diagnostics: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Some local information cannot be used safely. Other saved information remains available and unchanged."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Some local information cannot be used safely. Other saved information remains available and unchanged."
accessibility_focus = "VoiceOver focus contract: Open Diagnostics announces its consequence; success focuses the Quarantined result heading in Application launch readiness gate; rejection focuses the Open Diagnostics control and exact failed field in Application launch readiness gate — Quarantined. The announcement first communicates: Some local information cannot be used safely. Other saved information remains available and unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-APP-LAUNCH-GATE-QUARANTINED-001"
label = "Open Diagnostics"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Application launch readiness gate route and Quarantined presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the redacted local Diagnostics inspection from Application launch readiness gate — Quarantined"
destination_id = "DEST-APP-LAUNCH-GATE-QUARANTINED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Open Diagnostics changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Some local information cannot be used safely. Other saved information remains available and unchanged."
success_focus = "the Quarantined result heading in Application launch readiness gate"
success_focus_id = "FOCUS-APP-LAUNCH-GATE-QUARANTINED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open Diagnostics control and exact failed field in Application launch readiness gate — Quarantined"
failure_focus_id = "FOCUS-APP-LAUNCH-GATE-QUARANTINED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-APP-LAUNCH-GATE-QUARANTINED-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-LAUNCH-GATE-READY"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the Today root with ready local data from Application launch readiness gate — Ready; effect: No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Ambitions is ready. Saved Goals, Captures, time, and settings are available.; focus: the Ready result heading in Application launch readiness gate."
durable_effect = "Exact state consequences: Continue: No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Ambitions is ready. Saved Goals, Captures, time, and settings are available. Current visible status: Ambitions is ready. Saved Goals, Captures, time, and settings are available."
recovery_rollback = "Exact recovery and rollback: Continue: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Ambitions is ready. Saved Goals, Captures, time, and settings are available."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Ambitions is ready. Saved Goals, Captures, time, and settings are available."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence; success focuses the Ready result heading in Application launch readiness gate; rejection focuses the Continue control and exact failed field in Application launch readiness gate — Ready. The announcement first communicates: Ambitions is ready. Saved Goals, Captures, time, and settings are available."

[[state_command_contracts.commands]]
command_id = "CMD-APP-LAUNCH-GATE-READY-001"
label = "Continue"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Application launch readiness gate route and Ready presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the Today root with ready local data from Application launch readiness gate — Ready"
destination_id = "DEST-APP-LAUNCH-GATE-READY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Ambitions is ready. Saved Goals, Captures, time, and settings are available."
success_focus = "the Ready result heading in Application launch readiness gate"
success_focus_id = "FOCUS-APP-LAUNCH-GATE-READY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact failed field in Application launch readiness gate — Ready"
failure_focus_id = "FOCUS-APP-LAUNCH-GATE-READY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-APP-LAUNCH-GATE-READY-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-LAUNCH-GATE-REPAIR-REQUIRED"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Repair => destination: the bounded repair preview from Application launch readiness gate — Repair Required; effect: No durable mutation occurs and no Receipt is created; Review Repair changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Saved information needs a safe repair before this part of Ambitions can open.; focus: the Repair Required result heading in Application launch readiness gate."
durable_effect = "Exact state consequences: Review Repair: No durable mutation occurs and no Receipt is created; Review Repair changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Saved information needs a safe repair before this part of Ambitions can open. Current visible status: Saved information needs a safe repair before this part of Ambitions can open."
recovery_rollback = "Exact recovery and rollback: Review Repair: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Saved information needs a safe repair before this part of Ambitions can open."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Saved information needs a safe repair before this part of Ambitions can open."
accessibility_focus = "VoiceOver focus contract: Review Repair announces its consequence; success focuses the Repair Required result heading in Application launch readiness gate; rejection focuses the Review Repair control and exact failed field in Application launch readiness gate — Repair Required. The announcement first communicates: Saved information needs a safe repair before this part of Ambitions can open."

[[state_command_contracts.commands]]
command_id = "CMD-APP-LAUNCH-GATE-REPAIR-REQUIRED-001"
label = "Review Repair"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Application launch readiness gate route and Repair Required presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the bounded repair preview from Application launch readiness gate — Repair Required"
destination_id = "DEST-APP-LAUNCH-GATE-REPAIR-REQUIRED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Repair changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Saved information needs a safe repair before this part of Ambitions can open."
success_focus = "the Repair Required result heading in Application launch readiness gate"
success_focus_id = "FOCUS-APP-LAUNCH-GATE-REPAIR-REQUIRED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Repair control and exact failed field in Application launch readiness gate — Repair Required"
failure_focus_id = "FOCUS-APP-LAUNCH-GATE-REPAIR-REQUIRED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-APP-LAUNCH-GATE-REPAIR-REQUIRED-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-LAUNCH-GATE-RETRYABLE-DELAY"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Try Again => destination: the exact failed provider or launch readiness operation from Application launch readiness gate — Retryable Delay; effect: No durable mutation occurs and no Receipt is created; Try Again changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Opening is taking longer than expected; saved information remains protected.; focus: the Retryable Delay result heading in Application launch readiness gate."
durable_effect = "Exact state consequences: Try Again: No durable mutation occurs and no Receipt is created; Try Again changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Opening is taking longer than expected; saved information remains protected. Current visible status: Opening is taking longer than expected; saved information remains protected."
recovery_rollback = "Exact recovery and rollback: Try Again: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Opening is taking longer than expected; saved information remains protected."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Opening is taking longer than expected; saved information remains protected."
accessibility_focus = "VoiceOver focus contract: Try Again announces its consequence; success focuses the Retryable Delay result heading in Application launch readiness gate; rejection focuses the Try Again control and exact failed field in Application launch readiness gate — Retryable Delay. The announcement first communicates: Opening is taking longer than expected; saved information remains protected."

[[state_command_contracts.commands]]
command_id = "CMD-APP-LAUNCH-GATE-RETRYABLE-DELAY-001"
label = "Try Again"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Application launch readiness gate route and Retryable Delay presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the exact failed provider or launch readiness operation from Application launch readiness gate — Retryable Delay"
destination_id = "DEST-APP-LAUNCH-GATE-RETRYABLE-DELAY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Try Again changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Opening is taking longer than expected; saved information remains protected."
success_focus = "the Retryable Delay result heading in Application launch readiness gate"
success_focus_id = "FOCUS-APP-LAUNCH-GATE-RETRYABLE-DELAY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Try Again control and exact failed field in Application launch readiness gate — Retryable Delay"
failure_focus_id = "FOCUS-APP-LAUNCH-GATE-RETRYABLE-DELAY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-APP-LAUNCH-GATE-RETRYABLE-DELAY-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-LAUNCH-GATE-STOP-SHIP-DATA-RISK"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Export Data => destination: the reviewed local export destination chooser from Application launch readiness gate — Stop Ship Data Risk; effect: The external Export Data result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Local data needs attention before Ambitions can open safely.; focus: the Stop Ship Data Risk result heading in Application launch readiness gate."
durable_effect = "Exact state consequences: Export Data: The external Export Data result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Local data needs attention before Ambitions can open safely. Current visible status: Local data needs attention before Ambitions can open safely."
recovery_rollback = "Exact recovery and rollback: Export Data: Cancellation or rejection preserves the last confirmed local state; retry cannot replay an accepted local Event or duplicate provider identity. Recovery preserves this user-visible evidence: Local data needs attention before Ambitions can open safely."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Local data needs attention before Ambitions can open safely."
accessibility_focus = "VoiceOver focus contract: Export Data announces its consequence; success focuses the Stop Ship Data Risk result heading in Application launch readiness gate; rejection focuses the Export Data control and exact failed field in Application launch readiness gate — Stop Ship Data Risk. The announcement first communicates: Local data needs attention before Ambitions can open safely."

[[state_command_contracts.commands]]
command_id = "CMD-APP-LAUNCH-GATE-STOP-SHIP-DATA-RISK-001"
label = "Export Data"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Application launch readiness gate route and Stop Ship Data Risk presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the reviewed local export destination chooser from Application launch readiness gate — Stop Ship Data Risk"
destination_id = "DEST-APP-LAUNCH-GATE-STOP-SHIP-DATA-RISK-001"
destination_posture = "current"
effect = "The external Export Data result causes no local canonical mutation; accepted local data and the last confirmed account or readiness state remain unchanged. Visible evidence remains: Local data needs attention before Ambitions can open safely."
success_focus = "the Stop Ship Data Risk result heading in Application launch readiness gate"
success_focus_id = "FOCUS-APP-LAUNCH-GATE-STOP-SHIP-DATA-RISK-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Export Data control and exact failed field in Application launch readiness gate — Stop Ship Data Risk"
failure_focus_id = "FOCUS-APP-LAUNCH-GATE-STOP-SHIP-DATA-RISK-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: provider or system work completes outside the canonical mutation boundary and must be revalidated before any later local commit."
rollback_undo = "Cancellation or rejection preserves the last confirmed local state; retry cannot replay an accepted local Event or duplicate provider identity."
recovery_id = "RECOVERY-APP-LAUNCH-GATE-STOP-SHIP-DATA-RISK-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SETUP-FIRST-USE-IN-PROGRESS"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the next incomplete setup chapter from Progressive first use — In Progress; effect: No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup is in progress; completed local choices remain saved if the user leaves.; focus: the In Progress result heading in Progressive first use.\nBack => destination: the prior canonical setup chapter and its first relevant field; effect: No durable mutation occurs and no Receipt is created; Back changes only navigation and preserves every accepted answer and checkpoint; focus: the prior chapter heading and first unanswered or invalid field.\nSkip Setup for Now => destination: the local core with setup marked revisitable; effect: The typed Skip Setup for Now command appends one Event, updates the owning Projection, records a Receipt, and preserves History; only the resumable setup checkpoint is marked skipped-for-now and accepted answers remain intact; focus: the local core heading and unobtrusive Resume Setup route.\nSkip This Chapter => destination: the next canonical setup chapter or sufficient-for-local-use result; effect: The typed Skip This Chapter command appends one Event, updates the owning Projection, records a Receipt, and preserves History; only the current chapter skip marker is recorded and every accepted answer remains revisitable; focus: the next chapter heading or sufficient-for-local-use result.\nSkip This Question => destination: the next canonical setup question or chapter; effect: The typed Skip This Question command appends one Event, updates the owning Projection, records a Receipt, and preserves History; only the current question skip marker is recorded and no answer is inferred; focus: the next question or chapter heading."
durable_effect = "Exact state consequences: Continue: No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup is in progress; completed local choices remain saved if the user leaves. Current visible status: Setup is in progress; completed local choices remain saved if the user leaves."
recovery_rollback = "Exact recovery and rollback: Continue: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Setup is in progress; completed local choices remain saved if the user leaves."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Setup is in progress; completed local choices remain saved if the user leaves."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence; success focuses the In Progress result heading in Progressive first use; rejection focuses the Continue control and exact failed field in Progressive first use — In Progress. The announcement first communicates: Setup is in progress; completed local choices remain saved if the user leaves."

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-001"
label = "Continue"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Progressive first use route and In Progress presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the next incomplete setup chapter from Progressive first use — In Progress"
destination_id = "DEST-SETUP-FIRST-USE-IN-PROGRESS-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup is in progress; completed local choices remain saved if the user leaves."
success_focus = "the In Progress result heading in Progressive first use"
success_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact failed field in Progressive first use — In Progress"
failure_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-SETUP-FIRST-USE-IN-PROGRESS-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-002"
label = "Back"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["A prior canonical setup chapter exists", "Accepted answers and the current checkpoint revision remain available"]
destination = "the prior canonical setup chapter and its first relevant field"
destination_id = "DEST-SETUP-FIRST-USE-IN-PROGRESS-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Back changes only navigation and preserves every accepted answer and checkpoint"
success_focus = "the prior chapter heading and first unanswered or invalid field"
success_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Back control and unchanged current chapter"
failure_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-SETUP-FIRST-USE-IN-PROGRESS-002"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "No egress occurs; private object content, History, Proof, and Receipts remain local."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-003"
label = "Skip Setup for Now"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["Local core readiness does not require completing setup", "The command cannot clear or fabricate an accepted answer", "The current setup checkpoint revision is valid"]
destination = "the local core with setup marked revisitable"
destination_id = "DEST-SETUP-FIRST-USE-IN-PROGRESS-003"
destination_posture = "current"
effect = "The typed Skip Setup for Now command appends one Event, updates the owning Projection, records a Receipt, and preserves History; only the resumable setup checkpoint is marked skipped-for-now and accepted answers remain intact"
success_focus = "the local core heading and unobtrusive Resume Setup route"
success_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Skip Setup for Now control and exact checkpoint reason"
failure_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "Resume Setup is the typed inverse command and reopens the preserved checkpoint without rewriting History."
recovery_id = "RECOVERY-SETUP-FIRST-USE-IN-PROGRESS-003"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "No egress occurs; private object content, History, Proof, and Receipts remain local."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "checkpoint_restore"
checkpoint_id = "CHECKPOINT-SETUP-FIRST-USE-IN-PROGRESS-003"

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-004"
label = "Skip This Chapter"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The command cannot clear or fabricate any accepted answer", "The current chapter identity and checkpoint revision are valid", "The next canonical chapter exists or setup can become sufficient for local use"]
destination = "the next canonical setup chapter or sufficient-for-local-use result"
destination_id = "DEST-SETUP-FIRST-USE-IN-PROGRESS-004"
destination_posture = "current"
effect = "The typed Skip This Chapter command appends one Event, updates the owning Projection, records a Receipt, and preserves History; only the current chapter skip marker is recorded and every accepted answer remains revisitable"
success_focus = "the next chapter heading or sufficient-for-local-use result"
success_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Skip This Chapter control and exact checkpoint reason"
failure_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "Returning to the skipped chapter and accepting an answer is the typed inverse command; History retains both decisions."
recovery_id = "RECOVERY-SETUP-FIRST-USE-IN-PROGRESS-004"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "No egress occurs; private object content, History, Proof, and Receipts remain local."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-004-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-004"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-004"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-004-INVERSE"
label = "Undo"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["CMD-SETUP-FIRST-USE-IN-PROGRESS-004 is the exact trigger command and its exact trigger Receipt is current", "The skipped chapter marker, setup checkpoint revision, supplied answer and exact target field, and accepted chapter answers are current, with no newer dependent setup answer"]
destination = "the skipped setup chapter immediately after the supplied answer is accepted, with accepted answers preserved and the inverse Receipt available in setup History"
destination_id = "DEST-SETUP-FIRST-USE-IN-PROGRESS-004-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it atomically clears the exact chapter skip marker and commits the supplied answer to its exact setup field without clearing accepted answers, appends a reversing Event, updates the setup checkpoint Projection, and creates a new inverse Receipt and History entry while the original skip Receipt and History remain intact."
success_focus = "the next unanswered prompt after the committed supplied answer, followed by confirmation that the chapter skip marker cleared and accepted answers were preserved"
success_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-004-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the supplied answer field and exact unsafe, stale, invalid-answer, or dependency-invalid chapter/checkpoint reason; the exact skip marker and trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-004-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: the exact skip marker clear and supplied answer commit occur atomically only after the exact trigger Receipt, current revision, answer validity, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-SETUP-FIRST-USE-IN-PROGRESS-004-INVERSE"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-005"
label = "Skip This Question"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The command cannot clear or fabricate an accepted answer", "The current question identity and checkpoint revision are valid", "The next canonical question or chapter is resolved"]
destination = "the next canonical setup question or chapter"
destination_id = "DEST-SETUP-FIRST-USE-IN-PROGRESS-005"
destination_posture = "current"
effect = "The typed Skip This Question command appends one Event, updates the owning Projection, records a Receipt, and preserves History; only the current question skip marker is recorded and no answer is inferred"
success_focus = "the next question or chapter heading"
success_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-005-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Skip This Question control and exact checkpoint reason"
failure_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-005-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "Returning to the skipped question and accepting an answer is the typed inverse command; History retains both decisions."
recovery_id = "RECOVERY-SETUP-FIRST-USE-IN-PROGRESS-005"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "No egress occurs; private object content, History, Proof, and Receipts remain local."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-005-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-005"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-005"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-SETUP-FIRST-USE-IN-PROGRESS-005-INVERSE"
label = "Undo"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["CMD-SETUP-FIRST-USE-IN-PROGRESS-005 is the exact trigger command and its exact trigger Receipt is current", "The skipped question identity, setup checkpoint revision, supplied answer and exact target field, and absence of an accepted answer are current, with no newer dependent setup answer"]
destination = "the setup sequence immediately after the supplied answer to the exact skipped question is accepted, with the inverse Receipt available in setup History"
destination_id = "DEST-SETUP-FIRST-USE-IN-PROGRESS-005-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it atomically clears the exact question skip marker and commits the supplied answer to its exact setup field without inferring any other answer, appends a reversing Event, updates the setup checkpoint Projection, and creates a new inverse Receipt and History entry while the original skip Receipt and History remain intact."
success_focus = "the next setup question or chapter after the committed supplied answer, followed by confirmation that the question skip marker cleared and no other answer was inferred"
success_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-005-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the supplied answer field and exact unsafe, stale, invalid-answer, or dependency-invalid question/checkpoint reason; the exact skip marker and trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-SETUP-FIRST-USE-IN-PROGRESS-005-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: the exact skip marker clear and supplied answer commit occur atomically only after the exact trigger Receipt, current revision, answer validity, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-SETUP-FIRST-USE-IN-PROGRESS-005-INVERSE"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SETUP-FIRST-USE-NOT-STARTED"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the next incomplete setup chapter from Progressive first use — Not Started; effect: No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup has not started. The local app can still open without an account.; focus: the Not Started result heading in Progressive first use."
durable_effect = "Exact state consequences: Continue: No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup has not started. The local app can still open without an account. Current visible status: Setup has not started. The local app can still open without an account."
recovery_rollback = "Exact recovery and rollback: Continue: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Setup has not started. The local app can still open without an account."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Setup has not started. The local app can still open without an account."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence; success focuses the Not Started result heading in Progressive first use; rejection focuses the Continue control and exact failed field in Progressive first use — Not Started. The announcement first communicates: Setup has not started. The local app can still open without an account."

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-FIRST-USE-NOT-STARTED-001"
label = "Continue"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Progressive first use route and Not Started presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the next incomplete setup chapter from Progressive first use — Not Started"
destination_id = "DEST-SETUP-FIRST-USE-NOT-STARTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup has not started. The local app can still open without an account."
success_focus = "the Not Started result heading in Progressive first use"
success_focus_id = "FOCUS-SETUP-FIRST-USE-NOT-STARTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact failed field in Progressive first use — Not Started"
failure_focus_id = "FOCUS-SETUP-FIRST-USE-NOT-STARTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-SETUP-FIRST-USE-NOT-STARTED-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SETUP-FIRST-USE-REVISITABLE"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Resume Setup => destination: the first unanswered or invalid setup field from Progressive first use — Revisitable; effect: No durable mutation occurs and no Receipt is created; Resume Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup is incomplete. Earlier choices remain saved.; focus: the Revisitable result heading in Progressive first use."
durable_effect = "Exact state consequences: Resume Setup: No durable mutation occurs and no Receipt is created; Resume Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup is incomplete. Earlier choices remain saved. Current visible status: Setup is incomplete. Earlier choices remain saved."
recovery_rollback = "Exact recovery and rollback: Resume Setup: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Setup is incomplete. Earlier choices remain saved."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Setup is incomplete. Earlier choices remain saved."
accessibility_focus = "VoiceOver focus contract: Resume Setup announces its consequence; success focuses the Revisitable result heading in Progressive first use; rejection focuses the Resume Setup control and exact failed field in Progressive first use — Revisitable. The announcement first communicates: Setup is incomplete. Earlier choices remain saved."

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-FIRST-USE-REVISITABLE-001"
label = "Resume Setup"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Progressive first use route and Revisitable presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the first unanswered or invalid setup field from Progressive first use — Revisitable"
destination_id = "DEST-SETUP-FIRST-USE-REVISITABLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Resume Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup is incomplete. Earlier choices remain saved."
success_focus = "the Revisitable result heading in Progressive first use"
success_focus_id = "FOCUS-SETUP-FIRST-USE-REVISITABLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Resume Setup control and exact failed field in Progressive first use — Revisitable"
failure_focus_id = "FOCUS-SETUP-FIRST-USE-REVISITABLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-SETUP-FIRST-USE-REVISITABLE-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SETUP-FIRST-USE-SKIPPED"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Resume Setup => destination: the first unanswered or invalid setup field from Progressive first use — Skipped; effect: No durable mutation occurs and no Receipt is created; Resume Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup was skipped without blocking the local app or discarding prior choices.; focus: the Skipped result heading in Progressive first use."
durable_effect = "Exact state consequences: Resume Setup: No durable mutation occurs and no Receipt is created; Resume Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup was skipped without blocking the local app or discarding prior choices. Current visible status: Setup was skipped without blocking the local app or discarding prior choices."
recovery_rollback = "Exact recovery and rollback: Resume Setup: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Setup was skipped without blocking the local app or discarding prior choices."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Setup was skipped without blocking the local app or discarding prior choices."
accessibility_focus = "VoiceOver focus contract: Resume Setup announces its consequence; success focuses the Skipped result heading in Progressive first use; rejection focuses the Resume Setup control and exact failed field in Progressive first use — Skipped. The announcement first communicates: Setup was skipped without blocking the local app or discarding prior choices."

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-FIRST-USE-SKIPPED-001"
label = "Resume Setup"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Progressive first use route and Skipped presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the first unanswered or invalid setup field from Progressive first use — Skipped"
destination_id = "DEST-SETUP-FIRST-USE-SKIPPED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Resume Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup was skipped without blocking the local app or discarding prior choices."
success_focus = "the Skipped result heading in Progressive first use"
success_focus_id = "FOCUS-SETUP-FIRST-USE-SKIPPED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Resume Setup control and exact failed field in Progressive first use — Skipped"
failure_focus_id = "FOCUS-SETUP-FIRST-USE-SKIPPED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-SETUP-FIRST-USE-SKIPPED-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SETUP-FIRST-USE-SUFFICIENT-FOR-LOCAL-USE"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the usable local Ambitions core from Progressive first use — Sufficient For Local Use; effect: No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Enough setup is complete for full local use; optional account and permissions remain optional.; focus: the Sufficient For Local Use result heading in Progressive first use."
durable_effect = "Exact state consequences: Continue: No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Enough setup is complete for full local use; optional account and permissions remain optional. Current visible status: Enough setup is complete for full local use; optional account and permissions remain optional."
recovery_rollback = "Exact recovery and rollback: Continue: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Enough setup is complete for full local use; optional account and permissions remain optional."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Enough setup is complete for full local use; optional account and permissions remain optional."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence; success focuses the Sufficient For Local Use result heading in Progressive first use; rejection focuses the Continue control and exact failed field in Progressive first use — Sufficient For Local Use. The announcement first communicates: Enough setup is complete for full local use; optional account and permissions remain optional."

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-FIRST-USE-SUFFICIENT-FOR-LOCAL-USE-001"
label = "Continue"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Progressive first use route and Sufficient For Local Use presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the usable local Ambitions core from Progressive first use — Sufficient For Local Use"
destination_id = "DEST-SETUP-FIRST-USE-SUFFICIENT-FOR-LOCAL-USE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Enough setup is complete for full local use; optional account and permissions remain optional."
success_focus = "the Sufficient For Local Use result heading in Progressive first use"
success_focus_id = "FOCUS-SETUP-FIRST-USE-SUFFICIENT-FOR-LOCAL-USE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact failed field in Progressive first use — Sufficient For Local Use"
failure_focus_id = "FOCUS-SETUP-FIRST-USE-SUFFICIENT-FOR-LOCAL-USE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-SETUP-FIRST-USE-SUFFICIENT-FOR-LOCAL-USE-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SETUP-RESUME-CHECKPOINT-FOUND"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Resume Setup => destination: the first unanswered or invalid setup field from Setup interruption and resume — Checkpoint Found; effect: No durable mutation occurs and no Receipt is created; Resume Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Earlier setup progress was found. No unfinished choice is marked complete.; focus: the Checkpoint Found result heading in Setup interruption and resume."
durable_effect = "Exact state consequences: Resume Setup: No durable mutation occurs and no Receipt is created; Resume Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Earlier setup progress was found. No unfinished choice is marked complete. Current visible status: Earlier setup progress was found. No unfinished choice is marked complete."
recovery_rollback = "Exact recovery and rollback: Resume Setup: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Earlier setup progress was found. No unfinished choice is marked complete."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Earlier setup progress was found. No unfinished choice is marked complete."
accessibility_focus = "VoiceOver focus contract: Resume Setup announces its consequence; success focuses the Checkpoint Found result heading in Setup interruption and resume; rejection focuses the Resume Setup control and exact failed field in Setup interruption and resume — Checkpoint Found. The announcement first communicates: Earlier setup progress was found. No unfinished choice is marked complete."

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-RESUME-CHECKPOINT-FOUND-001"
label = "Resume Setup"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Setup interruption and resume route and Checkpoint Found presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the first unanswered or invalid setup field from Setup interruption and resume — Checkpoint Found"
destination_id = "DEST-SETUP-RESUME-CHECKPOINT-FOUND-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Resume Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Earlier setup progress was found. No unfinished choice is marked complete."
success_focus = "the Checkpoint Found result heading in Setup interruption and resume"
success_focus_id = "FOCUS-SETUP-RESUME-CHECKPOINT-FOUND-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Resume Setup control and exact failed field in Setup interruption and resume — Checkpoint Found"
failure_focus_id = "FOCUS-SETUP-RESUME-CHECKPOINT-FOUND-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-SETUP-RESUME-CHECKPOINT-FOUND-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SETUP-RESUME-CHECKPOINT-INVALID"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Diagnostics => destination: the redacted local Diagnostics inspection from Setup interruption and resume — Checkpoint Invalid; effect: No durable mutation occurs and no Receipt is created; Open Diagnostics changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Saved setup progress cannot be used. Earlier product information and choices outside setup remain unchanged.; focus: the Checkpoint Invalid result heading in Setup interruption and resume.\nStart Over Setup => destination: the first setup chapter with accepted answers retained from Setup interruption and resume — Checkpoint Invalid; effect: No durable mutation occurs and no Receipt is created; Start Over Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Saved setup progress cannot be used. Earlier product information and choices outside setup remain unchanged.; focus: the Checkpoint Invalid result heading in Setup interruption and resume."
durable_effect = "Exact state consequences: Open Diagnostics: No durable mutation occurs and no Receipt is created; Open Diagnostics changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Saved setup progress cannot be used. Earlier product information and choices outside setup remain unchanged. | Start Over Setup: No durable mutation occurs and no Receipt is created; Start Over Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Saved setup progress cannot be used. Earlier product information and choices outside setup remain unchanged. Current visible status: Saved setup progress cannot be used. Earlier product information and choices outside setup remain unchanged."
recovery_rollback = "Exact recovery and rollback: Open Diagnostics: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. | Start Over Setup: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Saved setup progress cannot be used. Earlier product information and choices outside setup remain unchanged."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Saved setup progress cannot be used. Earlier product information and choices outside setup remain unchanged."
accessibility_focus = "VoiceOver focus contract: Open Diagnostics announces its consequence; success focuses the Checkpoint Invalid result heading in Setup interruption and resume; rejection focuses the Open Diagnostics control and exact failed field in Setup interruption and resume — Checkpoint Invalid | Start Over Setup announces its consequence; success focuses the Checkpoint Invalid result heading in Setup interruption and resume; rejection focuses the Start Over Setup control and exact failed field in Setup interruption and resume — Checkpoint Invalid. The announcement first communicates: Saved setup progress cannot be used. Earlier product information and choices outside setup remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-RESUME-CHECKPOINT-INVALID-001"
label = "Open Diagnostics"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Setup interruption and resume route and Checkpoint Invalid presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the redacted local Diagnostics inspection from Setup interruption and resume — Checkpoint Invalid"
destination_id = "DEST-SETUP-RESUME-CHECKPOINT-INVALID-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Open Diagnostics changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Saved setup progress cannot be used. Earlier product information and choices outside setup remain unchanged."
success_focus = "the Checkpoint Invalid result heading in Setup interruption and resume"
success_focus_id = "FOCUS-SETUP-RESUME-CHECKPOINT-INVALID-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open Diagnostics control and exact failed field in Setup interruption and resume — Checkpoint Invalid"
failure_focus_id = "FOCUS-SETUP-RESUME-CHECKPOINT-INVALID-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-SETUP-RESUME-CHECKPOINT-INVALID-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-RESUME-CHECKPOINT-INVALID-002"
label = "Start Over Setup"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Setup interruption and resume route and Checkpoint Invalid presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the first setup chapter with accepted answers retained from Setup interruption and resume — Checkpoint Invalid"
destination_id = "DEST-SETUP-RESUME-CHECKPOINT-INVALID-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Start Over Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Saved setup progress cannot be used. Earlier product information and choices outside setup remain unchanged."
success_focus = "the Checkpoint Invalid result heading in Setup interruption and resume"
success_focus_id = "FOCUS-SETUP-RESUME-CHECKPOINT-INVALID-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Start Over Setup control and exact failed field in Setup interruption and resume — Checkpoint Invalid"
failure_focus_id = "FOCUS-SETUP-RESUME-CHECKPOINT-INVALID-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-SETUP-RESUME-CHECKPOINT-INVALID-002"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SETUP-RESUME-RESUMED"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Continue => destination: the next incomplete setup chapter from Setup interruption and resume — Resumed; effect: No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Resumed — Setup resumes at the first unfinished selected step with prior choices preserved.; focus: the Resumed result heading in Setup interruption and resume."
durable_effect = "Exact state consequences: Continue: No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Resumed — Setup resumes at the first unfinished selected step with prior choices preserved. Current visible status: Resumed — Setup resumes at the first unfinished selected step with prior choices preserved."
recovery_rollback = "Exact recovery and rollback: Continue: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Resumed — Setup resumes at the first unfinished selected step with prior choices preserved."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Resumed — Setup resumes at the first unfinished selected step with prior choices preserved."
accessibility_focus = "VoiceOver focus contract: Continue announces its consequence; success focuses the Resumed result heading in Setup interruption and resume; rejection focuses the Continue control and exact failed field in Setup interruption and resume — Resumed. The announcement first communicates: Resumed — Setup resumes at the first unfinished selected step with prior choices preserved."

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-RESUME-RESUMED-001"
label = "Continue"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Setup interruption and resume route and Resumed presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the next incomplete setup chapter from Setup interruption and resume — Resumed"
destination_id = "DEST-SETUP-RESUME-RESUMED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Continue changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Resumed — Setup resumes at the first unfinished selected step with prior choices preserved."
success_focus = "the Resumed result heading in Setup interruption and resume"
success_focus_id = "FOCUS-SETUP-RESUME-RESUMED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Continue control and exact failed field in Setup interruption and resume — Resumed"
failure_focus_id = "FOCUS-SETUP-RESUME-RESUMED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-SETUP-RESUME-RESUMED-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SETUP-RESUME-REVALIDATING"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Save and Exit => destination: the usable local Ambitions core with the setup checkpoint retained from Setup interruption and resume — Revalidating; effect: No durable mutation occurs and no Receipt is created; Save and Exit changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Ambitions is checking the saved setup point against current permissions and optional services. Earlier choices remain saved.; focus: the Revalidating result heading in Setup interruption and resume."
durable_effect = "Exact state consequences: Save and Exit: No durable mutation occurs and no Receipt is created; Save and Exit changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Ambitions is checking the saved setup point against current permissions and optional services. Earlier choices remain saved. Current visible status: Ambitions is checking the saved setup point against current permissions and optional services. Earlier choices remain saved."
recovery_rollback = "Exact recovery and rollback: Save and Exit: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Ambitions is checking the saved setup point against current permissions and optional services. Earlier choices remain saved."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Ambitions is checking the saved setup point against current permissions and optional services. Earlier choices remain saved."
accessibility_focus = "VoiceOver focus contract: Save and Exit announces its consequence; success focuses the Revalidating result heading in Setup interruption and resume; rejection focuses the Save and Exit control and exact failed field in Setup interruption and resume — Revalidating. The announcement first communicates: Ambitions is checking the saved setup point against current permissions and optional services. Earlier choices remain saved."

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-RESUME-REVALIDATING-001"
label = "Save and Exit"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Setup interruption and resume route and Revalidating presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the usable local Ambitions core with the setup checkpoint retained from Setup interruption and resume — Revalidating"
destination_id = "DEST-SETUP-RESUME-REVALIDATING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Save and Exit changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Ambitions is checking the saved setup point against current permissions and optional services. Earlier choices remain saved."
success_focus = "the Revalidating result heading in Setup interruption and resume"
success_focus_id = "FOCUS-SETUP-RESUME-REVALIDATING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Save and Exit control and exact failed field in Setup interruption and resume — Revalidating"
failure_focus_id = "FOCUS-SETUP-RESUME-REVALIDATING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-SETUP-RESUME-REVALIDATING-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SETUP-RESUME-START-OVER"
requirement_id = "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Start Over Setup => destination: the first setup chapter with accepted answers retained from Setup interruption and resume — Start Over; effect: No durable mutation occurs and no Receipt is created; Start Over Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup progress is unchanged. Product information remains available.; focus: the Start Over result heading in Setup interruption and resume."
durable_effect = "Exact state consequences: Start Over Setup: No durable mutation occurs and no Receipt is created; Start Over Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup progress is unchanged. Product information remains available. Current visible status: Setup progress is unchanged. Product information remains available."
recovery_rollback = "Exact recovery and rollback: Start Over Setup: No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged. Recovery preserves this user-visible evidence: Setup progress is unchanged. Product information remains available."
offline_behavior = "The local core, accepted setup answers, and last confirmed account or readiness state remain available offline. Offline evidence remains: Setup progress is unchanged. Product information remains available."
accessibility_focus = "VoiceOver focus contract: Start Over Setup announces its consequence; success focuses the Start Over result heading in Setup interruption and resume; rejection focuses the Start Over Setup control and exact failed field in Setup interruption and resume — Start Over. The announcement first communicates: Setup progress is unchanged. Product information remains available."

[[state_command_contracts.commands]]
command_id = "CMD-SETUP-RESUME-START-OVER-001"
label = "Start Over Setup"
canonical_owner = "app.launch-setup.command-contract"
preconditions = ["The Setup interruption and resume route and Start Over presentation anchor are current", "The local object, account, setup, or readiness revision has been revalidated"]
destination = "the first setup chapter with accepted answers retained from Setup interruption and resume — Start Over"
destination_id = "DEST-SETUP-RESUME-START-OVER-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Start Over Setup changes only navigation, selection, checkpoint position, or inspection. Visible evidence remains: Setup progress is unchanged. Product information remains available."
success_focus = "the Start Over result heading in Setup interruption and resume"
success_focus_id = "FOCUS-SETUP-RESUME-START-OVER-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Start Over Setup control and exact failed field in Setup interruption and resume — Start Over"
failure_focus_id = "FOCUS-SETUP-RESUME-START-OVER-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: navigation, inspection, selection, retry preview, or cancellation completes without a canonical commit."
rollback_undo = "No Undo is required; dismissal restores the initiating control with accepted answers and local product data unchanged."
recovery_id = "RECOVERY-SETUP-RESUME-START-OVER-001"
recovery_posture = "current"
recovery_owner = "app.launch-setup.command-contract"
privacy_egress = "The operation remains local and sends no private life graph content off device."
verification_ids = ["SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

+++

# Launch and Progressive Setup



## APP-ACCOUNT-LAUNCH-001 — Optional account support ships at launch

- **Concept:** `account.launch-commitment`
- **Modality:** `MUST`
- **Scope:** Launch account availability and no-account product entry
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-ACCOUNT-OPTIONAL-001`
- **Supersedes:** none

Ambitions Account support MUST be available at launch while remaining optional. The user MUST be able to enter and use the complete local core without creating or signing into an account; account availability does not weaken the local-authority, private-data, or network boundaries.

Ambitions Account MAY support Sign in with Apple, Google Sign-In, identity, entitlement, approved recovery/support, and future approved services.

Ambitions Account MAY support continuity, sync, and account-backed capabilities but MUST NOT gate the local core.

Ambitions Account MUST NOT gate Today, Goals, Time, Capture, Search, or local data.

Ambitions Account MUST NOT gate the local core or become the private-graph backend.

Ambitions Account MAY support identity, entitlements, approved recovery or support, and non-sensitive service state.

Account status and sign-out consequences MUST be explicit.

## APP-SETUP-PROGRESSIVE-FIRST-USE-001 — Local core precedes optional setup

- **Concept:** `app.setup.progressive-first-use`
- **Modality:** `MUST`
- **Scope:** First launch and later setup continuation
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-FIRST-USE-001`, `SCENARIO-APP-SETUP-SKIP-001`
- **Supersedes:** none

First use MUST open a useful local core before account sign-in or optional network access. Setup asks only for context that improves the next useful action, saves each accepted answer durably, permits every nonessential question to be skipped, and keeps skipped work reachable later through the owning You setup surface. Account, notification, calendar, reminders, speech, health, and other optional integrations are requested only when their value is contextual and their denied fallback is already defined.

Setup may encourage a first Goal and may preview a first Path when enough information exists; it cannot require either before the local app becomes usable. It must not present a long mandatory permission wall, chatbot center, or static completion checklist as the product.

Ambitions MUST open to usable product value immediately and MUST prompt setup only when needed.

Onboarding SHOULD be a conversational guided interview.

Onboarding MUST use chapters.

Onboarding SHOULD recommend adding a first goal but allow skipping.

Ambitions SHOULD ask questions that quickly improve pathing.

## APP-LAUNCH-READINESS-001 — Launch gate protects durable local readiness

- **Concept:** `app.launch.readiness`
- **Modality:** `MUST`
- **Scope:** Cold launch, warm launch, relaunch, and restored local session
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-LAUNCH-READY-001`, `SCENARIO-APP-LAUNCH-DEGRADED-001`
- **Supersedes:** none

Launch MUST establish enough local readiness to avoid presenting a false usable state: readable local authority, a valid app/navigation root, and a safe path for pending repair or recovery. Optional account, sync, R2, Source Atlas, permission, and external-source checks cannot block entry to the healthy local core. A launch indicator may communicate real bounded work;

Skipping onboarding MUST NOT block the app.

## APP-LAUNCH-RECOVERY-001 — Launch failure offers repair without destructive reset

- **Concept:** `app.launch.recovery`
- **Modality:** `MUST`
- **Scope:** Local-store unavailability, migration failure, replay failure, incomplete setup recovery, and interrupted launch
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-LAUNCH-REPAIR-001`, `PROOF-APP-LAUNCH-NO-DATA-LOSS-001`
- **Supersedes:** none

When safe local readiness cannot be established, launch MUST distinguish retryable delay, repairable local degradation, quarantined data, and a stop-ship risk of silent loss. It preserves accepted data and setup progress, offers bounded retry, repair preview, export, or diagnostics as applicable, and never defaults to destructive reset. A reproducible silent-loss path remains governed by `LAW-DATA-LOSS-STOP-SHIP-001`.

## APP-SETUP-RESUME-001 — Setup interruption never loses accepted progress

- **Concept:** `app.setup.interruption-resume`
- **Modality:** `MUST`
- **Scope:** Skip, cancellation, app interruption, crash, relaunch, and later continuation
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SETUP-RESUME-001`, `SCENARIO-APP-SETUP-PARTIAL-001`
- **Supersedes:** none

Each accepted setup answer MUST persist before the next question is presented. Interruption restores the last durable setup state and preserves already entered context. Skip records no invented answer and leaves core use available. Later edits identify affected settings or paths and route material consequences through confirmation and the constitutional mutation sequence.

## APP-SETUP-STATE-001 — Setup progress reflects useful context

- **Concept:** `app.setup.state`
- **Modality:** `MUST`
- **Scope:** Setup chapter availability, progress, completion, and revision
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SETUP-PROGRESS-001`, `AUDIT-APP-SETUP-NONCOERCION-001`
- **Supersedes:** none

Setup state MUST distinguish not started, in progress, skipped, sufficient for local use, and revisitable. Any displayed progress reflects the weighted usefulness of durable accepted context rather than pressuring completion through raw question count. Completion does not grant permissions, create an account, enable continuity, or prove that a first path was generated unless the owning flow separately commits and proves that result.

## APP-SETUP-PROGRESS-001 — Setup progress

- **Concept:** `app.setup.progress`
- **Modality:** `MUST`
- **Scope:** First-use setup
- **Status:** `normative`
- **Verification:** `SCENARIO-SETUP-PROGRESS-001`
- **Supersedes:** none

Setup MUST disclose bounded progress for work that is not immediate, remain resumable, and never block useful local entry on network availability.

## APP-ACCOUNT-COMMAND-CONTRACT-001 — Account commands preserve local private authority

- **Concept:** `account.command-contract`
- **Modality:** `MUST`
- **Scope:** Account choice, provider authentication, account status, sign-out, retry, interruption, and offline local use
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-ACCOUNT-COMMAND-CONTRACT-001`
- **Supersedes:** none

Account and Sync MUST expose explicit Local Only, provider choice, provider-in-progress, cancelled, failed, signed-in, and signed-out behavior. The only launch providers are `Sign in with Apple` and `Sign in with Google`. Opening provider UI, `Cancel`, `Try Again`, `Continue Without an Account`, and `Done` are non-canonical navigation or provider effects.

Successful sign-in MAY commit only account identity, protected provider/session material, entitlement/service association, and an account-action Receipt. It MUST NOT upload, attach, migrate, inspect, or grant the account authority over the private graph.

`Sign Out` MUST invalidate local account credentials and pause account-only services while retaining all local Goals, Captures, Time, settings, Proof, History, and Receipts. It MUST NOT delete local data or continuity data. Deletion requires a separately routed destructive command.


`You → Account & Sync → Account`; provider authentication uses a native sheet. Entry focuses provider choice or current account status. Success focuses signed-in status; failure focuses the failed provider and `Try Again`; cancellation returns focus to that provider; sign-out focuses signed-out/local-only status.


Provider cancellation or failure makes no local product-state change. Offline use remains Local Only; provider controls are unavailable with a plain reason and core use continues. Provider egress is restricted to identity/authentication fields.

## APP-LAUNCH-SETUP-COMMAND-CONTRACT-001 — Launch and setup commands preserve accepted progress

- **Concept:** `app.launch-setup.command-contract`
- **Modality:** `MUST`
- **Scope:** Launch readiness, progressive setup, checkpoint recovery, interruption, skip, resume, and offline entry
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-LAUNCH-SETUP-COMMAND-CONTRACT-001`
- **Supersedes:** none

Progressive setup MUST preserve the canonical chapter order:

1. Direction
2. Current Schedule
3. Goals
4. Energy & Work Style
5. Resources
6. Life Capital
7. Obstacles
8. Data Sources
9. Automation
10. First Path Preview

Commands are `Continue`, `Back`, `Skip This Question`, `Skip This Chapter`, `Save and Exit`, `Resume Setup`, `Start Over Setup`, and `Skip Setup for Now`.

Each accepted answer commits independently with its own revision/history. Navigation is non-mutating. Skipping records only that the question or chapter was skipped; it MUST NOT invent an answer or prevent later completion. `Start Over Setup` resets only navigation/checkpoint position and reopens existing accepted answers; clearing accepted answers requires a separate data command.

An invalid checkpoint MUST be quarantined without deleting accepted answers. Recovery offers `Start Over Setup` and `Open Diagnostics`. Launch readiness may offer `Try Again`, `Review Repair`, `Open Diagnostics`, or `Export Data` only when the classified state safely supports that command. A stop-ship/data-loss state MUST NOT offer continue or reset.


Focus resumes at the chapter heading and first unanswered or invalid field. Success focuses the next chapter or completion result; failure focuses the exact field or readiness reason. Setup works offline and never requires an account or permission wall.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Launch and setup have bounded owners with no authority over product objects or external services.

Launch owns local readiness gating and entry to safe recovery. Progressive setup owns skippable context collection, durable progress, and later continuation. Neither owns account policy, permission decisions, canonical Goal/path behavior, persistence implementation, or release status.

<!-- canon-section: inputs-outputs -->
Launch inputs are local-store readiness, replay/migration result, route readiness, pending repair, and interruption state. Setup inputs are explicit user answers, skips, and owning-system status. Outputs are a valid local entry or honest recovery state, plus durable setup progress and a next optional question.

<!-- canon-section: authority-boundary -->
The Constitution owns offline/no-account, force-nothing, durable-success, data-loss, and account boundaries. Setup references later surface and system owners and cannot silently enable, mutate, or claim their behavior.

<!-- canon-section: data-classification -->
Setup answers may be private life context and remain local private data by default. Launch telemetry and diagnostics use minimum necessary redacted state. Account or public-reference services receive no setup answers or private graph context under this specification.

<!-- canon-section: state-model -->
Launch and setup retain separate state machines linked only by explicit local readiness facts.

Launch states are checking local readiness, ready, retryable delay, repair required, quarantined, and stop-ship data-risk. Setup states are not started, in progress, skipped, sufficient, and revisitable, with each accepted answer carrying its own durable commit state.

<!-- canon-section: failure-recovery -->
Interrupted setup resumes from durable progress. Launch failure offers retry, repair preview, quarantine inspection, export, or diagnostics according to the failure class. Destructive reset is never an automatic recovery path.

<!-- canon-section: local-network-boundary -->
Launch and useful core entry are local and do not await sign-in, sync, entitlement, R2, Source Atlas, or any external permission. Optional network-dependent setup is deferred or degraded without blocking local use.

<!-- canon-section: determinism -->
Given the same durable readiness facts, launch chooses the same ready or recovery class. Given the same accepted setup answers and skips, setup resumes at the same next useful point without synthesizing private context.

<!-- canon-section: observability -->
Scoped evidence records launch phase, local-readiness decision, failure class, recovery offered, setup progress state, accepted-answer durability, and resume result with private values redacted. Current instrumentation must be inspected before claiming this proof exists.

<!-- canon-section: source-ownership -->
`App/` owns launch assembly, the shared LaunchGate view presents readiness, LocalRuntimeOS Boundary and Repair own their underlying decisions, You owns later Setup & Personalization, and `Quality/` owns verification. These mappings do not promote present source to compliance proof.

<!-- canon-section: tests-proof -->
Required proof covers cold/warm/offline launch, no-account entry, optional-service outage, migration/replay failure, non-destructive repair, crash/interruption resume, skip behavior, durable per-answer save, accessibility focus/order/actions, Dynamic Type, Reduce Motion, and private diagnostic redaction.

<!-- canon-section: performance-resource-constraints -->
On the oldest supported physical iPhone in an optimized build with 10,000 canonical objects, 50,000 events, and 5,000 receipts, a healthy cold launch MUST present the first useful local frame within 1.5 seconds at P95 across 20 launches; warm entry MUST complete within 500 ms at P95. The readiness decision itself MUST complete within 250 ms at P95 and read no more than 16 MiB before first useful presentation. An operation exceeding 2 seconds MUST expose truthful progress and yield the main actor at least every 50 ms. A setup-answer commit MUST complete within 100 ms at P95 and use one local transaction; resume decision MUST complete within 250 ms at P95. Launch/readiness memory growth MUST remain at or below 40 MiB, make zero network calls, and perform no polling after readiness.
