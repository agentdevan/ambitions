# Docs Status

This folder contains the current Swift-native documentation for the Ambitions repo.

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
- [canon/Ambitions_Full_Frontend_Transformation_Program.md](canon/Ambitions_Full_Frontend_Transformation_Program.md)
  Post-hardening frontend transformation canon. Use with the registry; do not treat it as active work by itself.
- [canon/Ambitions_State_Continuity_Mesh.md](canon/Ambitions_State_Continuity_Mesh.md)
  Canonical State Continuity Mesh contract for Now State Lease, Continuity Receipts, Sync Health Strip, semantic conflict language, provenance-preserving handoff/return, degraded-sync states, and local-first plus Apple-account-based sync launch truth.
- [canon/Ambitions_App_Store_Release_Compliance.md](canon/Ambitions_App_Store_Release_Compliance.md)
  Canonical App Store release-compliance and final submission-gate truth after the transformation program closes.
- [canon/Ambitions_Launch_Master_Checklist.md](canon/Ambitions_Launch_Master_Checklist.md)
  Canonical launch-planning layer for locked launch strategy, launch doctrine, tracks, and now-to-launch phases. It supplements the roadmap and release-compliance canon without replacing them.
- [canon/Ambitions_Accessibility_Nutrition_Labels_Audit.md](canon/Ambitions_Accessibility_Nutrition_Labels_Audit.md)
  Canonical accessibility-label audit artifact for honest, device-specific launch accessibility claims.
- [canon/Ambitions_Product_Addendum_Continuity_Reality_Execution.md](canon/Ambitions_Product_Addendum_Continuity_Reality_Execution.md)
  Supporting canon addendum for top-level surface questions, mobile provenance, and consolidated platform-pillar language after Batch 48. Use as shorthand only; do not treat it as a parallel master roadmap.
- [canon/Ambitions_Frontend_Batches_49_60_Revised.md](canon/Ambitions_Frontend_Batches_49_60_Revised.md)
  Supporting canon queue note for the revised queued Batch 49-60 frontend sequence. Registry status and the master transformation program still govern execution.
- [canon/design/README.md](canon/design/README.md)
  Canonical future frontend design-truth set for shell IA, screen architecture, motion, trust UX, copy, external surfaces, and cross-device roles.
- [canon/design/Ambitions_Frontend_Transformation_Execution_Classification.md](canon/design/Ambitions_Frontend_Transformation_Execution_Classification.md)
  Canonical future frontend execution-tiering source for early-core, later-core, and optional-experimental systems and surface programs.
- [codex/BATCH_REGISTRY.md](codex/BATCH_REGISTRY.md)
  Active work status only.
- [codex/batches/README.md](codex/batches/README.md)
  Per-batch execution docs for the post-hardening frontend transformation program.

Older docs in this folder are supporting context and do not override the canonical planning stack.

## Current shipping native docs

- [native-build-and-release.md](native-build-and-release.md)
  Native source-of-truth build, test, archive, and CI validation guidance for the current SwiftUI iOS app.
- [codex/Launch_Operator_Runbook.md](codex/Launch_Operator_Runbook.md)
  Short operator runbook for App Store Connect, TestFlight, metadata, reviewer notes, and launch-day operations.
- [codex/Release_Candidate_Review_Checklist.md](codex/Release_Candidate_Review_Checklist.md)
  Short operator checklist for final release-candidate review, reviewer access, privacy/disclosure, and App Store submission prep.
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
- The repo no longer carries an active TypeScript / Expo / React Native runtime path.
- The current shipped native surface is local-first and on-device first.
- Today quick capture persists to the native Captures tab.
- External routes are registered and shell-validated for canonical Plan and Captures inbox entry points.
- Notifications: Available in this build, manual verification still required.
- Widgets and Live Activity: Available in this build, manual verification still required.
- Navigation-only App Intents: Available in this build, manual verification still required.
- Share Extension: Not shipped in this build.
- Sync, auth, and account deletion backend flows are not current shipping features.
- Launch planning and submission operations now have dedicated docs under `docs/canon/` and `docs/codex/`; they supplement but do not replace the roadmap or compliance canon.
