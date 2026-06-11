# UIQL-002 Repair Reframe Report

Status: Repair continued safely after more than three cycles because each cycle narrowed the same shell-geometry Red with current UI test evidence and did not broaden scope outside UIQL-002.

## Original Frame

UIQL-002 was initially framed as shell geometry and safe-area proof. Existing source and tests proved the canonical five-tab shell and global Capture routing, but not actionable frame placement against safe boundaries.

## Reframed Repair Target

The repair target became explicit and measurable:

- header actionable controls must be inside the app window and hittable;
- native tab bar must be inside the app window;
- five canonical tab buttons must be inside the native tab bar and at least 44pt in width and height;
- Capture/Pulse/Plan must not appear as top-level tabs;
- activated Capture seam must stay above the native tab bar after keyboard dismissal.

## Cycles

1. Added strict UIQL-002 shell geometry UI test.
   - Result: Red; shell header rail/control frames extended above the top boundary.
2. Reframed material bleed vs actionable controls.
   - Result: Red; context crown still extended above top boundary.
3. Increased root header top clearance.
   - Result: Red; trailing Capture button still extended above top boundary.
4. Standardized header controls to `theme.panel.minimumTapTarget` and increased top clearance.
   - Result: Red; remaining Capture button overflow narrowed to about 1.2pt.
5. Finalized top clearance at `theme.spacing.lg + theme.spacing.lg + theme.spacing.lg`.
   - Result: Green for shell header/dock geometry UI test.
6. Added activated Capture seam frame proof.
   - Result: Red; seam overlapped the native tab bar after keyboard dismissal.
7. Increased activated seam bottom clearance to `theme.spacing.xxxl`.
   - Result: Green for activated Capture seam UI test.

## Why Continuing Was Safe

- Every failed cycle came from the same UIQL-002 shell/safe-area proof target.
- No branch was created.
- No dependency, runtime architecture, data, release, or adjacent program work was touched.
- The source patch stayed within shell geometry files and UI tests:
  - `Native/Ambitions/App/AppShellView.swift`
  - `Native/Ambitions/App/AmbitionsRootView.swift`
  - `Native/AmbitionsUITests/AmbitionsUITests.swift`
- Failed logs were preserved instead of hidden.
- The final evidence came from current simulator UI automation, not screenshot path claims.

## Rollback

Rollback this issue by reverting:

- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `artifacts/ui-quality-lockdown/UIQL-002_SHELL_GEOMETRY_PROOF.md`
- `artifacts/ui-quality-lockdown/UIQL-002_REPAIR_REFRAME_REPORT.md`
- UIQL-002 log additions under `artifacts/ui-quality-lockdown/script-output/`
- related proof-ledger/run-state/changelog entries

## Non-Claims

This reframe does not claim screenshot approval, full accessibility certification, owner approval, release readiness, physical-device proof, performance proof, or UIQL-003+ surface quality.
