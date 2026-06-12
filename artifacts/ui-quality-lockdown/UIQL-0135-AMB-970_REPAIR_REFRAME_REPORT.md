# AMB-970 Repair Reframe Report

Issue: AMB-970 - UIQL-013.5 Independent Red-Team Visual Audit
Status: Repair in progress
Date: 2026-06-12

## Why This Reframe Exists

AMB-970 repair exceeded three visual repair cycles while addressing the shell safe-area and large Dynamic Type blockers found during the independent red-team audit. Continuing is still safe because the active edits remain limited to UIQL shell geometry, dock legibility, Time/Motion bottom clearance, Create Goal proof framing, and matching UI test selectors.

## Current Narrowed Problem

The original AMB-970 Red included:

- Large Dynamic Type dock showing only three tabs at rest.
- Time and Motion large Dynamic Type actions falling into the bottom fade/dock.
- You large Dynamic Type proof capturing a detail sheet instead of the You root.
- Create Goal retaining generic modal/form anatomy and large Dynamic Type striping.

The latest user correction narrowed the active shell issue: shell safe-area reserve was too large, causing screens to sit too low and not use the full screen. The repair now focuses on reducing excess root header and bottom dock clearance without allowing content to collide with the status bar, header, or dock.

## Repair Attempts So Far

- Removed the accessibility-only horizontal dock scroll so all five tabs must remain visible at rest.
- Reduced dock label/icon sizing for accessibility Dynamic Type instead of hiding destinations behind horizontal scroll.
- Reduced global dock backdrop and visible dock padding.
- Reduced Time and Motion internal bottom safe-area spacers.
- Made the root shell header opaque enough to prevent scrolled content from bleeding through it.
- Reduced root shell header top clearance after user feedback that the screen was still too low.
- Updated You screenshot proof to target the root surface instead of a detail sheet.
- Reframed Create Goal around a first-path object preview and removed large Dynamic Type top striping.

## Safe Continuation Boundary

Continue only within:

- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/Ambitions/App/AppShellView.swift`
- UIQL-owned Time/Motion/Create Goal shell proof surfaces already touched in this repair
- UIQL proof artifacts and UI tests required to verify AMB-970

Do not broaden into PLOS, AOR, AESP, Source Atlas, runtime architecture, dependencies, release work, or non-UIQL product implementation.

## Stop Conditions

Stop and keep AMB-970 Red if any current screenshot shows:

- Header/content overlap or clipped primary action text.
- Dock hiding a tab destination at rest.
- Required Time/Motion action controls unreadable or trapped under the dock.
- Create Goal reverting to generic modal/form anatomy.
- You root proof unavailable.
- Any proof claim depending only on screenshot paths rather than visual inspection.

## Current Validation Basis

Latest focused validation before this report:

- `git diff --check`: passed.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`: passed.
- `xcodebuild test ... testAMB964TimeReconstructionScreenshotMatrix ... testUIQL002ShellGeometryKeepsChromeInsideSafeAreasAndDockHittable`: passed after root header/bottom clearance repair.
- Latest screenshots exported under `artifacts/ui-quality-lockdown/screenshots/amb-970/time-header-rerun5/` and visually inspected.

## Decision

Continue AMB-970 repair only long enough to rerun focused Motion, You, and Create Goal visual proof after the global shell clearance changes. Do not close AMB-970 until those proofs are visually inspected and no product Red remains.
