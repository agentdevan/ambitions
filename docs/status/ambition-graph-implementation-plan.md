# Ambition Graph Implementation Plan — MOAT-ALIGNMENT-01

Current model inventory (implemented now):

- `AmbitionGraphModels.swift` contains additive value models for:
  - `Ambition`
  - `GoalThread`
  - `Commitment`
  - `Proof`
  - `Constraint`
  - `RecoveryThread`
  - `RecommendationTrace`
  - `Reflection`
  - `AdaptationPivot`
  - `AmbitionGraphSnapshot`
- Existing SwiftData records and feature screens are unchanged in this phase.

Proposed durable object hierarchy:

```text
Identity Direction
  -> Life Area
    -> Ambition
      -> Outcome
        -> Goal Thread
          -> Commitment
            -> Step
              -> Closure Event
                -> Proof
                  -> Reflection
                    -> Adaptation / Recovery
```

What was implemented this phase:

- Additive in-memory/value-level ambition graph models in `Native/Ambitions/Domain/AmbitionGraphModels.swift`.
- Added enums for:
  - `AmbitionPrivacyClass`
  - `AmbitionGraphProofType`
  - `AmbitionRecoveryStatus`
  - `AmbitionCommitmentStatus`
  - `AmbitionRecommendationAction`
  - `AmbitionClosureState`
- Added `CaptureRoute.proofItem` and `CaptureRoute.constraintItem` and destination mapping in `Native/Ambitions/Domain/CaptureModels.swift`.
- Added dedicated regression coverage:
  - `Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift`
  - `Native/AmbitionsTests/Domain/CaptureModelsTests.swift`

What remains scaffolded:

- No SwiftData model migration in this phase.
- No service/projector integration between:
  - `AmbitionGraphSnapshot`
  - `Closure / Recovery / Proof` flows
  - `RecommendationTrace` UI surfaces
- No migration path implemented from older `Goal`-first assumptions to the new object priority.

Migration risks:

- SwiftData migration for legacy persisted fields may be required before any persisted creation of `Ambition`-level objects.
- Existing historical storage names (e.g., route/type enums for legacy goals and steps) require compatibility mapping before any feature-surface rewrites.
- Recommendation trace behavior is still scaffolding and must be tied into existing recommendation projectors carefully to avoid duplicate explanation surfaces.

Rollback considerations:

- The phase is additive; removing `AmbitionGraphModels.swift` additions does not require schema rollback.
- If needed, rollback scope includes:
  - New tests in `Native/AmbitionsTests/Domain/*Ambition*Graph*ModelsTests.swift`
  - `CaptureRoute.proofItem` and `.constraintItem` in `CaptureModels.swift` (safe to remove without schema migration)
  - Added scripts and status docs.
