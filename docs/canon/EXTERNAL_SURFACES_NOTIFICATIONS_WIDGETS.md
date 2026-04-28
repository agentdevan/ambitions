# Ambitions External Surfaces, Notifications, Widgets, And Live Activities

Status: Active canon consolidation layer.

Purpose: Consolidate external-surface behavior, notification tone/frequency, widgets, Live Activities, App Intents, Shortcuts, privacy, receipt, and safe-action boundaries into one implementation-readable reference. This document reflects Wave 14 product decisions.

## Core External-Surface Doctrine

External surfaces should primarily:

```text
Surface the right next thing safely.
```

External-surface north star:

```text
Calm continuity.
```

External surfaces are not:

- engagement loops
- marketing surfaces
- full dashboards
- replacements for the app
- pressure systems

## Notifications

Notification frequency:

```text
Sparse by default.
User controls later.
```

Notification tone:

```text
Calm and operational.
```

Rules:

- Notifications should be rare, useful, and context-aware.
- Avoid fake urgency.
- Avoid motivational pressure.
- Avoid salesy language.
- Notification permission is requested only after reminder/protected-block value.
- Sensitive/private details collapse as `Private item` at launch.

## Widgets

Widgets should show:

```text
Best next action / Today slice.
```

Widgets should not show:

- full dashboard
- goal analytics
- motivation quote
- calendar clone
- sensitive details in plain text at launch

Rules:

- Widgets should provide calm continuity.
- Widgets should preserve privacy by default.
- Widgets should lead back to the right app context.
- Widget content should be compact and immediately understandable.

## Live Activities

Live Activities should show:

```text
Active focus/protected block or time-sensitive plan slice.
```

Live Activities should not show:

- everything happening today
- full goal list
- reviews
- dashboards
- non-time-sensitive clutter

Rules:

- Live Activities should be reserved for active or time-sensitive execution states.
- Live Activities should avoid fake urgency.
- Sensitive/private details collapse as `Private item` at launch.
- Live Activities should not replace Today or Plan.

## App Intents / Shortcuts

App Intents / Shortcuts should support:

```text
Capture.
```

Rules:

- Capture through App Intents/Shortcuts should preserve routing, receipts, and privacy boundaries.
- Captured input should not be lost.
- Low-confidence capture should route to Needs a Place or ask through supported system affordances.
- External capture should not expose sensitive details unnecessarily.

## Sensitive / Private Content

Sensitive/private details in notifications/widgets:

```text
Collapse as Private item at launch.
```

Rules:

- Do not expose sensitive Life Area details on external surfaces at launch.
- Use generic labels such as `Private item`.
- Do not claim Face ID/screenshot hiding/export exclusion unless implemented and verified.
- Sensitive details may be opened inside the app where privacy context can be handled.

## External-Surface Data Changes

External-surface data changes:

```text
Safe local actions with receipts are allowed.
External writes require app confirmation.
```

Rules:

- Safe local actions can happen if they produce receipts and have undo/correction where safe.
- External writes require app confirmation.
- Destructive actions require confirmation.
- Calendar writes require app confirmation.
- Memory deletion requires confirmation.
- Sensitive/high-impact memory creation requires confirmation.

## Receipts

External-surface actions should preserve Action Closure.

Receipts should explain:

- what happened
- where it went
- what remains safe
- how to correct or inspect where safe

Examples:

```text
Saved as Task · Today
Saved to Needs a Place
Private item updated
```

Rules:

- If the external surface cannot display full receipt safely, the app should show it on next open.
- Do not fake successful writes.
- Do not silently lose external input.

## External Surfaces Must Never

External surfaces must never:

```text
Expose private details.
Spam user.
Show fake urgency.
Replace core app context.
```

Additional red flags:

- notification tone feels alarmist
- widget becomes a dashboard
- Live Activity shows non-time-sensitive clutter
- shortcut action changes external data silently
- sensitive details appear on lock screen
- notification tries to motivate through shame

## QA Acceptance Criteria

External surfaces are acceptable when:

- They surface the right next thing safely.
- Notification behavior is sparse by default.
- Notification tone is calm and operational.
- Sensitive/private details collapse as `Private item` at launch.
- Widgets show best next action / Today slice.
- Live Activities show active focus/protected block or time-sensitive plan slice.
- App Intents / Shortcuts support capture.
- Safe local external-surface actions create receipts where meaningful.
- External writes require app confirmation.
- External surfaces do not expose private details, spam the user, show fake urgency, or replace core app context.
- The external-surface north star remains calm continuity.

## Open Questions For Future Waves

- Which notification categories ship first?
- Should widget variants include small/medium/large with different Today-slice density?
- What exact actions are safe from widgets without opening the app?
- Should Live Activities support protected blocks only at launch?
- How should external capture receipts appear when launched from Shortcuts/Siri?
