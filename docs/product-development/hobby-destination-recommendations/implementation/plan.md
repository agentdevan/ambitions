# Implementation Plan

## Outcome and boundary

Add an explicit, ephemeral hobby exploration session for the two approved
low-risk families. It joins temporary choices and optionally selected Capability
facets with a verified public hobby corpus locally, then shows one to four
qualitative, neutrally ordered possibilities. It creates no durable preference,
learning, Goal, path, schedule, provider interaction, interest inference, or
session-derived diagnostic.

## Affected components and exact files

- Add `docs/canon/specifications/systems/hobby-destination-recommendations.md`;
  update Source Atlas, privacy, and private-runtime canon.
- Add `Native/Ambitions/Core/Domain/HobbyRecommendation/HobbyRecommendationModels.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Planning/HobbyRecommendation/HobbyDestinationEligibilityPolicy.swift`,
  `HobbyCandidateWindowPolicy.swift`, and `HobbyExplorationCoordinator.swift`.
- Add `Native/Ambitions/Surfaces/Goals/HobbyExplorationView.swift` and
  `Native/Ambitions/Trust/HobbySourceInspectionView.swift`.
- Add the approved synthetic public corpus fixture under
  `Native/AmbitionsTests/Fixtures/HobbyRecommendation/approved-hobby-corpus-v1.json`;
  do not add a production corpus until its separate source review is complete.

## Data flow, persistence, and rollout

The in-memory session actor captures policy and corpus revisions, temporary
choices, selected Capability IDs, and exact consent. A fixed public artifact ID
loads an already verified corpus. Eligibility, local join, derived-output
classification, suppression, family-first alternation, overflow, correction,
and dismissal all occur in memory. Exit destroys session state. Persistence and
user-data migration are N/A because the approved Design forbids them; only
versioned engine policy and synthetic fixture schemas exist. V1 reuses the
public-reference foundation's signed JSON envelope, schema decoder, signature
verifier, and fixed public artifact identity; it does not define another
certificate format. Implement models,
gates, neutral ordering, coordinator, then UI/inspection. Launch remains behind
an explicit user action and fails quiet when no approved corpus is installed.
