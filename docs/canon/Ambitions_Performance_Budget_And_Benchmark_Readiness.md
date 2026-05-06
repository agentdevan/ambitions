# Ambitions Performance Budget And Benchmark Readiness
<!-- markdownlint-disable MD013 -->

Status: Active PFC30 performance budget and Instruments checklist
Last updated: 2026-05-05

## Rule

Do not claim performance compliance until measured. PFC30 defines budgets,
profiling lanes, fixtures, stop conditions, and handoff evidence only. It does
not add benchmarking dependencies, runtime instrumentation, MetricKit,
analytics, crash reporting, telemetry, background services, release claims,
App Store claims, TestFlight claims, physical-device proof, or battery safety
claims.

## Official Tooling Baseline

Use current Apple developer guidance as the profiling baseline:

- [Improving app responsiveness](https://developer.apple.com/documentation/xcode/improving-app-responsiveness)
- [Reducing your app's launch time](https://developer.apple.com/documentation/xcode/reducing-your-app-s-launch-time)
- [Understanding and improving SwiftUI performance](https://developer.apple.com/documentation/xcode/understanding-and-improving-swiftui-performance)
- [Improving your app's rendering efficiency](https://developer.apple.com/documentation/xcode/improving-your-app-s-rendering-efficiency)
- [Instruments tutorials](https://developer.apple.com/tutorials/instruments)

Budget interpretation:

- Apple treats hangs, hitches, launch time, view-update frequency, rendering
  cost, and energy use as measured behaviors, not design assertions.
- Simulator/source review can find risk, but real responsiveness, battery, and
  thermal claims require device traces.
- Any future field diagnostics must pass PFC29 privacy/observability gates
  before collection exists.

## Current Repo Evidence Boundary

PFC30 starts from these current repo facts:

- `Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift`
  records source/simulator performance scope from the earlier R02 pass.
- R02 did not claim cold-start timing, memory pressure, touch latency,
  large-data scrolling, rendered widget/Live Activity performance,
  Shortcuts/Siri speed, TestFlight readiness, App Store readiness, or RC lock.
- PFC29 locks the current runtime posture to no remote analytics, no telemetry,
  no crash SDK, and no developer diagnostics collection.
- PFC30 is docs/QA only. PFC31 owns measured performance/battery repairs.

## Performance Budget Matrix

All targets remain `baseline required` until PFC31 or a later measured batch
records trace-backed numbers. Warning/failure thresholds are relative to the
first accepted baseline for the same device class, OS, build configuration,
fixture, and interaction script.

| Scope | Baseline needed | Warning | Failure | Method | Fixture | Stop condition |
| --- | --- | --- | --- | --- | --- | --- |
| Cold launch | Device trace | +20 percent | +40 percent | Xcode Organizer or Instruments launch profile | Clean install, no goals | Main-thread startup blocks first useful surface |
| Warm launch | Device or simulator trace | +20 percent | +40 percent | Instruments Time Profiler | Recent session | Bootstrap repeats cold setup |
| Today first render | Trace/UI timing | +15 percent | +30 percent | SwiftUI + Time Profiler | Dense day, low-capacity day | Full graph/recommendation recompute in render path |
| Capture open | Trace/UI timing | +15 percent | +30 percent | SwiftUI + Hitches | Empty and dense capture history | Placement/source work blocks composer |
| Goal Detail open | Trace/UI timing | +20 percent | +40 percent | SwiftUI + Time Profiler | 100 goals, deep path | Eager graph/path/archive load |
| Plan week open | Trace/UI timing | +20 percent | +40 percent | SwiftUI + Time Profiler | Dense schedule, calendar denied | Unbounded reflow or calendar wait |
| You trust surface open | Trace/UI timing | +20 percent | +40 percent | SwiftUI + allocations review | Many memories/receipts | Unbounded receipt or memory scan |
| Scroll/hitch pass | Device trace | Any recurring hitch | Persistent hitch | Animation Hitches | Today, Goals, Plan, You | Jank on primary scroll/gesture paths |
| Memory growth | Device trace | Repeatable growth | Unbounded growth | Allocations/Leaks | 30-minute navigation loop | Retained view models or large projections |
| Rendering/animation | Device trace | Missed display budget | Persistent dropped frames | SwiftUI, Hitches, Core Animation | FCP objects, Reduce Motion on/off | Decorative motion harms interaction |
| Widget reload | Extension timing | +20 percent | +40 percent | Extension trace/manual reload | Privacy projection | Raw sensitive data or slow projection |
| Live Activity update | Device proof | Any privacy/battery concern | Repeated heavy update | ActivityKit/manual trace | Active Step Focus Window | Update cadence/battery risk unbounded |
| App Intent execution | Platform proof | +20 percent | +40 percent | Shortcuts/App Intents test | Capture/route action | No fallback or slow launch path |
| Notification/calendar/reminder work | Device/manual proof | Any permission stall | UI blocked | Manual/device script | Denied/allowed permissions | Plan-owned permission boundary breaks |
| Sync/conflict future path | Future measured baseline | +20 percent | +40 percent | PFC10/PFC11 proof | Conflict fixture | UI waits on network or merge |
| Background task future path | Future measured baseline | Any heavy wake | Repeated heavy wake | Energy trace | Low Power Mode | Ignores power/thermal state |
| Large receipt history | Fixture benchmark | +20 percent | +40 percent | Local benchmark | 1000 receipts | Full scan per render |
| Ten-year archive | Fixture benchmark | +20 percent | +40 percent | Local benchmark | 10-year archive | No compaction or paging plan |
| Offline mode | UI/manual proof | Source wait | Navigation blocked | Offline run | No internet | Internet dependency enters core loop |

## Instruments Checklist

Every measured performance batch should record:

- device, OS, Xcode version, build configuration, simulator/device status, and
  whether Low Power Mode or Reduce Motion was enabled;
- exact interaction script and seed fixture;
- trace template used: Time Profiler, SwiftUI, Animation Hitches, Allocations,
  Leaks, Energy, Launch, or extension/platform-specific trace;
- baseline number, candidate number, delta, warning/failure classification, and
  whether the result is simulator-only or device-backed;
- screenshots or exported trace location when available;
- source owner for any regression and the smallest safe repair path;
- explicit non-claims for TestFlight, App Store, release, physical-device,
  public accessibility, privacy/legal compliance, and battery safety unless
  matching evidence exists.

## SwiftUI Review Checklist

Use the SwiftUI performance-audit workflow before measuring or repairing:

- avoid broad `Environment`, `Observable`, and app-wide state reads in dense
  view hierarchies;
- keep expensive projection, sorting, graph traversal, source evaluation, and
  text generation outside `body`;
- stabilize `ForEach` identities and avoid transient IDs for scrollable
  surfaces;
- keep `GeometryReader`, preference keys, material/blur, timeline updates,
  shimmer, and animation scopes bounded;
- provide Reduce Motion equivalents and non-motion state meaning;
- ensure widgets, Live Activities, and App Intents use privacy-minimized
  projections instead of raw app state;
- preserve local-first behavior and avoid network waits in core navigation.

## Claim Boundary

PFC30 may say Ambitions has a performance budget and profiling plan. It must
not say Ambitions meets the budget, is battery safe, is release ready, is
App Store ready, is TestFlight ready, passed physical-device proof, passed
manual accessibility proof, or has production observability.

## PFC31 Handoff

PFC31 should use this document to choose measured repair targets. If local
tooling cannot collect device traces, PFC31 should produce the strongest
simulator/source proof available and classify remaining device, battery,
thermal, widget, Live Activity, App Intent, and Shortcuts evidence as
human/operator Yellow rather than pretending it exists.
