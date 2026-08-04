# Implementation Plan

## Outcome and boundary

Deliver local education exploration across approved route forms and authority
lanes while preserving the distinction between classification, provider facts,
transfer policy, accreditation context, licensing authority, and receiver
acceptance. Suggestions remain advisory options, not admission, transfer,
equivalency, eligibility, affordability, availability, or completion claims.
No Goal, path, schedule, provider contact, or external write occurs.

## Affected components and exact files

- Add `docs/canon/specifications/systems/education-destination-recommendations.md`;
  update Source Atlas, Source Reference, private-runtime, privacy, and You canon.
- Add `Native/Ambitions/Core/Domain/EducationRecommendation/EducationRecommendationModels.swift`,
  `EducationAuthorityLaneModels.swift`, and `EducationExplorationSessionModels.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Planning/EducationRecommendation/EducationExplorationCoordinator.swift`,
  `EducationEligibilityPolicy.swift`, `EducationOptionComposer.swift`, and
  `EducationExplanationBuilder.swift`.
- Add `Commands/EducationPreferenceCommandService.swift`,
  `State/EducationExplorationStore.swift`, and
  `Projections/EducationRecommendationProjector.swift`.
- Add `Native/Ambitions/Surfaces/Goals/EducationExplorationView.swift` and
  `Native/Ambitions/Trust/EducationOptionInspectionView.swift`.

## Data flow, persistence, and migration

The coordinator freezes user-selected intent, Capability facets, declared
education context, exact protected-data consent, public authority snapshots,
policy, and clock. Source Atlas returns verified public claims by fixed artifact
ID; all matching and output classification remain local. Private session
snapshots and explicit preference events persist behind protected local storage,
while public pack bytes remain Source Atlas-owned. Migration creates empty
session/preference collections and never derives education history from existing
Life Context or Goals. Revision checks, generation tokens, atomic events, and
replay prevent stale or duplicate results.

## Dependencies, order, and rollout

Depend on Capability and public-reference foundations; reuse the advisory
candidate handoff contract established by career recommendations without sharing
career authority rules. Implement models/authority lanes, gates/composition,
persistence/commands, projection/UI, then adoption compatibility. Start with
synthetic verified packs; provider contact, applications, transfer evaluation,
financial-aid advice, and licensing decisions remain excluded.
