# AFEP-004 Privacy Matrix

Branch: `main`
Current SHA: `cea2a5f90026bb4b99e4c8b55886b740f371c8fc`
Run directory: `.codex/runs/AFEP-004/20260601T044152Z`
Reported at: `2026-06-01T05:11:23Z`

## Policy Matrix

| Owner / field set | Privacy class | Indexing policy | Export policy | Evidence state |
| --- | --- | --- | --- | --- |
| Runtime snapshot `sourceRecordIDs` | `local_only` | `not_indexed` | `redacted` | `planned` |
| Runtime snapshot `receiptIDs` | `proof_restricted` | `not_indexed` | `redacted` | `planned` |
| Runtime snapshot `replayTraceIDs` | `replay_restricted` | `not_indexed` | `redacted` | `planned` |
| Runtime snapshot `afep02LineageReferenceIDs` | `lineage_restricted` | `not_indexed` | `redacted` | `planned` |
| Operational / proof / projection `sourceObjectIDs`, `sourceFields` | `private_sensitive` | `not_indexed` | `redacted` | `planned` |
| Operational / proof / projection `receiptIDs`, `replayTraceIDs` | `proof_restricted` / `replay_restricted` | `not_indexed` | `redacted` | `planned` |
| Operational / proof / projection `checksum`, `projectionHash`, `invalidationReason` | `system_owned` | `not_indexed` | `safe` | `planned` |
| Portable export goals / captures / proof / receipts / memory | `private_sensitive` / `proof_restricted` / `local_only` | `not_indexed` | `export_review_only` | `planned` |
| Portable export settings | `system_owned` | `indexed` | `safe` | `planned` |

## Validation

| Command | Result | Notes |
| --- | --- | --- |
| `make xcode-build-for-testing BATCH=AFEP-004` | Pass | Passed after compile repair. |
| `make xcode-focused-test BATCH=AFEP-004 TEST=AmbitionsTests/Domain/AFEP004QueryBudgetPrivacyPolicyTests` | Pass | Verified runtime and split-record policy contracts, including Phase 03 repair coverage for unsafe clear redaction overrides. |
| `make xcode-focused-test BATCH=AFEP-004 TEST=AmbitionsTests/Persistence/AFEP004ExportPolicyTests` | Pass | Verified portable export policy defaults and visibility. |

Phase 03 repair note: runtime snapshot export projections now require actual redaction before `redacted` policy fields can be considered export-safe. A clear redaction request for a redacted AFEP field is forced back to a redacted projection.

## Yellow Items

* No device or Instruments evidence was collected.
* No release, accessibility, privacy/legal, TestFlight, or App Store claim is made.
* `docs/codex/concept-lock-registry.yml` carries the AFEP-004 locked-concept allowance needed for the guard-reviewed batch slice.
* Broader `AmbitionsTests`, UI, device, CI, and privacy/legal validation were not run.

## Rollback Notes

Restore the AFEP source/report scope with:

```bash
git restore -- Native/Ambitions/Domain/AmbitionGraphStoreSplitModels.swift Native/Ambitions/Domain/RuntimeSnapshotLedgerModels.swift Native/Ambitions/Persistence/PersistenceContracts.swift Native/Ambitions/Persistence/PortableSnapshotContracts.swift Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift Native/Ambitions/Persistence/SwiftDataRepositories.swift Native/AmbitionsTests/Domain/AFEP004QueryBudgetPrivacyPolicyTests.swift Native/AmbitionsTests/Persistence/AFEP004ExportPolicyTests.swift docs/codex/concept-lock-registry.yml docs/codex/existing-code-champion-coverage.yml prompts/batches/AFEP-004.md build/reports/intelligence-consolidation/champion-coverage-check.json build/reports/intelligence-consolidation/champion-coverage-check.md build/reports/afep/AFEP-004
```

## Non-claims

* No claim that the policies are device-measured.
* No claim that export flows are fully validated on hardware.
* No claim that private data is globally non-indexed outside the touched AFEP owners.
