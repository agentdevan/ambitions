# Widget + Live Activity Manual Testing

This checklist is the Batch 36 manual validation bar for external surfaces that are currently described as `Available in this build, pending Batch 36 validation`.

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
3. Confirm payload includes `nextAction.goalID` and `nextAction.stepID`.

## Widget Verification
1. Add the `Next Step` widget from `AmbitionsWidgetExtension` to Home Screen.
2. Confirm widget renders:
   - `Next step ready` when snapshot has `nextAction`
   - fallback empty state when no next action
3. Tap widget:
   - should deep-link via `ambitions://goal/{goalID}`
   - app should route through existing external router to Goal Detail.

## Live Activity Verification
1. Trigger goal/today mutation that refreshes snapshot scheduling path.
2. Confirm a Live Activity appears (`Next step active`) on Lock Screen / Dynamic Island.
3. Tap `Open in Ambitions`:
   - should deep-link via `ambitions://goal/{goalID}`
   - app should route to Goal Detail.
4. Clear next-action context (or no actionable steps):
   - existing activity should end.

## Notes
- Widget and Live Activity are read-only surfaces.
- They consume only the exported snapshot contract, not app repositories/services directly.
- Do not promote widget or Live Activity wording from pending validation to validated until this checklist passes.
