# Current Batch Train State

Path: .codex/reports/current-batch-train-state.md
Status: F07 complete; F08 next if F07 commit succeeds

- train name: F07-F09 Capture Placement Train
- train type: Standard/Product Train
- active batch: F08 Placement Resolver
- completed batches: F03.5, F04, F05, F06, F07
- gate status: F07 Green with accepted background Yellow
- accepted Yellow reason: doc QA advisory backlog unchanged; known UI smoke readiness failures unchanged; large-file architecture warnings unchanged in substance; legacy focus command/deep-link compatibility deferred to F15
- current primitive: Placement Resolver next; Capture Composer completed for F07 scope
- current surface: Capture
- docs read: README.md; docs/README.md; docs/canon/README.md; AGENTS.md; Ambitions 3.0 source stack; Batch Train Orchestrator; F04-F06 train prompt/manifest; downstream train manifests/prompts for ordering; F13.5/F16.5 conditional prompts; BATCH_REGISTRY; current gap audit; F03.5 report; batch-train orchestrator report
- context pack: Ambitions 3.0 Capture / Placement train context plus privacy/accessibility context
- skill: phase-executor; repo-truth-enforcer
- operation: batch-train-gate-protocol; Capture composer cleanup; per-batch report and commit
- validation pack: base-build-test-pack; focused Capture tests; copy-guard-pack; privacy-trust-pack; accessibility-pack; architecture-scan-pack
- files allowed for F07: Native/Ambitions/Features/Captures; Native/AmbitionsTests/Captures; Capture screen contract state; docs/codex; docs/audits; .codex/reports/current-run-state.md; .codex/reports/current-batch-train-state.md
- files forbidden: .github/workflows/**; runtime dependency additions; Shell/Meridian implementation; Placement Resolver full behavior; Grow into Goal; Plan/Capture/Goals/You broad work; global identifier migration; unapproved release claims
- files touched: Native/Ambitions/Domain/ScreenContractModels.swift; Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift; Native/Ambitions/Features/Captures/CapturesScreen.swift; Native/Ambitions/Features/Captures/CapturesViewModel.swift; Native/AmbitionsTests/Captures/CapturesViewModelTests.swift; docs/codex/BATCH_REGISTRY.md; docs/audits/ambitions-3-0-f07-capture-composer-report.md; .codex/reports/current-run-state.md; .codex/reports/current-batch-train-state.md
- commands run: xcodegen generate; scripts/build-local.sh; focused xcodebuild CapturesViewModelTests; scripts/swiftui-architecture-scan.sh; touched-path copy scan; git diff --check; git status --short .github/workflows
- tests run: scripts/build-local.sh PASS; CapturesViewModelTests PASS 11 tests
- failures: one focused Capture test run failed on stale `Recent captures` screen-contract requirement after the F07 canon update; screen contract was updated to `Ready to Place` and sequential rerun passed. One parallel build/test attempt produced an Xcode build database lock; rerun sequentially passed.
- architecture warnings: `CapturesScreen.swift` briefly crossed to 700 lines during F07, then `CaptureDraftRoutePreviewCard.swift` was extracted; final `CapturesScreen.swift` is 606 lines. Broader pre-existing architecture warnings remain advisory.
- file responsibility warnings: F07 avoided leaving new composer preview behavior inside a large screen file by adding a focused Capture-owned card file.
- checkpoint history: preflight clean on main; F04 committed; F05 committed; F06 committed; F07 implemented; build and focused validation Green; accepted Yellow recorded; report written
- stop condition: none for F07
- next batch: F08 Placement Resolver
- resume instructions: commit F07, then read this file, current-run-state, F07 report, F07-F09 manifest/prompt, Capture canon, and Placement Resolver canon before continuing to F08
