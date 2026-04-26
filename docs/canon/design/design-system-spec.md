# Design System Spec

## Purpose

Define exact shared visual rules for transformed Ambitions surfaces.

## Core Visual Standard

- calm
- warm-neutral
- editorial rather than dashboard-like
- tactile without decorative excess
- premium through spacing, contrast control, hierarchy, and restraint

## Typography Hierarchy

### Levels

- `Hero Display`
  - used for the main truth on hero surfaces
  - short phrases only
- `Section Title`
  - used for major modules
- `Primary Body`
  - used for actionable copy and important explanation
- `Secondary Body`
  - used for support text and rationale
- `Meta`
  - timestamps, state labels, supporting details

### Rules

- one hero display treatment only
- no more than three type weights on one screenful
- uppercase reserved for tiny utility labels only
- numeric treatments for time, progress, and pace must be clean and quiet

## Spacing System

Use one rhythm scale:

- `4` micro spacing
- `8` tight spacing
- `12` compact grouping
- `16` standard inner spacing
- `20` strong separation inside hero content
- `24` section break
- `32` major screen break

Rules:

- hero modules use `20` or `24` internally
- stacked modules use `16` minimum separation
- avoid inconsistent half-rhythms

## Layout Rhythm

- strong top offset for hero region
- compressed support metadata
- generous breathing room around primary actions
- no equal-height dashboard card grids on iPhone core surfaces
- continuity surfaces such as ribbons, lightweight drawers, and quiet signals must read as structural layers, not extra cards

## Surface Philosophy

### Backgrounds

- dark mode: warm charcoal / blue-black / near-black navy family; never pure black as the primary app canvas
- light mode: warm-neutral off-white, never stark pure white

### Surfaces

- use tonal lift before border emphasis
- borders are faint, not structural
- material use is subtle and never decorative by default
- glassy elevated surfaces may use translucent dark fills, soft borders, inner light, subtle gradients, rounded corners, and restrained depth
- avoid heavy fake shadows, flat generic cards, and per-screen hard-coded surface colors

## Card Rules

- cards exist to group meaningfully related content
- cards must not become the default answer for every module
- hero zones may use bands or panels instead of standard cards
- cards should avoid nested-card composition unless absolutely necessary
- continuity ribbon, path preview drawer, and trust whisper should prefer rails, bands, or embedded layers over standalone heavy cards

## Row Rules

- row left side: primary identity
- row center: optional contextual support
- row right side: state or affordance
- rows must remain tap-clear and glanceable
- object-persistent rows should keep stable identity treatment when shown across surfaces

## Chip and Badge Rules

- chips indicate state or action scope
- chips stay compact and quiet
- badges are reserved for meaningful pending state, not decorative counts

## Progress Visualization Rules

- prefer segmented bars, rails, or compact ladders
- avoid large rings unless the ring clearly improves comprehension
- pace, pressure, and confidence should not all use the same visual encoding

## Pressure Map Visual Grammar

- pressure uses spatial compression, tonal intensity, and small semantic labels
- do not use analytics heatmap styling
- week density should feel like shaped space, not chart rendering
- feasibility fragility should read as calm caution, not alert red

## Continuity Ribbon Styling

- single-line or compact two-line band
- visually lighter than the hero but stronger than secondary meta text
- may include one direct action only
- should read as a through-line, not a notification
- may carry Save the Day availability, one plan/recovery/status message, stale capture pressure, or one continuity fact
- must be token-driven, accessible, and dismissible where appropriate

## Global Chrome Rules

Global chrome includes the persistent app frame: safe-area/status-bar treatment, app canvas, top header/navigation bar, logo, title behavior, Mode Lens pill, notification/back/overflow controls, bottom tab bar, scroll-edge behavior, sheet/modal headers, screen-edge spacing, panel-to-background relationship, receipt placement, and continuity/status messaging.

Rules:

- near-black navy shell canvas is the flagship dark identity
- amber is the sparse active accent for active tab, primary action, selected focus, protected action, and completion warmth
- inactive tabs and secondary shell controls use muted blue-gray
- bottom tab, header, sheet, receipt, and panel materials must come from centralized tokens
- no one-off tab treatments
- no per-screen shell hacks
- no hidden navigation layers
- no generic toast system for meaningful commands
- Appearance Studio must remain able to influence shell and panel tokens safely
- light mode must retain the same hierarchy and interaction logic
- Dynamic Type, VoiceOver, Reduce Motion, contrast, tap targets, and non-color distinguishability must be verified before claims
- rich shell effects must avoid excessive blur stacking, expensive scroll-tied animations, and repeated calculations that should come from shared projections
- widgets, Live Activities, and other external surfaces must use lightweight snapshots rather than heavy live computation

## Mode Lens Rules

Mode Lens may expose Focus, Triage, Plan, Recover, and Review as contextual emphasis states. It must not add tabs, hide source-of-truth ownership, or route users into a second navigation system.

## Action Closure Tray Rules

Meaningful commands close with a premium receipt tray/panel instead of disposable toast spam. The tray should show what happened, what changed, why, undo where safely supported, correction, next action when relevant, and safe failure states.

