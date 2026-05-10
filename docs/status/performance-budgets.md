<!-- markdownlint-disable MD013 -->

# Performance Budgets

Status: Active performance budget contract  
Date updated: 2026-05-10  
Authority: Subordinate to `docs/truth/*` and current measurement evidence

This file defines budgets Codex must use when performance is touched or
claimed. It does not prove current app performance.

## 1. Budget Rule

Codex must not claim performance quality unless a current measurement is run,
recorded, and compared against the relevant budget. If no measurement runs,
closeout must say performance was not verified.

## 2. App-Level Budgets

| Area | Target budget | Required evidence before claim |
| --- | --- | --- |
| Launch responsiveness | No launch-regression claim without current local launch/build evidence | Local run or launch measurement with device/simulator noted |
| Main-thread responsiveness | No new long-running UI work in touched seam | Instruments/logs or focused review for touched code |
| Memory posture | No memory-safe claim without measurement | Memory graph, Instruments, or scoped test output |
| Scroll/layout smoothness | No scroll-performance claim without visual/perf proof | Simulator recording, Instruments, or focused manual proof |
| Build/test duration | No speed claim without command timing | exact command and elapsed time |

## 3. Surface-Level Budgets

| Surface | Primary risk | Budget expectation | Proof when touched |
| --- | --- | --- | --- |
| Today | dense current-state rendering | primary action appears without layout thrash | screenshot/recording plus focused tests if source changes |
| Goals | graph/detail density | relationship view does not become heavy dashboard | visual proof and source review |
| Capture | keyboard/input responsiveness | input remains immediate and route reveal is calm | focused UI/manual proof if source changes |
| Time | horizon/capacity visuals | canvas remains legible and avoids expensive decoration | visual proof and performance review |
| You | settings/control density | grouped controls remain readable and responsive | screenshot/accessibility review |
| Widgets/extensions | compact rendering and data safety | no platform claim without target-specific evidence | focused extension proof when scoped |

## 4. Measurement Tiers

Tier 1, lightweight local:

- command timing
- focused tests
- simulator smoke run
- manual scroll/input inspection
- screenshot proof

Tier 2, targeted engineering:

- Instruments trace
- memory graph
- signpost/log review
- repeated simulator runs

Tier 3, release-grade:

- device-specific measurement
- archive/export context where approved
- human release review

Only Tier 3 can support real-device or release-grade performance claims, and
only when `docs/truth/RELEASE_TRUTH.md` allows the exact claim.

## 5. Budget Closeout Template

```text
Performance scope:
Budget selected:
Measurement run:
Command/procedure:
Environment:
Result:
Pass/fail:
Not verified:
Non-claims:
```

## 6. Red Conditions

Stop on:

- performance claim without measurement
- source change that adds obvious unbounded work to render path
- new continuous animation without live-state purpose
- expensive blur/glow/motion that obscures content or harms accessibility
- package/dependency addition for performance without approval

## 7. Current Status

No current performance measurement was run by this setup pass. Current
performance status remains unproven unless another proof packet provides
current evidence.

## 8. Phase 7 Gate Result

Phase 7 result: Green.

Validation:

- docs-only performance budget artifact
- no source/runtime files touched
- no performance proof or readiness claim made

