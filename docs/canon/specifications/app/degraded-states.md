+++
spec_id = "APP-DEGRADED-STATES"
title = "App Degraded States"
kind = "app"
status = "normative"
owner_domain = "app-degraded-states"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "app.degraded.command-contract",
  "app.degraded.failure-taxonomy",
  "app.degraded.input-preservation",
  "app.degraded.presentation",
  "app.degraded.recovery",
  "app.degraded.state",
]
inherits = [
  "LAW-OFFLINE-NO-ACCOUNT-001",
  "CONTROL-UNDO-RECOVERY-001",
  "LAW-RUNTIME-DURABLE-SUCCESS-001",
  "LAW-DATA-LOSS-STOP-SHIP-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
  "CONST-PROOF-EVIDENCE-001",
]
depends_on = ["CONSTITUTION"]
source_owners = [
  "Native/Ambitions/DesignSystem/",
  "Native/Ambitions/Core/LocalRuntimeOS/Repair/",
  "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/",
  "Native/Ambitions/Diagnostics/",
  "Native/Ambitions/Surfaces/Today/",
  "Native/Ambitions/Surfaces/Goals/",
  "Native/Ambitions/Surfaces/Time/",
  "Native/Ambitions/Surfaces/You/",
  "Native/Ambitions/Quality/",
]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-CONFLICT"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review Conflict => destination: the future-gated continuity conflict review from Scoped degraded state — Continuity Conflict; effect: No durable mutation occurs and no Receipt is created; Review Conflict is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Optional continuity copies disagree. Information saved on this device remains protected and unchanged.; focus: the updated classified status or first affected item after Review Conflict in Scoped degraded state — Continuity Conflict."
durable_effect = "Exact failure-class recovery consequences: Review Conflict: No durable mutation occurs and no Receipt is created; Review Conflict is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Optional continuity copies disagree. Information saved on this device remains protected and unchanged. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: Optional continuity copies disagree. Information saved on this device remains protected and unchanged."
recovery_rollback = "Exact classified recovery and rollback: Review Conflict: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: Optional continuity copies disagree. Information saved on this device remains protected and unchanged."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: Optional continuity copies disagree. Information saved on this device remains protected and unchanged."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Review Conflict announces failure class and consequence; success focuses the updated classified status or first affected item after Review Conflict in Scoped degraded state — Continuity Conflict; rejection focuses the Review Conflict control and exact affected scope or failed identity in Scoped degraded state — Continuity Conflict. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: Optional continuity copies disagree. Information saved on this device remains protected and unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-CONFLICT-001"
label = "Review Conflict"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the disabled continuity gate, local source authority, checkpoint, and quarantined alternatives"]
destination = "the future-gated continuity conflict review from Scoped degraded state — Continuity Conflict"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-CONFLICT-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Conflict is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Optional continuity copies disagree. Information saved on this device remains protected and unchanged."
success_focus = "the updated classified status or first affected item after Review Conflict in Scoped degraded state — Continuity Conflict"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-CONFLICT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Conflict control and exact affected scope or failed identity in Scoped degraded state — Continuity Conflict"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-CONFLICT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-CONFLICT-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-PENDING"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review Continuity Status => destination: the disabled continuity status explanation from Scoped degraded state — Continuity Pending; effect: No durable mutation occurs and no Receipt is created; Review Continuity Status is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: A continuity update is waiting. Information already saved on this device remains unchanged.; focus: the updated classified status or first affected item after Review Continuity Status in Scoped degraded state — Continuity Pending."
durable_effect = "Exact failure-class recovery consequences: Review Continuity Status: No durable mutation occurs and no Receipt is created; Review Continuity Status is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: A continuity update is waiting. Information already saved on this device remains unchanged. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: A continuity update is waiting. Information already saved on this device remains unchanged."
recovery_rollback = "Exact classified recovery and rollback: Review Continuity Status: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: A continuity update is waiting. Information already saved on this device remains unchanged."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: A continuity update is waiting. Information already saved on this device remains unchanged."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Review Continuity Status announces failure class and consequence; success focuses the updated classified status or first affected item after Review Continuity Status in Scoped degraded state — Continuity Pending; rejection focuses the Review Continuity Status control and exact affected scope or failed identity in Scoped degraded state — Continuity Pending. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: A continuity update is waiting. Information already saved on this device remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-PENDING-001"
label = "Review Continuity Status"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the disabled continuity gate, local source authority, checkpoint, and quarantined alternatives"]
destination = "the disabled continuity status explanation from Scoped degraded state — Continuity Pending"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-PENDING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Continuity Status is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: A continuity update is waiting. Information already saved on this device remains unchanged."
success_focus = "the updated classified status or first affected item after Review Continuity Status in Scoped degraded state — Continuity Pending"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-PENDING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Continuity Status control and exact affected scope or failed identity in Scoped degraded state — Continuity Pending"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-PENDING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-PENDING-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-EXTERNAL-WRITE-FAILURE"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Retry External Update => destination: the owning external-write reconciliation result from Scoped degraded state — External Write Failure; effect: The Retry External Update external result causes no local canonical mutation; it retries only the failed external outbox identity and cannot replay or roll back accepted local success. Visible evidence and local truth remain: An outside update did not finish; the accepted local change remains recorded separately.; focus: the updated classified status or first affected item after Retry External Update in Scoped degraded state — External Write Failure.\nReview Details => destination: the affected-scope status and consequence details from Scoped degraded state — External Write Failure; effect: No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: An outside update did not finish; the accepted local change remains recorded separately.; focus: the updated classified status or first affected item after Review Details in Scoped degraded state — External Write Failure."
durable_effect = "Exact failure-class recovery consequences: Retry External Update: The Retry External Update external result causes no local canonical mutation; it retries only the failed external outbox identity and cannot replay or roll back accepted local success. Visible evidence and local truth remain: An outside update did not finish; the accepted local change remains recorded separately. | Review Details: No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: An outside update did not finish; the accepted local change remains recorded separately. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: An outside update did not finish; the accepted local change remains recorded separately."
recovery_rollback = "Exact classified recovery and rollback: Retry External Update: Cancellation leaves the accepted local result and failed outbox identity unchanged; another retry requires fresh owner and external-state validation. | Review Details: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: An outside update did not finish; the accepted local change remains recorded separately."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: An outside update did not finish; the accepted local change remains recorded separately."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Retry External Update announces failure class and consequence; success focuses the updated classified status or first affected item after Retry External Update in Scoped degraded state — External Write Failure; rejection focuses the Retry External Update control and exact affected scope or failed identity in Scoped degraded state — External Write Failure | Review Details announces failure class and consequence; success focuses the updated classified status or first affected item after Review Details in Scoped degraded state — External Write Failure; rejection focuses the Review Details control and exact affected scope or failed identity in Scoped degraded state — External Write Failure. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: An outside update did not finish; the accepted local change remains recorded separately."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-EXTERNAL-WRITE-FAILURE-001"
label = "Retry External Update"
canonical_owner = "app.degraded.command-contract"
preconditions = ["Only the exact failed external outbox identity may be retried", "The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the accepted local command revision, external outbox identity, and failed external result"]
destination = "the owning external-write reconciliation result from Scoped degraded state — External Write Failure"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-EXTERNAL-WRITE-FAILURE-001"
destination_posture = "current"
effect = "The Retry External Update external result causes no local canonical mutation; it retries only the failed external outbox identity and cannot replay or roll back accepted local success. Visible evidence and local truth remain: An outside update did not finish; the accepted local change remains recorded separately."
success_focus = "the updated classified status or first affected item after Retry External Update in Scoped degraded state — External Write Failure"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-EXTERNAL-WRITE-FAILURE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Retry External Update control and exact affected scope or failed identity in Scoped degraded state — External Write Failure"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-EXTERNAL-WRITE-FAILURE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: the external retry remains downstream of accepted local truth and cannot redefine canonical success."
rollback_undo = "Cancellation leaves the accepted local result and failed outbox identity unchanged; another retry requires fresh owner and external-state validation."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-EXTERNAL-WRITE-FAILURE-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-EXTERNAL-WRITE-FAILURE-002"
label = "Review Details"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the accepted local command revision, external outbox identity, and failed external result"]
destination = "the affected-scope status and consequence details from Scoped degraded state — External Write Failure"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-EXTERNAL-WRITE-FAILURE-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: An outside update did not finish; the accepted local change remains recorded separately."
success_focus = "the updated classified status or first affected item after Review Details in Scoped degraded state — External Write Failure"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-EXTERNAL-WRITE-FAILURE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Details control and exact affected scope or failed identity in Scoped degraded state — External Write Failure"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-EXTERNAL-WRITE-FAILURE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-EXTERNAL-WRITE-FAILURE-002"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-IMPORT-FAILURE"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Retry Failed Items => destination: the owning import review with explicit failed identities from Scoped degraded state — Import Failure; effect: No durable mutation occurs and no Receipt is created; Retry Failed Items is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: An import did not finish. Original input and completed local items remain identifiable.; focus: the updated classified status or first affected item after Retry Failed Items in Scoped degraded state — Import Failure.\nReview Partial Import => destination: the import owner’s completed, failed, and pending record review from Scoped degraded state — Import Failure; effect: No durable mutation occurs and no Receipt is created; Review Partial Import is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: An import did not finish. Original input and completed local items remain identifiable.; focus: the updated classified status or first affected item after Review Partial Import in Scoped degraded state — Import Failure."
durable_effect = "Exact failure-class recovery consequences: Retry Failed Items: No durable mutation occurs and no Receipt is created; Retry Failed Items is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: An import did not finish. Original input and completed local items remain identifiable. | Review Partial Import: No durable mutation occurs and no Receipt is created; Review Partial Import is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: An import did not finish. Original input and completed local items remain identifiable. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: An import did not finish. Original input and completed local items remain identifiable."
recovery_rollback = "Exact classified recovery and rollback: Retry Failed Items: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. | Review Partial Import: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: An import did not finish. Original input and completed local items remain identifiable."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: An import did not finish. Original input and completed local items remain identifiable."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Retry Failed Items announces failure class and consequence; success focuses the updated classified status or first affected item after Retry Failed Items in Scoped degraded state — Import Failure; rejection focuses the Retry Failed Items control and exact affected scope or failed identity in Scoped degraded state — Import Failure | Review Partial Import announces failure class and consequence; success focuses the updated classified status or first affected item after Review Partial Import in Scoped degraded state — Import Failure; rejection focuses the Review Partial Import control and exact affected scope or failed identity in Scoped degraded state — Import Failure. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: An import did not finish. Original input and completed local items remain identifiable."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-IMPORT-FAILURE-001"
label = "Retry Failed Items"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the import source fingerprint and explicit completed, failed, and pending record identities"]
destination = "the owning import review with explicit failed identities from Scoped degraded state — Import Failure"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-IMPORT-FAILURE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Retry Failed Items is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: An import did not finish. Original input and completed local items remain identifiable."
success_focus = "the updated classified status or first affected item after Retry Failed Items in Scoped degraded state — Import Failure"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-IMPORT-FAILURE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Retry Failed Items control and exact affected scope or failed identity in Scoped degraded state — Import Failure"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-IMPORT-FAILURE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-IMPORT-FAILURE-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-IMPORT-FAILURE-002"
label = "Review Partial Import"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the import source fingerprint and explicit completed, failed, and pending record identities"]
destination = "the import owner’s completed, failed, and pending record review from Scoped degraded state — Import Failure"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-IMPORT-FAILURE-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Partial Import is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: An import did not finish. Original input and completed local items remain identifiable."
success_focus = "the updated classified status or first affected item after Review Partial Import in Scoped degraded state — Import Failure"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-IMPORT-FAILURE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Partial Import control and exact affected scope or failed identity in Scoped degraded state — Import Failure"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-IMPORT-FAILURE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-IMPORT-FAILURE-002"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-LOCAL-STORE-DEGRADATION"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Diagnostics => destination: the redacted local Diagnostics inspection from Scoped degraded state — Local Store Degradation; effect: No durable mutation occurs and no Receipt is created; Open Diagnostics is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Some saved local information cannot be read safely; affected content is isolated for recovery.; focus: the updated classified status or first affected item after Open Diagnostics in Scoped degraded state — Local Store Degradation."
durable_effect = "Exact failure-class recovery consequences: Open Diagnostics: No durable mutation occurs and no Receipt is created; Open Diagnostics is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Some saved local information cannot be read safely; affected content is isolated for recovery. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: Some saved local information cannot be read safely; affected content is isolated for recovery."
recovery_rollback = "Exact classified recovery and rollback: Open Diagnostics: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: Some saved local information cannot be read safely; affected content is isolated for recovery."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: Some saved local information cannot be read safely; affected content is isolated for recovery."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Open Diagnostics announces failure class and consequence; success focuses the updated classified status or first affected item after Open Diagnostics in Scoped degraded state — Local Store Degradation; rejection focuses the Open Diagnostics control and exact affected scope or failed identity in Scoped degraded state — Local Store Degradation. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: Some saved local information cannot be read safely; affected content is isolated for recovery."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-LOCAL-STORE-DEGRADATION-001"
label = "Open Diagnostics"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the affected local-store scope, verified snapshot, quarantine identity, and repair evidence"]
destination = "the redacted local Diagnostics inspection from Scoped degraded state — Local Store Degradation"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-LOCAL-STORE-DEGRADATION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Open Diagnostics is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Some saved local information cannot be read safely; affected content is isolated for recovery."
success_focus = "the updated classified status or first affected item after Open Diagnostics in Scoped degraded state — Local Store Degradation"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-LOCAL-STORE-DEGRADATION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open Diagnostics control and exact affected scope or failed identity in Scoped degraded state — Local Store Degradation"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-LOCAL-STORE-DEGRADATION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-LOCAL-STORE-DEGRADATION-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-OFFLINE-HEALTHY"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Details => destination: the affected-scope status and consequence details from Scoped degraded state — Offline Healthy; effect: No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Saved Goals, Captures, and time remain fully available without a connection.; focus: the updated classified status or first affected item after Review Details in Scoped degraded state — Offline Healthy."
durable_effect = "Exact failure-class recovery consequences: Review Details: No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Saved Goals, Captures, and time remain fully available without a connection. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: Saved Goals, Captures, and time remain fully available without a connection."
recovery_rollback = "Exact classified recovery and rollback: Review Details: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: Saved Goals, Captures, and time remain fully available without a connection."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: Saved Goals, Captures, and time remain fully available without a connection."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Review Details announces failure class and consequence; success focuses the updated classified status or first affected item after Review Details in Scoped degraded state — Offline Healthy; rejection focuses the Review Details control and exact affected scope or failed identity in Scoped degraded state — Offline Healthy. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: Saved Goals, Captures, and time remain fully available without a connection."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-OFFLINE-HEALTHY-001"
label = "Review Details"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the classified health evidence, affected scope, current local revision, and safe local availability"]
destination = "the affected-scope status and consequence details from Scoped degraded state — Offline Healthy"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-OFFLINE-HEALTHY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Saved Goals, Captures, and time remain fully available without a connection."
success_focus = "the updated classified status or first affected item after Review Details in Scoped degraded state — Offline Healthy"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-OFFLINE-HEALTHY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Details control and exact affected scope or failed identity in Scoped degraded state — Offline Healthy"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-OFFLINE-HEALTHY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-OFFLINE-HEALTHY-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-PARTIAL-OPERATION"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Retry Failed Items => destination: the owning import review with explicit failed identities from Scoped degraded state — Partial Operation; effect: No durable mutation occurs and no Receipt is created; Retry Failed Items is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Only part of the requested work completed; finished and pending results remain distinct.; focus: the updated classified status or first affected item after Retry Failed Items in Scoped degraded state — Partial Operation.\nReview Partial Import => destination: the import owner’s completed, failed, and pending record review from Scoped degraded state — Partial Operation; effect: No durable mutation occurs and no Receipt is created; Review Partial Import is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Only part of the requested work completed; finished and pending results remain distinct.; focus: the updated classified status or first affected item after Review Partial Import in Scoped degraded state — Partial Operation."
durable_effect = "Exact failure-class recovery consequences: Retry Failed Items: No durable mutation occurs and no Receipt is created; Retry Failed Items is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Only part of the requested work completed; finished and pending results remain distinct. | Review Partial Import: No durable mutation occurs and no Receipt is created; Review Partial Import is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Only part of the requested work completed; finished and pending results remain distinct. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: Only part of the requested work completed; finished and pending results remain distinct."
recovery_rollback = "Exact classified recovery and rollback: Retry Failed Items: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. | Review Partial Import: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: Only part of the requested work completed; finished and pending results remain distinct."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: Only part of the requested work completed; finished and pending results remain distinct."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Retry Failed Items announces failure class and consequence; success focuses the updated classified status or first affected item after Retry Failed Items in Scoped degraded state — Partial Operation; rejection focuses the Retry Failed Items control and exact affected scope or failed identity in Scoped degraded state — Partial Operation | Review Partial Import announces failure class and consequence; success focuses the updated classified status or first affected item after Review Partial Import in Scoped degraded state — Partial Operation; rejection focuses the Review Partial Import control and exact affected scope or failed identity in Scoped degraded state — Partial Operation. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: Only part of the requested work completed; finished and pending results remain distinct."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-PARTIAL-OPERATION-001"
label = "Retry Failed Items"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the import source fingerprint and explicit completed, failed, and pending record identities"]
destination = "the owning import review with explicit failed identities from Scoped degraded state — Partial Operation"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-PARTIAL-OPERATION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Retry Failed Items is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Only part of the requested work completed; finished and pending results remain distinct."
success_focus = "the updated classified status or first affected item after Retry Failed Items in Scoped degraded state — Partial Operation"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-PARTIAL-OPERATION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Retry Failed Items control and exact affected scope or failed identity in Scoped degraded state — Partial Operation"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-PARTIAL-OPERATION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-PARTIAL-OPERATION-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-PARTIAL-OPERATION-002"
label = "Review Partial Import"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the import source fingerprint and explicit completed, failed, and pending record identities"]
destination = "the import owner’s completed, failed, and pending record review from Scoped degraded state — Partial Operation"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-PARTIAL-OPERATION-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Partial Import is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Only part of the requested work completed; finished and pending results remain distinct."
success_focus = "the updated classified status or first affected item after Review Partial Import in Scoped degraded state — Partial Operation"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-PARTIAL-OPERATION-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Partial Import control and exact affected scope or failed identity in Scoped degraded state — Partial Operation"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-PARTIAL-OPERATION-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-PARTIAL-OPERATION-002"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-PROTECTED-DATA-UNAVAILABLE"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Unlock and Retry => destination: the native device-protection result, then the exact protected operation from Scoped degraded state — Protected Data Unavailable; effect: The Unlock and Retry external result causes no local canonical mutation; native device protection reauthorizes access before the exact operation and current revision are revalidated. Rejection preserves protected local data unchanged. Visible evidence remains: Protected Data Unavailable — Protected local data is unavailable until device protection permits access.; focus: the updated classified status or first affected item after Unlock and Retry in Scoped degraded state — Protected Data Unavailable."
durable_effect = "Exact failure-class recovery consequences: Unlock and Retry: The Unlock and Retry external result causes no local canonical mutation; native device protection reauthorizes access before the exact operation and current revision are revalidated. Rejection preserves protected local data unchanged. Visible evidence remains: Protected Data Unavailable — Protected local data is unavailable until device protection permits access. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: Protected Data Unavailable — Protected local data is unavailable until device protection permits access."
recovery_rollback = "Exact classified recovery and rollback: Unlock and Retry: Cancellation or failed authentication changes nothing, reveals no protected content, and returns focus to Unlock and Retry. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: Protected Data Unavailable — Protected local data is unavailable until device protection permits access."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: Protected Data Unavailable — Protected local data is unavailable until device protection permits access."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Unlock and Retry announces failure class and consequence; success focuses the updated classified status or first affected item after Unlock and Retry in Scoped degraded state — Protected Data Unavailable; rejection focuses the Unlock and Retry control and exact affected scope or failed identity in Scoped degraded state — Protected Data Unavailable. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: Protected Data Unavailable — Protected local data is unavailable until device protection permits access."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-PROTECTED-DATA-UNAVAILABLE-001"
label = "Unlock and Retry"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the device-protection posture, protected scope, and unchanged last readable local state", "The user explicitly invokes the native device-protection challenge"]
destination = "the native device-protection result, then the exact protected operation from Scoped degraded state — Protected Data Unavailable"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-PROTECTED-DATA-UNAVAILABLE-001"
destination_posture = "current"
effect = "The Unlock and Retry external result causes no local canonical mutation; native device protection reauthorizes access before the exact operation and current revision are revalidated. Rejection preserves protected local data unchanged. Visible evidence remains: Protected Data Unavailable — Protected local data is unavailable until device protection permits access."
success_focus = "the updated classified status or first affected item after Unlock and Retry in Scoped degraded state — Protected Data Unavailable"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-PROTECTED-DATA-UNAVAILABLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Unlock and Retry control and exact affected scope or failed identity in Scoped degraded state — Protected Data Unavailable"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-PROTECTED-DATA-UNAVAILABLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: authentication itself is not canonical success; any later owner operation revalidates independently."
rollback_undo = "Cancellation or failed authentication changes nothing, reveals no protected content, and returns focus to Unlock and Retry."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-PROTECTED-DATA-UNAVAILABLE-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-STALE-EXTERNAL-SOURCE"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Refresh Source => destination: the source-owner freshness comparison from Scoped degraded state — Stale External Source; effect: The Refresh Source external result causes no local canonical mutation; it obtains a new source fingerprint for owner review while the last verified local facts remain usable. A changed source cannot silently overwrite local truth. Visible evidence remains: Stale External Source — An external source is stale while verified local facts remain usable.; focus: the updated classified status or first affected item after Refresh Source in Scoped degraded state — Stale External Source.\nReview Source => destination: the Trust source lineage and freshness inspection from Scoped degraded state — Stale External Source; effect: No durable mutation occurs and no Receipt is created; Review Source is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Stale External Source — An external source is stale while verified local facts remain usable.; focus: the updated classified status or first affected item after Review Source in Scoped degraded state — Stale External Source."
durable_effect = "Exact failure-class recovery consequences: Refresh Source: The Refresh Source external result causes no local canonical mutation; it obtains a new source fingerprint for owner review while the last verified local facts remain usable. A changed source cannot silently overwrite local truth. Visible evidence remains: Stale External Source — An external source is stale while verified local facts remain usable. | Review Source: No durable mutation occurs and no Receipt is created; Review Source is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Stale External Source — An external source is stale while verified local facts remain usable. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: Stale External Source — An external source is stale while verified local facts remain usable."
recovery_rollback = "Exact classified recovery and rollback: Refresh Source: Cancellation or source failure preserves the last verified local facts and stale marker; another refresh cannot replay an accepted local Event. | Review Source: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: Stale External Source — An external source is stale while verified local facts remain usable."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: Stale External Source — An external source is stale while verified local facts remain usable."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Refresh Source announces failure class and consequence; success focuses the updated classified status or first affected item after Refresh Source in Scoped degraded state — Stale External Source; rejection focuses the Refresh Source control and exact affected scope or failed identity in Scoped degraded state — Stale External Source | Review Source announces failure class and consequence; success focuses the updated classified status or first affected item after Review Source in Scoped degraded state — Stale External Source; rejection focuses the Review Source control and exact affected scope or failed identity in Scoped degraded state — Stale External Source. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: Stale External Source — An external source is stale while verified local facts remain usable."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-STALE-EXTERNAL-SOURCE-001"
label = "Refresh Source"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the external source identity, last verified fingerprint, freshness, and locally accepted facts", "The source adapter can re-read only minimum necessary facts without mutating canonical state"]
destination = "the source-owner freshness comparison from Scoped degraded state — Stale External Source"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-STALE-EXTERNAL-SOURCE-001"
destination_posture = "current"
effect = "The Refresh Source external result causes no local canonical mutation; it obtains a new source fingerprint for owner review while the last verified local facts remain usable. A changed source cannot silently overwrite local truth. Visible evidence remains: Stale External Source — An external source is stale while verified local facts remain usable."
success_focus = "the updated classified status or first affected item after Refresh Source in Scoped degraded state — Stale External Source"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-STALE-EXTERNAL-SOURCE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Refresh Source control and exact affected scope or failed identity in Scoped degraded state — Stale External Source"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-STALE-EXTERNAL-SOURCE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: source refresh produces external facts only; any later accepted local lineage or object change belongs to a separate owner command."
rollback_undo = "Cancellation or source failure preserves the last verified local facts and stale marker; another refresh cannot replay an accepted local Event."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-STALE-EXTERNAL-SOURCE-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-STALE-EXTERNAL-SOURCE-002"
label = "Review Source"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the external source identity, last verified fingerprint, freshness, and locally accepted facts"]
destination = "the Trust source lineage and freshness inspection from Scoped degraded state — Stale External Source"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-STALE-EXTERNAL-SOURCE-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Source is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Stale External Source — An external source is stale while verified local facts remain usable."
success_focus = "the updated classified status or first affected item after Review Source in Scoped degraded state — Stale External Source"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-STALE-EXTERNAL-SOURCE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Source control and exact affected scope or failed identity in Scoped degraded state — Stale External Source"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-STALE-EXTERNAL-SOURCE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-STALE-EXTERNAL-SOURCE-002"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-STORAGE-PRESSURE"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Export Data => destination: the dedicated reviewed export preview from Scoped degraded state — Storage Pressure; effect: No durable mutation occurs and no Receipt is created; Export Data is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Storage space is low enough to threaten new saves. Existing readable information remains unchanged.; focus: the updated classified status or first affected item after Export Data in Scoped degraded state — Storage Pressure.\nReview Storage => destination: You → Data & Storage with safe capacity options from Scoped degraded state — Storage Pressure; effect: No durable mutation occurs and no Receipt is created; Review Storage is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Storage space is low enough to threaten new saves. Existing readable information remains unchanged.; focus: the updated classified status or first affected item after Review Storage in Scoped degraded state — Storage Pressure."
durable_effect = "Exact failure-class recovery consequences: Export Data: No durable mutation occurs and no Receipt is created; Export Data is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Storage space is low enough to threaten new saves. Existing readable information remains unchanged. | Review Storage: No durable mutation occurs and no Receipt is created; Review Storage is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Storage space is low enough to threaten new saves. Existing readable information remains unchanged. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: Storage space is low enough to threaten new saves. Existing readable information remains unchanged."
recovery_rollback = "Exact classified recovery and rollback: Export Data: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. | Review Storage: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: Storage space is low enough to threaten new saves. Existing readable information remains unchanged."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: Storage space is low enough to threaten new saves. Existing readable information remains unchanged."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Export Data announces failure class and consequence; success focuses the updated classified status or first affected item after Export Data in Scoped degraded state — Storage Pressure; rejection focuses the Export Data control and exact affected scope or failed identity in Scoped degraded state — Storage Pressure | Review Storage announces failure class and consequence; success focuses the updated classified status or first affected item after Review Storage in Scoped degraded state — Storage Pressure; rejection focuses the Review Storage control and exact affected scope or failed identity in Scoped degraded state — Storage Pressure. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: Storage space is low enough to threaten new saves. Existing readable information remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-STORAGE-PRESSURE-001"
label = "Export Data"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the current storage threshold, readable local scope, and safe export eligibility"]
destination = "the dedicated reviewed export preview from Scoped degraded state — Storage Pressure"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-STORAGE-PRESSURE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Export Data is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Storage space is low enough to threaten new saves. Existing readable information remains unchanged."
success_focus = "the updated classified status or first affected item after Export Data in Scoped degraded state — Storage Pressure"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-STORAGE-PRESSURE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Export Data control and exact affected scope or failed identity in Scoped degraded state — Storage Pressure"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-STORAGE-PRESSURE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-STORAGE-PRESSURE-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-STORAGE-PRESSURE-002"
label = "Review Storage"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the current storage threshold, readable local scope, and safe export eligibility"]
destination = "You → Data & Storage with safe capacity options from Scoped degraded state — Storage Pressure"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-STORAGE-PRESSURE-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Storage is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Storage space is low enough to threaten new saves. Existing readable information remains unchanged."
success_focus = "the updated classified status or first affected item after Review Storage in Scoped degraded state — Storage Pressure"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-STORAGE-PRESSURE-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Storage control and exact affected scope or failed identity in Scoped degraded state — Storage Pressure"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-STORAGE-PRESSURE-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-STORAGE-PRESSURE-002"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-UNAVAILABLE-PERMISSION"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Settings => destination: the relevant Ambitions permission control in iOS Settings from Scoped degraded state — Unavailable Permission; effect: The Open Settings external result causes no local canonical mutation; system authorization remains externally owned and foreground return must re-read the actual status. Unaffected local work remains usable. Visible evidence remains: A permission is unavailable; unaffected local work remains usable.; focus: the updated classified status or first affected item after Open Settings in Scoped degraded state — Unavailable Permission.\nReview Access => destination: the contextual permission status and local fallback from Scoped degraded state — Unavailable Permission; effect: No durable mutation occurs and no Receipt is created; Review Access is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: A permission is unavailable; unaffected local work remains usable.; focus: the updated classified status or first affected item after Review Access in Scoped degraded state — Unavailable Permission."
durable_effect = "Exact failure-class recovery consequences: Open Settings: The Open Settings external result causes no local canonical mutation; system authorization remains externally owned and foreground return must re-read the actual status. Unaffected local work remains usable. Visible evidence remains: A permission is unavailable; unaffected local work remains usable. | Review Access: No durable mutation occurs and no Receipt is created; Review Access is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: A permission is unavailable; unaffected local work remains usable. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: A permission is unavailable; unaffected local work remains usable."
recovery_rollback = "Exact classified recovery and rollback: Open Settings: Cancellation or unchanged permission preserves the prior status and local data; no repeated prompt is triggered automatically. | Review Access: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: A permission is unavailable; unaffected local work remains usable."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: A permission is unavailable; unaffected local work remains usable."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Open Settings announces failure class and consequence; success focuses the updated classified status or first affected item after Open Settings in Scoped degraded state — Unavailable Permission; rejection focuses the Open Settings control and exact affected scope or failed identity in Scoped degraded state — Unavailable Permission | Review Access announces failure class and consequence; success focuses the updated classified status or first affected item after Review Access in Scoped degraded state — Unavailable Permission; rejection focuses the Review Access control and exact affected scope or failed identity in Scoped degraded state — Unavailable Permission. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: A permission is unavailable; unaffected local work remains usable."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-UNAVAILABLE-PERMISSION-001"
label = "Open Settings"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the current system authorization, prior known status, and unaffected local capability"]
destination = "the relevant Ambitions permission control in iOS Settings from Scoped degraded state — Unavailable Permission"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-UNAVAILABLE-PERMISSION-001"
destination_posture = "current"
effect = "The Open Settings external result causes no local canonical mutation; system authorization remains externally owned and foreground return must re-read the actual status. Unaffected local work remains usable. Visible evidence remains: A permission is unavailable; unaffected local work remains usable."
success_focus = "the updated classified status or first affected item after Open Settings in Scoped degraded state — Unavailable Permission"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-UNAVAILABLE-PERMISSION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open Settings control and exact affected scope or failed identity in Scoped degraded state — Unavailable Permission"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-UNAVAILABLE-PERMISSION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: Settings owns authorization; return reconciliation is separate and cannot infer consent or replay a rejected action."
rollback_undo = "Cancellation or unchanged permission preserves the prior status and local data; no repeated prompt is triggered automatically."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-UNAVAILABLE-PERMISSION-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-LOCAL-HEALTH-UNAVAILABLE-PERMISSION-002"
label = "Review Access"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the current system authorization, prior known status, and unaffected local capability"]
destination = "the contextual permission status and local fallback from Scoped degraded state — Unavailable Permission"
destination_id = "DEST-OFFLINE-DEGRADED-LOCAL-HEALTH-UNAVAILABLE-PERMISSION-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Access is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: A permission is unavailable; unaffected local work remains usable."
success_focus = "the updated classified status or first affected item after Review Access in Scoped degraded state — Unavailable Permission"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-UNAVAILABLE-PERMISSION-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Access control and exact affected scope or failed identity in Scoped degraded state — Unavailable Permission"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-LOCAL-HEALTH-UNAVAILABLE-PERMISSION-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-LOCAL-HEALTH-UNAVAILABLE-PERMISSION-002"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-REPAIR-EXPORT-ONLY"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Export Data => destination: the dedicated reviewed export preview from Recovery and repair — Export Only; effect: No durable mutation occurs and no Receipt is created; Export Data is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Automatic repair is unsafe. Saved information remains unchanged, and the affected scope is available as a redacted record.; focus: the updated classified status or first affected item after Export Data in Recovery and repair — Export Only."
durable_effect = "Exact failure-class recovery consequences: Export Data: No durable mutation occurs and no Receipt is created; Export Data is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Automatic repair is unsafe. Saved information remains unchanged, and the affected scope is available as a redacted record. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: Automatic repair is unsafe. Saved information remains unchanged, and the affected scope is available as a redacted record."
recovery_rollback = "Exact classified recovery and rollback: Export Data: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: Automatic repair is unsafe. Saved information remains unchanged, and the affected scope is available as a redacted record."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: Automatic repair is unsafe. Saved information remains unchanged, and the affected scope is available as a redacted record."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Export Data announces failure class and consequence; success focuses the updated classified status or first affected item after Export Data in Recovery and repair — Export Only; rejection focuses the Export Data control and exact affected scope or failed identity in Recovery and repair — Export Only. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: Automatic repair is unsafe. Saved information remains unchanged, and the affected scope is available as a redacted record."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-REPAIR-EXPORT-ONLY-001"
label = "Export Data"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the affected local-store scope, verified snapshot, quarantine identity, and repair evidence"]
destination = "the dedicated reviewed export preview from Recovery and repair — Export Only"
destination_id = "DEST-OFFLINE-DEGRADED-REPAIR-EXPORT-ONLY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Export Data is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Automatic repair is unsafe. Saved information remains unchanged, and the affected scope is available as a redacted record."
success_focus = "the updated classified status or first affected item after Export Data in Recovery and repair — Export Only"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-REPAIR-EXPORT-ONLY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Export Data control and exact affected scope or failed identity in Recovery and repair — Export Only"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-REPAIR-EXPORT-ONLY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-REPAIR-EXPORT-ONLY-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-REPAIR-QUARANTINE-INSPECTION"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Details => destination: the affected-scope status and consequence details from Recovery and repair — Quarantine Inspection; effect: No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Protected information is isolated. Saved information outside the affected area remains unchanged.; focus: the updated classified status or first affected item after Review Details in Recovery and repair — Quarantine Inspection."
durable_effect = "Exact failure-class recovery consequences: Review Details: No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Protected information is isolated. Saved information outside the affected area remains unchanged. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: Protected information is isolated. Saved information outside the affected area remains unchanged."
recovery_rollback = "Exact classified recovery and rollback: Review Details: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: Protected information is isolated. Saved information outside the affected area remains unchanged."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: Protected information is isolated. Saved information outside the affected area remains unchanged."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Review Details announces failure class and consequence; success focuses the updated classified status or first affected item after Review Details in Recovery and repair — Quarantine Inspection; rejection focuses the Review Details control and exact affected scope or failed identity in Recovery and repair — Quarantine Inspection. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: Protected information is isolated. Saved information outside the affected area remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-REPAIR-QUARANTINE-INSPECTION-001"
label = "Review Details"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the affected local-store scope, verified snapshot, quarantine identity, and repair evidence"]
destination = "the affected-scope status and consequence details from Recovery and repair — Quarantine Inspection"
destination_id = "DEST-OFFLINE-DEGRADED-REPAIR-QUARANTINE-INSPECTION-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Protected information is isolated. Saved information outside the affected area remains unchanged."
success_focus = "the updated classified status or first affected item after Review Details in Recovery and repair — Quarantine Inspection"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-REPAIR-QUARANTINE-INSPECTION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Details control and exact affected scope or failed identity in Recovery and repair — Quarantine Inspection"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-REPAIR-QUARANTINE-INSPECTION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-REPAIR-QUARANTINE-INSPECTION-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-REPAIR-REPAIR-AVAILABLE"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Details => destination: the affected-scope status and consequence details from Recovery and repair — Repair Available; effect: No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: A limited data issue is isolated within a verified snapshot. The last valid saved copy remains protected.; focus: the updated classified status or first affected item after Review Details in Recovery and repair — Repair Available."
durable_effect = "Exact failure-class recovery consequences: Review Details: No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: A limited data issue is isolated within a verified snapshot. The last valid saved copy remains protected. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: A limited data issue is isolated within a verified snapshot. The last valid saved copy remains protected."
recovery_rollback = "Exact classified recovery and rollback: Review Details: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: A limited data issue is isolated within a verified snapshot. The last valid saved copy remains protected."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: A limited data issue is isolated within a verified snapshot. The last valid saved copy remains protected."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Review Details announces failure class and consequence; success focuses the updated classified status or first affected item after Review Details in Recovery and repair — Repair Available; rejection focuses the Review Details control and exact affected scope or failed identity in Recovery and repair — Repair Available. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: A limited data issue is isolated within a verified snapshot. The last valid saved copy remains protected."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-REPAIR-REPAIR-AVAILABLE-001"
label = "Review Details"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the affected local-store scope, verified snapshot, quarantine identity, and repair evidence"]
destination = "the affected-scope status and consequence details from Recovery and repair — Repair Available"
destination_id = "DEST-OFFLINE-DEGRADED-REPAIR-REPAIR-AVAILABLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: A limited data issue is isolated within a verified snapshot. The last valid saved copy remains protected."
success_focus = "the updated classified status or first affected item after Review Details in Recovery and repair — Repair Available"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-REPAIR-REPAIR-AVAILABLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Details control and exact affected scope or failed identity in Recovery and repair — Repair Available"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-REPAIR-REPAIR-AVAILABLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-REPAIR-REPAIR-AVAILABLE-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-REPAIR-REPAIR-COMPLETE"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Details => destination: the affected-scope status and consequence details from Recovery and repair — Repair Complete; effect: No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Repair Complete — Repair completed and the receipt names corrected and unchanged data.; focus: the updated classified status or first affected item after Review Details in Recovery and repair — Repair Complete."
durable_effect = "Exact failure-class recovery consequences: Review Details: No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Repair Complete — Repair completed and the receipt names corrected and unchanged data. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: Repair Complete — Repair completed and the receipt names corrected and unchanged data."
recovery_rollback = "Exact classified recovery and rollback: Review Details: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: Repair Complete — Repair completed and the receipt names corrected and unchanged data."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: Repair Complete — Repair completed and the receipt names corrected and unchanged data."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Review Details announces failure class and consequence; success focuses the updated classified status or first affected item after Review Details in Recovery and repair — Repair Complete; rejection focuses the Review Details control and exact affected scope or failed identity in Recovery and repair — Repair Complete. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: Repair Complete — Repair completed and the receipt names corrected and unchanged data."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-REPAIR-REPAIR-COMPLETE-001"
label = "Review Details"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the affected local-store scope, verified snapshot, quarantine identity, and repair evidence"]
destination = "the affected-scope status and consequence details from Recovery and repair — Repair Complete"
destination_id = "DEST-OFFLINE-DEGRADED-REPAIR-REPAIR-COMPLETE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Repair Complete — Repair completed and the receipt names corrected and unchanged data."
success_focus = "the updated classified status or first affected item after Review Details in Recovery and repair — Repair Complete"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-REPAIR-REPAIR-COMPLETE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Details control and exact affected scope or failed identity in Recovery and repair — Repair Complete"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-REPAIR-REPAIR-COMPLETE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-REPAIR-REPAIR-COMPLETE-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-REPAIR-REPAIR-FAILED"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Open Diagnostics => destination: the redacted local Diagnostics inspection from Recovery and repair — Repair Failed; effect: No durable mutation occurs and no Receipt is created; Open Diagnostics is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Repair Failed — Repair failed without replacing the last valid local snapshot.; focus: the updated classified status or first affected item after Open Diagnostics in Recovery and repair — Repair Failed."
durable_effect = "Exact failure-class recovery consequences: Open Diagnostics: No durable mutation occurs and no Receipt is created; Open Diagnostics is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Repair Failed — Repair failed without replacing the last valid local snapshot. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: Repair Failed — Repair failed without replacing the last valid local snapshot."
recovery_rollback = "Exact classified recovery and rollback: Open Diagnostics: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: Repair Failed — Repair failed without replacing the last valid local snapshot."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: Repair Failed — Repair failed without replacing the last valid local snapshot."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Open Diagnostics announces failure class and consequence; success focuses the updated classified status or first affected item after Open Diagnostics in Recovery and repair — Repair Failed; rejection focuses the Open Diagnostics control and exact affected scope or failed identity in Recovery and repair — Repair Failed. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: Repair Failed — Repair failed without replacing the last valid local snapshot."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-REPAIR-REPAIR-FAILED-001"
label = "Open Diagnostics"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the affected local-store scope, verified snapshot, quarantine identity, and repair evidence"]
destination = "the redacted local Diagnostics inspection from Recovery and repair — Repair Failed"
destination_id = "DEST-OFFLINE-DEGRADED-REPAIR-REPAIR-FAILED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Open Diagnostics is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: Repair Failed — Repair failed without replacing the last valid local snapshot."
success_focus = "the updated classified status or first affected item after Open Diagnostics in Recovery and repair — Repair Failed"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-REPAIR-REPAIR-FAILED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Open Diagnostics control and exact affected scope or failed identity in Recovery and repair — Repair Failed"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-REPAIR-REPAIR-FAILED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-REPAIR-REPAIR-FAILED-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-OFFLINE-DEGRADED-REPAIR-REPAIR-RUNNING"
requirement_id = "APP-DEGRADED-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Details => destination: the affected-scope status and consequence details from Recovery and repair — Repair Running; effect: No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: A limited repair is in progress against a verified snapshot. The last valid saved copy remains protected.; focus: the updated classified status or first affected item after Review Details in Recovery and repair — Repair Running."
durable_effect = "Exact failure-class recovery consequences: Review Details: No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: A limited repair is in progress against a verified snapshot. The last valid saved copy remains protected. Existing local truth and accepted input remain available wherever safe; Offline Healthy exposes review only and no repair prompt. Current visible status: A limited repair is in progress against a verified snapshot. The last valid saved copy remains protected."
recovery_rollback = "Exact classified recovery and rollback: Review Details: No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged. No inline destructive reset exists. Reset routes only through You → Data & Storage → Review Reset with exact scope, irreversibility, verified export or backup when feasible, explicit confirmation, and a rollback reference. Recovery preserves: A limited repair is in progress against a verified snapshot. The last valid saved copy remains protected."
offline_behavior = "Readable Goals, Captures, Time, settings, accepted input, completed results, snapshots, History, and Receipts remain available offline wherever safe. Network and external operations wait without weakening local truth. Offline evidence remains: A limited repair is in progress against a verified snapshot. The last valid saved copy remains protected."
accessibility_focus = "VoiceOver announces failure class, affected scope, local consequence, safe recovery, and unchanged data before controls: Review Details announces failure class and consequence; success focuses the updated classified status or first affected item after Review Details in Recovery and repair — Repair Running; rejection focuses the Review Details control and exact affected scope or failed identity in Recovery and repair — Repair Running. Dynamic Type stacks status and actions without color dependence. The announcement first communicates: A limited repair is in progress against a verified snapshot. The last valid saved copy remains protected."

