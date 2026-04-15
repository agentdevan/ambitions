# Eval Prompt 02: xcodegen-target-writer

## Prompt

Add a new App Intents-capable extension target and wire its plist and entitlements through XcodeGen using current Ambitions conventions.

## Success Looks Like

- Inspects existing `project.yml` targets first.
- Touches `project.yml` plus only the supporting plist/entitlement/target files actually needed.
- Notes dependency, bundle ID, and validation impact.

## Common Failure Patterns

- Edits a generated `.xcodeproj` instead of `project.yml`.
- Adds arbitrary target sprawl without checking existing extension patterns.
- Skips plist or entitlement updates.

## Files That Should Probably Be Touched

- `project.yml`
- new or existing extension `Info.plist`
- new or existing entitlements file

## Should Not Touch By Default

- planner/domain files
- unrelated feature screens
