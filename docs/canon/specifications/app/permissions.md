+++
spec_id = "APP-PERMISSIONS"
title = "Contextual Permissions"
kind = "app"
status = "normative"
owner_domain = "app-permissions"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "app.permissions.command-contract",
  "app.permissions.contextual-request",
  "app.permissions.denied-fallback",
  "app.permissions.reconciliation",
  "app.permissions.recovery",
  "app.permissions.state",
]
inherits = [
  "PRIVACY-VISIBILITY-001",
  "LAW-OFFLINE-NO-ACCOUNT-001",
  "CONTROL-FORCE-NOTHING-001",
  "PLATFORM-NATIVE-IPHONE-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
  "CONST-PROOF-EVIDENCE-001",
]
depends_on = ["CONSTITUTION", "APP-LAUNCH-SETUP", "APP-DEGRADED-STATES"]
source_owners = [
  "Native/Ambitions/Core/Permissions/",
  "Native/Ambitions/Core/LocalRuntimeOS/Boundary/",
  "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/",
  "Native/Ambitions/Surfaces/You/",
  "Native/Ambitions/Quality/",
]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-AUTHORIZED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the initiating local feature or You permission context from Calendar permission — Authorized; effect: No durable mutation occurs and no Receipt is created; Done closes only the confirmed Calendar status. Authorization observation, local objects, and external capability remain unchanged. Visible evidence remains: Calendar access is allowed. Ambitions-owned information remains unchanged.; focus: the resulting Calendar status, local fallback, or Done destination in Calendar permission — Authorized."
durable_effect = "Exact contextual Calendar permission consequences: Done: No durable mutation occurs and no Receipt is created; Done closes only the confirmed Calendar status. Authorization observation, local objects, and external capability remain unchanged. Visible evidence remains: Calendar access is allowed. Ambitions-owned information remains unchanged. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Calendar access is allowed. Ambitions-owned information remains unchanged."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Done: No Undo is required; reopening the capability shows the current revalidated status and local fallback. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Calendar access is allowed. Ambitions-owned information remains unchanged."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Calendar access is allowed. Ambitions-owned information remains unchanged."
accessibility_focus = "Deterministic entry focus is enabled capability result. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Done announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Done destination in Calendar permission — Authorized; rejection focuses the Done control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Authorized. Dynamic Type stacks explanations and controls. The announcement first communicates: Calendar access is allowed. Ambitions-owned information remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-AUTHORIZED-001"
label = "Done"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the initiating local feature or You permission context from Calendar permission — Authorized"
destination_id = "DEST-PERMISSIONS-CALENDAR-AUTHORIZED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done closes only the confirmed Calendar status. Authorization observation, local objects, and external capability remain unchanged. Visible evidence remains: Calendar access is allowed. Ambitions-owned information remains unchanged."
success_focus = "the resulting Calendar status, local fallback, or Done destination in Calendar permission — Authorized"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-AUTHORIZED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Authorized"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-AUTHORIZED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: status dismissal cannot grant, revoke, reconcile, or mutate permission or product data."
rollback_undo = "No Undo is required; reopening the capability shows the current revalidated status and local fallback."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-AUTHORIZED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-DENIED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Settings => destination: the Ambitions Calendar permission control in iOS Settings from Calendar permission — Denied; effect: The Open Settings external result causes no local canonical mutation; system Settings owns authorization. On foreground return, Ambitions re-reads Calendar status and reconciles only the external-capability projection. Local objects remain unchanged. Visible evidence remains: Calendar access is not allowed. Saved Goals, Captures, and time remain available.; focus: the resulting Calendar status, local fallback, or Open Settings destination in Calendar permission — Denied.\nUse Local Only => destination: the fully usable local Calendar fallback from Calendar permission — Denied; effect: No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar access is not allowed. Saved Goals, Captures, and time remain available.; focus: the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Denied."
durable_effect = "Exact contextual Calendar permission consequences: Open Settings: The Open Settings external result causes no local canonical mutation; system Settings owns authorization. On foreground return, Ambitions re-reads Calendar status and reconciles only the external-capability projection. Local objects remain unchanged. Visible evidence remains: Calendar access is not allowed. Saved Goals, Captures, and time remain available. | Use Local Only: No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar access is not allowed. Saved Goals, Captures, and time remain available. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Calendar access is not allowed. Saved Goals, Captures, and time remain available."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Open Settings: Cancellation, unchanged status, or Settings-return failure preserves the prior known status and local fallback, focuses the recovery control, and triggers no repeated prompt. | Use Local Only: No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Calendar access is not allowed. Saved Goals, Captures, and time remain available."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Calendar access is not allowed. Saved Goals, Captures, and time remain available."
accessibility_focus = "Deterministic entry focus is denied status, local fallback, and Open Settings. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Open Settings announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Open Settings destination in Calendar permission — Denied; rejection focuses the Open Settings control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Denied | Use Local Only announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Denied; rejection focuses the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Denied. Dynamic Type stacks explanations and controls. The announcement first communicates: Calendar access is not allowed. Saved Goals, Captures, and time remain available."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-DENIED-001"
label = "Open Settings"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable", "The user explicitly selected the system Settings route after seeing current status and local fallback"]
destination = "the Ambitions Calendar permission control in iOS Settings from Calendar permission — Denied"
destination_id = "DEST-PERMISSIONS-CALENDAR-DENIED-001"
destination_posture = "current"
effect = "The Open Settings external result causes no local canonical mutation; system Settings owns authorization. On foreground return, Ambitions re-reads Calendar status and reconciles only the external-capability projection. Local objects remain unchanged. Visible evidence remains: Calendar access is not allowed. Saved Goals, Captures, and time remain available."
success_focus = "the resulting Calendar status, local fallback, or Open Settings destination in Calendar permission — Denied"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-DENIED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open Settings control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Denied"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-DENIED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: Settings changes are externally owned; foreground reconciliation cannot infer consent or commit canonical product data."
rollback_undo = "Cancellation, unchanged status, or Settings-return failure preserves the prior known status and local fallback, focuses the recovery control, and triggers no repeated prompt."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-DENIED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-DENIED-002"
label = "Use Local Only"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the fully usable local Calendar fallback from Calendar permission — Denied"
destination_id = "DEST-PERMISSIONS-CALENDAR-DENIED-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar access is not allowed. Saved Goals, Captures, and time remain available."
success_focus = "the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Denied"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-DENIED-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Denied"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-DENIED-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: choosing the local fallback performs no permission, canonical-data, or inferred-consent commit."
rollback_undo = "No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-DENIED-002"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-ELIGIBILITY-CHECK"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Check Again => destination: the freshly observed Calendar capability status from Calendar permission — Eligibility Check; effect: The Check Again external result causes no local canonical mutation; it re-reads current Calendar authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Calendar permission availability is being checked. Existing calendar and Ambitions information remains as it was.; focus: the resulting Calendar status, local fallback, or Check Again destination in Calendar permission — Eligibility Check."
durable_effect = "Exact contextual Calendar permission consequences: Check Again: The Check Again external result causes no local canonical mutation; it re-reads current Calendar authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Calendar permission availability is being checked. Existing calendar and Ambitions information remains as it was. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Calendar permission availability is being checked. Existing calendar and Ambitions information remains as it was."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Check Again: Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Calendar permission availability is being checked. Existing calendar and Ambitions information remains as it was."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Calendar permission availability is being checked. Existing calendar and Ambitions information remains as it was."
accessibility_focus = "Deterministic entry focus is eligibility heading and current request reason. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Check Again announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Check Again destination in Calendar permission — Eligibility Check; rejection focuses the Check Again control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Eligibility Check. Dynamic Type stacks explanations and controls. The announcement first communicates: Calendar permission availability is being checked. Existing calendar and Ambitions information remains as it was."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-ELIGIBILITY-CHECK-001"
label = "Check Again"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable", "The user explicitly retries or the app has returned to foreground; no system prompt is inferred"]
destination = "the freshly observed Calendar capability status from Calendar permission — Eligibility Check"
destination_id = "DEST-PERMISSIONS-CALENDAR-ELIGIBILITY-CHECK-001"
destination_posture = "current"
effect = "The Check Again external result causes no local canonical mutation; it re-reads current Calendar authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Calendar permission availability is being checked. Existing calendar and Ambitions information remains as it was."
success_focus = "the resulting Calendar status, local fallback, or Check Again destination in Calendar permission — Eligibility Check"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-ELIGIBILITY-CHECK-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Check Again control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Eligibility Check"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-ELIGIBILITY-CHECK-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: authorization re-read and capability reconciliation remain externally sourced and cannot mutate canonical product data."
rollback_undo = "Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-ELIGIBILITY-CHECK-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-LIMITED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Access => destination: the exact available and unavailable Calendar scope with local fallback from Calendar permission — Limited; effect: No durable mutation occurs and no Receipt is created; Review Access explains the current limited, partial, denied, restricted, or unavailable scope without requesting permission, revealing hidden fields, or changing local objects. Visible evidence remains: Calendar: Limited. Only a limited system-selected scope is available.; focus: the resulting Calendar status, local fallback, or Review Access destination in Calendar permission — Limited."
durable_effect = "Exact contextual Calendar permission consequences: Review Access: No durable mutation occurs and no Receipt is created; Review Access explains the current limited, partial, denied, restricted, or unavailable scope without requesting permission, revealing hidden fields, or changing local objects. Visible evidence remains: Calendar: Limited. Only a limited system-selected scope is available. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Calendar: Limited. Only a limited system-selected scope is available."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Review Access: No Undo is required; dismissal returns to the exact prior capability status and preserves all local content. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Calendar: Limited. Only a limited system-selected scope is available."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Calendar: Limited. Only a limited system-selected scope is available."
accessibility_focus = "Deterministic entry focus is exact available and unavailable scope plus Review Access. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Review Access announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Review Access destination in Calendar permission — Limited; rejection focuses the Review Access control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Limited. Dynamic Type stacks explanations and controls. The announcement first communicates: Calendar: Limited. Only a limited system-selected scope is available."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-LIMITED-001"
label = "Review Access"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the exact available and unavailable Calendar scope with local fallback from Calendar permission — Limited"
destination_id = "DEST-PERMISSIONS-CALENDAR-LIMITED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Access explains the current limited, partial, denied, restricted, or unavailable scope without requesting permission, revealing hidden fields, or changing local objects. Visible evidence remains: Calendar: Limited. Only a limited system-selected scope is available."
success_focus = "the resulting Calendar status, local fallback, or Review Access destination in Calendar permission — Limited"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-LIMITED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Access control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Limited"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-LIMITED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: access inspection remains explanatory and crosses no system or canonical commit boundary."
rollback_undo = "No Undo is required; dismissal returns to the exact prior capability status and preserves all local content."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-LIMITED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-LOCAL-FALLBACK"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Use Local Only => destination: the fully usable local Calendar fallback from Calendar permission — Local Fallback; effect: No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar: Local Fallback. The feature continues locally without the unavailable system capability.; focus: the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Local Fallback."
durable_effect = "Exact contextual Calendar permission consequences: Use Local Only: No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar: Local Fallback. The feature continues locally without the unavailable system capability. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Calendar: Local Fallback. The feature continues locally without the unavailable system capability."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Use Local Only: No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Calendar: Local Fallback. The feature continues locally without the unavailable system capability."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Calendar: Local Fallback. The feature continues locally without the unavailable system capability."
accessibility_focus = "Deterministic entry focus is local fallback result. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Use Local Only announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Local Fallback; rejection focuses the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Local Fallback. Dynamic Type stacks explanations and controls. The announcement first communicates: Calendar: Local Fallback. The feature continues locally without the unavailable system capability."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-LOCAL-FALLBACK-001"
label = "Use Local Only"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the fully usable local Calendar fallback from Calendar permission — Local Fallback"
destination_id = "DEST-PERMISSIONS-CALENDAR-LOCAL-FALLBACK-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar: Local Fallback. The feature continues locally without the unavailable system capability."
success_focus = "the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Local Fallback"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-LOCAL-FALLBACK-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Local Fallback"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-LOCAL-FALLBACK-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: choosing the local fallback performs no permission, canonical-data, or inferred-consent commit."
rollback_undo = "No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-LOCAL-FALLBACK-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-NOT-DETERMINED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Allow Calendar Access => destination: the native Calendar system permission prompt, then the exact resulting capability status from Calendar permission — Not Determined; effect: The Allow Calendar Access external result causes no local canonical mutation; the system prompt alone owns Calendar authorization. Ambitions records no Goal, Step, Event, Capture, Rule, or private graph change from prompting or authorization, and foreground return re-reads the actual status before capability reconciliation. Visible evidence remains until the system result: Calendar: Not Asked. Ambitions has not requested this permission.; focus: the resulting Calendar status, local fallback, or Allow Calendar Access destination in Calendar permission — Not Determined.\nNot Now => destination: the initiating local feature with Calendar fallback from Calendar permission — Not Determined; effect: No durable mutation occurs and no Receipt is created; Not Now dismisses the contextual request without inferred consent, repeated prompting, or replay of the initiating action. Local core behavior remains available. Visible evidence remains: Calendar: Not Asked. Ambitions has not requested this permission.; focus: the resulting Calendar status, local fallback, or Not Now destination in Calendar permission — Not Determined."
durable_effect = "Exact contextual Calendar permission consequences: Allow Calendar Access: The Allow Calendar Access external result causes no local canonical mutation; the system prompt alone owns Calendar authorization. Ambitions records no Goal, Step, Event, Capture, Rule, or private graph change from prompting or authorization, and foreground return re-reads the actual status before capability reconciliation. Visible evidence remains until the system result: Calendar: Not Asked. Ambitions has not requested this permission. | Not Now: No durable mutation occurs and no Receipt is created; Not Now dismisses the contextual request without inferred consent, repeated prompting, or replay of the initiating action. Local core behavior remains available. Visible evidence remains: Calendar: Not Asked. Ambitions has not requested this permission. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Calendar: Not Asked. Ambitions has not requested this permission."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Allow Calendar Access: Cancellation, denial, interruption, or prompt failure preserves all local objects and returns focus to the status and local fallback; Ambitions does not prompt again without new explicit intent and eligibility. | Not Now: No Undo is required; later prompting requires fresh explicit intent, relevance, eligibility, scope explanation, and fallback. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Calendar: Not Asked. Ambitions has not requested this permission."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Calendar: Not Asked. Ambitions has not requested this permission."
accessibility_focus = "Deterministic entry focus is permission purpose and primary Allow Calendar command. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Allow Calendar Access announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Allow Calendar Access destination in Calendar permission — Not Determined; rejection focuses the Allow Calendar Access control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Not Determined | Not Now announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Not Now destination in Calendar permission — Not Determined; rejection focuses the Not Now control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Not Determined. Dynamic Type stacks explanations and controls. The announcement first communicates: Calendar: Not Asked. Ambitions has not requested this permission."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-NOT-DETERMINED-001"
label = "Allow Calendar Access"
canonical_owner = "app.permissions.command-contract"
preconditions = ["A plain scope explanation names every requested field and system consequence", "Explicit user intent selected a permission-dependent feature", "Feature relevance is current and the requested capability is necessary for the chosen action", "Request eligibility is confirmed and no prior denial, restriction, or system prohibition permits another prompt", "The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The local fallback and unavailable behavior are explained before the system prompt", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the native Calendar system permission prompt, then the exact resulting capability status from Calendar permission — Not Determined"
destination_id = "DEST-PERMISSIONS-CALENDAR-NOT-DETERMINED-001"
destination_posture = "current"
effect = "The Allow Calendar Access external result causes no local canonical mutation; the system prompt alone owns Calendar authorization. Ambitions records no Goal, Step, Event, Capture, Rule, or private graph change from prompting or authorization, and foreground return re-reads the actual status before capability reconciliation. Visible evidence remains until the system result: Calendar: Not Asked. Ambitions has not requested this permission."
success_focus = "the resulting Calendar status, local fallback, or Allow Calendar Access destination in Calendar permission — Not Determined"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-NOT-DETERMINED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Allow Calendar Access control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Not Determined"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-NOT-DETERMINED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: the system permission prompt owns authorization and cannot commit canonical product data or replay the user’s rejected action."
rollback_undo = "Cancellation, denial, interruption, or prompt failure preserves all local objects and returns focus to the status and local fallback; Ambitions does not prompt again without new explicit intent and eligibility."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-NOT-DETERMINED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-NOT-DETERMINED-002"
label = "Not Now"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the initiating local feature with Calendar fallback from Calendar permission — Not Determined"
destination_id = "DEST-PERMISSIONS-CALENDAR-NOT-DETERMINED-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Not Now dismisses the contextual request without inferred consent, repeated prompting, or replay of the initiating action. Local core behavior remains available. Visible evidence remains: Calendar: Not Asked. Ambitions has not requested this permission."
success_focus = "the resulting Calendar status, local fallback, or Not Now destination in Calendar permission — Not Determined"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-NOT-DETERMINED-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Not Now control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Not Determined"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-NOT-DETERMINED-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: declining or postponing a permission crosses no authorization or canonical product-data boundary."
rollback_undo = "No Undo is required; later prompting requires fresh explicit intent, relevance, eligibility, scope explanation, and fallback."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-NOT-DETERMINED-002"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-PARTIAL-EXTERNAL-ACCESS"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Access => destination: the exact available and unavailable Calendar scope with local fallback from Calendar permission — Partial External Access; effect: No durable mutation occurs and no Receipt is created; Review Access explains the current limited, partial, denied, restricted, or unavailable scope without requesting permission, revealing hidden fields, or changing local objects. Visible evidence remains: Only some calendar data is available; hidden details stay hidden and incomplete results are marked.; focus: the resulting Calendar status, local fallback, or Review Access destination in Calendar permission — Partial External Access."
durable_effect = "Exact contextual Calendar permission consequences: Review Access: No durable mutation occurs and no Receipt is created; Review Access explains the current limited, partial, denied, restricted, or unavailable scope without requesting permission, revealing hidden fields, or changing local objects. Visible evidence remains: Only some calendar data is available; hidden details stay hidden and incomplete results are marked. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Only some calendar data is available; hidden details stay hidden and incomplete results are marked."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Review Access: No Undo is required; dismissal returns to the exact prior capability status and preserves all local content. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Only some calendar data is available; hidden details stay hidden and incomplete results are marked."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Only some calendar data is available; hidden details stay hidden and incomplete results are marked."
accessibility_focus = "Deterministic entry focus is exact available and unavailable scope plus Review Access. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Review Access announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Review Access destination in Calendar permission — Partial External Access; rejection focuses the Review Access control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Partial External Access. Dynamic Type stacks explanations and controls. The announcement first communicates: Only some calendar data is available; hidden details stay hidden and incomplete results are marked."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-PARTIAL-EXTERNAL-ACCESS-001"
label = "Review Access"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the exact available and unavailable Calendar scope with local fallback from Calendar permission — Partial External Access"
destination_id = "DEST-PERMISSIONS-CALENDAR-PARTIAL-EXTERNAL-ACCESS-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Access explains the current limited, partial, denied, restricted, or unavailable scope without requesting permission, revealing hidden fields, or changing local objects. Visible evidence remains: Only some calendar data is available; hidden details stay hidden and incomplete results are marked."
success_focus = "the resulting Calendar status, local fallback, or Review Access destination in Calendar permission — Partial External Access"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-PARTIAL-EXTERNAL-ACCESS-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Access control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Partial External Access"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-PARTIAL-EXTERNAL-ACCESS-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: access inspection remains explanatory and crosses no system or canonical commit boundary."
rollback_undo = "No Undo is required; dismissal returns to the exact prior capability status and preserves all local content."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-PARTIAL-EXTERNAL-ACCESS-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-RECONCILING"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Check Again => destination: the freshly observed Calendar capability status from Calendar permission — Reconciling; effect: The Check Again external result causes no local canonical mutation; it re-reads current Calendar authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Calendar: Refreshing. Ambitions is reconciling the current system permission after returning from Settings.; focus: the resulting Calendar status, local fallback, or Check Again destination in Calendar permission — Reconciling."
durable_effect = "Exact contextual Calendar permission consequences: Check Again: The Check Again external result causes no local canonical mutation; it re-reads current Calendar authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Calendar: Refreshing. Ambitions is reconciling the current system permission after returning from Settings. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Calendar: Refreshing. Ambitions is reconciling the current system permission after returning from Settings."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Check Again: Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Calendar: Refreshing. Ambitions is reconciling the current system permission after returning from Settings."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Calendar: Refreshing. Ambitions is reconciling the current system permission after returning from Settings."
accessibility_focus = "Deterministic entry focus is reconciliation heading. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Check Again announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Check Again destination in Calendar permission — Reconciling; rejection focuses the Check Again control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Reconciling. Dynamic Type stacks explanations and controls. The announcement first communicates: Calendar: Refreshing. Ambitions is reconciling the current system permission after returning from Settings."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-RECONCILING-001"
label = "Check Again"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable", "The user explicitly retries or the app has returned to foreground; no system prompt is inferred"]
destination = "the freshly observed Calendar capability status from Calendar permission — Reconciling"
destination_id = "DEST-PERMISSIONS-CALENDAR-RECONCILING-001"
destination_posture = "current"
effect = "The Check Again external result causes no local canonical mutation; it re-reads current Calendar authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Calendar: Refreshing. Ambitions is reconciling the current system permission after returning from Settings."
success_focus = "the resulting Calendar status, local fallback, or Check Again destination in Calendar permission — Reconciling"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-RECONCILING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Check Again control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Reconciling"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-RECONCILING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: authorization re-read and capability reconciliation remain externally sourced and cannot mutate canonical product data."
rollback_undo = "Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-RECONCILING-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-REQUEST-FAILED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Check Again => destination: the freshly observed Calendar capability status from Calendar permission — Request Failed; effect: The Check Again external result causes no local canonical mutation; it re-reads current Calendar authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: The calendar permission request did not finish; Ambitions remains usable with local Time.; focus: the resulting Calendar status, local fallback, or Check Again destination in Calendar permission — Request Failed.\nUse Local Only => destination: the fully usable local Calendar fallback from Calendar permission — Request Failed; effect: No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: The calendar permission request did not finish; Ambitions remains usable with local Time.; focus: the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Request Failed."
durable_effect = "Exact contextual Calendar permission consequences: Check Again: The Check Again external result causes no local canonical mutation; it re-reads current Calendar authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: The calendar permission request did not finish; Ambitions remains usable with local Time. | Use Local Only: No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: The calendar permission request did not finish; Ambitions remains usable with local Time. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: The calendar permission request did not finish; Ambitions remains usable with local Time."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Check Again: Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action. | Use Local Only: No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: The calendar permission request did not finish; Ambitions remains usable with local Time."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: The calendar permission request did not finish; Ambitions remains usable with local Time."
accessibility_focus = "Deterministic entry focus is failed request reason, Check Again, and local fallback. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Check Again announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Check Again destination in Calendar permission — Request Failed; rejection focuses the Check Again control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Request Failed | Use Local Only announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Request Failed; rejection focuses the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Request Failed. Dynamic Type stacks explanations and controls. The announcement first communicates: The calendar permission request did not finish; Ambitions remains usable with local Time."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-REQUEST-FAILED-001"
label = "Check Again"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable", "The user explicitly retries or the app has returned to foreground; no system prompt is inferred"]
destination = "the freshly observed Calendar capability status from Calendar permission — Request Failed"
destination_id = "DEST-PERMISSIONS-CALENDAR-REQUEST-FAILED-001"
destination_posture = "current"
effect = "The Check Again external result causes no local canonical mutation; it re-reads current Calendar authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: The calendar permission request did not finish; Ambitions remains usable with local Time."
success_focus = "the resulting Calendar status, local fallback, or Check Again destination in Calendar permission — Request Failed"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-REQUEST-FAILED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Check Again control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Request Failed"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-REQUEST-FAILED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: authorization re-read and capability reconciliation remain externally sourced and cannot mutate canonical product data."
rollback_undo = "Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-REQUEST-FAILED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-REQUEST-FAILED-002"
label = "Use Local Only"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the fully usable local Calendar fallback from Calendar permission — Request Failed"
destination_id = "DEST-PERMISSIONS-CALENDAR-REQUEST-FAILED-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: The calendar permission request did not finish; Ambitions remains usable with local Time."
success_focus = "the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Request Failed"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-REQUEST-FAILED-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Request Failed"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-REQUEST-FAILED-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: choosing the local fallback performs no permission, canonical-data, or inferred-consent commit."
rollback_undo = "No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-REQUEST-FAILED-002"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-RESTRICTED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Use Local Only => destination: the fully usable local Calendar fallback from Calendar permission — Restricted; effect: No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar: Restricted. System policy prevents Ambitions from requesting or using this capability.; focus: the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Restricted."
durable_effect = "Exact contextual Calendar permission consequences: Use Local Only: No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar: Restricted. System policy prevents Ambitions from requesting or using this capability. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Calendar: Restricted. System policy prevents Ambitions from requesting or using this capability."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Use Local Only: No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Calendar: Restricted. System policy prevents Ambitions from requesting or using this capability."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Calendar: Restricted. System policy prevents Ambitions from requesting or using this capability."
accessibility_focus = "Deterministic entry focus is restricted status and local fallback. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Use Local Only announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Restricted; rejection focuses the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Restricted. Dynamic Type stacks explanations and controls. The announcement first communicates: Calendar: Restricted. System policy prevents Ambitions from requesting or using this capability."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-RESTRICTED-001"
label = "Use Local Only"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the fully usable local Calendar fallback from Calendar permission — Restricted"
destination_id = "DEST-PERMISSIONS-CALENDAR-RESTRICTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar: Restricted. System policy prevents Ambitions from requesting or using this capability."
success_focus = "the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Restricted"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-RESTRICTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Restricted"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-RESTRICTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: choosing the local fallback performs no permission, canonical-data, or inferred-consent commit."
rollback_undo = "No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-RESTRICTED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-REVOKED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Settings => destination: the Ambitions Calendar permission control in iOS Settings from Calendar permission — Revoked; effect: The Open Settings external result causes no local canonical mutation; system Settings owns authorization. On foreground return, Ambitions re-reads Calendar status and reconciles only the external-capability projection. Local objects remain unchanged. Visible evidence remains: Calendar access was turned off after being granted; Ambitions-owned time remains available.; focus: the resulting Calendar status, local fallback, or Open Settings destination in Calendar permission — Revoked.\nUse Local Only => destination: the fully usable local Calendar fallback from Calendar permission — Revoked; effect: No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar access was turned off after being granted; Ambitions-owned time remains available.; focus: the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Revoked."
durable_effect = "Exact contextual Calendar permission consequences: Open Settings: The Open Settings external result causes no local canonical mutation; system Settings owns authorization. On foreground return, Ambitions re-reads Calendar status and reconciles only the external-capability projection. Local objects remain unchanged. Visible evidence remains: Calendar access was turned off after being granted; Ambitions-owned time remains available. | Use Local Only: No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar access was turned off after being granted; Ambitions-owned time remains available. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Calendar access was turned off after being granted; Ambitions-owned time remains available."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Open Settings: Cancellation, unchanged status, or Settings-return failure preserves the prior known status and local fallback, focuses the recovery control, and triggers no repeated prompt. | Use Local Only: No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Calendar access was turned off after being granted; Ambitions-owned time remains available."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Calendar access was turned off after being granted; Ambitions-owned time remains available."
accessibility_focus = "Deterministic entry focus is revoked capability, preserved local objects, and recovery. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Open Settings announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Open Settings destination in Calendar permission — Revoked; rejection focuses the Open Settings control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Revoked | Use Local Only announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Revoked; rejection focuses the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Revoked. Dynamic Type stacks explanations and controls. The announcement first communicates: Calendar access was turned off after being granted; Ambitions-owned time remains available."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-REVOKED-001"
label = "Open Settings"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable", "The user explicitly selected the system Settings route after seeing current status and local fallback"]
destination = "the Ambitions Calendar permission control in iOS Settings from Calendar permission — Revoked"
destination_id = "DEST-PERMISSIONS-CALENDAR-REVOKED-001"
destination_posture = "current"
effect = "The Open Settings external result causes no local canonical mutation; system Settings owns authorization. On foreground return, Ambitions re-reads Calendar status and reconciles only the external-capability projection. Local objects remain unchanged. Visible evidence remains: Calendar access was turned off after being granted; Ambitions-owned time remains available."
success_focus = "the resulting Calendar status, local fallback, or Open Settings destination in Calendar permission — Revoked"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-REVOKED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open Settings control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Revoked"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-REVOKED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: Settings changes are externally owned; foreground reconciliation cannot infer consent or commit canonical product data."
rollback_undo = "Cancellation, unchanged status, or Settings-return failure preserves the prior known status and local fallback, focuses the recovery control, and triggers no repeated prompt."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-REVOKED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-REVOKED-002"
label = "Use Local Only"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the fully usable local Calendar fallback from Calendar permission — Revoked"
destination_id = "DEST-PERMISSIONS-CALENDAR-REVOKED-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar access was turned off after being granted; Ambitions-owned time remains available."
success_focus = "the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Revoked"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-REVOKED-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Revoked"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-REVOKED-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: choosing the local fallback performs no permission, canonical-data, or inferred-consent commit."
rollback_undo = "No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-REVOKED-002"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-SETTINGS-RETURN-FAILED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Check Again => destination: the freshly observed Calendar capability status from Calendar permission — Settings Return Failed; effect: The Check Again external result causes no local canonical mutation; it re-reads current Calendar authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Calendar access could not be rechecked after Settings; the prior known status remains visible.; focus: the resulting Calendar status, local fallback, or Check Again destination in Calendar permission — Settings Return Failed."
durable_effect = "Exact contextual Calendar permission consequences: Check Again: The Check Again external result causes no local canonical mutation; it re-reads current Calendar authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Calendar access could not be rechecked after Settings; the prior known status remains visible. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Calendar access could not be rechecked after Settings; the prior known status remains visible."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Check Again: Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Calendar access could not be rechecked after Settings; the prior known status remains visible."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Calendar access could not be rechecked after Settings; the prior known status remains visible."
accessibility_focus = "Deterministic entry focus is prior status and Check Again. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Check Again announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Check Again destination in Calendar permission — Settings Return Failed; rejection focuses the Check Again control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Settings Return Failed. Dynamic Type stacks explanations and controls. The announcement first communicates: Calendar access could not be rechecked after Settings; the prior known status remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-SETTINGS-RETURN-FAILED-001"
label = "Check Again"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable", "The user explicitly retries or the app has returned to foreground; no system prompt is inferred"]
destination = "the freshly observed Calendar capability status from Calendar permission — Settings Return Failed"
destination_id = "DEST-PERMISSIONS-CALENDAR-SETTINGS-RETURN-FAILED-001"
destination_posture = "current"
effect = "The Check Again external result causes no local canonical mutation; it re-reads current Calendar authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Calendar access could not be rechecked after Settings; the prior known status remains visible."
success_focus = "the resulting Calendar status, local fallback, or Check Again destination in Calendar permission — Settings Return Failed"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-SETTINGS-RETURN-FAILED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Check Again control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Settings Return Failed"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-SETTINGS-RETURN-FAILED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: authorization re-read and capability reconciliation remain externally sourced and cannot mutate canonical product data."
rollback_undo = "Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-SETTINGS-RETURN-FAILED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-UNAVAILABLE"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Use Local Only => destination: the fully usable local Calendar fallback from Calendar permission — Unavailable; effect: No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar: Unavailable. This capability is unavailable on this device or configuration.; focus: the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Unavailable."
durable_effect = "Exact contextual Calendar permission consequences: Use Local Only: No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar: Unavailable. This capability is unavailable on this device or configuration. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Calendar: Unavailable. This capability is unavailable on this device or configuration."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Use Local Only: No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Calendar: Unavailable. This capability is unavailable on this device or configuration."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Calendar authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Calendar: Unavailable. This capability is unavailable on this device or configuration."
accessibility_focus = "Deterministic entry focus is unavailable reason and local fallback. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Use Local Only announces authorization and fallback consequence; success focuses the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Unavailable; rejection focuses the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Unavailable. Dynamic Type stacks explanations and controls. The announcement first communicates: Calendar: Unavailable. This capability is unavailable on this device or configuration."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-CALENDAR-UNAVAILABLE-001"
label = "Use Local Only"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Calendar authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the fully usable local Calendar fallback from Calendar permission — Unavailable"
destination_id = "DEST-PERMISSIONS-CALENDAR-UNAVAILABLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Use Local Only continues without Calendar access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Calendar: Unavailable. This capability is unavailable on this device or configuration."
success_focus = "the resulting Calendar status, local fallback, or Use Local Only destination in Calendar permission — Unavailable"
success_focus_id = "FOCUS-PERMISSIONS-CALENDAR-UNAVAILABLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Calendar permission — Unavailable"
failure_focus_id = "FOCUS-PERMISSIONS-CALENDAR-UNAVAILABLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: choosing the local fallback performs no permission, canonical-data, or inferred-consent commit."
rollback_undo = "No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation."
recovery_id = "RECOVERY-PERMISSIONS-CALENDAR-UNAVAILABLE-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Calendar permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-AUTHORIZED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the initiating local feature or You permission context from Notification permission — Authorized; effect: No durable mutation occurs and no Receipt is created; Done closes only the confirmed Notifications status. Authorization observation, local objects, and external capability remain unchanged. Visible evidence remains: Notification access is allowed. Saved Goals, Steps, and time remain unchanged.; focus: the resulting Notifications status, local fallback, or Done destination in Notification permission — Authorized."
durable_effect = "Exact contextual Notifications permission consequences: Done: No durable mutation occurs and no Receipt is created; Done closes only the confirmed Notifications status. Authorization observation, local objects, and external capability remain unchanged. Visible evidence remains: Notification access is allowed. Saved Goals, Steps, and time remain unchanged. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Notification access is allowed. Saved Goals, Steps, and time remain unchanged."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Done: No Undo is required; reopening the capability shows the current revalidated status and local fallback. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Notification access is allowed. Saved Goals, Steps, and time remain unchanged."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Notification access is allowed. Saved Goals, Steps, and time remain unchanged."
accessibility_focus = "Deterministic entry focus is enabled capability result. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Done announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Done destination in Notification permission — Authorized; rejection focuses the Done control and exact authorization, eligibility, or Settings-return reason in Notification permission — Authorized. Dynamic Type stacks explanations and controls. The announcement first communicates: Notification access is allowed. Saved Goals, Steps, and time remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-AUTHORIZED-001"
label = "Done"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the initiating local feature or You permission context from Notification permission — Authorized"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-AUTHORIZED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done closes only the confirmed Notifications status. Authorization observation, local objects, and external capability remain unchanged. Visible evidence remains: Notification access is allowed. Saved Goals, Steps, and time remain unchanged."
success_focus = "the resulting Notifications status, local fallback, or Done destination in Notification permission — Authorized"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-AUTHORIZED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and exact authorization, eligibility, or Settings-return reason in Notification permission — Authorized"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-AUTHORIZED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: status dismissal cannot grant, revoke, reconcile, or mutate permission or product data."
rollback_undo = "No Undo is required; reopening the capability shows the current revalidated status and local fallback."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-AUTHORIZED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-DENIED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Settings => destination: the Ambitions Notifications permission control in iOS Settings from Notification permission — Denied; effect: The Open Settings external result causes no local canonical mutation; system Settings owns authorization. On foreground return, Ambitions re-reads Notifications status and reconciles only the external-capability projection. Local objects remain unchanged. Visible evidence remains: Notification access is not allowed. Saved Goals, Steps, and time remain available.; focus: the resulting Notifications status, local fallback, or Open Settings destination in Notification permission — Denied.\nUse Local Only => destination: the fully usable local Notifications fallback from Notification permission — Denied; effect: No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notification access is not allowed. Saved Goals, Steps, and time remain available.; focus: the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Denied."
durable_effect = "Exact contextual Notifications permission consequences: Open Settings: The Open Settings external result causes no local canonical mutation; system Settings owns authorization. On foreground return, Ambitions re-reads Notifications status and reconciles only the external-capability projection. Local objects remain unchanged. Visible evidence remains: Notification access is not allowed. Saved Goals, Steps, and time remain available. | Use Local Only: No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notification access is not allowed. Saved Goals, Steps, and time remain available. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Notification access is not allowed. Saved Goals, Steps, and time remain available."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Open Settings: Cancellation, unchanged status, or Settings-return failure preserves the prior known status and local fallback, focuses the recovery control, and triggers no repeated prompt. | Use Local Only: No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Notification access is not allowed. Saved Goals, Steps, and time remain available."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Notification access is not allowed. Saved Goals, Steps, and time remain available."
accessibility_focus = "Deterministic entry focus is denied status, local fallback, and Open Settings. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Open Settings announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Open Settings destination in Notification permission — Denied; rejection focuses the Open Settings control and exact authorization, eligibility, or Settings-return reason in Notification permission — Denied | Use Local Only announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Denied; rejection focuses the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Notification permission — Denied. Dynamic Type stacks explanations and controls. The announcement first communicates: Notification access is not allowed. Saved Goals, Steps, and time remain available."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-DENIED-001"
label = "Open Settings"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable", "The user explicitly selected the system Settings route after seeing current status and local fallback"]
destination = "the Ambitions Notifications permission control in iOS Settings from Notification permission — Denied"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-DENIED-001"
destination_posture = "current"
effect = "The Open Settings external result causes no local canonical mutation; system Settings owns authorization. On foreground return, Ambitions re-reads Notifications status and reconciles only the external-capability projection. Local objects remain unchanged. Visible evidence remains: Notification access is not allowed. Saved Goals, Steps, and time remain available."
success_focus = "the resulting Notifications status, local fallback, or Open Settings destination in Notification permission — Denied"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-DENIED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open Settings control and exact authorization, eligibility, or Settings-return reason in Notification permission — Denied"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-DENIED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: Settings changes are externally owned; foreground reconciliation cannot infer consent or commit canonical product data."
rollback_undo = "Cancellation, unchanged status, or Settings-return failure preserves the prior known status and local fallback, focuses the recovery control, and triggers no repeated prompt."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-DENIED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-DENIED-002"
label = "Use Local Only"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the fully usable local Notifications fallback from Notification permission — Denied"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-DENIED-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notification access is not allowed. Saved Goals, Steps, and time remain available."
success_focus = "the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Denied"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-DENIED-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Notification permission — Denied"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-DENIED-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: choosing the local fallback performs no permission, canonical-data, or inferred-consent commit."
rollback_undo = "No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-DENIED-002"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-ELIGIBILITY-CHECK"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Check Again => destination: the freshly observed Notifications capability status from Notification permission — Eligibility Check; effect: The Check Again external result causes no local canonical mutation; it re-reads current Notifications authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Notification permission availability is being checked. Existing notification settings and saved Steps remain as they were.; focus: the resulting Notifications status, local fallback, or Check Again destination in Notification permission — Eligibility Check."
durable_effect = "Exact contextual Notifications permission consequences: Check Again: The Check Again external result causes no local canonical mutation; it re-reads current Notifications authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Notification permission availability is being checked. Existing notification settings and saved Steps remain as they were. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Notification permission availability is being checked. Existing notification settings and saved Steps remain as they were."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Check Again: Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Notification permission availability is being checked. Existing notification settings and saved Steps remain as they were."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Notification permission availability is being checked. Existing notification settings and saved Steps remain as they were."
accessibility_focus = "Deterministic entry focus is eligibility heading and current request reason. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Check Again announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Check Again destination in Notification permission — Eligibility Check; rejection focuses the Check Again control and exact authorization, eligibility, or Settings-return reason in Notification permission — Eligibility Check. Dynamic Type stacks explanations and controls. The announcement first communicates: Notification permission availability is being checked. Existing notification settings and saved Steps remain as they were."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-ELIGIBILITY-CHECK-001"
label = "Check Again"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable", "The user explicitly retries or the app has returned to foreground; no system prompt is inferred"]
destination = "the freshly observed Notifications capability status from Notification permission — Eligibility Check"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-ELIGIBILITY-CHECK-001"
destination_posture = "current"
effect = "The Check Again external result causes no local canonical mutation; it re-reads current Notifications authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Notification permission availability is being checked. Existing notification settings and saved Steps remain as they were."
success_focus = "the resulting Notifications status, local fallback, or Check Again destination in Notification permission — Eligibility Check"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-ELIGIBILITY-CHECK-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Check Again control and exact authorization, eligibility, or Settings-return reason in Notification permission — Eligibility Check"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-ELIGIBILITY-CHECK-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: authorization re-read and capability reconciliation remain externally sourced and cannot mutate canonical product data."
rollback_undo = "Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-ELIGIBILITY-CHECK-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-LIMITED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Access => destination: the exact available and unavailable Notifications scope with local fallback from Notification permission — Limited; effect: No durable mutation occurs and no Receipt is created; Review Access explains the current limited, partial, denied, restricted, or unavailable scope without requesting permission, revealing hidden fields, or changing local objects. Visible evidence remains: Notifications: Limited. Only a limited system-selected scope is available.; focus: the resulting Notifications status, local fallback, or Review Access destination in Notification permission — Limited."
durable_effect = "Exact contextual Notifications permission consequences: Review Access: No durable mutation occurs and no Receipt is created; Review Access explains the current limited, partial, denied, restricted, or unavailable scope without requesting permission, revealing hidden fields, or changing local objects. Visible evidence remains: Notifications: Limited. Only a limited system-selected scope is available. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Notifications: Limited. Only a limited system-selected scope is available."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Review Access: No Undo is required; dismissal returns to the exact prior capability status and preserves all local content. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Notifications: Limited. Only a limited system-selected scope is available."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Notifications: Limited. Only a limited system-selected scope is available."
accessibility_focus = "Deterministic entry focus is exact available and unavailable scope plus Review Access. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Review Access announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Review Access destination in Notification permission — Limited; rejection focuses the Review Access control and exact authorization, eligibility, or Settings-return reason in Notification permission — Limited. Dynamic Type stacks explanations and controls. The announcement first communicates: Notifications: Limited. Only a limited system-selected scope is available."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-LIMITED-001"
label = "Review Access"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the exact available and unavailable Notifications scope with local fallback from Notification permission — Limited"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-LIMITED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Access explains the current limited, partial, denied, restricted, or unavailable scope without requesting permission, revealing hidden fields, or changing local objects. Visible evidence remains: Notifications: Limited. Only a limited system-selected scope is available."
success_focus = "the resulting Notifications status, local fallback, or Review Access destination in Notification permission — Limited"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-LIMITED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Access control and exact authorization, eligibility, or Settings-return reason in Notification permission — Limited"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-LIMITED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: access inspection remains explanatory and crosses no system or canonical commit boundary."
rollback_undo = "No Undo is required; dismissal returns to the exact prior capability status and preserves all local content."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-LIMITED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-LOCAL-FALLBACK"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Use Local Only => destination: the fully usable local Notifications fallback from Notification permission — Local Fallback; effect: No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notifications: Local Fallback. The feature continues locally without the unavailable system capability.; focus: the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Local Fallback."
durable_effect = "Exact contextual Notifications permission consequences: Use Local Only: No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notifications: Local Fallback. The feature continues locally without the unavailable system capability. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Notifications: Local Fallback. The feature continues locally without the unavailable system capability."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Use Local Only: No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Notifications: Local Fallback. The feature continues locally without the unavailable system capability."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Notifications: Local Fallback. The feature continues locally without the unavailable system capability."
accessibility_focus = "Deterministic entry focus is local fallback result. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Use Local Only announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Local Fallback; rejection focuses the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Notification permission — Local Fallback. Dynamic Type stacks explanations and controls. The announcement first communicates: Notifications: Local Fallback. The feature continues locally without the unavailable system capability."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-LOCAL-FALLBACK-001"
label = "Use Local Only"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the fully usable local Notifications fallback from Notification permission — Local Fallback"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-LOCAL-FALLBACK-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notifications: Local Fallback. The feature continues locally without the unavailable system capability."
success_focus = "the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Local Fallback"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-LOCAL-FALLBACK-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Notification permission — Local Fallback"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-LOCAL-FALLBACK-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: choosing the local fallback performs no permission, canonical-data, or inferred-consent commit."
rollback_undo = "No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-LOCAL-FALLBACK-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-NOT-DETERMINED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Allow Notifications => destination: the native Notifications system permission prompt, then the exact resulting capability status from Notification permission — Not Determined; effect: The Allow Notifications external result causes no local canonical mutation; the system prompt alone owns Notifications authorization. Ambitions records no Goal, Step, Event, Capture, Rule, or private graph change from prompting or authorization, and foreground return re-reads the actual status before capability reconciliation. Visible evidence remains until the system result: Notifications: Not Asked. Ambitions has not requested this permission.; focus: the resulting Notifications status, local fallback, or Allow Notifications destination in Notification permission — Not Determined.\nNot Now => destination: the initiating local feature with Notifications fallback from Notification permission — Not Determined; effect: No durable mutation occurs and no Receipt is created; Not Now dismisses the contextual request without inferred consent, repeated prompting, or replay of the initiating action. Local core behavior remains available. Visible evidence remains: Notifications: Not Asked. Ambitions has not requested this permission.; focus: the resulting Notifications status, local fallback, or Not Now destination in Notification permission — Not Determined."
durable_effect = "Exact contextual Notifications permission consequences: Allow Notifications: The Allow Notifications external result causes no local canonical mutation; the system prompt alone owns Notifications authorization. Ambitions records no Goal, Step, Event, Capture, Rule, or private graph change from prompting or authorization, and foreground return re-reads the actual status before capability reconciliation. Visible evidence remains until the system result: Notifications: Not Asked. Ambitions has not requested this permission. | Not Now: No durable mutation occurs and no Receipt is created; Not Now dismisses the contextual request without inferred consent, repeated prompting, or replay of the initiating action. Local core behavior remains available. Visible evidence remains: Notifications: Not Asked. Ambitions has not requested this permission. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Notifications: Not Asked. Ambitions has not requested this permission."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Allow Notifications: Cancellation, denial, interruption, or prompt failure preserves all local objects and returns focus to the status and local fallback; Ambitions does not prompt again without new explicit intent and eligibility. | Not Now: No Undo is required; later prompting requires fresh explicit intent, relevance, eligibility, scope explanation, and fallback. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Notifications: Not Asked. Ambitions has not requested this permission."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Notifications: Not Asked. Ambitions has not requested this permission."
accessibility_focus = "Deterministic entry focus is permission purpose and primary Allow Notifications command. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Allow Notifications announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Allow Notifications destination in Notification permission — Not Determined; rejection focuses the Allow Notifications control and exact authorization, eligibility, or Settings-return reason in Notification permission — Not Determined | Not Now announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Not Now destination in Notification permission — Not Determined; rejection focuses the Not Now control and exact authorization, eligibility, or Settings-return reason in Notification permission — Not Determined. Dynamic Type stacks explanations and controls. The announcement first communicates: Notifications: Not Asked. Ambitions has not requested this permission."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-NOT-DETERMINED-001"
label = "Allow Notifications"
canonical_owner = "app.permissions.command-contract"
preconditions = ["A plain scope explanation names every requested field and system consequence", "Explicit user intent selected a permission-dependent feature", "Feature relevance is current and the requested capability is necessary for the chosen action", "Request eligibility is confirmed and no prior denial, restriction, or system prohibition permits another prompt", "The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The local fallback and unavailable behavior are explained before the system prompt", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the native Notifications system permission prompt, then the exact resulting capability status from Notification permission — Not Determined"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-NOT-DETERMINED-001"
destination_posture = "current"
effect = "The Allow Notifications external result causes no local canonical mutation; the system prompt alone owns Notifications authorization. Ambitions records no Goal, Step, Event, Capture, Rule, or private graph change from prompting or authorization, and foreground return re-reads the actual status before capability reconciliation. Visible evidence remains until the system result: Notifications: Not Asked. Ambitions has not requested this permission."
success_focus = "the resulting Notifications status, local fallback, or Allow Notifications destination in Notification permission — Not Determined"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-NOT-DETERMINED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Allow Notifications control and exact authorization, eligibility, or Settings-return reason in Notification permission — Not Determined"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-NOT-DETERMINED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: the system permission prompt owns authorization and cannot commit canonical product data or replay the user’s rejected action."
rollback_undo = "Cancellation, denial, interruption, or prompt failure preserves all local objects and returns focus to the status and local fallback; Ambitions does not prompt again without new explicit intent and eligibility."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-NOT-DETERMINED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-NOT-DETERMINED-002"
label = "Not Now"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the initiating local feature with Notifications fallback from Notification permission — Not Determined"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-NOT-DETERMINED-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Not Now dismisses the contextual request without inferred consent, repeated prompting, or replay of the initiating action. Local core behavior remains available. Visible evidence remains: Notifications: Not Asked. Ambitions has not requested this permission."
success_focus = "the resulting Notifications status, local fallback, or Not Now destination in Notification permission — Not Determined"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-NOT-DETERMINED-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Not Now control and exact authorization, eligibility, or Settings-return reason in Notification permission — Not Determined"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-NOT-DETERMINED-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: declining or postponing a permission crosses no authorization or canonical product-data boundary."
rollback_undo = "No Undo is required; later prompting requires fresh explicit intent, relevance, eligibility, scope explanation, and fallback."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-NOT-DETERMINED-002"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-PARTIAL-EXTERNAL-ACCESS"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Access => destination: the exact available and unavailable Notifications scope with local fallback from Notification permission — Partial External Access; effect: No durable mutation occurs and no Receipt is created; Review Access explains the current limited, partial, denied, restricted, or unavailable scope without requesting permission, revealing hidden fields, or changing local objects. Visible evidence remains: Only some notification capability is available; unsupported delivery remains clearly unavailable.; focus: the resulting Notifications status, local fallback, or Review Access destination in Notification permission — Partial External Access."
durable_effect = "Exact contextual Notifications permission consequences: Review Access: No durable mutation occurs and no Receipt is created; Review Access explains the current limited, partial, denied, restricted, or unavailable scope without requesting permission, revealing hidden fields, or changing local objects. Visible evidence remains: Only some notification capability is available; unsupported delivery remains clearly unavailable. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Only some notification capability is available; unsupported delivery remains clearly unavailable."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Review Access: No Undo is required; dismissal returns to the exact prior capability status and preserves all local content. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Only some notification capability is available; unsupported delivery remains clearly unavailable."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Only some notification capability is available; unsupported delivery remains clearly unavailable."
accessibility_focus = "Deterministic entry focus is exact available and unavailable scope plus Review Access. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Review Access announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Review Access destination in Notification permission — Partial External Access; rejection focuses the Review Access control and exact authorization, eligibility, or Settings-return reason in Notification permission — Partial External Access. Dynamic Type stacks explanations and controls. The announcement first communicates: Only some notification capability is available; unsupported delivery remains clearly unavailable."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-PARTIAL-EXTERNAL-ACCESS-001"
label = "Review Access"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the exact available and unavailable Notifications scope with local fallback from Notification permission — Partial External Access"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-PARTIAL-EXTERNAL-ACCESS-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Access explains the current limited, partial, denied, restricted, or unavailable scope without requesting permission, revealing hidden fields, or changing local objects. Visible evidence remains: Only some notification capability is available; unsupported delivery remains clearly unavailable."
success_focus = "the resulting Notifications status, local fallback, or Review Access destination in Notification permission — Partial External Access"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-PARTIAL-EXTERNAL-ACCESS-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Access control and exact authorization, eligibility, or Settings-return reason in Notification permission — Partial External Access"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-PARTIAL-EXTERNAL-ACCESS-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: access inspection remains explanatory and crosses no system or canonical commit boundary."
rollback_undo = "No Undo is required; dismissal returns to the exact prior capability status and preserves all local content."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-PARTIAL-EXTERNAL-ACCESS-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-RECONCILING"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Check Again => destination: the freshly observed Notifications capability status from Notification permission — Reconciling; effect: The Check Again external result causes no local canonical mutation; it re-reads current Notifications authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Notifications: Refreshing. Ambitions is reconciling the current system permission after returning from Settings.; focus: the resulting Notifications status, local fallback, or Check Again destination in Notification permission — Reconciling."
durable_effect = "Exact contextual Notifications permission consequences: Check Again: The Check Again external result causes no local canonical mutation; it re-reads current Notifications authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Notifications: Refreshing. Ambitions is reconciling the current system permission after returning from Settings. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Notifications: Refreshing. Ambitions is reconciling the current system permission after returning from Settings."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Check Again: Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Notifications: Refreshing. Ambitions is reconciling the current system permission after returning from Settings."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Notifications: Refreshing. Ambitions is reconciling the current system permission after returning from Settings."
accessibility_focus = "Deterministic entry focus is reconciliation heading. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Check Again announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Check Again destination in Notification permission — Reconciling; rejection focuses the Check Again control and exact authorization, eligibility, or Settings-return reason in Notification permission — Reconciling. Dynamic Type stacks explanations and controls. The announcement first communicates: Notifications: Refreshing. Ambitions is reconciling the current system permission after returning from Settings."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-RECONCILING-001"
label = "Check Again"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable", "The user explicitly retries or the app has returned to foreground; no system prompt is inferred"]
destination = "the freshly observed Notifications capability status from Notification permission — Reconciling"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-RECONCILING-001"
destination_posture = "current"
effect = "The Check Again external result causes no local canonical mutation; it re-reads current Notifications authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Notifications: Refreshing. Ambitions is reconciling the current system permission after returning from Settings."
success_focus = "the resulting Notifications status, local fallback, or Check Again destination in Notification permission — Reconciling"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-RECONCILING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Check Again control and exact authorization, eligibility, or Settings-return reason in Notification permission — Reconciling"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-RECONCILING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: authorization re-read and capability reconciliation remain externally sourced and cannot mutate canonical product data."
rollback_undo = "Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-RECONCILING-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-REQUEST-FAILED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Check Again => destination: the freshly observed Notifications capability status from Notification permission — Request Failed; effect: The Check Again external result causes no local canonical mutation; it re-reads current Notifications authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: The notification permission request did not finish; Ambitions remains usable without alerts.; focus: the resulting Notifications status, local fallback, or Check Again destination in Notification permission — Request Failed.\nUse Local Only => destination: the fully usable local Notifications fallback from Notification permission — Request Failed; effect: No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: The notification permission request did not finish; Ambitions remains usable without alerts.; focus: the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Request Failed."
durable_effect = "Exact contextual Notifications permission consequences: Check Again: The Check Again external result causes no local canonical mutation; it re-reads current Notifications authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: The notification permission request did not finish; Ambitions remains usable without alerts. | Use Local Only: No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: The notification permission request did not finish; Ambitions remains usable without alerts. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: The notification permission request did not finish; Ambitions remains usable without alerts."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Check Again: Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action. | Use Local Only: No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: The notification permission request did not finish; Ambitions remains usable without alerts."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: The notification permission request did not finish; Ambitions remains usable without alerts."
accessibility_focus = "Deterministic entry focus is failed request reason, Check Again, and local fallback. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Check Again announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Check Again destination in Notification permission — Request Failed; rejection focuses the Check Again control and exact authorization, eligibility, or Settings-return reason in Notification permission — Request Failed | Use Local Only announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Request Failed; rejection focuses the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Notification permission — Request Failed. Dynamic Type stacks explanations and controls. The announcement first communicates: The notification permission request did not finish; Ambitions remains usable without alerts."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-REQUEST-FAILED-001"
label = "Check Again"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable", "The user explicitly retries or the app has returned to foreground; no system prompt is inferred"]
destination = "the freshly observed Notifications capability status from Notification permission — Request Failed"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-REQUEST-FAILED-001"
destination_posture = "current"
effect = "The Check Again external result causes no local canonical mutation; it re-reads current Notifications authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: The notification permission request did not finish; Ambitions remains usable without alerts."
success_focus = "the resulting Notifications status, local fallback, or Check Again destination in Notification permission — Request Failed"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-REQUEST-FAILED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Check Again control and exact authorization, eligibility, or Settings-return reason in Notification permission — Request Failed"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-REQUEST-FAILED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: authorization re-read and capability reconciliation remain externally sourced and cannot mutate canonical product data."
rollback_undo = "Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-REQUEST-FAILED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-REQUEST-FAILED-002"
label = "Use Local Only"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the fully usable local Notifications fallback from Notification permission — Request Failed"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-REQUEST-FAILED-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: The notification permission request did not finish; Ambitions remains usable without alerts."
success_focus = "the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Request Failed"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-REQUEST-FAILED-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Notification permission — Request Failed"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-REQUEST-FAILED-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: choosing the local fallback performs no permission, canonical-data, or inferred-consent commit."
rollback_undo = "No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-REQUEST-FAILED-002"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-RESTRICTED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Use Local Only => destination: the fully usable local Notifications fallback from Notification permission — Restricted; effect: No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notifications: Restricted. System policy prevents Ambitions from requesting or using this capability.; focus: the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Restricted."
durable_effect = "Exact contextual Notifications permission consequences: Use Local Only: No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notifications: Restricted. System policy prevents Ambitions from requesting or using this capability. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Notifications: Restricted. System policy prevents Ambitions from requesting or using this capability."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Use Local Only: No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Notifications: Restricted. System policy prevents Ambitions from requesting or using this capability."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Notifications: Restricted. System policy prevents Ambitions from requesting or using this capability."
accessibility_focus = "Deterministic entry focus is restricted status and local fallback. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Use Local Only announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Restricted; rejection focuses the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Notification permission — Restricted. Dynamic Type stacks explanations and controls. The announcement first communicates: Notifications: Restricted. System policy prevents Ambitions from requesting or using this capability."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-RESTRICTED-001"
label = "Use Local Only"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the fully usable local Notifications fallback from Notification permission — Restricted"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-RESTRICTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notifications: Restricted. System policy prevents Ambitions from requesting or using this capability."
success_focus = "the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Restricted"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-RESTRICTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Notification permission — Restricted"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-RESTRICTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: choosing the local fallback performs no permission, canonical-data, or inferred-consent commit."
rollback_undo = "No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-RESTRICTED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-REVOKED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Settings => destination: the Ambitions Notifications permission control in iOS Settings from Notification permission — Revoked; effect: The Open Settings external result causes no local canonical mutation; system Settings owns authorization. On foreground return, Ambitions re-reads Notifications status and reconciles only the external-capability projection. Local objects remain unchanged. Visible evidence remains: Notification access was turned off after being allowed. Saved Goals, Steps, and time remain unchanged.; focus: the resulting Notifications status, local fallback, or Open Settings destination in Notification permission — Revoked.\nUse Local Only => destination: the fully usable local Notifications fallback from Notification permission — Revoked; effect: No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notification access was turned off after being allowed. Saved Goals, Steps, and time remain unchanged.; focus: the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Revoked."
durable_effect = "Exact contextual Notifications permission consequences: Open Settings: The Open Settings external result causes no local canonical mutation; system Settings owns authorization. On foreground return, Ambitions re-reads Notifications status and reconciles only the external-capability projection. Local objects remain unchanged. Visible evidence remains: Notification access was turned off after being allowed. Saved Goals, Steps, and time remain unchanged. | Use Local Only: No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notification access was turned off after being allowed. Saved Goals, Steps, and time remain unchanged. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Notification access was turned off after being allowed. Saved Goals, Steps, and time remain unchanged."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Open Settings: Cancellation, unchanged status, or Settings-return failure preserves the prior known status and local fallback, focuses the recovery control, and triggers no repeated prompt. | Use Local Only: No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Notification access was turned off after being allowed. Saved Goals, Steps, and time remain unchanged."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Notification access was turned off after being allowed. Saved Goals, Steps, and time remain unchanged."
accessibility_focus = "Deterministic entry focus is revoked capability, preserved local objects, and recovery. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Open Settings announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Open Settings destination in Notification permission — Revoked; rejection focuses the Open Settings control and exact authorization, eligibility, or Settings-return reason in Notification permission — Revoked | Use Local Only announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Revoked; rejection focuses the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Notification permission — Revoked. Dynamic Type stacks explanations and controls. The announcement first communicates: Notification access was turned off after being allowed. Saved Goals, Steps, and time remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-REVOKED-001"
label = "Open Settings"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable", "The user explicitly selected the system Settings route after seeing current status and local fallback"]
destination = "the Ambitions Notifications permission control in iOS Settings from Notification permission — Revoked"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-REVOKED-001"
destination_posture = "current"
effect = "The Open Settings external result causes no local canonical mutation; system Settings owns authorization. On foreground return, Ambitions re-reads Notifications status and reconciles only the external-capability projection. Local objects remain unchanged. Visible evidence remains: Notification access was turned off after being allowed. Saved Goals, Steps, and time remain unchanged."
success_focus = "the resulting Notifications status, local fallback, or Open Settings destination in Notification permission — Revoked"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-REVOKED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open Settings control and exact authorization, eligibility, or Settings-return reason in Notification permission — Revoked"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-REVOKED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: Settings changes are externally owned; foreground reconciliation cannot infer consent or commit canonical product data."
rollback_undo = "Cancellation, unchanged status, or Settings-return failure preserves the prior known status and local fallback, focuses the recovery control, and triggers no repeated prompt."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-REVOKED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-REVOKED-002"
label = "Use Local Only"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the fully usable local Notifications fallback from Notification permission — Revoked"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-REVOKED-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notification access was turned off after being allowed. Saved Goals, Steps, and time remain unchanged."
success_focus = "the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Revoked"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-REVOKED-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Notification permission — Revoked"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-REVOKED-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: choosing the local fallback performs no permission, canonical-data, or inferred-consent commit."
rollback_undo = "No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-REVOKED-002"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-SETTINGS-RETURN-FAILED"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Check Again => destination: the freshly observed Notifications capability status from Notification permission — Settings Return Failed; effect: The Check Again external result causes no local canonical mutation; it re-reads current Notifications authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Notification access could not be rechecked after Settings; the prior known status remains visible.; focus: the resulting Notifications status, local fallback, or Check Again destination in Notification permission — Settings Return Failed."
durable_effect = "Exact contextual Notifications permission consequences: Check Again: The Check Again external result causes no local canonical mutation; it re-reads current Notifications authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Notification access could not be rechecked after Settings; the prior known status remains visible. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Notification access could not be rechecked after Settings; the prior known status remains visible."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Check Again: Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Notification access could not be rechecked after Settings; the prior known status remains visible."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Notification access could not be rechecked after Settings; the prior known status remains visible."
accessibility_focus = "Deterministic entry focus is prior status and Check Again. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Check Again announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Check Again destination in Notification permission — Settings Return Failed; rejection focuses the Check Again control and exact authorization, eligibility, or Settings-return reason in Notification permission — Settings Return Failed. Dynamic Type stacks explanations and controls. The announcement first communicates: Notification access could not be rechecked after Settings; the prior known status remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-SETTINGS-RETURN-FAILED-001"
label = "Check Again"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable", "The user explicitly retries or the app has returned to foreground; no system prompt is inferred"]
destination = "the freshly observed Notifications capability status from Notification permission — Settings Return Failed"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-SETTINGS-RETURN-FAILED-001"
destination_posture = "current"
effect = "The Check Again external result causes no local canonical mutation; it re-reads current Notifications authorization and updates only the external-capability observation after validation. Revocation marks the capability unavailable or stale while preserving every local object, accepted input, and prior status until a reliable result exists. Visible evidence remains: Notification access could not be rechecked after Settings; the prior known status remains visible."
success_focus = "the resulting Notifications status, local fallback, or Check Again destination in Notification permission — Settings Return Failed"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-SETTINGS-RETURN-FAILED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Check Again control and exact authorization, eligibility, or Settings-return reason in Notification permission — Settings Return Failed"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-SETTINGS-RETURN-FAILED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: authorization re-read and capability reconciliation remain externally sourced and cannot mutate canonical product data."
rollback_undo = "Failure preserves the prior known status, local fallback, and objects; another Check Again requires explicit retry or a new foreground return and cannot replay a rejected action."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-SETTINGS-RETURN-FAILED-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-UNAVAILABLE"
requirement_id = "APP-PERMISSIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Use Local Only => destination: the fully usable local Notifications fallback from Notification permission — Unavailable; effect: No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notifications: Unavailable. This capability is unavailable on this device or configuration.; focus: the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Unavailable."
durable_effect = "Exact contextual Notifications permission consequences: Use Local Only: No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notifications: Unavailable. This capability is unavailable on this device or configuration. The system prompt owns authorization and never commits canonical product data; revocation preserves local objects and marks only external capability unavailable or stale. Current visible status: Notifications: Unavailable. This capability is unavailable on this device or configuration."
recovery_rollback = "Exact denial, restriction, partial access, request failure, foreground reread, Settings return, and local fallback recovery: Use Local Only: No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation. Repeated prompting, inferred consent, and replay of a rejected action are forbidden. Recovery preserves: Notifications: Unavailable. This capability is unavailable on this device or configuration."
offline_behavior = "The complete local core, local Time, Rules, Goals, Steps, Captures, settings, History, and Receipts remain usable offline without Notifications authorization. System prompts and Settings routes wait for platform availability. Offline evidence remains: Notifications: Unavailable. This capability is unavailable on this device or configuration."
accessibility_focus = "Deterministic entry focus is unavailable reason and local fallback. VoiceOver announces purpose, scope, system ownership, local fallback, unavailable fields, and consequence without color dependence: Use Local Only announces authorization and fallback consequence; success focuses the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Unavailable; rejection focuses the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Notification permission — Unavailable. Dynamic Type stacks explanations and controls. The announcement first communicates: Notifications: Unavailable. This capability is unavailable on this device or configuration."

[[state_command_contracts.commands]]
command_id = "CMD-PERMISSIONS-NOTIFICATIONS-UNAVAILABLE-001"
label = "Use Local Only"
canonical_owner = "app.permissions.command-contract"
preconditions = ["The current Notifications authorization observation, request history, and foreground revision have been revalidated", "The prior status and unaffected local fallback remain visible and usable"]
destination = "the fully usable local Notifications fallback from Notification permission — Unavailable"
destination_id = "DEST-PERMISSIONS-NOTIFICATIONS-UNAVAILABLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Use Local Only continues without Notifications access and without another prompt. Local Goals, Steps, Events, Captures, Rules, settings, History, and Receipts remain available. Visible evidence remains: Notifications: Unavailable. This capability is unavailable on this device or configuration."
success_focus = "the resulting Notifications status, local fallback, or Use Local Only destination in Notification permission — Unavailable"
success_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-UNAVAILABLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Use Local Only control and exact authorization, eligibility, or Settings-return reason in Notification permission — Unavailable"
failure_focus_id = "FOCUS-PERMISSIONS-NOTIFICATIONS-UNAVAILABLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: choosing the local fallback performs no permission, canonical-data, or inferred-consent commit."
rollback_undo = "No Undo is required; the user may later choose a relevant permission-dependent feature, which must restart contextual eligibility and explanation."
recovery_id = "RECOVERY-PERMISSIONS-NOTIFICATIONS-UNAVAILABLE-001"
recovery_posture = "current"
recovery_owner = "app.permissions.command-contract"
privacy_egress = "The system receives only the native Notifications permission request; Ambitions sends no private life graph content, and partial or denied access never reveals unavailable external fields."
verification_ids = ["SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

+++

# Contextual Permissions

This specification defines permission request, denial, recovery, and reconciliation behavior.

## APP-PERMISSIONS-CONTRACT-001 — Every request explains its boundary

- **Concept:** `app.permissions.contextual-request`
- **Modality:** `MUST`
- **Scope:** Every system or app-managed permission request
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-PERMISSION-REQUEST-001`, `AUDIT-APP-PERMISSION-COPY-001`
- **Supersedes:** none

Every permission request MUST occur in the context of a user-understandable feature and state: what the feature needs, what Ambitions reads or writes, what remains available without permission, and where the choice can later be changed. The app asks only when the capability is relevant and the user has a meaningful choice. Setup may explain a future capability but cannot batch-request unrelated access or treat consent as mandatory product completion.

Ambitions MUST NOT open with a permission wall.

## APP-PERMISSION-DENIAL-001 — Denial preserves useful local behavior

- **Concept:** `app.permissions.denied-fallback`
- **Modality:** `MUST`
- **Scope:** Denied, restricted, unavailable, or not-yet-requested permission states
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-PERMISSION-DENIED-001`, `SCENARIO-APP-PERMISSION-RESTRICTED-001`
- **Supersedes:** none

Denial MUST produce a useful degraded state rather than a dead end. The owning feature continues with local manual entry, local-only content, reduced integration, or another explicitly specified fallback. The app does not repeatedly prompt, shame, conceal core actions, or imply that denied access erased existing Ambitions-owned data.

Prompts MUST be contextual and explain value.

## APP-PERMISSION-STATE-001 — Permission state remains distinct from feature data

- **Concept:** `app.permissions.state`
- **Modality:** `MUST`
- **Scope:** Authorization status, request eligibility, and feature availability
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-PERMISSION-STATE-001`, `AUDIT-APP-PERMISSION-DATA-SEPARATION-001`
- **Supersedes:** none

Permission state MUST distinguish not determined, authorized, limited where the platform supports it, denied, restricted, and unavailable. This authorization axis remains separate from source freshness, local data availability, import state, account state, and external-write result. A permission transition cannot independently create, delete, import, or mutate a canonical Ambitions object.

## APP-PERMISSION-RECOVERY-001 — Recovery uses exact settings and safe return

- **Concept:** `app.permissions.recovery`
- **Modality:** `MUST`
- **Scope:** Later enablement, revocation, and settings recovery
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-PERMISSION-SETTINGS-001`, `SCENARIO-APP-PERMISSION-REVOCATION-001`
- **Supersedes:** none

When the platform permits recovery through Settings, Ambitions MUST present an exact, user-initiated path and explain the consequence before leaving the app. On return or foreground activation, the owning feature re-reads authorization, reconciles its projection, restores focus, and shows the resulting capability state. Revocation preserves Ambitions-owned local objects and marks only the affected external capability unavailable or stale.

## APP-PERMISSION-RECONCILE-001 — Authorization changes reconcile deterministically

- **Concept:** `app.permissions.reconciliation`
- **Modality:** `MUST`
- **Scope:** Foreground, relaunch, extension entry, and external authorization change
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-PERMISSION-RECONCILE-001`, `SCENARIO-APP-PERMISSION-PARTIAL-001`
- **Supersedes:** none

Authorization changes MUST reconcile through the owning capability without silently accepting external data or replaying a previously rejected action. Pending work is revalidated against current authorization and canonical state. Partial external results remain inspectable and recoverable; an authorization change does not convert an external candidate into an Ambitions object or mark an external write successful.

## APP-PERMISSIONS-COMMAND-CONTRACT-001 — Permission commands require contextual intent and preserve local fallback

- **Concept:** `app.permissions.command-contract`
- **Modality:** `MUST`
- **Scope:** Calendar and notification eligibility, contextual request, system authorization, limited and partial access, denial, restriction, revocation, foreground reconciliation, Settings return, local fallback, focus, offline use, privacy, and accessibility
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-PERMISSIONS-COMMAND-CONTRACT-001`
- **Supersedes:** none

Calendar and notification permission presentations MUST expose contextual `Allow Calendar Access` or `Allow Notifications`, plus `Not Now`, `Use Local Only`, `Open Settings`, `Check Again`, and `Done` as applicable.

A system request may occur only after explicit user intent, feature relevance, request eligibility, and a plain explanation of scope and fallback. The system prompt owns authorization; it MUST NOT commit canonical product data.

Focus behavior MUST be deterministic:

- Not Determined → permission purpose and primary Allow command.
- Requesting → request heading.
- Authorized → enabled capability result.
- Limited/Partial → exact available and unavailable scope plus `Review Access`.
- Denied/Restricted → status, local fallback, and `Open Settings` where allowed.
- Unavailable → local fallback and reason.
- Reconciling → reconciliation heading.
- Settings return → exact resulting capability.
- Settings-return failure → prior status and `Check Again`.

On foreground return, authorization is re-read and the owning projection reconciles. Revocation marks only the external capability unavailable/stale and preserves local objects. Repeated prompting, inferred consent, or replay of a rejected action is forbidden.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
This system owns contextual request eligibility, authorization-state interpretation, denied fallback routing, Settings recovery, and authorization reconciliation. It does not own platform authorization, feature-specific data use, imports, external writes, privacy approval, or canonical mutation.

<!-- canon-section: inputs-outputs -->
Inputs are explicit user intent, owning-feature need, platform authorization state, request history, app lifecycle, and capability fallback. Outputs are request/no-request, a scoped explanation, current availability, degraded fallback, Settings recovery, and a reconciliation signal to the owning feature.

<!-- canon-section: authority-boundary -->
Permission coordination mediates access while product and data authority stay with their owning systems.

Privacy and user-control laws set the floor. Each feature specification owns why it needs data and its fallback. Permissions mediate access only and never become a private-data owner, import owner, mutation authority, or release approval.

<!-- canon-section: data-classification -->
Authorization status is local security metadata. Permission rationale may identify a capability but must not disclose sensitive object content. Data obtained after authorization retains the classification and egress limits of its owning feature.

<!-- canon-section: state-model -->
Authorization, request eligibility, fallback, and reconciliation remain separate state axes.

Authorization states are not determined, authorized, limited, denied, restricted, and unavailable. Separate axes track request eligibility, feature fallback, pending reconciliation, and last-known platform state; these axes do not collapse into sync or source freshness.

<!-- canon-section: failure-recovery -->
Request API failure, Settings-return failure, revocation, and partial external access produce a bounded degraded state with retry, manual fallback, or exact recovery. Existing local data remains intact and no unauthorized action is replayed automatically.

<!-- canon-section: local-network-boundary -->
Permission interpretation, local fallback, and Settings recovery require no account or Ambitions network. Authorization never becomes a reason to send private context to an external service.

<!-- canon-section: determinism -->
Given the same platform state, request history, feature need, and explicit user action, the permission system produces the same request eligibility and fallback. It does not infer consent from usage, setup completion, or account state.

<!-- canon-section: observability -->
Evidence records permission class, prior and current authorization, request decision, fallback selected, Settings handoff, and reconciliation result without protected resource content.

<!-- canon-section: source-ownership -->
`Core/Permissions/` maps platform authorization and request coordination; LocalRuntimeOS Boundary and PrivacySecurity enforce capability and egress law; You owns global discoverability and repair; `Quality/` owns verification. Existing files are implementation evidence only.

<!-- canon-section: tests-proof -->
Required proof covers every state transition, first request, denial, repeated denial without nagging, restriction, limited access where supported, revocation, Settings return, foreground reconciliation, offline fallback, local-data preservation, VoiceOver explanation/actions, Dynamic Type, and focus restoration.

<!-- canon-section: performance-resource-constraints -->
For 8 declared permission classes on the oldest supported physical iPhone in an optimized build, cached authorization lookup MUST complete within 10 ms at P95, a platform-state refresh excluding system-owned prompt time within 100 ms at P95, and foreground reconciliation within 250 ms at P95 across 1,000 checks. The reconciliation queue MUST cap at 8 classes and coalesce duplicate lifecycle signals. One thousand checks MUST add no more than 2 MiB resident memory and perform zero network calls and zero synchronous disk writes. A failed platform read may retry once per foreground transition; further retry requires a new lifecycle event or user action. Permission coordination MUST not poll in foreground or background.
