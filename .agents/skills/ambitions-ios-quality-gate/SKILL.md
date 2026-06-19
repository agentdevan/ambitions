---
name: ambitions-ios-quality-gate
description: Use for Ambitions native iPhone source/UI changes that need Apple Platform Source Atlas review, build, accessibility, visual, safe-area, keyboard, Dynamic Type, Reduce Motion, privacy/permission, and proof discipline.
---

# Ambitions iOS Quality Gate

This skill is operating support only. Product truth lives in `docs/truth/*`. It does not override product canon, release truth, live source, current tests, current logs, or current Xcode evidence.

## Required Source Map

Before touching SwiftUI, UIKit interop, SwiftData or local persistence, App Intents, WidgetKit, Live Activities, notifications, BackgroundTasks, LocalAuthentication, privacy, permissions, accessibility, Human Interface Guidelines aligned behavior, iOS design resources, shell chrome, keyboard behavior, or design-system primitives, read:

1. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
2. `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`
3. relevant live source, tests, `project.yml`, `Package.swift`, entitlements, Info.plist, scripts, and current logs

`PRODUCT_DESIGN_TRUTH.md` is product canon. `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md` is the iOS implementation source map. If they conflict, product canon wins.

If `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md` is missing during Apple-platform work, stop and close Blocked or Yellow with the missing-source reason. Do not guess Apple API behavior from memory.

## Required Posture

- Preserve native SwiftUI architecture and XcodeGen.
- Verify active source ownership before source edits.
- Keep root surfaces to Today / Goals / Time / You.
- Treat Capture as global composer and Motion as behavior.
- Use focused build/test validation first, then broader validation when risk warrants it.
- Verify iOS 26 availability before adopting an Apple API.
- Do not introduce APIs above the Ambitions minimum deployment target unless availability-gated and the iOS 26 path preserves the same user-facing behavior.
- Prefer Apple-native components and platform behavior where they serve Ambitions product law.
- Use UIKit interop only when SwiftUI cannot safely deliver the required shell, keyboard, input, accessibility, rendering, or navigation behavior.
- Keep local-first/offline core behavior intact.
- Do not claim accessibility, visual, device, TestFlight, App Store, privacy/legal, performance, CI, account, R2, or release readiness without current proof.

## Apple Platform Enforcement

For every Apple API, framework, sample-code pattern, design-resource dependency, or HIG behavior used in the train, record:

- Apple Platform Source Atlas section consulted
- reason the API/pattern belongs in Ambitions
- iOS 26 availability status
- fallback path when availability is limited
- permission/privacy impact
- accessibility impact
- validation command or explicit not-run reason

The Apple Platform Source Atlas does not authorize broad feature expansion. It is a source map for implementing approved Ambitions behavior natively.

## Native iPhone Quality Gates

Any source/UI train that changes visible behavior must check:

- safe area and status bar behavior
- keyboard choreography
- root dock visibility and drilldown hiding
- Dynamic Type behavior
- VoiceOver order and accessible actions
- Reduce Motion fallback
- Reduce Transparency fallback where materials/glass are used
- contrast and legibility
- screenshot proof or explicit not-run reason
- no duplicate native/custom chrome artifacts
- no content hidden behind shell chrome

## Expected Evidence

- source paths touched
- Apple Platform Source Atlas sections consulted
- Apple APIs/frameworks/patterns used
- iOS 26 availability notes
- focused build/test commands and exit codes
- screenshot or explicit not-run reason for UI changes
- accessibility/non-claim notes where relevant
- privacy/permission notes where relevant
- rollback path
