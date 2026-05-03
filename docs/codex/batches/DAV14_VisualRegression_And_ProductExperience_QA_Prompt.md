# DAV14 VisualRegression And ProductExperience QA Prompt
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV14
- Name: VisualRegression And ProductExperience QA
- Global order: 068
## Active 4.0 Status
Active DAV QA batch.
## Purpose
Run visual QA, PXEQ product-experience scorecard, anti-generic checks, and regression validation for DAV surfaces.
## Affected Surfaces
All DAV surfaces.
## Allowed Production Swift Files
Only narrow repair files named by QA evidence.
## Forbidden Files
Dependencies, persistence/schema, routes/raw values.
## Required Visual Primitives
All DAV primitives scored.
## Motion Rules
Motion meaning validated.
## Reduce Motion Equivalent
Scorecard dimension.
## Dynamic Type Requirements
Scorecard dimension.
## VoiceOver Requirements
Scorecard dimension.
## Preview Fixture Requirements
Scenario gallery referenced.
## Product-Experience Before/After Notes
Each surface must score 4/5 or be Yellow/Red.
## Validation Commands
DAV scorecard scripts, docs QA, focused tests/build.
## Green/Yellow/Red Criteria
Green: scorecard passes. Yellow: safe polish advisory. Red: technical pass but mediocre product experience.
## Stop Conditions
Stop on unresolved PXEQ Red.
## Commit Message
`Run DAV14 VisualRegression And ProductExperience QA`
## Next Safe Path
DAV15 closeout.

## Required Premium Experience Gates
- Inspect `docs/reference/visual-targets/ambitionsos-photo-matched/`.
- Cite Signature Experience and Transformative Motion docs.
- Pass SIG scorecard, PXEQ scorecard, DAV scorecard, Transformative Motion QA if motion is affected, accessibility evidence, Reduce Motion evidence, preview evidence, visual QA evidence, and photo-reference evidence.
