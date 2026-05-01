# Current Run State

- current task: F08 Placement Resolver
- task size: M/L
- active mode: Product Train / F07-F09 Capture Placement Train
- active primitive: Placement Resolver
- active surface: Capture
- active context pack: Ambitions 3.0 source stack plus F07-F09 train manifest and Placement Resolver canon
- active skill: phase-executor plus repo-truth-enforcer
- active operations: batch-train-gate-protocol; placement preview contract; focused Capture and Smart Attachment validation
- active validation packs: base-build-test-pack; copy-guard-pack; privacy-trust-pack; accessibility-pack; architecture-scan-pack
- docs read: README.md; docs/README.md; docs/canon/README.md; AGENTS.md; Ambitions 3.0 source stack; Batch Train Orchestrator; F04-F06 train prompt/manifest; F07-F16 train manifests/prompts for ordering; F13.5/F16.5 conditional prompts; BATCH_REGISTRY; current gap audit; F03.5 report; batch-train orchestrator report
- files allowed: Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift; Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift; Native/Ambitions/Features/Captures; Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift; Native/AmbitionsTests/Captures; docs/codex; docs/audits; .codex/reports/current-run-state.md; .codex/reports/current-batch-train-state.md
- files forbidden: Grow into Goal; Plan Life Suite; broad Goals/Plan/You work; Shell/Meridian implementation; global legacy identifier migration; .github/workflows/**; runtime dependency manifests; release-readiness claims
- accepted Yellow reason: doc QA advisory backlog unchanged; known full UI smoke readiness failures unchanged; large-file architecture warnings unchanged in substance; legacy focus command/deep-link compatibility remains intentionally deferred to F15
- preflight git: clean on main at 93aabb771fb79e21be243b6b693b2a576ccfc5b0 / 93aabb77 Complete F03.5 Today state contract hardening
- preflight validation: scripts/validate-dev-tools.sh PASS; scripts/batch-train-preflight.sh PASS; scripts/batch-train-gate-check.sh PASS; scripts/swiftui-architecture-scan.sh advisory; scripts/build-local.sh PASS on iPhone 17

## F08 Implementation

- Added `SmartAttachmentPlacementPreview` as the explicit Placement Resolver preview contract.
- Placement previews now expose original text, post-input state, suggested destination, object type, where it appears, Today impact, consequence, privacy label, and `Place it` / `Change` / `Decide later` actions.
- Capture draft previews render the placement consequence and privacy label without changing persistence or routing behavior.
- The preview logic was extracted into `SmartAttachmentPlacementPreview.swift` so `SmartAttachmentModels.swift` returned to its pre-batch 572-line responsibility-review size.
- No Grow into Goal, Plan Life Suite, broad Goals/Plan/You work, Shell/Meridian, workflow changes, runtime dependencies, or release claims were added.

## Validation

- build: `scripts/build-local.sh` PASS on iPhone 17.
- focused tests: `CapturesViewModelTests` PASS 11 tests; `SmartAttachmentServiceTests` PASS 10 tests.
- focused Placement proof: `testF08PlacementPreviewShowsDestinationConsequenceAndPrivacy` PASS; `testF08NeedsPlacePreviewPreservesSafePlacementWithoutForcingStructure` PASS.
- copy guard: touched-path scan found only existing internal `triage` / failure-state taxonomy, negative test assertions, and existing no-calendar-change safety copy; no new user-facing inbox/backlog/chat/assistant/fake-AI framing introduced.
- privacy/accessibility: no account, sync, calendar mutation, silent automation, external display, or sensitive-data persistence change; placement preview exposes privacy label and visible alternatives before confirmation.
- architecture scan: advisory only; the temporary `SmartAttachmentModels.swift` threshold crossing was repaired by extracting `SmartAttachmentPlacementPreview.swift`.
- diff whitespace: `git diff --check` PASS.
- project generation: `xcodegen generate` PASS and `scripts/build-local.sh` regenerated/compiled the new file.

## Gate

- F08 gate result: Green with accepted background Yellow recorded.
- stop condition: none introduced by current batch.
- next phase: commit F08, then continue to F09 Capture-to-Goal / Grow into Goal.
- last checkpoint: validation complete and tracking docs updating.
