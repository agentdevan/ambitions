# Widget + Live Activity Manual Testing

This checklist covers the productized widget and Live Activity surfaces that are currently described as `Productized in this build, platform review still required`.

## Prerequisites
1. Regenerate the Xcode project:
   - `xcodegen generate`
2. Open the generated project/workspace in Xcode.
3. Run `Ambitions` on an iOS 17+ simulator.
4. Ensure notification permission is granted (Live Activity visibility often rides with notification settings).

## Shared Snapshot Verification
1. In app, create or update a goal/step so snapshot refresh runs.
2. Confirm shared snapshot exists:
   - App Group container: `group.com.ambitions.shared/ExternalSnapshots/external-snapshot.v1.json`
3. Confirm payload includes `nextAction.goalID`, `nextAction.stepID`, `ambientState`, and `continuity`.

## Widget Verification
1. Add the `Next Step` widget from `AmbitionsWidgetExtension` to Home Screen.
2. Confirm widget renders:
   - Today, Focus, Goal, and Plan ambient hierarchy when snapshot has `ambientState`
   - fallback empty state when no next action
3. Confirm small, medium, and large Home Screen widgets remain glanceable and avoid mini-dashboard density.
4. Confirm Lock Screen inline, circular, and rectangular widgets fit and preserve local-first continuity language.
5. Tap widget:
   - should deep-link via `ambitions://goal/{goalID}?origin=widget`
   - app should route through existing external router to Goal Detail.

## Live Activity Verification
1. Trigger goal/today mutation that refreshes snapshot scheduling path.
2. Confirm a Live Activity appears as bounded focus/execution continuity on Lock Screen / Dynamic Island.
3. Confirm updating the exported snapshot updates title, detail, lease, sync-health, and pressure content.
4. Tap `Return to Ambitions`:
   - should deep-link via `ambitions://goal/{goalID}?origin=live_activity`
   - app should route to Goal Detail.
5. Confirm stale activity state uses the bounded stale date behavior and does not imply permanent current truth.
6. Clear next-action context (or no actionable steps):
   - existing activity should end.

## Notes
- Widget and Live Activity are ambient execution surfaces backed by the shared external snapshot contract.
- They consume only the exported snapshot contract, not app repositories/services directly.
- Do not promote widget or Live Activity wording beyond platform-review-required language until this checklist passes on the intended real-device band.

## April 23, 2026 Closeout Audit
- Verified app-side handoff routes on iPhone 17 simulator:
  - `ambitions://tab/plan?origin=widget` landed on Plan.
  - `ambitions://tab/today?origin=notification` landed on Today.
  - `ambitions://tab/today?origin=live_activity` landed on Today.
- Verified simulated push transport accepted a category payload for `com.ambitions.ios`, but no banner or Notification Center card appeared during the simulator pass.
- Blocked here: this `simctl` runtime exposes no widget/Lock Screen placement command, so Home Screen widget placement, Lock Screen widget rendering, and Dynamic Island / Live Activity visual behavior remain release/platform review items.
- Required release/platform review items: Home Screen widget placement/rendering, Lock Screen widget rendering, notification banner / Notification Center UI, Live Activity / Dynamic Island visuals, and Live Activity stale behavior.
