# Docs Status

This folder contains current native-shipping documentation plus a small set of retained reference notes that still apply to the SwiftUI codebase.

## Canonical planning stack

Use [codex/CONTEXT_INDEX.md](codex/CONTEXT_INDEX.md) for source-of-truth precedence before non-trivial work.

- [../MASTER_PRODUCT_SPEC.md](../MASTER_PRODUCT_SPEC.md)
  Current shipping product truth.
- [canon/Ambitions_OS_Master_Roadmap.md](canon/Ambitions_OS_Master_Roadmap.md)
  Platform and endgame vision.
- [canon/Ambitions_Surgical_Execution_Plan.md](canon/Ambitions_Surgical_Execution_Plan.md)
  Execution order and dependency hierarchy.
- [canon/Ambitions_Codex_Batch_Plan.md](canon/Ambitions_Codex_Batch_Plan.md)
  Batching and work packaging.
- [codex/BATCH_REGISTRY.md](codex/BATCH_REGISTRY.md)
  Active work status only.

Older docs in this folder are supporting context and do not override the canonical planning stack.

## Current shipping native docs

- [native-build-and-release.md](native-build-and-release.md)
  Native source-of-truth build, test, archive, and CI validation guidance for the current SwiftUI iOS app.
- [codex/BATCH_REGISTRY.md](codex/BATCH_REGISTRY.md)
  Current batch status for active Ambitions work.
- [rc1-native-finish-pass.md](rc1-native-finish-pass.md)
  Historical native polish/release-candidate notes that still describe the current native app direction accurately where not superseded by newer build/release docs.
- [implementation-backlog.md](implementation-backlog.md)
  Supporting backlog translation aligned to the live native codebase where it does not conflict with the canonical planning stack.

## Other reference docs

- [goal-engine-contract-notes.md](goal-engine-contract-notes.md)
  Goal-engine contract and planning notes.

## Repo truth

- The current shipping app is the native SwiftUI target under `Native/Ambitions/`.
- The native SwiftUI app is the source of truth.
- The current shipped native surface is local-first and on-device first.
- Today quick capture persists to the native Captures tab.
- Notification scheduling and calendar/reminders are wired in the native app.
- Widget and Live Activity foundations exist in the repo, but they still require separate validation before they should be described as fully verified shipping behavior.
- Sync, auth, and account deletion backend flows are not current shipping features.
