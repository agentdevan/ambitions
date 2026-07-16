+++
spec_id = "APP-DEEP-LINKING"
title = "Deep Linking and External Route Entry"
kind = "app"
status = "normative"
owner_domain = "app-deep-linking"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "app.deep-linking.command-contract",
  "app.deep-linking.external-entry",
  "app.deep-linking.fallback",
  "app.deep-linking.privacy",
  "app.deep-linking.resolution",
  "app.deep-linking.state",
]
inherits = [
  "LAW-IA-NONROOT-001",
  "CONST-RUNTIME-MUTATION-001",
  "CONTROL-MATERIAL-CONFIRMATION-001",
  "LAW-LOCAL-AUTHORITY-001",
  "PLATFORM-NATIVE-IPHONE-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-NAVIGATION", "APP-DEGRADED-STATES"]
source_owners = [
  "Native/Ambitions/App/",
  "Native/Ambitions/PreviewSupport/",
  "Native/Ambitions/Quality/",
]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-CONSUMED"
requirement_id = "APP-DEEP-LINK-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Dismiss => destination: the nearest safe owning context without protected target disclosure from Deep-link intake and resolution — Consumed; effect: No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: This link was already used. Saved information remains unchanged.; focus: the safe destination heading after Consumed."
durable_effect = "Exact deep-link consequences: Dismiss: No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: This link was already used. Saved information remains unchanged. Current visible status: This link was already used. Saved information remains unchanged."
recovery_rollback = "Exact fallback and replay protection: Dismiss: No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input. Recovery preserves: This link was already used. Saved information remains unchanged."
offline_behavior = "Allowlisted local routes and preserved Capture input remain available offline; network-only destinations wait without changing local truth. Offline evidence remains: This link was already used. Saved information remains unchanged."
accessibility_focus = "VoiceOver route and recovery contract: Dismiss announces its safe route consequence; success focuses the safe destination heading after Consumed; rejection focuses the Dismiss control and opaque recovery reason in Deep-link intake and resolution — Consumed. The announcement first communicates: This link was already used. Saved information remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-APP-DEEP-LINK-INTAKE-CONSUMED-001"
label = "Dismiss"
canonical_owner = "app.deep-linking.command-contract"
preconditions = ["The current stable route and originating valid root have been revalidated", "The opaque deep-link request identity and source-class revision are current"]
destination = "the nearest safe owning context without protected target disclosure from Deep-link intake and resolution — Consumed"
effect = "No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: This link was already used. Saved information remains unchanged."
success_focus = "the safe destination heading after Consumed"
failure_focus = "the Dismiss control and opaque recovery reason in Deep-link intake and resolution — Consumed"
commit_boundary = "Non-mutating: route resolution, retry, fallback, or dismissal completes without a canonical commit."
rollback_undo = "No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input."
privacy_egress = "Resolution uses only allowlisted source metadata and opaque identifiers; rejected or locked targets disclose no protected identity or content."
verification_ids = ["SCENARIO-APP-DEEP-LINK-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-PRESENTED"
requirement_id = "APP-DEEP-LINK-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Dismiss => destination: the nearest safe owning context without protected target disclosure from Deep-link intake and resolution — Presented; effect: No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: This link has already opened once. Goals, Captures, time, and settings remain as they were.; focus: the safe destination heading after Presented."
durable_effect = "Exact deep-link consequences: Dismiss: No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: This link has already opened once. Goals, Captures, time, and settings remain as they were. Current visible status: This link has already opened once. Goals, Captures, time, and settings remain as they were."
recovery_rollback = "Exact fallback and replay protection: Dismiss: No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input. Recovery preserves: This link has already opened once. Goals, Captures, time, and settings remain as they were."
offline_behavior = "Allowlisted local routes and preserved Capture input remain available offline; network-only destinations wait without changing local truth. Offline evidence remains: This link has already opened once. Goals, Captures, time, and settings remain as they were."
accessibility_focus = "VoiceOver route and recovery contract: Dismiss announces its safe route consequence; success focuses the safe destination heading after Presented; rejection focuses the Dismiss control and opaque recovery reason in Deep-link intake and resolution — Presented. The announcement first communicates: This link has already opened once. Goals, Captures, time, and settings remain as they were."

[[state_command_contracts.commands]]
command_id = "CMD-APP-DEEP-LINK-INTAKE-PRESENTED-001"
label = "Dismiss"
canonical_owner = "app.deep-linking.command-contract"
preconditions = ["The current stable route and originating valid root have been revalidated", "The opaque deep-link request identity and source-class revision are current"]
destination = "the nearest safe owning context without protected target disclosure from Deep-link intake and resolution — Presented"
effect = "No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: This link has already opened once. Goals, Captures, time, and settings remain as they were."
success_focus = "the safe destination heading after Presented"
failure_focus = "the Dismiss control and opaque recovery reason in Deep-link intake and resolution — Presented"
commit_boundary = "Non-mutating: route resolution, retry, fallback, or dismissal completes without a canonical commit."
rollback_undo = "No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input."
privacy_egress = "Resolution uses only allowlisted source metadata and opaque identifiers; rejected or locked targets disclose no protected identity or content."
verification_ids = ["SCENARIO-APP-DEEP-LINK-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-QUEUED"
requirement_id = "APP-DEEP-LINK-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Dismiss => destination: the nearest safe owning context without protected target disclosure from Deep-link intake and resolution — Queued; effect: No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: Ambitions cannot open this link yet. Destination and access checks are pending; no Goal, Capture, or time item has changed.; focus: the safe destination heading after Queued."
durable_effect = "Exact deep-link consequences: Dismiss: No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: Ambitions cannot open this link yet. Destination and access checks are pending; no Goal, Capture, or time item has changed. Current visible status: Ambitions cannot open this link yet. Destination and access checks are pending; no Goal, Capture, or time item has changed."
recovery_rollback = "Exact fallback and replay protection: Dismiss: No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input. Recovery preserves: Ambitions cannot open this link yet. Destination and access checks are pending; no Goal, Capture, or time item has changed."
offline_behavior = "Allowlisted local routes and preserved Capture input remain available offline; network-only destinations wait without changing local truth. Offline evidence remains: Ambitions cannot open this link yet. Destination and access checks are pending; no Goal, Capture, or time item has changed."
accessibility_focus = "VoiceOver route and recovery contract: Dismiss announces its safe route consequence; success focuses the safe destination heading after Queued; rejection focuses the Dismiss control and opaque recovery reason in Deep-link intake and resolution — Queued. The announcement first communicates: Ambitions cannot open this link yet. Destination and access checks are pending; no Goal, Capture, or time item has changed."

[[state_command_contracts.commands]]
command_id = "CMD-APP-DEEP-LINK-INTAKE-QUEUED-001"
label = "Dismiss"
canonical_owner = "app.deep-linking.command-contract"
preconditions = ["The current stable route and originating valid root have been revalidated", "The opaque deep-link request identity and source-class revision are current"]
destination = "the nearest safe owning context without protected target disclosure from Deep-link intake and resolution — Queued"
effect = "No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: Ambitions cannot open this link yet. Destination and access checks are pending; no Goal, Capture, or time item has changed."
success_focus = "the safe destination heading after Queued"
failure_focus = "the Dismiss control and opaque recovery reason in Deep-link intake and resolution — Queued"
commit_boundary = "Non-mutating: route resolution, retry, fallback, or dismissal completes without a canonical commit."
rollback_undo = "No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input."
privacy_egress = "Resolution uses only allowlisted source metadata and opaque identifiers; rejected or locked targets disclose no protected identity or content."
verification_ids = ["SCENARIO-APP-DEEP-LINK-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-RECOVERABLE"
requirement_id = "APP-DEEP-LINK-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Dismiss => destination: the nearest safe owning context without protected target disclosure from Deep-link intake and resolution — Recoverable; effect: No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: This link did not open because its destination or access needs another check. Saved information is unchanged.; focus: the safe destination heading after Recoverable.\nTry Again => destination: the allowlisted deep-link resolver for the interrupted request from Deep-link intake and resolution — Recoverable; effect: No durable mutation occurs and no Receipt is created; Try Again repeats only source-class, access, version, and destination resolution. It cannot replay a consumed action or commit a material request. Visible evidence remains: This link did not open because its destination or access needs another check. Saved information is unchanged.; focus: the safe destination heading after Recoverable."
durable_effect = "Exact deep-link consequences: Dismiss: No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: This link did not open because its destination or access needs another check. Saved information is unchanged. | Try Again: No durable mutation occurs and no Receipt is created; Try Again repeats only source-class, access, version, and destination resolution. It cannot replay a consumed action or commit a material request. Visible evidence remains: This link did not open because its destination or access needs another check. Saved information is unchanged. Current visible status: This link did not open because its destination or access needs another check. Saved information is unchanged."
recovery_rollback = "Exact fallback and replay protection: Dismiss: No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input. | Try Again: No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input. Recovery preserves: This link did not open because its destination or access needs another check. Saved information is unchanged."
offline_behavior = "Allowlisted local routes and preserved Capture input remain available offline; network-only destinations wait without changing local truth. Offline evidence remains: This link did not open because its destination or access needs another check. Saved information is unchanged."
accessibility_focus = "VoiceOver route and recovery contract: Dismiss announces its safe route consequence; success focuses the safe destination heading after Recoverable; rejection focuses the Dismiss control and opaque recovery reason in Deep-link intake and resolution — Recoverable | Try Again announces its safe route consequence; success focuses the safe destination heading after Recoverable; rejection focuses the Try Again control and opaque recovery reason in Deep-link intake and resolution — Recoverable. The announcement first communicates: This link did not open because its destination or access needs another check. Saved information is unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-APP-DEEP-LINK-INTAKE-RECOVERABLE-001"
label = "Dismiss"
canonical_owner = "app.deep-linking.command-contract"
preconditions = ["The current stable route and originating valid root have been revalidated", "The opaque deep-link request identity and source-class revision are current"]
destination = "the nearest safe owning context without protected target disclosure from Deep-link intake and resolution — Recoverable"
effect = "No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: This link did not open because its destination or access needs another check. Saved information is unchanged."
success_focus = "the safe destination heading after Recoverable"
failure_focus = "the Dismiss control and opaque recovery reason in Deep-link intake and resolution — Recoverable"
commit_boundary = "Non-mutating: route resolution, retry, fallback, or dismissal completes without a canonical commit."
rollback_undo = "No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input."
privacy_egress = "Resolution uses only allowlisted source metadata and opaque identifiers; rejected or locked targets disclose no protected identity or content."
verification_ids = ["SCENARIO-APP-DEEP-LINK-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-APP-DEEP-LINK-INTAKE-RECOVERABLE-002"
label = "Try Again"
canonical_owner = "app.deep-linking.command-contract"
preconditions = ["Destination access and disclosure eligibility have been revalidated", "The interrupted request is recoverable and has not been consumed", "The opaque deep-link request identity and source-class revision are current"]
destination = "the allowlisted deep-link resolver for the interrupted request from Deep-link intake and resolution — Recoverable"
effect = "No durable mutation occurs and no Receipt is created; Try Again repeats only source-class, access, version, and destination resolution. It cannot replay a consumed action or commit a material request. Visible evidence remains: This link did not open because its destination or access needs another check. Saved information is unchanged."
success_focus = "the safe destination heading after Recoverable"
failure_focus = "the Try Again control and opaque recovery reason in Deep-link intake and resolution — Recoverable"
commit_boundary = "Non-mutating: route resolution, retry, fallback, or dismissal completes without a canonical commit."
rollback_undo = "No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input."
privacy_egress = "Resolution uses only allowlisted source metadata and opaque identifiers; rejected or locked targets disclose no protected identity or content."
verification_ids = ["SCENARIO-APP-DEEP-LINK-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-REJECTED"
requirement_id = "APP-DEEP-LINK-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Dismiss => destination: the nearest safe owning context without protected target disclosure from Deep-link intake and resolution — Rejected; effect: No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: This link could not open safely. No saved information or Capture changed.; focus: the safe destination heading after Rejected.\nUnlock => destination: the native protected-data unlock challenge, then deep-link revalidation; effect: The Unlock external result causes no local canonical mutation; successful authentication only resumes full allowlist, authorization, target, and revision validation; it never commits the requested action; focus: the revalidated owning destination heading or consequence preview.\nUpdate Ambitions => destination: the Apple-managed Ambitions update destination; effect: The Update Ambitions external result causes no local canonical mutation; the handoff reveals no target identity and returning cannot replay or commit the link; focus: the Apple-managed update destination heading."
durable_effect = "Exact deep-link consequences: Dismiss: No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: This link could not open safely. No saved information or Capture changed. Current visible status: This link could not open safely. No saved information or Capture changed."
recovery_rollback = "Exact fallback and replay protection: Dismiss: No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input. Recovery preserves: This link could not open safely. No saved information or Capture changed."
offline_behavior = "Allowlisted local routes and preserved Capture input remain available offline; network-only destinations wait without changing local truth. Offline evidence remains: This link could not open safely. No saved information or Capture changed."
accessibility_focus = "VoiceOver route and recovery contract: Dismiss announces its safe route consequence; success focuses the safe destination heading after Rejected; rejection focuses the Dismiss control and opaque recovery reason in Deep-link intake and resolution — Rejected. The announcement first communicates: This link could not open safely. No saved information or Capture changed."

[[state_command_contracts.commands]]
command_id = "CMD-APP-DEEP-LINK-INTAKE-REJECTED-001"
label = "Dismiss"
canonical_owner = "app.deep-linking.command-contract"
preconditions = ["The current stable route and originating valid root have been revalidated", "The opaque deep-link request identity and source-class revision are current"]
destination = "the nearest safe owning context without protected target disclosure from Deep-link intake and resolution — Rejected"
effect = "No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: This link could not open safely. No saved information or Capture changed."
success_focus = "the safe destination heading after Rejected"
failure_focus = "the Dismiss control and opaque recovery reason in Deep-link intake and resolution — Rejected"
commit_boundary = "Non-mutating: route resolution, retry, fallback, or dismissal completes without a canonical commit."
rollback_undo = "No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input."
privacy_egress = "Resolution uses only allowlisted source metadata and opaque identifiers; rejected or locked targets disclose no protected identity or content."
verification_ids = ["SCENARIO-APP-DEEP-LINK-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-APP-DEEP-LINK-INTAKE-REJECTED-002"
label = "Unlock"
canonical_owner = "app.deep-linking.command-contract"
preconditions = ["The allowlisted deep-link rejection class is locked-target only", "The protected target identity remains opaque until successful device authentication", "The requested route and object revision will be fully revalidated after authentication"]
destination = "the native protected-data unlock challenge, then deep-link revalidation"
effect = "The Unlock external result causes no local canonical mutation; successful authentication only resumes full allowlist, authorization, target, and revision validation; it never commits the requested action"
success_focus = "the revalidated owning destination heading or consequence preview"
failure_focus = "the Unlock control and opaque authentication reason"
commit_boundary = "External-result: the external or protected-system result is revalidated before any separately authorized local command."
rollback_undo = "No Undo is required; cancellation or external failure preserves the prior verified local state."
privacy_egress = "Device authentication receives no Ambitions private content or target identity."
verification_ids = ["SCENARIO-APP-DEEP-LINK-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-APP-DEEP-LINK-INTAKE-REJECTED-003"
label = "Update Ambitions"
canonical_owner = "app.deep-linking.command-contract"
preconditions = ["Returning from the update destination requires cold re-resolution of the link", "The allowlisted deep-link rejection class is stale-or-unsupported-version only", "The update handoff discloses no protected target identity"]
destination = "the Apple-managed Ambitions update destination"
effect = "The Update Ambitions external result causes no local canonical mutation; the handoff reveals no target identity and returning cannot replay or commit the link"
success_focus = "the Apple-managed update destination heading"
failure_focus = "the Update Ambitions control and safe unsupported-version reason"
commit_boundary = "External-result: the external or protected-system result is revalidated before any separately authorized local command."
rollback_undo = "No Undo is required; cancellation or external failure preserves the prior verified local state."
privacy_egress = "Only the public Ambitions application identity reaches Apple; no private graph data leaves the device."
verification_ids = ["SCENARIO-APP-DEEP-LINK-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-RESOLVING"
requirement_id = "APP-DEEP-LINK-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Dismiss => destination: the nearest safe owning context without protected target disclosure from Deep-link intake and resolution — Resolving; effect: No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: Ambitions is checking this link before anything opens or changes.; focus: the safe destination heading after Resolving."
durable_effect = "Exact deep-link consequences: Dismiss: No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: Ambitions is checking this link before anything opens or changes. Current visible status: Ambitions is checking this link before anything opens or changes."
recovery_rollback = "Exact fallback and replay protection: Dismiss: No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input. Recovery preserves: Ambitions is checking this link before anything opens or changes."
offline_behavior = "Allowlisted local routes and preserved Capture input remain available offline; network-only destinations wait without changing local truth. Offline evidence remains: Ambitions is checking this link before anything opens or changes."
accessibility_focus = "VoiceOver route and recovery contract: Dismiss announces its safe route consequence; success focuses the safe destination heading after Resolving; rejection focuses the Dismiss control and opaque recovery reason in Deep-link intake and resolution — Resolving. The announcement first communicates: Ambitions is checking this link before anything opens or changes."

[[state_command_contracts.commands]]
command_id = "CMD-APP-DEEP-LINK-INTAKE-RESOLVING-001"
label = "Dismiss"
canonical_owner = "app.deep-linking.command-contract"
preconditions = ["The current stable route and originating valid root have been revalidated", "The opaque deep-link request identity and source-class revision are current"]
destination = "the nearest safe owning context without protected target disclosure from Deep-link intake and resolution — Resolving"
effect = "No durable mutation occurs and no Receipt is created; Dismiss closes only the route request. It cannot consume, replay, reveal, or mutate the requested target, and recoverable Capture input remains locally preserved. Visible evidence remains: Ambitions is checking this link before anything opens or changes."
success_focus = "the safe destination heading after Resolving"
failure_focus = "the Dismiss control and opaque recovery reason in Deep-link intake and resolution — Resolving"
commit_boundary = "Non-mutating: route resolution, retry, fallback, or dismissal completes without a canonical commit."
rollback_undo = "No Undo is required; cancellation preserves the last stable route, local canonical state, and any recoverable Capture input."
privacy_egress = "Resolution uses only allowlisted source metadata and opaque identifiers; rejected or locked targets disclose no protected identity or content."
verification_ids = ["SCENARIO-APP-DEEP-LINK-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

+++

# Deep Linking and External Route Entry

This shadow specification defines how trusted local route requests and external ecosystem entry resolve into app navigation.

## APP-DEEP-LINK-EXTERNAL-ENTRY-001 — External entry preserves owning-system boundaries

- **Concept:** `app.deep-linking.external-entry`
- **Modality:** `MUST`
- **Scope:** Share intake, Spotlight, widgets, App Intents, notifications, files, and approved deep-link sources
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEEP-LINK-EXTERNAL-001`, `AUDIT-APP-DEEP-LINK-MUTATION-001`
- **Supersedes:** none

External entry MUST resolve through a typed, allowlisted route contract. Share intake routes preserved source content into the owning Capture intake contract; Spotlight and glance surfaces index or carry only approved privacy-filtered local metadata; widgets, App Intents, notifications, and files route to the owning object, date, review, setting, or composer context. No external route may create a new root, bypass authorization or confirmation, or mutate canonical state directly.

## APP-DEEP-LINK-RESOLVE-001 — Resolution validates target and action separately

- **Concept:** `app.deep-linking.resolution`
- **Modality:** `MUST`
- **Scope:** Incoming route parsing, target lookup, eligibility, and optional action intent
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEEP-LINK-RESOLVE-001`, `SCENARIO-APP-DEEP-LINK-REJECT-001`
- **Supersedes:** none

Resolution MUST parse a versioned route identifier, validate source class and payload shape, resolve a local owner and target, and then validate any requested action as a separate step. Opening a destination may be allowed when mutation is not. A material action requires current authorization, consequence preview, confirmation where applicable, and the constitutional mutation sequence after the app is foregrounded in a comprehensible context.

## APP-DEEP-LINK-PRIVACY-001 — Routes disclose minimum necessary identity

- **Concept:** `app.deep-linking.privacy`
- **Modality:** `MUST`
- **Scope:** Route payloads, logs, Spotlight metadata, notification actions, extension handoff, and diagnostics
- **Status:** `normative`
- **Verification:** `PRIVACY-APP-DEEP-LINK-PAYLOAD-001`, `AUDIT-APP-DEEP-LINK-REDACTION-001`
- **Supersedes:** none

Route payloads MUST use opaque minimum-necessary identity and approved action parameters. They must not embed private titles, notes, proof, receipts, schedule assumptions, inferred priorities, or private graph context in URLs, public indexes, logs, analytics, or cross-process handoff unless a separately approved local protected channel and owning specification require the exact field. Invalid or unauthorized routes reveal no target existence.

## APP-DEEP-LINK-FALLBACK-001 — Unavailable targets degrade safely

- **Concept:** `app.deep-linking.fallback`
- **Modality:** `MUST`
- **Scope:** Missing, deleted, archived, trashed, locked, unauthorized, stale-version, and unsupported targets
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEEP-LINK-MISSING-001`, `SCENARIO-APP-DEEP-LINK-UNAUTHORIZED-001`
- **Supersedes:** none

An unavailable target MUST degrade to the nearest safe owning context without fabricating content or leaking why a protected target failed. When useful and authorized, the user may search locally, open the relevant root or setting, restore from Trash through the owning flow, update the app, or retry after unlocking. Unsupported versions fail closed and retain source input where the owning intake contract permits recovery.

## APP-DEEP-LINK-STATE-001 — Route handling is replay-safe and single-use where required

- **Concept:** `app.deep-linking.state`
- **Modality:** `MUST`
- **Scope:** Queued, resolving, presented, rejected, consumed, and recoverable external routes
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEEP-LINK-REPLAY-001`, `SCENARIO-APP-DEEP-LINK-INTERRUPTION-001`
- **Supersedes:** none

Deep-link state MUST distinguish queued, resolving, presented, rejected, consumed, and recoverable input. Repeated delivery may reopen an idempotent destination but cannot repeat a consumed mutation or duplicate Capture intake. Interruption preserves recoverable input and resumes only after revalidating target, authorization, canonical state, and user-visible consequence.

## APP-DEEP-LINK-COMMAND-CONTRACT-001 — Deep-link commands resolve safely without replay

- **Concept:** `app.deep-linking.command-contract`
- **Modality:** `MUST`
- **Scope:** Allowlisted deep-link intake, resolution, fallback, retry, dismissal, focus, privacy, and single-use replay protection
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEEP-LINK-COMMAND-CONTRACT-001`
- **Supersedes:** none

Every deep link MUST resolve through an allowlisted source-class contract and choose the nearest authorized owning context:

- Share/File recoverable input → Capture draft.
- Spotlight, Widget, App Intent, Notification, or Handoff → owning object, date, setting, review, or material-action preview.
- Missing or deleted authorized target → Search or Trash only when existence and access may safely be disclosed.
- Locked target → `Unlock` followed by full revalidation.
- Stale or unsupported version → `Update Ambitions` or `Dismiss`.
- Recoverable interruption → `Try Again` or `Dismiss`.
- Malformed or unauthorized input → `Dismiss` only, without target disclosure.

Fallback order MUST be: nearest safe owning context, originating valid root, current stable route, then Today on cold launch. A material requested action MUST focus its consequence preview and never commit directly from the link. Consumed single-use actions MUST NOT replay.


Presented destinations focus their heading or resolved object. Material actions focus the first consequence. Rejection focuses the recovery control without announcing protected identity. Recoverable Capture input remains locally preserved until explicitly accepted or discarded.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Deep linking owns typed external route intake, allowlisting, target/action resolution, minimum payloads, replay handling, and safe fallback. It does not own source-app behavior, canonical objects, destination UI, mutation policy, public indexing policy beyond route payloads, or extension implementation completeness.

<!-- canon-section: inputs-outputs -->
The resolver consumes one bounded typed envelope and emits one typed resolution result.

Inputs are route version, source class, opaque target reference, approved parameters, app lifecycle, local authorization, target eligibility, and optional recoverable content. Outputs are a validated navigation request, a separately validated action proposal, a safe fallback, or a rejection with no private disclosure.

<!-- canon-section: authority-boundary -->
Navigation owns presentation, destination specifications own behavior, Capture owns shared input intake, and LocalRuntimeOS owns mutation. Deep links are entry references only and cannot become roots, stores, object owners, or direct-write paths.

<!-- canon-section: data-classification -->
All route data is minimum-necessary local operational metadata unless the owning protected intake contract classifies preserved content more restrictively. Public URL/query text, Spotlight metadata, and diagnostic logs exclude private graph content by default.

<!-- canon-section: state-model -->
The route record uses explicit orthogonal fields for lifecycle, resolution, and authorization.

Route state includes source, version, opaque target, parameters, lifecycle state, resolution status, action eligibility, consumption token where needed, fallback, and redacted diagnostic reason. Target existence and authorization remain separate.

<!-- canon-section: failure-recovery -->
Resolution errors retain recoverable intake and produce a safe destination or rejection.

Malformed, stale, unknown, missing, locked, unauthorized, or interrupted routes fail closed. Recovery may update, unlock, retry, search locally, open a safe owner, or resume preserved intake; it never repeats a consumed mutation or reveals protected target facts.

<!-- canon-section: local-network-boundary -->
Local object, date, review, setting, Search, and Capture routes resolve offline without an account. A route cannot require a server redirect to discover private identity. Optional external/reference destinations own their own offline fallback.

<!-- canon-section: determinism -->
Route resolution is a pure decision over the declared typed inputs and current local facts.

The same route version, source class, payload, authorization, and current local state produce the same resolution or rejection. Free-form external text cannot choose arbitrary internal types, selectors, commands, or paths.

<!-- canon-section: observability -->
Redacted route evidence records the decision without copying protected payload content.

Evidence records source class, route version, redacted target class, resolution result, action eligibility, presentation result, fallback, and consumption/idempotency result. Private identifiers and payload content remain redacted in routine diagnostics.

<!-- canon-section: source-ownership -->
`App/` owns the registry, typed external-route models, translators, payload/overlay translation, and App Intent launch routing; preview routing remains non-authoritative; `Quality/` owns route, privacy, replay, and accessibility proof.

<!-- canon-section: tests-proof -->
The verification matrix executes each approved source class and route outcome.

Required proof covers every approved source class, versions, malformed and unknown routes, missing/deleted/trashed/locked targets, authorization denial, privacy redaction, offline resolution, duplicate delivery, interrupted intake, action confirmation, no direct mutation, focus restoration, VoiceOver destination announcement, Dynamic Type, and Reduce Motion.

<!-- canon-section: performance-resource-constraints -->
An external route envelope MUST be at most 16 KiB, use maximum nesting depth 8, and enter a queue capped at 32 items; larger or deeper input fails closed before allocation proportional to claimed size. On the oldest supported physical iPhone in an optimized build with 250 typed routes and maximum app route depth 20, parse plus local resolution MUST complete within 25 ms at P95 and presentation dispatch within 50 ms at P95 across 10,000 routes. The run MUST add no more than 8 MiB resident memory, perform zero synchronous disk I/O and zero network calls on resolution, and consume each single-use action at most once. Extension and app handling MUST use no polling or autonomous retry loop.
