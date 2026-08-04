# Implementation Plan

## Outcome and boundary

Implement the registered-task, on-device-first Private Generative Runtime with
deterministic/manual fallback, context minimization, read-only tools, structured
validation, no-payload receipts, deletion and evaluation/change bindings. PCC
must remain unavailable unless entitlement and evidence pass. Add no third-party
provider, write tool, autonomous action, hidden profile or source implementation.

## Exact expected files

### Canon and task Foundry

- Add `docs/canon/specifications/systems/private-generative-runtime.md`.
- Update privacy/data classification, permissions, degraded states, trust
  inspection, local learning, Source Atlas and Receipts/History specifications.
- Add `tools/generative-runtime/` containing `models.py`, `task_registry.py`,
  `task_bundle_builder.py`, `task_bundle_validator.py`, `prompt_linter.py`,
  `schema_validator.py`, `golden_runner.py`, `release_diff.py`, `cli.py`,
  `contracts/generation-task-v1.schema.json`,
  `contracts/generation-task-bundle-v1.schema.json`,
  `contracts/generation-task-output-v1.schema.json`,
  `config/generation-capabilities-v1.json`,
  `config/generation-mode-policy-v1.json`,
  `config/generation-prohibited-claims-v1.json`,
  `fixtures/generation-task-valid-v1.json`,
  `fixtures/generation-task-invalid-command-v1.json`, and the exact test files
  named below.
- Add signed generated
  `Native/Ambitions/Resources/PrivateGenerativeRuntime/generation-task-registry-v1.json`
  plus reviewed compiled artifact. Update `project.yml` and regenerate the Xcode
  project because the new resource directory is excluded.

### Native runtime

Add under `Native/Ambitions/Core/LocalRuntimeOS/GenerativeRuntime/`:

- `GenerationTaskModels.swift`, `GenerationTaskRegistry.swift`, artifact loader,
  semantic validator and store, specifically
  `GenerationTaskArtifactLoader.swift`, `GenerationTaskSemanticValidator.swift`,
  and `GenerationTaskStore.swift`;
- `GenerationCapabilityModels.swift`, `GenerationCapabilityRegistry.swift`,
  `GenerationModePolicy.swift`;
- `GenerationContextModels.swift`, `GenerationContextAssembler.swift`,
  `GenerationContextFieldSourceClients.swift`, and
  `GenerationContextMinimizationValidator.swift`;
- `GenerationTransferConsentModels.swift`, `GenerationTransferConsentPolicy.swift`,
  `GenerationTransferConsentStore.swift`, and
  `GenerationTransferConsentPreview.swift`;
- `GenerationReadToolModels.swift`, `GenerationReadToolRegistry.swift`,
  `GenerationReadToolGateway.swift`, `GenerationReadToolBudget.swift`, and
  `GenerationReadToolReceiptModels.swift`;
- `UntrustedGenerationEnvelope.swift`, `ValidatedGenerationCandidate.swift`;
- `GenerationSchemaValidator.swift`, `GenerationIdentifierValidator.swift`,
  `GenerationSourceValidator.swift`, `GenerationInvariantValidator.swift`,
  `GenerationProhibitedClaimValidator.swift`, `GenerationPrivacyValidator.swift`,
  `GenerationSecurityValidator.swift`, and `GenerationValidationPipeline.swift`;
- `GenerationRepairCoordinator.swift`, `GenerationSessionActor.swift`,
  `PrivateGenerationCoordinator.swift`, `GenerationCancellationService.swift`,
  and `GenerationRecoveryService.swift`;
- `OnDeviceFoundationModelAdapter.swift`, `PrivateCloudComputeModelAdapter.swift`
  behind compile/runtime gates, `HostedModelProviderProtocol.swift` and disabled
  registry with zero configured providers;
- `GenerationReceiptStore.swift`, `GenerationDependencyInvalidator.swift`,
  `GenerationClearService.swift`, `GenerationPurgeService.swift`, and
  `PrivateGenerationClient.swift`.

Update runtime bootstrap and boundary client composition only. Feature owners
integrate in later initiatives; do not inject command/external-operation clients.

### UI and tests

Add `GenerationContextPreviewView.swift`, `GenerationModeDisclosureView.swift`,
`GenerationProgressView.swift`, `GenerationFailureView.swift`,
`GenerationReceiptView.swift`, and `GenerationClearView.swift` under
`Native/Ambitions/Trust/PrivateGenerativeRuntime/`. Add
`test_generation_task_registry.py`, `test_generation_task_schema.py`,
`test_generation_prompt_linter.py`, and `test_generation_repeat_build.py` under
`tools/generative-runtime/tests/`. Add under
`Native/AmbitionsTests/LocalRuntimeOS/GenerativeRuntime/`:
`GenerationTaskRegistryTests.swift`, `GenerationModeRoutingTests.swift`,
`GenerationContextTests.swift`, `GenerationTransferConsentTests.swift`,
`GenerationReadToolTests.swift`, `GenerationModelAdapterTests.swift`,
`GenerationValidationPipelineTests.swift`, `GenerationRepairTests.swift`,
`GenerationSessionConcurrencyTests.swift`, `GenerationPrivacySecurityTests.swift`,
`GenerationInvalidationTests.swift`, and `GenerationPurgeTests.swift`. Add
`Native/AmbitionsTests/Quality/PrivateGenerationAccessibilityTests.swift` and
`Native/AmbitionsUITests/PrivateGenerationUITests.swift` for preview, progress,
failure, correction and clear.

## Sequencing and lifecycle

Implement contracts/registry first; native registry/routing second; context and
consent third; tools fourth; envelope/validators fifth; fake/on-device adapters
sixth; sessions/repair seventh; receipts/change/deletion eighth; UI ninth;
resources/project tenth; full proof last. Use deterministic fake models for
repeatable tests and eligible physical devices for platform proof.

Raw session data is memory-only and cancellation-scoped. One actor owns each
session; a separate deletion actor journals scoped purge. Registry compatibility
tuples bind task/model/runtime/prompt/schema/policy/tools. No migration reclassifies
existing content as model output.

## Grooming review and approval

Review verdict: **PASS** after one reconciliation round. Exact project/resource,
runtime, boundary, UI and test seams are named; PCC and hosted modes remain
explicitly unavailable; physical-device and model-version evidence is required.
Devan delegated approval; grooming approved 2026-08-04. No implementation,
runtime, provider, deployment or release evidence is claimed.
