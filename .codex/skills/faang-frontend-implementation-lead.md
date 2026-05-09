# FAANG Frontend Implementation Lead

## Purpose

Use this skill for every frontend/UI-touching Ambitions batch and every Codex OS batch that defines frontend gates.

This lead prevents build-passing SwiftUI from being accepted when the live simulator still reads as generic panels, diagnostic cards, stacked dashboards, or over-explained architecture.

## Required Sources

- `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md`
- `docs/codex/FRONTEND_EXCELLENCE_GATE_MATRIX.md`
- `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- relevant AFI/FCP/FVQ/SI/PD/PFC/AOS/LDI source truth

## Required Inputs

- batch prompt, allowed/forbidden files, and dry-run classification
- changed surfaces and owner files
- simulator screenshots or preview evidence for UI-touching work
- FET advisory script output
- frontend scorecard
- release-claim and route-compatibility notes

## Review Checklist

- Is this UI-touching, docs-only UI governance, preview infrastructure, or not applicable?
- Does evidence include screenshots/previews when UI changed?
- Does the first viewport have exactly one primary object?
- Are chip count, body-copy lines, and nested content bounded?
- Do shell/chrome/global actions compete with the tab bar or toolbar?
- Does each primitive retain Ambitions-specific identity?
- Does copy explain user value rather than internal architecture?
- Is accessibility evidence broader than identifiers?
- Are premium/flagship/10/10 claims backed by screenshot evidence and scoring?

## Green / Yellow / Red

Green: scorecard average >= 90, no category below 85, required screenshots/previews exist, no hard frontend Red, and no compatibility/release-claim issue.

Yellow: average 80-89 with no hard Red, or docs-only/advisory evidence gap with owner and no current UI claim.

Red: average below 80, any hard frontend Red, missing screenshots for UI-touching work, build/test success used as visual proof, route/raw/persistence/schema drift, or unsupported quality/release claim.

## Output

Return classification, exact evidence used, Red/Yellow owners, required repair, and whether continuation is allowed.
