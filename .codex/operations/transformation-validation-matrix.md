# Transformation Validation Matrix

Use this matrix to choose the narrowest truthful validation set for post-hardening transformation work.

## Core Principle

Default to the smallest validation set that can still prove the changed seam.
Do not jump straight to full `AmbitionsUITests` unless the batch archetype or recent failures justify it.

## Validation Layers

- `control truth`: registry, batch docs, program wording, canon status
- `generation/build`: `xcodegen generate`, native build
- `targeted tests`: focused unit/integration tests for the touched seam
- `focused UI proof`: isolated UI tests for the touched flow and the fixed regression pack slice
- `manual signoff`: direct simulator/device review against the surface checklist
- `full AmbitionsTests`: full non-UI suite
- `full AmbitionsUITests`: broad end-to-end UI suite

## Archetype Defaults

### docs-control

Use:

- control truth
- link/file consistency if docs-only

Usually skip:

- build
- tests
- UI validation

### shared-system

Use:

- control truth if touched
- `xcodegen generate`
- native build
- targeted tests for the shared primitives or service seams
- full `AmbitionsTests`
- focused downstream UI proof only if the shared change affects shipped surface behavior

Usually skip:

- full `AmbitionsUITests`
- broad manual signoff unless a visible system changed materially

### surface-rebuild

Use:

- control truth if touched
- `xcodegen generate`
- native build
- targeted surface tests
- full `AmbitionsTests`
- focused UI proof for the surface and relevant regression-pack slice
- manual signoff using the surface checklist

Run full `AmbitionsUITests` only when:

- the batch changes shell-wide interaction behavior
- focused UI proof suggests broader instability
- the batch plan explicitly calls for it

### shell-external

Use:

- control truth if touched
- `xcodegen generate`
- native build
- targeted shell/routing tests
- full `AmbitionsTests`
- focused UI proof across affected shell/external routes
- broader UI reruns when route ownership or overlay behavior changed materially
- manual signoff for the shipped user paths

This is the archetype most likely to justify a larger UI validation slice.

### coherence-pass

Use:

- control truth if touched
- `xcodegen generate`
- native build
- targeted cross-surface tests
- full `AmbitionsTests`
- focused regression-pack proof
- manual signoff on handoff continuity

Usually skip:

- full `AmbitionsUITests` unless coherence changes span shell + multiple destination surfaces

### multi-device

Use:

- control truth if touched
- `xcodegen generate`
- target/device build validation
- targeted tests
- focused UI proof per platform surface
- manual signoff per platform
- full `AmbitionsTests`

Treat platform-specific manual signoff as mandatory.

### finish-quality

Use:

- all relevant lower layers first
- broad focused UI proof
- manual accessibility/performance/readability signoff
- full `AmbitionsUITests` when the batch intent is true finish-quality certification

## Fixed Regression Pack Rule

Before broad UI reruns, use the fixed regression pack in `frontend-regression-pack.md` and only the slice affected by the batch.

## Manual Signoff Rule

For premium surface work, manual signoff is required whenever the batch changes:

- hierarchy
- scanability
- motion or reduced motion
- continuity cues
- pressure/recovery posture
- readability/accessibility in ways that UI automation cannot judge well

## Known Flake Handling

If a known combined UI flake appears:

1. rerun it in isolation
2. confirm whether the user-facing flow is actually broken
3. use the known-flakes policy
4. do not block wrap with broad rerun churn unless the risk is no longer bounded

## Closeout Evidence Rule

A batch may close with a documented combined UI flake only when all of these are true:

- the flake is known and timing-sensitive, not a new unexplained failure
- isolated reruns are green
- manual signoff is complete
- the residual caveat is documented in the batch completion note and registry truth
- no user-facing regression remains in normal runtime use
