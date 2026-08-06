# Implementation Plan

## Outcome and boundary

Add an explicit, local capability-summary export for user-selected advisor or
planning purposes. The export is a point-in-time, provenance-bearing rendering,
not a credential, resume truth service, sync channel, automatic external write,
or permission for future reuse. It consumes approved Capability projections and
cannot edit Capability, Proof, Credential, Goal, or Source Reference.

## Affected components and exact files

- Update `docs/canon/specifications/systems/import-export-repair.md`,
  `objects/source-reference.md`, and `surfaces/you.md`.
- Add `Native/Ambitions/Core/Domain/Capability/CapabilityExportModels.swift`,
  `Core/LocalRuntimeOS/PrivacySecurity/CapabilityExportPolicy.swift`,
  `Commands/CapabilityExportCommandService.swift`,
  `State/CapabilityExportRecordStore.swift`, and
  `Inspection/CapabilityExportProjection.swift`.
- Add
  `Native/Ambitions/Core/LocalRuntimeOS/Repair/CapabilityExport/CapabilityAdvisorSummaryRenderer.swift`,
  `Attachments/CapabilityExportArtifactService.swift`, and
  `ExternalOperations/CapabilityExportHandoffService.swift`.
- Add `Native/Ambitions/Surfaces/You/CapabilityExportView.swift` and use the
  platform share/export controller only after local preview confirmation.

## Data flow, persistence, and migration

The user selects exact Capability IDs and facets from a revisioned read-only
projection. Policy redacts prohibited, third-party, protected, revoked, deleted,
or stale content before rendering. Confirmation creates one short-lived export
attempt record. The pure renderer emits normalized UTF-8 `.txt` with LF line
endings, fixed field/Capability ordering, deterministic escaping, and one
terminal newline. A protected ephemeral blob is byte/hash checked before either
a user-selected Files export or native share handoff; Files `created/cancelled/
failed` and share `invoked/returned/ambiguous` remain separate from delivery.
Records contain hashes, selection, policy/revision bindings, lifecycle, and
result—not rendered text. Additive migration creates empty session/record/
artifact-link collections. Actor isolation, expected revisions, expiry,
deletion, cleanup journals, and idempotent retry prevent stale or duplicate
exports; ordinary replay never reopens Files or a share sheet.

## Order and rollout

Capability continuity is a hard dependency. Implement models/policy, record
store/migration, rendering command, inspection/UI, then privacy/device evidence.
No background job, account path, clipboard default, public indexing, or direct
LinkedIn/employer/school adapter is included.
