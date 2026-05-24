Status: YELLOW

Files changed:
- Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift
- build/reports/time-operations/eventkit-mirror-permission.md

User jobs covered:
- Calendar event creation from Ambitions must not write when Calendar write permission is denied.
- Calendar mirror read/write boundaries must preserve local-only/degraded behavior when permissions block operations.

Replacement app floor:
- Confirmed that EventKit write-gated behavior for calendar events records a blocked SideEffectLedger action and avoids any persistence attempt when permission is denied.
- This preserves local-first safety by preventing unapproved external calendar writes and keeps the Time floor unchanged unless user-approved context flow is available.

P0 contract status:
- The batch-level P0 contract is covered for denied write-permission safety and no silent write behavior.
- Read/derive mirror behavior is unchanged and remains blocked safely through denied/empty permission paths in existing service and fixture coverage.

Tests run:
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04F-B02`
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04F-B02`

Validation not run:
- Xcode/xcodebuild, XCTest execution, simulator, device, accessibility, privacy/legal review, performance measurement, and release readiness validation.
- `AMBITIONS_SKIP_XCODE_TESTING=1` is set by operator policy for this phase.

Accessibility status:
- Not verified in this phase. No new UI text/input surface was changed.

Privacy/local-first status:
- No cloud LLMs, hosted personal-data backends, or analytics dependencies were added.
- Permission-gated calendar reads/writes remain local-first and write attempts are blocked without explicit allowed permission state.

Performance status:
- Not measured. No performance claim is made.

Claims allowed:
- This batch records source-level regression coverage that denied Calendar write permission prevents EventKit event save attempts and records a blocked, confirmation-required ledger outcome when the XCTest lane is next allowed to run.

Claims forbidden:
- No release readiness, App Store readiness, TestFlight readiness, CI proof, accessibility verification, or broader behavioral completion claims are made.

Yellow/Red items:
- Yellow: `proof_receipt_replay` remains accepted by upstream Champion Merge context and is unchanged by this narrow boundary test.
- Yellow: Xcode-based validation is intentionally skipped due operator `AMBITIONS_SKIP_XCODE_TESTING=1`.
- Red: none.
