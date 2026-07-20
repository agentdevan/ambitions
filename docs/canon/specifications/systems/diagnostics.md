+++
spec_id = "SYSTEM-DIAGNOSTICS"
title = "Diagnostics"
kind = "system"
status = "normative"
owner_domain = "system-diagnostics"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "system.diagnostics.command-contract",
  "system.diagnostics.non-authority",
  "system.diagnostics.redacted-health",
]
inherits = ["PRIVACY-VISIBILITY-001", "LAW-LOCAL-AUTHORITY-001", "CONST-PROOF-EVIDENCE-001", "LAW-DATA-LOSS-STOP-SHIP-001"]
depends_on = ["CONSTITUTION", "APP-DEGRADED-STATES", "SYSTEM-PRIVACY-DATA-CLASSIFICATION", "SYSTEM-PERSISTENCE-REPLAY", "SURFACE-YOU"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/", "Native/Ambitions/Diagnostics/", "Native/Ambitions/Surfaces/You/", "Native/Ambitions/Quality/"]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DIAGNOSTICS-BLOCKED"
requirement_id = "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Repair => destination: the redacted Repair-owned review for the exact affected scope from Diagnostics and repair inspection — Blocked; effect: No durable mutation occurs and no Receipt is created; Review Repair opens only redacted inspection and a Repair-owned dry-run or quarantine explanation. It cannot repair, isolate, delete, or reset data. Visible evidence remains: Repair cannot proceed until the named safety condition is resolved.; focus: the Review Repair result, preview, or first affected-scope heading in Diagnostics and repair inspection — Blocked."
durable_effect = "Exact observational and artifact consequences: Review Repair: No durable mutation occurs and no Receipt is created; Review Repair opens only redacted inspection and a Repair-owned dry-run or quarantine explanation. It cannot repair, isolate, delete, or reset data. Visible evidence remains: Repair cannot proceed until the named safety condition is resolved. Diagnostics never owns canonical repair, quarantine, reset, or deletion. Current visible status: Repair cannot proceed until the named safety condition is resolved."
recovery_rollback = "Exact cancellation before handoff, during safely cancellable Repair work, and after Repair commit: Review Repair: No Undo is required; dismissal returns focus to the unchanged diagnostic status, and uncertain records remain protected rather than deleted. Any post-commit rollback remains a separate Repair-owned typed command. Recovery preserves: Repair cannot proceed until the named safety condition is resolved."
offline_behavior = "Health inspection, redacted previews, quarantine review, and Repair handoff remain local and offline. File creation uses a user-chosen local destination; no automatic upload or network dependency is introduced. Offline evidence remains: Repair cannot proceed until the named safety condition is resolved."
accessibility_focus = "VoiceOver announces health class, affected scope, freshness, redaction, consequence, and safe action without exposing raw identifiers: Review Repair announces affected scope and consequence; success focuses the Review Repair result, preview, or first affected-scope heading in Diagnostics and repair inspection — Blocked; rejection focuses the Review Repair control and exact invalid field or blocked reason in Diagnostics and repair inspection — Blocked. Dynamic Type stacks findings and preview fields. The announcement first communicates: Repair cannot proceed until the named safety condition is resolved."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-BLOCKED-001"
label = "Review Repair"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["Core/LocalRuntimeOS/Repair owns any later canonical mutation", "The affected scope, diagnostics revision, and evidence freshness are current", "The current canonical revision and exact affected scope are revalidated", "The dry-run result, verified recovery point, explicit confirmation, and rollback plan are present before Repair may commit", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the redacted Repair-owned review for the exact affected scope from Diagnostics and repair inspection — Blocked"
destination_id = "DEST-YOU-DIAGNOSTICS-BLOCKED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Repair opens only redacted inspection and a Repair-owned dry-run or quarantine explanation. It cannot repair, isolate, delete, or reset data. Visible evidence remains: Repair cannot proceed until the named safety condition is resolved."
success_focus = "the Review Repair result, preview, or first affected-scope heading in Diagnostics and repair inspection — Blocked"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-BLOCKED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Repair control and exact invalid field or blocked reason in Diagnostics and repair inspection — Blocked"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-BLOCKED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: review and handoff complete before any Repair-owned confirmation or canonical commit."
rollback_undo = "No Undo is required; dismissal returns focus to the unchanged diagnostic status, and uncertain records remain protected rather than deleted."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-BLOCKED-001"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DIAGNOSTICS-DEGRADED"
requirement_id = "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Inspect => destination: the first redacted affected-scope finding from Diagnostics and repair inspection — Degraded; effect: No durable mutation occurs and no Receipt is created; Inspect reveals only allowlisted redacted evidence, freshness, consequence, and safe next routes using opaque identifiers. Visible evidence remains: The health check found a limited issue; unaffected local work remains available.; focus: the Inspect result, preview, or first affected-scope heading in Diagnostics and repair inspection — Degraded."
durable_effect = "Exact observational and artifact consequences: Inspect: No durable mutation occurs and no Receipt is created; Inspect reveals only allowlisted redacted evidence, freshness, consequence, and safe next routes using opaque identifiers. Visible evidence remains: The health check found a limited issue; unaffected local work remains available. Diagnostics never owns canonical repair, quarantine, reset, or deletion. Current visible status: The health check found a limited issue; unaffected local work remains available."
recovery_rollback = "Exact cancellation before handoff, during safely cancellable Repair work, and after Repair commit: Inspect: No Undo is required; dismissal returns to the same evidence-backed status and affected scope. Any post-commit rollback remains a separate Repair-owned typed command. Recovery preserves: The health check found a limited issue; unaffected local work remains available."
offline_behavior = "Health inspection, redacted previews, quarantine review, and Repair handoff remain local and offline. File creation uses a user-chosen local destination; no automatic upload or network dependency is introduced. Offline evidence remains: The health check found a limited issue; unaffected local work remains available."
accessibility_focus = "VoiceOver announces health class, affected scope, freshness, redaction, consequence, and safe action without exposing raw identifiers: Inspect announces affected scope and consequence; success focuses the Inspect result, preview, or first affected-scope heading in Diagnostics and repair inspection — Degraded; rejection focuses the Inspect control and exact invalid field or blocked reason in Diagnostics and repair inspection — Degraded. Dynamic Type stacks findings and preview fields. The announcement first communicates: The health check found a limited issue; unaffected local work remains available."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-DEGRADED-001"
label = "Inspect"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["The affected scope, diagnostics revision, and evidence freshness are current", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the first redacted affected-scope finding from Diagnostics and repair inspection — Degraded"
destination_id = "DEST-YOU-DIAGNOSTICS-DEGRADED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect reveals only allowlisted redacted evidence, freshness, consequence, and safe next routes using opaque identifiers. Visible evidence remains: The health check found a limited issue; unaffected local work remains available."
success_focus = "the Inspect result, preview, or first affected-scope heading in Diagnostics and repair inspection — Degraded"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-DEGRADED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Inspect control and exact invalid field or blocked reason in Diagnostics and repair inspection — Degraded"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-DEGRADED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: diagnostic inspection observes and explains without canonical mutation."
rollback_undo = "No Undo is required; dismissal returns to the same evidence-backed status and affected scope."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-DEGRADED-001"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DIAGNOSTICS-DIAGNOSIS-READY"
requirement_id = "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Inspect => destination: the first redacted affected-scope finding from Diagnostics and repair inspection — Diagnosis Ready; effect: No durable mutation occurs and no Receipt is created; Inspect reveals only allowlisted redacted evidence, freshness, consequence, and safe next routes using opaque identifiers. Visible evidence remains: A limited issue and its affected area are shown. Goals, Captures, time, and settings remain unchanged.; focus: the Inspect result, preview, or first affected-scope heading in Diagnostics and repair inspection — Diagnosis Ready.\nPreview Diagnostic Export => destination: the allowlisted redacted diagnostic export preview from Diagnostics and repair inspection — Diagnosis Ready; effect: No durable mutation occurs and no Receipt is created; Preview Diagnostic Export shows the exact included fields, exclusions, and redactions without creating a file or uploading anything. Visible evidence remains: A limited issue and its affected area are shown. Goals, Captures, time, and settings remain unchanged.; focus: the Preview Diagnostic Export result, preview, or first affected-scope heading in Diagnostics and repair inspection — Diagnosis Ready."
durable_effect = "Exact observational and artifact consequences: Inspect: No durable mutation occurs and no Receipt is created; Inspect reveals only allowlisted redacted evidence, freshness, consequence, and safe next routes using opaque identifiers. Visible evidence remains: A limited issue and its affected area are shown. Goals, Captures, time, and settings remain unchanged. | Preview Diagnostic Export: No durable mutation occurs and no Receipt is created; Preview Diagnostic Export shows the exact included fields, exclusions, and redactions without creating a file or uploading anything. Visible evidence remains: A limited issue and its affected area are shown. Goals, Captures, time, and settings remain unchanged. Diagnostics never owns canonical repair, quarantine, reset, or deletion. Current visible status: A limited issue and its affected area are shown. Goals, Captures, time, and settings remain unchanged."
recovery_rollback = "Exact cancellation before handoff, during safely cancellable Repair work, and after Repair commit: Inspect: No Undo is required; dismissal returns to the same evidence-backed status and affected scope. | Preview Diagnostic Export: No Undo is required; cancellation returns to the diagnosis with no file, share sheet, upload, or product-state change. Any post-commit rollback remains a separate Repair-owned typed command. Recovery preserves: A limited issue and its affected area are shown. Goals, Captures, time, and settings remain unchanged."
offline_behavior = "Health inspection, redacted previews, quarantine review, and Repair handoff remain local and offline. File creation uses a user-chosen local destination; no automatic upload or network dependency is introduced. Offline evidence remains: A limited issue and its affected area are shown. Goals, Captures, time, and settings remain unchanged."
accessibility_focus = "VoiceOver announces health class, affected scope, freshness, redaction, consequence, and safe action without exposing raw identifiers: Inspect announces affected scope and consequence; success focuses the Inspect result, preview, or first affected-scope heading in Diagnostics and repair inspection — Diagnosis Ready; rejection focuses the Inspect control and exact invalid field or blocked reason in Diagnostics and repair inspection — Diagnosis Ready | Preview Diagnostic Export announces affected scope and consequence; success focuses the Preview Diagnostic Export result, preview, or first affected-scope heading in Diagnostics and repair inspection — Diagnosis Ready; rejection focuses the Preview Diagnostic Export control and exact invalid field or blocked reason in Diagnostics and repair inspection — Diagnosis Ready. Dynamic Type stacks findings and preview fields. The announcement first communicates: A limited issue and its affected area are shown. Goals, Captures, time, and settings remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-DIAGNOSIS-READY-001"
label = "Inspect"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["The affected scope, diagnostics revision, and evidence freshness are current", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the first redacted affected-scope finding from Diagnostics and repair inspection — Diagnosis Ready"
destination_id = "DEST-YOU-DIAGNOSTICS-DIAGNOSIS-READY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect reveals only allowlisted redacted evidence, freshness, consequence, and safe next routes using opaque identifiers. Visible evidence remains: A limited issue and its affected area are shown. Goals, Captures, time, and settings remain unchanged."
success_focus = "the Inspect result, preview, or first affected-scope heading in Diagnostics and repair inspection — Diagnosis Ready"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-DIAGNOSIS-READY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Inspect control and exact invalid field or blocked reason in Diagnostics and repair inspection — Diagnosis Ready"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-DIAGNOSIS-READY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: diagnostic inspection observes and explains without canonical mutation."
rollback_undo = "No Undo is required; dismissal returns to the same evidence-backed status and affected scope."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-DIAGNOSIS-READY-001"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-DIAGNOSIS-READY-002"
label = "Preview Diagnostic Export"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["The affected scope, diagnostics revision, and evidence freshness are current", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the allowlisted redacted diagnostic export preview from Diagnostics and repair inspection — Diagnosis Ready"
destination_id = "DEST-YOU-DIAGNOSTICS-DIAGNOSIS-READY-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Preview Diagnostic Export shows the exact included fields, exclusions, and redactions without creating a file or uploading anything. Visible evidence remains: A limited issue and its affected area are shown. Goals, Captures, time, and settings remain unchanged."
success_focus = "the Preview Diagnostic Export result, preview, or first affected-scope heading in Diagnostics and repair inspection — Diagnosis Ready"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-DIAGNOSIS-READY-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Preview Diagnostic Export control and exact invalid field or blocked reason in Diagnostics and repair inspection — Diagnosis Ready"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-DIAGNOSIS-READY-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: redacted export preview remains before local artifact creation and any egress Receipt."
rollback_undo = "No Undo is required; cancellation returns to the diagnosis with no file, share sheet, upload, or product-state change."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-DIAGNOSIS-READY-002"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DIAGNOSTICS-EXPORT-FAILED"
requirement_id = "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Try Again => destination: the refreshed redacted health status or exact failed diagnostic step from Diagnostics and repair inspection — Export Failed; effect: No durable mutation occurs and no Receipt is created; Try Again repeats only observational inspection against current evidence. It cannot repair, quarantine, reset, or automatically create an export. Visible evidence remains until a reliable result exists: The diagnostic export did not finish; local health information remains unchanged.; focus: the Try Again result, preview, or first affected-scope heading in Diagnostics and repair inspection — Export Failed."
durable_effect = "Exact observational and artifact consequences: Try Again: No durable mutation occurs and no Receipt is created; Try Again repeats only observational inspection against current evidence. It cannot repair, quarantine, reset, or automatically create an export. Visible evidence remains until a reliable result exists: The diagnostic export did not finish; local health information remains unchanged. Diagnostics never owns canonical repair, quarantine, reset, or deletion. Current visible status: The diagnostic export did not finish; local health information remains unchanged."
recovery_rollback = "Exact cancellation before handoff, during safely cancellable Repair work, and after Repair commit: Try Again: Cancellation preserves the prior reliable health status; interruption may resume the inspection without replaying a Repair or export action. Any post-commit rollback remains a separate Repair-owned typed command. Recovery preserves: The diagnostic export did not finish; local health information remains unchanged."
offline_behavior = "Health inspection, redacted previews, quarantine review, and Repair handoff remain local and offline. File creation uses a user-chosen local destination; no automatic upload or network dependency is introduced. Offline evidence remains: The diagnostic export did not finish; local health information remains unchanged."
accessibility_focus = "VoiceOver announces health class, affected scope, freshness, redaction, consequence, and safe action without exposing raw identifiers: Try Again announces affected scope and consequence; success focuses the Try Again result, preview, or first affected-scope heading in Diagnostics and repair inspection — Export Failed; rejection focuses the Try Again control and exact invalid field or blocked reason in Diagnostics and repair inspection — Export Failed. Dynamic Type stacks findings and preview fields. The announcement first communicates: The diagnostic export did not finish; local health information remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-EXPORT-FAILED-001"
label = "Try Again"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["The affected scope, diagnostics revision, and evidence freshness are current", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the refreshed redacted health status or exact failed diagnostic step from Diagnostics and repair inspection — Export Failed"
destination_id = "DEST-YOU-DIAGNOSTICS-EXPORT-FAILED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Try Again repeats only observational inspection against current evidence. It cannot repair, quarantine, reset, or automatically create an export. Visible evidence remains until a reliable result exists: The diagnostic export did not finish; local health information remains unchanged."
success_focus = "the Try Again result, preview, or first affected-scope heading in Diagnostics and repair inspection — Export Failed"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-EXPORT-FAILED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Try Again control and exact invalid field or blocked reason in Diagnostics and repair inspection — Export Failed"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-EXPORT-FAILED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: observational health inspection completes without canonical state mutation."
rollback_undo = "Cancellation preserves the prior reliable health status; interruption may resume the inspection without replaying a Repair or export action."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-EXPORT-FAILED-001"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DIAGNOSTICS-EXPORT-PREVIEW"
requirement_id = "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the originating You or Diagnostics context from Diagnostics and repair inspection — Export Preview; effect: No durable mutation occurs and no Receipt is created; Cancel closes only the current diagnostic presentation. No repair, quarantine, reset, file, or upload begins. Visible evidence remains available: The exact diagnostic fields and redactions are visible before export.; focus: the Cancel result, preview, or first affected-scope heading in Diagnostics and repair inspection — Export Preview.\nCreate Diagnostic File => destination: the user-chosen local diagnostic-file result from Diagnostics and repair inspection — Export Preview; effect: The Create Diagnostic File external result causes no local canonical mutation; it writes only the reviewed redacted fields to a user-chosen local artifact and records a separate egress Receipt. It never repairs, quarantines, resets, or uploads. Visible evidence before creation remains: The exact diagnostic fields and redactions are visible before export.; focus: the Create Diagnostic File result, preview, or first affected-scope heading in Diagnostics and repair inspection — Export Preview."
durable_effect = "Exact observational and artifact consequences: Cancel: No durable mutation occurs and no Receipt is created; Cancel closes only the current diagnostic presentation. No repair, quarantine, reset, file, or upload begins. Visible evidence remains available: The exact diagnostic fields and redactions are visible before export. | Create Diagnostic File: The Create Diagnostic File external result causes no local canonical mutation; it writes only the reviewed redacted fields to a user-chosen local artifact and records a separate egress Receipt. It never repairs, quarantines, resets, or uploads. Visible evidence before creation remains: The exact diagnostic fields and redactions are visible before export. Diagnostics never owns canonical repair, quarantine, reset, or deletion. Current visible status: The exact diagnostic fields and redactions are visible before export."
recovery_rollback = "Exact cancellation before handoff, during safely cancellable Repair work, and after Repair commit: Cancel: No Undo is required; focus returns to the initiating status or command with the inspected local state unchanged. | Create Diagnostic File: Cancellation before file creation changes nothing; cancellation during safely cancellable creation removes the incomplete temporary artifact and restores the preview; after creation the user controls deletion or sharing while the egress Receipt remains. Any post-commit rollback remains a separate Repair-owned typed command. Recovery preserves: The exact diagnostic fields and redactions are visible before export."
offline_behavior = "Health inspection, redacted previews, quarantine review, and Repair handoff remain local and offline. File creation uses a user-chosen local destination; no automatic upload or network dependency is introduced. Offline evidence remains: The exact diagnostic fields and redactions are visible before export."
accessibility_focus = "VoiceOver announces health class, affected scope, freshness, redaction, consequence, and safe action without exposing raw identifiers: Cancel announces affected scope and consequence; success focuses the Cancel result, preview, or first affected-scope heading in Diagnostics and repair inspection — Export Preview; rejection focuses the Cancel control and exact invalid field or blocked reason in Diagnostics and repair inspection — Export Preview | Create Diagnostic File announces affected scope and consequence; success focuses the Create Diagnostic File result, preview, or first affected-scope heading in Diagnostics and repair inspection — Export Preview; rejection focuses the Create Diagnostic File control and exact invalid field or blocked reason in Diagnostics and repair inspection — Export Preview. Dynamic Type stacks findings and preview fields. The announcement first communicates: The exact diagnostic fields and redactions are visible before export."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-EXPORT-PREVIEW-001"
label = "Cancel"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["The affected scope, diagnostics revision, and evidence freshness are current", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the originating You or Diagnostics context from Diagnostics and repair inspection — Export Preview"
destination_id = "DEST-YOU-DIAGNOSTICS-EXPORT-PREVIEW-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Cancel closes only the current diagnostic presentation. No repair, quarantine, reset, file, or upload begins. Visible evidence remains available: The exact diagnostic fields and redactions are visible before export."
success_focus = "the Cancel result, preview, or first affected-scope heading in Diagnostics and repair inspection — Export Preview"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-EXPORT-PREVIEW-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Cancel control and exact invalid field or blocked reason in Diagnostics and repair inspection — Export Preview"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-EXPORT-PREVIEW-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: cancellation or dismissal completes without canonical mutation."
rollback_undo = "No Undo is required; focus returns to the initiating status or command with the inspected local state unchanged."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-EXPORT-PREVIEW-001"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-EXPORT-PREVIEW-002"
label = "Create Diagnostic File"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["The affected scope, diagnostics revision, and evidence freshness are current", "The user explicitly chose a local file destination", "The user reviewed the exact allowlisted fields and redactions", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the user-chosen local diagnostic-file result from Diagnostics and repair inspection — Export Preview"
destination_id = "DEST-YOU-DIAGNOSTICS-EXPORT-PREVIEW-002"
destination_posture = "current"
effect = "The Create Diagnostic File external result causes no local canonical mutation; it writes only the reviewed redacted fields to a user-chosen local artifact and records a separate egress Receipt. It never repairs, quarantines, resets, or uploads. Visible evidence before creation remains: The exact diagnostic fields and redactions are visible before export."
success_focus = "the Create Diagnostic File result, preview, or first affected-scope heading in Diagnostics and repair inspection — Export Preview"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-EXPORT-PREVIEW-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Create Diagnostic File control and exact invalid field or blocked reason in Diagnostics and repair inspection — Export Preview"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-EXPORT-PREVIEW-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "External-result: local file creation occurs only after redacted preview and destination choice, outside canonical product-state mutation."
rollback_undo = "Cancellation before file creation changes nothing; cancellation during safely cancellable creation removes the incomplete temporary artifact and restores the preview; after creation the user controls deletion or sharing while the egress Receipt remains."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-EXPORT-PREVIEW-002"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DIAGNOSTICS-HEALTHY"
requirement_id = "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Done => destination: the originating You or Diagnostics context from Diagnostics and repair inspection — Healthy; effect: No durable mutation occurs and no Receipt is created; Done closes only the current diagnostic presentation. No repair, quarantine, reset, file, or upload begins. Visible evidence remains available: The local health check found no issue in the inspected scope.; focus: the Done result, preview, or first affected-scope heading in Diagnostics and repair inspection — Healthy."
durable_effect = "Exact observational and artifact consequences: Done: No durable mutation occurs and no Receipt is created; Done closes only the current diagnostic presentation. No repair, quarantine, reset, file, or upload begins. Visible evidence remains available: The local health check found no issue in the inspected scope. Diagnostics never owns canonical repair, quarantine, reset, or deletion. Current visible status: The local health check found no issue in the inspected scope."
recovery_rollback = "Exact cancellation before handoff, during safely cancellable Repair work, and after Repair commit: Done: No Undo is required; focus returns to the initiating status or command with the inspected local state unchanged. Any post-commit rollback remains a separate Repair-owned typed command. Recovery preserves: The local health check found no issue in the inspected scope."
offline_behavior = "Health inspection, redacted previews, quarantine review, and Repair handoff remain local and offline. File creation uses a user-chosen local destination; no automatic upload or network dependency is introduced. Offline evidence remains: The local health check found no issue in the inspected scope."
accessibility_focus = "VoiceOver announces health class, affected scope, freshness, redaction, consequence, and safe action without exposing raw identifiers: Done announces affected scope and consequence; success focuses the Done result, preview, or first affected-scope heading in Diagnostics and repair inspection — Healthy; rejection focuses the Done control and exact invalid field or blocked reason in Diagnostics and repair inspection — Healthy. Dynamic Type stacks findings and preview fields. The announcement first communicates: The local health check found no issue in the inspected scope."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-HEALTHY-001"
label = "Done"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["The affected scope, diagnostics revision, and evidence freshness are current", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the originating You or Diagnostics context from Diagnostics and repair inspection — Healthy"
destination_id = "DEST-YOU-DIAGNOSTICS-HEALTHY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Done closes only the current diagnostic presentation. No repair, quarantine, reset, file, or upload begins. Visible evidence remains available: The local health check found no issue in the inspected scope."
success_focus = "the Done result, preview, or first affected-scope heading in Diagnostics and repair inspection — Healthy"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-HEALTHY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Done control and exact invalid field or blocked reason in Diagnostics and repair inspection — Healthy"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-HEALTHY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: cancellation or dismissal completes without canonical mutation."
rollback_undo = "No Undo is required; focus returns to the initiating status or command with the inspected local state unchanged."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-HEALTHY-001"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DIAGNOSTICS-QUARANTINED"
requirement_id = "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Quarantine => destination: the redacted Repair-owned review for the exact affected scope from Diagnostics and repair inspection — Quarantined; effect: No durable mutation occurs and no Receipt is created; Review Quarantine opens only redacted inspection and a Repair-owned dry-run or quarantine explanation. It cannot repair, isolate, delete, or reset data. Visible evidence remains: Unsafe or uncertain information is protected for inspection before repair.; focus: the Review Quarantine result, preview, or first affected-scope heading in Diagnostics and repair inspection — Quarantined."
durable_effect = "Exact observational and artifact consequences: Review Quarantine: No durable mutation occurs and no Receipt is created; Review Quarantine opens only redacted inspection and a Repair-owned dry-run or quarantine explanation. It cannot repair, isolate, delete, or reset data. Visible evidence remains: Unsafe or uncertain information is protected for inspection before repair. Diagnostics never owns canonical repair, quarantine, reset, or deletion. Current visible status: Unsafe or uncertain information is protected for inspection before repair."
recovery_rollback = "Exact cancellation before handoff, during safely cancellable Repair work, and after Repair commit: Review Quarantine: No Undo is required; dismissal returns focus to the unchanged diagnostic status, and uncertain records remain protected rather than deleted. Any post-commit rollback remains a separate Repair-owned typed command. Recovery preserves: Unsafe or uncertain information is protected for inspection before repair."
offline_behavior = "Health inspection, redacted previews, quarantine review, and Repair handoff remain local and offline. File creation uses a user-chosen local destination; no automatic upload or network dependency is introduced. Offline evidence remains: Unsafe or uncertain information is protected for inspection before repair."
accessibility_focus = "VoiceOver announces health class, affected scope, freshness, redaction, consequence, and safe action without exposing raw identifiers: Review Quarantine announces affected scope and consequence; success focuses the Review Quarantine result, preview, or first affected-scope heading in Diagnostics and repair inspection — Quarantined; rejection focuses the Review Quarantine control and exact invalid field or blocked reason in Diagnostics and repair inspection — Quarantined. Dynamic Type stacks findings and preview fields. The announcement first communicates: Unsafe or uncertain information is protected for inspection before repair."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-QUARANTINED-001"
label = "Review Quarantine"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["The affected scope, diagnostics revision, and evidence freshness are current", "The quarantined record identities and reason are available without private content", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the redacted Repair-owned review for the exact affected scope from Diagnostics and repair inspection — Quarantined"
destination_id = "DEST-YOU-DIAGNOSTICS-QUARANTINED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Quarantine opens only redacted inspection and a Repair-owned dry-run or quarantine explanation. It cannot repair, isolate, delete, or reset data. Visible evidence remains: Unsafe or uncertain information is protected for inspection before repair."
success_focus = "the Review Quarantine result, preview, or first affected-scope heading in Diagnostics and repair inspection — Quarantined"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-QUARANTINED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Quarantine control and exact invalid field or blocked reason in Diagnostics and repair inspection — Quarantined"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-QUARANTINED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: review and handoff complete before any Repair-owned confirmation or canonical commit."
rollback_undo = "No Undo is required; dismissal returns focus to the unchanged diagnostic status, and uncertain records remain protected rather than deleted."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-QUARANTINED-001"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DIAGNOSTICS-RECOVERABLE"
requirement_id = "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Review Repair => destination: the redacted Repair-owned review for the exact affected scope from Diagnostics and repair inspection — Recoverable; effect: No durable mutation occurs and no Receipt is created; Review Repair opens only redacted inspection and a Repair-owned dry-run or quarantine explanation. It cannot repair, isolate, delete, or reset data. Visible evidence remains: A limited issue has a recoverable saved copy. Saved information remains protected.; focus: the Review Repair result, preview, or first affected-scope heading in Diagnostics and repair inspection — Recoverable."
durable_effect = "Exact observational and artifact consequences: Review Repair: No durable mutation occurs and no Receipt is created; Review Repair opens only redacted inspection and a Repair-owned dry-run or quarantine explanation. It cannot repair, isolate, delete, or reset data. Visible evidence remains: A limited issue has a recoverable saved copy. Saved information remains protected. Diagnostics never owns canonical repair, quarantine, reset, or deletion. Current visible status: A limited issue has a recoverable saved copy. Saved information remains protected."
recovery_rollback = "Exact cancellation before handoff, during safely cancellable Repair work, and after Repair commit: Review Repair: No Undo is required; dismissal returns focus to the unchanged diagnostic status, and uncertain records remain protected rather than deleted. Any post-commit rollback remains a separate Repair-owned typed command. Recovery preserves: A limited issue has a recoverable saved copy. Saved information remains protected."
offline_behavior = "Health inspection, redacted previews, quarantine review, and Repair handoff remain local and offline. File creation uses a user-chosen local destination; no automatic upload or network dependency is introduced. Offline evidence remains: A limited issue has a recoverable saved copy. Saved information remains protected."
accessibility_focus = "VoiceOver announces health class, affected scope, freshness, redaction, consequence, and safe action without exposing raw identifiers: Review Repair announces affected scope and consequence; success focuses the Review Repair result, preview, or first affected-scope heading in Diagnostics and repair inspection — Recoverable; rejection focuses the Review Repair control and exact invalid field or blocked reason in Diagnostics and repair inspection — Recoverable. Dynamic Type stacks findings and preview fields. The announcement first communicates: A limited issue has a recoverable saved copy. Saved information remains protected."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-RECOVERABLE-001"
label = "Review Repair"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["Core/LocalRuntimeOS/Repair owns any later canonical mutation", "The affected scope, diagnostics revision, and evidence freshness are current", "The current canonical revision and exact affected scope are revalidated", "The dry-run result, verified recovery point, explicit confirmation, and rollback plan are present before Repair may commit", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the redacted Repair-owned review for the exact affected scope from Diagnostics and repair inspection — Recoverable"
destination_id = "DEST-YOU-DIAGNOSTICS-RECOVERABLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Review Repair opens only redacted inspection and a Repair-owned dry-run or quarantine explanation. It cannot repair, isolate, delete, or reset data. Visible evidence remains: A limited issue has a recoverable saved copy. Saved information remains protected."
success_focus = "the Review Repair result, preview, or first affected-scope heading in Diagnostics and repair inspection — Recoverable"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-RECOVERABLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Review Repair control and exact invalid field or blocked reason in Diagnostics and repair inspection — Recoverable"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-RECOVERABLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: review and handoff complete before any Repair-owned confirmation or canonical commit."
rollback_undo = "No Undo is required; dismissal returns focus to the unchanged diagnostic status, and uncertain records remain protected rather than deleted."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-RECOVERABLE-001"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DIAGNOSTICS-REPAIR-PREVIEW"
requirement_id = "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel => destination: the originating You or Diagnostics context from Diagnostics and repair inspection — Repair Preview; effect: No durable mutation occurs and no Receipt is created; Cancel closes only the current diagnostic presentation. No repair, quarantine, reset, file, or upload begins. Visible evidence remains available: A proposed repair and its affected information are visible. The affected information still matches its saved value.; focus: the Cancel result, preview, or first affected-scope heading in Diagnostics and repair inspection — Repair Preview.\nQuarantine Affected Data => destination: the Core/LocalRuntimeOS/Repair confirmation owned by the exact affected scope from Diagnostics and repair inspection — Repair Preview; effect: No durable mutation occurs and no Receipt is created; Quarantine Affected Data is only a handoff carrying current revision, affected scope, dry-run result, verified recovery point, explicit confirmation requirement, and rollback plan to Core/LocalRuntimeOS/Repair. Diagnostics cannot commit repair or quarantine. Visible evidence remains: A proposed repair and its affected information are visible. The affected information still matches its saved value.; focus: the Quarantine Affected Data result, preview, or first affected-scope heading in Diagnostics and repair inspection — Repair Preview.\nRun Repair => destination: the Core/LocalRuntimeOS/Repair confirmation owned by the exact affected scope from Diagnostics and repair inspection — Repair Preview; effect: No durable mutation occurs and no Receipt is created; Run Repair is only a handoff carrying current revision, affected scope, dry-run result, verified recovery point, explicit confirmation requirement, and rollback plan to Core/LocalRuntimeOS/Repair. Diagnostics cannot commit repair or quarantine. Visible evidence remains: A proposed repair and its affected information are visible. The affected information still matches its saved value.; focus: the Run Repair result, preview, or first affected-scope heading in Diagnostics and repair inspection — Repair Preview."
durable_effect = "Exact observational and artifact consequences: Cancel: No durable mutation occurs and no Receipt is created; Cancel closes only the current diagnostic presentation. No repair, quarantine, reset, file, or upload begins. Visible evidence remains available: A proposed repair and its affected information are visible. The affected information still matches its saved value. | Quarantine Affected Data: No durable mutation occurs and no Receipt is created; Quarantine Affected Data is only a handoff carrying current revision, affected scope, dry-run result, verified recovery point, explicit confirmation requirement, and rollback plan to Core/LocalRuntimeOS/Repair. Diagnostics cannot commit repair or quarantine. Visible evidence remains: A proposed repair and its affected information are visible. The affected information still matches its saved value. | Run Repair: No durable mutation occurs and no Receipt is created; Run Repair is only a handoff carrying current revision, affected scope, dry-run result, verified recovery point, explicit confirmation requirement, and rollback plan to Core/LocalRuntimeOS/Repair. Diagnostics cannot commit repair or quarantine. Visible evidence remains: A proposed repair and its affected information are visible. The affected information still matches its saved value. Diagnostics never owns canonical repair, quarantine, reset, or deletion. Current visible status: A proposed repair and its affected information are visible. The affected information still matches its saved value."
recovery_rollback = "Exact cancellation before handoff, during safely cancellable Repair work, and after Repair commit: Cancel: No Undo is required; focus returns to the initiating status or command with the inspected local state unchanged. | Quarantine Affected Data: Cancellation before Repair commit changes nothing; cancellation during a safely cancellable Repair operation restores the verified checkpoint; after Repair commit, rollback is a separate typed repair or restore command with its own Receipt. | Run Repair: Cancellation before Repair commit changes nothing; cancellation during a safely cancellable Repair operation restores the verified checkpoint; after Repair commit, rollback is a separate typed repair or restore command with its own Receipt. Any post-commit rollback remains a separate Repair-owned typed command. Recovery preserves: A proposed repair and its affected information are visible. The affected information still matches its saved value."
offline_behavior = "Health inspection, redacted previews, quarantine review, and Repair handoff remain local and offline. File creation uses a user-chosen local destination; no automatic upload or network dependency is introduced. Offline evidence remains: A proposed repair and its affected information are visible. The affected information still matches its saved value."
accessibility_focus = "VoiceOver announces health class, affected scope, freshness, redaction, consequence, and safe action without exposing raw identifiers: Cancel announces affected scope and consequence; success focuses the Cancel result, preview, or first affected-scope heading in Diagnostics and repair inspection — Repair Preview; rejection focuses the Cancel control and exact invalid field or blocked reason in Diagnostics and repair inspection — Repair Preview | Quarantine Affected Data announces affected scope and consequence; success focuses the Quarantine Affected Data result, preview, or first affected-scope heading in Diagnostics and repair inspection — Repair Preview; rejection focuses the Quarantine Affected Data control and exact invalid field or blocked reason in Diagnostics and repair inspection — Repair Preview | Run Repair announces affected scope and consequence; success focuses the Run Repair result, preview, or first affected-scope heading in Diagnostics and repair inspection — Repair Preview; rejection focuses the Run Repair control and exact invalid field or blocked reason in Diagnostics and repair inspection — Repair Preview. Dynamic Type stacks findings and preview fields. The announcement first communicates: A proposed repair and its affected information are visible. The affected information still matches its saved value."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-REPAIR-PREVIEW-001"
label = "Cancel"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["The affected scope, diagnostics revision, and evidence freshness are current", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the originating You or Diagnostics context from Diagnostics and repair inspection — Repair Preview"
destination_id = "DEST-YOU-DIAGNOSTICS-REPAIR-PREVIEW-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Cancel closes only the current diagnostic presentation. No repair, quarantine, reset, file, or upload begins. Visible evidence remains available: A proposed repair and its affected information are visible. The affected information still matches its saved value."
success_focus = "the Cancel result, preview, or first affected-scope heading in Diagnostics and repair inspection — Repair Preview"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-REPAIR-PREVIEW-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Cancel control and exact invalid field or blocked reason in Diagnostics and repair inspection — Repair Preview"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-REPAIR-PREVIEW-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: cancellation or dismissal completes without canonical mutation."
rollback_undo = "No Undo is required; focus returns to the initiating status or command with the inspected local state unchanged."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-REPAIR-PREVIEW-001"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-REPAIR-PREVIEW-002"
label = "Quarantine Affected Data"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["Core/LocalRuntimeOS/Repair owns any later canonical mutation", "The affected scope, diagnostics revision, and evidence freshness are current", "The current canonical revision and exact affected scope are revalidated", "The dry-run result, verified recovery point, explicit confirmation, and rollback plan are present before Repair may commit", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the Core/LocalRuntimeOS/Repair confirmation owned by the exact affected scope from Diagnostics and repair inspection — Repair Preview"
destination_id = "DEST-YOU-DIAGNOSTICS-REPAIR-PREVIEW-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Quarantine Affected Data is only a handoff carrying current revision, affected scope, dry-run result, verified recovery point, explicit confirmation requirement, and rollback plan to Core/LocalRuntimeOS/Repair. Diagnostics cannot commit repair or quarantine. Visible evidence remains: A proposed repair and its affected information are visible. The affected information still matches its saved value."
success_focus = "the Quarantine Affected Data result, preview, or first affected-scope heading in Diagnostics and repair inspection — Repair Preview"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-REPAIR-PREVIEW-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Quarantine Affected Data control and exact invalid field or blocked reason in Diagnostics and repair inspection — Repair Preview"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-REPAIR-PREVIEW-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Diagnostics ends at the Repair-owned consequence preview; any later mutation uses a separately authorized typed Repair command."
rollback_undo = "Cancellation before Repair commit changes nothing; cancellation during a safely cancellable Repair operation restores the verified checkpoint; after Repair commit, rollback is a separate typed repair or restore command with its own Receipt."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-REPAIR-PREVIEW-002"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-REPAIR-PREVIEW-003"
label = "Run Repair"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["Core/LocalRuntimeOS/Repair owns any later canonical mutation", "The affected scope, diagnostics revision, and evidence freshness are current", "The current canonical revision and exact affected scope are revalidated", "The dry-run result, verified recovery point, explicit confirmation, and rollback plan are present before Repair may commit", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the Core/LocalRuntimeOS/Repair confirmation owned by the exact affected scope from Diagnostics and repair inspection — Repair Preview"
destination_id = "DEST-YOU-DIAGNOSTICS-REPAIR-PREVIEW-003"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Run Repair is only a handoff carrying current revision, affected scope, dry-run result, verified recovery point, explicit confirmation requirement, and rollback plan to Core/LocalRuntimeOS/Repair. Diagnostics cannot commit repair or quarantine. Visible evidence remains: A proposed repair and its affected information are visible. The affected information still matches its saved value."
success_focus = "the Run Repair result, preview, or first affected-scope heading in Diagnostics and repair inspection — Repair Preview"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-REPAIR-PREVIEW-003-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Run Repair control and exact invalid field or blocked reason in Diagnostics and repair inspection — Repair Preview"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-REPAIR-PREVIEW-003-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Diagnostics ends at the Repair-owned consequence preview; any later mutation uses a separately authorized typed Repair command."
rollback_undo = "Cancellation before Repair commit changes nothing; cancellation during a safely cancellable Repair operation restores the verified checkpoint; after Repair commit, rollback is a separate typed repair or restore command with its own Receipt."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-REPAIR-PREVIEW-003"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-YOU-DIAGNOSTICS-UNKNOWN"
requirement_id = "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Run Health Check => destination: the refreshed redacted health status or exact failed diagnostic step from Diagnostics and repair inspection — Unknown; effect: No durable mutation occurs and no Receipt is created; Run Health Check repeats only observational inspection against current evidence. It cannot repair, quarantine, reset, or automatically create an export. Visible evidence remains until a reliable result exists: The health check does not have a reliable result yet. Saved information remains available.; focus: the Run Health Check result, preview, or first affected-scope heading in Diagnostics and repair inspection — Unknown."
durable_effect = "Exact observational and artifact consequences: Run Health Check: No durable mutation occurs and no Receipt is created; Run Health Check repeats only observational inspection against current evidence. It cannot repair, quarantine, reset, or automatically create an export. Visible evidence remains until a reliable result exists: The health check does not have a reliable result yet. Saved information remains available. Diagnostics never owns canonical repair, quarantine, reset, or deletion. Current visible status: The health check does not have a reliable result yet. Saved information remains available."
recovery_rollback = "Exact cancellation before handoff, during safely cancellable Repair work, and after Repair commit: Run Health Check: Cancellation preserves the prior reliable health status; interruption may resume the inspection without replaying a Repair or export action. Any post-commit rollback remains a separate Repair-owned typed command. Recovery preserves: The health check does not have a reliable result yet. Saved information remains available."
offline_behavior = "Health inspection, redacted previews, quarantine review, and Repair handoff remain local and offline. File creation uses a user-chosen local destination; no automatic upload or network dependency is introduced. Offline evidence remains: The health check does not have a reliable result yet. Saved information remains available."
accessibility_focus = "VoiceOver announces health class, affected scope, freshness, redaction, consequence, and safe action without exposing raw identifiers: Run Health Check announces affected scope and consequence; success focuses the Run Health Check result, preview, or first affected-scope heading in Diagnostics and repair inspection — Unknown; rejection focuses the Run Health Check control and exact invalid field or blocked reason in Diagnostics and repair inspection — Unknown. Dynamic Type stacks findings and preview fields. The announcement first communicates: The health check does not have a reliable result yet. Saved information remains available."

[[state_command_contracts.commands]]
command_id = "CMD-YOU-DIAGNOSTICS-UNKNOWN-001"
label = "Run Health Check"
canonical_owner = "system.diagnostics.command-contract"
preconditions = ["The affected scope, diagnostics revision, and evidence freshness are current", "Visible records use opaque identifiers and an allowlisted redacted field set"]
destination = "the refreshed redacted health status or exact failed diagnostic step from Diagnostics and repair inspection — Unknown"
destination_id = "DEST-YOU-DIAGNOSTICS-UNKNOWN-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Run Health Check repeats only observational inspection against current evidence. It cannot repair, quarantine, reset, or automatically create an export. Visible evidence remains until a reliable result exists: The health check does not have a reliable result yet. Saved information remains available."
success_focus = "the Run Health Check result, preview, or first affected-scope heading in Diagnostics and repair inspection — Unknown"
success_focus_id = "FOCUS-YOU-DIAGNOSTICS-UNKNOWN-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Run Health Check control and exact invalid field or blocked reason in Diagnostics and repair inspection — Unknown"
failure_focus_id = "FOCUS-YOU-DIAGNOSTICS-UNKNOWN-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: observational health inspection completes without canonical state mutation."
rollback_undo = "Cancellation preserves the prior reliable health status; interruption may resume the inspection without replaying a Repair or export action."
recovery_id = "RECOVERY-YOU-DIAGNOSTICS-UNKNOWN-001"
recovery_posture = "current"
recovery_owner = "system.diagnostics.command-contract"
privacy_egress = "Diagnostics uses opaque identifiers and allowlisted redacted fields; it never uploads automatically, and only explicit user-chosen local artifact creation can produce an egress Receipt."
verification_ids = ["SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

+++

# Diagnostics

This target specifies private, local, redacted diagnostics and user-understandable health. It does not establish analytics, telemetry, implementation completeness, privacy approval, incident closure, or release proof.

## SYSTEM-DIAGNOSTICS-HEALTH-001 — Health is evidence-backed, scoped, and redacted

- **Concept:** `system.diagnostics.redacted-health`
- **Modality:** `MUST`
- **Scope:** Commands, projections, stores, replay, sync, Source Atlas, privacy firewall, imports, external writes, and performance/resource state
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-DIAGNOSTICS-HEALTH-001`
- **Supersedes:** none

Each major subsystem MUST report healthy, degraded, recoverable, quarantined, blocked, or unknown from current evidence with affected scope, freshness, correlation, safe actions, and privacy annotation. User-facing health appears only when action or interpretation changes and uses product language rather than raw architecture. Logs and support packages exclude private content by default.

Diagnostics MUST expose sync health, local-store health, index status, extension status, and a privacy-reviewed debug export.

## SYSTEM-DIAGNOSTICS-AUTHORITY-001 — Diagnostics observe and propose; they never decide or repair silently

- **Concept:** `system.diagnostics.non-authority`
- **Modality:** `MUST NOT`
- **Scope:** Runtime inspection, support export, health checks, incident response, and repair routing
- **Status:** `normative`
- **Verification:** `AUDIT-SYSTEM-DIAGNOSTICS-NO-MUTATION-001`
- **Supersedes:** none

A diagnostic may produce a redacted diagnosis and typed repair proposal; any repair that changes state requires preview, rollback/backup protection, runtime Command/Event/Projection/Receipt/Replay, and post-repair invariants.

## SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001 — Diagnostics commands observe, preview, and hand off without authority

- **Concept:** `system.diagnostics.command-contract`
- **Modality:** `MUST`
- **Scope:** Redacted health inspection, retry, quarantine and repair handoff, local diagnostic export, cancellation, focus, offline use, privacy, and accessibility
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001`
- **Supersedes:** none

Diagnostics MUST remain observational. It may run `Run Health Check`, `Try Again`, `Inspect`, `Review Quarantine`, `Review Repair`, `Preview Diagnostic Export`, `Cancel`, and `Done`. It MUST NOT directly repair, quarantine, reset, or mutate canonical state.

Visible commands `Quarantine Affected Data` and `Run Repair` MUST hand off to `Core/LocalRuntimeOS/Repair/` with current revision, affected scope, dry-run result, verified recovery point, confirmation, and rollback plan. Quarantine isolates uncertain records and MUST NOT delete them.

Diagnostic export MUST show an allowlisted redacted preview before `Create Diagnostic File`; creation writes only a local user-chosen artifact and egress Receipt. It MUST NOT upload automatically.

Cancellation before repair commit changes nothing. Cancellation during a safely cancellable operation restores the verified checkpoint. After commit, rollback is a separate typed repair/restore command.


Focus moves from health status to the affected scope, then repair/export preview, exact invalid field, or result. Diagnostic traces exclude private content and use opaque identifiers.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Owns structured categories, correlation/signposts, bounded retention, subsystem health, privacy annotation, user diagnostics presentation model, reviewed support export, and incident evidence routing. It does not own product policy, canonical mutation, repair execution, telemetry by default, or proof-status promotion.

<!-- canon-section: inputs-outputs -->
The contract consumes redacted subsystem signals and emits scoped health and safe actions.
The contract consumes redacted runtime/store/projection/privacy/sync/import/effect/performance signals, policy revision, freshness, and correlation IDs. It emits scoped health, redacted traces/diagnosis, safe inspection actions, repair proposal link, and reviewed diagnostic export manifest.

<!-- canon-section: authority-boundary -->
`Core/LocalRuntimeOS/Diagnostics/` reads bounded inspector interfaces; `Inspection/` owns history facts; `PrivacySecurity/` redacts; app `Diagnostics/` and You present. Diagnostics cannot access unrestricted private values or write canonical stores.

<!-- canon-section: data-classification -->
Diagnostic data is redacted local metadata. Raw titles, notes, schedules, attachments, proof, behavior context, tokens, keys, and payloads are excluded by default; explicit support export previews every field/destination and remains user-controlled egress.

<!-- canon-section: state-model -->
Health binds subsystem/scope, category/severity, evidence source and age, correlation, privacy class, current status, safe action set, export inclusion, incident link, and resolution evidence.

<!-- canon-section: failure-recovery -->
Logging/inspection/export failure never blocks core or fabricates health. Overflow coalesces or drops low-priority diagnostics visibly; corrupt diagnosis is quarantined. Recovery re-reads current facts and preserves unresolved incident/history evidence.

<!-- canon-section: local-network-boundary -->
Health, traces, diagnosis, and repair routing operate locally/no-account. No telemetry or support upload is implicit; any diagnostic export is explicitly previewed/redacted egress. Server profiling and private analytics are excluded.

<!-- canon-section: determinism -->
Stable evidence, freshness, privacy policy, and health rules select the same status/action set. Diagnostic timing cannot change canonical state or the truth of the operation observed.

<!-- canon-section: observability -->
Local counters expose diagnostic volume, retention, and export behavior.
The diagnostic system observes itself through bounded volume/drop/retention/export counters and stable correlation while excluding private values. Evidence age, environment, source revision, and gaps remain explicit.

<!-- canon-section: source-ownership -->
Canonical ownership is divided among runtime Diagnostics, Inspection, PrivacySecurity, app presentation, and Quality.
Exact targets are `Core/LocalRuntimeOS/Diagnostics/`, `Inspection/`, and `PrivacySecurity/`; app `Diagnostics/` and `Surfaces/You/` present, while `Quality/` owns proof. app-wide consumption, calibrated budgets, incident operations, privacy approval, and release evidence remain separate.

<!-- canon-section: tests-proof -->
Executable scenarios exercise every health class, redaction boundary, and non-mutation rule.
Exercise every health class and subsystem, stale/missing/conflicting evidence, redaction of every private class, overflow/retention, support export preview/cancel, malicious log payload, no mutation, repair handoff, incident correlation, offline/no-account, accessibility, and proof-ceiling enforcement.

<!-- canon-section: performance-resource-constraints -->
Logging, signposts, health aggregation, retention, export, and inspectors use bounded queues/storage, sampling/coalescing, cancellation, and no unbounded polling; material work stays off-main. Article 31 calibration must declare representative signal/export scale, device/OS/build/tool, percentile/maximum, memory/energy/storage, and regression thresholds; no numeric budget is invented.
