# Fixture and state inventory

## Stable family

- Family: `today-flagship/preparing-for-baby/still-counts/v1`
- Present: Thursday, July 23, 2026 in the existing deterministic context
- Start Here: `step.nursery-ready-for-crib`
- Parent pursuit: `goal.welcome-baby-home`
- Revealed Start Here: `step.send-launch-brief`
- Return anchor: `today.settled.step.nursery-ready-for-crib`
- Receipt and History identities: unchanged from B01
- Recovery command identities and effects: unchanged from B01

## Existing state model retained

`todayInitial → focusedCurrent → reviewingProposal → savingAcceptedTruth →
settled → todayReturned`, plus interrupted and recovery-review branches.

Current truth remains accepted until settlement. History disclosure is
secondary and non-mutating. Return preserves the settled nursery Step and
reveals the launch brief exactly once.

## B02 presentation additions

- Read-only Full Day route derived from the existing timeline snapshot
- Root overview limited to three or four anchors
- `TodayFlagshipTimelineRole`: Now, ordinary, fixed, protected, external, open lane
- Explicit `nowAnchorObjectID(for:)` resolved by Full Day origin. Initial Today
  maps to the primary nursery Step; returned Today maps to the revealed
  `step.send-launch-brief`. Full Day inserts that existing origin-specific Start
  Here snapshot as its Now row. Root Start Here is the Now anchor and is not
  duplicated in the overview. After return, the nursery Step remains present as
  settled, subordinate, and read-only rather than retaining the Now role.
- Optional immutable `TodayFlagshipContextSeamSnapshot` with an explicit
  offline-local, stale-external, or conflict-transfer condition, affected
  object identity, owner title, visible copy, and accessibility label
- Explicit quiet, dense, and very-dense timelines of three, six, and ten
  objects. Overview selection uses Start Here as Now, then chooses earliest
  fixed, first protected, first open/later, and earliest remaining ordinary
  object, stopping at four; Full Day retains the complete order.
- Offline retains nursery truth without a retry control. Stale external context
  names the work commitment without a false refresh action. Conflict transfer
  names Time ownership without fabricating an `Open in Time` route.
- No new product command, runtime capability, owner, or persistence guarantee

Fixture copy and localization remain evaluation content, not canon or
production localization authority.

## Source-support matrix

| Fixture state | Authority | Snapshot fields | Visible placement | Controls |
| --- | --- | --- | --- | --- |
| Quiet day | Today screen inventory and first-viewport law | explicit three-object timeline roles | root overview and Full Day | existing object actions only |
| Dense/very dense | Today temporal rail and dense transformation law | six/ten stable timeline objects | four-anchor root projection; full sequence in Full Day | existing source-backed Step action only |
| Offline local truth | `APP-DEGRADED-FAILURE-TAXONOMY-001`, `APP-DEGRADED-PRESENTATION-001`, no-account core | condition, affected local Step, currentness, what remains available, owner, accessibility label | narrow Step seam | none; core action remains available |
| Stale external context | same degraded-state authority | condition, affected work commitment, freshness statement, owner, accessibility label | affected external timeline row | none; no source-backed refresh path in Foundry |
| Conflict transfer | Today ownership plus degraded presentation | condition, affected nursery/time relationship, Time owner title, accessibility label | read-only timeline seam | none; no source-backed Time route in Foundry |
| Undo | no exact fixture inverse contract | absent | absent | absent |

The degraded-state canon permits narrower presentation but commands must match a
real classified consequence. Because the fixture has no executable refresh,
continuity, diagnostics, or Time-handoff path, these evidence seams are
read-only. The absence is recorded rather than hidden behind a fake control.

## Immutable localized copy contract

`TodayFlagshipInterfaceCopy` is expanded with fixture-injected strings for the
Ambitions crown, Today accessibility heading, overview labels, Full Day title/
action/Scroll to Now, dock root/global group labels, selected-state value,
navigation hints, relationship prefixes, Today/Goals/Time/You/Search/Capture
titles, Time owner title, resilience seams, and announcements. Navigation
command IDs remain stable and separate from localized titles.

The same snapshot owns every current B01 literal that can reach product or
accessibility UI: timeline context, Start Here hint, fallback Today title/body,
Still Counts rationale and hint, saved-progress label, settlement relationship,
History availability and record prefix, return hint, interruption title,
review receipt/history detail, commit/cancel hints, open/close navigation labels,
navigation command summary, and current/proposed/settled/interrupted semantic
state labels. Semantic fixture objects continue to own their own titles, times,
states, receipt text, and recovery-choice text.

The English, Arabic Saudi, and long-LTR fixtures populate every field. Views do
not own new user-visible English literals. The only English permitted in Arabic
stress is the deliberate mixed-direction identity `Ambitions S10`.

A package source guard rejects user-facing literals in B02 views; identifiers,
command IDs, SF Symbol names, and locale identifiers are the only literal
exceptions. A host UI test enumerates all Arabic labels and rejects Latin
letters after removing the approved mixed-direction identity.

Full Day records its origin as initial or returned Today. Initial Full Day may
open only the source-backed primary Step, retaining Full Day beneath it. Returned
Full Day is entirely read-only: neither the settled Step nor the revealed Step
can re-enter the Still Counts journey. Returned-origin validation asserts the
revealed Start Here owns Now while the nursery Step remains settled and
subordinate. Back restores the exact origin phase and focus.
