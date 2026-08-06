# Implementation Plan

## Outcome and boundary

Implement the approved, default-off Scoped Automation Authority for exactly two
foreground Capture operations: `.archiveItem` and `.markWaiting`. A user may
activate one seven-day-or-shorter grant for one-to-five exact current Capture
revisions, with one successful use per target and one global five-success rolling
24-hour budget. Every use remains below current Safe Automation and owner-policy
ceilings and commits through the existing local mutation authority.

This work does not create background, model, tool, extension, App Intent,
notification, or external authority. It does not infer or renew permission,
repair unrelated Safe Automation drift, or enable release behavior before every
proof gate passes. Ordinary user confirmation remains the fallback.

## Affected components and exact files

- Add `docs/canon/specifications/systems/scoped-automation-authority.md`; update
  `docs/canon/MANIFEST.toml`, `docs/canon/specifications/systems/private-life-runtime.md`,
  `docs/canon/specifications/global/capture.md`,
  `docs/canon/specifications/global/trust-inspection.md`,
  `docs/canon/specifications/surfaces/you.md`,
  `docs/canon/specifications/systems/persistence-and-replay.md`, and
  `docs/canon/specifications/systems/privacy-and-data-classification.md`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/AutomationAuthority/ScopedAutomationGrantModels.swift`,
  `ScopedAutomationUseModels.swift`, `ScopedAutomationAuthorityPolicy.swift`,
  `ScopedAutomationAuthorityRepository.swift`,
  `ScopedAutomationAuthorityCoordinator.swift`, and
  `ScopedAutomationAuthorityProjection.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Storage/ScopedAutomationStoreSchema.swift`
  and `Native/Ambitions/Core/LocalRuntimeOS/Repair/ScopedAutomationSchemaMigration.swift`;
  extend `CanonicalRuntimeStore.swift`, `RuntimeGenerationDatabaseAuthority.swift`,
  `StoreInvariantChecker.swift`, runtime Event/Receipt/replay registries, and the
  next canonical storage generation.
- Extend `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommand.swift`,
  `RuntimeCommandCodec.swift`, `RuntimeMutationPreparation.swift`,
  `RuntimeMutationPreparationService.swift`, `RuntimeTransactionCommitPolicy.swift`,
  `RuntimeCommandMutationCommitter.swift`, and `MeaningfulMutationRegistry.swift`.
- Extend `Native/Ambitions/Core/Domain/SafeAutomationProposedAction.swift` and
  `SafeAutomationPolicyModels.swift` only for the exact authority validation seam;
  do not broaden the action allowlist or absorb unrelated `.createReminder` drift.
- Add `Native/Ambitions/Composer/Capture/ScopedAutomationReviewSurface.swift` and
  `ScopedAutomationRunSurface.swift`; extend `CaptureComposerSurface.swift`,
  `CaptureViewModel.swift`, `YouFeatureServicePolicyCenterProjection.swift`,
  `YouRootDetailRouteSurface.swift`, and `YouAccessibility.swift`.
- Add focused domain, storage, command, replay, privacy, accessibility, and UI
  tests under the exact test paths named in `tasks.md`.

## Interfaces and data flow

`ScopedAutomationAuthorityClient` exposes draft preview, activate, inspect,
run-next, pause, reviewed-resume, and revoke operations. UI supplies only stable
Capture IDs and current revisions. The domain policy creates a typed immutable
grant revision; no view or projection writes the store.

A run derives a deterministic use ID from grant revision plus target binding and
submits the existing typed Capture command with a
`ScopedAutomationAuthorityClaim`. Runtime preparation reads the grant, target,
Safe Automation decision, owner rules, privacy/protection, policy fingerprints,
foreground source/actor, and singleton materiality aggregate. Authorization
accepts only an exact current read set. One authority transaction commits the
grant-use event, materiality event, Capture event, projections, Receipt/History,
and replay identity. Failure commits none of those requested effects; projection
repair replays accepted authority without retrying the mutation.

## Persistence, migration, and concurrency

The additive local schema stores grant revisions, target bindings, minimized use
results, the rolling materiality aggregate, operation/idempotency identities,
and projection checkpoints under the canonical runtime generation. Waiting
values remain protected private data; diagnostics contain only versioned action,
state, reason, and coarse count fields.

Migration creates an empty store and never derives authority from prior commands,
confirmations, automation levels, context grants, behavior, or platform state.
Unknown/corrupt/future records hold or quarantine without changing a Capture.
Grant revision, target revision, and global materiality revision are compare-and-
set inputs to one commit. Pause/Revoke and a use therefore have one durable
ordering; terminal grant revisions cannot revive through replay, restore,
compaction, import, or downgrade.

## Rollout, canon, and implementation order

Land canon and typed models first, then storage/migration, policy/codec,
transaction integration, coordinator/projections, and native UI. Regenerate the
Xcode project from `project.yml`. The feature remains compile-time/runtime
default-off until the focused mutation lineage, privacy, accessibility,
simulator, physical-device, and direct-user gates in `verification.md` are all
bound to the same source revision. A failed gate preserves ordinary confirmation
and may remove the experiment; it never widens authority.
