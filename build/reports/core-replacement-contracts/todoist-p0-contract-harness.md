# IOS26 Todoist P0 Contract Harness

Status: Yellow

## Files changed
- `Native/AmbitionsTests/Domain/IOS26TodoistP0ContractHarnessTests.swift`
- `build/reports/core-replacement-contracts/todoist-p0-contract-harness.md`

## User jobs covered
- Todoist project and task management job
- Project / Commitment hierarchy replacement seam
- Step ordering, dependencies, labels, filters, saved views, recurrence, and local replay seams

## Replacement P0 gates
- Project equivalence: represented as a local `GoalThread`-backed project fixture
- Task equivalence: represented as a local `Commitment` and `Step` fixture
- Due/deadline: represented in `GoalTiming.dueAt`
- Dependencies: represented in `Step.dependencyStepIDs`
- Labels/tags: represented as explicit local metadata
- Filters: represented as explicit local metadata
- Saved views: represented as explicit local metadata
- Recurrence: represented in the recurring `Step` fixture and the harness evidence gate
- Deterministic sort: represented by stable local commitment ordering
- Source record wiring: covered by `KnowledgeSourceRecord` plus receipt source-object linkage
- Receipt wiring: covered by `ActionReceipt` and `ActionReceiptProofLedgerEntry`
- Replay trace wiring: covered by `ReplayableDecisionTrace`
- You inspection boundary: covered by the `What Ambitions knows` surface boundary fixture
- Unsupported broad claims: blocked by the harness fixture unless current evidence exists

## Tests run
- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04E-B03` -> Green
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch IOS26-T04E-B03 --prompt prompts/batches/IOS26-T04E-B03-todoist-p0-contract-harness.md` -> Green
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04E-B03` -> Green
- `python3 scripts/ios26-core-replacement-contract-check.py` -> Green
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04E-B03 --require-existing --artifact build/reports/core-replacement-contracts/todoist-p0-contract-harness.md` -> Green
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04E-B03 --prompt prompts/batches/IOS26-T04E-B03-todoist-p0-contract-harness.md --changed-from 6931515f48f29817cdc7666255f2d30c3c3158a9` -> Green
- `scripts/codex-forbidden-claim-scan.sh Native/AmbitionsTests/Domain/IOS26TodoistP0ContractHarnessTests.swift build/reports/core-replacement-contracts/todoist-p0-contract-harness.md build/reports/parallel-implementation-guard/IOS26-T04E-B03-post.md build/reports/intelligence-consolidation/champion-coverage-check.md docs/codex/existing-code-champion-coverage.yml docs/audits/intelligence-consolidation/EXISTING_CODE_CHAMPION_COVERAGE.md` -> Green, context-only denied-claim fixture hits
- `git diff --check -- Native/AmbitionsTests/Domain/IOS26TodoistP0ContractHarnessTests.swift build/reports/core-replacement-contracts/todoist-p0-contract-harness.md docs/codex/existing-code-champion-coverage.yml docs/audits/intelligence-consolidation/EXISTING_CODE_CHAMPION_COVERAGE.md build/reports/intelligence-consolidation/champion-coverage-check.md build/reports/intelligence-consolidation/champion-coverage-check.json` -> Green

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
- The Todoist P0 contract harness source exists
- Broad Todoist replacement claims are blocked in the harness fixture unless the required evidence is present
- Project, task, due/deadline, dependencies, labels, filters, saved views, recurrence, source, receipt, replay, and You-boundary seams are represented in test source
- The batch remains contract-only and does not change app behavior

## Claims forbidden
- Forbidden claim fixture: release-ready
- Forbidden claim fixture: App Store-ready
- Forbidden claim fixture: TestFlight-ready
- Forbidden claim fixture: fully accessible
- Forbidden claim fixture: performance validated
- Forbidden claim fixture: privacy approved
- Forbidden claim fixture: any claim that Todoist replacement is complete
- Forbidden claim fixture: any claim that this batch changed app behavior

## Yellow items
- Xcode validation is intentionally skipped by operator instruction, so compile/test proof remains unproven
- The harness is contract-only until the focused Xcode lane is allowed to run

## Red items
- None observed in the bounded patch surface

## Yellow/Red items
- Yellow: Xcode validation is intentionally skipped, so compile/test proof is unproven
- Red: none observed in the bounded patch surface

## Scenario count
- 2 source-backed contract scenarios
