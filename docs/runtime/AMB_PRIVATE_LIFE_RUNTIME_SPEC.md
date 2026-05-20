# AMB_PRIVATE_LIFE_RUNTIME_SPEC

## Runtime owner model

`Private Life Runtime` is the only owner of:
- Start Here selection
- decision truth
- source freshness truth
- closure engine
- closure mutation truth
- receipt truth
- not-chosen reasons
- runtime unavailable state
- continuity conflict state
- replay identity
- local learning state
- privacy-sensitive memory state

Ownership invariants:
- Start Here selection is made by the runtime, not by projection code.
- source freshness is computed and carried by the runtime, not synthesized by UI.
- not-chosen reasons are emitted by the runtime as part of the decision packet.
- replay identity is runtime-owned and stable across renderers.
- runtime unavailable and continuity conflict states are runtime-authored states.
- `CandidateRankingLedger` records the deterministic tournament order, selected candidate, excluded candidates, source snapshot, replay id, and not-chosen reason ids for a single decision.
- `ConstraintFirewall` runs before ranking and blocks unavailable, stale beyond policy, unsafe, privacy-redacted beyond policy, or recovery-incompatible candidates.
- `RuntimeCritic` records deterministic weak-signal, stale-source, blocked-goal, recovery, and believability rejection reasons and may down-rank or reject candidates.
- `DecisionReplayContract` binds the seed, source snapshot, candidate sequence, ranking ledger, selected candidate, excluded candidates, and no-mutation-after-publish rule.
- closure mutation is allowed only through `CommandPipeline`.
- projections may render repair and refresh affordances, but they do not rank, override, or silently mutate runtime decisions.
- recovery-first mutation applies to missed, blocked, shortened, or waiting outcomes only through `CommandPipeline` and receipt lineage.
- blocked-goal unstick handling may assume a smaller next step, protected time, waiting state, stale or unavailable source data, recovery already in progress, or user correction/reset.
- local learning state and privacy-sensitive memory state must remain inspectable and resettable.

## Maturity levels

| Level | Required runtime entities | Proof expectation |
| --- | --- | --- |
| L0 | `PrivateLifeRuntime`, `RuntimeSourceTruth`, `CommandPipeline`, `RuntimeDecisionIR` | contract-defined data model, state scaffolding, and ownership boundaries exist |
| L1 | `ConstraintFirewall`, `RuntimeCritic`, `SourceFreshness`, `DecisionReplayContract` | deterministic ranking with freshness gating and stable replay identity |
| L2 | `TrustReceipt`, `NotChosenReason`, `CandidateRankingLedger`, `RealitySignature` | replayable recommendations and explicit not-chosen reasons for every decision |
| L3 | `ClosureEngine`, `ContinuityReceipt`, `RuntimeUnavailableState` | continuity-aware closure with recovery-first mutation and explicit unavailable handling |
| L4 | `LocalMemoryControls`, `PredictionCache`, `FrictionMap` | offline, conflict, and repair loops remain inspectable and receipt-backed |

## Core entities

| Entity | Purpose |
| --- | --- |
| `PrivateLifeRuntime` | orchestrates ranking, decision gating, replay, and closure hooks |
| `RuntimeSourceTruth` | single source truth boundary for runtime facts |
| `NowState` | current time and capacity state |
| `RealityLedger` | runtime event ledger for decisions and mutations |
| `IntelligenceEventLedger` | rationale and candidate competition events |
| `CommandPipeline` | safe runtime command transport |
| `ClosureEngine` | updates intent and follow-up state on outcome |
| `SourceFreshness` | tracks staleness, partiality, and conflict |
| `TrustReceipt` | evidence record for trust-critical assertions |
| `ContinuityReceipt` | restore/conflict evidence receipts |
| `RuntimeDecisionIR` | runtime internal decision representation |
| `DecisionCandidate` | immutable candidate candidate with constraints/score |
| `CandidateRankingLedger` | deterministic tournament record |
| `ConstraintFirewall` | safety gate before recommendation eligibility |
| `RuntimeCritic` | weak-signal rejection and correction path |
| `DecisionReplayContract` | replay identity + sequence integrity |
| `RealitySignature` | checksum + state signature for replay and evidence |
| `NotChosenReason` | explicit non-selection records |
| `RuntimeUnavailableState` | explicit projection state for runtime blockage |
| `RuntimeDiagnostics` | debug and claim-friendly diagnostics |
| `PredictionCache` | stale-safe local precompute for ranking |
| `PersonalOperatingCurve` | context/energy-aware candidate shaping |
| `FrictionMap` | blocked friction and adaptation hints |
| `LocalMemoryControls` | explicit memory retention and reset controls |

## Runtime interfaces

- `RuntimeDecisionIR` receives `ConstraintFirewall` input and produces ranked candidates.
- `RuntimeCritic` can down-rank or reject unsafe/low-believability candidates.
- `ClosureEngine` only mutates via `CommandPipeline` and emits `TrustReceipt` and `ContinuityReceipt` entries.
- `DecisionReplayContract` guarantees replay id, actor, and source snapshot.
- Projection surfaces consume runtime packets and may expose refresh or repair controls, but they do not become decision authorities.
- Every non-selected candidate must carry a compact reason code and privacy-safe reason text or the decision packet is invalid.

## Unavailable and stale state behavior

- `runtime_unavailable`: no recommendation produced; projection is blocked and explicit repair path surfaced.
- `stale_source`: recommendations include freshness severity and must degrade or require review.
- `partial_conflict`: conflict state included and repairable path preserved.
- `last_valid_packet` fallback is allowed only when explicitly marked stale or degraded; it is never promoted as fresh Green output.
