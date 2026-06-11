# UIQL REPAIR LOG

- 2026-06-11: Goal Mode UIQL adapter installed. Future UIQL execution must update this file with issue evidence.
- 2026-06-11: UIQL-001 found a dependent Red: `Native/AmbitionsTests/App/ActivationContractTests.swift` still expects `Today / Goals / Capture / Time / You` and `.plan` activation surface ordering. Repair must be scoped before UIQL-002.
- 2026-06-11: UIQL-001 repaired the stale Activation Contract test expectation by asserting canonical tabs as `Today / Goals / Time / Motion / You`, proving `.capture` is not in `AppTab.allCases`, and keeping Capture/Plan-era activation rules as supporting/global route coverage. Rebuilt focused `ActivationContractTests` passed 4 tests, 0 failures.
