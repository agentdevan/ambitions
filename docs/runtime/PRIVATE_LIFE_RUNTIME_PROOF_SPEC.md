# Private Life Runtime Proof Spec

Status: Active supporting runtime proof specification  
Authority: Subordinate to `docs/truth/*`  
Created directly through GitHub API: 2026-05-15

This file defines the minimum proof target for the Private Life Runtime moat. It is a specification only, not implementation proof.

## Core Proof Target

Ambitions must prove this behavior:

```text
same intent
+ different local user context
= different inspectable daily execution plan
```

The plan must persist after relaunch, adapt after closure/recovery events, preserve proof/receipt continuity, and remain inspectable by the user.

## Required Scenario Set

| Scenario | Input | Expected proof |
|---|---|---|
| Busy user | Same goal, low available capacity, protected time | Smaller or safer daily step with reason trace. |
| Open-capacity user | Same goal, open useful work window | Deeper step with different reason trace. |
| Missed step | Prior step not closed | Closure/recovery path before stale carryover. |
| Relaunch | Existing recommendation with receipt | Same recommendation and receipt restore unless source data changed. |
| Early completion | Step completed sooner than planned | Optional reflow prompt, not silent rearrangement. |
| User correction | User adjusts recommendation reason, duration, or timing | Future behavior respects correction and exposes reset/inspection. |

## Required Inspection Questions

Every recommendation must answer:

- What intent or goal did this come from?
- Why this step?
- Why now?
- What source/context was used?
- What can the user change?
- What receipt was created if behavior changed?

## Required Evidence

Future implementation proof must include fixtures or tests for each scenario, local persistence/replay evidence, closure/recovery evidence, receipt evidence, and a current status report that separates implemented behavior from planned behavior.

## Non-Proof Boundary

This document does not prove build success, test success, runtime implementation, visual QA, accessibility conformance, device validation, TestFlight readiness, App Store readiness, or release readiness.
