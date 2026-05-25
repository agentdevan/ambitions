# IOS26-T04G-B03 Natural Reminder Capture Parser

Status: Yellow
Batch: IOS26-T04G-B03
Train: TRAIN_04G / Reminder Operations / Reminders Replacement

## End-user job

Replace reminder-like natural language capture with a local parser that stays on-device and preserves Ambitions-native proof and inspection boundaries.

## Replacement floor

The parser now recognizes the batch contract cases locally:

- `tomorrow at 9`
- `tomorrow, at 9`
- `every Monday`
- `follow up next week`
- `pay rent monthly`
- `call person Friday`
- `waiting on response`
- ambiguous input that must stay in review

The parser preserves:

- `SourceRecord`
- `Receipt`
- `ReplayTrace`
- `You / What Ambitions knows`

## Files changed

- `Native/Ambitions/Domain/ReminderNaturalLanguageCaptureParser.swift`
- `Native/AmbitionsTests/Domain/ReminderNaturalLanguageCaptureParserTests.swift`
- `docs/codex/canonical-owner-map.yml`
- `prompts/batches/IOS26-T04G-B03-natural-reminder-capture-parser.md`
- `scripts/ambitions-parallel-implementation-guard.py`
- `build/reports/parallel-implementation-guard/IOS26-T04G-B03-pre.json`
- `build/reports/parallel-implementation-guard/IOS26-T04G-B03-pre.md`
- `build/reports/parallel-implementation-guard/IOS26-T04G-B03-post.json`
- `build/reports/parallel-implementation-guard/IOS26-T04G-B03-post.md`
- `build/reports/reminder-operations/IOS26-T04G-B03.md`
- `build/reports/reminder-operations/natural-reminder-capture-parser.md`

## Implementation behavior

- Parses reminder-like language locally; no cloud LLM or hosted backend use is introduced.
- Distinguishes concrete, recurring, waiting, and review-needed language.
- Keeps waiting targets inspectable as the object after the waiting phrase.
- Uses a local notification delivery policy.
- Keeps ambiguous input in review instead of silently scheduling it.
- Preserves the `What Ambitions knows` inspection boundary.

## Validation run

- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04G-B03`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch IOS26-T04G-B03 --prompt prompts/batches/IOS26-T04G-B03-natural-reminder-capture-parser.md --batch-type source-changing --allow-yellow`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04G-B03 --prompt prompts/batches/IOS26-T04G-B03-natural-reminder-capture-parser.md --changed-from 8b0e099336449c97463a22799a793e4eb341cfe4 --batch-type source-changing --allow-yellow`
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04G-B03`
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04G-B03`
- `python3 scripts/ambitions-unsupported-claim-scan.py build/reports/reminder-operations/IOS26-T04G-B03.md build/reports/reminder-operations/natural-reminder-capture-parser.md build/reports/parallel-implementation-guard/IOS26-T04G-B03-pre.md build/reports/parallel-implementation-guard/IOS26-T04G-B03-post.md`
- `scripts/codex-forbidden-claim-scan.sh build/reports/reminder-operations/IOS26-T04G-B03.md build/reports/reminder-operations/natural-reminder-capture-parser.md build/reports/parallel-implementation-guard/IOS26-T04G-B03-pre.md build/reports/parallel-implementation-guard/IOS26-T04G-B03-post.md`
- `git diff --check`

## Phase 02 verification

- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04G-B03 --print-counts` -> Green
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04G-B03` -> Green
- `python3 scripts/ambitions-unsupported-claim-scan.py build/reports/reminder-operations/IOS26-T04G-B03.md build/reports/reminder-operations/natural-reminder-capture-parser.md build/reports/parallel-implementation-guard/IOS26-T04G-B03-pre.md build/reports/parallel-implementation-guard/IOS26-T04G-B03-post.md` -> Green
- `swiftc -parse Native/Ambitions/Domain/ReminderNaturalLanguageCaptureParser.swift Native/AmbitionsTests/Domain/ReminderNaturalLanguageCaptureParserTests.swift` -> Green
- Xcode, `xcodebuild`, simulator, device, XCTest, accessibility, and performance validation remain skipped by operator policy for this batch.

## Phase 04 repair pass

- Repaired the focused test matrix so `tomorrow, at 9` is asserted directly.
- Confirmed `waiting on response` expects the dependency object `response`, matching the parser contract.
- Repaired the parallel guard owner-classification path so exact champion-coverage file ownership is preferred before broad canonical owner path fallback.
- Refreshed `IOS26-T04G-B03` pre/post guard reports.

## Validation results

- Champion coverage check: Green
- Parallel guard pre: Yellow
- Parallel guard post: Yellow
- Parallel guard post owner classification: parser types classify under `proof_receipt_replay`; test helpers classify as `test-only`
- IOS26 flagship preflight: Green
- IOS26 core replacement proof shape: Green
- Diff check: clean

## Validation not run

- Xcode, `xcodebuild`, focused XCTest, simulator, device, accessibility, and performance validation were not run because `AMBITIONS_SKIP_XCODE_TESTING=1` is set for this batch.

## Proof artifacts

- `build/reports/reminder-operations/natural-reminder-capture-parser.md`
- `build/reports/intelligence-consolidation/champion-coverage-check.md`
- `build/reports/intelligence-consolidation/champion-coverage-check.json`
- `build/reports/parallel-implementation-guard/IOS26-T04G-B03-pre.md`
- `build/reports/parallel-implementation-guard/IOS26-T04G-B03-post.md`

## Accessibility status

- Not verified in this batch.

## Privacy/local-first status

- Local-first only.
- No cloud LLM, hosted personal-data backend, or external analytics dependency introduced.

## Performance status

- Not measured in this batch.

## Claims allowed

- Local reminder-like parsing exists for the sealed contract cases.
- The parser preserves canonical source/receipt/replay/inspection boundaries.
- Coverage and guard classification were repaired to include the new parser files.
- Non-Xcode validation lanes listed above completed with no Red blockers.

## Claims forbidden

- Build, XCTest, simulator, device, accessibility, performance, CI, TestFlight, App Store, or release claims.
- Any claim that ambiguous reminder input is silently committed.
- Any claim that broader reminder replacement is complete beyond this sealed parser contract.

## Yellow items

- Xcode validation is intentionally skipped by operator policy.
- `proof_receipt_replay` remains an accepted Yellow lock boundary.

## Red items

- None found in the non-Xcode validation lanes for this batch.

## Next batch

- `IOS26-T04G-B04`
