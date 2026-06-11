# UIQL-007 Repair Reframe Report

Status: Repair reframe complete
Issue: UIQL-007 - Motion / Motion Current quality gate
Program: UIQL

## Trigger

UIQL-007 required more than three repair cycles. The initial Motion screenshot showed a product Red: the dock/mask area covered Motion source/proof/receipt/control text, which made the first viewport unreadable and unfit for UIQL closeout.

Additional validation friction came from stale or unreliable focused selector paths:

- early concurrent focused unit selectors produced zero-test evidence
- a new standalone UI test selector compiled but returned zero executed tests through the focused wrapper

## Reframe

The repair was reframed from "add a Motion UI test" to "make Motion Current own the first viewport and prove it through stable existing selectors." The final proof path uses:

- current visual evaluation of the final Motion screenshot
- compact Source / Proof / Receipt facts for the non-accessibility first viewport
- preserved vertical proof trace lines for accessibility Dynamic Type sizes
- rebuilt focused Motion unit tests
- folded Motion fact assertions inside the already discoverable canonical five-tab shell UI test

## Repairs Applied

- Removed the opaque bottom safe-area mask and bottom overlay from Motion.
- Added clear bottom and section clearance so the native dock does not cover first-viewport text.
- Moved user-control copy above Source / Proof / Receipt facts.
- Shortened empty-state source/receipt/control copy so it stays inspectable in a compact first viewport.
- Kept Source / Proof / Receipt as accessibility identifiers and accessibility labels/values.
- Rejected stale dock-mask color patterns in the Motion object-stage primitive test.
- Reused the canonical five-tab shell UI test for Motion fact visibility proof.

## Final Gate

Green:

- Motion Current is the visible primary object.
- Source / Proof / Receipt facts are visible and UI-tested.
- Dock no longer masks Motion Current text.
- No visible Pulse, dashboard, score, streak, analytics/feed, or task-list anatomy in the scoped proof path.
- Focused build, unit, UI, banned-copy, card-anatomy, and mini-regression gates passed.

Yellow:

- Xcode wrapper `.xcresult` warnings remain a tooling limitation.
- Earlier zero-test selector logs remain repair evidence only.
- Linear issue lookup remains unavailable through the current connector.

Red:

- None for UIQL-007 scoped product closeout.

## Rollback

If UIQL-007 must be reverted, revert the closeout commit and rerun UIQL preflight plus the Motion focused tests. The most sensitive rollback points are the Motion bottom safe-area/mask change and the folded canonical shell UI assertions.

## Non-Claims

This reframe does not claim full accessibility certification, device proof, performance proof, owner approval, release readiness, TestFlight readiness, App Store readiness, or completion of UIQL-008+.
