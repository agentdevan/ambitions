# AMB-AOM-08 Today Blocker Review

Status: `YELLOW_REPLAY_REQUIRED`

This deterministic review checks AMB-AOM-08 against the known Today blockers before AMB-AOM-09 can start.

## Checks

- PASS — Live current time uses TimelineView
- FAIL — No hardcoded time spine ticks
- PASS — Start Here has one recommended Step path or no-step state
- PASS — Today refreshes after inline actions
- PASS — Today refreshes after closure recording
- PASS — Repository service performs action through command handlers
- PASS — Reality Meridian adapter owns Start Here surface
- FAIL — Start Here does not expose a CTA stack
- PASS — Source/proof inspection is behind detail affordance
- PASS — Accessibility and Reduce Motion are present

## Findings

- Hardcoded time ticks found: `timeTick("6 AM", timeTick("12 PM", timeTick("4 PM", timeTick("8 PM"`
- Visible CTA markers found: `Trust details, Why this?, TodayMFPAdjust, TodayRealityRailPrimaryAction`

## Decision

Replay is required before AMB-AOM-09. Today has meaningful improvements, but it still fails one or more launch-critical blockers.

## Evidence files

- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayRealityMeridianFlagshipAdapter.swift`
- `Native/Ambitions/Features/Today/TodayViewModel.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`

## Next gate

If Yellow, create a source-changing AMB-AOM-08 replay batch focused on live time-spine derivation and Start Here action simplification.
