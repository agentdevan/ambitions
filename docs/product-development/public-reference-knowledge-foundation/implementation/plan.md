# Implementation Plan

## Outcome and boundary

Create one verified public-reference substrate for career, education, hobby,
credential, and pathway consumers. It owns public artifact identity, authority
lane, jurisdiction, freshness, rights, claim provenance, conflict, availability,
and last-known-good behavior. It never accepts private graph context, ranks a
user, recommends a destination, decides equivalence, or mutates canonical user
objects.

## Affected components and exact files

- Update `docs/canon/specifications/systems/source-atlas.md`,
  `objects/source-reference.md`, and
  `systems/privacy-and-data-classification.md`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/PublicReferenceKnowledgeModels.swift`,
  `PublicReferenceAuthorityPolicy.swift`, `PublicReferencePackAdapter.swift`,
  `PublicReferenceRepository.swift`, and `PublicReferenceQueryService.swift`.
- Extend `SourceAtlasPublicPackRequestValidator.swift`,
  `SourceAtlasVerifiedPublicPackProvider.swift`, `FreshnessEngine.swift`,
  `LastKnownGoodStore.swift`, and `PublicOnlyFirewall.swift` only through the new
  typed public-reference contract.
- Replace private-context access in
  `SourceAtlasPackModels+08-SourceAtlasCapabilityPathComposer.swift` with a
  public-only adapter over `SourceAtlasPublicPlanningContextModels.swift` before
  any recommendation consumer is enabled.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Inspection/PublicReferenceInspectionProjection.swift`
  and a contextual inspection view at
  `Native/Ambitions/Trust/PublicReferenceInspectionView.swift`.

## Data flow, persistence, and migration

A finite allowlisted public artifact request enters Source Atlas, passes public-
only validation, signature/schema/rights/authority/freshness checks, and becomes
an immutable versioned public-reference snapshot. Query clients submit public
artifact IDs and claim selectors only. The repository stores verified public
pack bytes and metadata separately from the private graph. Cache migration is
additive; incompatible packs remain last-known-good or unavailable, never
silently reinterpreted. Refresh is actor-isolated and revisioned; network timing
cannot change deterministic local claim ordering. V1 uses the existing signed
Source Atlas JSON pack envelope and the existing file-backed public-pack cache:
immutable pack and manifest artifacts, hash-addressed indexes, and the cache
journal. Current and last-known-good selection is persisted as an atomic,
versioned public-only pointer over those verified artifacts. The implementation
must call the existing signature, manifest, schema, and payload-hash verifiers;
it must not accept a caller-supplied verification assertion or introduce a
parallel artifact format or persistence system. Until an exact approved O*NET
30.3 artifact and trusted verification material exist in the registry, the
production query path remains honestly unavailable rather than installing a
synthetic or weakly verified release.

## Rollout and implementation order

Land canon and models, then authority/freshness policy, adapter/repository,
query/inspection, and finally consumer integration tests. Seed only synthetic
fixtures until each real domain pack has its own source/rights review. A public
pack can become usable only through an explicit registry entry; no recommendation
initiative may bypass this foundation with direct network access.
