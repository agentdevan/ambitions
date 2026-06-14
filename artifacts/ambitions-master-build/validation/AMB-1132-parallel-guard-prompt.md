# AMB-1132 Parallel Implementation Guard Prompt

Program: `amb-master`
Issue: `AMB-1132`
Train: `M02.T06`
Scope type: source-changing

Implement the Schedule Install Kernel as a local deterministic runtime primitive.

Allowed source scope:
- Add a focused runtime value model under `Native/Ambitions/Runtime/`.
- Add focused runtime unit tests under `Native/AmbitionsTests/Runtime/`.
- Update AMB master proof/control-plane metadata only after validation.
- Update concept-lock/champion coverage metadata only if the guard or coverage validator requires it.

Required behavior:
- Compose from AMB-1131 `StepElasticityRecord` output instead of duplicating path selection, graph compilation, or elastic action generation.
- Emit an explicit schedule preview before any install receipt can exist.
- Require an explicit user commit decision for install readiness, and keep cancel/preview-only states from driving downstream runtime.
- Emit local install receipts, SourceRecord references, rollback traces, ReplayTrace references, and time-boundary proof for committed installs.
- Preserve a What Ambitions knows / You inspection route for preview, commit, rollback, and protected-time boundary proof.
- Enforce protected-time boundaries by blocking protected windows rather than silently installing into them.
- Produce deterministic preview ordering, receipt identifiers, rollback identifiers, and a `.scheduleInstall` `RuntimeCoreChainSegment`.
- Fail closed when elasticity is blocked, when preview/window/commit/rollback proof is missing, when protected time is selected, when SourceRecord/Receipt/ReplayTrace/What Ambitions knows inspection references are missing, or when time would mutate without an explicit receipt.

Forbidden behavior:
- No silent mutation of user time.
- No hidden schedule install, hidden rollback, or protected-time override.
- No required cloud LLM, hosted backend, analytics, telemetry, or network dependency.
- No private user data export to Source Atlas or R2.
- No user-facing UI, visual, release, privacy/legal, device, accessibility certification, or App Store readiness claim.
