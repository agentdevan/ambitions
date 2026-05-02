# Ambitions Native UI Primitive Reviewer
<!-- markdownlint-disable MD013 -->

## Purpose

Review whether a proposed SwiftUI primitive is genuinely Ambitions-native,
small enough to maintain, and reusable without becoming a generic card kit.

## When It Applies

Use for `AdaptivePanel`, `DayTimelineRail`, `HeroStepPanel`, `LifePathView`,
`MissionControlLane`, `LifeShapeMap`, `CaptureAtmosphereComposer`,
`TrustReceiptToast`, `AmbitionsInAppModule`, and adjacent SI primitives.

## Source-Truth Hierarchy

User prompt, `AGENTS.md`, Ambitions 3.0 primitives, PXOS visual/surface canon,
SI canon, current `Native/Ambitions/**`, `Sources/**`, `AppUI/Sources/**`.

## Review Inputs

Component API, preview states, file-size snapshot, call sites, tests, visual
evidence, accessibility labels/values, and rollback plan.

## Review Checklist

- Owns one clear responsibility and state model.
- Uses Ambitions-native naming, not `CardView` or vague utility naming.
- Supports normal, loading, empty, disabled, degraded, privacy-sensitive,
  reduced-motion, and Dynamic Type states when relevant.
- Can compose without making top-level surfaces into card stacks.
- Keeps logic out of view files.

## Green / Yellow / Red Criteria

- Green: focused primitive, previewed states, accessible semantics, maintainable
  file size, and clear reuse boundary.
- Yellow: missing noncritical state or preview with named owner.
- Red: broad one-off component, generic card wrapper, unreviewable file growth,
  visual-only behavior, missing accessibility, or route/persistence drift.

## Forbidden Approvals

Do not approve generic cards, style wrappers, component names that hide product
meaning, or primitives without previews when preview infrastructure exists.

## Required Evidence

Component ownership, state matrix, preview list, file-size snapshot, validation
commands, and visual acceptance notes.

## Repair Guidance

Split responsibility, rename to product-owned primitive, add states/previews,
move logic into projectors/state, or stop on Red if the primitive is generic.

## Claims

May claim primitive review passed for a scope. Must not claim full SI, PXOS,
Product Depth, AOS, visual approval, or release readiness.
