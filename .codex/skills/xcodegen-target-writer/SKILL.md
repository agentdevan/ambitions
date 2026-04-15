---
name: xcodegen-target-writer
description: Safely edit Ambitions `project.yml` and related plist, entitlements, bundle ID, dependency, resource, and test target wiring for new iOS targets or target changes. Use when adding or modifying app targets, test bundles, WidgetKit targets, Share extensions, App Intents support, capabilities, or shared configuration through XcodeGen; do not use for general SwiftUI feature work that does not require target or build-graph changes.
---

# XcodeGen Target Writer

## Purpose

Make target-level changes through `project.yml` without breaking existing Ambitions target conventions, bundle wiring, or validation flow.

## When To Use

- Adding a new target or editing an existing one in `project.yml`.
- Wiring widgets, extensions, intents, test bundles, resources, or entitlements.
- Updating bundle identifiers, dependencies, Info.plist paths, or target-specific sources.

## When Not To Use

- The task is only feature code inside an existing target.
- The user wants generic Xcode advice with no repo change.
- The request should be handled by `ios-extension-builder`, which should still route target edits back through this skill.

## Required Inputs

- The requested target or capability change.
- The current `project.yml`.
- Existing target folders, plist files, entitlements, and extension directories.

## Execution Steps

1. Inspect current target patterns in `project.yml` before editing anything.
2. Identify whether the new work belongs in:
   - `Ambitions`
   - `AmbitionsWidgetExtension`
   - a new extension target
   - an existing test bundle
3. Mirror current conventions for:
   - `type`
   - `platform`
   - deployment target
   - source and resource paths
   - `INFOPLIST_FILE`
   - `CODE_SIGN_ENTITLEMENTS`
   - bundle ID naming
   - scheme inclusion
4. Verify whether supporting files already exist. If plist, entitlements, or target directories are missing, create only what is required.
5. Check dependencies and shared-source usage carefully. Prefer reusing extension-safe contracts like `ExternalSurfaceSnapshotContracts` instead of exposing app internals directly.
6. Confirm testability. Decide whether unit or UI test coverage or manual-test notes need updates.
7. Regenerate and validate through the repo’s actual XcodeGen/build path when possible.

Use the checklists in `templates/`:

- `templates/extension-target-checklist.md`
- `templates/plist-entitlements-checklist.md`

## Output Format Expectations

When summarizing the work, report:

1. target change made
2. files added or updated
3. plist/entitlement/capability impact
4. validation run
5. any remaining manual Xcode or simulator checks

## Validation Requirements

- Confirm `project.yml` remains structurally consistent with existing targets.
- Run `xcodegen generate` after meaningful target changes when the toolchain is available.
- Prefer at least a build validation after changing sources, dependencies, or capabilities.
- Call out any Apple-only manual validation that could not be run locally.

## Ambitions-Specific Guardrails

- Do not rely on a checked-in `.xcodeproj`; `project.yml` is the source of truth.
- Avoid arbitrary target sprawl. New targets must have a clear product surface and validation path.
- Keep bundle IDs aligned with existing naming such as `com.ambitions.ios` and `com.ambitions.ios.widgetextension`.
- Preserve the existing pattern where extension code reads exported contracts or shared snapshot files instead of app-only repositories.
- Re-check docs before trusting them. Some older docs in this repo are historical and may lag current target state.

## Trigger Phrases

- `add a new target`
- `wire a widget extension`
- `update XcodeGen for intents`
- `add plist and entitlements for this extension`
