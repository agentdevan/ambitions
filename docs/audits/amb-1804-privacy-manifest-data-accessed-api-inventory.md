# AMB-1804 Privacy Manifest Data and Accessed-API Inventory

Status: Implemented Yellow  
Date: 2026-07-05T20:56:02Z  
Baseline main SHA: `440b5b2368a21779f97252dac9e562a62308a748`  
Manifest reviewed: `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`

## Current Manifest Position

| Area | Manifest value | Source-backed disposition |
| --- | --- | --- |
| Tracking | `NSPrivacyTracking = false` | Preserved. No tracking framework imports or tracking-domain declaration were added in this slice. |
| Collected data | `NSPrivacyCollectedDataTypes = []` | Preserved as a source inventory result only. This is not legal/privacy approval and does not answer the App Store questionnaire. |
| Accessed APIs | one `NSPrivacyAccessedAPICategoryFileTimestamp` entry with reason `C617.1` | Added for the app-owned local file metadata access in `ObjectStoreSwiftDataLegacyMigration.swift`. |

## Accessed API Inventory

| Category | Reason | Source reference | Local-only justification |
| --- | --- | --- | --- |
| `NSPrivacyAccessedAPICategoryFileTimestamp` | `C617.1` | `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataLegacyMigration.swift:66` | The migration path reads app-owned legacy SwiftData sidecar file metadata through `FileManager.attributesOfItem(atPath:)` to detect and remove empty migrated files. The path is local/app-group storage only; no derived file metadata is sent off-device. |

## Targeted Source Scan Summary

- `UserDefaults`, `@AppStorage`, `SceneStorage`, `NSUserDefaults`, and `CFPreferences`: no production hits in `Native/`, `Sources/`, `Packages/`, or `AppUI`.
- File metadata/timestamp scan: one production hit, the legacy SwiftData sidecar size check above.
- Disk-space, system-boot-time, and active-keyboard API scans: no production hits in the scoped search patterns.
- Permission/data-source scan: EventKit imports and `EKEventStore` use remain present for calendar/reminder integration, with purpose strings in `Native/Ambitions/Support/Info.plist`; this inventory does not convert EventKit permission use into a collected-data or legal approval claim.
- Extension scan: widget/share extension Info.plist and entitlements were inspected; no extension-specific `PrivacyInfo.xcprivacy` is currently present. This packet does not claim extension App Store privacy completeness.

## Non-Claims

- No privacy/legal approval.
- No App Store privacy questionnaire readiness.
- No App Store Connect privacy report or archive proof.
- No third-party SDK privacy aggregation proof.
- No extension-specific privacy manifest Green claim.
- No release proof.

## Rollback

Revert the manifest accessed-API entry, the source/test alignment updates, and this audit/evidence packet.
