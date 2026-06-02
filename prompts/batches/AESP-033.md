<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-033 - App Intents experience grammar

Linear issue: AMB-455
Project: Ambitions Experience Sovereignty Program
Milestone: M07 - Native Platform Experience Depth

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Batch Goal

Verify App Intents preserve object identity, source/reason/control/receipt behavior, local-first privacy boundaries, and graceful unavailable fallbacks.

## Implementation Scope

- `Native/Ambitions/AppIntents`
- `Native/Ambitions/App`
- `Native/Ambitions/ExternalSnapshots`
- `Native/Ambitions/Runtime`
- `Native/Ambitions/Services/ExternalActionCommandService.swift`
- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`
- `Native/AmbitionsTests/App/ExternalCreationImportServiceTests.swift`
- `Native/AmbitionsTests/App/ShellCommandRouterTests.swift`

## Required Product Outcomes

- App Intent entry/exit keeps local-only assumptions clear.
- Runtime command receipt is visible where routing actions are performed.
- Fallbacks are explicit when intent payloads are stale or unavailable.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-033/app-intents-experience-grammar-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-033
make xcode-focused-test BATCH=AESP-033 TEST=AmbitionsTests/App/AppIntentRoutingTests
make xcode-focused-test BATCH=AESP-033 TEST=AmbitionsTests/App/ExternalCreationImportServiceTests
make xcode-focused-test BATCH=AESP-033 TEST=AmbitionsTests/App/ShellCommandRouterTests
make xcode-focused-test BATCH=AESP-033 TEST=AmbitionsTests
```
