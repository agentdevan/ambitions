# Local Notification Simulator Testing

## Scope
- Verifies local notification foundation only.
- No backend sync or remote push is involved.

## Prerequisites
- Build and run `Ambitions` on an iOS Simulator from Xcode.
- Ensure the app is launched at least once so categories are registered at startup.

## 1) Opt-in authorization (manual)
1. In the running app debug session, pause and run this in LLDB:
   - `expr -l Swift -- await NotificationRuntime.shared.bootstrapper?.requestNotificationAuthorizationOptIn()`
2. Accept the notification permission alert in the simulator.
3. Confirm permission in `Settings > Notifications > Ambitions`.

## 2) Create schedulable state
1. Create or open a goal with an actionable step.
2. Trigger an action that refreshes snapshot + notification schedule (for example `Complete`, `Delay`, or `Create Goal`).
3. Wait for the scheduled notification interval (soon = ~5 minutes, overdue = ~1 minute).

## 3) Validate actions
1. Tap `Open`:
   - Expect route to Goal Detail for the notification `goalID`.
2. Tap `Snooze`:
   - Expect existing Today `delay` semantics to run, then routing through external router.
3. Tap `Complete`:
   - Expect existing Today `complete` semantics to run, then routing through external router.

## 4) Debugging tips
- Reset simulator notification permissions:
  - `xcrun simctl privacy booted reset notifications`
- Clear pending notifications:
  - `xcrun simctl notification booted clear`
- If no notification appears, verify:
  - authorization granted
  - snapshot file exists (`ExternalSnapshots/external-snapshot.v1.json`)
  - current snapshot has `nextAction`
