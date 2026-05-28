# Linear Sync Dry Run

Status: dry_run_only
Generated UTC: 2026-05-28T14:49:24Z
Manifest: `.linear-sync/ambitions-linear-sync.yml`
Linear writes: none

## Summary
- active_truth: 11
- active_work: 164
- historical_reference: 1128
- ignored: 2
- proof: 855
- source: 473
- supporting_reference: 20
- test: 269
- unknown: 2992
- total scanned paths: 5914

## Proposed Linear Mappings
- `active_truth` -> class `active_truth`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: canon`, `area: process`, create_work_items=true, sync_status_only=false, priorities conflict_with_truth=1, stale_or_missing_link=2, classification_only=3
- `active_sequence_and_ios26_manifest` -> class `active_work`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: process`, `area: batch-ledger`, create_work_items=true, sync_status_only=false, priorities runnable_sequence_conflict=1, manifest_or_runner_policy_conflict=1, missing_proof_root_mapping=2, status_mirror_only=3
- `source_paths` -> class `source`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: frontend`, `area: runtime`, create_work_items=true, sync_status_only=false, priorities source_compile_or_contract_regression=1, unproven_source_present_status=2, classification_only=3
- `test_paths` -> class `test`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: process`, create_work_items=true, sync_status_only=false, priorities failing_current_test_or_compile_gate=1, stale_test_expectation=2, coverage_mapping_only=3
- `proof_paths` -> class `proof`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: batch-ledger`, `area: process`, create_work_items=false, sync_status_only=true, priorities failed_current_proof_gate=1, missing_required_proof_for_claim=2, historical_or_advisory_proof=4
- `ios26_batch_prompts` -> class `active_work`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`, labels `area: batch-ledger`, `area: process`, create_work_items=true, sync_status_only=false, priorities runnable_ios26_batch_missing_from_manifest=1, prompt_runner_header_missing=1, dependency_or_proof_root_mismatch=2, installed_not_run_status_mirror=3
- `future_decisions_specs_traceability` -> class `supporting_reference`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: canon`, `area: process`, create_work_items=false, sync_status_only=false, priorities conflicts_with_docs_truth=1, should_be_promoted_to_truth=2, reference_only=4
- `codex_state_allowlist` -> class `supporting_reference`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: process`, `area: batch-ledger`, create_work_items=false, sync_status_only=true, priorities contradicts_active_authority=1, stale_status_mirror=3, reference_only=4
- `historical_canon` -> class `historical_reference`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: canon`, create_work_items=false, sync_status_only=true, priorities active_truth_conflict=1, useful_reference_not_promoted=3, historical_only=4
- `historical_non_ios26_prompts` -> class `historical_reference`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`, labels `area: batch-ledger`, create_work_items=false, sync_status_only=true, priorities conflicts_with_ios26_authority=1, needs_retirement_or_supersession_note=3, historical_only=4

## Exclusions
- `local_generated_and_cache` -> class `ignored`, reason: Local generated artifacts, caches, and build outputs are not active Linear work by default.
- `secrets_and_machine_local` -> class `ignored`, reason: Secret-bearing or machine-local paths must not be mirrored into Linear.

