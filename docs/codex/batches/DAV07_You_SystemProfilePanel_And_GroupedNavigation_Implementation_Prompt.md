# DAV07 You SystemProfilePanel And GroupedNavigation Implementation Prompt
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV07
- Name: You SystemProfilePanel And GroupedNavigation Implementation
- Global order: 061
## Active 4.0 Status
Active DAV implementation batch; production SwiftUI allowed in You/Profile visual owners.
## Purpose
Implement SystemProfilePanel and GroupedNavigationSystem sections for Trust, Memory, Planning Setup, and Accessibility.
## Affected Surfaces
You/Profile.
## Allowed Production Swift Files
Native/Ambitions/Features/Profile/**, Sources/Components/**, Native/Ambitions/PreviewSupport/**.
## Forbidden Files
Profile raw value migration, default tab changes, persistence/schema, dependencies, workflows.
## Required Visual Primitives
GroupedNavigationSystem, AdaptiveModuleChrome, EvidenceLabel, StateDrivenMaterialPanel.
## Motion Rules
Grouped reveal only.
## Reduce Motion Equivalent
Static grouping.
## Dynamic Type Requirements
Rows and subtitles wrap.
## VoiceOver Requirements
Section headings and row labels in order.
## Preview Fixture Requirements
No data, trusted, stale, sensitive, correction, high Dynamic Type.
## Product-Experience Before/After Notes
Record personal system center, not settings dump.
## Validation Commands
`git diff --check`; DAV scans; focused You/Profile build/tests.
## Green/Yellow/Red Criteria
Green: You compiles and avoids settings dump. Yellow: polish deferred. Red: Profile compatibility break or admin dashboard drift.
## Stop Conditions
Stop on compatibility/persistence/default-tab changes.
## Commit Message
`Implement You dynamic adaptive screen`
## Next Safe Path
DAV08 Memory.

