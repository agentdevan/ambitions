# F03.5 Today Execution State Contract Hardening Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Path: docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md
Status: Copy/paste ready batch prompt


Run immediately after F03 and before F04.

Docs to read: README.md, docs/README.md, AGENTS.md, Ambitions 3.0 source stack, Batch Train Orchestrator, SwiftUI State Contract Standard, Feature Boundary Constitution, State Projection Extraction Rules, F01-F03 audit reports, BATCH_REGISTRY, CONTEXT_INDEX.

Task width: M/L Quality Train architecture hygiene. Allowed files: Today state/projection/panel/screen/test/preview files, F03.5 audit report, run-state docs, batch registry/index. Forbidden files: Plan, Capture, Goals, You/Profile, shell/routing outside Today, `.github/workflows/**`, dependency manifests, Step Session behavior, Action Closure, Proof/Receipt, global identifier migration.

Inspect exactly: `Native/Ambitions/Features/Today/TodayExecutionViewState.swift`, `TodayPanels.swift`, `TodayScreen.swift`, `Native/AmbitionsTests/Today/TodayViewModelTests.swift`.

Extraction candidates: `DayRailViewState.swift`, `DayRailProjection.swift`, `DayRailStepDetailState.swift`, `TodayStepDetailPanel.swift`, `TodayExecutionProjector.swift`, `TodayExecutionCompatibility.swift`, `TodayScreenContractSnapshot.swift`.

Rules: Do not implement F04. Do not add Step Session behavior. Do not add new user-facing Today behavior. Do not migrate global identifiers. Refactor only if it reduces responsibility creep and preserves tests. If no extraction is needed, document why and pass with no app-code change.

Tests: `scripts/build-local.sh`, focused `TodayViewModelTests`, `TodayFreshGoalVisibilityTests`, `TodayShellIntegrationTests`, `git diff --check`, `scripts/swiftui-architecture-scan.sh`.

Stop on Yellow/Red gates, forbidden scope pressure, needs review build/focused tests, privacy/copy regression, or extraction becoming a broad rewrite.

Closeout: report Result, files changed, extraction decision, validation, gate result, commit, remaining risks, next prompt.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
