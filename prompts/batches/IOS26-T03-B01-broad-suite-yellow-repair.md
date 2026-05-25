<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T03-B01 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T03-B01`

## Train ID and title
`TRAIN_03` - Private Life Runtime centralization and proof harness

## Batch role in train
Batch 1 of 3 in TRAIN_03

## Upstream dependencies
- `TRAIN_00`
- `TRAIN_01`

## Downstream dependencies
- `TRAIN_04`
- `TRAIN_04A`
- `TRAIN_04B`
- `TRAIN_04C`
- `TRAIN_04D`
- `TRAIN_04E`
- `TRAIN_05`
- `TRAIN_06`
- `TRAIN_08`
- `TRAIN_09`

## Objective
Preserve the original objective below and implement only the sealed IOS26 work-order boundary.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
Preserve local-first deterministic behavior. Do not introduce external personal-data, cloud LLM, analytics, tracking, backend SDK, or paid service dependencies.

## Accessibility constraints
Preserve VoiceOver semantics, Dynamic Type, Reduce Motion, Increase Contrast, and 44 pt minimum touch-target expectations where UI is touched. Do not claim accessibility verification without proof.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- `private_life_runtime` owns runtime/recommendation/compiler work under `Native/Ambitions/Runtime`, `Native/Ambitions/Domain`, and `Native/Ambitions/Services`.
- `proof_receipt_replay` owns receipt, proof, and replay connections used by runtime traces.

## Allowed files/directories
- Scope is limited to the original prompt intent and the active owner files identified after truth/source inspection.

## Forbidden files/directories
- No cloud dependency.
- No LLM dependency.
- No analytics/tracking SDK.
- No top-level IA changes.
- No release/accessibility/performance/privacy claims without proof.

## Exact implementation steps
1. Re-read active truth files.
2. Inspect only the allowed source and proof areas.
3. Implement the smallest patch that satisfies this sealed work order.
4. Write the required proof artifact.
5. Run validation and report proof honestly.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T03-B01 TEST=AmbitionsTests
```

## Proof artifacts to write
- `build/reports/ios26-flagship/<batch-id>.md`
- `build/reports/ios26-baseline/`
- `build/reports/ios26-migration/`
- `build/reports/ios26-shell/`
- `build/reports/private-life-runtime/`
- `build/reports/goal-intent-compiler/`
- `build/reports/life-context/`
- `build/reports/step-optionality/`
- `build/reports/source-atlas-runtime-bridge/`
- `build/reports/capture-runtime-bridge/`
- `build/reports/core-replacement-contracts/`
- `build/reports/core-life-object-store/`
- `build/reports/time-operations/`
- `build/reports/reminder-operations/`
- `build/reports/project-step-operations/`
- `build/reports/life-knowledge-operations/`
- `build/reports/life-command-search/`
- `build/reports/private-life-runtime-integration/`
- `build/reports/reality-meridian/`
- `build/reports/lifeshape-field/`
- `build/reports/constellation-atlas/`
- `build/reports/atmosphere-composer/`
- `build/reports/user-system-profile/`
- `build/reports/proof-receipts-replay/`
- `build/reports/data-safety/`
- `build/reports/external-surfaces/`
- `build/reports/accessibility-nutrition/`
- `build/reports/performance/`
- `build/reports/repo-hygiene/`
- `build/reports/release-candidate/`

## Green / Yellow / Red gates
Green: sealed objective, validation, and proof artifact pass. Yellow: bounded gap with owner, reason, no-claim boundary, and follow-up gate. Red: missing prompt, boundary violation, failed validation without accepted Yellow, or forbidden dependency/claim.

## Rollback behavior
Rollback only files touched by this batch and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
Status:
Files changed:
Validation run:
Validation not run:
Proof artifacts:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Rollback:

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
# IOS26-T03-B01 Broad Suite Yellow Repair

Status: Runner-required repair prompt
Owner: Codex operator
Scope: Repair the current broad `AmbitionsTests` Yellow that blocks committing the already-run `IOS26-T03-B01` runtime-kernel slice.

## Required Read Order

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `README.md`
10. `docs/README.md`
11. `project.yml`
12. `Package.swift`

## Starting State

The worktree intentionally contains the uncommitted `IOS26-T03-B01` runtime-kernel slice:

- `Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift`
- `Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift`
- `Native/Ambitions/Runtime/PrivateLifeRuntimeKernelContracts.swift`
- `Native/AmbitionsTests/Runtime/AmbitionsRuntimeBoundaryTests.swift`
- `Native/AmbitionsTests/Runtime/AmbitionsRuntimeKernelContractsTests.swift`
- `build/reports/private-life-runtime/kernel-contracts.md`

Do not revert or rewrite those files except to preserve compile/test compatibility if directly required.

## Repair Target

Latest broad-suite summary:

- `.codex/xcode-summaries/IOS26-T03-B01/20260522T154136Z/focused-test-summary.json`
- log `.codex/xcode-logs/IOS26-T03-B01/20260522T154136Z/focused-test.log`

Failing test families:

- `AmbitionsOSVerticalSliceProofModelsTests`
- `AppShellNavigationTests`
- `CoreSurfaceIntegrationScenarioTests`
- `SourceAtlasCoverageRuntimeFixtureModelsTests`

Repair only the smallest live-source or test drift needed to make these families pass without weakening truth, release, privacy, or local-first boundaries.

Known likely drift points:

- `AppMeridianShellChromeState.launchDefault.rollbackLabel` must satisfy both rollback-to-native and meridian-opt-in contract tests without reintroducing a noncanonical tab.
- The You system-center local memory status has conflicting expectations between local proof integration and current You service tests; repair by aligning the assertion or source with active truth without weakening local-only wording.
- `SourceAtlasCoverageRuntimeFixtureModelsTests.repoRoot()` appears to resolve to `Native/` instead of the repo root; fix the fixture-root lookup rather than moving fixture files.
- `AmbitionsOSVerticalSliceProofModelsTests` expects action receipt order while `AmbitionsOSProofTrustReceipt` normalizes receipt IDs deterministically; repair the assertion or model only if active source truth supports it.

## Allowed Files

Prefer these files only:

- `Native/Ambitions/App/AppShellPresentationMode.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `Native/AmbitionsTests/App/CoreSurfaceIntegrationScenarioTests.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSVerticalSliceProofModelsTests.swift`
- `Native/AmbitionsTests/Domain/SourceAtlasCoverageRuntimeFixtureModelsTests.swift`
- `build/reports/private-life-runtime/kernel-contracts.md`

If a different file is required, stop and explain why before broadening.

## Validation

Run:

```bash
git diff --check
make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests/Domain/AmbitionsOSVerticalSliceProofModelsTests
make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests/App/AppShellNavigationTests
make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests/App/CoreSurfaceIntegrationScenarioTests
make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests/Domain/SourceAtlasCoverageRuntimeFixtureModelsTests
make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests
```

If broad `AmbitionsTests` still fails outside the repaired families, classify the failures with owner/no-claim boundary and do not overclaim Green.

## Closeout

Return Green only if the focused repaired families and broad `AmbitionsTests` pass. Otherwise return Yellow or Red with exact failures and no release/test-suite overclaim.
----- END ORIGINAL PROMPT -----
