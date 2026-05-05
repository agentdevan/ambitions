# MEG01 Metal / Advanced Rendering Eligibility Gate
<!-- markdownlint-disable MD013 -->

Status: Active-scope advanced-rendering policy.
Date: 2026-05-05

## Purpose

MEG01 prevents Codex from using Metal, shaders, particles, or advanced rendering as a gimmick or as a substitute for proper layout, hierarchy, copy, and SwiftUI composition.

Metal may be valuable for Ambitions signature visuals, but it is not the default fix for visual quality.

## Default Rendering Stack

Use this order unless MEG01 approves escalation:

1. SwiftUI native layout, typography, materials, safe areas, and controls.
2. SwiftUI Shapes and custom view composition.
3. SwiftUI Canvas for rich 2D drawing and lightweight atmospheric/contour work.
4. Metal only if SwiftUI/Canvas cannot meet the measured quality/performance target.

## Metal / Advanced Rendering Candidate Areas

Potential candidates:

- Capture Atmosphere starfield / thought-field renderer
- LifeShape contour / pressure / protected-pocket renderer
- MissionControlTimeSpine proof/pressure field renderer
- subtle material texture/noise/light-falloff where Canvas is insufficient

## Forbidden Uses

Do not use Metal or advanced rendering to fix:

- weak Today hierarchy
- poor Start Here composition
- generic Reality Rail layout
- tab/shell polish
- generic cards
- dashboard drift
- weak copy
- missing source/trust behavior
- missing accessibility labels
- business logic
- navigation
- persistence
- recommendation logic
- privacy/trust/source logic

## Eligibility Requirements

Metal/advanced rendering is allowed only when all are true:

- target is a true Ambitions signature primitive
- simpler SwiftUI/Canvas approach is insufficient or measured as too weak
- performance and battery budget exists
- static fallback exists
- Reduce Motion fallback exists
- VoiceOver/nonvisual equivalent exists
- low-power/degraded mode exists where needed
- renderer is isolated in a small component boundary
- no business/domain/trust logic enters renderer
- screenshot evidence exists
- profiling/instruments plan exists
- effect is subtle, premium, and non-gimmicky
- no sci-fi UI drift

## Required Report

Any batch adding Metal/advanced rendering must write:

`docs/audits/meg01-advanced-rendering-eligibility-report.md`

Report must include:

- why SwiftUI/Canvas was insufficient
- visual primitive owner
- renderer file boundary
- performance/battery budget
- fallback behavior
- accessibility equivalent
- Reduce Motion equivalent
- screenshots
- profiling plan or evidence
- rollback path

## Hard Red

Hard Red if:

- Metal is added broadly
- Metal code contains business logic
- effect is decorative/noisy/gimmicky
- no static fallback exists
- no Reduce Motion fallback exists
- no accessibility equivalent exists
- battery/performance risk is unbounded
- shader complexity makes the repo harder to maintain without clear product value

## Completion

MEG01 completes when advanced rendering is either explicitly deferred or approved for named signature primitives with strict boundaries. No Metal implementation is required by this policy.
