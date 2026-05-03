# DAV01 Dynamic Visual Source Truth And Surface Map Prompt
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV01
- Name: Dynamic Visual Source Truth And Surface Map
- Global order: 055
## Active 4.0 Status
Active Ambitions 4.0 DAV implementation train. Docs/source mapping only; no app behavior unless a later DAV batch implements SwiftUI.
## Purpose
Map source truth, affected surfaces, primary visual objects, allowed Swift owners, dependencies, and validation lanes before visual implementation.
## Affected Surfaces
Today, Goals, Capture, Plan, You, Memory, Trust/Receipts, previews.
## Allowed Production Swift Files
None for DAV01.
## Forbidden Files
Native/**, Sources/**, AppUI/**, project.yml, persistence/schema, routes/raw values, enum/raw values, dependencies, workflows, signing.
## Required Visual Primitives
Name primitives and owner paths for DAV02.
## Motion Rules
No motion implementation; define allowed motion only.
## Reduce Motion Equivalent
Map required equivalents per surface.
## Dynamic Type Requirements
Map text hierarchy and large-type evidence.
## VoiceOver Requirements
Map reading order and labels.
## Preview Fixture Requirements
Define required scenario fixtures.
## Product-Experience Before/After Notes
Record current surface baseline and target impact.
## Validation Commands
`git status --short`; `git diff --check`; `scripts/dav-visual-primitive-inventory.sh || true`; `scripts/batch-train-gate-check.sh || true`.
## Green/Yellow/Red Criteria
Green: source map complete. Yellow: implementation deferred. Red: duplicate canon or unsafe Swift scope.
## Stop Conditions
Stop on dirty unknown tree, source conflict, or forbidden file request.
## Commit Message
`Run DAV01 Dynamic Visual Source Truth And Surface Map`
## Next Safe Path
DAV02 reusable primitives.

