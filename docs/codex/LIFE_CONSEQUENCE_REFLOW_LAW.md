# Life Consequence Reflow Law

Status: Active PLOS M00 governance law
Issue: AMB-641 / PLOS-005
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting PLOS law subordinate to `docs/truth/*`
Runtime implementation proof: none

This law defines cross-goal consequence prevention for PLOS execution. It does not implement a reflow engine, schedule install, active-goal mutation, UI warnings, or runtime behavior.

## Core Law

No Step, path, schedule, or goal mutation can silently harm another active goal.

Ambitions may recommend reflow, but material consequences must be simulated, classified, and receipted before they affect the user's life system. The user should never discover later that a skipped Step, shrunken Step, source change, schedule install, or deadline adjustment quietly damaged another goal, broke protected time, erased proof value, or made a future deadline impossible.

Life Consequence Reflow is a Personal Life OS law. It is not analytics, scoring, shame, or a productivity dashboard. Its job is to protect the user's life system from hidden mutation.

## Existing Model Anchors

AMB-641 inspected current source before installing this law. Existing seams include:

- `Native/Ambitions/Domain/LifeGraphEventLogModels.swift`
  - human progress graph nodes and edges already carry source state, freshness state, review state, privacy class, receipt IDs, affected node IDs, affected edge IDs, rollback hints, and review-before-mutation checks.
- `Native/Ambitions/Domain/EventLedgerModels.swift`
  - event kinds already include goal updates, plan rescheduling/recovery/scheduling, priority and deadline changes, item displacement, action delay/skip/move/split, recovery acceptance/decline, and recommendation events.
- `Native/Ambitions/Features/Time/TimeReflowDecisionState.swift`
  - Time reflow decision state already models no-silent-change trust posture, before/after previews, impacted Steps, capacity impact, protected-time impact, confirmation, decline, receipt preview, and local suggestion boundaries.
- `Native/Ambitions/Features/Time/TimeReflowDecisionCard.swift`
  - Time reflow UI state already presents source, reason, no-silent-change, impact, before/after, and receipt concepts without claiming engine behavior.
- `Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift`
  - replacement options already preview deadline impact, timeline impact, receipt preview, approval receipts, and impact sections before replacement approval.
- `Native/Ambitions/Domain/Reschedule/RescheduleEngine.swift`
  - rescheduling already models delay, skip, stuck, smaller-step triggers, recovery posture, waiting state, defer recommendation, rationale, confidence, and suggested time.
- `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift`
  - Step impact simulation already includes deadline pressure delta, protected-time threat, feasibility band, impossible-state concepts, deadline review, and scope review.
- `Native/Ambitions/Runtime/SourceAtlasStepCandidateFieldBridge.swift`
  - Source Atlas Step expansion already marks deadline-protecting candidates and carries source record and claim traces.
- `Native/AmbitionsTests/Services/AmbitionsCommandExecutorTests.swift`
  - local schedule mutation tests already require user confirmation and record source record, receipt, replay trace, displaced disposition, pressure shifts, and LifeShape impact metadata.

These anchors are existing-first context only. They do not prove Life Consequence Reflow implementation.

## Reflow Triggers

Every future runtime implementation that claims Life Consequence Reflow Green must evaluate these triggers:

| Trigger | Minimum consequence check |
|---|---|
| add goal | Does the new goal compete with active deadlines, protected time, capacity, proof, source, or treaty constraints? |
| change goal | Does the changed scope, deadline, or proof expectation displace another active goal? |
| skip Step | Does skipping reduce proof value, break a dependency, delay a deadline, or increase recovery cost? |
| shrink Step | Does shrinking reduce proof, deadline protection, source validity, or downstream readiness? |
| extend Step | Does extending consume protected time, create density pressure, or cannibalize another active goal? |
| replace Step | Does replacement preserve source authority, proof, deadline, and dependency value? |
| split/merge Step | Does split/merge preserve traceability, receipts, and affected-goal visibility? |
| change deadline | Does the new deadline compress schedule, make another path impossible, or require review? |
| complete early | Does early completion open safe momentum, pull a next Step forward, or create overcommit risk? |
| pause/resume goal | Does pausing/resuming affect treaty commitments, proof windows, or active portfolio density? |
| source pack changes | Does new source tighten, loosen, revoke, or alter eligible paths and active Steps? |
| source revoked/stale | Does stale or revoked source block a current Step, schedule install, share path, or proof claim? |
| schedule availability changes | Does changed availability affect protected time, active deadlines, or installed Steps? |
| permission/context changes | Does lost or gained context change eligibility, privacy, source, location, or safety assumptions? |