[[state_command_contracts.commands]]
command_id = "CMD-OFFLINE-DEGRADED-REPAIR-REPAIR-RUNNING-001"
label = "Review Details"
canonical_owner = "app.degraded.command-contract"
preconditions = ["The command is allowlisted for this exact failure class and preserves accepted local input and truth", "The current failure classification revalidates the affected local-store scope, verified snapshot, quarantine identity, and repair evidence"]
destination = "the affected-scope status and consequence details from Recovery and repair — Repair Running"
destination_id = "DEST-OFFLINE-DEGRADED-REPAIR-REPAIR-RUNNING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Details is inspection, preview, or a handoff to the dedicated owner. It performs no inline repair, retry commit, export creation, destructive reset, source overwrite, or continuity operation. Visible evidence remains: A limited repair is in progress against a verified snapshot. The last valid saved copy remains protected."
success_focus = "the updated classified status or first affected item after Review Details in Recovery and repair — Repair Running"
success_focus_id = "FOCUS-OFFLINE-DEGRADED-REPAIR-REPAIR-RUNNING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Details control and exact affected scope or failed identity in Recovery and repair — Repair Running"
failure_focus_id = "FOCUS-OFFLINE-DEGRADED-REPAIR-REPAIR-RUNNING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: classified recovery review and owner handoff remain before any dedicated canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to the classified state with accepted local truth, input, snapshots, and explicit failed identities unchanged."
recovery_id = "RECOVERY-OFFLINE-DEGRADED-REPAIR-REPAIR-RUNNING-001"
recovery_posture = "current"
recovery_owner = "app.degraded.command-contract"
privacy_egress = "Degraded presentation remains local and reveals only the affected scope and safe consequence; external retry, source refresh, Settings, export, and diagnostics use their dedicated privacy boundaries."
verification_ids = ["SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

+++

# App Degraded States

This shadow specification defines a shared classification and presentation contract for whole-app degradation. Owning features retain their specific failure semantics.

## APP-DEGRADED-FAILURE-TAXONOMY-001 — Failures keep distinct user consequences

- **Concept:** `app.degraded.failure-taxonomy`
- **Modality:** `MUST`
- **Scope:** App-visible availability, freshness, continuity, external integration, local storage, and partial-operation failures
- **Status:** `normative`
- **Verification:** `AUDIT-APP-DEGRADED-TAXONOMY-001`, `SCENARIO-APP-DEGRADED-CLASSIFY-001`
- **Supersedes:** none

App-visible failure handling MUST distinguish at least: offline but locally healthy, stale external source, continuity pending, continuity conflict, import failure, external-write failure, local-store degradation, partial operation, and unavailable permission. These classes cannot collapse into a generic error because they differ in canonical-state safety, what remains usable, whether retry is safe, and what recovery the user controls.

No class implies that optional CloudKit continuity, account, R2, Source Atlas, external import, or side-effect behavior is enabled or proven. Feature specifications may add narrower subclasses without redefining these shared consequences.

## APP-DEGRADED-PRESENTATION-001 — Degradation is calm, scoped, and actionable

- **Concept:** `app.degraded.presentation`
- **Modality:** `MUST`
- **Scope:** Inline, object-detail, surface, and launch-level degraded presentation
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEGRADED-PRESENTATION-001`, `PROOF-APP-DEGRADED-A11Y-001`
- **Supersedes:** none

A degraded presentation MUST state what is affected, what remains available, whether displayed information is current, and the safest next action. It appears at the narrowest level that explains the consequence and does not turn private status, diagnostics, or architecture vocabulary into ambient root chrome. Color, motion, or spatial position may not be the sole carrier of severity or recovery state.

The app MUST NOT show a persistent offline warning when the requested action is fully available locally.

## APP-DEGRADED-PRESERVE-001 — Failure preserves accepted input and local truth

- **Concept:** `app.degraded.input-preservation`
- **Modality:** `MUST`
- **Scope:** Drafts, accepted mutations, local canonical objects, pending external effects, and partial results
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEGRADED-PRESERVE-001`, `PROOF-APP-DEGRADED-NO-DATA-LOSS-001`
- **Supersedes:** none

Failure MUST preserve original input, accepted local intent, canonical object identity, and truthful pending or failed external-effect state. An external, permission, network, import, projection, or presentation failure cannot erase a durable local acceptance or relabel it as fully succeeded. Partial results remain identifiable and safe to retry, reconcile, quarantine, export, undo, or repair according to the owning contract.

## APP-DEGRADED-RECOVERY-001 — Recovery is class-specific and reversible

- **Concept:** `app.degraded.recovery`
- **Modality:** `MUST`
- **Scope:** Retry, reconciliation, conflict review, quarantine, export, rollback, repair preview, and destructive reset
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEGRADED-RECOVERY-001`, `SCENARIO-APP-DEGRADED-RETRY-IDEMPOTENCY-001`
- **Supersedes:** none

Recovery MUST match the failure class and current canonical state. Retry revalidates preconditions and is idempotent. Conflicts require human-meaningful review; quarantine isolates suspect data without silently deleting it; repair previews consequences before commit; export preserves user agency where feasible. Destructive reset is a separately confirmed last resort and cannot be presented as routine recovery for an unclassified failure.

Controls MUST NOT report success before durable mutation.

## APP-DEGRADED-STATE-001 — Degraded state retains scope and freshness

- **Concept:** `app.degraded.state`
- **Modality:** `MUST`
- **Scope:** Shared degraded-state representation and transition
- **Status:** `normative`
- **Verification:** `AUDIT-APP-DEGRADED-STATE-001`, `SCENARIO-APP-DEGRADED-RESTORE-001`
- **Supersedes:** none

Each degraded state MUST carry the affected capability or object scope, failure class, local-authority health, freshness, retry safety, available recovery actions, and whether user attention is required. Resolution clears only the affected degraded state after current facts are re-read; it does not discard unresolved history, receipt, conflict, or repair evidence.

## APP-DEGRADED-COMMAND-CONTRACT-001 — Degraded commands match classified failure consequences

- **Concept:** `app.degraded.command-contract`
- **Modality:** `MUST`
- **Scope:** Offline health, stale sources, continuity, external writes, imports, permissions, protected data, storage, local-store degradation, repair handoff, focus, offline preservation, and reset routing
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEGRADED-COMMAND-CONTRACT-001`
- **Supersedes:** none

Degraded presentation MUST expose only recovery appropriate to the classified failure:

- Offline but locally healthy → optional `Review Details`; no repair prompt.
- Stale external source → `Refresh Source`, `Review Source`.
- Continuity pending/conflict → future-gated `Review Continuity Status` or `Review Conflict`.
- External-write failure → `Retry External Update`, `Review Details`.
- Import failure/partial import → `Review Partial Import`, `Retry Failed Items`.
- Permission unavailable → `Review Access`, `Open Settings`.
- Protected data unavailable → `Unlock and Retry`.
- Storage pressure → `Review Storage`, `Export Data` when safe.
- Local-store degradation → `Open Diagnostics`.
- Unknown health → `Open Diagnostics`; no blind retry.

No inline degraded state may perform destructive reset. Reset MUST route through `You → Data & Storage → Review Reset`, disclose exact scope and irreversibility, offer verified export/backup when feasible, require confirmation, and preserve a rollback reference. Export, quarantine, repair, and reset remain owned by their dedicated systems.


Entry focuses affected scope and consequence. Recovery focuses the updated status or first failed item. Existing local truth and accepted input remain available wherever safe.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
This system owns shared failure classes, cross-app degraded presentation rules, input-preservation invariants, and recovery vocabulary. It does not own feature-specific failures, persistence repair algorithms, continuity enablement, permission policy, or a generic central error store that replaces owning state.

<!-- canon-section: inputs-outputs -->
Inputs are owning-system failure facts, affected scope, local-authority health, freshness, accepted-input state, partial results, retry safety, and recovery capabilities. Outputs are a classified degraded state, scoped presentation model, allowed recovery actions, and resolution/reconciliation request.

<!-- canon-section: authority-boundary -->
Owning systems remain authoritative for facts and recovery execution. This shared contract composes their user consequences and cannot mutate canonical data, override privacy/control law, or turn diagnostics into product policy.

<!-- canon-section: data-classification -->
Degraded state uses minimum necessary local metadata. User-visible and diagnostic representations redact private titles, proof, notes, attachments, schedules, and inferred context unless the owning object view explicitly requires that content to explain a direct consequence.

<!-- canon-section: state-model -->
The degraded record uses explicit fields for scope, health, freshness, operation, and recovery.

State records failure class, scope, local health, freshness, operation phase, retry safety, user-attention need, recovery set, and resolution status. Offline-healthy is distinct from stale, pending, conflicted, failed, partial, unavailable, quarantined, and local-store degraded.

<!-- canon-section: failure-recovery -->
Every classified failure exposes only recovery actions valid for its current facts.

Unknown failures fail closed to input preservation and non-destructive inspection. Classified failures offer only recovery valid for current state. Repeated failure remains visible with escalation to export, quarantine, diagnostics, or repair rather than endless retry.

<!-- canon-section: local-network-boundary -->
Offline-healthy local behavior remains usable and is not displayed as product failure. Recovery requiring an optional external service waits without blocking unrelated local core behavior or changing local authority.

<!-- canon-section: determinism -->
The same owning facts produce the same failure class, presentation scope, and allowed recovery set. Severity is based on user consequence and data safety, not arbitrary source names or transient error strings.

<!-- canon-section: observability -->
Redacted evidence identifies the failure class, affected scope, and recovery result.

Evidence records class, scope, local health, freshness, operation phase, preserved-input status, retry count/result, recovery chosen, and resolution with private content redacted. Evidence age and source revision remain explicit.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Core/LocalRuntimeOS/Repair/` and `Core/LocalRuntimeOS/Diagnostics/` own repair and health facts; `DesignSystem/` owns shared degraded-state product components; each owning root under `Surfaces/Today/`, `Goals/`, `Time/`, or `You/` owns contextual placement; app `Diagnostics/` owns redacted diagnostic presentation; and `Quality/` owns scenario and accessibility proof. A source repair must move or collapse their authority into the exact owners above.

<!-- canon-section: tests-proof -->
The scenario matrix executes every shared failure class and recovery outcome.

Required proof exercises every taxonomy class, unknown failure, offline-healthy operation, stale data, partial results, idempotent retry, conflict review, quarantine, repair preview, preserved drafts/local objects, redaction, VoiceOver semantics/actions, Dynamic Type, Reduce Motion, contrast, and focus recovery.

<!-- canon-section: performance-resource-constraints -->
With 100 simultaneous health signals across 25 affected scopes, classification MUST complete within 10 ms at P95 and shared presentation-model derivation within 16 ms at P95 across 1,000 evaluations. The active degraded-state queue MUST cap at 128 records and coalesce repeated facts by scope; each redacted diagnostic record MUST remain at or below 4 KiB. One thousand retained records MUST add no more than 4 MiB resident memory. Classification performs zero synchronous disk or network I/O. Automatic retry is capped at 3 attempts per operation with delays of at least 1, 5, and 30 seconds; further action requires user intent or an owning repair contract. No degraded-state classifier may poll or run an unbounded background loop.
