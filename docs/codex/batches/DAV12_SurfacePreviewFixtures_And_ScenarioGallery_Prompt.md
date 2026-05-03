# DAV12 SurfacePreviewFixtures And ScenarioGallery Prompt
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV12
- Name: SurfacePreviewFixtures And ScenarioGallery
- Global order: 066
## Active 4.0 Status
Active DAV preview fixture batch.
## Purpose
Create preview fixtures for calm normal day, overloaded day, recovery day, empty capture, routed capture, blocked step, Still Counts, goal proof/blocker, stale/rejected/private memory, high Dynamic Type, and Reduce Motion.
## Affected Surfaces
All DAV surfaces and PreviewSupport.
## Allowed Production Swift Files
Native/Ambitions/PreviewSupport/**, Sources/Previews/**, preview-only code in DAV components.
## Forbidden Files
Persistence/schema, routes/raw values, dependencies.
## Required Visual Primitives
All DAV primitives represented.
## Motion Rules
Preview motion must have Reduce Motion variant.
## Reduce Motion Equivalent
Preview included.
## Dynamic Type Requirements
Preview included.
## VoiceOver Requirements
Fixture labels named where possible.
## Preview Fixture Requirements
All named scenarios.
## Product-Experience Before/After Notes
Record preview coverage.
## Validation Commands
`scripts/dav-preview-fixture-check.sh || true`; focused build.
## Green/Yellow/Red Criteria
Green: fixture coverage exists. Yellow: screenshot capture deferred. Red: missing major scenarios.
## Stop Conditions
Stop on fake data claims.
## Commit Message
`Run DAV12 SurfacePreviewFixtures And ScenarioGallery`
## Next Safe Path
DAV13 performance.

