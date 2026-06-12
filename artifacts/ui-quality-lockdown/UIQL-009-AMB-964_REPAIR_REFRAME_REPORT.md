# UIQL-009 / AMB-964 Repair Reframe Report

Status: Closed after reframe
Program: UIQL
Linear issue: AMB-964
Date: 2026-06-11 America/New_York

## Why Reframe Was Required

AMB-964 required more than three repair cycles. Automated screenshot matrix passes were not sufficient because exported screenshots exposed product Reds that the element checks did not catch:

- Early source/receipt checks were too brittle for grouped accessibility output.
- Initial screenshots left the lower shaping actions dimmed by the dock.
- Large Dynamic Type captures showed only the oversized Time header, then later showed the capacity statement clipped under the dock.
- Accessibility-size capacity text rendered one word per line and truncated the required `protected recovery window` phrase.

Continuing without a reframe would have created false Green from passing UI automation.

## Reframed Scope

Keep AMB-964 narrow:

- Repair Time / LifeShape Field only.
- Do not change PLOS, AOR, AESP, Source Atlas Factory, Codex OS v2, or adjacent projects.
- Do not claim global accessibility certification, owner approval, physical-device proof, or release readiness.
- Use current screenshots as visual evidence only after direct inspection.

## Final Repair

- Moved the week-capacity object and shaping actions above lower source/detail lanes.
- Added explicit shaping actions: `Shape week`, `Review pressure`, `Protect this block`, `Adjust plan`.
- Added render-state-specific source labels for manual-only and denied-source proof states.
- Added accessibility-size bottom scroll reserve on the Time screen so content can clear the Meridian dock.
- Added a compact accessibility-size capacity proof block that preserves the required capacity sentence without one-word-per-line truncation.
- Retargeted the large Dynamic Type screenshot helper to anchor on the capacity proof rather than the top chrome.

## Closing Evidence

- Final screenshot matrix: `artifacts/ui-quality-lockdown/script-output/AMB-964-time-screenshot-matrix-rerun14.log`
- Final screenshot directory: `artifacts/ui-quality-lockdown/screenshots/amb-964/rerun14/`
- Final focused unit test: `artifacts/ui-quality-lockdown/script-output/AMB-964-time-focused-unit-tests-rerun3.log`
- Proof report: `artifacts/ui-quality-lockdown/UIQL-009-AMB-964-time-reconstruction.md`

## No-Claim Boundaries

This reframe does not claim:

- owner approval
- release readiness
- TestFlight readiness
- App Store readiness
- physical-device proof
- full accessibility certification
- VoiceOver certification
- AMB-965 or later completion

## Result

Green for scoped local AMB-964 evidence after rerun14 visual inspection. Push remains pending because the owner will push manually when GitHub is fixed; AMB-964 must remain non-Done in Linear until the commit is visible on `main`.
