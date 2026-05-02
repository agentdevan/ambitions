# Ambitions Performance Budget And Benchmark Readiness

Status: Future benchmark planning; no performance compliance claim

## Rule

Do not claim performance compliance until measured. Do not add benchmarking dependencies in this batch.

## Future Budgets

| Flow | Target | Warning | Failure | Method | Fixture | Release impact | Stop condition |
| --- | --- | --- | --- | --- | --- | --- | --- |
| cold launch | future measured baseline | +20 percent | +40 percent | XCTest/Xcode metrics | clean install | blocks launch performance claim | launch depends on model inference |
| warm launch | future measured baseline | +20 percent | +40 percent | local benchmark | recent session | blocks responsiveness claim | main-thread heavy work |
| Today first render | future measured baseline | +15 percent | +30 percent | UI timing | dense day | blocks Today claim | full graph recompute |
| Capture open | future measured baseline | +15 percent | +30 percent | UI timing | empty and dense | blocks first-use claim | source research blocks UI |
| Goal Detail open | future measured baseline | +20 percent | +40 percent | UI timing | 100 goals | blocks path-depth claim | eager full graph load |
| Plan week open | future measured baseline | +20 percent | +40 percent | UI timing | dense schedule | blocks Plan claim | unbounded reflow |
| You trust surface open | future measured baseline | +20 percent | +40 percent | UI timing | many memories | blocks trust claim | unbounded receipt scan |
| widget projection generation | future measured baseline | +20 percent | +40 percent | extension timing | privacy projection | blocks widget claim | raw sensitive state |
| App Intent execution | future measured baseline | +20 percent | +40 percent | platform proof | privacy projection | blocks App Intent claim | no fallback |
| Live Activity projection | future measured baseline | +20 percent | +40 percent | platform proof | active session | blocks Live Activity claim | privacy risk |
| large receipt history | future measured baseline | +20 percent | +40 percent | fixture benchmark | 1000 receipts | blocks longevity claim | full scan per render |
| 10 years history | future measured baseline | +20 percent | +40 percent | fixture benchmark | 10-year archive | blocks archive claim | no compaction |
| low-power mode | future measured baseline | any heavy optional work | repeated heavy wake | manual/sim proof | Low Power Mode | blocks energy claim | ignores battery state |
| old-device fallback | future measured baseline | degraded animations | unusable flow | device/sim matrix | old device | blocks broad support claim | no capability fallback |
| offline mode | future measured baseline | source fetch waits | navigation blocked | offline test | no internet | blocks offline claim | internet dependency |
