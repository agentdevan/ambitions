# UIQL REPAIR LOG

- 2026-06-11: Goal Mode UIQL adapter installed. Future UIQL execution must update this file with issue evidence.
- 2026-06-11: UIQL-001 found a dependent Red: `Native/AmbitionsTests/App/ActivationContractTests.swift` still expects `Today / Goals / Capture / Time / You` and `.plan` activation surface ordering. Repair must be scoped before UIQL-002.
- 2026-06-11: UIQL-001 repaired the stale Activation Contract test expectation by asserting canonical tabs as `Today / Goals / Time / Motion / You`, proving `.capture` is not in `AppTab.allCases`, and keeping Capture/Plan-era activation rules as supporting/global route coverage. Rebuilt focused `ActivationContractTests` passed 4 tests, 0 failures.
- 2026-06-11: UIQL-002 required more than three repair cycles. Reframe report created at `UIQL-002_REPAIR_REFRAME_REPORT.md`; final repair brought shell header controls and activated Capture seam inside safe geometry gates with focused UI tests passing.
- 2026-06-11: UIQL-003 used three repair cycles. The final fix kept the Today product copy repair and made the focused UI test validate visible Reality Meridian product labels instead of relying only on container identifiers. Final focused UI test, visible-copy unit test, object-stage unit suite, and screenshot evaluation passed for UIQL-003 scope.
