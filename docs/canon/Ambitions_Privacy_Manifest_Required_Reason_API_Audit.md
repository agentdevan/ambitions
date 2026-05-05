# Ambitions Privacy Manifest Required-Reason API Audit
<!-- markdownlint-disable MD013 -->

Status: Active PFC25 privacy manifest / required-reason API audit
Date: 2026-05-05
Owner: Privacy / Platform
Result: Green source audit; final archive privacy report remains release-gated

## Purpose

This document records the PFC25 audit of Ambitions' current
`PrivacyInfo.xcprivacy` and required-reason API exposure.

It is not a legal certification, App Store Connect submission, Xcode archive
privacy report, or final release claim. It decides whether the repo should edit
the privacy manifest in this batch based on current source evidence.

## Apple Source Baseline

Apple's current required-reason API documentation requires privacy-manifest
entries when app or third-party SDK code uses covered API categories. The
categories reviewed for PFC25 are:

- `NSPrivacyAccessedAPICategoryUserDefaults`
- `NSPrivacyAccessedAPICategoryFileTimestamp`
- `NSPrivacyAccessedAPICategoryDiskSpace`
- `NSPrivacyAccessedAPICategorySystemBootTime`
- `NSPrivacyAccessedAPICategoryActiveKeyboards`

Official Apple references used:

- `https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api`
- `https://developer.apple.com/documentation/technotes/tn3183-adding-required-reason-api-entries-to-your-privacy-manifest`
- `https://developer.apple.com/documentation/bundleresources/privacy_manifest_files`
- `https://developer.apple.com/documentation/foundation/userdefaults`

Apple notes that the required-reason list can change over time, so this audit
must be re-run before release and whenever dependencies or platform APIs change.

## Current Manifest State

`Native/Ambitions/Resources/PrivacyInfo.xcprivacy` currently declares:

- `NSPrivacyTracking`: false
- `NSPrivacyCollectedDataTypes`: empty array
- `NSPrivacyAccessedAPITypes`: empty array

PFC25 does not edit the manifest because the source scan did not find direct
current app usage requiring a declaration.

## Required-Reason API Inventory

| Category | Source scan result | Current declaration | PFC25 decision | Future trigger |
| --- | --- | --- | --- | --- |
| UserDefaults | No direct `UserDefaults` usage found in active `Native`, `Sources`, or `AppUI` roots. Preferences are repository-backed through SwiftData app state. | None | No manifest entry added. | Add `NSPrivacyAccessedAPICategoryUserDefaults` with approved reason if app or bundled SDK code uses `UserDefaults`. |
| File timestamps | No direct `creationDate`, `modificationDate`, `fileModificationDate`, `contentModificationDateKey`, `creationDateKey`, `attributesOfItem`, `stat`, `fstat`, `lstat`, or `getattrlist` usage found in active roots. | None | No manifest entry added. | Add file-timestamp declaration if file timestamp APIs are used for app-container metadata, user-visible timestamps, or user-granted files. |
| Disk space | No direct disk-space API usage found in active roots. | None | No manifest entry added. | Add disk-space declaration if storage/battery/performance work reads available capacity. |
| System boot time | No direct `systemUptime` or boot-time API usage found in active roots. | None | No manifest entry added. | Add system-boot-time declaration if diagnostics or performance tooling needs it. |
| Active keyboards | No active-keyboard API usage found in active roots. | None | No manifest entry added. | Add active-keyboard declaration if custom keyboard-related code is introduced. |

## Third-Party SDK And Dependency Boundary

Current `Package.swift` defines local package products only and no remote Swift
package dependencies. PFC04 previously found no active CocoaPods, Carthage,
Gem, Mint, or remote runtime dependency surface. PFC25 therefore found no
third-party SDK privacy manifest to reconcile.

If future work adds a third-party SDK, the owning batch must verify whether the
SDK is on Apple's privacy-manifest/signature list, inspect the SDK manifest, and
re-run this required-reason audit.

## Required Future Checks

Before App Store submission or any release-readiness claim, the operator must:

1. Archive the exact release candidate and review Xcode's privacy report.
2. Re-run required-reason scans against the final source and built products.
3. Reconcile all app, extension, framework, and SDK privacy manifests.
4. Confirm `PrivacyInfo.xcprivacy` contains every required category and only
   reasons that match actual behavior.
5. Confirm App Privacy labels from PFC24 still match the final signed binary.

## Stop Conditions

Stop and re-open PFC25 if future work adds:

- direct `UserDefaults` usage;
- file timestamp, disk-space, system-boot-time, or active-keyboard API usage;
- new SDKs, frameworks, binaries, or dynamic libraries;
- analytics, telemetry, crash reporting, ads, tracking, or attribution;
- account, cloud, sync, backend, StoreKit, or external-service behavior;
- a privacy manifest, entitlement, dependency, or project change that is not
  reconciled with this audit.

## PFC25 Decision

PFC25 closes with no `PrivacyInfo.xcprivacy` edit. The current manifest remains
consistent with the source scan: no tracking, no collected data types, and no
declared accessed API types. Final archive privacy-report proof remains a
release/human/operator gate, not a Codex docs-only claim.
