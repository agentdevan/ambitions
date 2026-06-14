# AMB-1133 Parallel Implementation Guard Prompt

Program: `amb-master`
Issue: `AMB-1133`
Train: `M02.T07`
Scope type: source-changing

Implement the Life Consequence Engine as a local deterministic runtime primitive.

Allowed source scope:
- Add a focused runtime value model under `Native/Ambitions/Runtime/`.
- Add focused runtime unit tests under `Native/AmbitionsTests/Runtime/`.
- Update AMB master proof/control-plane metadata only after validation.
- Update concept-lock/champion coverage metadata only if the guard or coverage validator requires it.

Required behavior:
- Compose from AMB-1132 `ScheduleInstallRecord` output instead of duplicating path selection, quality firewall, graph compilation, elasticity, or schedule install logic.
- Evaluate active goal portfolio consequences for deadline, density, proof value, dependency, protected-time, source authority, and recovery impact.
- Model Goal Treaty participation as local user-owned constraints that can produce treaty-safe, warn, block, or impossible consequences.
- Classify consequence severity deterministically as silent, inform, confirm, warn, block, or impossible.
- Treat deadline impossible, goal blocked, high-risk review required, source revoked, protected time broken, material displacement, unsafe state, and schedule install failure as non-suppressible events.
- Apply visibility preferences only after severity classification; quiet presentation may compress silent/inform items but must not suppress confirm, warn, block, or impossible consequences.
- Emit consequence receipts, SourceRecord references, Receipt identifiers, ReplayTrace references, rollback/failure state, and a What Ambitions knows / You inspection route for every material reflow.
- Produce deterministic reflow trace ordering, consequence receipt identifiers, treaty behavior output, and a `.consequenceReflow` `RuntimeCoreChainSegment`.
- Fail closed when schedule install is blocked, when source/receipt/replay/inspection references are missing, when treaty constraints are violated without visibility, when non-suppressible events are hidden, when reflow is irreversible, or when runtime would use a non-local boundary.

Forbidden behavior:
- No hidden suppression of consequential runtime changes.
- No same-goal-only proof claimed as cross-goal safety.
- No generic productivity metric framing, shame framing, or portfolio-optimization framing.
- No required cloud LLM, hosted backend, analytics, telemetry, or network dependency.
- No private user data export to Source Atlas or R2.
- No user-facing UI, visual, release, privacy/legal, device, accessibility certification, performance, or App Store readiness claim.
