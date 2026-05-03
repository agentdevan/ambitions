# DAV10 AdaptiveMotion ReduceMotion And StateTransitions Prompt
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV10
- Name: AdaptiveMotion ReduceMotion And StateTransitions
- Global order: 064
## Active 4.0 Status
Active DAV closeout/implementation batch for motion helpers.
## Purpose
Validate and refine reduce-motion-aware animations, subtle pulse, soft reveal, rail progress, receipt confirmation, and hero expansion transitions.
## Affected Surfaces
All DAV surfaces.
## Allowed Production Swift Files
Sources/Components/** and narrow surface files touched by prior DAV batches.
## Forbidden Files
Persistence/schema, routes/raw values, dependencies.
## Required Visual Primitives
Motion helpers attached to DAV primitives.
## Motion Rules
No infinite motion by default, no multi-axis/spinning/vortex motion.
## Reduce Motion Equivalent
Required for every meaningful transition.
## Dynamic Type Requirements
Motion must not depend on text size.
## VoiceOver Requirements
Motion cannot be the only state cue.
## Preview Fixture Requirements
Reduce Motion states.
## Product-Experience Before/After Notes
Record motion meaning.
## Validation Commands
`scripts/dav-reduce-motion-check.sh || true`; focused build/tests.
## Green/Yellow/Red Criteria
Green: all motion has meaning and fallback. Yellow: visual polish deferred. Red: decorative or accessibility-blocking motion.
## Stop Conditions
Stop on motion-only meaning.
## Commit Message
`Run DAV10 AdaptiveMotion ReduceMotion And StateTransitions`
## Next Safe Path
DAV11 accessibility closeout.

