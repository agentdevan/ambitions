<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-034 - Spotlight and Handoff experience grammar

Linear issue: AMB-456
Project: Ambitions Experience Sovereignty Program
Milestone: M07 - Native Platform Experience Depth

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Runtime Contract Boundary

- Preserve and expose `SourceRecord`, `Receipt`, and `ReplayTrace` continuity for any runtime-affecting change.
- Include explicit `What Ambitions Knows` / You inspection so state transitions remain explainable.

## Batch Goal

Verify Spotlight and handoff behavior preserves indexable object continuity, privacy controls, and recoverable open/restore flows.

## Implementation Scope

- `Native/Ambitions/ExternalSnapshots`
- `Native/Ambitions/Services/ExternalActionCommandService.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceActionPayloads.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceContractModels.swift`
- `Native/Ambitions/App`
- `Native/Ambitions/Runtime`
- `Native/AmbitionsTests/App/ExternalRoutingTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceActionPayloadTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceControlContractsTests.swift`

## Required Product Outcomes

- Searchability and handoff identifiers are deterministic and private-safe.
- Reopen routes point to explicit, valid in-app objects.
- Stale or unauthorized states degrade to safe local-only behavior.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-034/spotlight-and-handoff-experience-grammar-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-034
make xcode-focused-test BATCH=AESP-034 TEST=AmbitionsTests/App/ExternalRoutingTests
make xcode-focused-test BATCH=AESP-034 TEST=AmbitionsTests/App/ExternalSurfaceActionPayloadTests
make xcode-focused-test BATCH=AESP-034 TEST=AmbitionsTests/App/ExternalSurfaceControlContractsTests
make xcode-focused-test BATCH=AESP-034 TEST=AmbitionsTests
```
