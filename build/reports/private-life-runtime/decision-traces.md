# Private Life Runtime Decision Traces

Batch: IOS26-T03-B03
Scope: Replayable decision trace adapter and focused runtime tests
Status: Green

## Source support

- Added `ReplayableDecisionTrace` and nested runtime, goal-intelligence, recommendation, blocking, and privacy facts under `Native/Ambitions/Runtime/ReplayableDecisionTraceModels.swift`.
- The adapter is built from the existing `PrivateLifeRuntimeKernelDecisionInput`, `PrivateLifeRuntimeKernelDecisionOutput`, and `PrivateLifeRuntimeKernelDecisionRecord` paths.
- The emitted trace keeps runtime boundary and memory facts, normalized recommendation identifiers and block reasons, goal-intelligence quarantine/freshness/privacy facts where present, and receipt/proof references.
- The adapter intentionally omits raw narrative fields such as explanation summaries and why-this/why-now prose.
- Trace and record identifiers are emitted as stable local digests so replay artifacts can be matched without serializing raw recommendation or goal-intelligence narrative text.

## Validation

- `xcodegen generate` - passed.
- `scripts/build-local.sh` - passed; log: `output/logs/build-local-20260522-140912.log`.
- `scripts/ambitions-xcode-validate.sh --batch IOS26-T03-B03 --lane build-for-testing` - passed; summary: `.codex/xcode-summaries/IOS26-T03-B03/20260522T180352Z/build-for-testing-summary.json`.
- `make xcode-focused-test BATCH=IOS26-T03-B03 TEST=AmbitionsTests/ReplayableDecisionTraceTests` - passed with 4 executed tests; summary: `.codex/xcode-summaries/IOS26-T03-B03/20260522T180540Z/focused-test-summary.json`.
- `make xcode-focused-test BATCH=IOS26-T03-B03 TEST=AmbitionsTests/AmbitionsRuntimeKernelContractsTests` - passed with 4 executed tests; summary: `.codex/xcode-summaries/IOS26-T03-B03/20260522T180725Z/focused-test-summary.json`.
- `git diff --check` - passed.

## Notes

- No UI, project, dependency, or top-level IA changes were made.
- The replayable trace is a local-only inspection artifact, not release proof, accessibility proof, privacy/legal approval, or performance proof.
- Earlier wrapper runs that used `AmbitionsTests/Runtime/...` filters returned zero executed tests and are not treated as focused XCTest proof.
