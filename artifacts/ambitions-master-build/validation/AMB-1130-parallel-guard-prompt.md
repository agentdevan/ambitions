# AMB-1130 Parallel Implementation Guard Prompt

Program: `amb-master`
Issue: `AMB-1130`
Train: `M02.T04`
Scope type: source-changing

Implement the Step Graph Compiler as a local deterministic runtime primitive.

Allowed source scope:
- Add a focused runtime value model under `Native/Ambitions/Runtime/`.
- Add focused runtime unit tests under `Native/AmbitionsTests/Runtime/`.
- Update AMB master proof/control-plane metadata only after validation.
- Update concept-lock/champion coverage metadata only if the guard or coverage validator requires it.

Required behavior:
- Compile installed, reserve, proof, review, and dependency graph nodes from local deterministic inputs.
- Preserve graph inspection through stable graph snapshots, SourceRecord references, Receipt references, ReplayTrace references, and a What Ambitions knows / You inspection route.
- Keep dependency graph integrity deterministic across input ordering.
- Require proof and review node semantics before the graph compiler can drive the runtime core chain.
- Stay compatible with the existing M02 `RuntimeCoreUmbrellaGate` `.graphCompiler` segment.
- Stay compatible with AMB-1129 `MultiPathLatticeRecord` path-selection output instead of duplicating path selection.
- Fail closed when graph nodes are missing required source, receipt, replay, proof, review, dependency, or inspection information.

Forbidden behavior:
- No opaque scheduling output with no graph inspection path.
- No hidden mutation of a selected path or installed graph.
- No required cloud LLM, hosted backend, analytics, telemetry, or network dependency.
- No private user data export to Source Atlas or R2.
- No user-facing UI, visual, release, privacy/legal, device, accessibility, or App Store readiness claim.
