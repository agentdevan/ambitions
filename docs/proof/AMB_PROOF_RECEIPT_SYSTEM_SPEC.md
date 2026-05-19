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

## Consequence rules for every recommendation

Every consequential recommendation must answer:
- why this
- why now
- what source facts were used
- source freshness level
- what changed
- what was not chosen + why not
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

## Accessibility obligations

Receipt surfaces are semantically summarized and include reduced-motion alternatives.
