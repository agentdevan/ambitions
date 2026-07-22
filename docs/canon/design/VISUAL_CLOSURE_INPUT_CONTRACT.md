# Ambitions VC-01–VC-14 Visual Closure Input Contract

Status: `ACTIVE_RECONCILED_BASELINE / FIGMA_NOT_AUTHORIZED`

Date: 2026-07-22

Machine peer: `docs/canon/design/visual-closure-input-contract.json`

This contract is the sole active visual input for VC-01 through VC-14. It
normalizes the provisional visual system against the controlling owner record,
accepted reconciliation ADRs, canonical UX Blueprint, and reconstruction plan.
It authorizes visual-closure studies only. It does not select Figma work,
approve SwiftUI, authorize implementation, or prove runtime capability.

## Classification vocabulary

- `ACTIVE_RECONCILED_BASELINE`: current input to VC-01–VC-14.
- `HISTORICAL_REFERENCE`: retained provenance that cannot control current work.
- `DEFERRED_CANDIDATE_REQUIRING_OWNER_REVIEW`: candidate that may be assessed
  but cannot become current without the named review.
- `IMPLEMENTATION_DETAIL_NOT_YET_AUTHORIZED`: exact implementation choice that
  visual closure may study but cannot install.
- `SUPERSEDED`: replaced by the controlling owner reconciliation.

Every `VAD-R1-*` record in `VISUAL_SYSTEM_R1.md` is classified by the machine
peer. The historical Revision 1 corpus cannot become active by implication;
only rules repeated in this contract are active.

- `ACTIVE_RECONCILED_BASELINE`: `VAD-R1-SYS-001`, `VAD-R1-SYS-003`, and
  `VAD-R1-SPACE-001`.
- `HISTORICAL_REFERENCE`: `VAD-R1-FIGMA-001` and `VAD-R1-FIGMA-003`.
- `DEFERRED_CANDIDATE_REQUIRING_OWNER_REVIEW`:
  `VAD-R1-APPEARANCE-004` and `VAD-R1-SYSTEM-004`.
- `IMPLEMENTATION_DETAIL_NOT_YET_AUTHORIZED`: `VAD-R1-MOTION-001`,
  `VAD-R1-SYSTEM-002`, `VAD-R1-FIGMA-002`, `VAD-R1-FIGMA-004`, and
  `VAD-R1-FIGMA-005`.
- `SUPERSEDED`: `VAD-R1-SYS-002`, `VAD-R1-TYPE-001`,
  `VAD-R1-MATERIAL-001`, `VAD-R1-SYSTEM-001`, `VAD-R1-SYSTEM-003`,
  `VAD-R1-TODAY-001` through `005`, `VAD-R1-SURFACE-001` through `008`,
  `VAD-R1-COVERAGE-001`, `VAD-R1-APPEARANCE-001` through `003`,
  `VAD-R1-APPEARANCE-005`, `VAD-R1-APPEARANCE-006`, and `VAD-R1-A11Y-001`
  through `003`.

## Active direction IDs

The active set is exact and closed:

1. `AVF-DNA-S07-R00`
2. `AVF-SHELL-S07-R01`
3. `AVF-CAPTURE-S07-R01`
4. `AVF-GOALS-S08-R00`
5. `AVF-TIME-S07-R01`
6. `AVF-TODAY-S10-R00`
7. `AVF-SEARCH-D07-R01`
8. `AVF-YOU-D07-R02`
9. `AVF-RECOVERY-S07-R01`
10. `AVF-A11Y-S07-R00`
11. `AVF-COHERENCE-S07-R00`

`AVF-GOALS-S07-R01` is historical and superseded by
`AVF-GOALS-S08-R00`. `AVF-TODAY-S09-R00` is historical and superseded by
`AVF-TODAY-S10-R00`. No historical Figma frame is selected.

## Protected characteristics

- Articulated Relief and Native Semantic Continuum remain the cross-surface
  foundation.
- The Crowned Edge Dock remains the target shell under one shell owner and the
  accepted native/custom boundary.
- Today, Goals, Time, and You are the only roots. Search and Capture are global
  non-root systems.
- Goals is Life-Area-led, then Goal-owned, with the inline Linked Goal Lens and
  focused pursuit depth.
- Today presents one Start Here admission, at most one earned Also Fits Now
  admission, then the supporting timeline and owner handoff.
- Week is the first-use Time scale. A last-used scale is restored only when that
  scale is implemented and supported.
- Capture is text-first, bounded, and owner-routed. Search Find/Understand is
  grounded and Search Act transfers to the canonical owner.
- You is settings-first and local/no-account.
- Receipts, Undo, pending, partial settlement, freshness, and recovery
  presentations are capability-gated.
- Adaptive Semantic Continuity supplies equivalent meaning across accessibility
  transformations; it is a proof obligation, not a completion claim.

## Typography

