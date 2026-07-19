# AMB-1816 Runtime Event Replay Performance Smoke

Status: harness added; XCTest execution not claimed under the active user instruction authorizing issue completion without testing until advised otherwise.

## Scope

This leaf adds one measurable LocalRuntimeOS runtime smoke:

- Operation: `runtime.event_replay.append_lookup`
- Source owner measured: `Native/Ambitions/Core/LocalRuntimeOS/EventJournal`
- Harness owner: `Native/AmbitionsTests/Performance/RuntimeEventReplayPerformanceSmokeTests.swift`
- Store: `InMemoryRuntimeEventStore`
- Workload: append 160 command-execution runtime events, then perform 160 replay lookups through `RuntimeEventReplay`.
- Threshold: elapsed append-plus-lookup time must be <= 1,500 ms.

## Metadata Captured By The Harness

The failure summary records:

- operation id
- elapsed milliseconds
- maximum milliseconds
- event count
- replay lookup count
- runtime event store kind
- operating system version
- process name
- active processor count
- thermal state
- proof scope

## Non-Claims

This harness does not claim app-wide performance readiness, physical-device performance, launch performance, scroll/render performance, memory baseline, release readiness, or XCTest execution for the current commit.

## Required Follow-Up Before Stronger Claims

Run the focused XCTest lane for `AmbitionsTests/RuntimeEventReplayPerformanceSmokeTests`, capture the result bundle, and record the measured environment before upgrading this from harness-present proof to current measured performance proof.
