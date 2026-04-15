# Docs Status

This folder contains a mix of current native-shipping documentation, historical reference material, and future-work planning.

## Current shipping native docs

- [native-build-and-release.md](/Users/Devan/Documents/GitHub/ambitions/docs/native-build-and-release.md)
  Native source-of-truth build, test, archive, and CI validation guidance for the current SwiftUI iOS app.
- [rc1-native-finish-pass.md](/Users/Devan/Documents/GitHub/ambitions/docs/rc1-native-finish-pass.md)
  Historical native polish/release-candidate notes that still describe the current native app direction accurately where not superseded by newer build/release docs.
- [implementation-backlog.md](/Users/Devan/Documents/GitHub/ambitions/docs/implementation-backlog.md)
  Current roadmap-to-backlog translation aligned to the live native codebase.

## Historical backend or pre-native docs

- [auth-qa-flow.md](/Users/Devan/Documents/GitHub/ambitions/docs/auth-qa-flow.md)
  Historical Supabase-auth QA notes from an earlier backend-connected workflow. Not part of the currently shipped native app.
- [phase14.2-live-auth-sync.md](/Users/Devan/Documents/GitHub/ambitions/docs/phase14.2-live-auth-sync.md)
  Historical live-auth/live-sync activation notes for an earlier implementation path. Not active in the current native codebase.
- [phase14-supabase.sql](/Users/Devan/Documents/GitHub/ambitions/docs/phase14-supabase.sql)
  Historical Supabase SQL companion file for the older sync work.
- [phase28-account-deletion.md](/Users/Devan/Documents/GitHub/ambitions/docs/phase28-account-deletion.md)
  Historical account-deletion status notes for the older backend-connected path. Not a current native feature.
- [premium-modular-goal-engine-audit-plan.md](/Users/Devan/Documents/GitHub/ambitions/docs/premium-modular-goal-engine-audit-plan.md)
  Historical architecture plan written against the older Expo/React Native codebase assumptions.

## Other reference docs

- [goal-engine-contract-notes.md](/Users/Devan/Documents/GitHub/ambitions/docs/goal-engine-contract-notes.md)
  Goal-engine contract and planning notes.

## Repo truth

- The current shipping app is the native SwiftUI target under `Native/Ambitions/`.
- The current shipped native surface is local-first and on-device only.
- Account sync, live backend auth, and backend-driven account deletion are not current native shipping features.
