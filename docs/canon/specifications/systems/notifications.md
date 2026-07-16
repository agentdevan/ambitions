+++
spec_id = "SYSTEM-NOTIFICATIONS"
title = "Notifications"
kind = "system"
status = "normative"
owner_domain = "system-notifications"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "system.notifications.command-contract",
  "system.notifications.external-effect",
  "system.notifications.object-aware",
]
inherits = ["OBJECT-REMINDER-COMPLETION-001", "RUNTIME-MUTATION-SEQUENCE-001", "LAW-RUNTIME-DURABLE-SUCCESS-001", "PRIVACY-VISIBILITY-001", "PLATFORM-NATIVE-IPHONE-001"]
depends_on = ["CONSTITUTION", "APP-PERMISSIONS", "OBJECT-NOTIFICATION-RULE", "SYSTEM-PRIVATE-LIFE-RUNTIME", "SYSTEM-PRIVACY-DATA-CLASSIFICATION"]
source_owners = ["Native/Ambitions/Core/Permissions/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Projections/", "Native/Ambitions/Surfaces/You/", "Native/Ambitions/Quality/"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-NOTIFICATIONS-ACTED"
requirement_id = "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the originating You notification context from Notification rules and delivery state — Acted; effect: No durable mutation occurs and no Receipt is created; Done closes only the current delivery, callback, reconciliation, or removal status. Delivery or acknowledgment does not complete work; callback actions must already have routed to the resolved object owner and revalidated object revision, authorization, proof, and idempotency. Visible evidence remains: A notification response was received. Saved Goals, Steps, and time remain unchanged.; focus: the changed Rule, owning object, or Done result heading in Notification rules and delivery state — Acted."
durable_effect = "Exact local Rule and separate iOS-result consequences: Done: No durable mutation occurs and no Receipt is created; Done closes only the current delivery, callback, reconciliation, or removal status. Delivery or acknowledgment does not complete work; callback actions must already have routed to the resolved object owner and revalidated object revision, authorization, proof, and idempotency. Visible evidence remains: A notification response was received. Saved Goals, Steps, and time remain unchanged. Callback actions Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow route to resolved object owners with current revision, authorization, proof, and idempotency revalidation; delivery or acknowledgment does not complete work. Current visible status: A notification response was received. Saved Goals, Steps, and time remain unchanged."
recovery_rollback = "Exact local rollback, external retry, permission return, and foreground reconciliation: Done: No Undo is required; the owning object, local Rule, external result, and callback Receipt remain independently inspectable. Reconciliation compares committed Rules with system requests and cannot duplicate scheduling or callback replay. Recovery preserves: A notification response was received. Saved Goals, Steps, and time remain unchanged."
offline_behavior = "Local Rule creation, editing, removal, History, and Receipts remain available offline. iOS scheduling/removal enters the local outbox and reconciles later without redefining local success; owning objects remain usable. Offline evidence remains: A notification response was received. Saved Goals, Steps, and time remain unchanged."
accessibility_focus = "VoiceOver names Rule status, owning object, quiet-hours/privacy consequence, external failure, and available owner-routed actions: Done announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Done result heading in Notification rules and delivery state — Acted; rejection focuses the Done control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Acted. Action labels remain available without color and Dynamic Type stacks rule details. The announcement first communicates: A notification response was received. Saved Goals, Steps, and time remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-ACTED-001"
label = "Done"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated"]
destination = "the originating You notification context from Notification rules and delivery state — Acted"
effect = "No durable mutation occurs and no Receipt is created; Done closes only the current delivery, callback, reconciliation, or removal status. Delivery or acknowledgment does not complete work; callback actions must already have routed to the resolved object owner and revalidated object revision, authorization, proof, and idempotency. Visible evidence remains: A notification response was received. Saved Goals, Steps, and time remain unchanged."
success_focus = "the changed Rule, owning object, or Done result heading in Notification rules and delivery state — Acted"
failure_focus = "the Done control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Acted"
commit_boundary = "Non-mutating: status dismissal cannot create, edit, remove, complete, snooze, reschedule, or prove an owning object."
rollback_undo = "No Undo is required; the owning object, local Rule, external result, and callback Receipt remain independently inspectable."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-NOTIFICATIONS-DELIVERED"
requirement_id = "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the originating You notification context from Notification rules and delivery state — Delivered; effect: No durable mutation occurs and no Receipt is created; Done closes only the current delivery, callback, reconciliation, or removal status. Delivery or acknowledgment does not complete work; callback actions must already have routed to the resolved object owner and revalidated object revision, authorization, proof, and idempotency. Visible evidence remains: The notification reached the device; delivery alone does not mark work complete.; focus: the changed Rule, owning object, or Done result heading in Notification rules and delivery state — Delivered."
durable_effect = "Exact local Rule and separate iOS-result consequences: Done: No durable mutation occurs and no Receipt is created; Done closes only the current delivery, callback, reconciliation, or removal status. Delivery or acknowledgment does not complete work; callback actions must already have routed to the resolved object owner and revalidated object revision, authorization, proof, and idempotency. Visible evidence remains: The notification reached the device; delivery alone does not mark work complete. Callback actions Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow route to resolved object owners with current revision, authorization, proof, and idempotency revalidation; delivery or acknowledgment does not complete work. Current visible status: The notification reached the device; delivery alone does not mark work complete."
recovery_rollback = "Exact local rollback, external retry, permission return, and foreground reconciliation: Done: No Undo is required; the owning object, local Rule, external result, and callback Receipt remain independently inspectable. Reconciliation compares committed Rules with system requests and cannot duplicate scheduling or callback replay. Recovery preserves: The notification reached the device; delivery alone does not mark work complete."
offline_behavior = "Local Rule creation, editing, removal, History, and Receipts remain available offline. iOS scheduling/removal enters the local outbox and reconciles later without redefining local success; owning objects remain usable. Offline evidence remains: The notification reached the device; delivery alone does not mark work complete."
accessibility_focus = "VoiceOver names Rule status, owning object, quiet-hours/privacy consequence, external failure, and available owner-routed actions: Done announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Done result heading in Notification rules and delivery state — Delivered; rejection focuses the Done control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Delivered. Action labels remain available without color and Dynamic Type stacks rule details. The announcement first communicates: The notification reached the device; delivery alone does not mark work complete."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-DELIVERED-001"
label = "Done"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated"]
destination = "the originating You notification context from Notification rules and delivery state — Delivered"
effect = "No durable mutation occurs and no Receipt is created; Done closes only the current delivery, callback, reconciliation, or removal status. Delivery or acknowledgment does not complete work; callback actions must already have routed to the resolved object owner and revalidated object revision, authorization, proof, and idempotency. Visible evidence remains: The notification reached the device; delivery alone does not mark work complete."
success_focus = "the changed Rule, owning object, or Done result heading in Notification rules and delivery state — Delivered"
failure_focus = "the Done control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Delivered"
commit_boundary = "Non-mutating: status dismissal cannot create, edit, remove, complete, snooze, reschedule, or prove an owning object."
rollback_undo = "No Undo is required; the owning object, local Rule, external result, and callback Receipt remain independently inspectable."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-NOTIFICATIONS-DISABLED"
requirement_id = "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Settings => destination: the Ambitions notification controls in iOS Settings from Notification rules and delivery state — Disabled; effect: The Open Settings external result causes no local canonical mutation; it leaves the app for system authorization controls. Denial retains every local Rule as inactive and preserves the owning object. Visible evidence remains until foreground revalidation: Notifications are off. Goals, Steps, and time remain unchanged.; focus: the changed Rule, owning object, or Open Settings result heading in Notification rules and delivery state — Disabled."
durable_effect = "Exact local Rule and separate iOS-result consequences: Open Settings: The Open Settings external result causes no local canonical mutation; it leaves the app for system authorization controls. Denial retains every local Rule as inactive and preserves the owning object. Visible evidence remains until foreground revalidation: Notifications are off. Goals, Steps, and time remain unchanged. Callback actions Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow route to resolved object owners with current revision, authorization, proof, and idempotency revalidation; delivery or acknowledgment does not complete work. Current visible status: Notifications are off. Goals, Steps, and time remain unchanged."
recovery_rollback = "Exact local rollback, external retry, permission return, and foreground reconciliation: Open Settings: Cancellation or an unchanged permission returns to the prior status; no rule, owning object, or callback action is replayed. Reconciliation compares committed Rules with system requests and cannot duplicate scheduling or callback replay. Recovery preserves: Notifications are off. Goals, Steps, and time remain unchanged."
offline_behavior = "Local Rule creation, editing, removal, History, and Receipts remain available offline. iOS scheduling/removal enters the local outbox and reconciles later without redefining local success; owning objects remain usable. Offline evidence remains: Notifications are off. Goals, Steps, and time remain unchanged."
accessibility_focus = "VoiceOver names Rule status, owning object, quiet-hours/privacy consequence, external failure, and available owner-routed actions: Open Settings announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Open Settings result heading in Notification rules and delivery state — Disabled; rejection focuses the Open Settings control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Disabled. Action labels remain available without color and Dynamic Type stacks rule details. The announcement first communicates: Notifications are off. Goals, Steps, and time remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-DISABLED-001"
label = "Open Settings"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated"]
destination = "the Ambitions notification controls in iOS Settings from Notification rules and delivery state — Disabled"
effect = "The Open Settings external result causes no local canonical mutation; it leaves the app for system authorization controls. Denial retains every local Rule as inactive and preserves the owning object. Visible evidence remains until foreground revalidation: Notifications are off. Goals, Steps, and time remain unchanged."
success_focus = "the changed Rule, owning object, or Open Settings result heading in Notification rules and delivery state — Disabled"
failure_focus = "the Open Settings control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Disabled"
commit_boundary = "External-result: system Settings owns authorization; foreground return re-reads permission before any separate local projection reconciliation."
rollback_undo = "Cancellation or an unchanged permission returns to the prior status; no rule, owning object, or callback action is replayed."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-NOTIFICATIONS-EXTERNALLY-FAILED"
requirement_id = "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Try Again => destination: the current-rule iOS scheduling or removal reconciliation result from Notification rules and delivery state — Externally Failed; effect: The Try Again external result causes no local canonical mutation; it retries only the failed iOS scheduling or removal identity for the current committed Rule, cannot replay a superseded request or callback action, and preserves local success if iOS fails again. Visible evidence remains: The notification could not be scheduled. The related Step remains unchanged.; focus: the changed Rule, owning object, or Try Again result heading in Notification rules and delivery state — Externally Failed."
durable_effect = "Exact local Rule and separate iOS-result consequences: Try Again: The Try Again external result causes no local canonical mutation; it retries only the failed iOS scheduling or removal identity for the current committed Rule, cannot replay a superseded request or callback action, and preserves local success if iOS fails again. Visible evidence remains: The notification could not be scheduled. The related Step remains unchanged. Callback actions Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow route to resolved object owners with current revision, authorization, proof, and idempotency revalidation; delivery or acknowledgment does not complete work. Current visible status: The notification could not be scheduled. The related Step remains unchanged."
recovery_rollback = "Exact local rollback, external retry, permission return, and foreground reconciliation: Try Again: Cancellation leaves the local Rule and failed external identity unchanged; foreground reconciliation compares current committed rules with system requests before another retry. Reconciliation compares committed Rules with system requests and cannot duplicate scheduling or callback replay. Recovery preserves: The notification could not be scheduled. The related Step remains unchanged."
offline_behavior = "Local Rule creation, editing, removal, History, and Receipts remain available offline. iOS scheduling/removal enters the local outbox and reconciles later without redefining local success; owning objects remain usable. Offline evidence remains: The notification could not be scheduled. The related Step remains unchanged."
accessibility_focus = "VoiceOver names Rule status, owning object, quiet-hours/privacy consequence, external failure, and available owner-routed actions: Try Again announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Try Again result heading in Notification rules and delivery state — Externally Failed; rejection focuses the Try Again control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Externally Failed. Action labels remain available without color and Dynamic Type stacks rule details. The announcement first communicates: The notification could not be scheduled. The related Step remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-EXTERNALLY-FAILED-001"
label = "Try Again"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Only the failed external outbox identity for the current committed Rule may be retried", "Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated"]
destination = "the current-rule iOS scheduling or removal reconciliation result from Notification rules and delivery state — Externally Failed"
effect = "The Try Again external result causes no local canonical mutation; it retries only the failed iOS scheduling or removal identity for the current committed Rule, cannot replay a superseded request or callback action, and preserves local success if iOS fails again. Visible evidence remains: The notification could not be scheduled. The related Step remains unchanged."
success_focus = "the changed Rule, owning object, or Try Again result heading in Notification rules and delivery state — Externally Failed"
failure_focus = "the Try Again control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Externally Failed"
commit_boundary = "External-result: iOS scheduling or removal follows the accepted local Rule and cannot redefine or replay canonical success."
rollback_undo = "Cancellation leaves the local Rule and failed external identity unchanged; foreground reconciliation compares current committed rules with system requests before another retry."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-NOTIFICATIONS-PERMISSION-ALLOWED"
requirement_id = "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Create Rule => destination: the locally committed Notification Rule status from Notification rules and delivery state — Permission Allowed; effect: A typed Create Rule Command validates object ownership, current revision, user policy, privacy, and permission posture; appends an Event; updates the Notification Rule Projection; and creates a Receipt and History entry before any separate iOS scheduling result. If permission is denied, the local rule remains retained and inactive. Visible evidence before commit remains: Notification access is allowed, subject to each rule and privacy choice.; focus: the changed Rule, owning object, or Create Rule result heading in Notification rules and delivery state — Permission Allowed."
durable_effect = "Exact local Rule and separate iOS-result consequences: Create Rule: A typed Create Rule Command validates object ownership, current revision, user policy, privacy, and permission posture; appends an Event; updates the Notification Rule Projection; and creates a Receipt and History entry before any separate iOS scheduling result. If permission is denied, the local rule remains retained and inactive. Visible evidence before commit remains: Notification access is allowed, subject to each rule and privacy choice. Callback actions Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow route to resolved object owners with current revision, authorization, proof, and idempotency revalidation; delivery or acknowledgment does not complete work. Current visible status: Notification access is allowed, subject to each rule and privacy choice."
recovery_rollback = "Exact local rollback, external retry, permission return, and foreground reconciliation: Create Rule: Before commit, cancellation changes nothing; after local commit, Undo or a typed rule command reverses local policy while any iOS request removal reconciles separately. Reconciliation compares committed Rules with system requests and cannot duplicate scheduling or callback replay. Recovery preserves: Notification access is allowed, subject to each rule and privacy choice."
offline_behavior = "Local Rule creation, editing, removal, History, and Receipts remain available offline. iOS scheduling/removal enters the local outbox and reconciles later without redefining local success; owning objects remain usable. Offline evidence remains: Notification access is allowed, subject to each rule and privacy choice."
accessibility_focus = "VoiceOver names Rule status, owning object, quiet-hours/privacy consequence, external failure, and available owner-routed actions: Create Rule announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Create Rule result heading in Notification rules and delivery state — Permission Allowed; rejection focuses the Create Rule control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Permission Allowed. Action labels remain available without color and Dynamic Type stacks rule details. The announcement first communicates: Notification access is allowed, subject to each rule and privacy choice."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-PERMISSION-ALLOWED-001"
label = "Create Rule"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated", "The local rule consequence is accepted before any separate iOS scheduling or removal dispatch"]
destination = "the locally committed Notification Rule status from Notification rules and delivery state — Permission Allowed"
effect = "A typed Create Rule Command validates object ownership, current revision, user policy, privacy, and permission posture; appends an Event; updates the Notification Rule Projection; and creates a Receipt and History entry before any separate iOS scheduling result. If permission is denied, the local rule remains retained and inactive. Visible evidence before commit remains: Notification access is allowed, subject to each rule and privacy choice."
success_focus = "the changed Rule, owning object, or Create Rule result heading in Notification rules and delivery state — Permission Allowed"
failure_focus = "the Create Rule control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Permission Allowed"
commit_boundary = "Mutation: the local Notification Rule commits first through Event, Projection, Receipt, History, and replay-safe ownership; iOS scheduling follows as a separate external result."
rollback_undo = "Before commit, cancellation changes nothing; after local commit, Undo or a typed rule command reverses local policy while any iOS request removal reconciles separately."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-NOTIFICATIONS-PERMISSION-DENIED"
requirement_id = "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Settings => destination: the Ambitions notification controls in iOS Settings from Notification rules and delivery state — Permission Denied; effect: The Open Settings external result causes no local canonical mutation; it leaves the app for system authorization controls. Denial retains every local Rule as inactive and preserves the owning object. Visible evidence remains until foreground revalidation: Notification access is off. Saved Goals, Steps, and time remain available.; focus: the changed Rule, owning object, or Open Settings result heading in Notification rules and delivery state — Permission Denied."
durable_effect = "Exact local Rule and separate iOS-result consequences: Open Settings: The Open Settings external result causes no local canonical mutation; it leaves the app for system authorization controls. Denial retains every local Rule as inactive and preserves the owning object. Visible evidence remains until foreground revalidation: Notification access is off. Saved Goals, Steps, and time remain available. Callback actions Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow route to resolved object owners with current revision, authorization, proof, and idempotency revalidation; delivery or acknowledgment does not complete work. Current visible status: Notification access is off. Saved Goals, Steps, and time remain available."
recovery_rollback = "Exact local rollback, external retry, permission return, and foreground reconciliation: Open Settings: Cancellation or an unchanged permission returns to the prior status; no rule, owning object, or callback action is replayed. Reconciliation compares committed Rules with system requests and cannot duplicate scheduling or callback replay. Recovery preserves: Notification access is off. Saved Goals, Steps, and time remain available."
offline_behavior = "Local Rule creation, editing, removal, History, and Receipts remain available offline. iOS scheduling/removal enters the local outbox and reconciles later without redefining local success; owning objects remain usable. Offline evidence remains: Notification access is off. Saved Goals, Steps, and time remain available."
accessibility_focus = "VoiceOver names Rule status, owning object, quiet-hours/privacy consequence, external failure, and available owner-routed actions: Open Settings announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Open Settings result heading in Notification rules and delivery state — Permission Denied; rejection focuses the Open Settings control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Permission Denied. Action labels remain available without color and Dynamic Type stacks rule details. The announcement first communicates: Notification access is off. Saved Goals, Steps, and time remain available."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-PERMISSION-DENIED-001"
label = "Open Settings"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated"]
destination = "the Ambitions notification controls in iOS Settings from Notification rules and delivery state — Permission Denied"
effect = "The Open Settings external result causes no local canonical mutation; it leaves the app for system authorization controls. Denial retains every local Rule as inactive and preserves the owning object. Visible evidence remains until foreground revalidation: Notification access is off. Saved Goals, Steps, and time remain available."
success_focus = "the changed Rule, owning object, or Open Settings result heading in Notification rules and delivery state — Permission Denied"
failure_focus = "the Open Settings control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Permission Denied"
commit_boundary = "External-result: system Settings owns authorization; foreground return re-reads permission before any separate local projection reconciliation."
rollback_undo = "Cancellation or an unchanged permission returns to the prior status; no rule, owning object, or callback action is replayed."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-NOTIFICATIONS-PERMISSION-NOT-REQUESTED"
requirement_id = "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Settings => destination: the Ambitions notification controls in iOS Settings from Notification rules and delivery state — Permission Not Requested; effect: The Open Settings external result causes no local canonical mutation; it leaves the app for system authorization controls. Denial retains every local Rule as inactive and preserves the owning object. Visible evidence remains until foreground revalidation: Notification access has not been requested; Ambitions remains fully usable.; focus: the changed Rule, owning object, or Open Settings result heading in Notification rules and delivery state — Permission Not Requested."
durable_effect = "Exact local Rule and separate iOS-result consequences: Open Settings: The Open Settings external result causes no local canonical mutation; it leaves the app for system authorization controls. Denial retains every local Rule as inactive and preserves the owning object. Visible evidence remains until foreground revalidation: Notification access has not been requested; Ambitions remains fully usable. Callback actions Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow route to resolved object owners with current revision, authorization, proof, and idempotency revalidation; delivery or acknowledgment does not complete work. Current visible status: Notification access has not been requested; Ambitions remains fully usable."
recovery_rollback = "Exact local rollback, external retry, permission return, and foreground reconciliation: Open Settings: Cancellation or an unchanged permission returns to the prior status; no rule, owning object, or callback action is replayed. Reconciliation compares committed Rules with system requests and cannot duplicate scheduling or callback replay. Recovery preserves: Notification access has not been requested; Ambitions remains fully usable."
offline_behavior = "Local Rule creation, editing, removal, History, and Receipts remain available offline. iOS scheduling/removal enters the local outbox and reconciles later without redefining local success; owning objects remain usable. Offline evidence remains: Notification access has not been requested; Ambitions remains fully usable."
accessibility_focus = "VoiceOver names Rule status, owning object, quiet-hours/privacy consequence, external failure, and available owner-routed actions: Open Settings announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Open Settings result heading in Notification rules and delivery state — Permission Not Requested; rejection focuses the Open Settings control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Permission Not Requested. Action labels remain available without color and Dynamic Type stacks rule details. The announcement first communicates: Notification access has not been requested; Ambitions remains fully usable."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-PERMISSION-NOT-REQUESTED-001"
label = "Open Settings"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated"]
destination = "the Ambitions notification controls in iOS Settings from Notification rules and delivery state — Permission Not Requested"
effect = "The Open Settings external result causes no local canonical mutation; it leaves the app for system authorization controls. Denial retains every local Rule as inactive and preserves the owning object. Visible evidence remains until foreground revalidation: Notification access has not been requested; Ambitions remains fully usable."
success_focus = "the changed Rule, owning object, or Open Settings result heading in Notification rules and delivery state — Permission Not Requested"
failure_focus = "the Open Settings control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Permission Not Requested"
commit_boundary = "External-result: system Settings owns authorization; foreground return re-reads permission before any separate local projection reconciliation."
rollback_undo = "Cancellation or an unchanged permission returns to the prior status; no rule, owning object, or callback action is replayed."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-NOTIFICATIONS-RECONCILED"
requirement_id = "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the originating You notification context from Notification rules and delivery state — Reconciled; effect: No durable mutation occurs and no Receipt is created; Done closes only the current delivery, callback, reconciliation, or removal status. Delivery or acknowledgment does not complete work; callback actions must already have routed to the resolved object owner and revalidated object revision, authorization, proof, and idempotency. Visible evidence remains: The notification and its saved schedule now agree. The related Step remains unchanged.; focus: the changed Rule, owning object, or Done result heading in Notification rules and delivery state — Reconciled."
durable_effect = "Exact local Rule and separate iOS-result consequences: Done: No durable mutation occurs and no Receipt is created; Done closes only the current delivery, callback, reconciliation, or removal status. Delivery or acknowledgment does not complete work; callback actions must already have routed to the resolved object owner and revalidated object revision, authorization, proof, and idempotency. Visible evidence remains: The notification and its saved schedule now agree. The related Step remains unchanged. Callback actions Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow route to resolved object owners with current revision, authorization, proof, and idempotency revalidation; delivery or acknowledgment does not complete work. Current visible status: The notification and its saved schedule now agree. The related Step remains unchanged."
recovery_rollback = "Exact local rollback, external retry, permission return, and foreground reconciliation: Done: No Undo is required; the owning object, local Rule, external result, and callback Receipt remain independently inspectable. Reconciliation compares committed Rules with system requests and cannot duplicate scheduling or callback replay. Recovery preserves: The notification and its saved schedule now agree. The related Step remains unchanged."
offline_behavior = "Local Rule creation, editing, removal, History, and Receipts remain available offline. iOS scheduling/removal enters the local outbox and reconciles later without redefining local success; owning objects remain usable. Offline evidence remains: The notification and its saved schedule now agree. The related Step remains unchanged."
accessibility_focus = "VoiceOver names Rule status, owning object, quiet-hours/privacy consequence, external failure, and available owner-routed actions: Done announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Done result heading in Notification rules and delivery state — Reconciled; rejection focuses the Done control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Reconciled. Action labels remain available without color and Dynamic Type stacks rule details. The announcement first communicates: The notification and its saved schedule now agree. The related Step remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-RECONCILED-001"
label = "Done"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated"]
destination = "the originating You notification context from Notification rules and delivery state — Reconciled"
effect = "No durable mutation occurs and no Receipt is created; Done closes only the current delivery, callback, reconciliation, or removal status. Delivery or acknowledgment does not complete work; callback actions must already have routed to the resolved object owner and revalidated object revision, authorization, proof, and idempotency. Visible evidence remains: The notification and its saved schedule now agree. The related Step remains unchanged."
success_focus = "the changed Rule, owning object, or Done result heading in Notification rules and delivery state — Reconciled"
failure_focus = "the Done control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Reconciled"
commit_boundary = "Non-mutating: status dismissal cannot create, edit, remove, complete, snooze, reschedule, or prove an owning object."
rollback_undo = "No Undo is required; the owning object, local Rule, external result, and callback Receipt remain independently inspectable."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-NOTIFICATIONS-REMOVED"
requirement_id = "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the originating You notification context from Notification rules and delivery state — Removed; effect: No durable mutation occurs and no Receipt is created; Done closes only the current delivery, callback, reconciliation, or removal status. Delivery or acknowledgment does not complete work; callback actions must already have routed to the resolved object owner and revalidated object revision, authorization, proof, and idempotency. Visible evidence remains: The notification request is gone. The related Goal, Step, or time item remains unchanged.; focus: the changed Rule, owning object, or Done result heading in Notification rules and delivery state — Removed."
durable_effect = "Exact local Rule and separate iOS-result consequences: Done: No durable mutation occurs and no Receipt is created; Done closes only the current delivery, callback, reconciliation, or removal status. Delivery or acknowledgment does not complete work; callback actions must already have routed to the resolved object owner and revalidated object revision, authorization, proof, and idempotency. Visible evidence remains: The notification request is gone. The related Goal, Step, or time item remains unchanged. Callback actions Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow route to resolved object owners with current revision, authorization, proof, and idempotency revalidation; delivery or acknowledgment does not complete work. Current visible status: The notification request is gone. The related Goal, Step, or time item remains unchanged."
recovery_rollback = "Exact local rollback, external retry, permission return, and foreground reconciliation: Done: No Undo is required; the owning object, local Rule, external result, and callback Receipt remain independently inspectable. Reconciliation compares committed Rules with system requests and cannot duplicate scheduling or callback replay. Recovery preserves: The notification request is gone. The related Goal, Step, or time item remains unchanged."
offline_behavior = "Local Rule creation, editing, removal, History, and Receipts remain available offline. iOS scheduling/removal enters the local outbox and reconciles later without redefining local success; owning objects remain usable. Offline evidence remains: The notification request is gone. The related Goal, Step, or time item remains unchanged."
accessibility_focus = "VoiceOver names Rule status, owning object, quiet-hours/privacy consequence, external failure, and available owner-routed actions: Done announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Done result heading in Notification rules and delivery state — Removed; rejection focuses the Done control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Removed. Action labels remain available without color and Dynamic Type stacks rule details. The announcement first communicates: The notification request is gone. The related Goal, Step, or time item remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-REMOVED-001"
label = "Done"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated"]
destination = "the originating You notification context from Notification rules and delivery state — Removed"
effect = "No durable mutation occurs and no Receipt is created; Done closes only the current delivery, callback, reconciliation, or removal status. Delivery or acknowledgment does not complete work; callback actions must already have routed to the resolved object owner and revalidated object revision, authorization, proof, and idempotency. Visible evidence remains: The notification request is gone. The related Goal, Step, or time item remains unchanged."
success_focus = "the changed Rule, owning object, or Done result heading in Notification rules and delivery state — Removed"
failure_focus = "the Done control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Removed"
commit_boundary = "Non-mutating: status dismissal cannot create, edit, remove, complete, snooze, reschedule, or prove an owning object."
rollback_undo = "No Undo is required; the owning object, local Rule, external result, and callback Receipt remain independently inspectable."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-NOTIFICATIONS-SCHEDULED"
requirement_id = "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Edit Rule => destination: the updated local Notification Rule and pending iOS reconciliation from Notification rules and delivery state — Scheduled; effect: A typed Edit Rule Command validates the current Rule and owning-object revision; appends an Event; updates the Notification Rule Projection; and creates a Receipt and History entry. Only after local success does the outbox schedule the replacement and remove or supersede the old iOS request without duplication. Visible evidence before commit remains: A notification is scheduled. The related Goal, Step, or time item remains incomplete.; focus: the changed Rule, owning object, or Edit Rule result heading in Notification rules and delivery state — Scheduled.\nRemove Rule => destination: the removed local Rule result and pending iOS removal status from Notification rules and delivery state — Scheduled; effect: A typed Remove Rule Command validates the current Rule and owning-object revision; appends an Event; updates the Notification Rule Projection; and creates a Receipt and History entry before separate iOS removal. Remove Rule does not delete its Step, Event, Reminder, Goal, Proof, History, or Receipt. Visible evidence before commit remains: A notification is scheduled. The related Goal, Step, or time item remains incomplete.; focus: the changed Rule, owning object, or Remove Rule result heading in Notification rules and delivery state — Scheduled.\nTurn Off => destination: the inactive local Notification Rule and pending iOS removal status from Notification rules and delivery state — Scheduled; effect: A typed Turn Off Command validates the current Rule revision; appends an Event; updates its active policy in the Notification Rule Projection; and creates a Receipt and History entry before separate iOS removal. The owning object and completion state remain unchanged. Visible evidence before commit remains: A notification is scheduled. The related Goal, Step, or time item remains incomplete.; focus: the changed Rule, owning object, or Turn Off result heading in Notification rules and delivery state — Scheduled."
durable_effect = "Exact local Rule and separate iOS-result consequences: Edit Rule: A typed Edit Rule Command validates the current Rule and owning-object revision; appends an Event; updates the Notification Rule Projection; and creates a Receipt and History entry. Only after local success does the outbox schedule the replacement and remove or supersede the old iOS request without duplication. Visible evidence before commit remains: A notification is scheduled. The related Goal, Step, or time item remains incomplete. | Remove Rule: A typed Remove Rule Command validates the current Rule and owning-object revision; appends an Event; updates the Notification Rule Projection; and creates a Receipt and History entry before separate iOS removal. Remove Rule does not delete its Step, Event, Reminder, Goal, Proof, History, or Receipt. Visible evidence before commit remains: A notification is scheduled. The related Goal, Step, or time item remains incomplete. | Turn Off: A typed Turn Off Command validates the current Rule revision; appends an Event; updates its active policy in the Notification Rule Projection; and creates a Receipt and History entry before separate iOS removal. The owning object and completion state remain unchanged. Visible evidence before commit remains: A notification is scheduled. The related Goal, Step, or time item remains incomplete. Callback actions Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow route to resolved object owners with current revision, authorization, proof, and idempotency revalidation; delivery or acknowledgment does not complete work. Current visible status: A notification is scheduled. The related Goal, Step, or time item remains incomplete."
recovery_rollback = "Exact local rollback, external retry, permission return, and foreground reconciliation: Edit Rule: Before commit, cancellation preserves the prior rule; after commit, a typed inverse restores the prior local policy and external requests reconcile idempotently. | Remove Rule: Before commit, cancellation preserves the rule; after commit, restoring notification policy is a separate typed command and cannot recreate or complete the owning object. | Turn Off: Before commit, cancellation preserves the active rule; after commit, re-enabling is a separate typed command and scheduling reconciles without duplicate requests. Reconciliation compares committed Rules with system requests and cannot duplicate scheduling or callback replay. Recovery preserves: A notification is scheduled. The related Goal, Step, or time item remains incomplete."
offline_behavior = "Local Rule creation, editing, removal, History, and Receipts remain available offline. iOS scheduling/removal enters the local outbox and reconciles later without redefining local success; owning objects remain usable. Offline evidence remains: A notification is scheduled. The related Goal, Step, or time item remains incomplete."
accessibility_focus = "VoiceOver names Rule status, owning object, quiet-hours/privacy consequence, external failure, and available owner-routed actions: Edit Rule announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Edit Rule result heading in Notification rules and delivery state — Scheduled; rejection focuses the Edit Rule control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Scheduled | Remove Rule announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Remove Rule result heading in Notification rules and delivery state — Scheduled; rejection focuses the Remove Rule control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Scheduled | Turn Off announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Turn Off result heading in Notification rules and delivery state — Scheduled; rejection focuses the Turn Off control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Scheduled. Action labels remain available without color and Dynamic Type stacks rule details. The announcement first communicates: A notification is scheduled. The related Goal, Step, or time item remains incomplete."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-SCHEDULED-001"
label = "Edit Rule"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated", "The local rule consequence is accepted before any separate iOS scheduling or removal dispatch"]
destination = "the updated local Notification Rule and pending iOS reconciliation from Notification rules and delivery state — Scheduled"
effect = "A typed Edit Rule Command validates the current Rule and owning-object revision; appends an Event; updates the Notification Rule Projection; and creates a Receipt and History entry. Only after local success does the outbox schedule the replacement and remove or supersede the old iOS request without duplication. Visible evidence before commit remains: A notification is scheduled. The related Goal, Step, or time item remains incomplete."
success_focus = "the changed Rule, owning object, or Edit Rule result heading in Notification rules and delivery state — Scheduled"
failure_focus = "the Edit Rule control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Scheduled"
commit_boundary = "Mutation: rule editing commits locally through Event, Projection, Receipt, History, and replay-safe ownership before external reconciliation."
rollback_undo = "Before commit, cancellation preserves the prior rule; after commit, a typed inverse restores the prior local policy and external requests reconcile idempotently."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-SCHEDULED-002"
label = "Remove Rule"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated", "The local rule consequence is accepted before any separate iOS scheduling or removal dispatch"]
destination = "the removed local Rule result and pending iOS removal status from Notification rules and delivery state — Scheduled"
effect = "A typed Remove Rule Command validates the current Rule and owning-object revision; appends an Event; updates the Notification Rule Projection; and creates a Receipt and History entry before separate iOS removal. Remove Rule does not delete its Step, Event, Reminder, Goal, Proof, History, or Receipt. Visible evidence before commit remains: A notification is scheduled. The related Goal, Step, or time item remains incomplete."
success_focus = "the changed Rule, owning object, or Remove Rule result heading in Notification rules and delivery state — Scheduled"
failure_focus = "the Remove Rule control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Scheduled"
commit_boundary = "Mutation: local rule removal commits through Event, Projection, Receipt, History, and replay-safe ownership before the external request is removed."
rollback_undo = "Before commit, cancellation preserves the rule; after commit, restoring notification policy is a separate typed command and cannot recreate or complete the owning object."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-SCHEDULED-003"
label = "Turn Off"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated", "The local rule consequence is accepted before any separate iOS scheduling or removal dispatch"]
destination = "the inactive local Notification Rule and pending iOS removal status from Notification rules and delivery state — Scheduled"
effect = "A typed Turn Off Command validates the current Rule revision; appends an Event; updates its active policy in the Notification Rule Projection; and creates a Receipt and History entry before separate iOS removal. The owning object and completion state remain unchanged. Visible evidence before commit remains: A notification is scheduled. The related Goal, Step, or time item remains incomplete."
success_focus = "the changed Rule, owning object, or Turn Off result heading in Notification rules and delivery state — Scheduled"
failure_focus = "the Turn Off control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Scheduled"
commit_boundary = "Mutation: turning a rule off commits locally through Event, Projection, Receipt, History, and replay-safe ownership before external removal."
rollback_undo = "Before commit, cancellation preserves the active rule; after commit, re-enabling is a separate typed command and scheduling reconciles without duplicate requests."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-NOTIFICATIONS-SUPERSEDED"
requirement_id = "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Edit Rule => destination: the updated local Notification Rule and pending iOS reconciliation from Notification rules and delivery state — Superseded; effect: A typed Edit Rule Command validates the current Rule and owning-object revision; appends an Event; updates the Notification Rule Projection; and creates a Receipt and History entry. Only after local success does the outbox schedule the replacement and remove or supersede the old iOS request without duplication. Visible evidence before commit remains: A newer notification request replaces the earlier request. The related Goal, Step, or time item remains unchanged.; focus: the changed Rule, owning object, or Edit Rule result heading in Notification rules and delivery state — Superseded."
durable_effect = "Exact local Rule and separate iOS-result consequences: Edit Rule: A typed Edit Rule Command validates the current Rule and owning-object revision; appends an Event; updates the Notification Rule Projection; and creates a Receipt and History entry. Only after local success does the outbox schedule the replacement and remove or supersede the old iOS request without duplication. Visible evidence before commit remains: A newer notification request replaces the earlier request. The related Goal, Step, or time item remains unchanged. Callback actions Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow route to resolved object owners with current revision, authorization, proof, and idempotency revalidation; delivery or acknowledgment does not complete work. Current visible status: A newer notification request replaces the earlier request. The related Goal, Step, or time item remains unchanged."
recovery_rollback = "Exact local rollback, external retry, permission return, and foreground reconciliation: Edit Rule: Before commit, cancellation preserves the prior rule; after commit, a typed inverse restores the prior local policy and external requests reconcile idempotently. Reconciliation compares committed Rules with system requests and cannot duplicate scheduling or callback replay. Recovery preserves: A newer notification request replaces the earlier request. The related Goal, Step, or time item remains unchanged."
offline_behavior = "Local Rule creation, editing, removal, History, and Receipts remain available offline. iOS scheduling/removal enters the local outbox and reconciles later without redefining local success; owning objects remain usable. Offline evidence remains: A newer notification request replaces the earlier request. The related Goal, Step, or time item remains unchanged."
accessibility_focus = "VoiceOver names Rule status, owning object, quiet-hours/privacy consequence, external failure, and available owner-routed actions: Edit Rule announces rule and owning-object consequence; success focuses the changed Rule, owning object, or Edit Rule result heading in Notification rules and delivery state — Superseded; rejection focuses the Edit Rule control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Superseded. Action labels remain available without color and Dynamic Type stacks rule details. The announcement first communicates: A newer notification request replaces the earlier request. The related Goal, Step, or time item remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-NOTIFICATIONS-SUPERSEDED-001"
label = "Edit Rule"
canonical_owner = "system.notifications.command-contract"
preconditions = ["Proof requirements, quiet hours, privacy policy, and idempotency identity are current", "The current Notification Rule identity, local revision, owning object identity, and authorization have been revalidated", "The local rule consequence is accepted before any separate iOS scheduling or removal dispatch"]
destination = "the updated local Notification Rule and pending iOS reconciliation from Notification rules and delivery state — Superseded"
effect = "A typed Edit Rule Command validates the current Rule and owning-object revision; appends an Event; updates the Notification Rule Projection; and creates a Receipt and History entry. Only after local success does the outbox schedule the replacement and remove or supersede the old iOS request without duplication. Visible evidence before commit remains: A newer notification request replaces the earlier request. The related Goal, Step, or time item remains unchanged."
success_focus = "the changed Rule, owning object, or Edit Rule result heading in Notification rules and delivery state — Superseded"
failure_focus = "the Edit Rule control and exact permission, outbox, or owner-validation reason in Notification rules and delivery state — Superseded"
commit_boundary = "Mutation: rule editing commits locally through Event, Projection, Receipt, History, and replay-safe ownership before external reconciliation."
rollback_undo = "Before commit, cancellation preserves the prior rule; after commit, a typed inverse restores the prior local policy and external requests reconcile idempotently."
privacy_egress = "Lock Screen and system-request payloads are privacy-filtered and minimized; private Goal, Step, Event, Proof, and life-graph context remains local unless an explicitly approved field is necessary for the notification."
verification_ids = ["SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"]
+++

# Notifications

This shadow specification defines notification policy and external-effect boundaries. It does not claim permission, delivery, Lock Screen privacy, action, device, or release proof.

## SYSTEM-NOTIFICATIONS-POLICY-001 — Notifications are contextual, object-aware, private, and non-coercive

- **Concept:** `system.notifications.object-aware`
- **Modality:** `MUST`
- **Scope:** Reminder, Event, protected window, reflow/review, proof, quiet hours, previews, and actions
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-NOTIFICATIONS-POLICY-001`
- **Supersedes:** none

Notification permission MUST be requested only when a user chooses notification-dependent behavior, with purpose, fields, fallback, and settings path explained. Rules bind a canonical object and user policy; previews redact sensitive content by default; copy is calm and non-shaming; quiet hours and duplicate-source risk are honored. Generic return prompts, productivity pressure, learning insights, and hidden private detail are forbidden.

Lock-screen notification copy SHOULD be private by default.

Notifications MUST NOT be aggressive, overly personal, or emotionally interpretive.

## SYSTEM-NOTIFICATIONS-EFFECT-001 — Scheduling and actions preserve local authority

- **Concept:** `system.notifications.external-effect`
- **Modality:** `MUST`
- **Scope:** Notification scheduling/removal/reconciliation and Complete, Start, Snooze, Reschedule, Add Proof, Open, and Review actions
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-NOTIFICATIONS-EFFECT-001`
- **Supersedes:** none

Local validated commit of a Notification Rule or object mutation MUST precede notification scheduling/removal. Delivery state is an outbox result, not canonical success. Every mutating action preserves command/idempotency identity and follows validation through Event, Projection, Receipt, and Replay; Reminder acknowledgment alone never completes underlying work.

Notifications MUST be object-aware and action-oriented.

Notification actions MAY include Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow.

## SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001 — Notification commands preserve local ownership before external effects

- **Concept:** `system.notifications.command-contract`
- **Modality:** `MUST`
- **Scope:** Notification Rule lifecycle, permission denial, iOS scheduling/removal, callback routing, foreground reconciliation, privacy-filtered payloads, focus, offline use, and accessibility
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001`
- **Supersedes:** none

Notification rules MUST expose `Create Rule`, `Edit Rule`, `Turn Off`, `Remove Rule`, `Try Again`, `Reconcile`, `Open Settings`, and `Done`.

Create/edit/remove commits the local Notification Rule first through the canonical mutation sequence. Scheduling or removal through iOS is a separate external result. `Remove Rule` MUST NOT delete its Step, Event, Reminder, or Goal.

Notification callbacks may offer `Complete`, `Start`, `Snooze`, `Reschedule`, `Add Proof`, `Open Event`, and `Review Reflow`, but each action MUST route to its canonical owner and revalidate object revision, authorization, proof requirements, and idempotency. Delivery or acknowledgment alone MUST NOT complete work.

Permission denial leaves the rule local and inactive. Foreground reconciliation compares current committed rules with system requests without duplicate scheduling or action replay.


Success focuses the changed rule/status; external failure focuses failed delivery state and `Try Again`; callback action focuses its owning object or consequence preview. Lock Screen payloads remain minimized and privacy-filtered.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Owns notification permission posture, rule-to-request derivation, privacy preview, quiet-hour/duplicate policy, delivery reconciliation, and action handoff. It does not own object completion, surface navigation, external calendar alerts, canonical mutation, or guaranteed delivery.

<!-- canon-section: inputs-outputs -->
The contract consumes Notification Rules, object projections, permission/privacy/quiet-hour state, locale/time-zone, and durable outbox intent. It emits minimized requests, removal/reconciliation work, delivery state, action Commands, Receipt linkage, and privacy-safe presentation.

<!-- canon-section: authority-boundary -->
Notification APIs and callbacks are external adapters. They never open unrestricted stores, decide product policy, or mutate canonical state; `Commands/` validates actions and `ExternalWrites/` owns effects.

<!-- canon-section: data-classification -->
Titles, schedules, proof state, rationale, Goal links, and actions are private. Lock Screen payloads use explicit sensitivity policy and minimum fields; diagnostics record identifiers/results, not private copy.

<!-- canon-section: state-model -->
Rule and effect state distinguishes disabled, permission-not-requested/denied/allowed, scheduled, superseded, removed, delivered, acted, externally failed, and reconciled while retaining canonical object/rule identity.

<!-- canon-section: failure-recovery -->
Permission denial, stale schedule, DST/time-zone change, duplicate request, callback replay, or delivery failure preserves local objects and exposes contextual retry/settings/reconcile behavior. Relaunch rebuilds requests from current committed rules without duplicate actions.

<!-- canon-section: local-network-boundary -->
Local notifications, rules, actions, and reconciliation require no account/network. Denial or platform failure degrades alerts only and never blocks local planning/execution; no private notification content is sent to Ambitions backend/R2/Source Atlas.

<!-- canon-section: determinism -->
Stable committed rules, object facts, permission/privacy/quiet-hour state, locale/time-zone, and policy select the same request set and redaction. Callback duplication yields one canonical mutation.

<!-- canon-section: observability -->
Local redacted traces bind rule/object/request/command IDs, permission/privacy policy, scheduled time, delivery/action/reconciliation result, Receipt, and retry without message content.

<!-- canon-section: source-ownership -->
Exact targets are `Core/Permissions/`, `Core/LocalRuntimeOS/ExternalWrites/`, `Commands/`, and `Projections/`; `Surfaces/You/` presents settings and `Quality/` proves device/privacy/action behavior. Current permission/runtime/outbox source is not complete app-wide or device proof.

<!-- canon-section: tests-proof -->
Exercise contextual ask/denial, every rule/object class and action, preview privacy states, quiet hours, duplicates/external alerts, DST/time-zone/locale/significant-time changes, removal/update, callback replay/spoof, offline/relaunch, outbox failure/reconcile, Reminder noncompletion, VoiceOver actions, and physical-device Lock Screen behavior.

<!-- canon-section: performance-resource-constraints -->
Scheduling and reconciliation are bounded, cancellable, batched, lifecycle-safe, and off-main where material; callbacks finish promptly with safe fallback. Article 31 calibration must declare representative rule/request scale, device/OS/build/tool, timing/energy measures, percentile/maximum, and regression threshold; no numeric budget or device proof is asserted.
