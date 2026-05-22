# IOS26-T01-B03 Availability Cleanup

- Batch: `IOS26-T01-B03`
- Starting commit: `65551adce42bd9d5bf1f254deae4a23c5456abea`
- Scope: remove availability branches made impossible by the iOS 26 minimum without changing runtime behavior

## Files changed

- `Native/AmbitionsWidgetExtension/AmbitionsWidgetBundle.swift`
- `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`
- `Sources/Components/MotionPrimitives.swift`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`

## Edits made

- Removed the `if #available(iOS 16.1, *)` wrapper around `NextStepLiveActivityWidget()` and kept the widget in the bundle unconditionally.
- Removed the obsolete `@available(iOS 16.1, *)` annotation from `NextStepLiveActivityWidget`.
- Removed the iOS 17/macOS 14 fallback branch from `ambitionHaptic(...)` and the corresponding helper availability annotation.
- Removed the iOS 17 fallback branches in EventKit authorization requests and kept the full-access / write-only APIs only.

## Validation commands

- `grep -RIn "#available\|@available\|if #available" Native Sources AppUI 2>/dev/null || true`
- `xcodegen generate`
- `scripts/build-local.sh`
- `make xcode-focused-test BATCH=IOS26-T01-B03 TEST=AmbitionsTests/AppReleaseConfigurationTests`

## Validation status

- Grep: passed with no remaining matches in the targeted source trees
- XcodeGen: passed
- Local build: passed
- Focused test: passed

## Phase 04 repair-pass validation

- `grep -RIn "#available\|@available\|if #available" Native Sources AppUI 2>/dev/null || true`: passed with no remaining matches in the targeted source trees.
- `xcodegen generate`: passed and regenerated `Ambitions.xcodeproj` locally from `project.yml`.
- `scripts/build-local.sh`: passed with fresh log `output/logs/build-local-20260522-082853.log`.
- `make xcode-focused-test BATCH=IOS26-T01-B03 TEST=AmbitionsTests/AppReleaseConfigurationTests`: passed; summary `.codex/xcode-summaries/IOS26-T01-B03/20260522T123024Z/focused-test-summary.json`; result bundle `.codex/xcode-results/IOS26-T01-B03/20260522T123024Z/focused-test.xcresult`.

## Pass/fail

- Pass: scope stayed inside the approved compatibility-cleanup boundary.
- Pass: no route aliases, IA, dependencies, privacy manifest, entitlements, or top-level product seams were changed.
- Pass: removed impossible availability branches without changing the visible behavior path under the iOS 26 minimum.
- Pass: the local build log completed successfully.
- Pass: the focused wrapper test completed successfully.

## No-claim boundary

- This report does not claim release readiness, accessibility proof, device proof, or full test coverage.
- This report only records the bounded availability cleanup and the intended validation path.
