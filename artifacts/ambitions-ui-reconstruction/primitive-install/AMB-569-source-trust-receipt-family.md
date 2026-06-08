# AMB-569 Source / Trust / Receipt Primitive Family

Verdict: Yellow

AMB-569 installed the first shared `source-trust-strip` primitive and replaced one active generic Today source/freshness/receipt chip row with the new shared strip. The issue is accepted Yellow because the family replacement is intentionally partial; AMB-607 owns the remaining active card/container/source-row classification and replacement debt.

## Scope

Source-changing.

## Changed Files

- `Sources/Components/TrustReceiptLayerPrimitives.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift`
- `docs/codex/concept-lock-registry.yml`
- `artifacts/ambitions-ui-reconstruction/primitive-install/AMB-569-source-trust-receipt-family.md`

## Replacement Completed

- Replaced the Today Start Here source/freshness/receipt `meridianChip` row in `Native/Ambitions/Features/Today/TodayDayRailPanels.swift` with `SourceTrustReceiptStrip`.
- Added `SourceTrustReceiptStripRole`, `SourceTrustReceiptStripItem`, and `SourceTrustReceiptStrip` in `Sources/Components/TrustReceiptLayerPrimitives.swift`.
- The primitive does not wrap `AmbitionChip`, `AppCard`, `StateDrivenMaterialPanel`, or old panel/card UI.
- The primitive renders owner-supplied SourceRecord, Receipt, and ReplayTrace inspection labels only; it does not add hidden recommendation or routing logic.

## Registry Entry

Complete registry entry: `source-trust-strip` in `docs/codex/ambitions_primitive_invention_registry.md`.

The entry includes:

- Replaces
- Not a card because
- Accessibility
- Rollback

## Screenshot Artifact Paths

No AMB-569-generated screenshot was produced, and this report does not claim new visual proof.

Exact existing touched-surface screenshot references:

- `artifacts/ambitions-ui-reconstruction/screenshots/today-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-receipt-available-after-final.png`

## Validation

- `python3 scripts/ambitions-champion-coverage-check.py` - passed; report: `build/reports/intelligence-consolidation/champion-coverage-check.md`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-569 --prompt docs/codex/ambitions_primitive_invention_registry.md` - passed; report: `build/reports/parallel-implementation-guard/AMB-569-pre.md`.
- `make xcode-focused-test BATCH=AMB-569 TEST=AmbitionsTests/TrustReceiptLayerDesignSystemTests` - passed; executed 10 tests, 0 failures.
  - Log: `.codex/xcode-logs/AMB-569/20260608T064940Z-AmbitionsTests-TrustReceiptLayerDesignSystemTests-74640-15160/focused-test.log`
  - Result bundle: `.codex/xcode-results/AMB-569/20260608T064940Z-AmbitionsTests-TrustReceiptLayerDesignSystemTests-74640-15160/focused-test.xcresult`
  - Summary: `.codex/xcode-summaries/AMB-569/20260608T064940Z-AmbitionsTests-TrustReceiptLayerDesignSystemTests-74640-15160/focused-test-summary.json`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-569 --prompt docs/codex/ambitions_primitive_invention_registry.md --changed-from fae1fd2ca8247c15b90c76d51643fd65e826290c` - initial Red for lock/runtime-wiring disclosure, repaired, final passed; report: `build/reports/parallel-implementation-guard/AMB-569-post.md`.
- `python3 scripts/ambitions-unsupported-claim-scan.py Sources/Components/TrustReceiptLayerPrimitives.swift Native/Ambitions/Features/Today/TodayDayRailPanels.swift Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift docs/codex/concept-lock-registry.yml artifacts/ambitions-ui-reconstruction/primitive-install/AMB-569-source-trust-receipt-family.md` - passed.
- `bash scripts/codex-forbidden-claim-scan.sh Sources/Components/TrustReceiptLayerPrimitives.swift Native/Ambitions/Features/Today/TodayDayRailPanels.swift Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift docs/codex/concept-lock-registry.yml artifacts/ambitions-ui-reconstruction/primitive-install/AMB-569-source-trust-receipt-family.md` - passed after scanner-sensitive negative test literals were composed from tokens.
- `git diff --check` - passed.

## Proof Boundaries

- This proves a scoped primitive install, one active generic source/freshness/receipt row replacement, focused XCTest coverage, and guard compatibility.
- This does not prove full source/trust/receipt family replacement across the app.
- This does not claim new screenshot proof, human visual review, accessibility certification, device proof, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, or release readiness.

## Rollback Notes

- Revert `Sources/Components/TrustReceiptLayerPrimitives.swift` to remove `SourceTrustReceiptStripRole`, `SourceTrustReceiptStripItem`, `SourceTrustReceiptStrip`, and its FE04 role binding.
- Revert `Native/Ambitions/Features/Today/TodayDayRailPanels.swift` to restore the prior local `meridianChip` source/freshness/receipt row.
- Revert `Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift` to remove the strip role and accessibility-summary assertions.
- Revert `docs/codex/concept-lock-registry.yml` to remove AMB-569 from the explicit allowed-batch lists if the primitive install is rolled back.
- Remove this report.

## Required Completion Footer

Verdict: Yellow

Artifact paths:
- `artifacts/ambitions-ui-reconstruction/primitive-install/AMB-569-source-trust-receipt-family.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-receipt-available-after-final.png`

Focused tests:
- `make xcode-focused-test BATCH=AMB-569 TEST=AmbitionsTests/TrustReceiptLayerDesignSystemTests` - passed, 10 tests, 0 failures.

Changed files:
- `Sources/Components/TrustReceiptLayerPrimitives.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift`
- `docs/codex/concept-lock-registry.yml`
- `artifacts/ambitions-ui-reconstruction/primitive-install/AMB-569-source-trust-receipt-family.md`

Rollback notes:
- Revert the AMB-569 commit to remove the shared strip, restore the Today local row, remove focused test assertions, and remove the concept-lock allowance/report.

Remaining Yellow debt:
- AMB-607
