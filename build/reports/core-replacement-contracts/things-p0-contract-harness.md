# IOS26 Things P0 Contract Harness

Status: Yellow

## Files changed
- `Native/AmbitionsTests/Domain/IOS26ThingsP0ContractHarnessTests.swift`
- `docs/codex/canonical-owner-map.yml`
- `docs/codex/existing-code-champion-coverage.yml`
- `build/reports/core-replacement-contracts/things-p0-contract-harness.md`

## User jobs covered
- Things 3 instant capture and daily planning job
- Start Here / Today / Upcoming / Scheduled / Open / Held replacement seam
- Life Area and GoalThread organization seam
- Source / Receipt / Replay / You inspection seam for user-owned source knowledge

## Replacement P0 gates
- Instant capture: covered by the missing-evidence fixture and saved-view seam
- Start here: covered by the saved-view fixture and no-dashboard contract
- Today: covered by the saved-view fixture and Today-facing source object seam
- Upcoming: covered by the saved-view fixture
- Scheduled: covered by the saved-view fixture
- Open: covered by the saved-view fixture and step actionability seam
- Held: covered by the saved-view fixture
- Life Areas: covered by `LifeAreaDefinition` fixtures
- Goal Threads: covered by `GoalThread` and `Commitment` fixtures
- Low-friction closure: covered by the step recovery policy fixture
- Source record wiring: covered by `KnowledgeSourceRecord` plus receipt source-object linkage
- Receipt wiring: covered by `ActionReceipt` and `ActionReceiptProofLedgerEntry`
- Replay trace wiring: covered by `ReplayableDecisionTrace`
- You inspection boundary: covered by the `What Ambitions knows` surface boundary fixture
- Unsupported broad claims: blocked by the harness fixture unless current evidence exists

## Tests run
- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04E-B04` -> Green
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch IOS26-T04E-B04 --prompt prompts/batches/IOS26-T04E-B04-things-p0-contract-harness.md` -> Green
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04E-B04` -> Green
- `python3 scripts/ios26-core-replacement-contract-check.py` -> Green
- `scripts/codex-forbidden-claim-scan.sh Native/AmbitionsTests/Domain/IOS26ThingsP0ContractHarnessTests.swift build/reports/core-replacement-contracts/things-p0-contract-harness.md docs/codex/canonical-owner-map.yml` -> Green
- `git diff --check` -> Green
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04E-B04 --require-existing --artifact build/reports/core-replacement-contracts/things-p0-contract-harness.md` -> Green
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04E-B04 --prompt prompts/batches/IOS26-T04E-B04-things-p0-contract-harness.md --changed-from 43b4c73e4826d96e523db20d2722b2196bbe32c6` -> Green
- Phase 03 repair rerun added the Things harness to existing-code champion coverage and reconfirmed champion coverage/post guard/proof shape/forbidden-claim scan/diff hygiene as Green

## Validation not run
- Xcode build, focused XCTest, UI test, simulator, device, archive, accessibility audit, privacy/legal approval, and performance measurement were not run
- The operator pause `AMBITIONS_SKIP_XCODE_TESTING=1` remains in effect, so no Xcode proof is claimed

## Accessibility status
- Not verified by current proof
- The harness only asserts the You inspection boundary copy; it does not claim VoiceOver or Dynamic Type proof

## Privacy/local-first status
- Local-first contract gate only
- No cloud LLM, hosted user-data backend, or external analytics was introduced
- No privacy approval is claimed

## Performance status
- Not measured by this batch
- No performance validation is claimed

## Claims allowed
- The Things 3 P0 contract harness source exists
- Broad Things 3 replacement claims are blocked in the harness fixture unless the required evidence is present
- Instant capture, Start here, Today, Upcoming, Scheduled, Open, Held, life-area, goal-thread, source, receipt, replay, and You-boundary seams are represented in test source
- The batch remains contract-only and does not change app behavior

## Claims forbidden
- forbidden claim fixture: release-ready
- forbidden claim fixture: App Store-ready
- forbidden claim fixture: TestFlight-ready
- forbidden claim fixture: fully accessible
- forbidden claim fixture: performance validated
- forbidden claim fixture: privacy approved
- forbidden claim fixture: Things 3 replacement is complete
- forbidden claim fixture: this batch changed app behavior

## Yellow/Red items
- Yellow: Xcode validation is intentionally skipped by operator instruction, so compile/test proof remains unproven
- Parallel-guard post phase is Green in `build/reports/parallel-implementation-guard/IOS26-T04E-B04-post.md`
- Red: none observed in the bounded patch surface

## Scenario count
- 2 source-backed contract scenarios
