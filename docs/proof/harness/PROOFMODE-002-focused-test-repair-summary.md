# PROOFMODE-002 Focused Test Repair Summary

Status: Yellow
Issue: AMB-308
Created UTC: 2026-05-30T02:16:04Z

## Destination Discovery

- selected iPhone 17 from com.apple.CoreSimulator.SimRuntime.iOS-26-3

## Validation

- xcodegen generate exit: 0

### Focused Test Attempt

- exit: 65
- command: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/AppDrivingProofModeRouterTests CODE_SIGNING_ALLOWED=NO`
- log: `build/reports/harness/PROOFMODE-002/focused-test-discovered-destination.log`

### Retry Attempt

- exit: -11
- command: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination platform=iOS Simulator -only-testing:AmbitionsTests/AppDrivingProofModeRouterTests CODE_SIGNING_ALLOWED=NO`
- log: `build/reports/harness/PROOFMODE-002/focused-test-generic-destination.log`

## Classification

- `xcodebuild_exit_65_unclassified`

## Result

Focused app-driving proof remains Yellow. Inspect the recorded log for the next bounded repair.

## Claims Not Made

- No full app-driving proof completion claim unless reviewed.
- No release readiness claim.
- No TestFlight readiness claim.
- No App Store readiness claim.
- No device validation claim.
- No accessibility validation claim.
- No privacy/legal approval claim.
