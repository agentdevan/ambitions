---
name: ambitions-ios-quality-gate
description: Use for Ambitions native iPhone source/UI changes that need Apple Platform Source Atlas review, build, accessibility, visual, safe-area, keyboard, Dynamic Type, Reduce Motion, privacy/permission, and proof discipline.
---

# Ambitions iOS Quality Gate

## Skill digest
- Use when: SwiftUI, Apple-platform, iOS design system, accessibility, shell, keyboard, permissions, persistence, widgets, or visual/product surface work is in scope.
- Do not use as: product canon, release proof, visual acceptance, or permission to skip Apple/source proof.
- Required first read: `docs/truth/CODEX_START_HERE.md`.
- Owns: Apple Platform Source Atlas routing, iOS 26 availability checks, native quality gates, Stage thinness, SwiftUI-native default, accessibility/proof checklist.
- Does not own: product canon, implementation status, Visual Green, Release Green, or App Store readiness.
- Hard red: Apple API guesswork, unsafe shell geometry, custom Stage/UIKit/rendering machinery without product-law and Apple-source justification, missing accessibility semantics, screenshot paths as proof, or readiness overclaims.
- Required output: Apple Platform sections consulted, Product Experience gates touched, iOS 26 availability, accessibility checks, screenshot/proof or not-run reason, validation commands/results.

This skill is operating support only. Product truth lives in `docs/truth/*`. It does not override product canon, release truth, live source, current tests, current logs, or current Xcode evidence.

`docs/truth/*`, live source, tests, current logs, current proof artifacts, and current user or issue instructions win over this skill.

## Required Source Map

Before touching SwiftUI, UIKit interop, SwiftData or local persistence, App Intents, WidgetKit, Live Activities, notifications, BackgroundTasks, LocalAuthentication, privacy, permissions, accessibility, Human Interface Guidelines aligned behavior, iOS design resources, shell chrome, keyboard behavior, or design-system primitives, read:

1. `docs/truth/CODEX_START_HERE.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_EXPERIENCE_CANON.md` when the work touches scenario-gated behavior
4. `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md` when proof/readiness wording is in scope
6. `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`
7. relevant live source, tests, `project.yml`, `Package.swift`, entitlements, Info.plist, scripts, and current logs

`PRODUCT_DESIGN_TRUTH.md` is product canon. `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md` is the iOS implementation source map. If they conflict, product canon wins.

If `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md` is missing during Apple-platform work, stop and close Blocked or Yellow with the missing-source reason. Do not guess Apple API behavior from memory.

Product Experience scenario gates are required when UI/source work touches Steps, reminders, Capture, Time, Goals, Life Capital, Future Steps, proof, reviews, onboarding, notifications, automation, conflict resolution, or Source Atlas inspection.

## Required Posture

- Preserve native SwiftUI architecture and XcodeGen.
- Verify active source ownership before source edits.
- Keep root surfaces to Today / Goals / Time / You.
- Treat Capture as global composer and Motion as behavior.
- Keep Stage thin; do not make custom Stage, UIKit interop, or rendering machinery the product unless SwiftUI-native implementation cannot satisfy product law and the Apple source map supports the exception.
- Do not create new `+02` or `+03` split files, broad `Models.swift` files, file-size churn, or architecture nouns to avoid deleting/collapsing duplicate authority.
- Freeze Source Atlas growth for UI/platform work unless public-reference, no-private-life-graph, request-shape, and boundary-audit proof exists for the changed scope.
- Prefer feature-local projection and surface-owned view state before adding central `Projection/SurfaceLenses` authority where canon allows.
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
- Product Experience gates touched
- Apple APIs/frameworks/patterns used
- iOS 26 availability notes
- accessibility checks
- focused build/test commands and exit codes
- screenshot/proof or explicit not-run reason for UI changes
- accessibility/non-claim notes where relevant
- privacy/permission notes where relevant
- proof artifacts that actually set the closeout ceiling; prose cannot upgrade missing, failed, stale, or not-run checks
- rollback path
