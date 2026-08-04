# Implementation Plan

## Outcome and boundary

Implement conformance-first deterministic Portfolio Simulation, evidence gate,
resource accounting, scenarios/sensitivity and command-free owner/Life Branch
handoffs. Production remains unavailable until upstream/user gates pass. Do not
add global scores, predictions, hidden Goal selection or mutations.

## Exact expected files

- Add `docs/canon/specifications/systems/multi-goal-portfolio-simulation.md` and
  update simulation, Goal/Path/Time, Context/Capability/current, private runtime,
  Life Branch, privacy/trust/degraded/History/evaluation/change canon.
- Add schema/config/fixtures/evidence gate validator under
  `tools/portfolio-simulation/` with `models.py`, `fixture_runner.py`,
  `activation_gate.py`, `cli.py`,
  `contracts/portfolio-snapshot-v1.schema.json`,
  `contracts/portfolio-scenario-v1.schema.json`,
  `contracts/portfolio-activation-gate-v1.schema.json`,
  `config/scenario-templates-v1.json`, `config/production-activation-v1.json`,
  `fixtures/heterogeneous-resources.json`, `fixtures/double-count-conflict.json`,
  `fixtures/evidence-gate-closed.json`, `tests/test_fixture_runner.py`, and
  `tests/test_activation_gate.py`.
- Add under `Native/Ambitions/Core/LocalRuntimeOS/Simulation/Portfolio/`:
  `PortfolioActivationGateModels.swift`, `PortfolioActivationGateLoader.swift`,
  `PortfolioSnapshotModels.swift`, `PortfolioSnapshotAssembler.swift`,
  `PortfolioResourceModels.swift`, `PortfolioResourceLedger.swift`,
  `PortfolioAllocationValidator.swift`, `PortfolioScenarioModels.swift`,
  `PortfolioScenarioTemplateRegistry.swift`, `PortfolioScenarioEvaluators.swift`,
  `PortfolioSimulationEngine.swift`, `PortfolioSimulationValidator.swift`,
  `PortfolioSensitivityEngine.swift`, `PortfolioExplanationProjector.swift`,
  `PortfolioScenarioRepository.swift`, `PortfolioInvalidationService.swift`,
  `PortfolioSimulationMigration.swift`, `PortfolioSimulationPurgeService.swift`,
  `OwnerChangeProposalBuilder.swift`, `LifeBranchDraftInputClient.swift`, and
  `PortfolioSimulationDiagnostics.swift`.
- Add typed read-only owner clients and bootstrap boundary registration; inject
  no command clients. Add Life Branch draft-input client only.
- Add UI under `Native/Ambitions/Surfaces/Goals/PortfolioSimulation/` as
  `PortfolioSelectionView.swift`, `PortfolioScenarioBuilderView.swift`,
  `PortfolioScenarioComparisonView.swift`, `PortfolioSensitivityView.swift`,
  `PortfolioSimulationGateView.swift`, and `PortfolioPreviewFixtures.swift`;
  add `PortfolioSnapshotTests.swift`, `SharedResourceLedgerTests.swift`,
  `PortfolioScenarioEngineTests.swift`, `PortfolioSensitivityTests.swift`,
  `PortfolioScenarioRepositoryTests.swift`, `PortfolioOwnerHandoffTests.swift`,
  `PortfolioActivationGateTests.swift`, and `PortfolioPrivacyBiasTests.swift`
  under `Native/AmbitionsTests/LocalRuntimeOS/Simulation/Portfolio/`; add
  `Native/AmbitionsTests/Quality/PortfolioSimulationAccessibilityTests.swift`
  and `Native/AmbitionsUITests/PortfolioSimulationUITests.swift`.
- Add signed gate/template registry resource; update `project.yml` and regenerate
  only if verified resource inclusion requires it.

Sequence: canon/contracts/gate; snapshots; resource ledger; scenario engine;
sensitivity/validation; repository/lifecycle; owner/branch handoff; conformance
UI/accessibility; production gate verifier; integration; full proof.

## Grooming review and approval

Review verdict: **PASS** after one reconciliation round. Exact conformance gate,
core files, read-only boundaries, tests and claim ceilings are named. Devan
delegated approval; grooming approved 2026-08-04.
