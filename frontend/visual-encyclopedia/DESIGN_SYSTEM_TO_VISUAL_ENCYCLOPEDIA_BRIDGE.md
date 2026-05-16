# Design System To Visual Encyclopedia Bridge

Status: Active support bridge

Batch: `VISUAL-DESIGN-FINAL-FORM-LOCK-REPAIR-05`

## Purpose

This bridge keeps design tokens, component contracts, UI decisions, and mature surface canon aligned without claiming implementation proof.

## Active Mappings

- Design tokens describe the shared visual system.
- Component contracts describe how surfaces should behave.
- UI decisions describe current frontend intent changes that need traceability into recipes, primitives, source candidates, proof contracts, and rollback.
- The mature universe describes which surfaces belong in the final App Store control plane.

## UI Decision OS

Frontend UI decisions live under `frontend/visual-encyclopedia/decisions/`.

The decision layer is the intake point for current UI direction before code changes. It generates:

- `frontend/visual-encyclopedia/decisions/UI_DECISION_LEDGER.yaml`
- `frontend/visual-encyclopedia/trace/UI_DECISION_TO_SURFACE_MATRIX.yaml`
- `frontend/visual-encyclopedia/trace/UI_DECISION_TO_DESIGN_SYSTEM_MATRIX.yaml`
- `build/reports/ui-decisions/<decision-id>/generated-implementation-prompt.md`

Use this layer when a design decision should update the encyclopedia, expose design-system primitive gaps, and produce a bounded Ambitions runner prompt.

## Boundary

Implementation, device, release, screenshot, and accessibility conformance proof remain out of scope for this bridge. UI decisions and generated prompts are planning/control-plane artifacts until code changes land with current proof and receipts.
