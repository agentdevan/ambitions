# IOS26 Cross-app Journey Contract Harness

Status: Yellow

## Phase 04 repair pass
- Normalized fixture copy to the locked `Recommended step` wording.
- Reran non-Xcode validation after repair.
- Xcode/XCTest/simulator/device lanes remain skipped by operator instruction.

## Files changed
- `Native/AmbitionsTests/Domain/IOS26CrossAppJourneyContractHarnessTests.swift`
- `build/reports/core-replacement-contracts/cross-app-journey-contract-harness.md`
- `build/reports/core-replacement-contracts/IOS26-T04E-B06.md`
- `docs/codex/existing-code-champion-coverage.yml`
- `build/reports/intelligence-consolidation/champion-coverage-check.md`
- `build/reports/intelligence-consolidation/champion-coverage-check.json`
- `build/reports/parallel-implementation-guard/IOS26-T04E-B06-post.md`
- `build/reports/parallel-implementation-guard/IOS26-T04E-B06-post.json`

## User jobs covered
- Cross-app replacement for six flagship journeys (half-marathon, move/apartment, career growth, creative release, relationship/life balance, sensitive context)
- SourceReceiptReplay seam across six journey families
- You / What Ambitions knows inspection boundary for sensitive and source-backed contexts

## Replacement P0 gates
- Half-marathon: local `GoalThread`/`Step`/`Commitment` fixture with recurrence and local-only scheduling intent represented in test source
- Move/apartment: local planning and deadline fixture with move-prep commitment and replay seam represented
- Career growth: recurring study fixture with local source-backed scheduling seam represented
- Creative release: dependency-based step fixture with local source, receipt, and replay trace represented
- Relationship/life balance: protected-time/recurrence guard fixture represented with inspectable boundary and local source/receipt/replay linkage
- Sensitive context: sensitive journey fixture with explicit `What Ambitions knows` boundary and local, user-reviewed fallback path represented
- SourceRecord requirement: each journey fixture includes `KnowledgeSourceRecord` identity and source-domain linkage
- Receipt requirement: each journey fixture includes `ActionReceipt` plus proof ledger bridge
- ReplayTrace requirement: each journey fixture includes `ReplayableDecisionTrace`
- No-claim boundary: harness blocks broad claims when any journey evidence, SourceRecord, Receipt, ReplayTrace, or You-boundary evidence is absent
- Forbidden claims: release readiness and broad completion claims remain blocked by harness fixtures

## Tests run
- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04E-B06` -> Green
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04E-B06 --prompt prompts/batches/IOS26-T04E-B06-cross-app-journey-contract-harness.md --changed-from 46df54c9de81ae19a59aac678c70720cb5b4a426` -> Green
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04E-B06` -> Green
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch IOS26-T04E-B06 --prompt prompts/batches/IOS26-T04E-B06-cross-app-journey-contract-harness.md` -> Green
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04E-B06 --artifact build/reports/core-replacement-contracts/cross-app-journey-contract-harness.md` -> Green
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04E-B06` -> Green after the batch artifact was present
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/AmbitionsTests/Domain/IOS26CrossAppJourneyContractHarnessTests.swift build/reports/core-replacement-contracts/cross-app-journey-contract-harness.md docs/codex/existing-code-champion-coverage.yml build/reports/parallel-implementation-guard/IOS26-T04E-B06-post.md build/reports/intelligence-consolidation/champion-coverage-check.md` -> Green
- `scripts/codex-forbidden-claim-scan.sh Native/AmbitionsTests/Domain/IOS26CrossAppJourneyContractHarnessTests.swift build/reports/core-replacement-contracts/cross-app-journey-contract-harness.md docs/codex/canonical-owner-map.yml` -> Green
- `scripts/codex-forbidden-claim-scan.sh Native/AmbitionsTests/Domain/IOS26CrossAppJourneyContractHarnessTests.swift build/reports/core-replacement-contracts/cross-app-journey-contract-harness.md docs/codex/existing-code-champion-coverage.yml build/reports/parallel-implementation-guard/IOS26-T04E-B06-post.md build/reports/intelligence-consolidation/champion-coverage-check.md` -> Green, context-only forbidden fixture hits
- `git diff --check` -> Clean

## Validation not run
- Xcode compile/test lanes were not run due `AMBITIONS_SKIP_XCODE_TESTING=1`
- No raw `xcodebuild`, `make xcode-focused-test`, or simulator/device lanes were executed
- No accessibility audit was run
- No privacy/legal approval activity was run
- No benchmark/performance measurement lane was run

## Accessibility status
- Not verified by current proof
- The harness includes boundary copy on `What Ambitions knows`; it does not claim VoiceOver, Dynamic Type, reduce-motion, or contrast validation

## Privacy/local-first status
- Local-first contract seams only
- No cloud LLM, hosted personal-data backend, or external analytics introduced
- No privacy approval claim was made

## Performance status
- Not measured by this batch
- No performance proof was claimed

## Claims allowed
- The cross-app journey contract harness source exists and blocks broad cross-app replacement claims until explicit evidence is present
- Local `SourceRecord`-like identity, `Receipt`, and `ReplayTrace` proof is represented for each of six journey fixture families
- `What Ambitions knows` inspection boundaries are represented for sensitive/journey source review seams
- The harness remains contract-focused and does not declare runtime implementation completeness
- The batch-specific `IOS26-T04E-B06.md` proof artifact now exists, so the proof-shape check no longer reports a missing default artifact path.

## Claims forbidden
- Forbidden claim fixture: release-ready
- Forbidden claim fixture: App Store-ready
- Forbidden claim fixture: TestFlight-ready
- Forbidden claim fixture: fully accessible
- Forbidden claim fixture: performance validated
- Forbidden claim fixture: privacy approved
- Forbidden claim fixture: any claim that cross-app replacement is complete
- Forbidden claim fixture: any claim that this batch changed app behavior

## Yellow/Red items
- Yellow: Xcode/Focused test lanes are intentionally paused by operator policy (`AMBITIONS_SKIP_XCODE_TESTING=1`), so runtime compile/test proof is still unverified
- Yellow: no non-coding benchmark/accessibility/privacy verification was executed in this phase
- Red: none observed in bounded scope

## Scenario count
- 6 contract scenarios
