---
name: ios-extension-builder
description: Build or modify Ambitions iOS extension surfaces for WidgetKit, Live Activities, Share extensions, and App Intents using the repo's current native patterns. Use when a request involves adding a widget, Share extension, App Intent, or Live Activity; start with a plan for risky extension work, route any target-level wiring through `xcodegen-target-writer`, and finish with `ios-qa-regression-checker`; do not use for plain in-app SwiftUI work with no extension or OS-surface component.
---

# iOS Extension Builder

## Purpose

Implement extension-facing work in Ambitions without bypassing target wiring, extension safety, app groups, deep links, or snapshot/export constraints.

## When To Use

- The user asks to add a widget.
- The user asks to build a Share extension.
- The user asks for App Intents or Siri/Shortcuts support.
- The user asks to add or change a Live Activity.

## When Not To Use

- The work is only in-app routing or feature UI.
- The task is only a `project.yml` edit with no extension implementation detail; use `xcodegen-target-writer` directly.
- The user wants speculative extension design without repo grounding.

## Required Inputs

- Requested extension type.
- Current extension-safe models/contracts.
- Existing extension folders, snapshot exports, routing, plist, entitlements, and docs.

## Execution Steps

0. If the extension work is new, multi-file, or seam-uncertain, require a plan first via `phase-executor` or `extension-plan.md`.
1. Determine the requested surface:
   - WidgetKit
   - Live Activity / ActivityKit
   - Share extension
   - App Intents
2. Inspect existing repo patterns first:
   - `Native/AmbitionsWidgetExtension/`
   - `Native/Ambitions/ExternalSnapshots/`
   - `Native/Ambitions/App/AppExternalRouting.swift`
   - current Info.plist and entitlements
3. Route target-level edits through `xcodegen-target-writer`. Do not hand-edit target sprawl without checking current XcodeGen conventions.
4. Choose the first safe slice. If the repo seam is not ready for full runtime support, stop at target/config planning or shared-model preparation rather than faking a complete extension.
5. Keep extension code extension-safe:
   - no direct app-only repository access
   - no unsafe dependency on live app container state
   - use shared contracts, app groups, deep links, and snapshot readers/writers where appropriate
6. Verify required supporting pieces:
   - app groups
   - bundle IDs
   - entitlements
   - NSExtension or widget plist keys
   - deep-link routing
   - manual-test notes
7. Retry only with narrower config or shared-model fixes when a step fails. Do not widen into unrelated app rewrites.
8. Stop when the remaining request depends on a missing app-side seam, entitlement setup you cannot verify here, or unsupported runtime assumptions.
9. Note the validation path. For widgets and Live Activities, include manual simulator or device checks in addition to build validation.

## Skill Chaining

- Use `phase-executor` first when the extension seam or architecture is uncertain.
- Route target/config edits through `xcodegen-target-writer`.
- Use `capture-flow-implementer` if the extension feeds the capture domain.
- Use `ios-qa-regression-checker` after implementation.

## Failure Recovery

- If the request really needs only target wiring, switch to `xcodegen-target-writer`.
- If the underlying in-app action or capture seam does not exist yet, stop short of inventing unsupported runtime behavior and say what is missing.
- If manual extension validation cannot run here, separate config support from runtime support explicitly.

Use the templates in `templates/` to keep implementation and review grounded:

- `templates/widgetkit-template.md`
- `templates/live-activity-template.md`
- `templates/share-extension-template.md`
- `templates/app-intents-template.md`

## Output Format Expectations

When reporting work, summarize:

1. extension type implemented
2. target/config changes
3. code paths added or changed
4. deep-link/app-group/entitlement impact
5. build validation and manual validation notes

## Validation Requirements

- Regenerate the project after target changes when possible.
- Run the relevant build/test flow for affected targets.
- For widgets and Live Activities, include manual checks from `docs/widget-live-activity-manual-testing.md` if the environment allows.
- For Share extensions and App Intents, document any simulator/device steps that cannot be automated.

## Ambitions-Specific Guardrails

- Prefer the existing snapshot/export boundary for external surfaces.
- Reuse `AppExternalRoute`, `AppExternalRouteTranslator`, and deep links instead of inventing extension-only navigation.
- Keep the main app and extensions aligned on app group and bundle ID decisions.
- Do not expose unsupported shortcuts or share flows before the underlying capture or action path exists in the app.
- Extension work should feel additive to the current local-first native app, not like a parallel architecture.

## Trigger Phrases

- `add widget`
- `build share extension`
- `add App Intent`
- `create Live Activity`
