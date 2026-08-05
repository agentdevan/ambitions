# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-CLOUDKIT-CONTINUITY --test AmbitionsTests/ContinuityManifestGateTests --test AmbitionsTests/ContinuityEligibilityBoundaryTests --test AmbitionsTests/ContinuityStoreTests --test AmbitionsTests/ContinuityStoreMigrationTests --test AmbitionsTests/ContinuityEnvelopeProtectionTests --test AmbitionsTests/ContinuityCausalMergeTests --test AmbitionsTests/ContinuityTombstoneHorizonTests --test AmbitionsTests/CKSyncEngineContinuityDriverTests --test AmbitionsTests/ContinuityOutboxProjectorTests --test AmbitionsTests/ContinuityReconcilerTests --test AmbitionsTests/ContinuityOwnerCommandIngestionTests --test AmbitionsTests/ContinuityReplayIsolationTests --test AmbitionsTests/ContinuityAccountEpochTests --test AmbitionsTests/ContinuityControlCommandTests --test AmbitionsTests/ContinuityRemoteDeletionRecoveryTests --test AmbitionsTests/ContinuityInitialReconciliationTests --test AmbitionsTests/ContinuityRestoreMigrationTests --test AmbitionsTests/ContinuityRollbackTests --test AmbitionsTests/ContinuityControlCenterProjectionTests --test AmbitionsTests/CloudKitContinuityPrivacyBoundaryTests --test AmbitionsTests/CloudKitContinuityPerformanceTests --test AmbitionsTests/CloudKitContinuityReleaseGateTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-CLOUDKIT-CONTINUITY
git diff --check
```

## Required evidence

- Automated: closed field/destination inventory; encrypted record encoding;
  dotted-vector, owner merge, quarantine, and tombstone corpus; account epochs;
  durable outbox/inbox/engine state; every state/action/copy contract; all mapped
  to REQ-001 through REQ-023.
- Build: generated project drift check, signing/entitlement inspection, and
  changed-scope build-for-testing pass. Document approval supplies no build or
  runtime evidence.
- CKSyncEngine integration: development private container/custom zone; persisted
  newest serialization; independent outbox repopulation; configured batch
  ceilings; per-record success/failure; server conflict; throttling/quota/token/
  zone/network errors; account reset clears engine pending while local intent
  survives; no public/shared/database-backend path exists.
- Runtime/UI: simulator covers disabled, preflight/review, all pending/settled/
  conflict/account/migration/restore/delete/recovery states, interruption at
  every journal phase, relaunch, protected-data loss, and no-network local parity.
- Accessibility: each flow on a supported physical iPhone with VoiceOver, Voice
  Control, Switch Control, Full Keyboard Access, Dynamic Type, Bold Text, Button
  Shapes, contrast/non-color, Reduced Motion/Transparency, RTL/localization,
  protected-content speech, announcements, and focus recovery.
- Privacy/security: account A/no-account/B sends zero A or unreviewed-unbound
  payload; private canaries and reconstructive digests are absent from Account,
  R2, Source Atlas, public/shared CloudKit, logs, crashes, AI, analytics,
  telemetry, diagnostics egress, and support; encrypted field/asset, key-reset,
  tamper/replay, destination, schema, and entitlement abuse tests pass.
- Migration/restore: empty and non-empty devices, device replacement, every
  supported reader/writer transition, unknown client, additive dev/prod schema,
  every crash point, rollback/roll-forward, duplicate prevention, encrypted-key
  reset, missing/user-deleted zone, local reupload, and no-readable-copy ceiling.
- Performance/resource: measured small/large/attachment/conflict/quota fixtures
  establish latency, memory, energy, storage/network amplification, batch/retry/
  cancel duration, backpressure, and main-thread thresholds on supported devices.
- Physical multi-device: at least two signed physical iPhones prove same-account
  initial/ongoing continuity, offline divergence, same-field quarantine,
  deletion/no resurrection, relaunch/partial failure, A/no-account/B isolation,
  same-A return, old-client/schema transition, replacement restore,
  pause/turn-off/separate remote delete, and accessibility.
- Release: exact source/build/signing/entitlements/container/environment/schema/
  policy/gate/fixture/device evidence, command launched/executed/pass counts,
  privacy/security approval, known gaps, and tested rollback are immutable inputs.
  Until every cell passes for one candidate, production remains disabled and
  release/App Store continuity claims are N/A.