## Active Canon Files
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_UPGRADES_VISION.md`
- `docs/truth/README.md`
- `docs/truth/RELEASE_TRUTH.md`

## Active Decision Records
- None

## Active Specs
- None

## Active Traceability
- None

## Active Batch Prompts
- `prompts/batches/IOS26-FLAGSHIP-TRAIN-INSTALL-00.md`
- `prompts/batches/IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01.md`
- `prompts/batches/IOS26-T00-B01-repo-source-inventory.md`
- `prompts/batches/IOS26-T00-B02-validation-baseline.md`
- `prompts/batches/IOS26-T00-B03-naming-api-drift-inventory.md`
- `prompts/batches/IOS26-T01-B01-toolchain-confirmation.md`
- `prompts/batches/IOS26-T01-B02-deployment-target-bump.md`
- `prompts/batches/IOS26-T01-B03-availability-compatibility-cleanup.md`
- `prompts/batches/IOS26-T02-B00-safe-area-root-invariant.md`
- `prompts/batches/IOS26-T02-B01-native-ios26-shell.md`
- `prompts/batches/IOS26-T02-B02-liquid-glass-token-layer.md`
- `prompts/batches/IOS26-T02-B03-icon-screenshot-foundation.md`
- `prompts/batches/IOS26-T03-B01-broad-suite-yellow-repair.md`
- `prompts/batches/IOS26-T03-B01-runtime-kernel-contracts.md`
- `prompts/batches/IOS26-T03-B02-local-only-proof-harness.md`
- `prompts/batches/IOS26-T03-B03-replayable-decision-traces.md`
- `prompts/batches/IOS26-T04-B01-compiler-input-output-model.md`
- `prompts/batches/IOS26-T04-B02-capacity-aware-compilation.md`
- `prompts/batches/IOS26-T04-B03-compiler-persistence-receipts.md`
- `prompts/batches/IOS26-T04A-B01-life-context-domain.md`
- ... 138 more

## Active Batch Work Item Candidates
- `ambitions-linear-sync:batch:IOS26-FLAGSHIP-TRAIN-INSTALL-00` -> batch `IOS26-FLAGSHIP-TRAIN-INSTALL-00`, prompt `prompts/batches/IOS26-FLAGSHIP-TRAIN-INSTALL-00.md`, runner `scripts/ambitions-codex-train.sh IOS26-FLAGSHIP-TRAIN-INSTALL-00 prompts/batches/IOS26-FLAGSHIP-TRAIN-INSTALL-00.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01` -> batch `IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01`, prompt `prompts/batches/IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01.md`, runner `scripts/ambitions-codex-train.sh IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01 prompts/batches/IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T00-B01-repo-source-inventory` -> batch `IOS26-T00-B01-repo-source-inventory`, prompt `prompts/batches/IOS26-T00-B01-repo-source-inventory.md`, runner `scripts/ambitions-codex-train.sh IOS26-T00-B01-repo-source-inventory prompts/batches/IOS26-T00-B01-repo-source-inventory.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T00-B02-validation-baseline` -> batch `IOS26-T00-B02-validation-baseline`, prompt `prompts/batches/IOS26-T00-B02-validation-baseline.md`, runner `scripts/ambitions-codex-train.sh IOS26-T00-B02-validation-baseline prompts/batches/IOS26-T00-B02-validation-baseline.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T00-B03-naming-api-drift-inventory` -> batch `IOS26-T00-B03-naming-api-drift-inventory`, prompt `prompts/batches/IOS26-T00-B03-naming-api-drift-inventory.md`, runner `scripts/ambitions-codex-train.sh IOS26-T00-B03-naming-api-drift-inventory prompts/batches/IOS26-T00-B03-naming-api-drift-inventory.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T01-B01-toolchain-confirmation` -> batch `IOS26-T01-B01-toolchain-confirmation`, prompt `prompts/batches/IOS26-T01-B01-toolchain-confirmation.md`, runner `scripts/ambitions-codex-train.sh IOS26-T01-B01-toolchain-confirmation prompts/batches/IOS26-T01-B01-toolchain-confirmation.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T01-B02-deployment-target-bump` -> batch `IOS26-T01-B02-deployment-target-bump`, prompt `prompts/batches/IOS26-T01-B02-deployment-target-bump.md`, runner `scripts/ambitions-codex-train.sh IOS26-T01-B02-deployment-target-bump prompts/batches/IOS26-T01-B02-deployment-target-bump.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T01-B03-availability-compatibility-cleanup` -> batch `IOS26-T01-B03-availability-compatibility-cleanup`, prompt `prompts/batches/IOS26-T01-B03-availability-compatibility-cleanup.md`, runner `scripts/ambitions-codex-train.sh IOS26-T01-B03-availability-compatibility-cleanup prompts/batches/IOS26-T01-B03-availability-compatibility-cleanup.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T02-B00-safe-area-root-invariant` -> batch `IOS26-T02-B00-safe-area-root-invariant`, prompt `prompts/batches/IOS26-T02-B00-safe-area-root-invariant.md`, runner `scripts/ambitions-codex-train.sh IOS26-T02-B00-safe-area-root-invariant prompts/batches/IOS26-T02-B00-safe-area-root-invariant.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T02-B01-native-ios26-shell` -> batch `IOS26-T02-B01-native-ios26-shell`, prompt `prompts/batches/IOS26-T02-B01-native-ios26-shell.md`, runner `scripts/ambitions-codex-train.sh IOS26-T02-B01-native-ios26-shell prompts/batches/IOS26-T02-B01-native-ios26-shell.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T02-B02-liquid-glass-token-layer` -> batch `IOS26-T02-B02-liquid-glass-token-layer`, prompt `prompts/batches/IOS26-T02-B02-liquid-glass-token-layer.md`, runner `scripts/ambitions-codex-train.sh IOS26-T02-B02-liquid-glass-token-layer prompts/batches/IOS26-T02-B02-liquid-glass-token-layer.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T02-B03-icon-screenshot-foundation` -> batch `IOS26-T02-B03-icon-screenshot-foundation`, prompt `prompts/batches/IOS26-T02-B03-icon-screenshot-foundation.md`, runner `scripts/ambitions-codex-train.sh IOS26-T02-B03-icon-screenshot-foundation prompts/batches/IOS26-T02-B03-icon-screenshot-foundation.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T03-B01-broad-suite-yellow-repair` -> batch `IOS26-T03-B01-broad-suite-yellow-repair`, prompt `prompts/batches/IOS26-T03-B01-broad-suite-yellow-repair.md`, runner `scripts/ambitions-codex-train.sh IOS26-T03-B01-broad-suite-yellow-repair prompts/batches/IOS26-T03-B01-broad-suite-yellow-repair.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T03-B01-runtime-kernel-contracts` -> batch `IOS26-T03-B01-runtime-kernel-contracts`, prompt `prompts/batches/IOS26-T03-B01-runtime-kernel-contracts.md`, runner `scripts/ambitions-codex-train.sh IOS26-T03-B01-runtime-kernel-contracts prompts/batches/IOS26-T03-B01-runtime-kernel-contracts.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T03-B02-local-only-proof-harness` -> batch `IOS26-T03-B02-local-only-proof-harness`, prompt `prompts/batches/IOS26-T03-B02-local-only-proof-harness.md`, runner `scripts/ambitions-codex-train.sh IOS26-T03-B02-local-only-proof-harness prompts/batches/IOS26-T03-B02-local-only-proof-harness.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T03-B03-replayable-decision-traces` -> batch `IOS26-T03-B03-replayable-decision-traces`, prompt `prompts/batches/IOS26-T03-B03-replayable-decision-traces.md`, runner `scripts/ambitions-codex-train.sh IOS26-T03-B03-replayable-decision-traces prompts/batches/IOS26-T03-B03-replayable-decision-traces.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04-B01-compiler-input-output-model` -> batch `IOS26-T04-B01-compiler-input-output-model`, prompt `prompts/batches/IOS26-T04-B01-compiler-input-output-model.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04-B01-compiler-input-output-model prompts/batches/IOS26-T04-B01-compiler-input-output-model.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04-B02-capacity-aware-compilation` -> batch `IOS26-T04-B02-capacity-aware-compilation`, prompt `prompts/batches/IOS26-T04-B02-capacity-aware-compilation.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04-B02-capacity-aware-compilation prompts/batches/IOS26-T04-B02-capacity-aware-compilation.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04-B03-compiler-persistence-receipts` -> batch `IOS26-T04-B03-compiler-persistence-receipts`, prompt `prompts/batches/IOS26-T04-B03-compiler-persistence-receipts.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04-B03-compiler-persistence-receipts prompts/batches/IOS26-T04-B03-compiler-persistence-receipts.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04A-B01-life-context-domain` -> batch `IOS26-T04A-B01-life-context-domain`, prompt `prompts/batches/IOS26-T04A-B01-life-context-domain.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04A-B01-life-context-domain prompts/batches/IOS26-T04A-B01-life-context-domain.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04A-B02-historical-catchup-intake` -> batch `IOS26-T04A-B02-historical-catchup-intake`, prompt `prompts/batches/IOS26-T04A-B02-historical-catchup-intake.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04A-B02-historical-catchup-intake prompts/batches/IOS26-T04A-B02-historical-catchup-intake.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04A-B03-runtime-effect-proof` -> batch `IOS26-T04A-B03-runtime-effect-proof`, prompt `prompts/batches/IOS26-T04A-B03-runtime-effect-proof.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04A-B03-runtime-effect-proof prompts/batches/IOS26-T04A-B03-runtime-effect-proof.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04A-B04-you-controls-receipts` -> batch `IOS26-T04A-B04-you-controls-receipts`, prompt `prompts/batches/IOS26-T04A-B04-you-controls-receipts.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04A-B04-you-controls-receipts prompts/batches/IOS26-T04A-B04-you-controls-receipts.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04A-B05-you-life-context-premium-panel` -> batch `IOS26-T04A-B05-you-life-context-premium-panel`, prompt `prompts/batches/IOS26-T04A-B05-you-life-context-premium-panel.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04A-B05-you-life-context-premium-panel prompts/batches/IOS26-T04A-B05-you-life-context-premium-panel.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04A-B06-anti-bucket-factor-ledger-proof` -> batch `IOS26-T04A-B06-anti-bucket-factor-ledger-proof`, prompt `prompts/batches/IOS26-T04A-B06-anti-bucket-factor-ledger-proof.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04A-B06-anti-bucket-factor-ledger-proof prompts/batches/IOS26-T04A-B06-anti-bucket-factor-ledger-proof.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04B-B01-step-candidate-field` -> batch `IOS26-T04B-B01-step-candidate-field`, prompt `prompts/batches/IOS26-T04B-B01-step-candidate-field.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04B-B01-step-candidate-field prompts/batches/IOS26-T04B-B01-step-candidate-field.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04B-B02-rejection-reasoning-loop` -> batch `IOS26-T04B-B02-rejection-reasoning-loop`, prompt `prompts/batches/IOS26-T04B-B02-rejection-reasoning-loop.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04B-B02-rejection-reasoning-loop prompts/batches/IOS26-T04B-B02-rejection-reasoning-loop.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04B-B03-deadline-simulation-engine` -> batch `IOS26-T04B-B03-deadline-simulation-engine`, prompt `prompts/batches/IOS26-T04B-B03-deadline-simulation-engine.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04B-B03-deadline-simulation-engine prompts/batches/IOS26-T04B-B03-deadline-simulation-engine.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04B-B04-approval-receipts-learning` -> batch `IOS26-T04B-B04-approval-receipts-learning`, prompt `prompts/batches/IOS26-T04B-B04-approval-receipts-learning.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04B-B04-approval-receipts-learning prompts/batches/IOS26-T04B-B04-approval-receipts-learning.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04B-B05-exhaustive-simulation-gauntlet` -> batch `IOS26-T04B-B05-exhaustive-simulation-gauntlet`, prompt `prompts/batches/IOS26-T04B-B05-exhaustive-simulation-gauntlet.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04B-B05-exhaustive-simulation-gauntlet prompts/batches/IOS26-T04B-B05-exhaustive-simulation-gauntlet.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04B-B06-today-optionality-ui` -> batch `IOS26-T04B-B06-today-optionality-ui`, prompt `prompts/batches/IOS26-T04B-B06-today-optionality-ui.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04B-B06-today-optionality-ui prompts/batches/IOS26-T04B-B06-today-optionality-ui.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04C-B01-source-atlas-match-and-pack-selection` -> batch `IOS26-T04C-B01-source-atlas-match-and-pack-selection`, prompt `prompts/batches/IOS26-T04C-B01-source-atlas-match-and-pack-selection.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04C-B01-source-atlas-match-and-pack-selection prompts/batches/IOS26-T04C-B01-source-atlas-match-and-pack-selection.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04C-B02-capability-graph-to-path-composition` -> batch `IOS26-T04C-B02-capability-graph-to-path-composition`, prompt `prompts/batches/IOS26-T04C-B02-capability-graph-to-path-composition.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04C-B02-capability-graph-to-path-composition prompts/batches/IOS26-T04C-B02-capability-graph-to-path-composition.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04C-B03-path-to-step-candidate-expansion` -> batch `IOS26-T04C-B03-path-to-step-candidate-expansion`, prompt `prompts/batches/IOS26-T04C-B03-path-to-step-candidate-expansion.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04C-B03-path-to-step-candidate-expansion prompts/batches/IOS26-T04C-B03-path-to-step-candidate-expansion.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04C-B04-runtime-compiler-receipts-replay` -> batch `IOS26-T04C-B04-runtime-compiler-receipts-replay`, prompt `prompts/batches/IOS26-T04C-B04-runtime-compiler-receipts-replay.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04C-B04-runtime-compiler-receipts-replay prompts/batches/IOS26-T04C-B04-runtime-compiler-receipts-replay.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04C-B05-source-atlas-coverage-gauntlet` -> batch `IOS26-T04C-B05-source-atlas-coverage-gauntlet`, prompt `prompts/batches/IOS26-T04C-B05-source-atlas-coverage-gauntlet.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04C-B05-source-atlas-coverage-gauntlet prompts/batches/IOS26-T04C-B05-source-atlas-coverage-gauntlet.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04C-B06-source-atlas-you-inspection-surface` -> batch `IOS26-T04C-B06-source-atlas-you-inspection-surface`, prompt `prompts/batches/IOS26-T04C-B06-source-atlas-you-inspection-surface.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04C-B06-source-atlas-you-inspection-surface prompts/batches/IOS26-T04C-B06-source-atlas-you-inspection-surface.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04D-B01-capture-semantic-extraction` -> batch `IOS26-T04D-B01-capture-semantic-extraction`, prompt `prompts/batches/IOS26-T04D-B01-capture-semantic-extraction.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04D-B01-capture-semantic-extraction prompts/batches/IOS26-T04D-B01-capture-semantic-extraction.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04D-B02-goal-relevance-scanner` -> batch `IOS26-T04D-B02-goal-relevance-scanner`, prompt `prompts/batches/IOS26-T04D-B02-goal-relevance-scanner.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04D-B02-goal-relevance-scanner prompts/batches/IOS26-T04D-B02-goal-relevance-scanner.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- `ambitions-linear-sync:batch:IOS26-T04D-B03-plan-insertion-approval` -> batch `IOS26-T04D-B03-plan-insertion-approval`, prompt `prompts/batches/IOS26-T04D-B03-plan-insertion-approval.md`, runner `scripts/ambitions-codex-train.sh IOS26-T04D-B03-plan-insertion-approval prompts/batches/IOS26-T04D-B03-plan-insertion-approval.md`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`
- ... 87 more

## Superseded Batch Prompts
- `docs/codex/batches/AFI01_Canon_Language_Purge.md`
- `docs/codex/batches/AFI02_IA_Hierarchy_Lock.md`
- `docs/codex/batches/AFI03_Flagship_Object_Silhouettes.md`
- `docs/codex/batches/AFI04_Material_System_Proof.md`
- `docs/codex/batches/AFI05_Shell_And_Continuity_Chrome.md`
- `docs/codex/batches/AFI06_Today_Reality_Meridian.md`
- `docs/codex/batches/AFI07_Goals_Constellation_Atlas.md`
- `docs/codex/batches/AFI08_Capture_Atmosphere_Composer.md`
- `docs/codex/batches/AFI09_Time_LifeShape_Field.md`
- `docs/codex/batches/AFI10_You_User_System_Profile.md`
- `docs/codex/batches/AFI11_Trust_Seam_And_Receipts.md`
- `docs/codex/batches/AFI12_Accessibility_And_State_Proof.md`
- `docs/codex/batches/AFI13_Visual_QA_And_Drift_Gallery.md`
- `docs/codex/batches/AFI14_Cross_Surface_Coherence_Review.md`
- `docs/codex/batches/AFI15_Founder_Acceptance_Review.md`
- `docs/codex/batches/AFI16_Release_Claim_Safety_Review.md`
- `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md`
- `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md`
- `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md`
- `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md`
- ... 777 more

## Proof Artifacts
- `build/reports/capture-runtime-bridge/.gitkeep`
- `build/reports/capture-runtime-bridge/capture-runtime-gauntlet-output.json`
- `build/reports/capture-runtime-bridge/capture-runtime-gauntlet.md`
- `build/reports/capture-runtime-bridge/capture-ui-review-surface.md`
- `build/reports/capture-runtime-bridge/future-proof-context-storage.md`
- `build/reports/capture-runtime-bridge/goal-relevance-scanner.md`
- `build/reports/capture-runtime-bridge/plan-insertion-approval.md`
- `build/reports/capture-runtime-bridge/receipts-replay-corrections.md`
- `build/reports/capture-runtime-bridge/semantic-extraction.md`
- `build/reports/core-life-object-store/.gitkeep`
- `build/reports/core-replacement-contracts/.gitkeep`
- `build/reports/core-replacement-contracts/IOS26-T04E-B02.md`
- `build/reports/core-replacement-contracts/IOS26-T04E-B03.md`
- `build/reports/core-replacement-contracts/IOS26-T04E-B05.md`
- `build/reports/core-replacement-contracts/IOS26-T04E-B06.md`
- `build/reports/core-replacement-contracts/IOS26-T04E-B07.md`
- `build/reports/core-replacement-contracts/TRAIN_04E_CLOSEOUT.md`
- `build/reports/core-replacement-contracts/calendar-p0-contract-harness.md`
- `build/reports/core-replacement-contracts/cross-app-journey-contract-harness.md`
- `build/reports/core-replacement-contracts/notion-p0-contract-harness.md`
- ... 835 more

## Proof Status Mapping
- green: 289
- placeholder: 9
- red: 128
- unknown: 243
- yellow: 186

## Proof Follow-up Candidates
- `ambitions-linear-sync:proof:build-reports-capture-runtime-bridge-capture-ui-review-surface-md` -> `yellow` proof status, artifact `build/reports/capture-runtime-bridge/capture-ui-review-surface.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `not verified`
- `ambitions-linear-sync:proof:build-reports-capture-runtime-bridge-future-proof-context-storage-md` -> `unknown` proof status, artifact `build/reports/capture-runtime-bridge/future-proof-context-storage.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `no explicit Green/Yellow/Red status marker found`
- `ambitions-linear-sync:proof:build-reports-capture-runtime-bridge-goal-relevance-scanner-md` -> `yellow` proof status, artifact `build/reports/capture-runtime-bridge/goal-relevance-scanner.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-capture-runtime-bridge-plan-insertion-approval-md` -> `yellow` proof status, artifact `build/reports/capture-runtime-bridge/plan-insertion-approval.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Not verified`
- `ambitions-linear-sync:proof:build-reports-capture-runtime-bridge-semantic-extraction-md` -> `yellow` proof status, artifact `build/reports/capture-runtime-bridge/semantic-extraction.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-core-replacement-contracts-ios26-t04e-b02-md` -> `yellow` proof status, artifact `build/reports/core-replacement-contracts/IOS26-T04E-B02.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-core-replacement-contracts-ios26-t04e-b03-md` -> `yellow` proof status, artifact `build/reports/core-replacement-contracts/IOS26-T04E-B03.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Not verified`
- `ambitions-linear-sync:proof:build-reports-core-replacement-contracts-ios26-t04e-b05-md` -> `yellow` proof status, artifact `build/reports/core-replacement-contracts/IOS26-T04E-B05.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-core-replacement-contracts-ios26-t04e-b06-md` -> `yellow` proof status, artifact `build/reports/core-replacement-contracts/IOS26-T04E-B06.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-core-replacement-contracts-ios26-t04e-b07-md` -> `yellow` proof status, artifact `build/reports/core-replacement-contracts/IOS26-T04E-B07.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Not verified`
- `ambitions-linear-sync:proof:build-reports-core-replacement-contracts-train-04e-closeout-md` -> `yellow` proof status, artifact `build/reports/core-replacement-contracts/TRAIN_04E_CLOSEOUT.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Not verified`
- `ambitions-linear-sync:proof:build-reports-core-replacement-contracts-cross-app-journey-contract-harness-md` -> `yellow` proof status, artifact `build/reports/core-replacement-contracts/cross-app-journey-contract-harness.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-core-replacement-contracts-notion-p0-contract-harness-md` -> `yellow` proof status, artifact `build/reports/core-replacement-contracts/notion-p0-contract-harness.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-core-replacement-contracts-reminders-p0-contract-harness-md` -> `yellow` proof status, artifact `build/reports/core-replacement-contracts/reminders-p0-contract-harness.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-core-replacement-contracts-things-p0-contract-harness-md` -> `yellow` proof status, artifact `build/reports/core-replacement-contracts/things-p0-contract-harness.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-core-replacement-contracts-todoist-p0-contract-harness-md` -> `yellow` proof status, artifact `build/reports/core-replacement-contracts/todoist-p0-contract-harness.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-frontend-object-purity-ios26-frontend-install-anti-card-json` -> `red` proof status, artifact `build/reports/frontend-object-purity/IOS26-FRONTEND-INSTALL-anti-card.json`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `"status": "Red"`
- `ambitions-linear-sync:proof:build-reports-frontend-object-purity-ios26-frontend-install-anti-card-md` -> `red` proof status, artifact `build/reports/frontend-object-purity/IOS26-FRONTEND-INSTALL-anti-card.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Red`
- `ambitions-linear-sync:proof:build-reports-frontend-object-purity-ios26-t04l-b01-anti-card-json` -> `red` proof status, artifact `build/reports/frontend-object-purity/IOS26-T04L-B01-anti-card.json`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `"status": "Red"`
- `ambitions-linear-sync:proof:build-reports-frontend-object-purity-ios26-t04l-b01-anti-card-md` -> `red` proof status, artifact `build/reports/frontend-object-purity/IOS26-T04L-B01-anti-card.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Red`
- `ambitions-linear-sync:proof:build-reports-frontend-object-purity-ios26-t10-b04-anti-card-json` -> `red` proof status, artifact `build/reports/frontend-object-purity/IOS26-T10-B04-anti-card.json`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `"status": "Red"`
- `ambitions-linear-sync:proof:build-reports-frontend-object-purity-ios26-t10-b04-anti-card-md` -> `red` proof status, artifact `build/reports/frontend-object-purity/IOS26-T10-B04-anti-card.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Red`
- `ambitions-linear-sync:proof:build-reports-frontend-object-purity-object-frontend-install-md` -> `yellow` proof status, artifact `build/reports/frontend-object-purity/object-frontend-install.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-frontend-object-purity-validator-install-md` -> `yellow` proof status, artifact `build/reports/frontend-object-purity/validator-install.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-goal-intent-compiler-capacity-aware-compilation-md` -> `unknown` proof status, artifact `build/reports/goal-intent-compiler/capacity-aware-compilation.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `no explicit Green/Yellow/Red status marker found`
- `ambitions-linear-sync:proof:build-reports-goal-intent-compiler-input-output-model-md` -> `unknown` proof status, artifact `build/reports/goal-intent-compiler/input-output-model.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `no explicit Green/Yellow/Red status marker found`
- `ambitions-linear-sync:proof:build-reports-goal-intent-compiler-persistence-receipts-md` -> `unknown` proof status, artifact `build/reports/goal-intent-compiler/persistence-receipts.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `no explicit Green/Yellow/Red status marker found`
- `ambitions-linear-sync:proof:build-reports-ios26-baseline-readme-md` -> `unknown` proof status, artifact `build/reports/ios26-baseline/README.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `no explicit Green/Yellow/Red status marker found`
- `ambitions-linear-sync:proof:build-reports-ios26-baseline-log-index-md` -> `unknown` proof status, artifact `build/reports/ios26-baseline/log-index.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `no explicit Green/Yellow/Red status marker found`
- `ambitions-linear-sync:proof:build-reports-ios26-migration-availability-cleanup-md` -> `unknown` proof status, artifact `build/reports/ios26-migration/availability-cleanup.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `no explicit Green/Yellow/Red status marker found`
- `ambitions-linear-sync:proof:build-reports-ios26-migration-deployment-target-bump-md` -> `yellow` proof status, artifact `build/reports/ios26-migration/deployment-target-bump.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Not verified`
- `ambitions-linear-sync:proof:build-reports-ios26-migration-toolchain-md` -> `yellow` proof status, artifact `build/reports/ios26-migration/toolchain.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-ios26-shell-safe-area-root-invariant-md` -> `yellow` proof status, artifact `build/reports/ios26-shell/safe-area-root-invariant.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: Yellow`
- `ambitions-linear-sync:proof:build-reports-ios26-shell-screenshot-foundation-md` -> `yellow` proof status, artifact `build/reports/ios26-shell/screenshot-foundation.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: YELLOW`
- `ambitions-linear-sync:proof:build-reports-life-command-search-ios26-t04j-b01-md` -> `yellow` proof status, artifact `build/reports/life-command-search/IOS26-T04J-B01.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: YELLOW`
- `ambitions-linear-sync:proof:build-reports-life-command-search-ios26-t04j-b02-md` -> `yellow` proof status, artifact `build/reports/life-command-search/IOS26-T04J-B02.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: YELLOW`
- `ambitions-linear-sync:proof:build-reports-life-command-search-ios26-t04j-b04-md` -> `yellow` proof status, artifact `build/reports/life-command-search/IOS26-T04J-B04.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: YELLOW`
- `ambitions-linear-sync:proof:build-reports-life-command-search-ios26-t04j-b05-md` -> `yellow` proof status, artifact `build/reports/life-command-search/IOS26-T04J-B05.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: YELLOW`
- `ambitions-linear-sync:proof:build-reports-life-command-search-ios26-t04j-b06-md` -> `yellow` proof status, artifact `build/reports/life-command-search/IOS26-T04J-B06.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: YELLOW`
- `ambitions-linear-sync:proof:build-reports-life-command-search-command-search-obviousness-gauntlet-md` -> `yellow` proof status, artifact `build/reports/life-command-search/command-search-obviousness-gauntlet.md`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, evidence `Status: YELLOW`
- ... 517 more

## Historical Paths
- `docs/AmbitionsCanon/00_Canon_Index_10_10_Maturity_Gate.md`
- `docs/AmbitionsCanon/01A_Product_Canon_Flagship_Amendment.md`
- `docs/AmbitionsCanon/01_Product_Canon.md`
- `docs/AmbitionsCanon/02_Continuity_Layer_Chrome.md`
- `docs/AmbitionsCanon/03_Signature_Object_Specs.md`
- `docs/AmbitionsCanon/04_Trust_Privacy_Automation.md`
- `docs/AmbitionsCanon/05_Accessibility_Motion_Performance.md`
- `docs/AmbitionsCanon/06_QA_Preview_Visual_Drift.md`
- `docs/AmbitionsCanon/07_Native_Shell_Tokens_Materials.md`
- `docs/AmbitionsCanon/08_Implementation_Codex_Repo_Integration.md`
- `docs/AmbitionsCanon/09_Flagship_Interface_Preservation_Ledger.md`
- `docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md`
- `docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md`
- `docs/AmbitionsCanon/12_Screen_Composition_Constitution.md`
- `docs/AmbitionsCanon/13_Flagship_Experience_Laws.md`
- `docs/AmbitionsCanon/14_Flagship_QA_And_Award_Caliber_Bar.md`
- `docs/AmbitionsCanon/15_AFI_Implementation_Lane.md`
- `docs/AmbitionsCanon/16_Surface_Identity_And_Signature_Moments.md`
- `docs/AmbitionsCanon/17_Ambitions_Product_Grammar.md`
- `docs/AmbitionsCanon/18_Trust_Receipts_And_Closure_Language.md`
- ... 1108 more

## Ignored Paths
- `.env.example`
- `.swiftpm/xcode/xcuserdata/devan.xcuserdatad/xcschemes/xcschememanagement.plist`

## Unknown Paths
- `.agents/AGENTS.md`
- `.agents/skills/ambitions-accessibility-proof/SKILL.md`
- `.agents/skills/ambitions-batch-runner-operator/SKILL.md`
- `.agents/skills/ambitions-external-surfaces/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-ios-validation-xcode-wrapper/SKILL.md`
- `.agents/skills/ambitions-no-cost-gate/SKILL.md`
- `.agents/skills/ambitions-privacy-local-first/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `.agents/skills/ambitions-repo-hygiene-rollback/SKILL.md`
- `.agents/skills/ambitions-runtime-persistence/SKILL.md`
- `.agents/skills/ambitions-source-truth-auditor/SKILL.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-subagent-review-template/SKILL.md`
- `.agents/skills/ambitions-visual-product-quality/SKILL.md`
- `.codex/AGENTS.md`
- `.codex/BATCH_TRAIN_REGISTRY.md`
- `.codex/CODEX_SCORECARD.md`
- `.codex/DEPARTMENT_REGISTRY.md`
- `.codex/GLOBAL_BATCH_TRAIN.md`
- ... 2972 more

