# AMB-AOM-08 Today Replay

Status: `GREEN_REPLAY_SOURCE_DELTA`

This replay closes the AMB-AOM-08 Yellow by removing hardcoded time-spine labels and simplifying the visible Start Here action surface.

## Source changes

- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`

## Scope result

- The Today time spine now derives labels from live `TimelineView` dates instead of fixed `6 AM`, `12 PM`, `4 PM`, and `8 PM` ticks.
- Start Here now keeps one primary action plus one inspection affordance instead of a visible CTA stack.
- The existing live-now node, refresh-after-action path, refresh-after-closure path, Dynamic Type, VoiceOver identifiers, and Reduce Motion behavior remain intact.

## Remaining risk

This closes AMB-AOM-08 blocker scope. Pixel-level Today polish remains a later visual QA concern, not a blocker to reconciliation.

## Next gate

Proceed to AMB-AOM-00/01/02/05 proof-quality closeout before AMB-AOM-09.
