# Visual Canon / Moat Implementation Specification

Status: Phase 02 Control-Plane Authority Addendum
Date: 2026-05-11

## Status and authority

This specification is a control-plane document for the visual and moat surface lane.

- Active source-of-truth remains in `docs/truth/PRODUCT_DESIGN_TRUTH.md` and
  `docs/truth/PRODUCT_MOAT_TRUTH.md`.
- This spec is supporting canon; it does not by itself claim implementation or runtime completion.
- `docs/codex/VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY.md` installs the overlay
  sequencing.
- `docs/codex/VISUAL_CANON_MOAT_BATCH_TRAIN.md` owns the visual/moat train
  decomposition for missing batches.
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_VISUAL_CANON_MOAT_OVERLAY.md` wires
  this lane into the active global order.
- Hard boundaries:
  - top-level IA is `Today / Goals / Capture / Time / You`.
  - `Plan` remains a compatibility/context noun only.
  - no cloud/hosted AI, no hosted personal-data backend, no release claim, no
    accessibility conformance claim without proof.

## Locked visual north-star set

- Shell Overview Board (product family / IA / materials / continuity primer).
- Today / Reality Meridian (execution reference).
- Goals / Constellation Atlas (direction and proof continuity).
- Capture / Atmosphere Composer (resting intake and route-intent reveal).
- Time / Day Pressure Ledger (shape and bounded day).
- Time / Week Pressure Ledger with Reflow Crown.
- Time / LifeShape Node Calendar.
- You / User System Profile (system runtime controls).
- Moat Alignment Visual Addendum:
  - Ambition Graph
  - Proof-backed execution
  - Trust and Recovery clarity
  - Route reveal after input
  - Preview-before-reflow discipline
  - Personal Runtime and local trust controls

## Moat alignment rule

Every visual surface must make progress toward:

```text
proof-backed execution + local receipts + inspectable trust reasoning + recovery
```

and must avoid generic productivity abstractions (task list, dashboard, calendar clone, habit rings, streak scores, shame framing).

## Shell Overview Board role

- Holds the top-level continuity identity for the flagship surfaces.
- Surfaces context and transition continuity to Time/Today without replacing Today/Goals/Capture/Time/You as IA.
- Uses `QuietGlass`, `GraphiteRecess`, and `CelestialField` as primary visual language.
- Supports reduced-dominance chrome, non-color-only emphasis, and calm transition rhythm.

## Moat Alignment Visual Addendum role

The addendum is a required supporting canon proving moat mechanics in visual
copy, interactions, and evidence paths:

- Why this recommendation is shown.
- What changed in execution continuity.
- Where recovery/closure goes when outcomes are not met.
- How recommendation/receipt behavior can be inspected and corrected.
- How Personal Runtime and local trust controls are bounded by local data boundaries.

## Shared material system

- Shared token families:
  - base layers, glass, recess, trace, lumen, and celestial materials.
- Shared behavior:
  - contrast-safe emphasis (not color-only),
  - 44pt minimum interactive targets,
  - reduced-motion equivalents,
  - bounded transitions.
- Shared icon grammar:
  - `AmbitionsIconGrammar` with visual consistency across Today, Goals, Capture,
    Time, and You.

## Shared interaction primitives

- Continuity anchors:
  - `ContinuityDock`
  - `ContextCrown`
  - `ReflowCrown`
- Trust and explainability:
  - `TrustSeam`
  - `ReceiptSurface`
  - `Why this?` path for recommendation and recovery.
- Visual proof:
  - `LuminousTrace` and object transitions that preserve source continuity.

## Today / Reality Meridian rules

- Start Here is attached to the Meridian expansion surface and never detached as
  a standalone card.
- Start Here cannot degrade into agenda/focus/task-list/card-stack/dashboard surfaces.
- Day-level state must expose bounded proof continuity and recovery paths.
- Route reveal is allowed only in explicit expansion or user-intent states.

## Goals / Constellation Atlas rules

- One constellation icon per life area uses line-and-point geometry.
- Atlas is directional and continuity-first, not a score or ranking table.
- Life area transitions must preserve mission continuity and do not produce
  habit rings or KPI scoreboards.
- Proof trail and recommendation rationale remain discoverable from Goal outcomes.

## Capture / Atmosphere Composer rules

- Rest state is composer-first.
- No route labels/chips visible at rest.
- Route reveal is post-input or explicit expansion.
- Capture surfaces must remain intake-first and route intent must not become feed/inbox/chatbot metaphors.

## Time / LifeShape Field rules

- Time is the capacity owner (`Time` top-level) for day/week/month shaping.
- Day = bounded day ledger.
- Week = seven bounded day lanes with Reflow Crown.
- Month = node-grid view (`LifeShapeMonth`) with clear date ownership.
- No cross-date state bleed unless commitment semantics span boundaries.
- No terrain/blob/weather maps, no chart replacement, no unsafe auto-reflow.

## You / User System Profile rules

- You is system profile and control surface, not social/account/admin.
- Planning Setup remains primary for setup and defaults.
- Personal Runtime surfaces expose local learning controls, recommendation
  boundaries, reset/forget actions, local storage controls, and trust toggles.

## Moat addendum state references

- Ambition Graph state should be reflected in Goals and Today continuity.
- Proof/Recovery state should be traceable from capture and execution closures.
- Recommendation trace must include source + reason + control path.
- Personal Runtime must include reset/forget/purge controls and local trust
  boundaries.

## SwiftUI component mapping targets

- Continuity / shell
  - `ContinuityDock`
  - `ContextCrown`
- Trust and reasoning
  - `TrustSeam`
  - `ReceiptSurface`
- Material
  - `QuietGlass`
  - `GraphiteRecess`
  - `LuminousTrace`
  - `CelestialField`
- Symbol system
  - `AmbitionsIconGrammar`
- Today
  - `RealityMeridianView`
  - `MeridianExpansionSurface`
  - `ProofBackedStartHere`
- Goals
  - `ConstellationAtlasView`
  - `LifeAreaConstellationIcon`
  - `AmbitionGraphView`
  - `ProofTrailView`
- Capture
  - `AtmosphereComposerView`
  - `CaptureRouteRevealView`
  - route surfaces
- Time
  - `LifeShapeFieldView`
  - `PressureLedgerDayView`
  - `PressureLedgerWeekView`
  - `LifeShapeMonthView`
  - `ReflowCrown`
  - `ReflowPreviewView`
- You
  - `UserSystemProfileView`
  - `PersonalRuntimeView`

## Preview fixture matrix

Required fixture names for proof planning:

- Today_RealityMeridian_Default
- Today_ProofBackedStartHere
- Today_RecoveryThread
- Goals_ConstellationAtlas_Default
- Goals_AmbitionGraph_ProofTrail
- Capture_AtmosphereComposer_Resting
- Capture_RouteReveal_PostInput
- Time_Day_PressureLedger
- Time_Week_ReflowCrown
- Time_Month_LifeShapeNodeCalendar
- Time_ReflowPreview
- You_UserSystemProfile_Default
- You_PersonalRuntime_LocalTrust
- Moat_Addendum_AllStates

## Accessibility requirements

Visual-only completion cannot be claimed without proof. Every implemented object
must include:

- VoiceOver semantic grouping.
- Dynamic Type responsiveness.
- Reduce Motion alternatives.
- Contrast-safe state encoding.
- 44pt minimum hit targets.
- Non-color-only state meaning.
- Explicit and stable focus order.

## Anti-drift / Hard Red rules

Forbidden drift:

- Reintroducing `Plan` as a top-level IA tab.
- Turning Today/Goals/Capture/Time/You into generic productivity patterns.
- Introducing cloud-hosted intelligence or hosted personal-data dependency in core.
- Claiming accessibility, privacy, release, or performance readiness without proof.
- Introducing shame language or silent automation with no receipts and no "Why this?".

Hard stop triggers:

- task-list dashboard drift,
- detached Start Here card,
- capture anti-pattern drift,
- plan-like sixth top-level surface,
- non-reasoned recommendation behavior.

## Validation and proof honesty

- Control-plane installation is documented in:
  - `docs/codex/VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY.md`
  - `docs/codex/VISUAL_CANON_MOAT_BATCH_TRAIN.md`
  - `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_VISUAL_CANON_MOAT_OVERLAY.md`
  - `docs/status/visual-canon-moat-installation-report.md`
- This specification is not a substitute for runtime or accessibility proof.
- Front-end batches must still generate local visual proof and scan results.

## Next implementation sequence

1. Source truth alignment and visual authority install.
2. Ambition Graph foundation support.
3. Proof / recovery / closure domain support.
4. Recommendation explainability and Trust Seam.
5. Personal Runtime / local trust controls.
6. Shared materials and shell primitives.
7. Today surface.
8. Capture surface.
9. Time surface.
10. Goals surface.
11. You system profile and controls.
12. Moat addendum screens.
13. Accessibility equivalents and motion safeguards.
14. Preview fixture and visual QA gates.
15. Final integration with proof-honest status notes.
