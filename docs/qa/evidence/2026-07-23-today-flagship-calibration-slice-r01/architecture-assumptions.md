# Architecture-sensitive assumptions

## Snapshot adapter

Views consume immutable `TodayFlagshipCalibrationContent` snapshots. The
synthetic fixture creates those snapshots but owns no product policy and is not
a runtime. A future runtime adapter must construct the same contract without
changing view anatomy.

## Stable Step scope

This first slice uses one canonical Step because current canon and source
support its inspection, closure, Proof, Receipt, History, recovery, and inverse
constraints. It does not establish every future Start Here object as a Step.

## Mutation ownership

Today initiates review, but the Foundry view contains no production mutation or
persistence logic. `TodayFlagshipJourneyState` is a fixture-host state machine
used to prove semantic phases. Canonical production ownership remains outside
this package.

## Review presentation

Consequential review uses a native full-screen presentation. That is the
narrowest truthful choice after inspecting the current full-screen
consequential-review and object-scoped recovery patterns: it preserves exact
identity and cancellation without reducing the mutation to an alert. Recovery
review uses a native large sheet because interruption belongs to the affected
Step, not the whole product.

## Navigation and focus

Focused Step depth uses `NavigationStack` and native Back. The Today return
anchor is a stable semantic ID, not a screen coordinate. After settlement,
native Back is not the return contract; the explicit `Return to Today` action
projects the settled object and new eligible Start Here. Accessibility focus is
routed by semantic anchors, but direct-device VoiceOver restoration remains
open.

## Crown and scroll ownership

The compact matte crown sits above the single Today `ScrollView`. A real dense
scroll exposed status-area overlap when crown and content shared one scrolling
stack. Separating them preserves root orientation and safe-area readability
without inventing custom scroll physics. Exact future collapse thresholds remain
unfrozen.

## Settlement timing

The 1.2-second host delay and recorded phase pauses are synthetic evaluation
timing only. They imply no production latency, persistence, network, or replay
guarantee.

## Receipt, History, inverse, and recovery

Receipt and History appear only for this source-backed `Still counts` contract.
No inverse action is shown because the fixture does not prove every required
revision/dependency condition. Recovery exposes only two fixture-valid choices
and preserves accepted truth when dismissed.

## Time ownership and device ceiling

Today shows temporal relationship; it does not mutate chronology. Exact Time
placement remains Time-owned. Simulator and preview evidence do not complete
safe-area, edge-gesture, focus, assistive-input, low-brightness, or device proof.
