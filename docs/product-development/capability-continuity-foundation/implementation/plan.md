# Implementation Plan

## Outcome and boundary

Introduce the approved user-owned Capability object, evidence relationships,
proposal policy, correction controls, and You/Goals projections. Capability is
descriptive Life Capital: it carries provenance facets and lifecycle but no
universal level, employability score, destination match, credential acceptance,
or authority over Goal, Proof, or external systems. This initiative must land
before any recommendation, import, or export consumer writes Capability data.

## Affected components and exact files

- Add `docs/canon/specifications/objects/capability.md`; update
  `docs/canon/specifications/systems/local-learning.md`,
  `docs/canon/specifications/surfaces/you.md`, and
  `docs/canon/specifications/journeys/closure-and-proof.md`.
- Add `Native/Ambitions/Core/Domain/Capability/CapabilityModels.swift` and
  `CapabilityEvidenceModels.swift` for identity, provenance facets, permission,
  lifecycle, evidence edges, and proposal snapshots.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Planning/CapabilityProposalPolicy.swift`.
- Add
  `Native/Ambitions/Core/LocalRuntimeOS/Planning/CapabilitySourceLifecycleReconciler.swift`;
  cross-owner source changes use a causally linked idempotent Capability
  transaction rather than expanding the source owner's atomic write scope.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Commands/CapabilityCommandService.swift`,
  `State/CapabilityStateStore.swift`, `Storage/CapabilityStoreSchema.swift`,
  `Repair/CapabilitySchemaMigration.swift`, and
  `Projections/CapabilityProjector.swift`.
- Add `Native/Ambitions/Surfaces/You/CapabilityCollectionView.swift` and
  `Native/Ambitions/Surfaces/Goals/CapabilityProposalCard.swift`; connect them
  through existing You and Goals feature-service composition files rather than
  adding a root surface.

## Interfaces and data flow

Canonical completion/history observations and explicitly selected evidence
enter `CapabilityProposalPolicy` as immutable revisioned inputs. The policy may
emit a named proposal only; confirmation sends a typed command to the Capability
owner. Commands append versioned events, update state, invalidate projections,
and create truthful Receipt/History lineage atomically. Consumers receive
read-only `CapabilityCollectionProjection` values and can never mutate the
Capability store directly.

## Persistence, migration, and concurrency

The additive schema contains Capability records, evidence-edge records,
permission state, lifecycle tombstones, and projection checkpoints. Migration
creates empty collections and never infers Capabilities from historical Goals
or Receipts. The store is actor-isolated, commands use expected revisions and
idempotency keys, and replay must rebuild equivalent projections. Archive,
Trash, restore, deletion/redaction, evidence detach, and permission reset remain
explicit events; correction never rewrites history. Capability tables register
with `CanonicalRuntimeStore` and `RuntimeGenerationDatabaseAuthority`; they do
not create a parallel database.

## Rollout, canon, and implementation order

Land canon and domain contracts first, then store/migration, policy, command and
projection integration, and finally surfaces. Keep all downstream consumers
disabled until their own approved initiatives land. Regenerate the Xcode project
from `project.yml`; no project-file hand editing is permitted. Rollout is local-
only and additive, with no account, network, or background inference path.
