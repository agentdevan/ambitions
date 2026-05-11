<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# VISUAL-QA-PREVIEW-FIXTURES-01 — Visual QA Fixtures and Preview Proof

## Batch ID

VISUAL-QA-PREVIEW-FIXTURES-01

## Objective

Define and align the preview fixture matrix for visual moat surfaces and required
visual state coverage before front-end closure.

## Scope

- Ensure required fixture set includes Today / Goals / Capture / Time / You states.
- Maintain route-reveal timing artifacts for post-input transitions.
- Require rendered proof before closing any visual completion claim.

## Required fixture families

- `Today_RealityMeridian_Default`
- `Today_ProofBackedStartHere`
- `Today_RecoveryThread`
- `Goals_ConstellationAtlas_Default`
- `Goals_AmbitionGraph_ProofTrail`
- `Capture_AtmosphereComposer_Resting`
- `Capture_RouteReveal_PostInput`
- `Time_Day_PressureLedger`
- `Time_Week_ReflowCrown`
- `Time_Month_LifeShapeNodeCalendar`
- `Time_ReflowPreview`
- `You_UserSystemProfile_Default`
- `You_PersonalRuntime_LocalTrust`
- `Moat_Addendum_AllStates`

## Constraints

- No green accessibility proof claim without rendered artifact.
- No release claims based on fixture existence alone.

## EFC / claim boundaries

- EFC applicability: invoked.
- This batch is visual-proof-required in the lane.