Missing trigger handling is Yellow only when the trigger is explicitly out of scope for a law/report. It is Red for runtime behavior that can mutate user-visible plans.

## Build Tiers

Life Consequence Reflow can be built in tiers, but Green claims must name the tier in scope:

| Tier | Scope | Green blocker |
|---|---|---|
| same-goal reflow | Reorders or adjusts Steps inside one goal. | Claiming cross-goal safety from same-goal proof only. |
| schedule horizon reflow | Evaluates the next schedule window or planning horizon. | Moving work without preview and receipt. |
| active goal portfolio reflow | Checks all active goals for deadline, density, proof, dependency, and recovery consequences. | Hiding displacement of another active goal. |
| treaty-aware reflow | Applies user-owned Goal Treaties before mutation. | Letting generic optimization override a treaty silently. |
| source-change reflow | Re-evaluates affected paths and Steps when sources become fresh, stale, changed, contradicted, or revoked. | Letting stale/revoked source keep driving runtime behavior. |

Later phases may implement these tiers incrementally. This law requires honest tier boundaries and no broad claim from a narrow tier.

## Severity Tiers

Every material consequence must classify severity:

| Severity | Meaning | Visibility rule |
|---|---|---|
| Silent | No material harm, no deadline/proof/source/protected-time impact, and no affected active goal. | May be recorded quietly. |
| Inform | Low-impact consequence useful for user understanding. | May surface as calm information. |
| Confirm | Mutation is safe only after user choice or explicit approval. | Must require confirmation before mutation. |
| Warn | Material risk exists, but the user can still choose with a clear consequence phrase. | Must show consequence before approval. |
| Block | Mutation cannot proceed under current safety, source, proof, privacy, treaty, or schedule constraints. | Must block or route to review. |
| Impossible | Current constraints make the path impossible without changing scope, deadline, source, or capacity. | Must not pretend the path remains viable. |

Quiet mode cannot suppress Confirm, Warn, Block, or Impossible events. Any implementation that lets Quiet hide material harm is Red.

## Non-Suppressible Events

These events cannot be hidden by preference, compression, automation, or convenience UI:

- deadline impossible
- goal blocked
- high-risk review required
- source revoked
- protected time broken
- material displacement of another goal
- unsafe state
- schedule install failure

Non-suppressible does not mean loud or shameful. It means the user must have inspectable notice, consequence phrasing, and a receipt/failure state before behavior changes.

## User Reflow Visibility Preferences

Preferences may control presentation density, not truth:

| Preference | Allowed behavior | Forbidden behavior |
|---|---|---|
| Quiet | Collapse low-impact Silent and Inform events. | Hide material harm, warnings, blockers, impossible states, or receipts. |
| Balanced | Show meaningful consequences and keep routine details compressed. | Turn consequence review into generic status tiles or scores. |
| Detailed | Show trigger, affected goals, proof/deadline/density/source impact, and rollback state. | Overwhelm default surfaces when the user did not ask. |
| Expert | Show full trace, source, severity, tier, and affected-object details. | Treat internal details as proof without validation. |

Preference applies after severity classification. It cannot downgrade severity.

## Goal Treaty

A Goal Treaty is a user-owned constraint that declares how goals share life capacity.

Examples:

- Music gets evening deep-work until July 15.
- Fitness stays recovery-safe this week.
- Sleep protection wins after 10:30.
- Debt review stays Sunday.

Goal Treaties are not productivity rules, scores, or streaks. They are local, inspectable, user-owned agreements that future reflow must honor unless the user changes them. If a mutation would violate a treaty, the reflow must classify the consequence and require the appropriate visibility or block.

## Receipt Requirement

Every material reflow must produce a receipt or safe failure state with:

- what changed
- affected goals
- deadline, density, and proof impact
- user-facing consequence phrase
- rollback or failure state

Receipt content must be local-first and privacy-safe. A receipt is not optional when behavior changes. If source state changes caused the reflow, the receipt must also preserve source/freshness/revocation context or record why source authority is missing.

## User-Facing Consequence Phrasing

Life Consequence Reflow must describe human consequences, not analytics.

