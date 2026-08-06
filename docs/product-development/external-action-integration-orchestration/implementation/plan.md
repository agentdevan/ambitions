# Implementation Plan

## Outcome and boundary

Implement adapter registry, draft/preview/one-action confirmation, credential/
outbox/result/reconciliation state machine and Calendar system-editor handoff.
Enable no remote provider/high-consequence action; add no generic HTTP connector,
webhook service, model write tool or local-owner mutation.

## Exact expected files

- Add `docs/canon/specifications/systems/external-action-orchestration.md`; update
  external effects, permissions, privacy/security, degraded, History/Receipts,
  Time/Calendar, Life Branch, account/continuity and evaluation/change canon.
- Add adapter/action schemas/config/calendar fixtures/fake-provider fault server
  under `tools/external-actions/` as `models.py`, `registry_validator.py`,
  `threat_runner.py`, `fault_runner.py`, `fake_provider_server.py`, `cli.py`,
  `contracts/external-adapter-v1.schema.json`,
  `contracts/external-action-draft-v1.schema.json`,
  `contracts/external-action-result-v1.schema.json`,
  `config/adapter-registry-v1.json`, `config/action-policies-v1.json`,
  `fixtures/calendar-system-editor.json`, `fixtures/oauth-threat-cases.json`,
  `fixtures/outbox-fault-cases.json`, `tests/test_registry_validator.py`,
  `tests/test_oauth_threats.py`, and `tests/test_outbox_faults.py`. The remote
  registry config must contain zero enabled providers.
- Add under `Native/Ambitions/Core/LocalRuntimeOS/ExternalActions/`:
  `ExternalActionAdmissionModels.swift`, `ExternalActionAdapterRegistry.swift`,
  `ExternalActionArtifactLoader.swift`, `ExternalActionRegistryValidator.swift`,
  `ExternalActionDraftModels.swift`, `ExternalActionPreviewService.swift`,
  `ExternalActionAuthorizationModels.swift`,
  `ExternalActionAuthorizationStore.swift`, `ExternalConnectionModels.swift`,
  `ExternalCredentialVault.swift`, `ExternalActionAdapter.swift`,
  `ExternalActionOutboxModels.swift`, `ExternalActionOutboxStore.swift`,
  `ExternalActionOutboxActor.swift`, `ExternalActionJournal.swift`,
  `ExternalActionScheduler.swift`, `ExternalActionResultModels.swift`,
  `ExternalActionReconciliationService.swift`, `ExternalActionReceiptModels.swift`,
  `ExternalResultInputBuilder.swift`, `ExternalConnectionLifecycleService.swift`,
  `ExternalActionPurgeService.swift`, and `ExternalActionDiagnostics.swift`.
- Add `CalendarSystemEditorAdapter.swift` and
  `CalendarSystemEditorHandoff.swift` under `ExternalActions/Calendar/`; add
  `OAuthSessionModels.swift`, `OAuthPKCE.swift`, `OAuthCallbackValidator.swift`,
  and `FakeOAuthProviderAdapter.swift` under `ExternalActions/OAuth/`, with the
  fake adapter compiled for tests only.
- Update runtime bootstrap/boundary clients, permission descriptions through
  `project.yml` and regenerate; do not hand-edit Xcode.
- Add Action Center/preview/progress/settings surfaces under
  `Native/Ambitions/Surfaces/You/ExternalActions/` as
  `ExternalActionCenterView.swift`, `ExternalActionProgressView.swift`,
  `ExternalConnectionSettingsView.swift`, and `ExternalActionPreviewFixtures.swift`;
  add `ExternalActionPreviewSheet.swift` under
  `Native/Ambitions/Surfaces/Shared/ExternalActions/`.
- Add unit tests under `Native/AmbitionsTests/LocalRuntimeOS/ExternalActions/`,
  specifically `ExternalAdapterRegistryTests.swift`,
  `ExternalActionDraftPreviewTests.swift`, `ExternalActionAuthorizationTests.swift`,
  `OAuthNativeSecurityTests.swift`, `ExternalActionOutboxTests.swift`,
  `ExternalActionReconciliationTests.swift`, `CalendarEditorHandoffTests.swift`,
  `ExternalDisconnectPurgeTests.swift`, and
  `ExternalActionPrivacySecurityTests.swift`; add
  `Native/AmbitionsTests/Quality/ExternalActionAccessibilityTests.swift` and
  `Native/AmbitionsUITests/ExternalActionUITests.swift`.

Sequence: canon/contracts; intent/draft/preview; single-action auth; credential/
OAuth fake harness; adapter protocol; outbox/idempotency; result/reconcile;
Calendar editor; disconnect/purge; UI/accessibility; integration; full proof.

## Grooming review and approval

Review verdict: **PASS** after one reconciliation round. Exact zero-remote
registry, fake OAuth harness, EventKit/config path, outbox/recovery and tests are
named. Devan delegated approval; grooming approved 2026-08-04.