San Francisco is the sole core Ambitions interface family. SF Pro owns
navigation, roots, object identity, current truth, consequence, chronology,
Trust, recovery, forms, settings, and extended reading. Exact temporal and
numeric content may use monospaced or tabular digits from the San Francisco
family.

New York and every other serif are absent from the active baseline. Historical
serif explorations remain `SUPERSEDED`. Exact size, weight, tracking, line
height, and named Figma text styles remain
`IMPLEMENTATION_DETAIL_NOT_YET_AUTHORIZED` until visual validation.

## Appearance and accent

The only active appearance choices are System, Light, and Dark. System follows
the operating-system Light or Dark selection; it is not a third palette. OLED
Dark, atmosphere families, photo-derived atmosphere, sensory themes,
root-specific themes, text-comfort modes, density controls, typography controls,
material controls, and cross-device appearance are not active.

Restrained violet-indigo is the default action accent. It may tint actionable
controls and selected-control emphasis. It never identifies roots, replaces a
semantic color, communicates state alone, or creates glow. Semantic colors are
immutable and independent from appearance accents. Other existing accent
candidates are `DEFERRED_CANDIDATE_REQUIRING_OWNER_REVIEW` pending VC-02
light/dark, contrast, non-color, and coherence review. Exact violet-indigo and
candidate values are not fixed by this contract.

## Material, spacing, and motion

Primary content is opaque, matte, and continuous. Functional material is
limited to the crown, dock, Search, Capture, overlays, menus, transient
consequence review, and other justified chrome. Reduce Transparency receives an
authored opaque equivalent. Glow, decorative glass-content panels, universal
elevation, and atmosphere wash are excluded.

The active spatial doctrine favors negative space, alignment, typographic
contrast, simple dividers, full-bleed object-led roots, and a minimum 44-point
interaction envelope. Exact spacing steps, blur, shadows, radii, durations,
scale transforms, material recipes, Figma collections, variables, and component
APIs remain implementation details awaiting visual validation.

Motion preserves identity, state continuity, direct manipulation, and a static
Reduce Motion equivalent. Exact motion timing and transforms are not active
token authority.

## Capability and architecture boundary

Visual closure may specify the approved target architecture before runtime
implementation, but it must label target-only behavior and may not depict it as
current functionality. The following remain architecture-sensitive:

- one shell owner, independent paths, dock posture, gesture arbitration,
  restoration tiers, stale-target fallback, focus return, and external origin;
- stable Life Area, Event, Schedule Placement, Today admission, and Receipt
  identity;
- current/proposed/accepted/external/stale truth separation;
- canonical-owner mutation, settlement, Receipt, and executable Undo;
- Search/Capture owner transfer;
- operation-specific pending/recovery data;
- system accessibility, focus, localization, RTL, and device proof.

Unsupported capability is omitted or shown only as a clearly labelled target,
unavailable state, or capability gate. A placeholder, type, fixture, historical
frame, or disabled row is not capability evidence.

## Current product scope

- Device family: iPhone.
- Orientation: portrait.
- Scene model: single scene.
- Platform floor: the repository-approved iOS floor.
- External surfaces require their own source, privacy, failure, accessibility,
  simulator, and physical-device proof. Spotlight remains planned only.
- iPad, Mac, Mac Catalyst, visionOS, landscape, multiple windows, and external
  display are outside the current flagship baseline.

## Unsupported visual behavior exclusions

The active VC baseline excludes serif interface type; OLED Dark; atmosphere or
photo-derived controls; user-selectable typography, density, material, sensory,
or root themes; bottom-rail authority; old Goal-led Goals anatomy; three-priority
Today; account/cloud You administration; dictation and broad Capture attachment
parity; Search-owned mutation; unconditional exact restoration; universal
Receipts or Undo; untyped Settlement Ledger; generic pending/later-settlement
claims; unsupported Time scales or calendar replacement as present behavior;
unsupported permissions; and out-of-scope platforms.

## Visual validation still required

VC-01 through VC-13 may resolve only these bounded visual details:

- SF Pro role hierarchy, weight, size, spacing, and long-reading calibration;
- Light/Dark canvas and surface relationships;
- exact restrained violet-indigo values and disposition of existing accent
  candidates;
- functional-material opacity, blur candidate, and opaque substitution;
- spacing, radius, divider, elevation, and shadow candidates;
- motion duration and transform candidates plus static equivalents;
- Crowned Edge Dock geometry within the accepted shell/gesture contract;
- dense, very-dense, large-text, RTL, handedness, and recovery compositions;
- matched cross-root state, appearance, and accessibility coverage.

These are visual-validation choices, not permission to change product meaning,
add appearance axes, create component APIs, or introduce another direction ID.

## Authorization state

- Figma authorization: false.
- SwiftUI approval: false.
- Implementation authorization: false.
- Visual-closure planning input: active.
