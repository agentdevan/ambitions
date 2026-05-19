# Visual Regression Readiness

Status: readiness scaffold with implemented preview fixtures

## Definition

This gate defines readiness criteria for future visual regression tests. The preview fixtures exist now, but screenshot export and device proof do not.

## Current FE-11 Artifacts

- `frontend/visual-encyclopedia/trace/SCREENSHOT_PROOF_MATRIX.md`
- `frontend/visual-encyclopedia/trace/FE11_PREVIEW_VISUAL_QA_MATRIX.md`
- `docs/audits/fe-11-preview-visual-qa-report.md`
- `scripts/ambitions-fe11-preview-visual-qa-report.py`

## Allowed Use

- Use to describe future snapshot coverage.
- Use to track debt by surface and state.
- Use to distinguish implemented preview fixtures from missing screenshot proof.

## Forbidden Use

- Do not claim snapshot implementation exists.
- Do not claim current screenshot proof.
- Do not claim device proof or release proof.

## Required Tokens

- `AmbitionsVisualSnapshotTests`
- `AmbitionsAccessibilitySnapshotTests`
- `AmbitionsDynamicTypeSnapshotTests`
- `AmbitionsReduceMotionSnapshotTests`

## Accessibility Requirements

- The gate requires test-target names, state coverage, and an explicit debt note.
- The gate also requires a non-color meaning note for each implemented preview fixture surface.

## State Variants

- `implemented preview fixture`
- `screenshot not captured`
- `accessibility checklist scaffolded`
- `not release or device proof`

## Proof And Receipt

The gate remains a readiness contract until snapshot tests are actually implemented and screenshot artifacts are captured from a real run.
