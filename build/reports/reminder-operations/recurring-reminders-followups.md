# IOS26-T04G-B04 Recurring Reminders And Followups

Status: Yellow
Batch: IOS26-T04G-B04
Train: TRAIN_04G / Reminder Operations / Reminders Replacement

## End-user job

Use recurring obligations and waiting follow-ups locally, without introducing a new reminder graph or cloud dependency.

## Replacement floor

Reminder capture now distinguishes:

- recurring obligations
- waiting follow-ups
- blocked follow-ups
- reschedule and snooze transitions
- missed-trigger recovery

## Files changed

- `Native/Ambitions/Domain/ReminderModels.swift`
- `Native/Ambitions/Domain/ReminderNaturalLanguageCaptureParser.swift`
- `Native/AmbitionsTests/Domain/ReminderNaturalLanguageCaptureParserTests.swift`
- `Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift`

## Implementation behavior

- Reminder source notes now preserve recurrence, waiting, blocked, and follow-up text in the local source graph.
- Reminder parsing keeps the full matched recurrence and follow-up phrases instead of collapsing them to tails.
- Waiting and blocked phrases are distinguished by state.
- Waiting follow-ups preserve the follow-up text and surface the missing-time review boundary when the follow-up lacks a clock time.
- ReminderTrigger now exposes pure state helpers for recurring advances, missed-trigger recovery, rescheduling, snoozing, and blocked/waiting follow-up handling.
- Reminder repository round-trips the reminder source-note metadata through the local snapshot path.

## Validation run

- `swiftc -parse Native/Ambitions/Domain/ReminderModels.swift Native/Ambitions/Domain/ReminderNaturalLanguageCaptureParser.swift Native/AmbitionsTests/Domain/ReminderNaturalLanguageCaptureParserTests.swift Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift`
- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04G-B04`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch IOS26-T04G-B04 --prompt prompts/batches/IOS26-T04G-B04-recurring-reminders-and-followups.md --batch-type source-changing --allow-yellow`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04G-B04 --prompt prompts/batches/IOS26-T04G-B04-recurring-reminders-and-followups.md --changed-from 8b0e099336449c97463a22799a793e4eb341cfe4 --batch-type source-changing --allow-yellow`
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04G-B04`
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04G-B04`

## Validation not run

- Xcode build, XCTest, simulator, device, accessibility, performance, CI, TestFlight, and App Store validation were skipped because `AMBITIONS_SKIP_XCODE_TESTING=1` is set.

## Proof boundaries

- Local source, parser, and repository round-trip proof only.
- No build, XCTest, simulator, accessibility, performance, CI, TestFlight, App Store, or release proof is claimed.

## Guard fields

Champion coverage status: Green
Champion coverage report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
Parallel guard pre status: Yellow accepted
Parallel guard pre report: `build/reports/parallel-implementation-guard/IOS26-T04G-B04-pre.md`
Parallel guard post status: Yellow accepted
Parallel guard post report: `build/reports/parallel-implementation-guard/IOS26-T04G-B04-post.md`
Canonical owner extended: `proof_receipt_replay`
New implementation owners: none
Canonical owner map changed: no
Supersession ledger updated: no
Best-code rescue checked: yes
Runtime wiring gate: preserved through `SourceRecord`, `Receipt`, `ReplayTrace`, and `You / What Ambitions knows`
Yellow accepted reason: operator-skipped Xcode lanes and accepted `proof_receipt_replay` lock boundary
Red blockers: none in the non-Xcode lane

## Yellow items

- Xcode remains operator-skipped.
- This batch stays source-level only.
- The accepted `proof_receipt_replay` lock boundary remains in effect.

## Next batch

`IOS26-T04G-B05`
