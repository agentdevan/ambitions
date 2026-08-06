# Implementation Plan

## Outcome and boundary

Implement the bounded relocation/caregiving Life Branch workflow only when the
four-part necessity threshold proves that simpler Goal, Goal Path, Recovery,
destination-pivot, or Scheduling owners cannot repair the conflict independently.
Candidates are complete revision-bound simulations. One valid selection may
commit user-owned changes atomically and create one active branch; external and
recipient effects remain separate. An existing active, stale, expired, or
otherwise unresolved branch blocks promotion. Bounded v1 never supersedes it.

## Affected components and exact files

- Update `docs/canon/specifications/objects/life-branch.md`,
  `objects/branch-viability-certificate.md`,
  `systems/certified-executable-branch-reconciliation.md`, and
  `journeys/life-branch-reconciliation.md`.
- Add `Native/Ambitions/Core/Domain/LifeBranch/LifeBranchModels.swift`,
  `LifeBranchDeltaModels.swift`, and `BranchViabilityCertificateModels.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Planning/LifeBranch/LifeBranchNecessityAssessor.swift`,
  `LifeBranchCandidateMaterializer.swift`, `BranchViabilityEvaluator.swift`,
  and `BranchCompensationPlanner.swift`.
- Add `Commands/LifeBranchCommandService.swift`,
  `Transactions/LifeBranchPromotionTransaction.swift`,
  `State/LifeBranchStateStore.swift`, `Storage/LifeBranchStoreSchema.swift`,
  `Repair/LifeBranchSchemaMigration.swift`, and `Projections/LifeBranchProjector.swift`.
- Add `Native/Ambitions/Surfaces/Goals/LifeBranchReviewView.swift` and contextual
  entry/inspection adapters for Time, Today, and You/Trust.

## Data flow, persistence, and concurrency

Assessment freezes the confirmed trigger, graph, source, policy, authority,
capacity, protected-boundary, affected-owner revisions, and an
`ActiveLifeBranchBinding` containing either exact branch ID/revision/status or a
revisioned absence. Candidate materialization and certification are local and
side-effect-free. Promotion revalidates the complete read set and confirmation
digest, CASes the still-empty branch slot, and settles owner-typed operations,
branch lineage, Receipt/History, rollback disposition, and external intents in
one parent semantic transaction. Replay rebuilds occupancy and lifecycle without
reissuing external effects. Migration creates an explicit empty revisioned slot;
multiple occupants or ambiguous absence quarantine rather than choosing a winner.
All branch, certificate, checkpoint, transaction, and projection tables register
with `CanonicalRuntimeStore` schema plans and
`RuntimeGenerationDatabaseAuthority`; the supported direct-upgrade horizon is
the runtime store's current declared horizon at the implementation baseline,
not a new Life-Branch-specific retention promise.

## Dependencies, order, and rollout

This is last in the portfolio: it depends on stable Goal, Goal Path, destination
pivot, Scheduling, transaction, Receipt/History, persistence, and privacy owners.
Implement canon/domain, storage/migration, necessity/certification, atomic
promotion, lifecycle/recovery, projections/UI, then fault/race/device proof.
Gate entry to the approved relocation fixture until product work deliberately
widens Scope. No general scenario engine or automatic branch replacement ships.
