# IOS26-T04F-B03: Recurrence availability and free-time engine

Status: YELLOW

Files changed:
- Native/Ambitions/Features/Time/TimeCalendarAwarenessSupport.swift
- Native/Ambitions/Features/Time/TimeFeatureService.swift
- Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift
- Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift
- Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift

Behavior implemented:
- Added configurable Time availability horizon support for `day`, `week`, `month`, and `year` windows.
- Extended `makeTimeCalendarAware` through bounded service-level horizon configuration while preserving the protocol-required default path.
- Added deterministic calendar-aware all-day normalization and expansion in `EventKitIntegrationService`.
- Added deterministic all-day + DST-aware splitting by local calendar day boundaries.
- Added focused regression tests for horizon forwarding and all-day window expansion behavior.

Phase 04 repair:
- Corrected the horizon helper call sites to pass explicit string literals into the existing `String`-backed availability horizon helper.
- Re-ran the allowed non-Xcode gates after the repair.

Validation:
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04F-B03`
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04F-B03`
- `python3 scripts/ios26-prompt-freeze-check.py --batch IOS26-T04F-B03 --prompt prompts/batches/IOS26-T04F-B03-recurrence-availability-and-free-time-engine.md`
- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04F-B03`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04F-B03 --prompt prompts/batches/IOS26-T04F-B03-recurrence-availability-and-free-time-engine.md --changed-from edc6efd107f91a7e58c82021404f6cb4621bdf37 --allow-yellow`
- `git diff --check`

Validation not run (per operator pause):
- Xcode/XCTest/simulator validation (`AMBITIONS_SKIP_XCODE_TESTING=1`).

Notes:
- Recurrence-related behavior is represented by deterministic expansion of all-day projections and horizon breadth controls in this seam. EventKit recurrence expansion is handled through projected snapshots from the store and normalized in a bounded local envelope.
- `proof_receipt_replay` remains accepted Yellow and unchanged.
- Runtime wiring boundary: existing SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows inspection boundaries are preserved only for this recurrence availability and free-time context; broad proof/receipt/replay completion is not claimed.
