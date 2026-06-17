# AMB-AOM-09 Goals Reconstruction

Status: `GREEN_SOURCE_DELTA`

This deterministic Autopilot batch starts AMB-AOM-09 by making Life Areas actionable inside the Constellation Atlas first viewport instead of leaving them as passive labels.

## Source changes

- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/AmbitionsTests/Goals/GoalsConstellationAtlasReconstructionTests.swift`

## Scope result

- Goals remains Constellation Atlas.
- Life Areas are actionable buttons with selected state.
- Choosing a Life Area opens the Orbital Lens inspection layer instead of creating or mutating a goal silently.
- Goal Threads remain available through the Orbital Lens open-thread action.
- Today connection remains in the Atlas relationship/trust language.
- Accessibility labels, values, hints, identifiers, Dynamic Type, and Reduce Motion behavior remain preserved.

## Next gate

Run AMB-AOM-09 follow-up validation for no dashboard/list regression and screenshot-proof readiness.
