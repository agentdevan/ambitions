# Ambitions UI Primitive Review Board
<!-- markdownlint-disable MD013 -->

## Purpose

Gate reusable Ambitions UI primitives so SI implementation creates a coherent
system instead of one-off visual pieces.

## Member Roles

- Ambitions native UI primitive reviewer.
- Signature Interface creative director.
- SI file-size/component-boundary reviewer.
- Accessibility adaptive interface reviewer.
- Interaction motion/haptics reviewer.
- Signature iconography symbol reviewer when symbols are used.
- Loading degraded state reviewer when state surfaces are touched.

## Required Source Truth

Ambitions 3.0 primitives, PXOS visual/surface canon, SI canon when present,
current design-system primitives, selected prompt, and touched source files.

## Required Evidence Package

Component ownership, state matrix, API boundary, previews, visual QA evidence,
file-size snapshot, tests/build logs, accessibility notes, and rollback path.

## Review Sequence

1. Confirm product-owned primitive name and responsibility.
2. Confirm component state matrix.
3. Review API and ownership boundary.
4. Review visual/invented-but-native score.
5. Review accessibility and adaptive behavior.
6. Review motion/symbol/loading requirements if relevant.
7. Review file-size and test coverage.
8. Review release-claim safety.

## Voting And Gate Standard

Green requires focused ownership, previewable states, accessibility coverage,
reviewable file size, and Strong implementation validation. Yellow requires a
named future owner. Red blocks continuation.

## Invented-But-Native Rubric

Average score at least 4 and no category below 3 for originality, native
believability, usefulness, restraint, accessibility, emotional tone, system
coherence, and maintainability.

## Anti-Generic UI Review

Reject `CardView` architecture, vague wrappers, all-purpose modules, generic
dashboard panels, decorative icon clutter, and primitive names that do not
express Ambitions meaning.

## Accessibility And Adaptive Review

All meaningful states need labels/values or nonvisual equivalents. Dynamic
Type, reduced-motion, and privacy-sensitive states are required where relevant.

## Preview And Visual QA Review

Every primitive should have deterministic preview states when preview
infrastructure exists. Missing preview proof for UI-changing primitives is Red
unless tooling is unavailable and a safe substitute exists.

## File-Size And Component Boundary Review

New primitives should be small, focused, and testable. Material file-size
growth requires owner, rationale, and extraction path.

## Yellow Classification Protocol

Classify, name owner, document why continuation is safe, and identify the
future batch or backlog that must revisit the issue.

## Red Stop Protocol

Stop on generic primitive, missing state matrix, missing accessibility,
unreviewable file growth, weak validation, or unsupported release/platform
claim.

## Release-Claim Safety Review

Primitive implementation is not SI train completion and is not release,
platform, human visual approval, or public accessibility proof.
