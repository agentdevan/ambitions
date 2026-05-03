# DAV05 Plan LifeShapeMap And CapacityVisuals Implementation Prompt
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV05
- Name: Plan LifeShapeMap And CapacityVisuals Implementation
- Global order: 059
## Active 4.0 Status
Active DAV implementation batch; production SwiftUI allowed in Plan visual owners.
## Purpose
Upgrade Plan with LifeShapeMap, capacity visual, pressure visual, protected time blocks, Day/Week/Month scope chip, and evidence labels.
## Affected Surfaces
Plan.
## Allowed Production Swift Files
Native/Ambitions/Features/Plan/**, Sources/Components/**, Native/Ambitions/PreviewSupport/**.
## Forbidden Files
Calendar permission behavior changes, persistence/schema, routes/raw values, dependencies, workflows.
## Required Visual Primitives
LivingSurfaceBackground, PressureGlow, EvidenceLabel, AdaptiveModuleChrome.
## Motion Rules
Believable reflow orientation only; no calendar clone animation.
## Reduce Motion Equivalent
Static capacity state and non-animated scope selection.
## Dynamic Type Requirements
Capacity labels wrap and remain readable.
## VoiceOver Requirements
Scope, pressure, capacity, protected time in order.
## Preview Fixture Requirements
Day, week, month, overloaded, calendar denied, recovery.
## Product-Experience Before/After Notes
Record no-calendar-clone impact.
## Validation Commands
`git diff --check`; DAV scans; focused Plan build/tests.
## Green/Yellow/Red Criteria
Green: Plan compiles and is visually time-aware. Yellow: performance/human polish deferred. Red: generic calendar/dashboard drift.
## Stop Conditions
Stop on permission, persistence, route, or schema changes.
## Commit Message
`Implement Plan dynamic adaptive screen`
## Next Safe Path
DAV06 Goals.