Allowed law examples:

- "This keeps the deadline but moves recovery pressure to tomorrow."
- "This protects sleep but delays the debt review."
- "This Step can shrink safely; proof value stays intact."
- "This source changed, so the current path needs review before schedule install."

Forbidden framing:

- productivity score changed
- goal score dropped
- analytics say underperforming
- streak at risk
- optimize portfolio allocation
- failure heat map

These examples are law examples, not shipped copy.

## Integration Points

Life Consequence Reflow binds these PLOS laws and future phases:

- Personal Life OS Runtime Law: reflow is required because Ambitions fits execution to real life instead of making users fail rigid tasks.
- Any Goal Solution Loop: source-needed, coverage-demand, jurisdiction, high-risk, and unsupported states can only reflow inside their authority boundaries.
- Source Atlas Authority: stale, revoked, changed, contradicted, jurisdiction-needed, and review-required source states must trigger source-change reflow before runtime behavior continues.
- Seed-Based Planning: replacement, recovery, deadline-protection, resource-light, location-compatible, split/merge, and momentum-tail seeds must carry consequence receipts.
- Step Elasticity Runtime Law: every shrink, extend, replace, split, merge, recovery-safe, proof-only, or momentum-tail mutation must calculate reflow impact.
- Step Quality Firewall: generic, unsafe, source-weak, proof-erasing, inaccessible, or uninspectable reflow outputs must be rejected or degraded.
- Schedule Install Kernel: schedule mutations must be previewable, reversible, receipt-backed, and blocked on install failure.
- Trust-light UI: ordinary state stays quiet while material consequence remains inspectable.
- High-Risk Safety: high-risk review cannot be suppressed by same-goal reflow or Quiet preference.

Forward law/phase cross-links:

- AMB-627 / PLOS-M09 must use this law when proving Step Quality Firewall consequence rejection.
- AMB-623 / PLOS-M16 must use this law as the governance gate for any Life Consequence / Cross-Goal Reflow Engine implementation.
- AMB-622 / PLOS-M15 must use this law before schedule install Green.

## Green Enforcement

Any future PLOS issue that claims reflow, schedule install, goal mutation, Step mutation, deadline change, source-change adaptation, active-goal portfolio safety, Goal Treaty behavior, recovery routing, or cross-goal consequence handling must reference this law before Green.

Green requires:

- a live `AMB-*` issue identifier
- existing-first inspection of goal, schedule, plan, reflow, timeline, receipt, consequence, proof, capacity, protected-time, Today, Time, and Goals ownership
- explicit trigger coverage or named not-in-scope boundary
- explicit build tier
- severity classification
- non-suppressible event handling
- user visibility preference handling without severity downgrade
- Goal Treaty relationship when treaty constraints are in scope
- receipt or safe failure state for every material reflow
- no runtime implementation claim without source and validation proof

Yellow is allowed when this law/report is correct but future engine, UI, schedule install, Step Quality Firewall, or runtime proof remains owned. Red is required for same-goal-only overclaim, Quiet hiding material harm, schedule mutation without preview/receipt, shame framing, analytics replacement for human consequence phrasing, PLOS label Linear access, or phase-order violation.

## Cross-Links

Primary authority:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `AGENTS.md`

PLOS law authority:

- `docs/codex/PERSONAL_LIFE_OS_RUNTIME_LAW.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `docs/codex/SEED_BASED_PLANNING_LAW.md`
- `docs/codex/STEP_ELASTICITY_RUNTIME_LAW.md`
- `artifacts/plos-runtime/PLOS_PHASE_GATES.md`
- `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.md`

Forward PLOS law/phase authority:

- AMB-627 / PLOS-M09 Step Quality Firewall
- AMB-622 / PLOS-M15 Schedule Install Kernel
- AMB-623 / PLOS-M16 Life Consequence / Cross-Goal Reflow Engine

Proof for this law installation:

- `artifacts/personal-life-os/reports/PLOS-005-life-consequence-law-report.md`

## Non-Claims

This file does not prove:

- Life Consequence Reflow Engine implementation
- schedule install implementation
- active-goal mutation implementation
- Goal Treaty model implementation
- Step Quality Firewall implementation
- UI warning implementation
- app source behavior
- source migration completion
- release readiness
- TestFlight or App Store readiness
- accessibility verification
- privacy or legal approval
- performance validation
- device validation
- owner approval
