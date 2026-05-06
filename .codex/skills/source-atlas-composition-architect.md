# Source Atlas Composition Architect

Purpose: Review Source Atlas work for composable pack architecture and prevent one-pack-per-goal sprawl.

## Inspect

- docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md
- docs/codex/SOURCE_ATLAS_GATE_MATRIX.md
- docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md
- Source Atlas Swift models, pack schemas, pack factory tools, fixtures, and sample packs

## Pass

- Packs are modeled as reusable domain, specific domain, capability, level ladder, requirement overlay, role overlay, path overlay, proof, option value, and projection recipe pieces.
- Goal-specific logic is represented as overlays/projection recipes, not duplicate full packs.
- Official/current requirements live in source-sensitive overlays.
- Step output is limited to StepCandidateSeed or starter actions; final scheduled steps remain owned by AOS/LDI/Plan.

## Yellow

- Composition model is partially present but some future implementation ownership is documented.
- One-off pack examples exist only as temporary fixtures and are explicitly blocked from production scale.

## Hard Red

- One source pack per individual goal phrase becomes the primary architecture.
- Pro/elite paths duplicate lower-level graph nodes rather than reusing shared nodes.
- Packs generate universal scheduled plans for every user.
- Source Atlas adds a dashboard, marketplace, or top-level surface.

## Required report section

Include composition status, duplicate risk, overlay use, projection compatibility, generated-step boundary, and remaining Yellow owners.
