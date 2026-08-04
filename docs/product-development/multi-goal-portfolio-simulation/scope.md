+++
initiative = "multi-goal-portfolio-simulation"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Users can select several existing Goals, inspect cross-Goal conflicts/synergies
and compare a small set of assumption-bound portfolio scenarios. Results retain
dimension-level resources, unknowns, reversibility and per-owner consequences;
selection only prepares revalidated change previews. Production availability is
gated on upstream v1/runtime/user evidence.

## In scope

- Immutable user-selected portfolio snapshots and finite horizon.
- Heterogeneous time/money/place/equipment/context/responsibility/opportunity/
  dependency/capability/reversibility ledgers with ranges/unknowns.
- Deterministic current/protect-named-Goal/protect-constraints/reversible-bridge/
  lower-load/user-authored scenarios.
- Per-Goal/per-resource conflicts, continuities, tradeoffs, sensitivity and
  non-prediction explanations.
- Optional validated generative wording, never accounting/ranking.
- Owner change proposal bundle and Life Branch escalation for inseparable edits.
- Revision invalidation, save/archive/delete, accessibility/privacy/evaluation.
- Conformance-only implementation until upstream activation gates pass.

## Out of scope

- Universal life/Goal priority, balance, success, productivity or person score.
- Hidden Goal selection, inferred value hierarchy, probability/forecast,
  deterministic future or “best life” recommendation.
- Automatic Goal/Path/Step/Time/Proof/external mutation, route generation or
  Life Branch commit.
- Double-counted/converted heterogeneous resources, fabricated unknowns,
  unlimited goals/horizon/scenarios or model-owned accounting.

## Requirements

### REQ-001 — Scope is user selected
Users choose Goals, path revisions, horizon and optional scenario posture; no
behavior/profile automatically includes or prioritizes a Goal.

### REQ-002 — Snapshot binds exact owner truth
Inputs capture Goal/Path/Step/Time/Context/Capability/Proof/current/source/policy
revisions and statuses without copying mutable owner authority.

### REQ-003 — Resources remain dimensioned
Every resource retains unit/range/period/context/owner/source/uncertainty and
cannot be collapsed or double-counted. Unknown/not-included is not zero.

### REQ-004 — Scenario assumptions are explicit
Each scenario names its user-selected/system-template assumptions and protected
facts. Templates cannot infer value or choose a Goal to sacrifice.

### REQ-005 — Deterministic simulation owns consequences
Constraint/dependency/resource/conflict/sensitivity calculations are local,
bounded, replayable and model-independent.

### REQ-006 — Results are non-ranked, non-predictive alternatives
Return meaningfully different supported scenarios or fewer; show dimension-
level reasons/unknowns. No probability, global scalar, optimal/best/balanced or
success claim.

### REQ-007 — Per-Goal continuity and effects are exact
Each scenario identifies unchanged/delayed/conditional/paused/source-needed work,
capability/Proof continuity and no-change. It cannot delete completion/history.

### REQ-008 — Sensitivity is bounded and inspectable
Vary one registered assumption/range at a time and report changed semantic
decisions. It is not probability or a hidden optimization search.

### REQ-009 — Constraints are dignified and user-controlled
Money/time/access/care/relationship facts remain private explicit realities;
violations cite facts, offer alternatives and never penalize a person.

### REQ-010 — Generated explanation cannot add decisions
Optional private-runtime wording renders a validated scenario semantic object;
invalid/unavailable model falls back to deterministic language.

### REQ-011 — Selection creates no mutation
A selected scenario produces an owner-specific proposal bundle. Each owner
revalidates and confirms; inseparable multi-owner changes route to Life Branch.

### REQ-012 — Revision and failure handling preserve truth
Changed dependencies mark exact results stale. Sparse/conflicting/invalid/canceled
simulation yields partial/unknown/manual alternatives without changing owners.

### REQ-013 — Lifecycle is private and deletable
Save/replay/migrate/archive/delete/purge is atomic/idempotent; deletion removes
snapshots/assumptions/ledgers/explanations/feedback, not canonical owners.

### REQ-014 — Evaluation is scenario/slice bound
Measure accounting validity, conflict/unknown accuracy, option preservation,
sensitivity, privacy/bias/dignity, comprehension/usefulness and owner-boundary
integrity; no aggregate hides a hard gate.

### REQ-015 — Accessibility conveys complete meaning
All resources/scenarios/assumptions/conflicts/deltas/sensitivity and controls have
ordered nonvisual representations and calm non-shaming language.

### REQ-016 — Production activation is evidence gated
Only conformance fixtures are available until scheduling/comparison/Life Branch/
Context/Capability runtime and direct-user evidence listed in Research pass.

## Acceptance criteria

- AC-001: only explicitly selected Goal/revisions enter the snapshot.
- AC-002: owner changes invalidate exact results; snapshot cannot mutate owners.
- AC-003: unit/range/unknown/double-count fixtures remain dimensionally correct.
- AC-004: every assumption is visible/editable and Goal sacrifice is never inferred.
- AC-005: stable inputs reproduce semantic scenarios without a model.
- AC-006: invalid/filler/ranked/predictive scenario outputs fail validation.
- AC-007: per-Goal deltas preserve completion/history and exact continuity.
- AC-008: one-at-a-time sensitivity produces inspectable semantic differences.
- AC-009: privacy/bias/dignity fixtures offer alternatives without person penalty.
- AC-010: model failure changes wording availability, not scenario semantics.
- AC-011: mutation spies pass; inseparable bundle routes only to Life Branch.
- AC-012: sparse/stale/cancel/error preserves owner truth and manual review.
- AC-013: fault purge is complete, resumable and deletion terminal.
- AC-014: claim-bound evaluation passes each enabled slice.
- AC-015: accessibility/device/user comprehension evidence passes.
- AC-016: production mode remains unavailable until signed gate record passes.

## Canon impact

Add Multi-Goal Portfolio Simulation canon; update simulation, Goal/Path/Time,
Context/Capability/current, private runtime, Life Branch, trust/degraded,
History/Receipts, privacy and evaluation/change contracts.

## Risks and open decisions

No design fork remains. Production activation is intentionally unavailable until
named upstream evidence exists; conformance implementation and documentation are
fully specified.

Review verdict: **PASS** after two reconciliation rounds. Review made scope user-
selected, separated dimensions/model wording, defined Life Branch escalation and
encoded the evidence hold as a hard availability state. Devan delegated approval;
Scope approved 2026-08-04.
