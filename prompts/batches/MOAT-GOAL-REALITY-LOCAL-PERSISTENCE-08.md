<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-1300009, AMB28-same_source_file_targeted_by_multiple_active_batches-14217122, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-24962709, AMB28-same_source_file_targeted_by_multiple_active_batches-41370782, AMB28-same_source_file_targeted_by_multiple_active_batches-43735803, AMB28-same_source_file_targeted_by_multiple_active_batches-44395706, AMB28-same_source_file_targeted_by_multiple_active_batches-49529893, AMB28-same_source_file_targeted_by_multiple_active_batches-62616890, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-69806409 and 4 more

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08 — Local Review Candidate / Receipt Persistence

## Batch ID

`MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08 prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md
```

## Objective

Persist Goal Reality review candidates and receipts locally only after the review, rollback, migration, and privacy boundaries are proven. This batch turns value-model outputs into durable local review objects without automatically activating goals, plans, schedules, or commitments.

## Source Truth To Inspect

```text
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md
Native/Ambitions/Persistence/SwiftDataModels.swift
Native/Ambitions/Persistence/SwiftDataRepositories.swift
Native/Ambitions/Persistence/PersistenceContracts.swift
Native/Ambitions/Persistence/SwiftDataStore.swift
Native/Ambitions/Domain/GoalRealityModels.swift
Native/Ambitions/Domain/GoalRealityReceiptModels.swift
Native/Ambitions/Runtime/GoalRealityReceiptClosureService.swift
Native/AmbitionsTests/Persistence/
```

## Allowed Scope

```text
Native/Ambitions/Persistence/SwiftDataModels.swift
Native/Ambitions/Persistence/PersistenceContracts.swift
Native/Ambitions/Persistence/SwiftDataRepositories.swift
Native/Ambitions/Persistence/SwiftDataStore.swift
Native/Ambitions/Domain/GoalRealityPersistenceModels.swift
Native/Ambitions/Runtime/GoalRealityPersistenceService.swift
Native/AmbitionsTests/Persistence/GoalRealityPersistenceTests.swift
Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift
Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift
docs/audits/moat-goal-reality-local-persistence-08-report.md
docs/truth/IMPLEMENTATION_TRUTH.md
```

## Required Persistence Decision Gate

Before changing schema, inspect whether existing records can safely store review candidates and receipts. Prefer existing structures if they preserve:

```text
local-only storage
privacy classification
review state
receipt state
correction controls
no automatic activation
rollback/export safety
```

If new schema is required, provide:

```text
migration proof
pre-migration backup compatibility
rollback proof
in-memory store tests
persistent store tests if available
no data-loss claim without proof
```

If schema cannot be safely added, stop at repository/service design and report Yellow. Do not force persistence.

## Required Behavior

Persist only reviewable objects:

```text
GoalRealityCandidateRecord
GoalRealityReceiptRecord
GoalRealityCorrectionRecord if safe
```

Must not persist as active:

```text
Goal
GoalPlan
Today scheduled step
Commitment mutation
Calendar block
```

Records must preserve:

```text
raw intent reference
North Star
Active Path
Truth State
Risk Lane
Operating Level
Proof Gate summary
Receipt
Review State
Privacy Class
Local-only flag
```

## Required Tests

Prove:

```text
review candidate can be saved and loaded locally
receipt can be saved and loaded locally
candidate remains inactive until explicit future review flow
sensitive/private candidates do not project externally by default
reset/delete path removes review candidate if supported
migration/rollback proof exists if schema changed
no network, hosted AI, or user-data server
```

## Forbidden Scope

No cloud sync. No hosted backend. No automatic goal/plan activation. No external projection. No release claim. No unsafe schema change without rollback.

## Validation

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityPersistenceTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/PreMigrationBackupTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/PortableRestoreRollbackTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

## Hard Red Stop Conditions

Stop if persistence requires cloud/user-data server, unbounded schema risk, automatic activation, external projection of private data, or migration without rollback proof.

## Claim Boundary

Allowed: local persistence for review candidates/receipts is source-present and tested. Forbidden: full cross-surface persisted product flow complete unless later bridges prove it.

## Rollback

If schema changed, include explicit rollback/migration notes. If no schema changed, normal revert.

## Next Batch

`MOAT-GOAL-REALITY-SOURCE-PACKS-09`

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
