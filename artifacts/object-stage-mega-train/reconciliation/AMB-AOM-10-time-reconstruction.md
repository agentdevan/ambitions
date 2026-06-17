# AMB-AOM-10 Time Reconstruction

Status: `GREEN_SOURCE_DELTA`

This deterministic Autopilot batch starts AMB-AOM-10 by hardening Time as a LifeShape Field contract instead of a calendar, agenda, free/busy grid, or productivity score surface.

## Source changes

- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
- `Native/AmbitionsTests/Time/TimeLifeShapeFieldReconstructionTests.swift`

## Scope result

- Time owns LifeShape Field.
- The first viewport contract explicitly names capacity contours, pressure texture, protected windows, fixed points, horizons, and confirmation-first shaping actions.
- Calendar clone, agenda clone, free/busy grid, and metric-row dashboard geometry are explicitly rejected.
- Accessibility fallback language exposes protected windows, fixed points, and horizon state as text.
- Existing reflow controls remain confirmation-first and call the reflow decision callback only from explicit action buttons.

## Next gate

Run AMB-AOM-10 validation for no calendar/list regression and confirmation-control proof before AMB-AOM-11.
