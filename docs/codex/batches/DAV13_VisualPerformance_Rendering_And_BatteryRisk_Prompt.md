# DAV13 VisualPerformance Rendering And BatteryRisk Prompt
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV13
- Name: VisualPerformance Rendering And BatteryRisk
- Global order: 067
## Active 4.0 Status
Active DAV performance/risk batch.
## Purpose
Review rendering, animation, blur/material, battery, list identity, and preview performance risk.
## Affected Surfaces
All DAV surfaces.
## Allowed Production Swift Files
Narrow performance fixes in DAV-touched files.
## Forbidden Files
Dependencies, persistence/schema, routes/raw values.
## Required Visual Primitives
All implemented DAV primitives.
## Motion Rules
No expensive continuous animation by default.
## Reduce Motion Equivalent
Required for performance and accessibility.
## Dynamic Type Requirements
Large text must not explode layout cost.
## VoiceOver Requirements
Accessibility grouping must not hide controls.
## Preview Fixture Requirements
Representative heavy/overloaded fixtures.
## Product-Experience Before/After Notes
Record performance risk.
## Validation Commands
`scripts/dav-visual-performance-risk-scan.sh || true`; focused build/tests.
## Green/Yellow/Red Criteria
Green: risks bounded. Yellow: instruments/device proof deferred. Red: obvious costly visual loop.
## Stop Conditions
Stop on performance/battery uncertainty that cannot be bounded.
## Commit Message
`Run DAV13 VisualPerformance Rendering And BatteryRisk`
## Next Safe Path
DAV14 QA.

## Required Premium Experience Gates
- Inspect `docs/reference/visual-targets/ambitionsos-photo-matched/`.
- Cite Signature Experience and Transformative Motion docs.
- Pass SIG scorecard, PXEQ scorecard, DAV scorecard, Transformative Motion QA when motion is affected, accessibility evidence, Reduce Motion evidence, preview evidence, performance risk evidence, and photo-reference evidence.
