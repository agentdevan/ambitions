# DAV06 Goals MissionControlLanes Implementation Prompt
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV06
- Name: Goals MissionControlLanes Implementation
- Global order: 060
## Active 4.0 Status
Active DAV implementation batch; production SwiftUI allowed in Goals visual owners.
## Purpose
Implement GoalMissionControlLanes: proof, blockers, next step, confidence/momentum, and recommended step.
## Affected Surfaces
Goals and Goal Detail when narrowly needed.
## Allowed Production Swift Files
Native/Ambitions/Features/Goals/**, Sources/Components/**, Native/Ambitions/PreviewSupport/**.
## Forbidden Files
Persistence/schema, routes/raw values, dependencies, workflows.
## Required Visual Primitives
AdaptiveModuleChrome, ProofPulse, PressureGlow, EvidenceLabel.
## Motion Rules
Lane reveal and proof pulse only.
## Reduce Motion Equivalent
Static lane state.
## Dynamic Type Requirements
Lane titles and actions wrap.
## VoiceOver Requirements
Lane order: proof, blockers, next, momentum.
## Preview Fixture Requirements
Goal with proof, blocker, high momentum, empty goal, large type.
## Product-Experience Before/After Notes
Record no task-list clone proof.
## Validation Commands
`git diff --check`; DAV scans; focused Goals build/tests.
## Green/Yellow/Red Criteria
Green: lanes compile and preserve goal behavior. Yellow: polish deferred. Red: OKR/dashboard/kanban drift.
## Stop Conditions
Stop on domain/persistence/route changes.
## Commit Message
`Implement Goals dynamic adaptive screen`
## Next Safe Path
DAV07 You.

