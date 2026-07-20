+++
spec_id = "JOURNEY-START-AND-COMPLETE-STEP"
title = "Start and Complete Step"
kind = "journey"
status = "normative"
owner_domain = "journey-start-and-complete-step"
canon_revision = 1
profile = "journey-v1"
owns_concepts = ["journey.step.start-complete"]
inherits = ["CONTROL-FORCE-NOTHING-001", "OBJECT-PROOF-REQUIREMENT-001", "LAW-RUNTIME-DURABLE-SUCCESS-001", "CONTROL-UNDO-RECOVERY-001"]
depends_on = ["CONSTITUTION", "SURFACE-TODAY", "OBJECT-STEP", "OBJECT-CLOSURE", "OBJECT-PROOF", "GLOBAL-MOTION", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Surfaces/Today/", "Native/Ambitions/Stage/Motion/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Trust/", "Native/Ambitions/Quality/"]
+++

# Start and Complete Step

This journey coordinates execution entry and completion while Step, Closure, and Proof specifications retain lifecycle authority.

## JOURNEY-STEP-START-COMPLETE-001 — Start now preserves honest completion

- **Concept:** `journey.step.start-complete`
- **Modality:** `MUST`
- **Scope:** Recommended Step selection, execution, and completion request
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-STEP-START-COMPLETE-001`
- **Supersedes:** none

Open step MUST only navigate to the selected canonical Step and cannot change execution state. Start now MUST issue a typed Start command that durably records Started execution through Event, Projection, Receipt, and Replay. Completion remains a later validated command, not an animation, timer expiry, Reminder acknowledgement, recommendation acceptance, or consequence of opening detail.

<!-- canon-section: trigger-starting-state -->
Triggers are Start here, Open step then Start now, Search action, Reminder handoff, widget/App Intent, or resumed execution; starting state identifies the canonical Step, eligibility, placement, proof rule, dependencies, and current execution state.

<!-- canon-section: preconditions -->
Preflight resolves the canonical Step, current lifecycle and execution state, recurrence scope, placement, blockers, and proof rule.
The Step resolves to one current identity and its blocking/proof facts are readable. If blocked, stale, already complete, Trashed, or unavailable, the journey offers the valid owner action instead of starting a divergent copy.

<!-- canon-section: happy-path -->
Open step by resolving and presenting the canonical Step without mutation. After explicit Start now, validate current eligibility, issue the typed Start command, commit Started locally, update projections, and issue its Receipt/replay. Keep that durable execution state through interruption; later accept completion with required user-approved Proof if declared, issue a separate completion/Closure command, commit locally, update projections, and issue distinct Receipts.

<!-- canon-section: branches -->
Branches are non-mutating Open step, mutating Start now, Still counts, Move it, Blocked, Waiting, Not needed, add optional Proof, satisfy required Proof, complete a scoped recurrence occurrence, or choose another Step. Open step produces no Event/Receipt; every execution or closure transition routes to its owning typed command.

<!-- canon-section: cancellation -->
Cancel or leave after Open step changes nothing. Cancel before Start now issues no Start command. After the Start commit, leaving active execution preserves its Started state and Receipt/replay; canceling a completion preview does not attach Proof or complete the Step.

<!-- canon-section: interruption-resume -->
Resume the same Step from the durable Start Receipt/replay when Start now committed, otherwise resume only non-mutating detail context. Restore the proof draft and focus separately, revalidate completion and recurrence scope, and never infer Started or Completed from detail presentation or interruption duration.

<!-- canon-section: commit-boundary -->
Open step is non-mutating and has no commit boundary. Start now always crosses a typed durable Start commit boundary with Event, Projection, Receipt, and Replay. Completion is a separate validated commit; completion preview, proof draft, animation, and haptic remain non-durable until the local completion/Closure command commits and the projection reflects it.

<!-- canon-section: failure -->
Stale eligibility or Start rejection leaves execution unstarted and cannot issue a successful Start Receipt. Missing required Proof, recurrence ambiguity, completion rejection, projection delay, or optional external failure retains the last honest Step state and cannot display a later success.

<!-- canon-section: recovery -->
Offer reopen current Step without mutation, retry a rejected Start command idempotently, satisfy/correct Proof content, select recurrence scope, retry completion separately, mark Blocked/Waiting, Move it, or inspect the applicable Start/completion rejection and Receipt without shame.

<!-- canon-section: undo-rollback -->
Undo Start and undo completion are distinct canonical commands. Undo Start restores the prior execution axis and retains Start/undo Receipts; undo completion restores prior valid Step/placement/path influence, preserves Proof according to its owner, and retains completion/undo Receipts. Irreversible external consequences require reconciliation.

<!-- canon-section: receipts-proof -->
Open step produces no mutation history. Typed Start, Start undo, completion/Closure, proof association, recurrence scope, completion undo, and external result have distinct history and replay outcomes. User Proof remains honor-system evidence; automatic Receipts attest only to system mutations.

<!-- canon-section: accessibility -->
Semantics announce Step identity, status, timing, blocking facts, proof rule, Start now/Open step, closure alternatives, and result; all gestures have named actions, completion focus is stable, Dynamic Type preserves consequences, and reduced motion substitutes announcements for transformation.

<!-- canon-section: offline -->
Eligibility from local facts, Start now, execution continuity, completion, Proof attachment, closure alternatives, receipts, replay, and undo work without account/network; external notification or calendar results remain separate.

<!-- canon-section: scenario-tests -->
Execute `SCENARIO-JOURNEY-STEP-OPEN-NONMUTATING-001`, `SCENARIO-JOURNEY-STEP-START-COMMIT-001`, `SCENARIO-JOURNEY-STEP-START-COMPLETE-001`, `SCENARIO-JOURNEY-STEP-REQUIRED-PROOF-001`, `SCENARIO-JOURNEY-STEP-REMINDER-NONCOMPLETION-001`, `SCENARIO-JOURNEY-STEP-RECURRENCE-001`, `SCENARIO-JOURNEY-STEP-RESUME-001`, and `SCENARIO-JOURNEY-STEP-UNDO-001`; assert Open step emits no mutation, every accepted Start now emits one typed Start Event/Projection/Receipt/Replay, completion is separate, start/completion rejection cannot show success, each phase resumes/undoes independently, offline replay, focus, and Receipt/Proof separation.
