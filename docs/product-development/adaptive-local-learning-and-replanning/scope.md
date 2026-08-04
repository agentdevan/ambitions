+++
initiative = "adaptive-local-learning-and-replanning"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Ambitions can learn from explicit corrections and present bounded local pattern
candidates from permitted events. Users decide which influences become active,
inspect exactly what they affect, and receive non-mutating replan proposals when
relevant facts change. Learning can be disabled/reset/deleted without reducing
core manual/deterministic operation.

## In scope

- Private observation ledger with allowlisted event/category/purpose contracts.
- Deterministic pattern hypotheses with evidence/counterevidence/context/time/
  uncertainty/policy lineage.
- Immediate explicit-correction influence preview and candidate-only implicit
  patterns requiring user confirmation.
- Bounded influence types for duration, Step size, context/buffer, reminders,
  Proof-prompt timing, reversible-first preference and exact dismissals.
- Influence purpose/consumer grants, expiry/review, contradiction and neutral use.
- Influence/correction inspection, scope, disable/archive/reset/delete.
- Dependency impact and non-mutating path/schedule/proposal/simulation replan
  requests/deltas through existing owners.
- Offline deterministic rebuild/replay/purge, accessibility, privacy/security,
  longitudinal and direct-user evidence.

## Out of scope

- Auto-active implicit patterns, until a later Scope revision based on v1/user
  evidence.
- Hidden personality/emotion/motivation/grit/productivity/aptitude/health/wealth/
  relationship/employability/success models or scores.
- Observation of calendar titles, precise location history, contacts, health,
  communications, app/keystroke/biometric/browsing/free-form content.
- Capability decay, model/embedding-based learning, cross-user/cloud learning,
  telemetry/profile egress or training a generative model.
- Automatic Goal/Path/Step/Proof/Time/external mutation or causal claims.

## Requirements

### REQ-001 — Observations are allowlisted owner facts
Every observation binds owner event/revision, category, purpose, timestamp,
context classification, sensitivity, retention and policy; interpretations are
not stored as observations and excluded categories fail closed.

### REQ-002 — Pattern hypotheses retain complete evidence
Each candidate lists supporting/counterevidence IDs/categories, sample/context/
time bounds, missing/contradictory evidence, deterministic policy/version,
uncertainty and expiry. Stable inputs produce equivalent output.

### REQ-003 — Initial implicit patterns never influence automatically
Only explicit correction may create an active influence after preview. A derived
pattern stays candidate/non-influential until user confirmation.

### REQ-004 — Influence vocabulary is bounded and non-judgmental
Only approved dimension-level influence types/purposes exist; emotional,
personality, health, productivity, universal person and success labels/scores
are invalid in data, diagnostics and copy.

### REQ-005 — Capability and context ownership remains separate
Learning may reference approved Capability/Proof/Context revisions but cannot
create, decay or edit them. Absence/contradiction yields neutral candidate state.

### REQ-006 — Influence use is declared and inspectable
Each active influence has consumers/purposes, strength posture, scope, expiry,
evidence, uncertainty and explanation. Consumers record used/not-used/overridden/
conflicted/missing and observable effect without aggregate scores.

### REQ-007 — Correction scope is explicit
Users can apply a correction to this draft/candidate/Step shape/context/consumer/
Goal/everywhere as applicable. Original events remain truthful; exact derived
influences/drafts invalidate and rebuild.

### REQ-008 — Replan triggers are typed and dependency bounded
Explicit correction, accepted outcome/reason, context/capability/Proof/source/
current/intent/conflict changes or user reconsideration compute exact dependents
and request only relevant owner simulations.

### REQ-009 — Replanning returns proposals, never mutations
Deltas classify no-change/move/resize/split/replace/conditional/pause/review/
source-needed and show trigger, evidence/influences, objects, alternatives,
tradeoffs and retained accepted truth. Material change requires owner confirmation.

### REQ-010 — Learning-disabled and sparse behavior are useful
Disabled, insufficient, stale, contradictory, deleted or corrupt evidence yields
neutral/no influence and existing manual/deterministic behavior, not pressure.

### REQ-011 — Retention, contradiction and expiry are honest
Capabilities never decay. Observations use category policies; hypotheses may
expire/contradict; confirmed preferences persist until user change/expiry.
Behavior cannot silently override a confirmed fact/influence.

### REQ-012 — Controls cover the full lifecycle
Users can inspect, confirm, correct, disable by category/consumer, archive,
reset suggestions, reset influences, delete and review impact/recovery.

### REQ-013 — Delete and rebuild are deterministic
Event ingestion/rebuild/migrate/replay/purge are atomic/idempotent. Deleted data
stops influencing, cannot reappear via replay and is removed from derived
indices/snapshots/explanations/feedback/exports/continuity copies.

### REQ-014 — Privacy-safe observability is payload-free
Diagnostics/metrics contain category/policy/influence/reason IDs and counts, not
values, exact private time/place, names, content, features or profile vectors.

### REQ-015 — Security and concurrency fail closed
Forged owner events, injected labels, replay duplication, time rollback, policy
downgrade, graph cycles, resource exhaustion and stale async results cannot
activate an influence or mutate an owner.

### REQ-016 — Evaluation is influence/consumer/version bound
Measure false pattern, counterevidence, confirmation burden, correction fidelity,
replan stability/oscillation, privacy/bias/dignity, outcome usefulness and trust.
No hard gate may be averaged away.

### REQ-017 — Accessibility and calm language are complete
Evidence, counterevidence, uncertainty, scope, influence, delta and all controls
have ordered text/assistive access; no streak, blame, urgency or failure framing.

## Acceptance criteria

- AC-001: excluded/forged/malformed observations fail without state change.
- AC-002: order-independent rebuild reproduces candidate/evidence explanations.
- AC-003: no implicit pattern affects any consumer before confirmation.
- AC-004: prohibited label/score/copy corpus fails validation.
- AC-005: Capability/Context bytes remain unchanged under all learning actions.
- AC-006: every consumer result reports dimension-level influence use.
- AC-007: scope corrections invalidate only exact derivatives and retain history.
- AC-008: trigger fan-out is exact, bounded, cancelable and source-revision safe.
- AC-009: mutation spies prove replanning changes no canonical/external state.
- AC-010: learning-off/sparse/corrupt states preserve core value.
- AC-011: expiry/contradiction never decays Capability or overrides confirmation.
- AC-012: every lifecycle control has preview/receipt/recovery.
- AC-013: fault-purge/rebuild is complete, resumable and deletion terminal.
- AC-014: private canaries appear nowhere in diagnostics/metrics.
- AC-015: security/concurrency corpus fails closed deterministically.
- AC-016: longitudinal/slice gates pass before expansion.
- AC-017: accessibility/device/direct-user language proof passes.

## Canon impact

Update Local Learning canon and related privacy, Capability/Context, planning,
scheduling, Goal Path/Life Branch, History/Receipts, trust/degraded, deletion and
evaluation/change contracts.

## Risks and open decisions

No hard fork remains. Auto-active implicit learning is excluded—not pending a
routine configuration—until a new approved Scope is supported by v1 interaction
and longitudinal user evidence.

Review verdict: **PASS** after two reconciliation rounds. Review separated facts/
hypotheses/influences/decisions, made implicit candidates non-influential, made
replanning owner-requested and preserved deletion/capability boundaries. Devan
delegated approval; Scope approved 2026-08-04.
