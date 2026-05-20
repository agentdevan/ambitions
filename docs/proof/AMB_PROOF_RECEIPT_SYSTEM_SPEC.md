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
- closure outcome outcome

## Runtime obligations

- `RuntimeCritic` and `ConstraintFirewall` outputs are part of receipt lineage.
- `DecisionReplayContract` includes deterministic replay id and seed.
- `runtime_unavailable` blocks recommendation output and surfaces a repair path.
- `stale_source` may degrade or require review, but it must not be presented as fresh Green output.
- `last_valid_packet` fallback is allowed only when clearly marked stale or degraded.

## Accessibility obligations

Receipt surfaces are semantically summarized and include reduced-motion alternatives.
