# AMB_PROOF_RECEIPT_SYSTEM_SPEC

## Core proof objects

- `ProofTrail`
- `ReceiptDrawer`
- `WhyThisSurface`
- `NotChosenReasonsSurface`
- `PlanMutationReceipt`
- `ClosureReceipt`
- `ContinuityReceipt`
- `SourceFreshnessBadge`
- `ProofCompletenessIndex`
- `SourceFreshnessIndex`
- `DecisionReplayViewer`

## Candidate competition proof requirements

- `CandidateRankingLedger` must be reproducible from the source snapshot and replay id.
- `ConstraintFirewall` decisions must be visible in the proof lineage so blocked candidates are explainable.
- `RuntimeCritic` decisions must record deterministic down-rank or rejection reasons without model jargon.
- `DecisionReplayContract` must preserve the seed, source snapshot, candidate sequence, ranking ledger ref, selected candidate, excluded candidates, and a no-mutation-after-publish rule.

## Consequence rules for every recommendation

Every consequential recommendation must answer:
- why this
- why now
- what source facts were used
- source freshness level
- what changed
- what was not chosen + why not
- compact reason code and privacy-safe reason text for every excluded candidate
- replayability identity
- reversibility
- confirmation requirements
- unavailable/stale states

## Proof contract requirements

- No fake proof.
- No fixture-only proof as production truth.
- No raw model confidence exposure.
- No hidden mutation.

## Receipt structure

Each receipt includes:
- source references
- timing + state snapshots
- participant identity
- decision rationale
- not-chosen reasons set
- conflict/confidence (boolean and bounded)
- closure outcome
- affected object IDs
- command trace or replay reference
- replay id
- reversibility note
- privacy-safe summary

## Closure receipt path

Closure-sensitive recommendations and mutations must carry a `ClosureReceipt` path that ties the decision to the runtime packet that produced it.

The closure receipt path records:
- closure outcome
- source snapshot used at decision time
- command trace or `CommandPipeline` reference
- affected object IDs
- not-chosen reasons for excluded alternatives
- replay id and seed reference
- reversibility or recovery path
- privacy-safe summary suitable for user inspection

The receipt path must make it possible to explain why a closure happened, what changed, and what remains available for replay or recovery.

## Recovery-first mutation

Missed, blocked, shortened, or waiting outcomes may only mutate future recommendations through `CommandPipeline` and receipt lineage.

The runtime must not silently rewrite current intent. It may:
- record the closure outcome
- emit a receipt
- update future recommendation inputs
- preserve the prior source snapshot
- preserve the no-mutation-after-publish rule for replayed decisions

Any mutation that changes future guidance must remain inspectable through receipt lineage.

## Blocked-goal unstick assumptions

Blocked-goal recovery may assume:
- the next step can be smaller than the original step
- protected time may be required
- the goal may be in a waiting state
- source data may be stale or unavailable
- recovery may already be in progress
- the user may correct, reset, or re-open the path

These assumptions are proof requirements, not auto-execution rules. They define the recovery vocabulary the runtime must be able to explain.

## Runtime obligations

- `RuntimeCritic` and `ConstraintFirewall` outputs are part of receipt lineage.
- `DecisionReplayContract` includes deterministic replay id and seed.
- `runtime_unavailable` blocks recommendation output and surfaces a repair path.
- `stale_source` may degrade or require review, but it must not be presented as fresh Green output.
- `last_valid_packet` fallback is allowed only when clearly marked stale or degraded.

## Accessibility obligations

Receipt surfaces are semantically summarized and include reduced-motion alternatives.

## Claim boundary

This document defines required proof assets and receipt controls.

It does not prove app runtime behavior, accessibility conformance, privacy approval, build success, or release readiness.
