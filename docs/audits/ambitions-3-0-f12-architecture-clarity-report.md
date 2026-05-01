# Ambitions 3.0 F12 Architecture Clarity Report

Date: 2026-05-01

Result: Green

## Resume Context

- Active train: F10-F12 Plan Life Suite Train, resumed at F12.
- Resume reason: prior train stopped at the F12 architecture clarity gate.
- F10 and F11 are complete and Green.
- F13 remains blocked until F12 is Green, committed, and pushed.

## Plan Responsibility Map

- `PlanFeatureModels.swift`: 667 lines after F12, responsibility review zone. F12 added only one dashboard field and kept new state/projection in a focused file.
- `PlanLifeSuiteState.swift`: focused Plan Life Suite projection file.
- `PlanLifeSuiteCard.swift`: focused Plan Life Suite render file.
- `PlanScreenContractSnapshot.swift`: focused screen-contract snapshot file.
- `PlanFeatureService.swift`: 2394 lines after F12, pre-existing extraction-required zone. F12 added narrow projector wiring only.
- `PlanScreen.swift`: 1978 lines after F12, pre-existing extraction-required zone. F12 added a narrow card hook and route handler only.
- `PreviewPlanScenarios.swift`: 816 lines after F12, extraction-recommended zone. F12 updated deterministic preview fixtures for the new dashboard field.
- `PlanPanels.swift`: not present in the current repo state.

## Existing F12 Support

Repo evidence already contained typed Plan support for:

- reflow reason state through `PlanRealityReflowState` and `PlanRealityBreakReasonKind`
- recovery entry state through `PlanRecoveryEntryState`
- decision debt and conflict negotiation through `PlanDecisionDebtState` and `PlanConflictCourtState`
- recovery gradient, Save the Day, reflow receipt preview, and recovery maturity state
- confirmation boundaries, undo posture, safe local suggestions, and calendar-write boundaries
- focused Plan tests covering suggestion-only behavior, no mutation, confirmation, and copy guard posture

## F12 Home

F12 can live safely in focused Plan-owned files:

- `PlanReflowDecisionState.swift`
- `PlanReflowDecisionCard.swift`

Small integrations are safe in:

- `PlanDashboard` field wiring
- `RepositoryBackedPlanService` projector invocation
- `PlanScreen` render hook and route handler
- `PlanScreenContractSnapshot` copy samples
- `PreviewPlanScenarios` deterministic fixtures
- `PlanFeatureServiceTests`

## Safe / Forbidden Files

Safe F12 files:

- `Native/Ambitions/Features/Plan/**`
- `Native/Ambitions/PreviewSupport/PreviewPlanScenarios.swift`
- `Native/AmbitionsTests/Plan/**`
- `docs/audits/**`
- `docs/codex/**`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

Forbidden:

- `.github/workflows/**`
- runtime dependency manifests
- persistence, sync, backend, or paid-service assumptions
- Today behavior changes without explicit handoff
- Shell/Meridian work
- broad Goals/You/Capture work
- global legacy identifier migration

## Extraction Decision

No pre-implementation extraction is required. `PlanFeatureService.swift` and `PlanScreen.swift` remain large pre-existing files, but F12 can avoid making them logic owners by placing the new state/projection and UI body in focused files.

## Validation Plan

- `scripts/build-local.sh`
- focused `PlanFeatureServiceTests`
- `scripts/swiftui-architecture-scan.sh || true`
- `scripts/run-doc-qa.sh || true`
- touched-path copy guard
- `git diff --check`

## Gate

F12 clarity gate: Green.

F12 may proceed because the implementation can be deterministic, Plan-owned, user-confirmed, privacy-safe, and covered by focused tests without a broad Plan service rewrite or Today behavior change.
