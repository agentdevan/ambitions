# AOS08 Alternate Path Kernel Path Portfolio Report
<!-- markdownlint-disable MD013 -->

Result: Green
Date: 2026-05-06
Train: AOS01-AOS30 AmbitionsOS Local Intelligence Train
Batch: AOS08 Alternate Path Kernel Path Portfolio
Owner: Alternate Path Kernel

## Summary

AOS08 adds an additive native Alternate Path Kernel contract for path
portfolios, path candidates, path-change receipts, review-state projection,
proof-transfer overlap, Source Atlas source/freshness/review gates,
professional-boundary scaffolds, external-projection privacy protection,
non-shaming language, no-guarantee language, and value-only runtime boundaries.

This is typed domain proof only. It adds no Goal Detail UI, alternate-path
runtime, recommendation runtime, path mutation, Life Graph mutation,
requirement transfer runtime, proof transfer runtime, source certification,
official requirement database, persistence/schema, external projection,
sync/account/backend service, hosted AI, release/platform claim,
legal/current-requirement claim, or public accessibility proof.

## Decision Record

Owner files selected:

- `Native/Ambitions/Domain/AmbitionsOSAlternatePathModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSAlternatePathModelsTests.swift`

Reason: AOS08 is an Alternate Path Kernel domain-contract batch that depends on
AOS05 starting position, AOS06 compiled goals, and AOS07 local goal pack slots.
The repo already has GoalEngine alternate-interpretation and adaptation seams,
so AOS08 adds a compact adjacent AOS portfolio contract rather than modifying
large existing GoalEngine files or Goal Detail UI.

Large-file, compatibility, persistence, privacy, performance, and release
gates: no large production UI file, route/raw value, persistence/schema,
external payload, platform surface, performance-heavy runtime, or release copy
was touched. Path portfolios are value-only, require active plus alternate path
coverage, require source/proof overlap for transfer, require user-reviewable
path-change receipts, and block hidden mutation, runtime-store behavior,
guaranteed outcomes, and shame language.

## Files Read

- `docs/codex/batches/AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt.md`
- `docs/canon/AmbitionsOS_Alternate_Path_Kernel.md`
- `docs/canon/AmbitionsOS_Runtime_Contract.md`
- `docs/codex/AMBITIONSOS_AOS_BATCH_GATE_MATRIX.md`
- `docs/codex/AMBITIONSOS_AOS_INVARIANT_LEDGER.md`
- `docs/codex/HPS_CROSS_TRAIN_INTEGRATION_MAP.md`
- `Native/Ambitions/Domain/AmbitionsOSStartingPositionModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSGoalPathCompilerModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLocalGoalPackModels.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalPathCompilerModels.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalEngineAdaptationService.swift`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `Native/Ambitions/Domain/AmbitionsOSAlternatePathModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSAlternatePathModelsTests.swift`
- `docs/audits/aos08-alternate-path-kernel-path-portfolio-report.md`
- `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md`
- `docs/codex/AMBITIONSOS_AOS_TEST_IMPACT_MATRIX.md`
- `docs/codex/AMBITIONSOS_AOS_EVIDENCE_LEDGER.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Fixture Groups Named

- review-ready portfolio with active and alternate path
- invalid schema and malformed portfolio/path rejection
- active-path and alternative-path coverage gates
- proof transfer requiring requirement and source overlap
- source-check/professional-boundary review gates
- shame-language and guaranteed-outcome blocking
- path-change receipt requirement without Life Graph mutation
- hidden mutation, runtime-store, and sensitive projection blocking

## Validation Run

- `xcodegen generate`
- first focused `xcodebuild` run failed on malformed test fixture missing `kind`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AmbitionsOSAlternatePathModelsTests test CODE_SIGNING_ALLOWED=NO`
- `git diff --check`
- `scripts/cqs-product-drift-scan.sh docs/audits/aos08-alternate-path-kernel-path-portfolio-report.md || true`
- `scripts/cqs-privacy-security-claim-scan.sh docs/audits/aos08-alternate-path-kernel-path-portfolio-report.md || true`
- `scripts/sa-alternative-path-option-value-scan.sh || true`
- `scripts/sa-projection-fixture-coverage-scan.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- `scripts/swiftui-architecture-scan.sh || true`
- `scripts/run-doc-qa.sh || true`

Focused test result: `AmbitionsOSAlternatePathModelsTests` executed 8 tests
with 0 failures after repairing the malformed fixture. `xcodebuild` logged
expected simulator app-group `NOT_CODESIGNED` warnings under
`CODE_SIGNING_ALLOWED=NO`; they did not fail the test. Product-drift and
privacy/security scans returned 0 hits on this report. Source Atlas alternate
path / option value and projection fixture scans returned no hits. `git diff
--check` passed. Batch train gate returned only the expected dirty-worktree
hint before commit. Architecture scan completed with existing large-file
advisories outside AOS08 owner files. Docs QA completed with lychee 0 errors
and longstanding repo-wide markdownlint findings unrelated to AOS08.

## Yellow Items

- AOS08 does not add visible Goal Detail path-portfolio UI.
- AOS08 does not mutate the Life Graph or activate/switch paths.
- AOS08 does not implement proof transfer, requirement transfer, source
  certification, official requirements, recommendation runtime, or external
  projection.
- Repo-wide docs QA still reports longstanding markdownlint debt. Lychee had
  0 errors.

## Hard Red Status

No Hard Red known. AOS08 stays inside allowed domain/test/docs boundaries and
adds no hidden mutation, source overclaim, privacy leak, new top-level surface,
runtime AI, backend/sync/account dependency, runtime store behavior, guaranteed
outcome claim, shame language, or release/platform readiness claim.

## Rollback Path

Revert the AOS08 commit. No migration, schema rollback, persistence cleanup,
route cleanup, source-certification cleanup, local-pack cleanup, remote-service
cleanup, UI rollback, or platform cleanup is required.

## Next Eligible Batch

AOS09 Option Value North Star.
