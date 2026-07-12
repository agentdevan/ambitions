+++
spec_id = "JOURNEY-CAPTURE-TO-PLACEMENT"
title = "Capture to Placement"
kind = "journey"
status = "normative"
owner_domain = "journey-capture-to-placement"
canon_revision = 1
profile = "journey-v1"
owns_concepts = [
  "journey.first-use.trigger",
  "journey.capture.commit-boundary",
  "journey.saved-for-later.durable-save",
  "journey.offline-create.trigger",
]
inherits = ["CONTROL-FORCE-NOTHING-001", "CONTROL-MATERIAL-CONFIRMATION-001", "LAW-RUNTIME-DURABLE-SUCCESS-001", "LAW-OFFLINE-NO-ACCOUNT-001"]
depends_on = ["CONSTITUTION", "GLOBAL-CAPTURE", "OBJECT-SAVED-FOR-LATER-DRAFT", "OBJECT-SCHEDULE-PLACEMENT", "SURFACE-TIME"]
source_owners = ["Native/Ambitions/Composer/Capture/", "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Quality/"]
+++

# Capture to Placement

This shadow journey coordinates owning contracts; it does not redefine object lifecycle or claim current implementation.

## JOURNEY-FIRST-USE-001 — First useful intent starts without setup coercion

- **Concept:** `journey.first-use.trigger`
- **Modality:** `MUST`
- **Scope:** First Capture before account or setup completion
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-FIRST-USE-001`
- **Supersedes:** none

The first useful trigger MUST allow local Capture immediately, with optional context explained in place and no forced account, questionnaire, classification, deadline, or placement.

## JOURNEY-CAPTURE-PLACEMENT-001 — Proposal is not placement

- **Concept:** `journey.capture.commit-boundary`
- **Modality:** `MUST`
- **Scope:** Draft interpretation, object creation, and Time placement
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-CAPTURE-PLACEMENT-001`
- **Supersedes:** none

A type or placement proposal MUST remain explicitly non-durable. Only a validated, confirmed canonical command may create the object or Schedule Placement; durable success begins after the local commit and Receipt, while any external effect is separately pending.

## JOURNEY-SAVED-FOR-LATER-001 — Unresolved save is durable without promotion

- **Concept:** `journey.saved-for-later.durable-save`
- **Modality:** `MUST`
- **Scope:** Capture that the user declines to type, schedule, or place
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-SAVED-FOR-LATER-001`
- **Supersedes:** none

Save for Later MUST durably preserve the original draft identity and make it locally searchable without silently creating, scheduling, or promoting an executable object.

## JOURNEY-OFFLINE-CREATE-001 — Offline creation uses the same local boundary

- **Concept:** `journey.offline-create.trigger`
- **Modality:** `MUST`
- **Scope:** Capture and accepted local creation without account or network
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-OFFLINE-CREATE-001`
- **Supersedes:** none

An offline Capture MUST use the same local validation, confirmation, commit, Receipt, replay, and recovery path as online use; optional reference assistance may be unavailable but cannot gate creation.

<!-- canon-section: trigger-starting-state -->
Triggers are first launch Capture, shell or contextual Capture, Share/deep-link intake, recovered draft, or offline intent; starting state records origin, draft identity, local-store health, permission state, and network-independent capability.

<!-- canon-section: preconditions -->
The local store can preserve a draft; the canonical destination is available or unresolved save is offered; placement proposals have current Time constraints. Account and network are never preconditions.

<!-- canon-section: happy-path -->
Preserve input, expose editable type, gather only required metadata, compute a non-durable proposal, show material consequences, accept explicit confirmation, validate the canonical command, commit locally, project the result, issue a Receipt, and offer the owning object or Time route.

<!-- canon-section: branches -->
Branches are direct unplaced save, confirmed placement, choose another proposal, edit type/metadata, Save for Later, attachment removal/retry, accept a visible conflict, or reject every suggestion. Object lifecycle and placement semantics remain owned by their referenced specifications.

<!-- canon-section: cancellation -->
Cancel before commit returns to origin with the draft intact; explicit discard requires consequence confirmation. Canceling optional processing leaves the draft usable and creates no object or placement.

<!-- canon-section: interruption-resume -->
Interruption, crash, permission handoff, or process termination resumes the same draft, stage, proposal freshness marker, attachment state, origin, and focus. A stale proposal is recomputed and never auto-accepted.

<!-- canon-section: commit-boundary -->
The accepted command binds one draft identity to one canonical destination and records whether placement is included in the same confirmed scope.
Draft autosave and Save for Later are their own durable states. Object creation and placement remain non-durable through preview; the boundary is successful validation plus authoritative local commit, after which success may be shown and external work is queued separately.

<!-- canon-section: failure -->
Invalid metadata, stale constraints, attachment failure, store degradation, command rejection, projection delay, or external failure cannot destroy input or report a false save. Partial attachment and external results remain explicit.

<!-- canon-section: recovery -->
Recovery offers exact-field edit, remove/replace attachment, refresh proposal, retry idempotently, Save for Later, export original input where safe, or return to the last durable state.

<!-- canon-section: undo-rollback -->
Undo after accepted creation routes through the canonical owner and preserves lineage and Receipt history; placement rollback restores the prior valid Time state. External effects reconcile after local rollback rather than being assumed reversed.

<!-- canon-section: receipts-proof -->
Draft save, unresolved save, accepted creation, placement, undo, and external result have distinct Receipts/History. User Proof is neither required nor fabricated unless the destination object already declares it in advance.

<!-- canon-section: accessibility -->
Semantics order origin/close, input, type, attachments, proposal, consequences, alternatives, confirmation, and result; every spatial choice has a named action, validation receives focus, Dynamic Type reflows above the keyboard, reduced effects preserve announcements, and resume restores focus.

<!-- canon-section: offline -->
The local path performs classification, validation, mutation, projection, Receipt creation, replay, and undo from device-owned facts.
Composition, deterministic core classification, unresolved save, local object creation, placement, Receipt, replay, Search reachability, and undo work without account/network; unavailable optional sources are labeled without private egress.

<!-- canon-section: scenario-tests -->
Execute `SCENARIO-JOURNEY-FIRST-USE-001`, `SCENARIO-JOURNEY-CAPTURE-PLACEMENT-001`, `SCENARIO-JOURNEY-SAVED-FOR-LATER-001`, `SCENARIO-JOURNEY-OFFLINE-CREATE-001`, `SCENARIO-JOURNEY-CAPTURE-CANCEL-001`, `SCENARIO-JOURNEY-CAPTURE-RESUME-001`, and `SCENARIO-JOURNEY-CAPTURE-ROLLBACK-001`; tests bind draft/object/placement IDs and assert preview non-durability, one local commit, truthful receipts, offline parity, focus recovery, and no forced choice.
