+++
spec_id = "JOURNEY-LIFE-BRANCH-RECONCILIATION"
title = "Life Branch Reconciliation"
kind = "journey"
status = "normative"
owner_domain = "journey-life-branch-reconciliation"
canon_revision = 1
profile = "journey-v1"
owns_concepts = ["journey.life-branch-reconciliation.review", "journey.life-branch-reconciliation.selection", "journey.life-branch-reconciliation.promotion", "journey.life-branch-reconciliation.recovery"]
inherits = ["MISSION-ORCHESTRATION-LOOP-001", "MISSION-REFLOW-001", "OBJECT-CANONICAL-GRAPH-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONTROL-UNDO-RECOVERY-001", "RUNTIME-MUTATION-SEQUENCE-001"]
depends_on = ["CONSTITUTION", "SYSTEM-CERTIFIED-EXECUTABLE-BRANCH-RECONCILIATION", "OBJECT-LIFE-BRANCH", "OBJECT-BRANCH-VIABILITY-CERTIFICATE", "OBJECT-GOAL-PATH", "OBJECT-SCHEDULE-PLACEMENT", "OBJECT-RECEIPT", "GLOBAL-TRUST-INSPECTION", "SURFACE-TODAY", "SURFACE-GOALS", "SURFACE-TIME", "SURFACE-YOU"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Transactions/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/Today/", "Native/Ambitions/Surfaces/Goals/", "Native/Ambitions/Surfaces/Time/", "Native/Ambitions/Surfaces/You/", "Native/Ambitions/Quality/"]
+++

# Life Branch Reconciliation

This journey makes a changed-reality branch inspectable and user-controlled
across existing Today, Goals, Time, and You/Trust surfaces. It is not a new
destination or an automatic replanning flow.

## JOURNEY-LIFE-BRANCH-REVIEW-001 — Start from a concrete revision

- **Concept:** `journey.life-branch-reconciliation.review`
- **Modality:** `MUST`
- **Scope:** Trigger, changed reality, current branch, certificate, and review entry
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-LIFE-BRANCH-REVIEW-001`
- **Supersedes:** none

Reconciliation begins from a known trigger and current graph revision: changed
fact, policy, authority, capacity, operating condition, user request, or
review condition. The entry shows what changed, what remains protected, the
current branch and certificate status, and why review is needed. It does not
pretend that a forecast or model proposal is a committed fact.

## JOURNEY-LIFE-BRANCH-SELECTION-001 — Compare complete ways forward

- **Concept:** `journey.life-branch-reconciliation.selection`
- **Modality:** `MUST`
- **Scope:** Conflict, correction sets, candidates, tradeoffs, and user choice
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-LIFE-BRANCH-SELECTION-001`
- **Supersedes:** none

When the current branch cannot remain valid, the journey presents bounded,
complete candidates derived from policy-distinct correction sets. Each option
states what it protects, changes, costs, assumes, leaves unresolved, and would
affect in Goals, Today, Time, proof, recovery, recipients, or external
systems. The user may inspect, edit, reject all, keep the conflict, choose a
lighter path, or defer review. No option is selected from hidden model scores.

## JOURNEY-LIFE-BRANCH-PROMOTION-001 — Revalidate before one local commit

- **Concept:** `journey.life-branch-reconciliation.promotion`
- **Modality:** `MUST`
- **Scope:** Selection, confirmation, revalidation, local commit, and external intents
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-LIFE-BRANCH-PROMOTION-001`
- **Supersedes:** none

After explicit user selection, the runtime MUST revalidate graph revision,
certificate, current authority, protected boundaries, and materiality. A
confirmed selection commits through one parent local transaction, then updates
projections and creates a truthful Receipt and History Event. External or
recipient effects remain separately labeled proposals/outbox intents and may
not determine local success.

## JOURNEY-LIFE-BRANCH-RECOVERY-001 — Failed or stale review remains humane

- **Concept:** `journey.life-branch-reconciliation.recovery`
- **Modality:** `MUST`
- **Scope:** Stale review, invalid candidate, interrupted commit, rejection, and rollback
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-LIFE-BRANCH-RECOVERY-001`
- **Supersedes:** none

If a review becomes stale, a candidate fails validation, the user rejects all
options, or a commit is interrupted, the journey preserves the last honest
state and explains the exact reason. Recovery offers refresh, inspect, choose a
different correction, defer, undo/rollback where safe, or return to the
owning object. It uses calm recovery language and never labels an honest
no-fit result as user failure.

## Journey contract

<!-- canon-section: trigger-starting-state -->
Starting state captures current branch/certificate identity, graph and source
revisions, changed trigger, protected/fixed boundaries, capacity, authority
partitions, pending external state, user rules, and review condition.

<!-- canon-section: branches -->
Branches are inspect current branch, refresh certificate, compare candidates,
edit a candidate, choose another correction, keep conflict, choose a lighter
path, defer, reject all, accept selection, or undo/rollback. No branch silently
changes canonical objects before confirmation.

<!-- canon-section: accessibility -->
Every visual comparison has an ordered semantic alternative naming candidate,
state, protected and sacrificed conditions, changed objects, authority,
consequence, confirmation scope, and available recovery. Focus returns to the
changed branch or result; reduced motion and Dynamic Type remain equivalent.

<!-- canon-section: offline-and-privacy -->
Local review, certificate inspection, candidate comparison, selection, commit,
Receipt, replay, and rollback work without network or account. Public/reference
enrichment is optional and cannot receive private branch context.

<!-- canon-section: proof-ceiling -->
This journey records product and runtime design intent only. No current UI,
device, accessibility, performance, or release proof is implied.
