# Current Run State

- current task: F07 Capture Composer cleanup
- task size: M/L
- active mode: Product Train / F07-F09 Capture Placement Train
- active primitive: Capture Intake
- active surface: Capture
- active context pack: Ambitions 3.0 source stack plus F07-F09 train manifest and Placement Resolver canon
- active skill: phase-executor plus repo-truth-enforcer
- active operations: batch-train-gate-protocol; composer-driven Capture cleanup; focused Capture validation
- active validation packs: base-build-test-pack; copy-guard-pack; privacy-trust-pack; accessibility-pack; architecture-scan-pack
- docs read: README.md; docs/README.md; docs/canon/README.md; AGENTS.md; Ambitions 3.0 source stack; Batch Train Orchestrator; F04-F06 train prompt/manifest; F07-F16 train manifests/prompts for ordering; F13.5/F16.5 conditional prompts; BATCH_REGISTRY; current gap audit; F03.5 report; batch-train orchestrator report
- files allowed: Native/Ambitions/Features/Captures; Capture screen contract state; Native/AmbitionsTests/Captures; docs/codex; docs/audits; .codex/reports/current-run-state.md; .codex/reports/current-batch-train-state.md
- files forbidden: Placement Resolver behavior beyond F07 preparation; Grow into Goal; Plan Life Suite; Shell/Meridian implementation; global legacy identifier migration; .github/workflows/**; runtime dependency manifests; release-readiness claims
- accepted Yellow reason: doc QA advisory backlog unchanged; known full UI smoke readiness failures unchanged; large-file architecture warnings unchanged in substance; legacy focus command/deep-link compatibility remains intentionally deferred to F15
- preflight git: clean on main at 93aabb771fb79e21be243b6b693b2a576ccfc5b0 / 93aabb77 Complete F03.5 Today state contract hardening
- preflight validation: scripts/validate-dev-tools.sh PASS; scripts/batch-train-preflight.sh PASS; scripts/batch-train-gate-check.sh PASS; scripts/swiftui-architecture-scan.sh advisory; scripts/build-local.sh PASS on iPhone 17

## F07 Implementation

- Capture preview state now names post-input placement states as `Suggested Place`, `Needs a Decision`, or `Needs a Place`.
- The draft preview exposes canonical placement actions `Place it`, `Change`, and `Decide later`.
- The Capture screen contract now requires `Ready to Place` instead of the older `Recent captures` first-screen framing.
- `CaptureDraftRoutePreviewCard` was extracted into a focused Capture-owned view file so the batch did not worsen `CapturesScreen.swift` architecture debt.
- No Placement Resolver behavior, Grow into Goal, Plan Life Suite, Shell/Meridian, workflow changes, runtime dependencies, or release claims were added.

## Validation

- build: `scripts/build-local.sh` PASS on iPhone 17.
- focused tests: `CapturesViewModelTests` PASS 11 tests after screen-contract update; an earlier focused run correctly failed on the stale `Recent captures` requirement and was repaired.
- focused Capture proof: `testF07ComposerPreviewUsesPlacementLanguageWithoutInboxFraming` PASS; `testD12CaptureScreenContractSnapshotSatisfiesImplementationGate` PASS with `Ready to Place`.
- copy guard: touched-path scan found only guardrail text, negative test assertions, and internal `triage` / failure-state taxonomy; no new user-facing inbox/backlog/chat/assistant/fake-AI framing introduced.
- privacy/accessibility: no account, sync, calendar mutation, silent automation, or sensitive-data persistence change; preview card keeps combined accessibility label/value/hint and visible placement alternatives.
- architecture scan: advisory only; F07 extracted `CaptureDraftRoutePreviewCard.swift`, reducing `CapturesScreen.swift` from 680 pre-batch lines to 606 lines after briefly crossing 700 during implementation.
- diff whitespace: `git diff --check` PASS.
- project generation: `xcodegen generate` PASS and `scripts/build-local.sh` regenerated/compiled the new file.

## Gate

- F07 gate result: Green with accepted background Yellow recorded.
- stop condition: none introduced by current batch.
- next phase: commit F07, then continue to F08 Placement Resolver.
- last checkpoint: validation complete and tracking docs updating.
