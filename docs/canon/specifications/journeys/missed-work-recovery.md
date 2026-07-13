+++
spec_id = "JOURNEY-MISSED-WORK-RECOVERY"
title = "Missed Work Recovery"
kind = "journey"
status = "normative"
owner_domain = "journey-missed-work-recovery"
canon_revision = 1
profile = "journey-v1"
owns_concepts = ["journey.recovery.material-confirmation"]
inherits = ["CONTROL-FORCE-NOTHING-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONTROL-UNDO-RECOVERY-001", "LAW-RUNTIME-DURABLE-SUCCESS-001"]
depends_on = ["CONSTITUTION", "SURFACE-TODAY", "SURFACE-GOALS", "SURFACE-TIME", "OBJECT-RECOVERY-SEGMENT", "OBJECT-STEP", "OBJECT-GOAL-PATH", "GLOBAL-MOTION"]
source_owners = ["Native/Ambitions/Surfaces/Today/", "Native/Ambitions/Surfaces/Goals/", "Native/Ambitions/Surfaces/Time/", "Native/Ambitions/Stage/Motion/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Quality/"]
+++

# Missed Work Recovery

This shadow journey coordinates humane recovery choices while owning objects retain lifecycle, placement, and path semantics.

## JOURNEY-RECOVERY-001 — Material recovery requires confirmation

- **Concept:** `journey.recovery.material-confirmation`
- **Modality:** `MUST`
- **Scope:** Missed Step or path segment and proposed schedule/path adaptation
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-RECOVERY-001`
- **Supersedes:** none

Recovery MUST preserve the last honest state and present non-shaming choices. Moving committed time, changing required work, altering a path, or affecting protected boundaries remains a non-durable proposal until materially confirmed; missed work never authorizes silent reflow.

When a Goal enters Needs Attention or Recovering, Ambitions MUST show what changed, why attention is needed, the Recommended step, route and schedule impact, Proof gaps, and one clear recovery action.

Minor recovery MAY apply only within user-authorized automation and MUST remain visible through a marker, Receipt, History, and Undo.

After a missed Step, Ambitions MAY ask one necessary non-shaming question about what changed.

A review MAY suggest a future Goal Path change but MUST NOT commit it silently.

After several days of plan divergence, Ambitions MAY ask one necessary non-shaming question and MUST keep any response contextual, inspectable, and correctable.

<!-- canon-section: trigger-starting-state -->
Triggers are elapsed placement without closure, user-declared miss/block, repeated mismatch the user chooses to review, or return after interruption; starting state identifies affected Steps/path, proof/closure state, current capacity, deadlines, dependencies, protected boundaries, and prior recovery history.

<!-- canon-section: preconditions -->
No completion is inferred; current facts and last honest state are readable; recovery can preserve identity and thread of progress. Behavioral observations cannot diagnose character, motivation, or health.

<!-- canon-section: happy-path -->
Acknowledge what still counts, explain the concrete mismatch, generate bounded non-durable options, preview affected objects/time/path/proof, let the user choose or reject, confirm material scope, commit locally, project a Recovery Segment and updated plan, and issue Receipts.

<!-- canon-section: branches -->
Branches are Still counts, Move it, Blocked, Waiting, Not needed, resume unchanged, choose a lighter Step/path, protect a boundary, defer review, or reject every proposal. The user may accept a visible conflict.

<!-- canon-section: cancellation -->
Dismissal or cancellation preserves the missed Step and existing plan without penalty, score, escalation, or automatic movement. A draft recovery note remains only if explicitly saved.

<!-- canon-section: interruption-resume -->
The recovery draft binds the affected identities, selected options, user corrections, proposal fingerprint, facts fingerprint, and focus.
Resume the same recovery context, selected/nonselected options, user corrections, proposal revision, and focus. Changed reality invalidates affected options and produces a fresh preview, not silent adaptation.

<!-- canon-section: commit-boundary -->
One confirmed command names every affected object, placement, path node, protected boundary, and accepted recovery choice.
Observation, explanation, recommendation, simulation, and option selection remain non-durable. The boundary is confirmed, revalidated local commit of chosen object/path/placement changes and Receipt; external effects follow separately.

<!-- canon-section: failure -->
Insufficient facts, stale constraints, impossible dependency, local rejection, projection failure, or external failure cannot erase work, fabricate closure, or shame the user; each affected change retains truthful status.

<!-- canon-section: recovery -->
Recovery from recovery failure offers keep current plan, edit constraints, reduce scope, choose another concrete state, recompute, retry idempotently, inspect history, or export/repair when local health requires it.

<!-- canon-section: undo-rollback -->
Undo restores prior path/placements and preserves the Recovery Segment, correction, and Receipt history. External reversals reconcile separately; completed work and user Proof are not erased by schedule rollback.

<!-- canon-section: receipts-proof -->
Receipt/history record the triggering fact without moral inference, options shown, user choice/correction, affected IDs, local commit, external results, and undo. Existing Proof and honest closure state survive recovery.

<!-- canon-section: accessibility -->
Semantics present what happened, what remains true, each option and consequence, protected boundaries, confirmation, and result in stable order; choices never depend on gesture/color, Dynamic Type stacks comparisons, reduced motion preserves continuity via announcements, and focus returns to the affected Step.

<!-- canon-section: offline -->
Local facts drive the recovery options, consequence review, canonical commit, projection, Receipt, replay, and undo.
Miss detection from local facts, option generation available locally, review, commit, Recovery Segment, receipts, replay, and undo work without account/network; unavailable external freshness is labeled and cannot force a choice.

<!-- canon-section: scenario-tests -->
Execute `SCENARIO-JOURNEY-RECOVERY-001`, `SCENARIO-JOURNEY-RECOVERY-CANCEL-001`, `SCENARIO-JOURNEY-RECOVERY-STALE-001`, `SCENARIO-JOURNEY-RECOVERY-PROTECTED-001`, `SCENARIO-JOURNEY-RECOVERY-OFFLINE-001`, and `SCENARIO-JOURNEY-RECOVERY-UNDO-001`; assert humane language, Force Nothing, preview non-durability, identity/proof preservation, confirmed local commit, external ordering, accessibility, and replay.
