+++
spec_id = "SYSTEM-SYNC-CONTINUITY"
title = "Sync and Continuity"
kind = "system"
status = "normative"
owner_domain = "system-sync-continuity"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "system.continuity.command-contract",
  "system.continuity.conflict",
  "system.continuity.control-center",
  "system.continuity.disabled-gate",
  "system.continuity.environment",
  "system.continuity.failure",
  "system.continuity.record-identity",
  "system.continuity.restore",
  "system.continuity.user-owned-cloudkit",
]
inherits = ["LAW-LOCAL-AUTHORITY-001", "LAW-OFFLINE-NO-ACCOUNT-001", "LAW-ACCOUNT-BOUNDARY-001", "PRIVACY-CLOUDKIT-CONTINUITY-001", "LAW-DATA-LOSS-STOP-SHIP-001"]
depends_on = ["CONSTITUTION", "SYSTEM-PRIVATE-LIFE-RUNTIME", "SYSTEM-PERSISTENCE-REPLAY", "SYSTEM-PRIVACY-DATA-CLASSIFICATION", "SURFACE-YOU"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/Continuity/", "Native/Ambitions/Core/LocalRuntimeOS/Boundary/", "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/You/", "Native/Ambitions/Quality/"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-BLOCKED"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review Continuity Status => destination: the nonmutating continuity gate and local-authority explanation from Continuity control — Blocked; effect: No durable mutation occurs and no Receipt is created; Review Continuity Status exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Optional continuity cannot proceed until the named safety condition is resolved; local work continues.; focus: the Review Continuity Status gate, preview, or result heading in Continuity control — Blocked."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Review Continuity Status: No durable mutation occurs and no Receipt is created; Review Continuity Status exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Optional continuity cannot proceed until the named safety condition is resolved; local work continues. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: Optional continuity cannot proceed until the named safety condition is resolved; local work continues."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Review Continuity Status: No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity. Local truth and both conflicting alternatives remain protected. Recovery preserves: Optional continuity cannot proceed until the named safety condition is resolved; local work continues."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: Optional continuity cannot proceed until the named safety condition is resolved; local work continues."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Review Continuity Status announces gate and local-authority consequence; success focuses the Review Continuity Status gate, preview, or result heading in Continuity control — Blocked; rejection focuses the Review Continuity Status control and exact failed gate, field, or causal identity in Continuity control — Blocked. Dynamic Type stacks comparisons. The announcement first communicates: Optional continuity cannot proceed until the named safety condition is resolved; local work continues."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-BLOCKED-001"
label = "Review Continuity Status"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the nonmutating continuity gate and local-authority explanation from Continuity control — Blocked"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-BLOCKED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Continuity Status exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Optional continuity cannot proceed until the named safety condition is resolved; local work continues."
success_focus = "the Review Continuity Status gate, preview, or result heading in Continuity control — Blocked"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-BLOCKED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Continuity Status control and exact failed gate, field, or causal identity in Continuity control — Blocked"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-BLOCKED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: gate, conflict, migration, or restore review remains before every canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-BLOCKED-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review Conflict => destination: the quarantined two-sided conflict dry run from Continuity control — Conflicted Quarantined; effect: No durable mutation occurs and no Receipt is created; Review Conflict exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Conflicting continuity copies are protected. Information saved on this device remains unchanged.; focus: the Review Conflict gate, preview, or result heading in Continuity control — Conflicted Quarantined.\nKeep Other Copy => destination: the conflict result preserving the reviewed other copy; effect: The typed Keep Other Copy command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the reviewed other copy becomes the accepted local projection without deleting either quarantined alternative; focus: the resolved conflict result and preserved alternatives.\nKeep This Device => destination: the conflict result preserving this device’s reviewed copy; effect: The typed Keep This Device command appends one Event, updates the owning Projection, records a Receipt, and preserves History; this device’s reviewed copy remains local authority without deleting the quarantined alternative; focus: the resolved conflict result and preserved alternatives.\nMerge Selected Changes => destination: the reviewed field-by-field merge result; effect: The typed Merge Selected Changes command appends one Event, updates the owning Projection, records a Receipt, and preserves History; only the explicitly selected changes become the accepted local projection and all alternatives remain receipted; focus: the resolved conflict result and preserved alternatives."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Review Conflict: No durable mutation occurs and no Receipt is created; Review Conflict exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Conflicting continuity copies are protected. Information saved on this device remains unchanged. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: Conflicting continuity copies are protected. Information saved on this device remains unchanged."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Review Conflict: No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity. Local truth and both conflicting alternatives remain protected. Recovery preserves: Conflicting continuity copies are protected. Information saved on this device remains unchanged."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: Conflicting continuity copies are protected. Information saved on this device remains unchanged."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Review Conflict announces gate and local-authority consequence; success focuses the Review Conflict gate, preview, or result heading in Continuity control — Conflicted Quarantined; rejection focuses the Review Conflict control and exact failed gate, field, or causal identity in Continuity control — Conflicted Quarantined. Dynamic Type stacks comparisons. The announcement first communicates: Conflicting continuity copies are protected. Information saved on this device remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-001"
label = "Review Conflict"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the quarantined two-sided conflict dry run from Continuity control — Conflicted Quarantined"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Conflict exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Conflicting continuity copies are protected. Information saved on this device remains unchanged."
success_focus = "the Review Conflict gate, preview, or result heading in Continuity control — Conflicted Quarantined"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Conflict control and exact failed gate, field, or causal identity in Continuity control — Conflicted Quarantined"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: gate, conflict, migration, or restore review remains before every canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-002"
label = "Keep Other Copy"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A current verified backup, dry run, rollback checkpoint, and duplicate-prevention proof exist", "Current explicit consent is present", "Eligible iCloud state and privacy/security gate are verified", "Local source authority, stable schema, and causal identity are verified", "Silent last-writer-wins is forbidden", "The human-readable conflict dry run and exact selected revision are confirmed"]
destination = "the conflict result preserving the reviewed other copy"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-002"
destination_posture = "current"
effect = "The typed Keep Other Copy command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the reviewed other copy becomes the accepted local projection without deleting either quarantined alternative"
success_focus = "the resolved conflict result and preserved alternatives"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep Other Copy control and first stale causal identity or selected field"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "The verified rollback checkpoint restores the pre-resolution local projection through a typed restore command while History retains both outcomes."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-002"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Only user-owned encrypted continuity transport may carry approved records after the full gate; no server profiling or Ambitions backend ownership is introduced."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
rollback_posture = "checkpoint_restore"
checkpoint_id = "CHECKPOINT-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-002"

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-003"
label = "Keep This Device"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A current verified backup, dry run, rollback checkpoint, and duplicate-prevention proof exist", "Current explicit consent is present", "Eligible iCloud state and privacy/security gate are verified", "Local source authority, stable schema, and causal identity are verified", "Silent last-writer-wins is forbidden", "The human-readable conflict dry run and exact selected revision are confirmed"]
destination = "the conflict result preserving this device’s reviewed copy"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-003"
destination_posture = "current"
effect = "The typed Keep This Device command appends one Event, updates the owning Projection, records a Receipt, and preserves History; this device’s reviewed copy remains local authority without deleting the quarantined alternative"
success_focus = "the resolved conflict result and preserved alternatives"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Keep This Device control and first stale causal identity or selected field"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "The verified rollback checkpoint restores the pre-resolution local projection through a typed restore command while History retains both outcomes."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-003"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Only user-owned encrypted continuity transport may carry approved records after the full gate; no server profiling or Ambitions backend ownership is introduced."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
rollback_posture = "checkpoint_restore"
checkpoint_id = "CHECKPOINT-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-003"

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-004"
label = "Merge Selected Changes"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A current verified backup, dry run, rollback checkpoint, and duplicate-prevention proof exist", "Current explicit consent is present", "Eligible iCloud state and privacy/security gate are verified", "Local source authority, stable schema, and causal identity are verified", "Silent last-writer-wins is forbidden", "The human-readable conflict dry run and exact selected revision are confirmed"]
destination = "the reviewed field-by-field merge result"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-004"
destination_posture = "current"
effect = "The typed Merge Selected Changes command appends one Event, updates the owning Projection, records a Receipt, and preserves History; only the explicitly selected changes become the accepted local projection and all alternatives remain receipted"
success_focus = "the resolved conflict result and preserved alternatives"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-004-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Merge Selected Changes control and first stale causal identity or selected field"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-004-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "The verified rollback checkpoint restores the pre-resolution local projection through a typed restore command while History retains both outcomes."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-004"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Only user-owned encrypted continuity transport may carry approved records after the full gate; no server profiling or Ambitions backend ownership is introduced."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
rollback_posture = "checkpoint_restore"
checkpoint_id = "CHECKPOINT-YOU-CONTINUITY-CONTROL-CONFLICTED-QUARANTINED-004"

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-DISABLED"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Continuity Status => destination: the nonmutating continuity gate and local-authority explanation from Continuity control — Disabled; effect: No durable mutation occurs and no Receipt is created; Review Continuity Status exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Optional continuity is off. All private life information remains local to this device.; focus: the Review Continuity Status gate, preview, or result heading in Continuity control — Disabled."
durable_effect = "This is the sole active disabled explanation and authorizes no continuity operation. Exact continuity consequence: Review Continuity Status: No durable mutation occurs and no Receipt is created; Review Continuity Status exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Optional continuity is off. All private life information remains local to this device. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: Optional continuity is off. All private life information remains local to this device."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Review Continuity Status: No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity. Local truth and both conflicting alternatives remain protected. Recovery preserves: Optional continuity is off. All private life information remains local to this device."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: Optional continuity is off. All private life information remains local to this device."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Review Continuity Status announces gate and local-authority consequence; success focuses the Review Continuity Status gate, preview, or result heading in Continuity control — Disabled; rejection focuses the Review Continuity Status control and exact failed gate, field, or causal identity in Continuity control — Disabled. Dynamic Type stacks comparisons. The announcement first communicates: Optional continuity is off. All private life information remains local to this device."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-DISABLED-001"
label = "Review Continuity Status"
canonical_owner = "system.continuity.command-contract"
preconditions = ["Current conjunctive continuity-gate failures and disabled posture have been revalidated", "Local source authority remains readable, mutable, replayable, and primary offline"]
destination = "the nonmutating continuity gate and local-authority explanation from Continuity control — Disabled"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-DISABLED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Continuity Status exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Optional continuity is off. All private life information remains local to this device."
success_focus = "the Review Continuity Status gate, preview, or result heading in Continuity control — Disabled"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-DISABLED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Continuity Status control and exact failed gate, field, or causal identity in Continuity control — Disabled"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-DISABLED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: gate, conflict, migration, or restore review remains before every canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-DISABLED-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-ELIGIBLE-NOT-ENABLED"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Enable Continuity => destination: the consented continuity enablement result after the full gate from Continuity control — Eligible Not Enabled; effect: A typed Enable Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry before any separately reconciled transport. Local source authority remains primary, and no upload is authorized by this future-gated contract today. Visible evidence remains: This account and device can support optional continuity, which is currently off. All saved information remains on this device.; focus: the Enable Continuity gate, preview, or result heading in Continuity control — Eligible Not Enabled."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Enable Continuity: A typed Enable Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry before any separately reconciled transport. Local source authority remains primary, and no upload is authorized by this future-gated contract today. Visible evidence remains: This account and device can support optional continuity, which is currently off. All saved information remains on this device. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: This account and device can support optional continuity, which is currently off. All saved information remains on this device."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Enable Continuity: Before commit, cancellation changes nothing; after a future commit, Turn Off is a separate typed command, remote deletion remains separate, and rollback restores the verified local checkpoint. Local truth and both conflicting alternatives remain protected. Recovery preserves: This account and device can support optional continuity, which is currently off. All saved information remains on this device."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: This account and device can support optional continuity, which is currently off. All saved information remains on this device."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Enable Continuity announces gate and local-authority consequence; success focuses the Enable Continuity gate, preview, or result heading in Continuity control — Eligible Not Enabled; rejection focuses the Enable Continuity control and exact failed gate, field, or causal identity in Continuity control — Eligible Not Enabled. Dynamic Type stacks comparisons. The announcement first communicates: This account and device can support optional continuity, which is currently off. All saved information remains on this device."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-ELIGIBLE-NOT-ENABLED-001"
label = "Enable Continuity"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the consented continuity enablement result after the full gate from Continuity control — Eligible Not Enabled"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-ELIGIBLE-NOT-ENABLED-001"
destination_posture = "current"
effect = "A typed Enable Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry before any separately reconciled transport. Local source authority remains primary, and no upload is authorized by this future-gated contract today. Visible evidence remains: This account and device can support optional continuity, which is currently off. All saved information remains on this device."
success_focus = "the Enable Continuity gate, preview, or result heading in Continuity control — Eligible Not Enabled"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-ELIGIBLE-NOT-ENABLED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Enable Continuity control and exact failed gate, field, or causal identity in Continuity control — Eligible Not Enabled"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-ELIGIBLE-NOT-ENABLED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: future enablement may commit only through Event, Projection, Receipt, History, and replay-safe local ownership after explicit consent and the complete gate."
rollback_undo = "Before commit, cancellation changes nothing; after a future commit, Turn Off is a separate typed command, remote deletion remains separate, and rollback restores the verified local checkpoint."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-ELIGIBLE-NOT-ENABLED-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
rollback_posture = "checkpoint_restore"
checkpoint_id = "CHECKPOINT-YOU-CONTINUITY-CONTROL-ELIGIBLE-NOT-ENABLED-001"

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-ENABLED-IDLE"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Turn Off Continuity => destination: the locally committed Turn Off Continuity status after full-gate revalidation from Continuity control — Enabled Idle; effect: A typed Turn Off Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry without deleting local or remote records. Transport reconciles separately, local source authority remains primary, and this future-gated contract authorizes no present action. Visible evidence remains: Continuity is on and up to date. This device has no changes waiting to be shared.; focus: the Turn Off Continuity gate, preview, or result heading in Continuity control — Enabled Idle."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Turn Off Continuity: A typed Turn Off Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry without deleting local or remote records. Transport reconciles separately, local source authority remains primary, and this future-gated contract authorizes no present action. Visible evidence remains: Continuity is on and up to date. This device has no changes waiting to be shared. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: Continuity is on and up to date. This device has no changes waiting to be shared."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Turn Off Continuity: Before commit, cancellation changes nothing; after a future commit, inverse control is separately typed and verified, while remote deletion is never implied. Local truth and both conflicting alternatives remain protected. Recovery preserves: Continuity is on and up to date. This device has no changes waiting to be shared."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: Continuity is on and up to date. This device has no changes waiting to be shared."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Turn Off Continuity announces gate and local-authority consequence; success focuses the Turn Off Continuity gate, preview, or result heading in Continuity control — Enabled Idle; rejection focuses the Turn Off Continuity control and exact failed gate, field, or causal identity in Continuity control — Enabled Idle. Dynamic Type stacks comparisons. The announcement first communicates: Continuity is on and up to date. This device has no changes waiting to be shared."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-ENABLED-IDLE-001"
label = "Turn Off Continuity"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the locally committed Turn Off Continuity status after full-gate revalidation from Continuity control — Enabled Idle"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-ENABLED-IDLE-001"
destination_posture = "current"
effect = "A typed Turn Off Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry without deleting local or remote records. Transport reconciles separately, local source authority remains primary, and this future-gated contract authorizes no present action. Visible evidence remains: Continuity is on and up to date. This device has no changes waiting to be shared."
success_focus = "the Turn Off Continuity gate, preview, or result heading in Continuity control — Enabled Idle"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-ENABLED-IDLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Turn Off Continuity control and exact failed gate, field, or causal identity in Continuity control — Enabled Idle"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-ENABLED-IDLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: future Turn Off Continuity may commit only through Event, Projection, Receipt, History, and replay-safe local ownership after the complete gate."
rollback_undo = "Before commit, cancellation changes nothing; after a future commit, inverse control is separately typed and verified, while remote deletion is never implied."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-ENABLED-IDLE-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
rollback_posture = "inverse_command"
inverse_command_id = "CMD-YOU-CONTINUITY-CONTROL-ENABLED-IDLE-001-INVERSE"

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-INELIGIBLE"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review Continuity Status => destination: the nonmutating continuity gate and local-authority explanation from Continuity control — Ineligible; effect: No durable mutation occurs and no Receipt is created; Review Continuity Status exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Optional continuity is unavailable for this account or device. Saved information remains on this device.; focus: the Review Continuity Status gate, preview, or result heading in Continuity control — Ineligible."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Review Continuity Status: No durable mutation occurs and no Receipt is created; Review Continuity Status exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Optional continuity is unavailable for this account or device. Saved information remains on this device. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: Optional continuity is unavailable for this account or device. Saved information remains on this device."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Review Continuity Status: No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity. Local truth and both conflicting alternatives remain protected. Recovery preserves: Optional continuity is unavailable for this account or device. Saved information remains on this device."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: Optional continuity is unavailable for this account or device. Saved information remains on this device."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Review Continuity Status announces gate and local-authority consequence; success focuses the Review Continuity Status gate, preview, or result heading in Continuity control — Ineligible; rejection focuses the Review Continuity Status control and exact failed gate, field, or causal identity in Continuity control — Ineligible. Dynamic Type stacks comparisons. The announcement first communicates: Optional continuity is unavailable for this account or device. Saved information remains on this device."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-INELIGIBLE-001"
label = "Review Continuity Status"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the nonmutating continuity gate and local-authority explanation from Continuity control — Ineligible"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-INELIGIBLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Continuity Status exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Optional continuity is unavailable for this account or device. Saved information remains on this device."
success_focus = "the Review Continuity Status gate, preview, or result heading in Continuity control — Ineligible"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-INELIGIBLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Continuity Status control and exact failed gate, field, or causal identity in Continuity control — Ineligible"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-INELIGIBLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: gate, conflict, migration, or restore review remains before every canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-INELIGIBLE-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-LOCAL-PENDING"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Pause Continuity => destination: the locally committed Pause Continuity status after full-gate revalidation from Continuity control — Local Pending; effect: A typed Pause Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry without deleting local or remote records. Transport reconciles separately, local source authority remains primary, and this future-gated contract authorizes no present action. Visible evidence remains: A local continuity change is waiting to be prepared; local information remains current.; focus: the Pause Continuity gate, preview, or result heading in Continuity control — Local Pending."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Pause Continuity: A typed Pause Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry without deleting local or remote records. Transport reconciles separately, local source authority remains primary, and this future-gated contract authorizes no present action. Visible evidence remains: A local continuity change is waiting to be prepared; local information remains current. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: A local continuity change is waiting to be prepared; local information remains current."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Pause Continuity: Before commit, cancellation changes nothing; after a future commit, inverse control is separately typed and verified, while remote deletion is never implied. Local truth and both conflicting alternatives remain protected. Recovery preserves: A local continuity change is waiting to be prepared; local information remains current."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: A local continuity change is waiting to be prepared; local information remains current."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Pause Continuity announces gate and local-authority consequence; success focuses the Pause Continuity gate, preview, or result heading in Continuity control — Local Pending; rejection focuses the Pause Continuity control and exact failed gate, field, or causal identity in Continuity control — Local Pending. Dynamic Type stacks comparisons. The announcement first communicates: A local continuity change is waiting to be prepared; local information remains current."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-LOCAL-PENDING-001"
label = "Pause Continuity"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the locally committed Pause Continuity status after full-gate revalidation from Continuity control — Local Pending"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-LOCAL-PENDING-001"
destination_posture = "current"
effect = "A typed Pause Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry without deleting local or remote records. Transport reconciles separately, local source authority remains primary, and this future-gated contract authorizes no present action. Visible evidence remains: A local continuity change is waiting to be prepared; local information remains current."
success_focus = "the Pause Continuity gate, preview, or result heading in Continuity control — Local Pending"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-LOCAL-PENDING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Pause Continuity control and exact failed gate, field, or causal identity in Continuity control — Local Pending"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-LOCAL-PENDING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: future Pause Continuity may commit only through Event, Projection, Receipt, History, and replay-safe local ownership after the complete gate."
rollback_undo = "Before commit, cancellation changes nothing; after a future commit, inverse control is separately typed and verified, while remote deletion is never implied."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-LOCAL-PENDING-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
rollback_posture = "inverse_command"
inverse_command_id = "CMD-YOU-CONTINUITY-CONTROL-LOCAL-PENDING-001-INVERSE"

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-MERGING"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review Conflict => destination: the quarantined two-sided conflict dry run from Continuity control — Merging; effect: No durable mutation occurs and no Receipt is created; Review Conflict exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Local and optional continuity copies are being compared; neither silently replaces the other.; focus: the Review Conflict gate, preview, or result heading in Continuity control — Merging."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Review Conflict: No durable mutation occurs and no Receipt is created; Review Conflict exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Local and optional continuity copies are being compared; neither silently replaces the other. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: Local and optional continuity copies are being compared; neither silently replaces the other."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Review Conflict: No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity. Local truth and both conflicting alternatives remain protected. Recovery preserves: Local and optional continuity copies are being compared; neither silently replaces the other."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: Local and optional continuity copies are being compared; neither silently replaces the other."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Review Conflict announces gate and local-authority consequence; success focuses the Review Conflict gate, preview, or result heading in Continuity control — Merging; rejection focuses the Review Conflict control and exact failed gate, field, or causal identity in Continuity control — Merging. Dynamic Type stacks comparisons. The announcement first communicates: Local and optional continuity copies are being compared; neither silently replaces the other."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-MERGING-001"
label = "Review Conflict"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the quarantined two-sided conflict dry run from Continuity control — Merging"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-MERGING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Conflict exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Local and optional continuity copies are being compared; neither silently replaces the other."
success_focus = "the Review Conflict gate, preview, or result heading in Continuity control — Merging"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-MERGING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Conflict control and exact failed gate, field, or causal identity in Continuity control — Merging"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-MERGING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: gate, conflict, migration, or restore review remains before every canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-MERGING-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-MIGRATING"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review Migration => destination: the migration dry run and verified local checkpoint from Continuity control — Migrating; effect: No durable mutation occurs and no Receipt is created; Review Migration exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Continuity settings are being updated. Saved information remains available on this device.; focus: the Review Migration gate, preview, or result heading in Continuity control — Migrating.\nStart Migration => destination: the future migration progress state bound to the reviewed dry run; effect: The typed Start Migration command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the reviewed migration begins once with duplicate prevention and an interruption journal; focus: the migration progress heading and current verified phase."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Review Migration: No durable mutation occurs and no Receipt is created; Review Migration exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Continuity settings are being updated. Saved information remains available on this device. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: Continuity settings are being updated. Saved information remains available on this device."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Review Migration: No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity. Local truth and both conflicting alternatives remain protected. Recovery preserves: Continuity settings are being updated. Saved information remains available on this device."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: Continuity settings are being updated. Saved information remains available on this device."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Review Migration announces gate and local-authority consequence; success focuses the Review Migration gate, preview, or result heading in Continuity control — Migrating; rejection focuses the Review Migration control and exact failed gate, field, or causal identity in Continuity control — Migrating. Dynamic Type stacks comparisons. The announcement first communicates: Continuity settings are being updated. Saved information remains available on this device."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-MIGRATING-001"
label = "Review Migration"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the migration dry run and verified local checkpoint from Continuity control — Migrating"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-MIGRATING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Migration exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: Continuity settings are being updated. Saved information remains available on this device."
success_focus = "the Review Migration gate, preview, or result heading in Continuity control — Migrating"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-MIGRATING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Migration control and exact failed gate, field, or causal identity in Continuity control — Migrating"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-MIGRATING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: gate, conflict, migration, or restore review remains before every canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-MIGRATING-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-MIGRATING-002"
label = "Start Migration"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A current verified backup, dry run, rollback checkpoint, and duplicate-prevention proof exist", "Current explicit consent is present", "Eligible iCloud state and privacy/security gate are verified", "Local source authority, stable schema, and causal identity are verified", "Silent last-writer-wins is forbidden", "The reviewed migration dry run, exact scope, and interruption journal are explicitly confirmed before progress begins"]
destination = "the future migration progress state bound to the reviewed dry run"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-MIGRATING-002"
destination_posture = "current"
effect = "The typed Start Migration command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the reviewed migration begins once with duplicate prevention and an interruption journal"
success_focus = "the migration progress heading and current verified phase"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-MIGRATING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Start Migration control and first failed gate or dry-run fact"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-MIGRATING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "The verified rollback checkpoint and migration journal restore the pre-migration local projection through the typed recovery path."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-MIGRATING-002"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Only user-owned encrypted continuity transport may carry the confirmed scope after the full gate."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
rollback_posture = "checkpoint_restore"
checkpoint_id = "CHECKPOINT-YOU-CONTINUITY-CONTROL-MIGRATING-002"

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-PAUSED"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Resume Continuity => destination: the locally committed Resume Continuity status after full-gate revalidation from Continuity control — Paused; effect: A typed Resume Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry without deleting local or remote records. Transport reconciles separately, local source authority remains primary, and this future-gated contract authorizes no present action. Visible evidence remains: Optional continuity is paused; local work and pending history remain available.; focus: the Resume Continuity gate, preview, or result heading in Continuity control — Paused."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Resume Continuity: A typed Resume Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry without deleting local or remote records. Transport reconciles separately, local source authority remains primary, and this future-gated contract authorizes no present action. Visible evidence remains: Optional continuity is paused; local work and pending history remain available. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: Optional continuity is paused; local work and pending history remain available."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Resume Continuity: Before commit, cancellation changes nothing; after a future commit, inverse control is separately typed and verified, while remote deletion is never implied. Local truth and both conflicting alternatives remain protected. Recovery preserves: Optional continuity is paused; local work and pending history remain available."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: Optional continuity is paused; local work and pending history remain available."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Resume Continuity announces gate and local-authority consequence; success focuses the Resume Continuity gate, preview, or result heading in Continuity control — Paused; rejection focuses the Resume Continuity control and exact failed gate, field, or causal identity in Continuity control — Paused. Dynamic Type stacks comparisons. The announcement first communicates: Optional continuity is paused; local work and pending history remain available."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-PAUSED-001"
label = "Resume Continuity"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the locally committed Resume Continuity status after full-gate revalidation from Continuity control — Paused"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-PAUSED-001"
destination_posture = "current"
effect = "A typed Resume Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry without deleting local or remote records. Transport reconciles separately, local source authority remains primary, and this future-gated contract authorizes no present action. Visible evidence remains: Optional continuity is paused; local work and pending history remain available."
success_focus = "the Resume Continuity gate, preview, or result heading in Continuity control — Paused"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-PAUSED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Resume Continuity control and exact failed gate, field, or causal identity in Continuity control — Paused"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-PAUSED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: future Resume Continuity may commit only through Event, Projection, Receipt, History, and replay-safe local ownership after the complete gate."
rollback_undo = "Before commit, cancellation changes nothing; after a future commit, inverse control is separately typed and verified, while remote deletion is never implied."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-PAUSED-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
rollback_posture = "inverse_command"
inverse_command_id = "CMD-YOU-CONTINUITY-CONTROL-PAUSED-001-INVERSE"

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-REMOTE-PENDING"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review Conflict => destination: the quarantined two-sided conflict dry run from Continuity control — Remote Pending; effect: No durable mutation occurs and no Receipt is created; Review Conflict exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: An optional remote change is waiting for safe local comparison.; focus: the Review Conflict gate, preview, or result heading in Continuity control — Remote Pending."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Review Conflict: No durable mutation occurs and no Receipt is created; Review Conflict exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: An optional remote change is waiting for safe local comparison. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: An optional remote change is waiting for safe local comparison."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Review Conflict: No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity. Local truth and both conflicting alternatives remain protected. Recovery preserves: An optional remote change is waiting for safe local comparison."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: An optional remote change is waiting for safe local comparison."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Review Conflict announces gate and local-authority consequence; success focuses the Review Conflict gate, preview, or result heading in Continuity control — Remote Pending; rejection focuses the Review Conflict control and exact failed gate, field, or causal identity in Continuity control — Remote Pending. Dynamic Type stacks comparisons. The announcement first communicates: An optional remote change is waiting for safe local comparison."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-REMOTE-PENDING-001"
label = "Review Conflict"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the quarantined two-sided conflict dry run from Continuity control — Remote Pending"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-REMOTE-PENDING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Conflict exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: An optional remote change is waiting for safe local comparison."
success_focus = "the Review Conflict gate, preview, or result heading in Continuity control — Remote Pending"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-REMOTE-PENDING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Conflict control and exact failed gate, field, or causal identity in Continuity control — Remote Pending"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-REMOTE-PENDING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: gate, conflict, migration, or restore review remains before every canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-REMOTE-PENDING-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-RESTORING"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review Restore => destination: the restore dry run and verified local checkpoint from Continuity control — Restoring; effect: No durable mutation occurs and no Receipt is created; Review Restore exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: A selected continuity copy is loading. Information already saved on this device remains recoverable.; focus: the Review Restore gate, preview, or result heading in Continuity control — Restoring.\nRestore Reviewed Copy => destination: the future restore progress state bound to the reviewed copy; effect: The typed Restore Reviewed Copy command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the reviewed copy restores atomically without duplicate records or silent conflict loss; focus: the restored local result and retained rollback checkpoint."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Review Restore: No durable mutation occurs and no Receipt is created; Review Restore exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: A selected continuity copy is loading. Information already saved on this device remains recoverable. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: A selected continuity copy is loading. Information already saved on this device remains recoverable."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Review Restore: No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity. Local truth and both conflicting alternatives remain protected. Recovery preserves: A selected continuity copy is loading. Information already saved on this device remains recoverable."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: A selected continuity copy is loading. Information already saved on this device remains recoverable."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Review Restore announces gate and local-authority consequence; success focuses the Review Restore gate, preview, or result heading in Continuity control — Restoring; rejection focuses the Review Restore control and exact failed gate, field, or causal identity in Continuity control — Restoring. Dynamic Type stacks comparisons. The announcement first communicates: A selected continuity copy is loading. Information already saved on this device remains recoverable."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-RESTORING-001"
label = "Review Restore"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the restore dry run and verified local checkpoint from Continuity control — Restoring"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-RESTORING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Restore exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: A selected continuity copy is loading. Information already saved on this device remains recoverable."
success_focus = "the Review Restore gate, preview, or result heading in Continuity control — Restoring"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-RESTORING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Restore control and exact failed gate, field, or causal identity in Continuity control — Restoring"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-RESTORING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: gate, conflict, migration, or restore review remains before every canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-RESTORING-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-RESTORING-002"
label = "Restore Reviewed Copy"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A current verified backup, dry run, rollback checkpoint, and duplicate-prevention proof exist", "Current explicit consent is present", "Eligible iCloud state and privacy/security gate are verified", "Local source authority, stable schema, and causal identity are verified", "Silent last-writer-wins is forbidden", "The reviewed restore dry run, exact backup identity, and replacement consequences are explicitly confirmed"]
destination = "the future restore progress state bound to the reviewed copy"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-RESTORING-002"
destination_posture = "current"
effect = "The typed Restore Reviewed Copy command appends one Event, updates the owning Projection, records a Receipt, and preserves History; the reviewed copy restores atomically without duplicate records or silent conflict loss"
success_focus = "the restored local result and retained rollback checkpoint"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-RESTORING-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Restore Reviewed Copy control and first invalid backup, schema, or causal fact"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-RESTORING-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: the exact current revision validates before one typed command commits atomically."
rollback_undo = "The verified rollback checkpoint and restore journal recover the pre-restore local projection through the typed recovery path."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-RESTORING-002"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Only user-owned encrypted continuity storage supplies the confirmed reviewed copy after the full gate."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
rollback_posture = "checkpoint_restore"
checkpoint_id = "CHECKPOINT-YOU-CONTINUITY-CONTROL-RESTORING-002"

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-RETRYING"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Try Again => destination: the revalidated future continuity transport result from Continuity control — Retrying; effect: The Try Again external result causes no local canonical mutation; only after every future gate passes may it retry the exact failed causal transport identity. It cannot upload, download, merge, restore, migrate, delete, or replay accepted local Events while gated. Visible evidence remains: Optional continuity is trying again without blocking local work.; focus: the Try Again gate, preview, or result heading in Continuity control — Retrying."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Try Again: The Try Again external result causes no local canonical mutation; only after every future gate passes may it retry the exact failed causal transport identity. It cannot upload, download, merge, restore, migrate, delete, or replay accepted local Events while gated. Visible evidence remains: Optional continuity is trying again without blocking local work. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: Optional continuity is trying again without blocking local work."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Try Again: Cancellation preserves the verified local checkpoint and failed causal identity; another retry requires full freshness and gate revalidation. Local truth and both conflicting alternatives remain protected. Recovery preserves: Optional continuity is trying again without blocking local work."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: Optional continuity is trying again without blocking local work."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Try Again announces gate and local-authority consequence; success focuses the Try Again gate, preview, or result heading in Continuity control — Retrying; rejection focuses the Try Again control and exact failed gate, field, or causal identity in Continuity control — Retrying. Dynamic Type stacks comparisons. The announcement first communicates: Optional continuity is trying again without blocking local work."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-RETRYING-001"
label = "Try Again"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the revalidated future continuity transport result from Continuity control — Retrying"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-RETRYING-001"
destination_posture = "current"
effect = "The Try Again external result causes no local canonical mutation; only after every future gate passes may it retry the exact failed causal transport identity. It cannot upload, download, merge, restore, migrate, delete, or replay accepted local Events while gated. Visible evidence remains: Optional continuity is trying again without blocking local work."
success_focus = "the Try Again gate, preview, or result heading in Continuity control — Retrying"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-RETRYING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Try Again control and exact failed gate, field, or causal identity in Continuity control — Retrying"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-RETRYING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: any future retry remains subordinate to current local truth and cannot redefine canonical success or bypass the continuity gate."
rollback_undo = "Cancellation preserves the verified local checkpoint and failed causal identity; another retry requires full freshness and gate revalidation."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-RETRYING-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-SIGNED-OUT"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Review Continuity Status => destination: the nonmutating continuity gate and local-authority explanation from Continuity control — Signed Out; effect: No durable mutation occurs and no Receipt is created; Review Continuity Status exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: The account is signed out, so optional continuity is paused while local information remains.; focus: the Review Continuity Status gate, preview, or result heading in Continuity control — Signed Out."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Review Continuity Status: No durable mutation occurs and no Receipt is created; Review Continuity Status exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: The account is signed out, so optional continuity is paused while local information remains. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: The account is signed out, so optional continuity is paused while local information remains."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Review Continuity Status: No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity. Local truth and both conflicting alternatives remain protected. Recovery preserves: The account is signed out, so optional continuity is paused while local information remains."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: The account is signed out, so optional continuity is paused while local information remains."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Review Continuity Status announces gate and local-authority consequence; success focuses the Review Continuity Status gate, preview, or result heading in Continuity control — Signed Out; rejection focuses the Review Continuity Status control and exact failed gate, field, or causal identity in Continuity control — Signed Out. Dynamic Type stacks comparisons. The announcement first communicates: The account is signed out, so optional continuity is paused while local information remains."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-SIGNED-OUT-001"
label = "Review Continuity Status"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the nonmutating continuity gate and local-authority explanation from Continuity control — Signed Out"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-SIGNED-OUT-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Continuity Status exposes only gate status, local authority, affected identities, dry-run consequences, or rollback information. It cannot enable, upload, download, merge, restore, migrate, delete, pause, resume, retry, or choose a conflict while gated. Visible evidence remains: The account is signed out, so optional continuity is paused while local information remains."
success_focus = "the Review Continuity Status gate, preview, or result heading in Continuity control — Signed Out"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-SIGNED-OUT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Continuity Status control and exact failed gate, field, or causal identity in Continuity control — Signed Out"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-SIGNED-OUT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: gate, conflict, migration, or restore review remains before every canonical or external commit."
rollback_undo = "No Undo is required; dismissal returns to unchanged local truth and preserves every quarantined alternative, checkpoint, and causal identity."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-SIGNED-OUT-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-UNAVAILABLE"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Try Again => destination: the revalidated future continuity transport result from Continuity control — Unavailable; effect: The Try Again external result causes no local canonical mutation; only after every future gate passes may it retry the exact failed causal transport identity. It cannot upload, download, merge, restore, migrate, delete, or replay accepted local Events while gated. Visible evidence remains: Optional continuity is temporarily unavailable; the local app remains fully usable.; focus: the Try Again gate, preview, or result heading in Continuity control — Unavailable."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Try Again: The Try Again external result causes no local canonical mutation; only after every future gate passes may it retry the exact failed causal transport identity. It cannot upload, download, merge, restore, migrate, delete, or replay accepted local Events while gated. Visible evidence remains: Optional continuity is temporarily unavailable; the local app remains fully usable. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: Optional continuity is temporarily unavailable; the local app remains fully usable."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Try Again: Cancellation preserves the verified local checkpoint and failed causal identity; another retry requires full freshness and gate revalidation. Local truth and both conflicting alternatives remain protected. Recovery preserves: Optional continuity is temporarily unavailable; the local app remains fully usable."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: Optional continuity is temporarily unavailable; the local app remains fully usable."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Try Again announces gate and local-authority consequence; success focuses the Try Again gate, preview, or result heading in Continuity control — Unavailable; rejection focuses the Try Again control and exact failed gate, field, or causal identity in Continuity control — Unavailable. Dynamic Type stacks comparisons. The announcement first communicates: Optional continuity is temporarily unavailable; the local app remains fully usable."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-UNAVAILABLE-001"
label = "Try Again"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the revalidated future continuity transport result from Continuity control — Unavailable"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-UNAVAILABLE-001"
destination_posture = "current"
effect = "The Try Again external result causes no local canonical mutation; only after every future gate passes may it retry the exact failed causal transport identity. It cannot upload, download, merge, restore, migrate, delete, or replay accepted local Events while gated. Visible evidence remains: Optional continuity is temporarily unavailable; the local app remains fully usable."
success_focus = "the Try Again gate, preview, or result heading in Continuity control — Unavailable"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-UNAVAILABLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Try Again control and exact failed gate, field, or causal identity in Continuity control — Unavailable"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-UNAVAILABLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: any future retry remains subordinate to current local truth and cannot redefine canonical success or bypass the continuity gate."
rollback_undo = "Cancellation preserves the verified local checkpoint and failed causal identity; another retry requires full freshness and gate revalidation."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-UNAVAILABLE-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-UPLOADING"
requirement_id = "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
transition_exit = "Pause Continuity => destination: the locally committed Pause Continuity status after full-gate revalidation from Continuity control — Uploading; effect: A typed Pause Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry without deleting local or remote records. Transport reconciles separately, local source authority remains primary, and this future-gated contract authorizes no present action. Visible evidence remains: An encrypted copy is being sent to the user’s continuity storage. Saved information remains available on this device.; focus: the Pause Continuity gate, preview, or result heading in Continuity control — Uploading."
durable_effect = "This contract is future-gated and must not enter task-pack or visual implementation eligibility while the continuity-disabled gate remains. Exact continuity consequence: Pause Continuity: A typed Pause Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry without deleting local or remote records. Transport reconciles separately, local source authority remains primary, and this future-gated contract authorizes no present action. Visible evidence remains: An encrypted copy is being sent to the user’s continuity storage. Saved information remains available on this device. No silent last-writer-wins, remote deletion, or nonlocal authority is permitted. Current visible status: An encrypted copy is being sent to the user’s continuity storage. Saved information remains available on this device."
recovery_rollback = "Exact checkpoint, conflict, causal-identity, cancellation, and rollback behavior: Pause Continuity: Before commit, cancellation changes nothing; after a future commit, inverse control is separately typed and verified, while remote deletion is never implied. Local truth and both conflicting alternatives remain protected. Recovery preserves: An encrypted copy is being sent to the user’s continuity storage. Saved information remains available on this device."
offline_behavior = "The complete local core remains readable, mutable, replayable, and authoritative offline. While gated, no upload, download, merge, migration, restore, retry, or remote deletion is attempted. Offline evidence remains: An encrypted copy is being sent to the user’s continuity storage. Saved information remains available on this device."
accessibility_focus = "VoiceOver announces disabled or future-gated posture, local authority, affected identities, dry-run consequence, consent, and rollback without color dependence: Pause Continuity announces gate and local-authority consequence; success focuses the Pause Continuity gate, preview, or result heading in Continuity control — Uploading; rejection focuses the Pause Continuity control and exact failed gate, field, or causal identity in Continuity control — Uploading. Dynamic Type stacks comparisons. The announcement first communicates: An encrypted copy is being sent to the user’s continuity storage. Saved information remains available on this device."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-CONTINUITY-CONTROL-UPLOADING-001"
label = "Pause Continuity"
canonical_owner = "system.continuity.command-contract"
preconditions = ["A dry run names the exact local and remote consequences before confirmation", "A verified backup or checkpoint and bounded rollback plan are current", "An eligible iCloud account and container are explicitly verified", "Explicit consent has been recorded for this exact continuity operation", "Local source authority remains readable, mutable, replayable, and primary offline", "No silent last-writer-wins policy is permitted; every conflict stays explicit", "Privacy/security gate approval is current for the exact schema and data classification", "Remote deletion remains a separate explicit destructive command", "Stable schema version, record identity, and causal identity are available for every affected envelope"]
destination = "the locally committed Pause Continuity status after full-gate revalidation from Continuity control — Uploading"
destination_id = "DEST-YOU-CONTINUITY-CONTROL-UPLOADING-001"
destination_posture = "current"
effect = "A typed Pause Continuity Command may exist only after every gate and precondition passes; it appends an Event, updates the local continuity Projection, and creates a Receipt and History entry without deleting local or remote records. Transport reconciles separately, local source authority remains primary, and this future-gated contract authorizes no present action. Visible evidence remains: An encrypted copy is being sent to the user’s continuity storage. Saved information remains available on this device."
success_focus = "the Pause Continuity gate, preview, or result heading in Continuity control — Uploading"
success_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-UPLOADING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Pause Continuity control and exact failed gate, field, or causal identity in Continuity control — Uploading"
failure_focus_id = "FOCUS-YOU-CONTINUITY-CONTROL-UPLOADING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Mutation: future Pause Continuity may commit only through Event, Projection, Receipt, History, and replay-safe local ownership after the complete gate."
rollback_undo = "Before commit, cancellation changes nothing; after a future commit, inverse control is separately typed and verified, while remote deletion is never implied."
recovery_id = "RECOVERY-YOU-CONTINUITY-CONTROL-UPLOADING-001"
recovery_posture = "current"
recovery_owner = "system.continuity.command-contract"
privacy_egress = "Continuity remains separate from Ambitions Account and R2; no private envelope leaves the device while gated, and future eligible iCloud transport is user-owned, minimized, encrypted, and explicitly consented."
verification_ids = ["SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SYSTEM-CONTINUITY-DISABLED-001"]
rollback_posture = "inverse_command"
inverse_command_id = "CMD-YOU-CONTINUITY-CONTROL-UPLOADING-001-INVERSE"

+++

# Sync and Continuity

This shadow target specifies a possible user-owned CloudKit continuity boundary.

## SYSTEM-CONTINUITY-SEPARATION-001 — CloudKit continuity is separate and locally subordinate

- **Concept:** `system.continuity.user-owned-cloudkit`
- **Modality:** `MUST`
- **Scope:** Optional private-graph continuity across the user's Apple devices
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-CONTINUITY-SEPARATION-001`
- **Supersedes:** none

User-owned CloudKit continuity MUST remain separate from Ambitions Account identity/entitlement and R2/Source Atlas public-reference infrastructure. Local device state remains readable, mutable, replayable, and authoritative offline; CloudKit transports only explicitly eligible versioned envelopes and never becomes command, policy, sole-copy, or local-core authority. Sign-out and account deletion do not delete local data without a separate explicit destructive action.

CloudKit continuity MUST NOT become the only readable copy, block the local core, or become canonical command authority.

CloudKit sync MAY be optional and user-owned through iCloud.

CloudKit MAY provide optional continuity.

## SYSTEM-CONTINUITY-DISABLED-001 — Continuity stays disabled until the full gate passes

- **Concept:** `system.continuity.disabled-gate`
- **Modality:** `MUST`
- **Scope:** Any CloudKit container, schema, zone, upload, download, merge, restore, or user-facing enablement
- **Status:** `normative`
- **Verification:** `PRIVACY-CLOUDKIT-APPROVAL-001`, `SCENARIO-SYSTEM-CONTINUITY-GATE-001`
- **Supersedes:** none

Continuity MUST stay disabled until owner-approved design and executable exact-revision proof cover: data classification and explicit consent; local source-of-truth authority; user-private container, encryption/key and Ambitions Account separation; stable record/schema/causal identity; deterministic merge and human conflict quarantine; tombstones/deletion propagation; offline divergence; retry, batching, quotas, token expiry and partial failure; iCloud unavailable/disabled/account change/device removal; backup/restore and duplicate prevention; sign-out/delete/reset; old-client compatibility and minimum upgrade; development/production environment separation; schema migration and rollback; privacy/security/threat review; interruption/relaunch; diagnostics/observability; and release rollback. Every cell is conjunctive; scaffolding, prose, or partial tests cannot enable a subset.

## SYSTEM-CONTINUITY-COMMAND-CONTRACT-001 — Continuity commands remain disabled until the full gate passes

- **Concept:** `system.continuity.command-contract`
- **Modality:** `MUST`
- **Scope:** Disabled status, future enablement, transport, pause, resume, retry, conflict, migration, restore, consent, checkpoint, rollback, privacy, local authority, and task-pack eligibility
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-CONTINUITY-COMMAND-CONTRACT-001`
- **Supersedes:** none

While `PRIVACY-CLOUDKIT-CONTINUITY-001` or `SYSTEM-CONTINUITY-DISABLED-001` remains unsatisfied, the only active continuity behavior is a non-mutating `Review Continuity Status` route showing that continuity is disabled. No enable, upload, download, merge, restore, migration, remote deletion, conflict-choice, pause, resume, or retry command may be active, emitted by a task pack, or represented as implementation-ready visual authority.

The following future commands MAY be specified only with `activation_posture = "future_gated"`:

- `Enable Continuity`
- `Pause Continuity`
- `Resume Continuity`
- `Turn Off Continuity`
- `Try Again`
- `Review Conflict`
- `Keep This Device`
- `Keep Other Copy`
- `Merge Selected Changes`
- `Review Migration`
- `Start Migration`
- `Review Restore`
- `Restore Reviewed Copy`

Enablement requires the complete existing gate, explicit consent, current verified backup, local-source authority, eligible iCloud state, stable schema and causal identity, migration/rollback plan, privacy/security approval, and exact-revision proof.

Conflict resolution MUST show human-meaningful differences and consequences. It MUST NOT use silent last-write-wins. Migration and restore require dry-run validation, a rollback checkpoint, explicit confirmation, interruption recovery, duplicate prevention, and a Receipt. Turning continuity off stops future transport but deletes neither local nor remote data; remote deletion remains a separate destructive-data flow.


`You → Account & Sync → Continuity`, as a full native drilldown. Focus lands on current continuity status, then exact conflict, migration, restore, retry, or completion result.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Owns optional continuity eligibility, envelope transport, causal merge, conflict/quarantine, tombstone propagation, sync state, and enablement gate.
It does not own Ambitions Account identity, R2, public references, canonical command decisions, local store meaning, or backup as a synonym for sync.

<!-- canon-section: inputs-outputs -->
Inputs are committed local event/object envelopes, stable identities, schema/policy revisions, causal clocks, tombstones, eligibility/consent, local/account/iCloud state, server tokens, and environment. Outputs are disabled/eligible state, upload/download batch, deterministic merge or quarantine, local Command proposal, sync cursor/status, conflict review, and Receipt/history.

<!-- canon-section: authority-boundary -->
Downloaded facts cannot mutate canonical state directly; they enter the runtime mutation sequence as validated idempotent Commands. Local commit precedes upload. CloudKit, Ambitions Account, and R2 remain distinct capabilities and stores.

<!-- canon-section: data-classification -->
Only approved private-continuity envelopes may enter the user's private CloudKit boundary after the full gate. Account/R2/Source Atlas never receive them. Attachments and highly sensitive fields require explicit eligibility, protection, quota, tombstone, restore, and deletion rules.

<!-- canon-section: state-model -->
The state model binds continuity capability, causal progress, and recovery action.
Global and per-envelope states distinguish disabled, ineligible, eligible-not-enabled, enabled-idle, local-pending, uploading, remote-pending, merging, conflicted/quarantined, retrying, paused, unavailable, signed-out, migrating, restoring, and blocked. Disabled is the required current target state until gate proof exists.

<!-- canon-section: failure-recovery -->
Conflict never silently last-write-wins; unresolvable change is quarantined for human review. Partial failure retains local truth and causal progress, retry is idempotent, token/account/environment change revalidates, and restore uses a reviewed causal plan. Any silent-loss path is P0 Red.

<!-- canon-section: local-network-boundary -->
All Today/Goals/Time/You/Capture/Search, mutation, proof/history, learning, and replay remain complete without CloudKit, Ambitions Account, or network. Continuity outage only degrades continuity and cannot coerce sign-in.

<!-- canon-section: determinism -->
Equivalent versioned envelopes, causal metadata, local state, merge policy, and tombstones yield the same merge, rejection, or quarantine. Arrival timing and device order cannot silently change meaning.

<!-- canon-section: observability -->
Local redacted traces bind each envelope and cursor to one continuity result.
Local redacted sync evidence includes environment/container class, enablement-gate revision, envelope/cursor/causal IDs, batch/result, retries, conflicts/quarantine, tombstones, account/iCloud state, restore/migration phase, and Receipt without private content.

<!-- canon-section: source-ownership -->
Canonical ownership resides in the exact Continuity, Boundary, PrivacySecurity, and Inspection domains.
Exact target owner is `Core/LocalRuntimeOS/Continuity/`, with `Boundary/`, `PrivacySecurity/`, and `Inspection/` enforcement; `Surfaces/You/` presents controls and `Quality/` owns gate proof.

<!-- canon-section: tests-proof -->
Executable gate scenarios exercise every required continuity and separation cell.
Test the entire disabled gate, separation from Account/R2, local-first offline mutations, two-device conflicts, deterministic merge/quarantine, tombstones/deletion, duplicates, partial batches, token/quotas/network, iCloud/account/device changes, old clients, environment separation, migrations/rollback, backup/restore, sign-out retention, explicit deletion, interruption/relaunch, privacy attacks, and exact-revision production procedures. No test subset authorizes enablement.

<!-- canon-section: performance-resource-constraints -->
Envelope creation, batching, merge, retry, attachment work, and reconciliation are bounded, cancellable, backpressured, off-main where material, and lifecycle-safe. Article 31 calibration must define device/OS/build, graph/envelope/device/conflict/blob scale, network conditions, tools, percentile/maximum, memory/energy/storage/quota, and regression thresholds; no budget or readiness is claimed here.

## SYSTEM-CONTINUITY-CONFLICT-001 — Continuity conflict handling

- **Concept:** `system.continuity.conflict`
- **Modality:** `MUST NOT`
- **Scope:** Continuity conflict handling
- **Status:** `normative`
- **Verification:** `REVIEW-SYSTEM-CONTINUITY-CONFLICT-001`
- **Supersedes:** none

Continuity conflict merge behavior MUST be deterministic; unresolvable conflicts MUST be quarantined and presented as human-meaningful changes, and silent last-write-wins data loss MUST NOT occur.

## SYSTEM-CONTINUITY-CONTROL-CENTER-001 — Continuity control center

- **Concept:** `system.continuity.control-center`
- **Modality:** `MUST`
- **Scope:** Continuity control center
- **Status:** `normative`
- **Verification:** `REVIEW-SYSTEM-CONTINUITY-CONTROL-CENTER-001`
- **Supersedes:** none

The continuity control center MUST distinguish Ambitions Account from private-graph continuity and show enablement, last success, pending local changes, devices, reviewable conflicts, retry state, and recovery/reset actions; conflict resolution MUST be explicit and receipt-backed, and destructive reset MUST preview scope and provide an export or recovery path.

## SYSTEM-CONTINUITY-ENVIRONMENT-001 — Continuity environment separation

- **Concept:** `system.continuity.environment`
- **Modality:** `MUST`
- **Scope:** Continuity environment separation
- **Status:** `normative`
- **Verification:** `REVIEW-SYSTEM-CONTINUITY-ENVIRONMENT-001`
- **Supersedes:** none

Development and production continuity schemas and containers MUST remain separate and use reviewed deployment procedures; production schema mutation MUST have migration and rollback plans.

## SYSTEM-CONTINUITY-FAILURE-001 — Continuity failure matrix

- **Concept:** `system.continuity.failure`
- **Modality:** `MUST`
- **Scope:** Continuity failure matrix
- **Status:** `normative`
- **Verification:** `REVIEW-SYSTEM-CONTINUITY-FAILURE-001`
- **Supersedes:** none

Continuity failure behavior MUST define retry and backoff, batching and quotas, token expiration, partial failure, network changes, disabled iCloud, account changes, old clients, and device removal.

## SYSTEM-CONTINUITY-RECORD-IDENTITY-001 — Continuity record identity

- **Concept:** `system.continuity.record-identity`
- **Modality:** `MUST`
- **Scope:** Continuity record identity
- **Status:** `normative`
- **Verification:** `REVIEW-SYSTEM-CONTINUITY-RECORD-IDENTITY-001`
- **Supersedes:** none

Private continuity records MUST preserve canonical object identity, schema version, causal metadata, tombstones, and attachment references without exposing data outside the user-owned private container boundary.

## SYSTEM-CONTINUITY-RESTORE-001 — Continuity-aware restore

- **Concept:** `system.continuity.restore`
- **Modality:** `MUST`
- **Scope:** Continuity-aware restore
- **Status:** `normative`
- **Verification:** `REVIEW-SYSTEM-CONTINUITY-RESTORE-001`
- **Supersedes:** none

Restore while continuity is active MUST define duplicate prevention, causal reset, upload/download precedence, and user-visible consequence review before commit.
