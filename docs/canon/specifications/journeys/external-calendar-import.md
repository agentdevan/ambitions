+++
spec_id = "JOURNEY-EXTERNAL-CALENDAR-IMPORT"
title = "External Calendar Import"
kind = "journey"
status = "normative"
owner_domain = "journey-external-calendar-import"
canon_revision = 1
profile = "journey-v1"
owns_concepts = [
  "journey.calendar-diff.conflict-choice",
  "journey.calendar-diff.grouping",
  "journey.calendar-diff.no-silent-mutation",
  "journey.calendar-diff.notification-handoff",
  "journey.calendar-import.candidate",
  "journey.calendar-import.command-contract",
  "journey.calendar-import.commit",
  "journey.calendar-invite-diff",
]
inherits = ["TIME-EXTERNAL-VISIBILITY-001", "CONTROL-MATERIAL-CONFIRMATION-001", "LAW-RUNTIME-NO-DIRECT-WRITE-001", "LAW-RUNTIME-DURABLE-SUCCESS-001"]
depends_on = ["CONSTITUTION", "APP-PERMISSIONS", "SURFACE-TIME", "OBJECT-IMPORT-DIFF-RECORD", "OBJECT-EVENT", "OBJECT-SOURCE-REFERENCE", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Surfaces/Time/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Trust/", "Native/Ambitions/Quality/"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-IMPORT-COMMITTING-IMPORT"
requirement_id = "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the Time import origin or durable result summary from External calendar review — Committing Import; effect: No durable mutation occurs and no Receipt is created; Done dismisses only the current progress or result presentation. Completed and failed record IDs, source lineage, Receipts, and external-source status remain available. Visible evidence remains: Creating the selected Ambitions-native copies. The external source is not being edited.; focus: the first affected record or Done result heading in External calendar review — Committing Import."
durable_effect = "Exact import consequences across reviewed groups [Needs attention; Safe to import; Duplicate or link candidates; Removed source; Ignored history]: Done: No durable mutation occurs and no Receipt is created; Done dismisses only the current progress or result presentation. Completed and failed record IDs, source lineage, Receipts, and external-source status remain available. Visible evidence remains: Creating the selected Ambitions-native copies. The external source is not being edited. Outcomes preserve native-object, capacity, lineage, badge, notification, and external effects separately. Current visible status: Creating the selected Ambitions-native copies. The external source is not being edited."
recovery_rollback = "Exact atomic partial, failed-ID retry, semantic Undo, and external-write recovery: Done: No Undo is required; reopening Time import restores the durable completed/failed identities, Receipt, and safe recovery route. Completed and failed identities remain explicit, and a changed source fingerprint invalidates confirmation. Recovery preserves: Creating the selected Ambitions-native copies. The external source is not being edited."
offline_behavior = "Stored Import/Diff Records, exact groups, selection, reviewed outcomes, lineage, completed/failed IDs, Receipts, and recovery remain usable offline. New source reads and external writes wait without changing accepted local truth. Offline evidence remains: Creating the selected Ambitions-native copies. The external source is not being edited."
accessibility_focus = "VoiceOver names group, source summary, prior/new values, outcome, native-object and capacity consequence, external effect, and recovery without color dependence: Done announces the exact record consequence; success focuses the first affected record or Done result heading in External calendar review — Committing Import; rejection focuses the Done control and first stale, invalid, or failed record in External calendar review — Committing Import. Dynamic Type stacks every diff and consequence. The announcement first communicates: Creating the selected Ambitions-native copies. The external source is not being edited."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-COMMITTING-IMPORT-001"
label = "Done"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Permission and minimum necessary source access remain valid for the attempted import", "The presented source identity, source fingerprint, diff revision, and local revision have been revalidated"]
destination = "the Time import origin or durable result summary from External calendar review — Committing Import"
destination_id = "DEST-TIME-IMPORT-COMMITTING-IMPORT-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done dismisses only the current progress or result presentation. Completed and failed record IDs, source lineage, Receipts, and external-source status remain available. Visible evidence remains: Creating the selected Ambitions-native copies. The external source is not being edited."
success_focus = "the first affected record or Done result heading in External calendar review — Committing Import"
success_focus_id = "FOCUS-TIME-IMPORT-COMMITTING-IMPORT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and first stale, invalid, or failed record in External calendar review — Committing Import"
failure_focus_id = "FOCUS-TIME-IMPORT-COMMITTING-IMPORT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: dismissal completes without changing selection, import outcomes, lineage, or external source."
rollback_undo = "No Undo is required; reopening Time import restores the durable completed/failed identities, Receipt, and safe recovery route."
recovery_id = "RECOVERY-TIME-IMPORT-COMMITTING-IMPORT-001"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Review uses minimum necessary stored source facts; selection and preview never alter the source, and any explicit external write sends only approved event fields with a separate egress Receipt."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-IMPORT-EXTERNAL-SOURCE-UNCHANGED"
requirement_id = "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the Time import origin or durable result summary from External calendar review — External Source Unchanged; effect: No durable mutation occurs and no Receipt is created; Done dismisses only the current progress or result presentation. Completed and failed record IDs, source lineage, Receipts, and external-source status remain available. Visible evidence remains: Import complete. The external source remains unchanged; Ambitions created separate native copies only.; focus: the first affected record or Done result heading in External calendar review — External Source Unchanged."
durable_effect = "Exact import consequences across reviewed groups [Needs attention; Safe to import; Duplicate or link candidates; Removed source; Ignored history]: Done: No durable mutation occurs and no Receipt is created; Done dismisses only the current progress or result presentation. Completed and failed record IDs, source lineage, Receipts, and external-source status remain available. Visible evidence remains: Import complete. The external source remains unchanged; Ambitions created separate native copies only. Outcomes preserve native-object, capacity, lineage, badge, notification, and external effects separately. Current visible status: Import complete. The external source remains unchanged; Ambitions created separate native copies only."
recovery_rollback = "Exact atomic partial, failed-ID retry, semantic Undo, and external-write recovery: Done: No Undo is required; reopening Time import restores the durable completed/failed identities, Receipt, and safe recovery route. Completed and failed identities remain explicit, and a changed source fingerprint invalidates confirmation. Recovery preserves: Import complete. The external source remains unchanged; Ambitions created separate native copies only."
offline_behavior = "Stored Import/Diff Records, exact groups, selection, reviewed outcomes, lineage, completed/failed IDs, Receipts, and recovery remain usable offline. New source reads and external writes wait without changing accepted local truth. Offline evidence remains: Import complete. The external source remains unchanged; Ambitions created separate native copies only."
accessibility_focus = "VoiceOver names group, source summary, prior/new values, outcome, native-object and capacity consequence, external effect, and recovery without color dependence: Done announces the exact record consequence; success focuses the first affected record or Done result heading in External calendar review — External Source Unchanged; rejection focuses the Done control and first stale, invalid, or failed record in External calendar review — External Source Unchanged. Dynamic Type stacks every diff and consequence. The announcement first communicates: Import complete. The external source remains unchanged; Ambitions created separate native copies only."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-EXTERNAL-SOURCE-UNCHANGED-001"
label = "Done"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Permission and minimum necessary source access remain valid for the attempted import", "The presented source identity, source fingerprint, diff revision, and local revision have been revalidated"]
destination = "the Time import origin or durable result summary from External calendar review — External Source Unchanged"
destination_id = "DEST-TIME-IMPORT-EXTERNAL-SOURCE-UNCHANGED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done dismisses only the current progress or result presentation. Completed and failed record IDs, source lineage, Receipts, and external-source status remain available. Visible evidence remains: Import complete. The external source remains unchanged; Ambitions created separate native copies only."
success_focus = "the first affected record or Done result heading in External calendar review — External Source Unchanged"
success_focus_id = "FOCUS-TIME-IMPORT-EXTERNAL-SOURCE-UNCHANGED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and first stale, invalid, or failed record in External calendar review — External Source Unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-EXTERNAL-SOURCE-UNCHANGED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: dismissal completes without changing selection, import outcomes, lineage, or external source."
rollback_undo = "No Undo is required; reopening Time import restores the durable completed/failed identities, Receipt, and safe recovery route."
recovery_id = "RECOVERY-TIME-IMPORT-EXTERNAL-SOURCE-UNCHANGED-001"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Review uses minimum necessary stored source facts; selection and preview never alter the source, and any explicit external write sends only approved event fields with a separate egress Receipt."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-IMPORT-EXTERNAL-WRITE-FAILURE"
requirement_id = "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Retry Failed Items => destination: the external-write reconciliation result for only the failed identities from External calendar review — External Write Failure; effect: The Retry Failed Items external result causes no local canonical mutation; it retries only explicitly failed external-dispatch identities after revalidating source and local freshness, cannot replay completed local imports, and records the separate external result and egress Receipt. Accepted Ambitions-owned copies remain unchanged. Visible evidence remains: An outside calendar update failed; the Ambitions-owned copy remains unchanged.; focus: the first affected record or Retry Failed Items result heading in External calendar review — External Write Failure."
durable_effect = "Exact import consequences across reviewed groups [Needs attention; Safe to import; Duplicate or link candidates; Removed source; Ignored history]: Retry Failed Items: The Retry Failed Items external result causes no local canonical mutation; it retries only explicitly failed external-dispatch identities after revalidating source and local freshness, cannot replay completed local imports, and records the separate external result and egress Receipt. Accepted Ambitions-owned copies remain unchanged. Visible evidence remains: An outside calendar update failed; the Ambitions-owned copy remains unchanged. Outcomes preserve native-object, capacity, lineage, badge, notification, and external effects separately. Current visible status: An outside calendar update failed; the Ambitions-owned copy remains unchanged."
recovery_rollback = "Exact atomic partial, failed-ID retry, semantic Undo, and external-write recovery: Retry Failed Items: Cancellation leaves the accepted local import and failed external identity list unchanged; another retry starts only after fresh revalidation. Completed and failed identities remain explicit, and a changed source fingerprint invalidates confirmation. Recovery preserves: An outside calendar update failed; the Ambitions-owned copy remains unchanged."
offline_behavior = "Stored Import/Diff Records, exact groups, selection, reviewed outcomes, lineage, completed/failed IDs, Receipts, and recovery remain usable offline. New source reads and external writes wait without changing accepted local truth. Offline evidence remains: An outside calendar update failed; the Ambitions-owned copy remains unchanged."
accessibility_focus = "VoiceOver names group, source summary, prior/new values, outcome, native-object and capacity consequence, external effect, and recovery without color dependence: Retry Failed Items announces the exact record consequence; success focuses the first affected record or Retry Failed Items result heading in External calendar review — External Write Failure; rejection focuses the Retry Failed Items control and first stale, invalid, or failed record in External calendar review — External Write Failure. Dynamic Type stacks every diff and consequence. The announcement first communicates: An outside calendar update failed; the Ambitions-owned copy remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-EXTERNAL-WRITE-FAILURE-001"
label = "Retry Failed Items"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Every non-safe record has an explicit reviewed outcome before commit", "Every selected or failed record ID is explicit and belongs to its reviewed group", "Permission and minimum necessary source access remain valid for the attempted import", "The deterministic ordered batch can commit only at atomic per-record boundaries", "The failed identities name only external dispatches whose local per-record commits are already accepted", "The presented source identity, source fingerprint, diff revision, and local revision have been revalidated"]
destination = "the external-write reconciliation result for only the failed identities from External calendar review — External Write Failure"
destination_id = "DEST-TIME-IMPORT-EXTERNAL-WRITE-FAILURE-001"
destination_posture = "current"
effect = "The Retry Failed Items external result causes no local canonical mutation; it retries only explicitly failed external-dispatch identities after revalidating source and local freshness, cannot replay completed local imports, and records the separate external result and egress Receipt. Accepted Ambitions-owned copies remain unchanged. Visible evidence remains: An outside calendar update failed; the Ambitions-owned copy remains unchanged."
success_focus = "the first affected record or Retry Failed Items result heading in External calendar review — External Write Failure"
success_focus_id = "FOCUS-TIME-IMPORT-EXTERNAL-WRITE-FAILURE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Retry Failed Items control and first stale, invalid, or failed record in External calendar review — External Write Failure"
failure_focus_id = "FOCUS-TIME-IMPORT-EXTERNAL-WRITE-FAILURE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: the external write is separately dispatched after local success and cannot redefine or replay the accepted canonical import."
rollback_undo = "Cancellation leaves the accepted local import and failed external identity list unchanged; another retry starts only after fresh revalidation."
recovery_id = "RECOVERY-TIME-IMPORT-EXTERNAL-WRITE-FAILURE-001"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Review uses minimum necessary stored source facts; selection and preview never alter the source, and any explicit external write sends only approved event fields with a separate egress Receipt."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-IMPORT-IMPORT-FAILED"
requirement_id = "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Retry Failed Items => destination: the ordered retry result and first still-failed record from External calendar review — Import Failed; effect: Each failed identity executes one typed Retry Failed Items Command after source identity, source fingerprint, diff revision, and local revision validation; it appends an Event, updates the import and Time Projection, and creates a Receipt and History entry. Only failed IDs are retried, completed IDs cannot duplicate, and partial boundaries remain per-record. Visible evidence remains: The calendar import did not finish. The source and any completed local copies remain identifiable.; focus: the first affected record or Retry Failed Items result heading in External calendar review — Import Failed."
durable_effect = "Exact import consequences across reviewed groups [Needs attention; Safe to import; Duplicate or link candidates; Removed source; Ignored history]: Retry Failed Items: Each failed identity executes one typed Retry Failed Items Command after source identity, source fingerprint, diff revision, and local revision validation; it appends an Event, updates the import and Time Projection, and creates a Receipt and History entry. Only failed IDs are retried, completed IDs cannot duplicate, and partial boundaries remain per-record. Visible evidence remains: The calendar import did not finish. The source and any completed local copies remain identifiable. Outcomes preserve native-object, capacity, lineage, badge, notification, and external effects separately. Current visible status: The calendar import did not finish. The source and any completed local copies remain identifiable."
recovery_rollback = "Exact atomic partial, failed-ID retry, semantic Undo, and external-write recovery: Retry Failed Items: Before each record commit, cancellation leaves it failed; after commit, the record moves exactly once to completed and any remaining failed IDs stay explicit. Completed and failed identities remain explicit, and a changed source fingerprint invalidates confirmation. Recovery preserves: The calendar import did not finish. The source and any completed local copies remain identifiable."
offline_behavior = "Stored Import/Diff Records, exact groups, selection, reviewed outcomes, lineage, completed/failed IDs, Receipts, and recovery remain usable offline. New source reads and external writes wait without changing accepted local truth. Offline evidence remains: The calendar import did not finish. The source and any completed local copies remain identifiable."
accessibility_focus = "VoiceOver names group, source summary, prior/new values, outcome, native-object and capacity consequence, external effect, and recovery without color dependence: Retry Failed Items announces the exact record consequence; success focuses the first affected record or Retry Failed Items result heading in External calendar review — Import Failed; rejection focuses the Retry Failed Items control and first stale, invalid, or failed record in External calendar review — Import Failed. Dynamic Type stacks every diff and consequence. The announcement first communicates: The calendar import did not finish. The source and any completed local copies remain identifiable."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-IMPORT-FAILED-001"
label = "Retry Failed Items"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Every non-safe record has an explicit reviewed outcome before commit", "Every selected or failed record ID is explicit and belongs to its reviewed group", "Permission and minimum necessary source access remain valid for the attempted import", "The deterministic ordered batch can commit only at atomic per-record boundaries", "The presented source identity, source fingerprint, diff revision, and local revision have been revalidated"]
destination = "the ordered retry result and first still-failed record from External calendar review — Import Failed"
destination_id = "DEST-TIME-IMPORT-IMPORT-FAILED-001"
destination_posture = "current"
effect = "Each failed identity executes one typed Retry Failed Items Command after source identity, source fingerprint, diff revision, and local revision validation; it appends an Event, updates the import and Time Projection, and creates a Receipt and History entry. Only failed IDs are retried, completed IDs cannot duplicate, and partial boundaries remain per-record. Visible evidence remains: The calendar import did not finish. The source and any completed local copies remain identifiable."
success_focus = "the first affected record or Retry Failed Items result heading in External calendar review — Import Failed"
success_focus_id = "FOCUS-TIME-IMPORT-IMPORT-FAILED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Retry Failed Items control and first stale, invalid, or failed record in External calendar review — Import Failed"
failure_focus_id = "FOCUS-TIME-IMPORT-IMPORT-FAILED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: retry commits only failed identities, one atomic record at a time, through Event, Projection, Receipt, History, and replay-safe idempotency."
rollback_undo = "Before each record commit, cancellation leaves it failed; after commit, the import owner recovery handoff preserves completed IDs and exposes only remaining failed IDs."
recovery_id = "RECOVERY-TIME-IMPORT-IMPORT-FAILED-001"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Review uses minimum necessary stored source facts; selection and preview never alter the source, and any explicit external write sends only approved event fields with a separate egress Receipt."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "owner_recovery_handoff"
recovery_handoff_command_id = "CMD-TIME-IMPORT-IMPORT-FAILED-001-RECOVERY-HANDOFF"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-IMPORT-FAILED-001"
mechanism_kind = "recovery_handoff_command"
command_id = "CMD-TIME-IMPORT-IMPORT-FAILED-001-RECOVERY-HANDOFF"
label = "Review failed import recovery"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-IMPORT-FAILED-001 is the exact trigger command and its exact trigger Receipt is current", "The source fingerprint, completed-ID set, remaining failed-ID set, and per-record import Receipts are current"]
destination = "the calendar import recovery ledger filtered to the failed retry scope, with completed IDs, remaining failed IDs, source fingerprint, and per-record Receipts visible"
destination_id = "DEST-TIME-IMPORT-IMPORT-FAILED-001-RECOVERY-HANDOFF"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the exact trigger Receipt and scope route only to journey.calendar-import.command-contract for the failed retry set, preserving every completed import ID, remaining failed ID, source fingerprint, local object, Projection, Receipt, and History unchanged."
success_focus = "the remaining failed-ID heading followed by the first separately authorized per-record recovery action"
success_focus_id = "FOCUS-TIME-IMPORT-IMPORT-FAILED-001-RECOVERY-HANDOFF-SUCCESS"
success_focus_posture = "current"
failure_focus = "the failed-import recovery control and exact ledger-route failure; the exact trigger Receipt and scope, completed IDs, and failed IDs remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-IMPORT-FAILED-001-RECOVERY-HANDOFF-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: routing and inspection complete without a canonical Event, Projection change, or new Receipt."
rollback_undo = "No Undo is required; dismissal returns to the exact trigger result with canonical state, Receipt, and History unchanged."
recovery_id = "RECOVERY-TIME-IMPORT-IMPORT-FAILED-001-RECOVERY-HANDOFF"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The handoff reads only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-IMPORT-IMPORT-UNDO-UNAVAILABLE"
requirement_id = "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the Time import origin or durable result summary from External calendar review — Import Undo Unavailable; effect: No durable mutation occurs and no Receipt is created; Done dismisses only the current progress or result presentation. Completed and failed record IDs, source lineage, Receipts, and external-source status remain available. Visible evidence remains: Undo is unavailable because later native changes make reversal unsafe. The external source remains unchanged.; focus: the first affected record or Done result heading in External calendar review — Import Undo Unavailable."
durable_effect = "Exact import consequences across reviewed groups [Needs attention; Safe to import; Duplicate or link candidates; Removed source; Ignored history]: Done: No durable mutation occurs and no Receipt is created; Done dismisses only the current progress or result presentation. Completed and failed record IDs, source lineage, Receipts, and external-source status remain available. Visible evidence remains: Undo is unavailable because later native changes make reversal unsafe. The external source remains unchanged. Outcomes preserve native-object, capacity, lineage, badge, notification, and external effects separately. Current visible status: Undo is unavailable because later native changes make reversal unsafe. The external source remains unchanged."
recovery_rollback = "Exact atomic partial, failed-ID retry, semantic Undo, and external-write recovery: Done: No Undo is required; reopening Time import restores the durable completed/failed identities, Receipt, and safe recovery route. Completed and failed identities remain explicit, and a changed source fingerprint invalidates confirmation. Recovery preserves: Undo is unavailable because later native changes make reversal unsafe. The external source remains unchanged."
offline_behavior = "Stored Import/Diff Records, exact groups, selection, reviewed outcomes, lineage, completed/failed IDs, Receipts, and recovery remain usable offline. New source reads and external writes wait without changing accepted local truth. Offline evidence remains: Undo is unavailable because later native changes make reversal unsafe. The external source remains unchanged."
accessibility_focus = "VoiceOver names group, source summary, prior/new values, outcome, native-object and capacity consequence, external effect, and recovery without color dependence: Done announces the exact record consequence; success focuses the first affected record or Done result heading in External calendar review — Import Undo Unavailable; rejection focuses the Done control and first stale, invalid, or failed record in External calendar review — Import Undo Unavailable. Dynamic Type stacks every diff and consequence. The announcement first communicates: Undo is unavailable because later native changes make reversal unsafe. The external source remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-IMPORT-UNDO-UNAVAILABLE-001"
label = "Done"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Permission and minimum necessary source access remain valid for the attempted import", "The presented source identity, source fingerprint, diff revision, and local revision have been revalidated"]
destination = "the Time import origin or durable result summary from External calendar review — Import Undo Unavailable"
destination_id = "DEST-TIME-IMPORT-IMPORT-UNDO-UNAVAILABLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done dismisses only the current progress or result presentation. Completed and failed record IDs, source lineage, Receipts, and external-source status remain available. Visible evidence remains: Undo is unavailable because later native changes make reversal unsafe. The external source remains unchanged."
success_focus = "the first affected record or Done result heading in External calendar review — Import Undo Unavailable"
success_focus_id = "FOCUS-TIME-IMPORT-IMPORT-UNDO-UNAVAILABLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and first stale, invalid, or failed record in External calendar review — Import Undo Unavailable"
failure_focus_id = "FOCUS-TIME-IMPORT-IMPORT-UNDO-UNAVAILABLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: dismissal completes without changing selection, import outcomes, lineage, or external source."
rollback_undo = "No Undo is required; reopening Time import restores the durable completed/failed identities, Receipt, and safe recovery route."
recovery_id = "RECOVERY-TIME-IMPORT-IMPORT-UNDO-UNAVAILABLE-001"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Review uses minimum necessary stored source facts; selection and preview never alter the source, and any explicit external write sends only approved event fields with a separate egress Receipt."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-IMPORT-NATIVE-IMPORT-UNDO"
requirement_id = "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Undo Imported Items => destination: the native import Undo result and preserved batch History from External calendar review — Native Import Undo; effect: A typed Undo Imported Items Command validates current native dependencies, source provenance, and inverse safety; appends an Event, updates the Time, import, lineage, capacity, and badge Projection, and creates a Receipt and History entry. It never changes the external source or erases prior import evidence. Visible evidence before Undo remains: Imported Ambitions-native items remain linked to their source. The external source remains unchanged, and earlier History remains available.; focus: the first affected record or Undo Imported Items result heading in External calendar review — Native Import Undo."
durable_effect = "Exact import consequences across reviewed groups [Needs attention; Safe to import; Duplicate or link candidates; Removed source; Ignored history]: Undo Imported Items: A typed Undo Imported Items Command validates current native dependencies, source provenance, and inverse safety; appends an Event, updates the Time, import, lineage, capacity, and badge Projection, and creates a Receipt and History entry. It never changes the external source or erases prior import evidence. Visible evidence before Undo remains: Imported Ambitions-native items remain linked to their source. The external source remains unchanged, and earlier History remains available. Outcomes preserve native-object, capacity, lineage, badge, notification, and external effects separately. Current visible status: Imported Ambitions-native items remain linked to their source. The external source remains unchanged, and earlier History remains available."
recovery_rollback = "Exact atomic partial, failed-ID retry, semantic Undo, and external-write recovery: Undo Imported Items: Before commit, cancellation changes nothing; after commit, redo or further recovery is a separately validated typed command, while unsafe Undo routes to detail, Trash or reconciliation. Completed and failed identities remain explicit, and a changed source fingerprint invalidates confirmation. Recovery preserves: Imported Ambitions-native items remain linked to their source. The external source remains unchanged, and earlier History remains available."
offline_behavior = "Stored Import/Diff Records, exact groups, selection, reviewed outcomes, lineage, completed/failed IDs, Receipts, and recovery remain usable offline. New source reads and external writes wait without changing accepted local truth. Offline evidence remains: Imported Ambitions-native items remain linked to their source. The external source remains unchanged, and earlier History remains available."
accessibility_focus = "VoiceOver names group, source summary, prior/new values, outcome, native-object and capacity consequence, external effect, and recovery without color dependence: Undo Imported Items announces the exact record consequence; success focuses the first affected record or Undo Imported Items result heading in External calendar review — Native Import Undo; rejection focuses the Undo Imported Items control and first stale, invalid, or failed record in External calendar review — Native Import Undo. Dynamic Type stacks every diff and consequence. The announcement first communicates: Imported Ambitions-native items remain linked to their source. The external source remains unchanged, and earlier History remains available."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-NATIVE-IMPORT-UNDO-001"
label = "Undo Imported Items"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["A deterministic inverse remains semantically safe after dependency, provenance, Trash, and external-effect checks", "Permission and minimum necessary source access remain valid for the attempted import", "The exact imported native identities and prior lineage are still available", "The presented source identity, source fingerprint, diff revision, and local revision have been revalidated"]
destination = "the native import Undo result and preserved batch History from External calendar review — Native Import Undo"
destination_id = "DEST-TIME-IMPORT-NATIVE-IMPORT-UNDO-001"
destination_posture = "current"
effect = "A typed Undo Imported Items Command validates current native dependencies, source provenance, and inverse safety; appends an Event, updates the Time, import, lineage, capacity, and badge Projection, and creates a Receipt and History entry. It never changes the external source or erases prior import evidence. Visible evidence before Undo remains: Imported Ambitions-native items remain linked to their source. The external source remains unchanged, and earlier History remains available."
success_focus = "the first affected record or Undo Imported Items result heading in External calendar review — Native Import Undo"
success_focus_id = "FOCUS-TIME-IMPORT-NATIVE-IMPORT-UNDO-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Undo Imported Items control and first stale, invalid, or failed record in External calendar review — Native Import Undo"
failure_focus_id = "FOCUS-TIME-IMPORT-NATIVE-IMPORT-UNDO-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: semantic Undo commits only a proven deterministic inverse through Event, Projection, Receipt, History, and replay-safe ownership."
rollback_undo = "Before commit, cancellation changes nothing; after commit, redo or further recovery is a separately validated typed command, while unsafe Undo routes to detail, Trash or reconciliation."
recovery_id = "RECOVERY-TIME-IMPORT-NATIVE-IMPORT-UNDO-001"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Review uses minimum necessary stored source facts; selection and preview never alter the source, and any explicit external write sends only approved event fields with a separate egress Receipt."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-TIME-IMPORT-NATIVE-IMPORT-UNDO-001-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-NATIVE-IMPORT-UNDO-001"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-TIME-IMPORT-NATIVE-IMPORT-UNDO-001"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-TIME-IMPORT-NATIVE-IMPORT-UNDO-001-INVERSE"
label = "Restore imported items"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-NATIVE-IMPORT-UNDO-001 is the exact trigger command and its exact trigger Receipt is current", "The exact imported object set, source lineage, capacity/reflow dependencies, notification-rule links, and trigger Undo revision are current"]
destination = "the Time import result with the exact previously undone native objects restored under their original source lineage and per-record recovery Receipts"
destination_id = "DEST-TIME-IMPORT-NATIVE-IMPORT-UNDO-001-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it restores the exact Ambitions-native object set removed by Undo Imported Items together with its source lineage, capacity, badge, approved reflow, and linked local notification posture, appends a reversing Event, updates the Time and import Projection, and creates a new inverse Receipt and History entry while the external source, original import Receipts, trigger Undo Receipt, and History remain intact."
success_focus = "the first restored imported object followed by the restored-set count and new recovery Receipt"
success_focus_id = "FOCUS-TIME-IMPORT-NATIVE-IMPORT-UNDO-001-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Restore imported items control and exact unsafe, stale, or dependency-invalid object/lineage/reflow reason; the undone set and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-NATIVE-IMPORT-UNDO-001-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-TIME-IMPORT-NATIVE-IMPORT-UNDO-001-INVERSE"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-IMPORT-PARTIAL-IMPORT"
requirement_id = "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Retry Failed Items => destination: the ordered retry result and first still-failed record from External calendar review — Partial Import; effect: Each failed identity executes one typed Retry Failed Items Command after source identity, source fingerprint, diff revision, and local revision validation; it appends an Event, updates the import and Time Projection, and creates a Receipt and History entry. Only failed IDs are retried, completed IDs cannot duplicate, and partial boundaries remain per-record. Visible evidence remains: Only some calendar items were copied; completed and missing items are clearly separated.; focus: the first affected record or Retry Failed Items result heading in External calendar review — Partial Import."
durable_effect = "Exact import consequences across reviewed groups [Needs attention; Safe to import; Duplicate or link candidates; Removed source; Ignored history]: Retry Failed Items: Each failed identity executes one typed Retry Failed Items Command after source identity, source fingerprint, diff revision, and local revision validation; it appends an Event, updates the import and Time Projection, and creates a Receipt and History entry. Only failed IDs are retried, completed IDs cannot duplicate, and partial boundaries remain per-record. Visible evidence remains: Only some calendar items were copied; completed and missing items are clearly separated. Outcomes preserve native-object, capacity, lineage, badge, notification, and external effects separately. Current visible status: Only some calendar items were copied; completed and missing items are clearly separated."
recovery_rollback = "Exact atomic partial, failed-ID retry, semantic Undo, and external-write recovery: Retry Failed Items: Before each record commit, cancellation leaves it failed; after commit, the record moves exactly once to completed and any remaining failed IDs stay explicit. Completed and failed identities remain explicit, and a changed source fingerprint invalidates confirmation. Recovery preserves: Only some calendar items were copied; completed and missing items are clearly separated."
offline_behavior = "Stored Import/Diff Records, exact groups, selection, reviewed outcomes, lineage, completed/failed IDs, Receipts, and recovery remain usable offline. New source reads and external writes wait without changing accepted local truth. Offline evidence remains: Only some calendar items were copied; completed and missing items are clearly separated."
accessibility_focus = "VoiceOver names group, source summary, prior/new values, outcome, native-object and capacity consequence, external effect, and recovery without color dependence: Retry Failed Items announces the exact record consequence; success focuses the first affected record or Retry Failed Items result heading in External calendar review — Partial Import; rejection focuses the Retry Failed Items control and first stale, invalid, or failed record in External calendar review — Partial Import. Dynamic Type stacks every diff and consequence. The announcement first communicates: Only some calendar items were copied; completed and missing items are clearly separated."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-PARTIAL-IMPORT-001"
label = "Retry Failed Items"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Every non-safe record has an explicit reviewed outcome before commit", "Every selected or failed record ID is explicit and belongs to its reviewed group", "Permission and minimum necessary source access remain valid for the attempted import", "The deterministic ordered batch can commit only at atomic per-record boundaries", "The presented source identity, source fingerprint, diff revision, and local revision have been revalidated"]
destination = "the ordered retry result and first still-failed record from External calendar review — Partial Import"
destination_id = "DEST-TIME-IMPORT-PARTIAL-IMPORT-001"
destination_posture = "current"
effect = "Each failed identity executes one typed Retry Failed Items Command after source identity, source fingerprint, diff revision, and local revision validation; it appends an Event, updates the import and Time Projection, and creates a Receipt and History entry. Only failed IDs are retried, completed IDs cannot duplicate, and partial boundaries remain per-record. Visible evidence remains: Only some calendar items were copied; completed and missing items are clearly separated."
success_focus = "the first affected record or Retry Failed Items result heading in External calendar review — Partial Import"
success_focus_id = "FOCUS-TIME-IMPORT-PARTIAL-IMPORT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Retry Failed Items control and first stale, invalid, or failed record in External calendar review — Partial Import"
failure_focus_id = "FOCUS-TIME-IMPORT-PARTIAL-IMPORT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: retry commits only failed identities, one atomic record at a time, through Event, Projection, Receipt, History, and replay-safe idempotency."
rollback_undo = "Before each record commit, cancellation leaves it failed; after commit, the import owner recovery handoff preserves completed IDs and exposes only remaining failed IDs."
recovery_id = "RECOVERY-TIME-IMPORT-PARTIAL-IMPORT-001"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Review uses minimum necessary stored source facts; selection and preview never alter the source, and any explicit external write sends only approved event fields with a separate egress Receipt."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "owner_recovery_handoff"
recovery_handoff_command_id = "CMD-TIME-IMPORT-PARTIAL-IMPORT-001-RECOVERY-HANDOFF"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-PARTIAL-IMPORT-001"
mechanism_kind = "recovery_handoff_command"
command_id = "CMD-TIME-IMPORT-PARTIAL-IMPORT-001-RECOVERY-HANDOFF"
label = "Review partial import recovery"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-PARTIAL-IMPORT-001 is the exact trigger command and its exact trigger Receipt is current", "The source fingerprint, successfully copied object IDs, missing object IDs, and atomic per-record boundary are current"]
destination = "the partial import reconciliation view separating successfully copied objects from missing objects under the exact source fingerprint and trigger Receipt"
destination_id = "DEST-TIME-IMPORT-PARTIAL-IMPORT-001-RECOVERY-HANDOFF"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the exact trigger Receipt and scope route only to journey.calendar-import.command-contract for partial-import reconciliation, preserving copied objects and their Receipts, missing IDs, source lineage, Projection, and History unchanged."
success_focus = "the missing-object group heading followed by the first separately authorized per-record retry action"
success_focus_id = "FOCUS-TIME-IMPORT-PARTIAL-IMPORT-001-RECOVERY-HANDOFF-SUCCESS"
success_focus_posture = "current"
failure_focus = "the partial-import recovery control and exact reconciliation-route failure; the exact trigger Receipt and scope, copied IDs, and missing IDs remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-PARTIAL-IMPORT-001-RECOVERY-HANDOFF-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: routing and inspection complete without a canonical Event, Projection change, or new Receipt."
rollback_undo = "No Undo is required; dismissal returns to the exact trigger result with canonical state, Receipt, and History unchanged."
recovery_id = "RECOVERY-TIME-IMPORT-PARTIAL-IMPORT-001-RECOVERY-HANDOFF"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The handoff reads only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-IMPORT-RECONCILING"
requirement_id = "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Selected => destination: the first selected record and its complete consequence preview from External calendar review — Reconciling; effect: No durable mutation occurs and no Receipt is created; Review Selected preserves selection while showing native-object, capacity, lineage, badge, notification, and external consequences for each record. Visible evidence remains: Imported and outside calendar versions are being compared before another change.; focus: the first affected record or Review Selected result heading in External calendar review — Reconciling."
durable_effect = "Exact import consequences across reviewed groups [Needs attention; Safe to import; Duplicate or link candidates; Removed source; Ignored history]: Review Selected: No durable mutation occurs and no Receipt is created; Review Selected preserves selection while showing native-object, capacity, lineage, badge, notification, and external consequences for each record. Visible evidence remains: Imported and outside calendar versions are being compared before another change. Outcomes preserve native-object, capacity, lineage, badge, notification, and external effects separately. Current visible status: Imported and outside calendar versions are being compared before another change."
recovery_rollback = "Exact atomic partial, failed-ID retry, semantic Undo, and external-write recovery: Review Selected: No Undo is required; cancellation returns to the exact groups, selection, and first reviewed record with local and external data unchanged. Completed and failed identities remain explicit, and a changed source fingerprint invalidates confirmation. Recovery preserves: Imported and outside calendar versions are being compared before another change."
offline_behavior = "Stored Import/Diff Records, exact groups, selection, reviewed outcomes, lineage, completed/failed IDs, Receipts, and recovery remain usable offline. New source reads and external writes wait without changing accepted local truth. Offline evidence remains: Imported and outside calendar versions are being compared before another change."
accessibility_focus = "VoiceOver names group, source summary, prior/new values, outcome, native-object and capacity consequence, external effect, and recovery without color dependence: Review Selected announces the exact record consequence; success focuses the first affected record or Review Selected result heading in External calendar review — Reconciling; rejection focuses the Review Selected control and first stale, invalid, or failed record in External calendar review — Reconciling. Dynamic Type stacks every diff and consequence. The announcement first communicates: Imported and outside calendar versions are being compared before another change."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-RECONCILING-001"
label = "Review Selected"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Permission and minimum necessary source access remain valid for the attempted import", "The presented source identity, source fingerprint, diff revision, and local revision have been revalidated"]
destination = "the first selected record and its complete consequence preview from External calendar review — Reconciling"
destination_id = "DEST-TIME-IMPORT-RECONCILING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Selected preserves selection while showing native-object, capacity, lineage, badge, notification, and external consequences for each record. Visible evidence remains: Imported and outside calendar versions are being compared before another change."
success_focus = "the first affected record or Review Selected result heading in External calendar review — Reconciling"
success_focus_id = "FOCUS-TIME-IMPORT-RECONCILING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Selected control and first stale, invalid, or failed record in External calendar review — Reconciling"
failure_focus_id = "FOCUS-TIME-IMPORT-RECONCILING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: selection and consequence preview remain before every per-record canonical commit boundary."
rollback_undo = "No Undo is required; cancellation returns to the exact groups, selection, and first reviewed record with local and external data unchanged."
recovery_id = "RECOVERY-TIME-IMPORT-RECONCILING-001"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Review uses minimum necessary stored source facts; selection and preview never alter the source, and any explicit external write sends only approved event fields with a separate egress Receipt."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-IMPORT-RESTORED"
requirement_id = "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the Time import origin or durable result summary from External calendar review — Restored; effect: No durable mutation occurs and no Receipt is created; Done dismisses only the current progress or result presentation. Completed and failed record IDs, source lineage, Receipts, and external-source status remain available. Visible evidence remains: Earlier Ambitions calendar information is visible again. Import History remains intact.; focus: the first affected record or Done result heading in External calendar review — Restored."
durable_effect = "Exact import consequences across reviewed groups [Needs attention; Safe to import; Duplicate or link candidates; Removed source; Ignored history]: Done: No durable mutation occurs and no Receipt is created; Done dismisses only the current progress or result presentation. Completed and failed record IDs, source lineage, Receipts, and external-source status remain available. Visible evidence remains: Earlier Ambitions calendar information is visible again. Import History remains intact. Outcomes preserve native-object, capacity, lineage, badge, notification, and external effects separately. Current visible status: Earlier Ambitions calendar information is visible again. Import History remains intact."
recovery_rollback = "Exact atomic partial, failed-ID retry, semantic Undo, and external-write recovery: Done: No Undo is required; reopening Time import restores the durable completed/failed identities, Receipt, and safe recovery route. Completed and failed identities remain explicit, and a changed source fingerprint invalidates confirmation. Recovery preserves: Earlier Ambitions calendar information is visible again. Import History remains intact."
offline_behavior = "Stored Import/Diff Records, exact groups, selection, reviewed outcomes, lineage, completed/failed IDs, Receipts, and recovery remain usable offline. New source reads and external writes wait without changing accepted local truth. Offline evidence remains: Earlier Ambitions calendar information is visible again. Import History remains intact."
accessibility_focus = "VoiceOver names group, source summary, prior/new values, outcome, native-object and capacity consequence, external effect, and recovery without color dependence: Done announces the exact record consequence; success focuses the first affected record or Done result heading in External calendar review — Restored; rejection focuses the Done control and first stale, invalid, or failed record in External calendar review — Restored. Dynamic Type stacks every diff and consequence. The announcement first communicates: Earlier Ambitions calendar information is visible again. Import History remains intact."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-RESTORED-001"
label = "Done"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Permission and minimum necessary source access remain valid for the attempted import", "The presented source identity, source fingerprint, diff revision, and local revision have been revalidated"]
destination = "the Time import origin or durable result summary from External calendar review — Restored"
destination_id = "DEST-TIME-IMPORT-RESTORED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done dismisses only the current progress or result presentation. Completed and failed record IDs, source lineage, Receipts, and external-source status remain available. Visible evidence remains: Earlier Ambitions calendar information is visible again. Import History remains intact."
success_focus = "the first affected record or Done result heading in External calendar review — Restored"
success_focus_id = "FOCUS-TIME-IMPORT-RESTORED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and first stale, invalid, or failed record in External calendar review — Restored"
failure_focus_id = "FOCUS-TIME-IMPORT-RESTORED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: dismissal completes without changing selection, import outcomes, lineage, or external source."
rollback_undo = "No Undo is required; reopening Time import restores the durable completed/failed identities, Receipt, and safe recovery route."
recovery_id = "RECOVERY-TIME-IMPORT-RESTORED-001"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Review uses minimum necessary stored source facts; selection and preview never alter the source, and any explicit external write sends only approved event fields with a separate egress Receipt."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-TIME-IMPORT-REVIEWING-DIFF"
requirement_id = "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Import Selected => destination: the ordered import result and first failed record or batch Receipt from External calendar review — Reviewing Diff; effect: Each selected identity executes one typed Import Selected Command that validates source identity, source fingerprint, diff revision, and local revision; appends an Event; updates the import, Time, lineage, capacity, and badge Projection; and creates a Receipt and History entry. The batch is a deterministic ordered collection of atomic per-record commits, so partial results occur only between records with explicit completed and failed IDs. No external source is changed. Visible evidence before commit remains: The import differences are visible. No outside or Ambitions item has changed.; focus: the first affected record or Import Selected result heading in External calendar review — Reviewing Diff.\nReview Selected => destination: the first selected record and its complete consequence preview from External calendar review — Reviewing Diff; effect: No durable mutation occurs and no Receipt is created; Review Selected preserves selection while showing native-object, capacity, lineage, badge, notification, and external consequences for each record. Visible evidence remains: The import differences are visible. No outside or Ambitions item has changed.; focus: the first affected record or Review Selected result heading in External calendar review — Reviewing Diff.\nClear Selection => destination: the same grouped import diff with no records selected; effect: No durable mutation occurs and no Receipt is created; selection clears without changing source or native objects; focus: the changed selection and its first consequence.\nEdit before import => destination: the bounded local pre-import editor for the selected record; effect: No durable mutation occurs and no Receipt is created; a local review draft opens without changing the external source or canonical objects; focus: the first editable field and conflict consequence.\nEdit notification rules => destination: the owning notification-rule editor with the selected import consequence preview; effect: No durable mutation occurs and no Receipt is created; the import remains uncommitted while notification ownership is reviewed by the owning notification-rule system; focus: the notification-rule heading and selected import consequence.\nIgnore => destination: the reviewed diff with the conflict outcome recorded; effect: The typed Ignore command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the selected conflict is excluded from this import decision without changing its external source; focus: the committed record result or first failed identity.\nIgnore for planning => destination: the reviewed diff with planning exclusion recorded; effect: The typed Ignore for planning command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the selected source record remains external and stops contributing planning capacity under the reviewed outcome; focus: the committed record result or first failed identity.\nImport and reflow => destination: the native import result and reviewed reflow consequence; effect: The typed Import and reflow command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one native object and its atomic schedule change set are created from the reviewed record; focus: the committed record result or first failed identity.\nImport into Ambitions => destination: the native import result for the selected external record; effect: The typed Import into Ambitions command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one native object is created with source lineage and the external source remains unchanged; focus: the committed record result or first failed identity.\nImport with Ambitions notifications => destination: the native import result with Ambitions-owned notification policy; effect: The typed Import with Ambitions notifications command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one native object is created and its separately owned local notification rule is linked; focus: the committed record result or first failed identity.\nImport without Ambitions notifications => destination: the native import result without an Ambitions notification rule; effect: The typed Import without Ambitions notifications command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one native object is created while Ambitions does not own the alert; focus: the committed record result or first failed identity.\nImport without reflow => destination: the native import result with the reviewed schedule unchanged; effect: The typed Import without reflow command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one native object is created without applying a schedule reflow; focus: the committed record result or first failed identity.\nKeep external => destination: the reviewed diff with source ownership retained; effect: The typed Keep external command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the record and alert ownership remain external and no native object is created; focus: the committed record result or first failed identity.\nKeep external but reserve time => destination: the reviewed capacity result for the external record; effect: The typed Keep external but reserve time command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one local capacity reservation is created without importing or editing the external record; focus: the committed record result or first failed identity.\nLink => destination: the linked-source result for the selected record; effect: The typed Link command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one local source reference is linked without taking ownership of the external record; focus: the committed record result or first failed identity.\nReject permanently => destination: the reviewed diff with permanent rejection recorded; effect: The typed Reject permanently command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the exact source identity is rejected from future import proposals without deleting its external record; focus: the committed record result or first failed identity.\nReplace => destination: the replacement preview and native result for the selected record; effect: The typed Replace command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the reviewed native owner is replaced atomically while lineage and prior History remain inspectable; focus: the committed record result or first failed identity.\nSelect All in Group => destination: the same grouped import diff with every eligible record in the group selected; effect: No durable mutation occurs and no Receipt is created; eligible group selection changes only the local review draft; focus: the changed selection and its first consequence.\nSelect Item => destination: the same grouped import diff with the named record selected; effect: No durable mutation occurs and no Receipt is created; record selection changes only the local review draft; focus: the changed selection and its first consequence."
durable_effect = "Exact import consequences across reviewed groups [Needs attention; Safe to import; Duplicate or link candidates; Removed source; Ignored history]: Import Selected: Each selected identity executes one typed Import Selected Command that validates source identity, source fingerprint, diff revision, and local revision; appends an Event; updates the import, Time, lineage, capacity, and badge Projection; and creates a Receipt and History entry. The batch is a deterministic ordered collection of atomic per-record commits, so partial results occur only between records with explicit completed and failed IDs. No external source is changed. Visible evidence before commit remains: The import differences are visible. No outside or Ambitions item has changed. | Review Selected: No durable mutation occurs and no Receipt is created; Review Selected preserves selection while showing native-object, capacity, lineage, badge, notification, and external consequences for each record. Visible evidence remains: The import differences are visible. No outside or Ambitions item has changed. Outcomes preserve native-object, capacity, lineage, badge, notification, and external effects separately. Current visible status: The import differences are visible. No outside or Ambitions item has changed."
recovery_rollback = "Exact atomic partial, failed-ID retry, semantic Undo, and external-write recovery: Import Selected: Before the first record commit, cancellation changes nothing; after any record commits, completed and failed IDs stay explicit and recovery never rolls back a completed identity implicitly. | Review Selected: No Undo is required; cancellation returns to the exact groups, selection, and first reviewed record with local and external data unchanged. Completed and failed identities remain explicit, and a changed source fingerprint invalidates confirmation. Recovery preserves: The import differences are visible. No outside or Ambitions item has changed."
offline_behavior = "Stored Import/Diff Records, exact groups, selection, reviewed outcomes, lineage, completed/failed IDs, Receipts, and recovery remain usable offline. New source reads and external writes wait without changing accepted local truth. Offline evidence remains: The import differences are visible. No outside or Ambitions item has changed."
accessibility_focus = "VoiceOver names group, source summary, prior/new values, outcome, native-object and capacity consequence, external effect, and recovery without color dependence: Import Selected announces the exact record consequence; success focuses the first affected record or Import Selected result heading in External calendar review — Reviewing Diff; rejection focuses the Import Selected control and first stale, invalid, or failed record in External calendar review — Reviewing Diff | Review Selected announces the exact record consequence; success focuses the first affected record or Review Selected result heading in External calendar review — Reviewing Diff; rejection focuses the Review Selected control and first stale, invalid, or failed record in External calendar review — Reviewing Diff. Dynamic Type stacks every diff and consequence. The announcement first communicates: The import differences are visible. No outside or Ambitions item has changed."

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-001"
label = "Import Selected"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Every non-safe record has an explicit reviewed outcome before commit", "Every selected or failed record ID is explicit and belongs to its reviewed group", "Every selected record is Safe to import with an unambiguous outcome", "Permission and minimum necessary source access remain valid for the attempted import", "The deterministic ordered batch can commit only at atomic per-record boundaries", "The presented source identity, source fingerprint, diff revision, and local revision have been revalidated"]
destination = "the ordered import result and first failed record or batch Receipt from External calendar review — Reviewing Diff"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-001"
destination_posture = "current"
effect = "Each selected identity executes one typed Import Selected Command that validates source identity, source fingerprint, diff revision, and local revision; appends an Event; updates the import, Time, lineage, capacity, and badge Projection; and creates a Receipt and History entry. The batch is a deterministic ordered collection of atomic per-record commits, so partial results occur only between records with explicit completed and failed IDs. No external source is changed. Visible evidence before commit remains: The import differences are visible. No outside or Ambitions item has changed."
success_focus = "the first affected record or Import Selected result heading in External calendar review — Reviewing Diff"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Import Selected control and first stale, invalid, or failed record in External calendar review — Reviewing Diff"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: each selected record commits independently through Event, Projection, Receipt, History, and replay-safe ownership after the full freshness tuple is validated."
rollback_undo = "Before the first record commit, cancellation changes nothing; after any record commits, completed and failed IDs stay explicit and recovery never rolls back a completed identity implicitly."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-001"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Review uses minimum necessary stored source facts; selection and preview never alter the source, and any explicit external write sends only approved event fields with a separate egress Receipt."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "owner_recovery_handoff"
recovery_handoff_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-001-RECOVERY-HANDOFF"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-001"
mechanism_kind = "recovery_handoff_command"
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-001-RECOVERY-HANDOFF"
label = "Review selected import recovery"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-001 is the exact trigger command and its exact trigger Receipt is current", "The reviewed selection, source fingerprint, completed-ID set, failed-ID set, and last atomic record boundary are current"]
destination = "the selected import recovery ledger at the last atomic record boundary with completed, failed, and not-yet-attempted IDs separated"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-001-RECOVERY-HANDOFF"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the exact trigger Receipt and scope route only to journey.calendar-import.command-contract for the reviewed selection, preserving completed imports, failed IDs, unattempted IDs, source fingerprint, Projection, Receipt, and History unchanged."
success_focus = "the selected import recovery summary followed by the first separately authorized action for the exact failed or unattempted scope"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-001-RECOVERY-HANDOFF-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected-import recovery control and exact batch-ledger route failure; the exact trigger Receipt and scope and every completion boundary remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-001-RECOVERY-HANDOFF-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: routing and inspection complete without a canonical Event, Projection change, or new Receipt."
rollback_undo = "No Undo is required; dismissal returns to the exact trigger result with canonical state, Receipt, and History unchanged."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-001-RECOVERY-HANDOFF"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The handoff reads only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-002"
label = "Review Selected"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Permission and minimum necessary source access remain valid for the attempted import", "The presented source identity, source fingerprint, diff revision, and local revision have been revalidated"]
destination = "the first selected record and its complete consequence preview from External calendar review — Reviewing Diff"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Selected preserves selection while showing native-object, capacity, lineage, badge, notification, and external consequences for each record. Visible evidence remains: The import differences are visible. No outside or Ambitions item has changed."
success_focus = "the first affected record or Review Selected result heading in External calendar review — Reviewing Diff"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Selected control and first stale, invalid, or failed record in External calendar review — Reviewing Diff"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: selection and consequence preview remain before every per-record canonical commit boundary."
rollback_undo = "No Undo is required; cancellation returns to the exact groups, selection, and first reviewed record with local and external data unchanged."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-002"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Review uses minimum necessary stored source facts; selection and preview never alter the source, and any explicit external write sends only approved event fields with a separate egress Receipt."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-003"
label = "Clear Selection"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The target group and record identities remain present in the reviewed diff"]
destination = "the same grouped import diff with no records selected"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-003"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; selection clears without changing source or native objects"
success_focus = "the changed selection and its first consequence"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Clear Selection control and exact stale record or group"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-003"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Selection remains local; the external calendar receives no write or private Ambitions context."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-004"
label = "Edit before import"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The selected conflict record permits a local pre-import draft", "The target group and record identities remain present in the reviewed diff"]
destination = "the bounded local pre-import editor for the selected record"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-004"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; a local review draft opens without changing the external source or canonical objects"
success_focus = "the first editable field and conflict consequence"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Edit before import control and exact invalid field"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-004"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The draft remains local and does not write to the external calendar."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-005"
label = "Edit notification rules"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The selected record has an alert handoff requiring explicit notification ownership", "The target group and record identities remain present in the reviewed diff"]
destination = "the owning notification-rule editor with the selected import consequence preview"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-005"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the import remains uncommitted while notification ownership is reviewed by the owning notification-rule system"
success_focus = "the notification-rule heading and selected import consequence"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-005-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Edit notification rules control and unresolved alert ownership"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-005-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-005"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "No calendar or notification write occurs from the import review."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-006"
label = "Ignore"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Any changed source fingerprint invalidates confirmation before commit", "The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The exact reviewed outcome is valid for the selected record class", "The target group and record identities remain present in the reviewed diff"]
destination = "the reviewed diff with the conflict outcome recorded"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-006"
destination_posture = "current"
effect = "The typed Ignore command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the selected conflict is excluded from this import decision without changing its external source"
success_focus = "the committed record result or first failed identity"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-006-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Ignore control and exact stale fingerprint, revision, or outcome"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-006-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "The import owner recovery handoff opens a separately authorized correction command; cancellation before commit changes nothing and History preserves the decision."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-006"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Only separately confirmed calendar effects may reach EventKit; private graph context never leaves Ambitions."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "owner_recovery_handoff"
recovery_handoff_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-006-RECOVERY-HANDOFF"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-006"
mechanism_kind = "recovery_handoff_command"
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-006-RECOVERY-HANDOFF"
label = "Review ignored import decision"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-006 is the exact trigger command and its exact trigger Receipt is current", "The ignored source identity, conflict revision, source fingerprint, and exclusion decision Receipt are current"]
destination = "the import decision inspection for the exact ignored source identity with its conflict, source fingerprint, exclusion scope, and correction route visible"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-006-RECOVERY-HANDOFF"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the exact trigger Receipt and scope route only to journey.calendar-import.command-contract for inspection of the ignored import decision, while the external record, exclusion marker, Projection, Receipt, and History remain unchanged."
success_focus = "the ignored source identity and exclusion reason followed by the first separately authorized correction action"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-006-RECOVERY-HANDOFF-SUCCESS"
success_focus_posture = "current"
failure_focus = "the ignored-decision review control and exact source/decision route failure; the exact trigger Receipt and scope remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-006-RECOVERY-HANDOFF-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: routing and inspection complete without a canonical Event, Projection change, or new Receipt."
rollback_undo = "No Undo is required; dismissal returns to the exact trigger result with canonical state, Receipt, and History unchanged."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-006-RECOVERY-HANDOFF"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The handoff reads only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-007"
label = "Ignore for planning"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Any changed source fingerprint invalidates confirmation before commit", "The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The exact reviewed outcome is valid for the selected record class", "The target group and record identities remain present in the reviewed diff"]
destination = "the reviewed diff with planning exclusion recorded"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-007"
destination_posture = "current"
effect = "The typed Ignore for planning command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the selected source record remains external and stops contributing planning capacity under the reviewed outcome"
success_focus = "the committed record result or first failed identity"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-007-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Ignore for planning control and exact stale fingerprint, revision, or outcome"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-007-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "The import owner recovery handoff opens a separately authorized correction command; cancellation before commit changes nothing and History preserves the decision."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-007"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Only separately confirmed calendar effects may reach EventKit; private graph context never leaves Ambitions."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "owner_recovery_handoff"
recovery_handoff_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-007-RECOVERY-HANDOFF"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-007"
mechanism_kind = "recovery_handoff_command"
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-007-RECOVERY-HANDOFF"
label = "Review planning exclusion"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-007 is the exact trigger command and its exact trigger Receipt is current", "The external source identity, planning-capacity exclusion marker, source fingerprint, and decision Receipt are current"]
destination = "the import planning-decision inspection for the exact external record with its capacity exclusion and correction route visible"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-007-RECOVERY-HANDOFF"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the exact trigger Receipt and scope route only to journey.calendar-import.command-contract for planning-exclusion inspection, while the external record remains unowned and the capacity exclusion marker, Projection, Receipt, and History remain unchanged."
success_focus = "the planning-capacity exclusion summary followed by the first separately authorized correction action"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-007-RECOVERY-HANDOFF-SUCCESS"
success_focus_posture = "current"
failure_focus = "the planning-exclusion review control and exact source/capacity route failure; the exact trigger Receipt and scope remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-007-RECOVERY-HANDOFF-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: routing and inspection complete without a canonical Event, Projection change, or new Receipt."
rollback_undo = "No Undo is required; dismissal returns to the exact trigger result with canonical state, Receipt, and History unchanged."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-007-RECOVERY-HANDOFF"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The handoff reads only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-008"
label = "Import and reflow"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Any changed source fingerprint invalidates confirmation before commit", "The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The exact reviewed outcome is valid for the selected record class", "The target group and record identities remain present in the reviewed diff"]
destination = "the native import result and reviewed reflow consequence"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-008"
destination_posture = "current"
effect = "The typed Import and reflow command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one native object and its atomic schedule change set are created from the reviewed record"
success_focus = "the committed record result or first failed identity"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-008-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Import and reflow control and exact stale fingerprint, revision, or outcome"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-008-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "Undo Imported Items or the owning typed inverse command reverses the safe local effect while preserving source lineage and History."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-008"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Only separately confirmed calendar effects may reach EventKit; private graph context never leaves Ambitions."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-008-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-008"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-008"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-008-INVERSE"
label = "Undo imported object and reflow"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-008 is the exact trigger command and its exact trigger Receipt is current", "The imported native object, atomic reflow change set, source lineage, capacity revision, and affected schedule dependencies are current"]
destination = "the Time import result with the exact imported object removed from active placement and the pre-import schedule/capacity arrangement restored"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-008-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it moves the exact imported native object out of active placement, reverses only its atomic schedule reflow change set, restores the prior capacity arrangement, appends a reversing Event, updates the Time/import Projection, and creates a new inverse Receipt and History entry while external source data, lineage, the import Receipt, and History remain intact."
success_focus = "the restored pre-import schedule position and capacity summary followed by the inverse Receipt"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-008-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Undo imported object and reflow control and exact unsafe, stale, or dependency-invalid object/reflow reason; the imported placement and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-008-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-008-INVERSE"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-009"
label = "Import into Ambitions"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Any changed source fingerprint invalidates confirmation before commit", "The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The exact reviewed outcome is valid for the selected record class", "The target group and record identities remain present in the reviewed diff"]
destination = "the native import result for the selected external record"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-009"
destination_posture = "current"
effect = "The typed Import into Ambitions command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one native object is created with source lineage and the external source remains unchanged"
success_focus = "the committed record result or first failed identity"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-009-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Import into Ambitions control and exact stale fingerprint, revision, or outcome"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-009-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "Undo Imported Items or the owning typed inverse command reverses the safe local effect while preserving source lineage and History."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-009"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Only separately confirmed calendar effects may reach EventKit; private graph context never leaves Ambitions."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-009-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-009"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-009"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-009-INVERSE"
label = "Undo native import"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-009 is the exact trigger command and its exact trigger Receipt is current", "The imported native object identity, source lineage, owning Time revision, and dependent local relationships are current"]
destination = "the Time import result with the exact native object removed from active projections into its recoverable imported-object lifecycle while source lineage remains inspectable"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-009-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it removes the exact imported native object from active Time projections into its recoverable lifecycle without changing the external source, appends a reversing Event, updates the Time/import Projection, and creates a new inverse Receipt and History entry while source lineage, the import Receipt, and History remain intact."
success_focus = "the import History row showing the native object removed from active Time and its recoverable lineage retained"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-009-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Undo native import control and exact unsafe, stale, or dependency-invalid object/lineage reason; the imported object and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-009-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-009-INVERSE"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-010"
label = "Import with Ambitions notifications"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Any changed source fingerprint invalidates confirmation before commit", "The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The exact reviewed outcome is valid for the selected record class", "The target group and record identities remain present in the reviewed diff"]
destination = "the native import result with Ambitions-owned notification policy"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-010"
destination_posture = "current"
effect = "The typed Import with Ambitions notifications command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one native object is created and its separately owned local notification rule is linked"
success_focus = "the committed record result or first failed identity"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-010-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Import with Ambitions notifications control and exact stale fingerprint, revision, or outcome"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-010-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "Undo Imported Items or the owning typed inverse command reverses the safe local effect while preserving source lineage and History."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-010"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Only separately confirmed calendar effects may reach EventKit; private graph context never leaves Ambitions."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-010-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-010"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-010"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-010-INVERSE"
label = "Undo import and local notification"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-010 is the exact trigger command and its exact trigger Receipt is current", "The imported native object, linked local notification rule, source lineage, owning revisions, and external-request reconciliation state are current"]
destination = "the Time import result with the exact native object removed from active projections and its linked Ambitions notification rule removed from active local policy"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-010-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it removes the exact imported native object from active Time projections and reverses only its linked Ambitions notification-rule policy, appends a reversing Event, updates the Time/import/notification Projection, and creates a new inverse Receipt and History entry while external source data and alerts remain unchanged and any iOS request removal reconciles separately."
success_focus = "the import History row showing the native object and linked local notification policy reversed, followed by reconciliation status"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-010-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Undo import and local notification control and exact unsafe, stale, or dependency-invalid object/rule/request reason; the imported object, rule, and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-010-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-010-INVERSE"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-011"
label = "Import without Ambitions notifications"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Any changed source fingerprint invalidates confirmation before commit", "The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The exact reviewed outcome is valid for the selected record class", "The target group and record identities remain present in the reviewed diff"]
destination = "the native import result without an Ambitions notification rule"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-011"
destination_posture = "current"
effect = "The typed Import without Ambitions notifications command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one native object is created while Ambitions does not own the alert"
success_focus = "the committed record result or first failed identity"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-011-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Import without Ambitions notifications control and exact stale fingerprint, revision, or outcome"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-011-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "Undo Imported Items or the owning typed inverse command reverses the safe local effect while preserving source lineage and History."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-011"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Only separately confirmed calendar effects may reach EventKit; private graph context never leaves Ambitions."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-011-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-011"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-011"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-011-INVERSE"
label = "Undo import without local notification"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-011 is the exact trigger command and its exact trigger Receipt is current", "The imported native object identity, explicit no-Ambitions-alert posture, source lineage, and owning Time revision are current"]
destination = "the Time import result with the exact native object removed from active projections and the external alert-ownership posture still explicit"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-011-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it removes the exact imported native object from active Time projections without creating, changing, or removing any Ambitions notification rule or external alert, appends a reversing Event, updates the Time/import Projection, and creates a new inverse Receipt and History entry while source lineage, the import Receipt, and History remain intact."
success_focus = "the import History row showing the native object reversed and no Ambitions alert policy created"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-011-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Undo import without local notification control and exact unsafe, stale, or dependency-invalid object/lineage reason; the imported object and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-011-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-011-INVERSE"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-012"
label = "Import without reflow"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Any changed source fingerprint invalidates confirmation before commit", "The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The exact reviewed outcome is valid for the selected record class", "The target group and record identities remain present in the reviewed diff"]
destination = "the native import result with the reviewed schedule unchanged"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-012"
destination_posture = "current"
effect = "The typed Import without reflow command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one native object is created without applying a schedule reflow"
success_focus = "the committed record result or first failed identity"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-012-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Import without reflow control and exact stale fingerprint, revision, or outcome"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-012-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "Undo Imported Items or the owning typed inverse command reverses the safe local effect while preserving source lineage and History."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-012"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Only separately confirmed calendar effects may reach EventKit; private graph context never leaves Ambitions."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-012-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-012"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-012"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-012-INVERSE"
label = "Undo import without reflow"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-012 is the exact trigger command and its exact trigger Receipt is current", "The imported native object identity, explicit no-reflow posture, source lineage, and unchanged schedule revision are current"]
destination = "the Time import result with the exact native object removed from active projections and the unchanged pre-import schedule still visible"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-012-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it removes the exact imported native object from active Time projections without applying any schedule reflow, appends a reversing Event, updates the Time/import Projection, and creates a new inverse Receipt and History entry while the unchanged schedule, source lineage, import Receipt, and History remain intact."
success_focus = "the unchanged schedule context followed by the import History row showing the object reversal"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-012-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Undo import without reflow control and exact unsafe, stale, or dependency-invalid object/schedule reason; the imported object and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-012-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-012-INVERSE"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-013"
label = "Keep external"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Any changed source fingerprint invalidates confirmation before commit", "The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The exact reviewed outcome is valid for the selected record class", "The target group and record identities remain present in the reviewed diff"]
destination = "the reviewed diff with source ownership retained"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-013"
destination_posture = "current"
effect = "The typed Keep external command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the record and alert ownership remain external and no native object is created"
success_focus = "the committed record result or first failed identity"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-013-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep external control and exact stale fingerprint, revision, or outcome"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-013-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "The import owner recovery handoff opens a separately authorized correction command; cancellation before commit changes nothing and History preserves the decision."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-013"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Only separately confirmed calendar effects may reach EventKit; private graph context never leaves Ambitions."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "owner_recovery_handoff"
recovery_handoff_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-013-RECOVERY-HANDOFF"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-013"
mechanism_kind = "recovery_handoff_command"
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-013-RECOVERY-HANDOFF"
label = "Review external-ownership decision"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-013 is the exact trigger command and its exact trigger Receipt is current", "The external source identity, external record/alert ownership posture, no-native-object result, and decision Receipt are current"]
destination = "the import decision inspection for the exact externally owned record with its no-native-object result and separately authorized correction route visible"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-013-RECOVERY-HANDOFF"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the exact trigger Receipt and scope route only to journey.calendar-import.command-contract for external-ownership decision inspection, while the record and alert remain external, no native object is created, and the decision Projection, Receipt, and History remain unchanged."
success_focus = "the external record and alert ownership summary followed by the first separately authorized correction action"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-013-RECOVERY-HANDOFF-SUCCESS"
success_focus_posture = "current"
failure_focus = "the external-ownership decision review control and exact source/decision route failure; the exact trigger Receipt and scope remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-013-RECOVERY-HANDOFF-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: routing and inspection complete without a canonical Event, Projection change, or new Receipt."
rollback_undo = "No Undo is required; dismissal returns to the exact trigger result with canonical state, Receipt, and History unchanged."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-013-RECOVERY-HANDOFF"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The handoff reads only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-014"
label = "Keep external but reserve time"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Any changed source fingerprint invalidates confirmation before commit", "The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The exact reviewed outcome is valid for the selected record class", "The target group and record identities remain present in the reviewed diff"]
destination = "the reviewed capacity result for the external record"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-014"
destination_posture = "current"
effect = "The typed Keep external but reserve time command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one local capacity reservation is created without importing or editing the external record"
success_focus = "the committed record result or first failed identity"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-014-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep external but reserve time control and exact stale fingerprint, revision, or outcome"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-014-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "Undo Imported Items or the owning typed inverse command reverses the safe local effect while preserving source lineage and History."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-014"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Only separately confirmed calendar effects may reach EventKit; private graph context never leaves Ambitions."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-014-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-014"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-014"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-014-INVERSE"
label = "Remove capacity reservation"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-014 is the exact trigger command and its exact trigger Receipt is current", "The exact local capacity reservation, source identity, Time revision, and dependent placement calculations are current"]
destination = "the Time import result with the exact local capacity reservation removed and the external record still visible as externally owned"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-014-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it removes the exact local capacity reservation created for the external record without importing, editing, or unlinking that record, appends a reversing Event, updates the Time capacity Projection, and creates a new inverse Receipt and History entry while source identity, the reservation Receipt, and History remain intact."
success_focus = "the restored capacity summary and external record row showing that no local reservation remains"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-014-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Remove capacity reservation control and exact unsafe, stale, or dependency-invalid reservation/placement reason; the reservation and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-014-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-014-INVERSE"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-015"
label = "Link"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Any changed source fingerprint invalidates confirmation before commit", "The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The exact reviewed outcome is valid for the selected record class", "The target group and record identities remain present in the reviewed diff"]
destination = "the linked-source result for the selected record"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-015"
destination_posture = "current"
effect = "The typed Link command appends one Event, updates the owning Projection, records a Receipt, and preserves History; one local source reference is linked without taking ownership of the external record"
success_focus = "the committed record result or first failed identity"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-015-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Link control and exact stale fingerprint, revision, or outcome"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-015-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "Undo Imported Items or the owning typed inverse command reverses the safe local effect while preserving source lineage and History."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-015"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Only separately confirmed calendar effects may reach EventKit; private graph context never leaves Ambitions."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-015-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-015"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-015"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-015-INVERSE"
label = "Unlink source reference"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-015 is the exact trigger command and its exact trigger Receipt is current", "The exact local source-reference link, linked native object revision, external source identity, and lineage dependencies are current"]
destination = "the Time import result with the exact local source-reference link removed while both the native object and external record remain independently intact"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-015-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it removes only the exact local source-reference link without deleting or editing the native object or external record, appends a reversing Event, updates the import lineage Projection, and creates a new inverse Receipt and History entry while both object histories, the link Receipt, and source provenance remain intact."
success_focus = "the unlinked native object and external record identities followed by the new inverse Receipt"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-015-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Unlink source reference control and exact unsafe, stale, or dependency-invalid object/link/lineage reason; the link and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-015-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-015-INVERSE"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-016"
label = "Reject permanently"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Any changed source fingerprint invalidates confirmation before commit", "The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The exact reviewed outcome is valid for the selected record class", "The target group and record identities remain present in the reviewed diff"]
destination = "the reviewed diff with permanent rejection recorded"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-016"
destination_posture = "current"
effect = "The typed Reject permanently command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the exact source identity is rejected from future import proposals without deleting its external record"
success_focus = "the committed record result or first failed identity"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-016-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Reject permanently control and exact stale fingerprint, revision, or outcome"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-016-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "The import owner recovery handoff opens a separately authorized correction command; cancellation before commit changes nothing and History preserves the decision."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-016"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Only separately confirmed calendar effects may reach EventKit; private graph context never leaves Ambitions."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "owner_recovery_handoff"
recovery_handoff_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-016-RECOVERY-HANDOFF"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-016"
mechanism_kind = "recovery_handoff_command"
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-016-RECOVERY-HANDOFF"
label = "Review permanent rejection"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-016 is the exact trigger command and its exact trigger Receipt is current", "The exact rejected source identity, rejection-marker revision, source fingerprint, and decision Receipt are current"]
destination = "the import decision inspection for the exact permanently rejected source identity with the rejection marker, preserved external record, and correction route visible"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-016-RECOVERY-HANDOFF"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the exact trigger Receipt and scope route only to journey.calendar-import.command-contract for rejection-marker inspection, while the external record remains untouched and the exact rejection marker, Projection, Receipt, and History remain unchanged."
success_focus = "the rejected source identity and rejection-marker scope followed by the first separately authorized correction action"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-016-RECOVERY-HANDOFF-SUCCESS"
success_focus_posture = "current"
failure_focus = "the permanent-rejection review control and exact source/marker route failure; the exact trigger Receipt and scope remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-016-RECOVERY-HANDOFF-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: routing and inspection complete without a canonical Event, Projection change, or new Receipt."
rollback_undo = "No Undo is required; dismissal returns to the exact trigger result with canonical state, Receipt, and History unchanged."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-016-RECOVERY-HANDOFF"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The handoff reads only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-017"
label = "Replace"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["Any changed source fingerprint invalidates confirmation before commit", "The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The exact reviewed outcome is valid for the selected record class", "The target group and record identities remain present in the reviewed diff"]
destination = "the replacement preview and native result for the selected record"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-017"
destination_posture = "current"
effect = "The typed Replace command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the reviewed native owner is replaced atomically while lineage and prior History remain inspectable"
success_focus = "the committed record result or first failed identity"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-017-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Replace control and exact stale fingerprint, revision, or outcome"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-017-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "Undo Imported Items or the owning typed inverse command reverses the safe local effect while preserving source lineage and History."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-017"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Only separately confirmed calendar effects may reach EventKit; private graph context never leaves Ambitions."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
rollback_posture = "inverse_command"
inverse_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-017-INVERSE"

[[state_command_contracts.recovery_commands]]
trigger_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-017"
mechanism_kind = "inverse_command"
redo_command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-017"
redo_preconditions = ["current inverse Receipt", "current revision", "fresh command authorization"]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-017-INVERSE"
label = "Restore replaced native owner"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["CMD-TIME-IMPORT-REVIEWING-DIFF-017 is the exact trigger command and its exact trigger Receipt is current", "The prior native owner revision, replacement object revision, source lineage, dependent relationships, and atomic replacement Receipt are current"]
destination = "the Time import result with the prior native owner restored as active and the replacement retained only as inspectable lineage and History"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-017-INVERSE"
destination_posture = "current"
effect = "The command reverses only the exact proven trigger effect: it atomically restores the prior native owner and its relationships, removes the replacement from active ownership without erasing its lineage, appends a reversing Event, updates the Time/import Projection, and creates a new inverse Receipt and History entry while the external source, replacement Receipt, and all prior History remain intact."
success_focus = "the restored prior native owner followed by the replacement lineage and new inverse Receipt"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-017-INVERSE-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Restore replaced native owner control and exact unsafe, stale, or dependency-invalid owner/relationship/lineage reason; the replacement result and exact trigger Receipt remain visible and unchanged"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-017-INVERSE-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Inverse mutation: commit only after the exact trigger Receipt, current revision, dependencies, and absence of a newer dependent command are validated."
rollback_undo = "Redo is a distinct typed command that requires the current inverse Receipt and complete revalidation; this recovery-only record grants no implicit redo authority."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-017-INVERSE"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "The inverse reads and writes only local canonical state and sends no private content off device."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []
gate_dependency_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-018"
label = "Select All in Group"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The target group and record identities remain present in the reviewed diff"]
destination = "the same grouped import diff with every eligible record in the group selected"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-018"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; eligible group selection changes only the local review draft"
success_focus = "the changed selection and its first consequence"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-018-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Select All in Group control and exact stale record or group"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-018-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-018"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Selection remains local; the external calendar receives no write or private Ambitions context."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-TIME-IMPORT-REVIEWING-DIFF-019"
label = "Select Item"
canonical_owner = "journey.calendar-import.command-contract"
preconditions = ["The confirmed source identity, source fingerprint, diff revision, and local revision remain valid", "The target group and record identities remain present in the reviewed diff"]
destination = "the same grouped import diff with the named record selected"
destination_id = "DEST-TIME-IMPORT-REVIEWING-DIFF-019"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; record selection changes only the local review draft"
success_focus = "the changed selection and its first consequence"
success_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-019-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Select Item control and exact stale record or group"
failure_focus_id = "FOCUS-TIME-IMPORT-REVIEWING-DIFF-019-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-TIME-IMPORT-REVIEWING-DIFF-019"
recovery_posture = "current"
recovery_owner = "journey.calendar-import.command-contract"
privacy_egress = "Selection remains local; the external calendar receives no write or private Ambitions context."
verification_ids = ["SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

+++

# External Calendar Import

This journey coordinates reviewed import; Event and Import/Diff Record owners retain identity, recurrence, decision, and lifecycle law.

## JOURNEY-CALENDAR-DIFF-001 — External facts never silently mutate native Time

- **Concept:** `journey.calendar-diff.no-silent-mutation`
- **Modality:** `MUST`
- **Scope:** Discovery, diff, import, link, keep-external, ignore, and reconciliation
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-CALENDAR-DIFF-001`
- **Supersedes:** none

An external calendar adapter MUST supply facts to typed discovery/refresh commands, never mutate state itself. Discovery and refresh are durable local commits of the Import/Diff Record, source lineage, unreviewed state, and badge contribution with Receipt/replay; that commit creates no Ambitions Event and reserves no planning capacity until an explicit review outcome. `Import into Ambitions`, Link, Replace, `Keep external but reserve time`, `Ignore for planning`, and `Reject permanently` remain non-durable outcome previews until confirmed.

Ambitions MUST NOT silently import, mutate, or reflow when the user adds or changes items in Apple Calendar.

Imported or replaced Ambitions-owned objects MUST NOT mutate silently when Apple Calendar changes.

Time MUST NOT show persistent source markers for imported native objects.

Rejected or ignored external calendar items MUST be dismissed and MUST NOT continue contributing to the badge count.

Pending external-import review MUST appear as a small actionable control in the Time header or toolbar with the unreviewed-item count.

An external calendar change MUST NOT commit silently.

Apple Calendar and other approved calendar sources MUST be onboarding, migration, and external-change sources.

Import MUST create an Ambitions-owned object with provenance and a Receipt.

An external calendar change MUST NOT silently mutate an Ambitions-owned object.

An External Calendar Candidate MUST be an external item awaiting user review.

## JOURNEY-CALENDAR-DIFF-GROUPING-001 — Pending review is grouped by schedule impact
- **Concept:** `journey.calendar-diff.grouping`
- **Modality:** `MUST`
- **Scope:** External calendar diff review
- **Status:** `normative`
- **Verification:** `SCENARIO-CALENDAR-DIFF-GROUPING-001`
- **Supersedes:** none

External diff review MUST group pending items as Needs attention, Safe to import, Duplicate or link candidates, Removed source, or Ignored history so schedule consequence outranks raw chronology or source administration.

## JOURNEY-CALENDAR-CONFLICT-CHOICE-001 — Import conflicts are chosen before commit
- **Concept:** `journey.calendar-diff.conflict-choice`
- **Modality:** `MUST`
- **Scope:** Selected external item conflicting with Ambitions Time
- **Status:** `normative`
- **Verification:** `SCENARIO-CALENDAR-IMPORT-CONFLICT-001`
- **Supersedes:** none

Before import commit, Ambitions MUST show affected objects, available reflow, and consequences and let the user choose Import and reflow, Import without reflow, Keep external, Ignore, or Edit before import. Import never silently triggers reflow.

An External Calendar Candidate MUST NOT appear as an Ambitions Event before import.

## JOURNEY-CALENDAR-NOTIFICATION-HANDOFF-001 — Import never silently duplicates alerts
- **Concept:** `journey.calendar-diff.notification-handoff`
- **Modality:** `MUST NOT`
- **Scope:** External alerts and Ambitions Notification Rules during import
- **Status:** `normative`
- **Verification:** `SCENARIO-CALENDAR-NOTIFICATION-HANDOFF-001`
- **Supersedes:** none

Import MUST NOT silently alter Apple Calendar alerts or create duplicate notifications. Review shows existing alerts, proposed Ambitions rules, and duplication risk and offers Import with Ambitions notifications, Import without them, Edit notification rules, or Keep external.

Imported Apple Calendar alerts MUST become Ambitions-native notification settings on the imported Event.

During import review, Ambitions MUST show existing external alerts, the Ambitions-native notification rules that will be created, and any duplicate-notification risk.

Calendar notification handoff MUST offer Import with Ambitions notifications, Import without Ambitions notifications, Edit notification rules, and Keep external.

<!-- canon-section: trigger-starting-state -->
Triggers are permission-approved source scan, manual import, changed external fingerprint, Time review, or reconciliation notice; starting state identifies source, privacy-filtered fact, fingerprint, prior decision, native link, diff, recurrence range, capacity effect, permission, and freshness.

<!-- canon-section: preconditions -->
Permission is contextual and current; minimum necessary source facts can be read; stable fingerprinting and local review storage are available. Permission denial and offline use preserve Ambitions-owned Time.

<!-- canon-section: happy-path -->
Read source facts through the adapter, validate a typed discovery or refresh command, durably create/update the Import/Diff Record, source lineage, unreviewed state, and badge contribution, and issue its Receipt/replay without creating an Ambitions Event or reserving capacity. Then present privacy-safe differences and every exact reviewed outcome; preview native-object, capacity, decision-lineage, badge, and external consequences independently; confirm range/destination where applicable; commit the review decision locally with a separate Receipt/history; and only then perform any external write. `Import into Ambitions` alone creates the selected canonical native object; Replace preserves one existing canonical identity, and Link retains external authority without creating a second canonical Event.

<!-- canon-section: branches -->
Each reviewed decision stores source fingerprint, exact decision label, native-object effect, capacity effect, lineage effect, and badge effect as separate facts.
Branches are `Import into Ambitions`, Replace, Link, `Keep external but reserve time`, `Ignore for planning`, `Reject permanently`, select occurrence/future/series/range, redact optional fields, or revoke permission. `Import into Ambitions` creates a native object with provenance and removes its candidate from the unreviewed badge. `Keep external but reserve time` creates no native Event UI/object, keeps external authority, reserves planning capacity, records the reviewed decision/source mapping, and removes its badge contribution. `Ignore for planning` creates no native object, reserves no capacity, retains ignored-history lineage, and removes its badge contribution. `Reject permanently` creates no native object or capacity reservation, stores dismissal lineage, removes its badge contribution, and suppresses that candidate lineage unless a materially new external item appears.

<!-- canon-section: cancellation -->
A canceled pre-discovery preview commits no Import/Diff Record, source lineage, or badge contribution. Once discovery/refresh commits, canceling or dismissing review preserves the durable Import/Diff Record, source lineage, unreviewed badge contribution, zero native-object creation, and zero capacity effect. Canceling an outcome preview creates no reviewed decision or native object; permission revocation stops reads without deleting accepted local records or rewriting prior decisions.

<!-- canon-section: interruption-resume -->
Resume discovery/refresh from the durable Import/Diff Record, source lineage, unreviewed state, badge contribution, and discovery Receipt/replay, with no implied Event or capacity reservation. Resume review from that durable base plus any prior decision, field selection, range, capacity choice, dismissal/ignored lineage, badge state, and focus. A changed source fingerprint commits a refresh lineage before invalidating outcome confirmation; a permanently rejected lineage returns only for a materially new external item.

<!-- canon-section: commit-boundary -->
Two command IDs separate discovery acceptance from review-outcome acceptance, and each resolves its own Receipt/replay chain.
The discovery command validates candidate/source identity and diff facts before durably committing the Import/Diff Record, source lineage, unreviewed state, badge contribution, Receipt, and replay. It commits no Ambitions Event and no capacity reservation. Any pre-discovery preview is non-durable. After discovery, field selection, consequence preview, and outcome selection remain non-durable as reviewed-decision, native-object, or capacity state while retaining the durable unreviewed lineage/badge base. Import/Replace/Link or one of the three exact external-only decisions crosses a second boundary only after current validation, confirmation, local decision commit, projection, and Receipt; writeback follows after that local commit.

<!-- canon-section: failure -->
The failure record retains candidate/source/native IDs, discovery/refresh commit result, prior review decision, capacity reservation, source/decision lineage, badge state, and external result.
Failure before discovery commit creates no review record or badge. Failure after a durable discovery/refresh commit preserves its Import/Diff Record, source lineage, unreviewed badge, zero native-object/capacity effect, and Receipt/replay. Recurrence ambiguity, invalid outcome, review rejection, partial import, or external-write failure preserves the last committed review/native/capacity/lineage/badge truth and states exactly what remains local, external, pending, or failed.

<!-- canon-section: recovery -->
Offer reauthorize before discovery, retry discovery idempotently, refresh the durable diff/source lineage, resume review with the unreviewed badge intact, choose fewer fields/range, Link instead, choose one exact external-only outcome, reconcile local/external divergence, or restore the prior native mapping/decision from history. Recovery never erases a committed discovery lineage or converts discovery alone into native-object/capacity state.

<!-- canon-section: undo-rollback -->
Every supported reversal records the prior and restored native-object, capacity, lineage, and badge facts under the same candidate/source identifiers.
Undo an Import/Link/Replace or reversible reviewed decision through canonical commands and retain the review record, source lineage, capacity history, badge history, and Receipt. Permanent rejection follows its declared dismissal lineage rather than a generic Undo promise; external reversal is separately queued/reconciled, and source deletion never silently deletes a native Event.

<!-- canon-section: receipts-proof -->
Discovery/refresh Receipts and History Events bind the Import/Diff Record, source fingerprint/lineage, unreviewed state, badge contribution, zero native-object creation, and zero capacity reservation. Separate review-decision Receipts/history record the exact outcome, native-object creation or noncreation, capacity reservation or nonreservation, dismissal/ignored lineage, badge removal, field/range scope, privacy selection, external dispatch/result, reconciliation, and undo. An Import/Diff Record or source fact is not user Proof.

<!-- canon-section: accessibility -->
Semantics expose source summary at approved privacy level, changed fields and prior/new values, range, native-object consequence, capacity reservation, dismissal lineage, badge consequence, destination, external effects, exact choice labels, and applicable recovery without side-by-side or color dependence; focus returns to the record/native object and Dynamic Type stacks diffs.

<!-- canon-section: offline -->
Ambitions-owned Time and previously committed Import/Diff Records, source lineage, unreviewed badges, review decisions, native facts, capacity reservations, ignored history, dismissal lineage, Receipts, and replay remain usable offline. New source reads/writes wait; offline review of stored facts preserves the discovery-versus-outcome boundaries and never converts stale external facts into native Events or uploads private context.

<!-- canon-section: scenario-tests -->
Execute `SCENARIO-JOURNEY-CALENDAR-DISCOVERY-COMMIT-001`, `SCENARIO-JOURNEY-CALENDAR-REFRESH-COMMIT-001`, `SCENARIO-JOURNEY-CALENDAR-PREDISCOVERY-CANCEL-001`, `SCENARIO-JOURNEY-CALENDAR-REVIEW-DISMISS-001`, `SCENARIO-JOURNEY-CALENDAR-IMPORT-NATIVE-001`, `SCENARIO-JOURNEY-CALENDAR-KEEP-EXTERNAL-RESERVE-001`, `SCENARIO-JOURNEY-CALENDAR-IGNORE-PLANNING-001`, `SCENARIO-JOURNEY-CALENDAR-REJECT-PERMANENTLY-001`, `SCENARIO-JOURNEY-CALENDAR-RECURRENCE-001`, `SCENARIO-JOURNEY-CALENDAR-PERMISSION-001`, `SCENARIO-JOURNEY-CALENDAR-EXTERNAL-FAILURE-001`, and `SCENARIO-JOURNEY-CALENDAR-UNDO-001`; independently assert discovery/refresh durable Record/source-lineage/unreviewed-badge Receipt/replay, no Event or capacity from discovery alone, pre-discovery preview non-durability, review dismissal preservation, each outcome's native/capacity/lineage/badge effects, materially-new-item reappearance, adapter non-mutation, stable IDs, local-before-external ordering, offline safety, and accessible diff review.



## JOURNEY-CALENDAR-INVITE-DIFF-001 — Imported invite diff review

- **Concept:** `journey.calendar-invite-diff`
- **Modality:** `MUST NOT`
- **Scope:** Imported invite diff review
- **Status:** `normative`
- **Verification:** `REVIEW-JOURNEY-CALENDAR-INVITE-DIFF-001`
- **Supersedes:** none

Imported invite Events MUST preserve attendee, organizer, RSVP, location, notes, and source metadata; later changes MUST enter external diff review with explicit accept, keep, split, unlink, or ignore choices and MUST NOT silently mutate native truth.

## JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001 — Calendar import commands preserve atomic reviewed outcomes

- **Concept:** `journey.calendar-import.command-contract`
- **Modality:** `MUST`
- **Scope:** External-calendar grouping, selection, outcome review, per-record commit, deterministic partial recovery, external-write separation, semantic Undo, freshness, focus, offline use, privacy, and accessibility
- **Status:** `normative`
- **Verification:** `SCENARIO-CALENDAR-IMPORT-COMMAND-CONTRACT-001`
- **Supersedes:** none

External review MUST preserve the existing groups exactly:

- Needs attention
- Safe to import
- Duplicate or link candidates
- Removed source
- Ignored history

Selection commands are `Select Item`, `Select All in Group`, `Clear Selection`, `Review Selected`, and `Done`. Review outcomes remain the existing canonical choices:

- `Import into Ambitions`
- `Replace`
- `Link`
- `Keep external but reserve time`
- `Ignore for planning`
- `Reject permanently`
- For conflicts: `Import and reflow`, `Import without reflow`, `Keep external`, `Ignore`, `Edit before import`
- For alert handoff: `Import with Ambitions notifications`, `Import without Ambitions notifications`, `Edit notification rules`, `Keep external`

`Import Selected` may appear only for Safe to import records whose outcome is unambiguous. Every other selected record requires an explicit outcome before commit.

Each Import/Diff Record outcome is one atomic command covering native-object effect, capacity effect, lineage, badge contribution, and Receipt. A multi-record batch is a deterministic ordered collection of these atomic commands. Partial results may occur only between record boundaries, never within one record. Completed and failed record IDs remain explicit; `Retry Failed Items` retries only failed identities and cannot duplicate completed imports.

Any changed source fingerprint invalidates confirmation and returns to review. Selection and preview never alter the external source. External writeback requires a separate confirmation and external-effect Receipt.

`Undo Imported Items` is available only while a deterministic inverse remains safe. Eligibility is semantic, not an arbitrary timer. If later dependencies, irreversible external effects, permanent deletion, or provenance mismatch make direct Undo unsafe, `Undo Unavailable` MUST state the reason and route to owner detail, Trash/restore, or reconciliation. A temporary snackbar may disappear only if a durable recovery route remains.


Entry focuses the first group needing attention. Preview focuses the first consequence. Result focuses the first failed record or batch Receipt. Retry and Undo focus their exact result. Diffs stack under Dynamic Type and communicate prior/new values and consequence without color dependence.

## JOURNEY-CALENDAR-IMPORT-COMMIT-001 — Calendar import commit

- **Concept:** `journey.calendar-import.commit`
- **Modality:** `MUST`
- **Scope:** Accepted import decisions
- **Status:** `normative`
- **Verification:** `SCENARIO-CALENDAR-IMPORT-COMMIT-001`
- **Supersedes:** none

An accepted calendar import MUST validate the selected diff, commit local canonical state atomically, preserve source lineage, and issue Receipt and History evidence.

## JOURNEY-CALENDAR-CANDIDATE-001 — Calendar import candidate

- **Concept:** `journey.calendar-import.candidate`
- **Modality:** `MUST`
- **Scope:** Unreviewed imported records
- **Status:** `normative`
- **Verification:** `SCENARIO-CALENDAR-CANDIDATE-001`
- **Supersedes:** none

An unreviewed imported record MUST remain a candidate and MUST NOT silently become an Ambitions Event, reserve canonical capacity, or authorize outbound mutation.
