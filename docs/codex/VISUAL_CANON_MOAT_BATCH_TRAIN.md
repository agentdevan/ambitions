# Visual Canon + Moat Front-End Batch Train

Status: docs/control-plane only
Date: 2026-05-11

## Purpose

Install the visual/moat front-end sequence as a lane-compatible train without
executing runtime app source in this phase.

## Train scope (control-plane only)

- Build missing batch prompts under `prompts/batches/` for visual/moat front-end work.
- Sequence lane batches so they respect local-first and existing product truth.
- Prevent duplicate semantically identical batches by checking existing batch IDs in repo.

## Required new batch set for this phase

1. `AMBITION-GRAPH-FOUNDATION-01`
2. `PROOF-RECOVERY-LIFECYCLE-01`
3. `RECOMMENDATION-TRACE-TRUST-SEAM-01`
4. `PERSONAL-RUNTIME-LOCAL-TRUST-01`
5. `SHELL-CONTINUITY-DOCK-MATERIALS-01`
6. `TODAY-REALITY-MERIDIAN-VISUAL-01`
7. `CAPTURE-ATMOSPHERE-COMPOSER-VISUAL-01`
8. `TIME-PRESSURE-LEDGER-VISUAL-01`
9. `GOALS-CONSTELLATION-ATLAS-VISUAL-01`
10. `YOU-USER-SYSTEM-PROFILE-VISUAL-01`
11. `MOAT-ADDENDUM-STATE-SCREENS-01`
12. `ACCESSIBILITY-VISUAL-CANON-01`
13. `VISUAL-QA-PREVIEW-FIXTURES-01`
14. `FINAL-VISUAL-CANON-INTEGRATION-01`

No existing runner-compatible prompts were found for these exact IDs in this phase.

## Required sequence

1. Source-truth + visual authority install (this spec + overlay docs).
2. Ambition Graph foundations and domain scaffolding prompts.
3. Proof/recovery/closure lifecycle.
4. Recommendation trace and Trust Seam explainability.
5. Personal Runtime local trust controls.
6. Shell materials + continuity primitives.
7. Today Reality Meridian install prompts.
8. Capture Atmosphere Composer prompts.
9. Time Pressure Ledger / Reflow prompts.
10. Goals Constellation Atlas + proof trail prompts.
11. You User System Profile / runtime controls prompts.
12. Moat addendum screens.
13. Accessibility and visual proof gates.
14. Visual QA fixtures and preview matrices.
15. Final integration and honesty notes.

## Lane class and dependency constraints

- `active`: all 14 new lane batches.
- `must-run-before-ui`: Today/Accessibility/Visual QA checkpoints that produce
  safe handoff boundaries.
- `must-run-after-domain`: Proof recovery and Recommendation batches depend on domain
  consistency already represented in queue and run context.
- `visual-proof-required`: `VISUAL-QA-PREVIEW-FIXTURES-01`.
- `gpt-5.4-mini-safe`: all 14 batches are bounded and control-plane-safe.
- `senior-review-required`: `FINAL-VISUAL-CANON-INTEGRATION-01` requires human review for
  global handoff assumptions.

## Run behavior for future execution

- Do not execute these batches in this phase.
- Preserve `Time` as top-level IA in all future prompt text.
- Never convert `Plan` to a top-level destination.
- Use runner requirement headers in every generated prompt.
- For each future run batch, include EFC applicability (`invoked`, `not applicable`, or
  accepted Yellow owner).

## Non-goals for this phase

- Do not add app source edits.
- Do not claim implementation completeness.
- Do not assert accessibility, privacy, release, or visual conformance proof without
  logs/fixtures.
