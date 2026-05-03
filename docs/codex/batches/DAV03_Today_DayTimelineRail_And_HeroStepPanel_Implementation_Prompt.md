# DAV03 Today DayTimelineRail And HeroStepPanel Implementation Prompt
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV03
- Name: Today DayTimelineRail And HeroStepPanel Implementation
- Global order: 057
## Active 4.0 Status
Active DAV implementation batch; production SwiftUI allowed in Today visual owners.
## Purpose
Upgrade Today around DayTimelineRail, HeroStepPanel, Now/Next/Later, closure prompt state, pressure/time progress, and compact contextual header.
## Affected Surfaces
Today.
## Allowed Production Swift Files
Native/Ambitions/Features/Today/**, Sources/Components/** if using DAV primitives, Native/Ambitions/PreviewSupport/**.
## Forbidden Files
Persistence/schema, routes/raw values, enum/raw values, dependencies, workflows, signing.
## Required Visual Primitives
LivingSurfaceBackground, AdaptiveModuleChrome, PressureGlow, ProofPulse, EvidenceLabel.
## Motion Rules
Rail progress and hero reveal only; no generic card pile or celebratory loops.
## Reduce Motion Equivalent
Static rail and instant hero state.
## Dynamic Type Requirements
Hero and rail text reflow at accessibility sizes.
## VoiceOver Requirements
Hero then Now/Next/Later order; action labels stay stable.
## Preview Fixture Requirements
Normal day, overloaded day, recovery day, blocked step, Still Counts, high Dynamic Type, Reduce Motion.
## Product-Experience Before/After Notes
Record one-primary-object Today impact.
## Validation Commands
`git diff --check`; DAV scans; focused Today build/tests.
## Green/Yellow/Red Criteria
Green: Today compiles, previews/fixtures recorded, PXEQ >= 4/5. Yellow: visual polish deferred. Red: dashboard/task-list drift or accessibility regression.
## Stop Conditions
Stop on route/default/persistence changes or compile Red.
## Commit Message
`Implement Today dynamic adaptive screen`
## Next Safe Path
DAV04 Capture.