## Proof Rail Rules

Proof Rail is a compact evidence layer for Goal Detail, Reviews, and Path Builder. It may summarize proof on top-level Goals, but should not become a dense artifact dashboard.

Proof examples include notes, links, files, calendar completions, reflections, photos, milestone evidence, decisions, feedback received, blocker resolution, and external artifacts.

## Trust Badge Rules

Trust Badge / Trust status is a small treatment for You and Trust Center, surfaced globally only when action is needed. Candidate states include Local only, Synced, Export ready, Calendar local, Needs backup, and Stale widget. Avoid anxiety-inducing always-on warnings.

## Drawer and Split-Layer Rules

### Path Preview Drawer

- attached to the owning goal structure
- shallower depth than a full sheet
- always visibly subordinate to the current phase and next-action content

### Quiet Command Sheet

- premium consumer sheet, not utilitarian menu
- concise sections
- one primary input or action path visible at a time
- should never resemble a terminal or developer palette

### Compact split-pane on iPhone

- one dominant pane and one contextual pane only
- contextual pane uses quieter surface treatment
- split composition is allowed only when it reduces route thrash and does not create dashboard density

## Iconography Rules

- one consistent weight family
- icons support scanning and action memory
- icons do not replace labels when meaning could be unclear

## Depth and Material Rules

- use low-radius shadow or tonal depth only
- blurred material can support overlays, headers, and glance surfaces
- do not combine blur, glow, strong borders, and gradients on one element

## Color Architecture

### Base tones

- charcoal
- graphite
- espresso
- soft stone

### Accent families

- muted gold
- sand
- sage
- blue-gray
- copper

### Semantic signals

- success is calm and restrained
- caution is warm, not alarming orange spam
- risk is serious but not punitive

## Dark and Light Mode Behavior

- dark mode is primary environment
- light mode must retain the same hierarchy and not flatten the product
- both modes use the same spacing and component logic

## Accent Behavior

- accents emphasize primary action and key progress moments
- accent overuse cheapens the product
- one dominant accent per view

## Control Tiers

### Tier 1: Hero action

- 44-52pt height
- highest contrast
- strongest depth

### Tier 2: Secondary action

- same family, lower contrast
- optional tinted fill

### Tier 3: Tertiary action

- text or very light chip
- used for low-emphasis actions

## Sheet / Modal / Full-Screen Cover Rules

### Use sheets for

- fast edits
- rationale reveals
- filters
- compact corrections

### Use full-screen covers for

- Strategy Composer
- Memory Lens deep mode
- onboarding
- immersive focus

### Rules

- sheets should feel attached to the owning route
- full-screen covers should have a clear close or commit outcome

## List and Grouping Rules

- lists should feel authored, not system-default
- groups need clear section ownership
- avoid endless identical rows without hierarchy breaks

## Section Header Rules

- short and descriptive
- not essay-like
- may contain one supporting line if it materially improves comprehension

## Status and Signal Rules

### Signals that must remain distinct

- confidence
- freshness
- pressure
- momentum
- sync state
- continuity
- capture state

Each needs its own:

- label style
- color posture
- icon or shape support
- disclosure behavior

### Living Capture signal posture

- raw: low-structure neutral
- warming: slightly active but unresolved
- attached: linked and calmer
- activated: higher relevance, stronger action readiness
- parked: quiet and intentionally low-pressure

## Batch 63 Implementation Note

Batch 63 adds the first Ambitions 2.0 rich panel foundation in `Sources/Components/RichPanelPrimitives.swift` and extends shared tokens in `Sources/Theme/AmbitionTheme.swift`.

The reusable foundation is intentionally additive. Existing `AppCard`, `WidgetCard`, `HeroCard`, `TagPill`, `StatusChip`, and button styles remain compatible. New work should prefer `AmbitionRichPanel` or the canonical wrappers for hero decision, progress, timeline, schedule, insight, recovery, trust, capture, review, and settings/preference panels when building future 2.0 surfaces.

Semantic state must use text and icon support in addition to color. Batch 63 includes semantic states for confidence, recovery, waiting, protected, focus, capture, trust, review, calendar-derived context, and accessibility verification readiness. These primitives do not redesign Today, Goals, Capture, Plan, or You; later surface batches consume them.

## Accessibility Baseline

- dynamic type must preserve hero and action hierarchy
- minimum comfortable touch targets
- contrast must remain strong in both modes
- color cannot be the only meaning carrier

## Batch 64 Accessibility Nutrition Note

Batch 64 adds the internal Accessibility Nutrition checklist model in `Sources/Accessibility/AccessibilityNutrition.swift`. Future surface batches should use the checklist categories when recording audits for screens, sheets, rich panels, widgets, and external entry points.

Rich panels may expose accessibility verification readiness through semantic state, text, icon, label, value, and hint support. They must not present verified accessibility support to users until a screen-level audit records current evidence and Batch 115 promotes the relevant claim.

Batch 115 owns the final user-facing `You -> Accessibility` summary. It should consume verified, partially supported, unverified, and not-applicable states from the checklist/audit evidence rather than inventing new claim categories.
