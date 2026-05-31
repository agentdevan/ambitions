# AFRI-036 Privacy Manifest and App Store Declaration Alignment Proof

Issue: AMB-388 / AFRI-036  
Date: 2026-05-31  
Status: Green for source-manifest alignment and focused local validation. Yellow remains for human App Store Connect, legal/privacy, signed build, and device review.

## Scope

AFRI-036 audits the checked-in privacy manifest, permission strings, app/extension entitlements, external-surface indexing, local runtime boundary, and external-truth packet against current source evidence.

This packet is proof-only. No runtime source, manifest, entitlement, permission, dependency, or project wiring changed.

## Current Alignment

| Area | Current source evidence | AFRI-036 finding |
| --- | --- | --- |
| Privacy manifest | `Native/Ambitions/Resources/PrivacyInfo.xcprivacy` is bundled through `project.yml` resources. It sets `NSPrivacyTracking` to `false`, `NSPrivacyCollectedDataTypes` to an empty array, and `NSPrivacyAccessedAPITypes` to an empty array. | Green for current checked-in manifest shape. |
| Permission prompts | `Native/Ambitions/Support/Info.plist` includes Calendar and Reminders usage strings for selected-step scheduling and conflict checks. No camera, microphone, location, contacts, or user-tracking prompt strings were found in the app plist scan. | Green with App Store label follow-up for optional Calendar/Reminders behavior. |
| Entitlements | App, widget extension, and share extension entitlement files declare the shared App Group only. No iCloud entitlement was found in the current entitlement scan. | Green for current entitlement source. |
| External surfaces and indexing | Widget, Live Activity, App Intent, deep-link, and share-extension surfaces are source-present. Focused proof remains source/simulator scoped and does not prove device or App Store behavior. | Yellow for device/submission proof, Green for no new privacy-risking source in this slice. |
| Local runtime boundary | `LocalOnlyProofHarnessTests` verifies the local runtime boundary, local repository composition, no external side effects inside unit-of-work receipts, and empty collected/accessed manifest arrays. | Green for focused local test proof. |
| External-truth packet | `ReleaseExternalTruthReadinessPacketTests` keeps privacy wording tied to `PrivacyInfo.xcprivacy` and keeps submission claims blocked behind human/device gates. | Green for release-claim honesty. |

## Validation

Green:

- `plutil -lint Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `plutil -p Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `python3 scripts/ambitions_validate_trust_privacy.py`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/LocalOnlyProofHarnessTests -only-testing:AmbitionsTests/ReleaseExternalTruthReadinessPacketTests`
  - Result: 12 tests, 0 failures.
  - Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_19-39-26--0400.xcresult`

Yellow / advisory:

- `bash scripts/cqs-privacy-security-claim-scan.sh Native/Ambitions` returned advisory hits from pre-existing source identifiers and forbidden-claim fixture strings, including ordinary text parser names and source-owned guard phrases. AFRI-036 did not introduce or edit those files. This is not used as Green proof for the whole tree.

## Claim Boundaries

This packet does not prove:

- App Store Connect privacy questionnaire completion
- human legal/privacy approval
- signed archive validation
- physical-device behavior
- rendered widget or Live Activity privacy behavior
- TestFlight submission
- App Store submission
- public accessibility approval
- production release approval

## Rollback

Revert this proof packet only. Since AFRI-036 changed no runtime source or manifest files, rollback does not change app behavior.
