# Visual Regression Readiness

Status: readiness scaffold with implemented preview fixtures

## Definition

This gate defines readiness criteria for future visual regression tests. The preview fixtures and FE-11 SwiftUI ImageRenderer PNG inventory exist now, but device proof, snapshot-test automation, and human visual approval do not.

## Current FE-11 Artifacts

- `frontend/visual-encyclopedia/trace/SCREENSHOT_PROOF_MATRIX.md`
- `frontend/visual-encyclopedia/trace/FE11_PREVIEW_VISUAL_QA_MATRIX.md`
- `docs/audits/fe-11-preview-visual-qa-report.md`
- `docs/audits/visual-evidence/fe11/fe11-preview-visual-qa-proof.md`
- `scripts/ambitions-fe11-preview-visual-qa-report.py`
- `scripts/ambitions-fe11-generate-fixture-screenshots.py`

## Allowed Use

- Use to describe future snapshot coverage.
- Use to track debt by surface and state.
- Use to distinguish implemented preview fixtures and FE-11 inventory proof from missing device, release, and human approval proof.

## Forbidden Use

- Do not claim snapshot implementation exists.
- Do not claim current device screenshot proof.
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
- `screenshot inventory complete`
- `accessibility checklist scaffolded`
- `not release or device proof`
- `proof manifest`

## Proof And Receipt

The gate remains a readiness contract until snapshot tests are actually implemented and device or simulator artifacts are captured from a real app run.