## TODO/FIXME Markers
- TODO: 5

### Marker Samples
- `docs/codex/LINEAR_CONTROL_PLANE.md:116` | Todo | Work is requested but not proven or executed. |
- `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.json:5967` "excerpt": "residue, stale user-facing Plan/Profile copy, unowned TODO-style comments,",
- `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.json:5977` "excerpt": "residue, stale user-facing Plan/Profile copy, unowned TODO-style comments,",
- `docs/audits/me01-maintainability-baseline-and-ownership-map-report.md:159` - `rg -n "TODO|compat|route|accessibilityIdentifier|Start here|What Ambitions Knows|failed|Profile|You" ... || true`
- `docs/audits/me10-architecture-scan-gate-report.md:128` - `rg -n "TODO|compat|route|accessibilityIdentifier|Start here|What Ambitions Knows|failed|Profile|You" ... || true`

## Stale/Deprecated Canon Terms
- `AI recommendation framing`: 40
- `deprecated urgency term`: 475
- `failure-state language`: 2674
- `legacy IA with Plan`: 235
- `legacy Plan tab`: 92
- `legacy Profile tab`: 111
- `legacy move language`: 193
- `legacy next-move language`: 167
- `score-pressure language`: 5803
- `streak-pressure language`: 1657

### Stale Term Samples
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md:19` `failure-state language` - 2. Separate verified, failure-state language, not verified, blocked, and human/device follow-up.
- `.agents/skills/ambitions-visual-product-quality/SKILL.md:20` `legacy next-move language` - 3. Reject `legacy next-move language`, `legacy move language`, `legacy focus CTA`, legacy Plan placement, shame/streak-pressure language pressure, and fake urgency.
- `.agents/skills/ambitions-visual-product-quality/SKILL.md:20` `streak-pressure language` - 3. Reject `legacy next-move language`, `legacy move language`, `legacy focus CTA`, legacy Plan placement, shame/streak-pressure language pressure, and fake urgency.
- `.codex/CODEX_SCORECARD.md:3` `score-pressure language` - # Codex score-pressure languagecard
- `.codex/CODEX_SCORECARD.md:5` `score-pressure language` - Status: Active Codex execution-quality score-pressure languagecard
- `.codex/CODEX_SCORECARD.md:9` `score-pressure language` - This score-pressure languagecard measures Codex execution quality. It is not app quality proof,
- `.codex/CODEX_SCORECARD.md:14` `score-pressure language` - score-pressure language only the work being closed out. Do not score-pressure language uninspected repo areas.
- `.codex/CODEX_SCORECARD.md:15` `score-pressure language` - score-pressure languages require evidence; otherwise mark `not score-pressure languaged`.
- `.codex/CODEX_SCORECARD.md:40` `score-pressure language` - - Not score-pressure languaged: excluded
- `.codex/CODEX_SCORECARD.md:42` `score-pressure language` - Do not convert score-pressure language into user-facing product quality, release readiness, or
- `.codex/CODEX_SCORECARD.md:48` `score-pressure language` - Codex score-pressure languagecard:
- `.codex/CODEX_SCORECARD.md:61` `score-pressure language` - Not score-pressure languaged:
- `.codex/CODEX_SCORECARD.md:71` `score-pressure language` - - an owner explicitly asks for a score-pressure languagecard baseline update
- `.codex/CODEX_SCORECARD.md:73` `score-pressure language` - Per-run score-pressure languages belong in closeout reports, not in this definition file, unless
- `.codex/CODEX_SCORECARD.md:78` `score-pressure language` - This setup pass creates the score-pressure languagecard. It does not score-pressure language all historical Codex
- `.codex/CODEX_SCORECARD.md:87` `score-pressure language` - - docs-only score-pressure languagecard artifact
- `.codex/OPERATING_SYSTEM.md:80` `failure-state language` - | Release proof | `RELEASE_TRUTH.md`, release evidence packet, raw logs | Evidence capture and claim firewall only | Verified/failure-state language/not verified/human follow-up |
- `.codex/OPERATING_SYSTEM.md:146` `failure-state language` - 5. Re-run the failure-state language validation or explain why it was not rerun.
- `.codex/OPERATING_SYSTEM.md:147` `failure-state language` - 6. Close with verified, failure-state language, not verified, and non-claims.
- `.codex/PR_PROTOCOL.md:51` `failure-state language` - - failure-state language
- `.codex/evals/README.md:22` `failure-state language` - - Retries should get narrower instead of repeating the same failure-state language step.
- `.codex/hooks/post_tool_use_review.py:54` `failure-state language` - if any(token in text for token in ("error", "failure-state language", "denied", "permission")):
- `.codex/hooks/user_prompt_submit_guard.py:68` `score-pressure language` - score-pressure language = sum(1 for p in RISK_PHRASES if p in text)
- `.codex/hooks/user_prompt_submit_guard.py:70` `score-pressure language` - return score-pressure language >= 3 or has_forbidden
- `.codex/improvement/skill-refinement-template.md:6` `failure-state language` - - Request shape that failure-state language:
- `.codex/manifests/repair-profiles.yml:33` `legacy next-move language` - - "legacy next-move language"
- `.codex/manifests/repair-profiles.yml:34` `legacy move language` - - "Your legacy move language"
- `.codex/manifests/repair-profiles.yml:80` `failure-state language` - - "BUILD failure-state language"
- `.codex/manifests/repair-profiles.yml:92` `failure-state language` - - "TEST failure-state language"
- `.codex/manifests/repair-profiles.yml:93` `failure-state language` - - "failure-state language test"
- `.codex/manifests/visual-proof-map.yml:69` `score-pressure language` - - visual_score-pressure language
- `.codex/operations/batch-train-commit-policy.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-green-gate-protocol.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-human-escalation.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-orchestration-protocol.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-red-stop-protocol.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-repair-prompt-protocol.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-resume-protocol.md:7` `failure-state language` - Use after compaction, failure-state language validation, or user-approved resume.
- `.codex/operations/batch-train-resume-protocol.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-rollback-protocol.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved

## Non-Claims
- This dry run does not write to Linear.
- This dry run does not prove implementation completeness.
- This dry run does not prove build, test, accessibility, performance, device, TestFlight, App Store, privacy, legal, or release readiness.
- Historical paths remain historical unless repo truth explicitly promotes them.
