# Implementation Plan

## Outcome and boundary

Import a user-selected tabular profile archive through a preview-first,
row-by-row process. Imported rows become user-provided claim proposals with
source/checksum lineage and must be explicitly accepted, edited, related,
skipped, or rejected. They do not become verified credentials, capabilities,
Goals, employer truth, public references, or permission to contact or sync with
the provider. Raw staged bytes are protected and deleted on completion/cancel.

## Affected components and exact files

- Update `docs/canon/specifications/systems/import-export-repair.md`,
  `objects/import-diff-record.md`, `objects/source-reference.md`, and
  `surfaces/you.md`.
- Add `Native/Ambitions/Core/Domain/ProfileImport/ProfileArchiveImportModels.swift`
  and `ImportedProfileClaimModels.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Attachments/ProfileArchiveStagingService.swift`
  and
  `Native/Ambitions/Core/LocalRuntimeOS/Repair/ProfileTableImport/ProfileArchiveTableParser.swift`.
- Add `Commands/ProfileClaimImportCommandService.swift`,
  `State/ProfileArchiveImportStore.swift`,
  `Inspection/ProfileClaimInspectionProjection.swift`, and
  `Repair/ProfileArchiveImportMigration.swift`.
- Add `Native/Ambitions/Surfaces/You/ProfileArchiveImportView.swift` and
  `ProfileClaimReviewView.swift`.

## Data flow, persistence, and migration

The document picker hands a security-scoped local file to the staging service.
The parser validates size/type/encoding/schema, normalizes rows deterministically,
and stores only an encrypted temporary blob plus checksum and row projections.
Each accepted row sends a revisioned, idempotent command to the imported-claim
owner; optional Capability relationships are separate confirmed operations.
Events/Receipts/History record source kind and checksum, never provider login or
hidden enrichment. Migration creates empty session/claim collections. Replay
rebuilds accepted claims and decisions without rereading raw archives; cleanup
deletes staged bytes across success, cancel, expiry, crash recovery, and user
deletion.

## Dependencies, order, and rollout

Capability continuity is required only for optional relationships. Implement
models/parser security, staging/cleanup, preview/session store, row commands,
inspection/UI, then malicious-file/privacy/device proof. Support only the exact
approved tabular archive profile in v1. API login, background sync, scraping,
provider writeback, credential verification, and bulk auto-accept are excluded.
