# AMB-1129 Parallel Implementation Guard Prompt

Program: `amb-master`
Issue: `AMB-1129`
Train: `M02.T03`
Scope type: source-changing

Implement the Multi-Path Lattice as a local deterministic runtime primitive.

Allowed source scope:
- Add a focused runtime value model under `Native/Ambitions/Runtime/`.
- Add focused runtime unit tests under `Native/AmbitionsTests/Runtime/`.
- Update AMB master proof/control-plane metadata only after validation.
- Update concept-lock/champion coverage metadata only if the guard or coverage validator requires it.

Required behavior:
- Generate multiple viable path candidates for a goal from local inputs.
- Require explicit path selection before a path can drive visible execution.
- Preserve path comparison readiness through inspectable tradeoff rows.
- Persist deterministic path state without hidden auto-selection or silent life-graph mutation.
- Produce local selection receipts and replay references for inspection.
- Require `SourceRecord`, `Receipt`, and `ReplayTrace` wiring before any selected path can drive visible execution.
- Expose a What Ambitions knows / You inspection route for the selected lattice state and blocked alternatives.
- Stay compatible with the existing `AmbitionsOSPathPortfolio` / `AmbitionsOSAlternatePathCandidate` domain model instead of duplicating it.
- Stay compatible with the M02 `RuntimeCoreUmbrellaGate` path-selection segment.
- Fail closed when source records, receipts, replay trace, comparison readiness, or explicit selection are missing.

Forbidden behavior:
- No hidden auto-selection that bypasses user-visible tradeoffs.
- No required cloud LLM, hosted backend, analytics, telemetry, or network dependency.
- No private user data export to Source Atlas or R2.
- No user-facing UI, visual, release, privacy/legal, device, accessibility, or App Store readiness claim.
