# FCP08 Ambition Meridian Shell Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete Green on 2026-05-05
Train: FCP Flagship Completion
Owner: App shell / navigation
Type: Implementation

## Purpose

Promote the existing feature-flagged Ambition Meridian Shell into the default
shell presentation while preserving native rollback, canonical five-destination
topology, and route ownership.

FCP08 must deepen the shell as a navigation/trust/context layer. It must not
create a sixth tab, hide navigation, rewrite routes, add persistence, add
runtime intelligence, or claim release/accessibility proof.

## Source Truth

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Ambition_Meridian_Shell_SwiftUI_Build_Spec.md`
- `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md`
- `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`

## Allowed Files

- `Native/Ambitions/App/AppShellPresentationMode.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md`
- `docs/audits/fcp08-ambition-meridian-shell-report.md`
- global order, registry, context, and run-state docs needed to record batch truth

## Forbidden Files

- `AppTab.swift` raw values or canonical tab order unless a hard blocker appears
- external route, widget, App Intent, Live Activity, persistence, schema, sync,
  auth, network, AI, LDI runtime, CI, signing, entitlement, workflow, dependency,
  or release/legal/privacy claim files

## Acceptance

- Meridian is the default shell presentation.
- `--ambitions-shell=native` remains a tested rollback path.
- Five canonical destinations remain Today, Goals, Capture, Plan, You.
- Meridian exposes a compact shell-chrome contract for destination rail,
  receipt overlay zone, global action, safe-area posture, and rollback.
- No route ownership moves into the shell.
- No generic dashboard, sci-fi command center, AI command button, or hidden
  navigation is introduced.

## Validation

- `xcodegen generate`
- focused `AppShellNavigationTests` and `AppShellChromeTests`
- `scripts/build-local.sh`
- CQS advisory scans
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
