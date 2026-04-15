# Docs Status

This folder contains current native-shipping documentation plus a small set of retained reference notes that still apply to the SwiftUI codebase.

## Current shipping native docs

- [native-build-and-release.md](native-build-and-release.md)
  Native source-of-truth build, test, archive, and CI validation guidance for the current SwiftUI iOS app.
- [rc1-native-finish-pass.md](rc1-native-finish-pass.md)
  Historical native polish/release-candidate notes that still describe the current native app direction accurately where not superseded by newer build/release docs.
- [implementation-backlog.md](implementation-backlog.md)
  Current roadmap-to-backlog translation aligned to the live native codebase.

## Other reference docs

- [goal-engine-contract-notes.md](goal-engine-contract-notes.md)
  Goal-engine contract and planning notes.

## Repo truth

- The current shipping app is the native SwiftUI target under `Native/Ambitions/`.
- The native SwiftUI app is the source of truth.
- The current shipped native surface is local-first and on-device first.
- Notifications, widgets, Live Activities, and calendar/reminders are available as native device features.
- Sync, auth, and account deletion backend flows are not current shipping features.
