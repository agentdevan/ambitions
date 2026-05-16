# Frontend Decision OS Install Report

Status: Green for control-plane install

## Summary

Installed a frontend UI decision control plane for Ambitions.

The system captures active UI decisions once, maps them to visual encyclopedia surfaces, exposes AmbitionsDesignSystem primitive gaps, generates bounded Ambitions runner implementation prompts, and provides make entry points plus a final gate.

This is not SwiftUI implementation proof, screenshot proof, simulator proof, device proof, accessibility conformance proof, hosted CI proof, release readiness, or App Store readiness.

## Installed Files

- `GNUmakefile`
- `frontend/visual-encyclopedia/decisions/README.md`
- `frontend/visual-encyclopedia/decisions/UI_DECISION_LEDGER.yaml`
- `frontend/visual-encyclopedia/decisions/active/UID-2026-05-15-today-local-ambitions-lockup.yaml`
- `frontend/visual-encyclopedia/decisions/active/UID-2026-05-15-today-live-current-time-cursor.yaml`
- `frontend/visual-encyclopedia/decisions/active/UID-2026-05-15-bottom-ia-five-tabs.yaml`
- `frontend/visual-encyclopedia/trace/UI_DECISION_TO_SURFACE_MATRIX.yaml`
- `frontend/visual-encyclopedia/trace/UI_DECISION_TO_DESIGN_SYSTEM_MATRIX.yaml`
- `scripts/ambitions-ui-decision-new.py`
- `scripts/ambitions-ui-decision-check.py`
- `scripts/ambitions-ui-decision-recipe-link-check.py`
- `scripts/ambitions-ui-decision-sync.py`
- `scripts/ambitions-ui-decision-implementation-prompt.py`
- `scripts/ambitions-ui-decision-final-gate.py`
- `frontend/visual-encyclopedia/DESIGN_SYSTEM_TO_VISUAL_ENCYCLOPEDIA_BRIDGE.md`
- `build/reports/ui-decision-final-gate.md`
- `build/reports/ui-decision-final-gate.json`
- generated seed reports under `build/reports/ui-decisions/`

## Seed Decisions

- `UID-2026-05-15-today-local-ambitions-lockup`
- `UID-2026-05-15-today-live-current-time-cursor`
- `UID-2026-05-15-bottom-ia-five-tabs`

## Commands

Validate decisions:

```bash
make ui-decision-check
```

Validate decision-to-surface and decision-to-design-system linkage:

```bash
make ui-decision-link-check
```

Create a decision:

```bash
make ui-decision-new ARGS='--id UID-YYYY-MM-DD-example --decision "Describe the UI decision" --surface today_root_reality_meridian'
```

Sync generated reports:

```bash
make ui-decision-sync
```

Generate an implementation prompt:

```bash
make ui-decision-prompt DECISION=UID-2026-05-15-today-local-ambitions-lockup
```

Run the UI decision final gate:

```bash
make ui-decision-final-gate
```

Run the whole UI decision control-plane lane:

```bash
make ui-decision-all
```

## Validation Notes

- The installed UI decision final gate report is Green for the committed control-plane artifacts.
- A local dry run of the installed script set was performed before writing the initial files.
- This report does not claim hosted CI execution.

## Known Gaps

- Seed decisions identify missing AmbitionsDesignSystem primitives; they do not implement those primitives.
- No SwiftUI frontend code was modified in this pass.
- The root `GNUmakefile` includes the existing `Makefile` and adds UI-decision targets without replacing the large existing Makefile.
