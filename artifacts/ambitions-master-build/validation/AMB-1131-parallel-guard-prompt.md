# AMB-1131 Parallel Implementation Guard Prompt

Program: `amb-master`
Issue: `AMB-1131`
Train: `M02.T05`
Scope type: source-changing

Implement the Step Elasticity Engine as a local deterministic runtime primitive.

Allowed source scope:
- Add a focused runtime value model under `Native/Ambitions/Runtime/`.
- Add focused runtime unit tests under `Native/AmbitionsTests/Runtime/`.
- Update AMB master proof/control-plane metadata only after validation.
- Update concept-lock/champion coverage metadata only if the guard or coverage validator requires it.

Required behavior:
- Compose from AMB-1130 `StepGraphCompilerRecord` output instead of duplicating path selection or graph compilation.
- Emit proof-safe elastic action variants for `Shrink`, `Replace`, `Keep momentum`, and `Still Counts` recovery-safe behavior.
- Preserve partial-progress proof continuity through SourceRecord references, Receipt references, ReplayTrace references, and a What Ambitions knows / You inspection route.
- Produce deterministic action ordering, action receipts, replay traces, and an `.elasticity` `RuntimeCoreChainSegment`.
- Fail closed when the upstream graph compiler segment is blocked, when partial-progress proof is missing, when receipt/replay/inspection references are missing, when copy uses shame or false completion language, when a variant silently mutates the plan, or when recovery continuity is not inspectable.

Forbidden behavior:
- No false completion, shame, broken-chain framing, stale-carryover framing, or productivity-guilt fallback language.
- No hidden replacement or silent plan mutation without receipt/replay continuity.
- No required cloud LLM, hosted backend, analytics, telemetry, or network dependency.
- No private user data export to Source Atlas or R2.
- No user-facing UI, visual, release, privacy/legal, device, accessibility certification, or App Store readiness claim.
