# Ambitions Object Frontend Implementation Spec

Status: Final working draft — Waves 0–10 locked
Resume point: None — ready for Codex installation planning
Purpose: Codex-ready frontend implementation overlay for object-first Ambitions surfaces  
Scope: Object composition, interactions, motion choreography, no-card architecture, SwiftUI boundaries, preview/test/proof gates  
Non-scope: Redefining the Ambitions design system, global tokens, base typography scale, base spacing scale, base color palette, or base material system unless a scoped design-system extension is explicitly required

---

## 0. Authority and Non-Override Rule

This document is an implementation overlay. It does not replace or restate the Ambitions design system.

Codex must inherit existing authorities first:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- active Ambitions design-system source
- existing semantic tokens, materials, typography, spacing, color, motion, haptic, accessibility, and shell primitives
- live SwiftUI source, project files, tests, scripts, and current proof evidence

This document may define:

- object-specific surface composition
- object-specific state and interaction behavior
- object-specific motion choreography using existing motion primitives where possible
- object-specific SwiftUI component boundaries
- no-card architecture gates
- preview matrices
- screenshot proof requirements
- focused validation and Codex batch gates

This document may not casually redefine:

- global colors
- global typography scales
- global spacing scales
- global material recipes
- global icon rules
- base haptic vocabulary
- base accessibility requirements
- base shell/navigation behavior

If a surface needs a missing semantic token, missing object primitive, or missing material/state primitive, Codex may add a scoped design-system extension only when the change is justified by an object implementation need and is documented as such.

---

## 1. Wave 0 — Design-System Inheritance Lock

### 1.1 Design-system inheritance

Decision: Inherit the existing Ambitions design system, but allow new object-specific primitives when the existing design system has no equivalent.

Implementation rule:

- Codex must search the existing design system before creating new primitives.
- New primitives start object-local unless clearly shared.
- Design-system additions must be minimal, semantic, and reusable.
- Object batches must not rewrite base tokens for taste.

### 1.2 Base-token modification policy

Decision: Object batches may touch base tokens only when needed; the safer default is no token changes.

Implementation rule:

- Codex may not overwrite existing token definitions for visual preference.
- Codex may propose or implement a focused design-system extension when an object cannot be implemented cleanly with existing primitives.
- Any base token or shared primitive change must include:
  - reason the existing design system is insufficient
  - affected surfaces
  - accessibility impact
  - before/after source impact
  - rollback behavior
  - proof artifact

Required final-report field:

```text
Design system extension: none / scoped / required follow-up
```

### 1.3 Scope of this frontend spec

Decision: This spec defines object composition, interactions, motion choreography, and full implementation contract while referencing existing design-system tokens.

Implementation rule:

- The spec must describe what the object is, how it behaves, what it exposes, what it hides, how it moves, and what SwiftUI owns it.
- The spec must not invent raw visual values such as hex colors, arbitrary corner radii, ad hoc shadows, or one-off spacing constants.

### 1.4 Token reference policy

Decision: Use token names by reference.

Allowed examples:

```swift
theme.spacing.lg
theme.typography.section
theme.colors.textPrimary
theme.motion.animation(reduceMotion: reduceMotion)
```

Forbidden examples:

```swift
.padding(17)
.foregroundStyle(Color(hex: "#E9EEF8"))
.cornerRadius(23)
.shadow(radius: 19)
```

Exception: local geometry constants may exist only when they describe object layout mechanics rather than design-system styling, and they must be named semantically.

Allowed example:

```swift
private enum MeridianGeometry {
    static let nowNodeHitTarget: CGFloat = 48
    static let proofSeamCollapsedHeight: CGFloat = 36
}
```

### 1.5 Primitive placement policy

Decision: Feature-local first, promote to the design system after two or more surfaces need the primitive.

Implementation rule:

- `RealityMeridian*` primitives live under Today first.
- `LifeShape*` primitives live under Time first.
- `Constellation*` primitives live under Goals first.
- `Atmosphere*` primitives live under Capture first.
- `UserSystemProfile*`, `Trust*`, and `Memory*` primitives live under You first unless already shared.
- Shared object primitives may move into the design system only after reuse proves they are genuinely cross-surface.

### 1.6 Visual-change justification

Decision: Visual changes should map to object, state, interaction, accessibility, and proof, but a small visual-polish section is allowed.

Required final-report fields for object work:

```text
Object:
State:
Interaction:
Accessibility:
Proof:
Visual polish:
Design system extension:
```

### 1.7 Existing component preservation

Decision: Rebuild aggressively when an existing component preserves card architecture or weak object language.

Implementation rule:

- Existing components are preserved only when they support object-first architecture.
- Existing components with `Card`/generic naming must be renamed, rebuilt, quarantined, or deleted according to use.
- Compatibility-only wrappers require explicit comments and tests.

### 1.8 Card-removal meaning

Decision: Remove active card architecture, but allow compatibility wrappers with explicit comments and tests.

Card-removal does not ban:

- native sheets
- rows
- drawers
- trays
- grouped controls
- object-specific plates/lenses
- native containers required for accessibility or platform behavior

Card-removal does ban active root composition as:

- vertical stack of cards
- equal-weight card panels
- dashboard tiles
- task cards
- goal cards
- capture cards
- generic panel stacks pretending to be product objects

---

## 2. Wave 1 — Global Object Frontend Constitution

### 2.1 Surface-specific object law

Top-level tabs do not need a single universal layout law. Each surface may have a surface-specific object arrangement, but every surface must still be governed by one dominant object system.

Canonical objects:

- Today → `RealityMeridianSurface`
- Time → `LifeShapeFieldSurface`
- Goals → Constellation Atlas root behavior, public root may remain `GoalsScreen`
- Capture → `AtmosphereComposerSurface`
- You → `UserSystemProfileSurface`

### 2.2 Screen/container ownership

Recommended implementation posture based on Wave 1 answers:

- Existing screen files should remain route/state containers.
- Named object roots should own visual composition where the object is mature enough.
- Screen files may own loading, dependency injection, navigation, sheet routing, and high-level state.
- Object surfaces own geometry, interaction hierarchy, no-card composition, and object-specific depth.

### 2.3 No-card architecture

Priority order:

1. Remove composition architecture that behaves like cards.
2. Remove user-facing card feel.
3. Rename or rebuild active `Card` type names.
4. Remove visual card shape where it remains generic rather than object-specific.

Top-level surfaces must not use repeated equal-weight containers.

Object-purity batches fail Red if active top-level UI has types ending in `Card`, unless explicitly compatibility-only and not rendered by active root UI.

### 2.4 Replacement primitives

Allowed replacements for generic cards:

- object surfaces
- drawers
- rails
- lenses
- trays
- native grouped rows in drill-downs only
- object-specific primitives rather than generic “panel” replacements

Universal depth primitive is surface-specific.

Universal proof primitive is a combination of:

- receipt
- proof path
- trust seam
- lineage drawer

Universal “Why this?” primitive is tapping a proof/source label, opening a Trust drawer or source lens as needed.

Action confirmation is severity-specific:

- lightweight actions may use inline confirmation or receipt tray
- material actions use receipt tray/drawer with inspectable consequence
- sensitive actions may use native sheet/detail confirmation

Avoid generic replacement names like “Panel.” Use object-specific names.

### 2.5 Top-level behavior

Top-level screens must be:

- glanceable
- actionable
- inspectable
- calm

Content density is adaptive by object state. Details may live in drawers, sheets, object zoom/detail screens, or below-object scroll depending on surface.

Primary object detail does not have to preserve visible origin universally; detail behavior is surface-specific.

### 2.6 State architecture

Every object surface must define states for:

- empty
- loading
- low data
- active/normal
- high pressure
- recovery
- source unavailable/stale
- proof/receipt present

Empty states should be:

- instructional
- calm and minimal
- object-shaped, not card-shaped
- directly actionable

Recovery states appear across all surfaces where relevant.

Source/trust states are hidden unless tapped or relevant, except where compact visibility is required by the object.

Object state may be encoded by:

- position
- density
- motion
- text labels
- haptics

All non-text encodings require accessibility equivalents.

### 2.7 Motion and interaction intent

Motion should communicate, in priority order:

1. state change
2. object continuity
3. cause/effect
4. progress/closure
5. relationship between objects

Object transitions are surface-specific.

Closure motion is outcome-specific: it may feel like loop closure, receipt filing, or reality update/reflow depending on outcome.

Gestures may be object-specific but must be discoverable and redundant.

### 2.8 Codex implementation requirements

Every object-install batch should include, at minimum:

- SwiftUI source changes
- view-model/state changes
- preview matrix
- accessibility identifiers/labels

Object-install batches should include tests, screenshot proof, and anti-card scan whenever feasible. If omitted, the final report must record why and create a follow-up gate.

Anti-card/object-purity batches are added as `B04` after T05–T09 unless the surface owner explicitly makes the main object batch responsible.

If Codex cannot fully remove cards in a surface batch, close Yellow with exact leftover files and follow-up gate.

Object batches may create new files inside feature folders, but must document ownership.

Unused old card components should be deleted.

### 2.9 Final frontend feel

Final screenshot must communicate:

- this is not a task app
- this is not a dashboard
- native Apple-level product quality
- a new category
- calm usefulness

Worst failure mode: clear but generic.

Highest bar: Apple Design Award-level native polish, investor-grade category-defining screenshot, daily-use obviousness, and local-first trust/proof.

Frontend thesis:

```text
Instrument-quality life runtime.
```

---

## 3. Wave 2 — Global Shell / Living Chrome

### 3.1 Shell identity

The shell is an A/B/D hybrid:

- almost invisible by default
- native OS control layer when needed
- surface-specific where objects demand different posture

The shell should not visually announce the current tab. Tab/object context is enough.

`AppShellScaffold` should be replaced with object-specific shells where needed. Existing scaffold may remain as a route/navigation wrapper only if it does not dominate object composition.

Top-level labels remain canonical:

```text
Today / Goals / Capture / Time / You
```

Object names appear only surface-specifically, not as a universal top header system.

### 3.2 Tab and destination rail

Preferred top-level navigation form:

```text
Custom Meridian destination rail.
```

Rail visibility is surface-specific. It must not fight the active object.

Tabs may use custom object symbols now if they are premium, accessible, and not ornamental.

Tab reselection should scroll/root reset.

Switching tabs should preserve object state unless memory/performance constraints force a reload.

### 3.3 Global command/add

Global command/add is contextual and visually subordinate. It should not remain a generic persistent floating plus that competes with object actions.

The current floating plus button should be replaced by surface-specific controls or contextual object actions. Global command may still exist, but not as the dominant surface action.

Global command opens as a surface-specific contextual drawer.

The command surface must never look like:

- chat
- search engine
- Raycast clone
- dashboard

Command priority is context-dependent.

Command results/actions are surface-specific. They may render as object-action groups, lenses, or native rows in a drawer depending on context.

Command-K remains supported, but hidden from normal users.

Recent/frequent actions may be remembered locally and inspectably.

### 3.4 Cross-surface continuity

Origin should be preserved through back/origin labels, not necessarily persistent receipts.

A persistent current-life-context indicator is not required. Cross-surface state travels when relevant:

- active step
- current time context
- recent receipt
- source/trust state
- capture draft
- goal thread

Receipts appear for material changes only.

Receipt persistence is severity-based. Receipt placement is action-specific.

### 3.5 Navigation depth

Navigation depth is hybrid/surface-specific.

Object details open according to surface and action state. Details preserve visible origin only for complex objects.

Back behavior combines:

- object-aware back label
- return to exact object state

Deep routes must not fall back into generic structures. Lists/forms are allowed only when implemented as native drill-down utility, not as root composition. Cards are not allowed in active deep routes.

### 3.6 Overlays, sheets, drawers

Preferred depth mechanism is surface-specific.

Closure actions open a dedicated closure surface.

“Why this?” opens a Trust drawer.

Runtime controls open according to sensitivity.

Overlays may dim/blur the object behind them using native material. Drawer/sheet transitions should use object-origin motion.

### 3.7 Shell status and utility controls

Shell utility controls are surface-specific.

“What Ambitions knows” is hidden until source/trust is relevant.

Privacy/local status appears only when external source/sync is involved.

No notification badges.

Ambient current-time/current-context indication belongs to Today and Time only.

### 3.8 Shell motion/haptics

Tab transitions should use object-continuity transition when it preserves orientation and does not harm native feel.

Opening global command should feel like a native sheet.

Material cross-surface handoffs should show:

- source object origin
- destination object landing
- receipt confirmation

Shell haptics occur only for material actions.

Reduce Motion behavior is a combination of:

- native fades
- instant state updates
- no object-origin motion where it would create unnecessary movement
- essential sheet/drawer transitions only

### 3.9 Shell implementation boundary

Shell batches may modify all shell files if scoped and tested:

- `AmbitionsRootView.swift`
- `AppShellScaffold`
- command router / overlay state
- shell buttons/receipts
- navigation model

Global shell work should happen before object surface batches.

Shell must remove generic card architecture too.

Required new pre-T05 batch:

```text
IOS26-T04J-B07-living-chrome-object-purity.md
```

Shell success definition:

```text
The shell avoids chat/dashboard feel.
```

Supporting criteria:

- disappears behind objects by default
- provides calm continuity
- makes command/actions fast
- preserves native iPhone trust, accessibility, and orientation

---

## 4. Wave 3 — Today / Reality Meridian

### 4.1 Today core identity

Today primarily answers:

```text
What should I do now?
What is the reality of my day?
```

Today should feel like:

```text
A live current through the day.
```

Today must avoid:

- task list
- calendar agenda
- dashboard
- card stack
- AI suggestion screen

Primary visible object:

```text
Reality Meridian with Start here embedded.
```

Start here is collapsed by default and expands from the Meridian.

Today thesis:

```text
An instrument-quality current-state surface for starting, adapting, and closing the day.
```

### 4.2 Reality Meridian geometry

Reality Meridian is a seamless layered instrument with now/current/future zones.

It combines:

- vertical semantic spine
- below-surface contour/rail

Time is adaptive by day state.

Now position is a moving current marker and adaptive as needed.

Past/completed items:

- most recent visible
- older history visible by scrolling up
- clearly historical by design

Future/later items:

- soonest upcoming visible
- later items visible by scrolling down

Capacity is encoded by all of:

- node density
- spacing/compression
- labels
- field pressure
- motion/reflow
- accessibility labels

Protected time appears through:

- hard boundary
- muted protected field
- lock/edge marker
- text label

Free/open time appears through:

- open space
- “Use this time” action zone
- capacity glow/field
- text label
- adaptive behavior

Waiting/blocked states are combination states. Recovery softens density, lightens Start here, shows recovery current, and hides nonessential depth.

### 4.3 Start here

Start here is the current node expanded from the Meridian. It includes by default:

- step title
- why now
- time/capacity fit
- source/proof label
- CTA

It is collapsed by default, with strict hierarchy.

Primary CTA is contextual by step state.

Secondary actions are adaptive.

“Why this?” is a tappable proof/source label.

Start here should be absent in protected time and replaced with an appropriate state. Low-confidence Start here opens a clarifying or trust/source path rather than pretending certainty.

High pressure combines lighter step, closure/recovery first, protected-time conflict, and reflow prompt.

Early finish uses Momentum Reflow:

- Ride momentum
- Use this time elsewhere
- Continue this step
- Make original step lighter

Rejecting Start here combines:

- “Not this?” reason
- another step when useful
- command/action drawer when needed
- local learning

### 4.4 Detail depth and no-card replacement

Supporting information is object-state-specific and may live in drawers, lenses, sheets, details, or scroll.

Existing Today depth pattern must be removed/replaced with object-specific depth.

Generic message/empty/loading cards become object-specific replacements.

No repeated equal-weight containers in active Today UI.

Today object-purity bans all of:

- `Card` type names
- dashboard-like sections
- task list layout
- calendar agenda layout
- equal-weight panel stacks

Top-level detail is organized by object state, not generic sections.

Today scrolls, but the Meridian scrolls as one object.

The Meridian remains visible or not depending on detail type.

Step Detail opens depending on action severity.

Step Session is supported, launched only from `Start now` / `Open step`.

### 4.5 Closure and recovery

Closure is outcome-specific and may feel like:

- loop closure
- receipt filing
- reality update

Required visible closure states:

- Completed
- Still Counts
- Moved
- Skipped / Not Needed
- Blocked
- Waiting
- Needs Recovery
- Needs Review

Still Counts is hidden unless user chooses closure detail.

Missed/unclosed prior steps use a combination of:

- soft closure prompts
- recovery tray
- quiet Meridian residue
- review path

Recovery tone:

```text
Comforting, direct, and supportive. No cheerleading, no fake AI personality, but not unaware of sensitivity.
```

Recovery actions include all relevant:

- Make lighter
- Move
- Still counts
- Not needed
- Protect time
- Ask for help

Closure confirmation combines receipt tray, inline Meridian update, and drawer receipt where needed.

Closure affects future recommendations only after user-approved reflow when the change would materially mutate visible schedule/recommendation state.

Recovery reduces Today density only when pressure is high.

Today never uses shame. Factual urgency is allowed.

### 4.6 Proof, source, trust

Source/proof is hidden behind Trust drawer by default, except where compact labels are required.

Proof attaches to all relevant objects:

- Start here
- Meridian nodes
- closure receipts
- goal thread

“Why this?” shows all, prioritized:

- time fit
- goal thread
- capacity fit
- source freshness
- user preference/default
- what changed

Proof/source copy is concise by default and detailed on open.

Stale/unavailable source uses a combination of:

- fallback recommendation
- refresh/update prompt
- downgraded confidence
- hiding affected recommendations if needed

“What Ambitions knows” routes to You from Today.

Receipt history lives in Today drawer, You/history, and searchable later.

### 4.7 Today motion/haptics

Today motion metaphor is mapped by action:

- Meridian current
- Reality reflow
- Aperture opening
- Receipt filing

Start here appears by expanding the current node.

Rejecting a step opens reason sheet without motion emphasis, then shows replacement reflow.

Closure motion depends on closure type.

Haptics fire for material actions, subtly.

Reduce Motion replaces Meridian motion with a combination of fades, instant state updates, simple label/opacity changes, and native sheet transitions.

### 4.8 Today SwiftUI contract

Named root:

```swift
RealityMeridianSurface
```

`TodayScreen` becomes a hybrid container.

`RealityMeridianView` should be renamed/rebuilt.

`TodayExecutionDepthDisclosure` should be renamed/rebuilt as object-specific depth.

Today object-purity batch checks all:

- no active `Card` types
- no equal-weight panel stacks
- Reality Meridian above-fold dominance
- Start here connected to Meridian
- closure/proof still accessible

Today previews must include all:

- normal day
- tight day
- recovery day
- low-data day
- protected-time day
- source-stale day
- empty day
- Dynamic Type
- Reduce Motion

Today tests must prove:

- Start here visible/expandable
- card architecture removed
- closure states work
- recovery prompt appears
- source/proof is inspectable
- accessibility labels exist

Object-purity handling:

```text
T05-B01 owns Today object-purity and card removal.
No separate T05-B04 unless T05-B01 leaves accepted-Yellow leftovers.
```

### 4.9 Today success criteria

Today succeeds when:

- user knows where to start
- user understands day reality
- user can close/recover without shame
- user can inspect why
- it no longer looks like cards/list/dashboard

First screenshot priority:

1. Personal life OS
2. calm premium native app
3. new category
4. not a task list

Biggest Today failure modes:

- task list
- dashboard
- too abstract
- too much copy
- Start here feels like AI suggestion card

---

## 5. Wave 4 — Time / LifeShape Field

### 5.1 Time core identity

Time primarily answers all, ranked by state:

- What time do I actually have?
- Where is my capacity under pressure?
- What is protected, fixed, flexible, or open?
- How should my goals fit into real life?

Time should feel like:

```text
A native time instrument / private command surface for shaping time.
```

Time thesis:

```text
A native time instrument for shaping commitments around actual human capacity.
```

Time must avoid:

- Apple Calendar clone
- Google Calendar clone
- agenda list
- productivity dashboard
- card stack
- scheduling SaaS

Primary visible object combines:

- LifeShape Field
- compact horizon control
- current capacity summary

### 5.2 LifeShape Field geometry

Core field geometry is adaptive by horizon.

Time representation is a combination of:

- clock-based segments when needed
- semantic zones
- capacity bands
- commitment/protected/open regions

Main visual units:

- Time Blocks
- Capacity Windows
- Pressure Bands
- Protected Edges
- Open Time Regions
- Goal-Time Threads

Actual calendar events are all of:

- fixed anchors
- muted source blocks
- protected/fixed boundaries
- detail after tap
- adaptive by importance

Open/free time appears as:

- visible open space
- capacity glow/field
- “available to shape” region
- recommended insertion target

Protected time appears as:

- hard boundary
- lock/edge marker
- muted protected field
- non-interactive region

Flexible time appears as:

- softer movable region
- dotted/elastic boundary
- can-move affordance
- detail label where needed

Pressure is encoded by all, with accessibility equivalents.

Recovery is encoded by all:

- softened field
- lighter recommended time blocks
- reduced density
- protected recovery zone

Goal-time is adaptive.

### 5.3 Horizon model

Supported scopes:

```text
Day / Week / Month / Year / Life Range
```

Default scope:

```text
Last used.
```

Scope switching is primarily horizon scrubber and adaptive.

Day view emphasizes all:

- current commitments
- open capacity
- protected time
- pressure/recovery

Week view emphasizes all:

- pressure distribution
- goal-time placement
- recovery/protected balance
- commitments/openings

Month view emphasizes all:

- life areas
- pressure weeks
- protected time
- milestones
- recovery rhythm

Year / Life Range emphasizes:

- seasons of pressure
- life-area balance

Month, Week, and Day must avoid calendar-clone, agenda-list, task-board, card-stack, and heatmap-dashboard feel.

Time connects to Today by all:

- Today current step
- Start here placement
- capacity fit proof
- protected/open context

### 5.4 Time operations

Primary Time action is contextual.

Users can create all:

- protected block
- flexible block
- goal-time block
- recovery block
- away/vacation block

These operations should replace reasons to use Calendar for Ambitions-owned life shaping, without becoming a Calendar clone.

Tapping open time uses a combination of:

- recommended step placement
- protect time
- mark recovery
- use this time elsewhere
- object-action drawer

Tapping protected time uses:

- explanation
- edit if user-owned
- no silent mutation
- affected recommendations

Conflict/pressure region uses:

- conflict explanation
- reflow
- lighter step
- move/protect/recover

Schedule mutation requires all:

- explicit approval
- preview
- receipt
- never silent

Reflow preview shows all:

- before/after
- what moved
- why it changed
- effect on Today/Goals
- proof/receipt consequence

Vacation/away is all:

- hard unavailable by default
- available only if user marks it so
- visually distinct from free time
- editable with per-away override

Commute/buffer time is surfaced as field edges, accounted for, editable per event, and surfaced when it affects recommendations.

### 5.5 Detail depth and no-card replacement

Supporting details are object-specific and may use field drawers, lenses, sheets, details, or scroll.

Time does not allow repeated equal-weight containers.

Existing calendar/list/card-like UI becomes object-specific replacements.

Top-level Time detail is organized by horizon.

Time scrolls; LifeShape Field scrolls where appropriate and can adapt by horizon.

LifeShape Field remains visible depending on detail type.

Time detail opens depending on action severity.

Time object-purity bans all:

- active `Card` type names
- calendar clone layout
- agenda list root
- dashboard widgets
- equal panel stacks

### 5.6 Trust, source, proof

Calendar/source data appears through a combination of:

- source labels
- compact defaults
- trust/source drawer
- stale/unavailable states

Source freshness affects all:

- recommendations
- confidence
- field rendering
- user prompts

Stale sources use a combination of:

- stale state
- refresh/update prompt
- local last-known view
- downgraded recommendations

Time receipts created for all:

- protected block changes
- schedule mutation
- reflow approval
- recovery block creation
- away/vacation changes

Proof attaches to all relevant:

- time operation
- affected step
- affected goal thread
- changed time region

“What Ambitions knows” from Time routes to You.

### 5.7 Time motion/haptics

Time motion metaphor maps:

- field reflow
- pressure softening
- horizon zoom
- protected edge lock/unlock

Switching scopes uses field morph/adaptive transition.

Reflow approval animates all when not Reduce Motion:

- before/after
- movement path
- receipt filing
- affected regions settling

Protecting time uses:

- boundary forming
- region locking
- subtle receipt

Haptics fire for all material actions, subtle.

Reduce Motion uses a combination of fades, instant state change, labels/before-after states, and native sheet transitions.

### 5.8 Time SwiftUI contract

Named root:

```swift
LifeShapeFieldSurface
```

`TimeScreen` becomes a hybrid container.

Existing `TimeLifeShapeField` should be renamed/rebuilt.

Object-purity handling:

```text
T06-B02 owns Time object-purity and card/calendar removal.
No separate T06-B04 unless T06-B02 leaves accepted-Yellow leftovers.
```

Required previews:

- normal day
- tight day
- protected-time day
- open-time day
- recovery day
- stale-source day
- away/vacation day
- week pressure
- month pressure
- Dynamic Type
- Reduce Motion

Required tests:

- no calendar clone root
- no card architecture
- protected time distinct from free time
- open time can be shaped
- reflow requires approval
- receipts are created
- accessibility labels exist

Anti-card scan checks all:

- active `Card` type names
- calendar-grid clone root
- agenda-list root
- dashboard/widget language
- equal panel stacks

### 5.9 Time success criteria

Time succeeds when:

- user sees real available capacity
- protected/open/flexible time is obvious
- Time does not look like calendar app
- user can shape time without silent mutation
- Today/Goals fit into Time clearly

First screenshot priority:

1. premium native product

Biggest failure modes:

1. card stack
2. too abstract
3. weak connection to Today/Goals

---

## 6. Wave 5 — Goals / Constellation Atlas

### 6.1 Goals core identity

Goals primarily answers:

```text
What am I building toward?
```

Goals should feel like:

```text
A native instrument for long-range direction.
```

Goals thesis:

```text
A Constellation Atlas that turns goals into connected, inspectable direction.
```

Goals must avoid:

- task/project list
- Trello/kanban board
- KPI dashboard
- goal cards
- habit/progress rings
- Notion database

Primary visible object combines:

- Constellation Atlas
- compact goal-thread focus
- adaptive maturity behavior

### 6.2 Constellation Atlas geometry

Core concept:

```text
Solar-system-like Atlas, with life areas as planets.
```

Recommended implementation interpretation:

- Life areas are planets/territories.
- Goals orbit or anchor around those life-area bodies.
- Goal maturity determines whether a goal renders as a node, orbit body, thread origin, or region marker.
- Relationships remain hidden until selected by default.
- Active goal threads become inspectable paths, with a scrubbable timeline showing all steps.

Life areas appear as atlas regions.

Importance is shown through a combination of:

- size/weight
- position/proximity
- source/proof density
- user pinning/focus
- explicit label where needed

No life ranking. Focus/current priority is allowed.

Goal status uses all with accessibility equivalents:

- node state
- proof trace
- thread tension
- horizon placement
- text label

Stalled goals are adaptive.

Completed or archived goals:

- archived goals visible as archived constellation layer
- accessible through proof/history
- detail access where needed
- adaptive behavior

Density handled by clustering, semantic zoom, lenses/filters, and command when needed while keeping root object-first.

### 6.3 Goal hierarchy and relationships

Primary goal object is depth-specific.

Goal Thread is first-class and visible at root.

Sub-goals are explicit hierarchy.

Dependencies are visible in Atlas.

Conflicts are visible.

Relationship types support fewer visible types:

- supports
- drains
- blocks
- depends on

Life areas are visually equal-weight, with user focus/pin allowed.

Goals are not ranked, but focus/current priority and user-defined priority are allowed.

Primary goal is contextual by Today/Time.

Inactive or someday goals appear as distant/quiet layer.

### 6.4 Progress, proof, milestones

Progress uses all except generic percentage, adaptive by goal type:

- proof trail
- milestone path
- thread brightness/density

Percentage complete appears only in detail, not root.

Rings/bars are avoided unless necessary.

Milestones use a combination of:

- nodes along thread
- orbit markers
- proof anchors
- detail rows

Proof attaches to all relevant:

- goal node
- thread
- milestone
- step/action

Proof visibility is adaptive.

Goals with no proof use adaptive starter/first-step/clarify/low-data behavior.

Pivoted goals show pivot marker.

Goal completion uses a restrained combination of:

- proof closure
- orbit settling
- milestone arrival
- receipt filing
- celebration where appropriate

Goal abandonment/not-needed uses all:

- calm closure
- archive with receipt
- proof preserved
- recovery-aware tone

### 6.5 Goal actions

Primary action is contextual.

Tapping goal node is adaptive by tap target:

- open detail
- focus/zoom node
- reveal thread relationships
- open object-action drawer

Secondary action combines:

- object actions
- relationship controls
- proof/source
- not required for primary path

Creating a goal can start from all:

- create flow
- global command
- Capture promotion
- selected life area

Goal creation asks all progressively:

- what outcome
- why it matters
- horizon
- constraints/capacity
- proof/milestone

Goal detail emphasizes all, ranked by goal state.

From a goal, user can do all:

- create step
- schedule/shape time
- attach capture
- close/pivot/archive
- inspect proof

Goals offer `Start now`, `Shape time`, and `Why this goal?` inside detail only.

### 6.6 Detail depth and no-card replacement

Supporting details may live in Atlas drawers, goal lenses, native navigation detail, scroll, or other object-specific structures.

No repeated equal-weight containers in Goals.

Existing goal-list/card/board UI becomes object-specific replacements.

Top-level detail organization is by:

- horizon
- life area
- object state

Goals scrolls/pans through Atlas.

Atlas remains visible depending on detail type.

Goal detail opens depending on goal/action state.

Object-purity bans all:

- active `Card` type names
- goal-card root layout
- list root
- kanban/board root
- KPI/ring/dashboard root
- equal panel stacks

### 6.7 Trust, source, proof

Source/capture lineage is detail-only by default.

Captures attached to goals use a combination of:

- source sparks
- thread inputs
- detail list
- proof/source lens

Goal recommendations explain all, prioritized:

- why now
- goal relationship
- time/capacity fit
- proof gap
- source/capture lineage

Thin goal source/proof uses a combination of:

- clarification
- suggest capture
- create starter thread
- low-data state

“What Ambitions knows” from Goals routes to You.

Goal receipts are created for all material actions:

- create goal
- attach capture
- create step
- pivot
- archive/close
- relationship changes

Proof transfers appear when:

- pivoting
- merging/splitting goals
- changing milestones
- archiving as no longer needed

### 6.8 Goals motion/haptics

Goals motion metaphor maps all:

- constellation orbit
- atlas zoom
- thread drawing
- proof lighting

Selecting a goal is adaptive:

- zoom/focus
- draw relationships
- open detail
- lift node

Creating a goal animates all when not Reduce Motion:

- node appearing
- thread forming
- placement into life area
- receipt filing

Pivoting animates all when not Reduce Motion:

- thread redirection
- proof transfer
- old path dimming
- new path forming

Haptics fire for all material goal actions, subtle.

Reduce Motion uses combination:

- fades
- instant state change
- labels/before-after
- native navigation/sheet transitions

### 6.9 Goals SwiftUI contract

Public Goals root may remain:

```swift
GoalsScreen
```

`GoalsScreen` becomes hybrid container.

Existing list/card/board components should be renamed/rebuilt into Atlas primitives.

Object-purity handling:

```text
T07-B01 performs the primary Atlas installation.
T07-B04 is required before T08 as a Goals object-purity / anti-card closeout batch.
```

Required new batch:

```text
IOS26-T07-B04-constellation-atlas-object-purity.md
```

Required previews:

- few goals
- many goals
- low-data goal
- stalled goal
- active goal thread
- pivoted goal
- completed/archived goal
- life-area cluster
- Dynamic Type
- Reduce Motion

Required tests:

- no goal-card root
- no list/board root
- Constellation Atlas visible
- relationships inspectable
- proof inspectable
- create/pivot/archive receipts exist
- accessibility labels exist

Anti-card scan checks:

- active `Card` type names
- `GoalCard` / dashboard naming
- list root
- kanban/board language
- KPI/ring/score language
- equal panel stacks

### 6.10 Goals success criteria

Goals succeeds when:

- user sees direction, not tasks
- goal relationships are understandable
- proof is visible without dashboarding
- Goals connects to Today/Time/Capture
- no cards/list/board root remains

First screenshot priority:

1. Constellation Atlas
2. premium native product
3. long-range direction

Biggest failure modes:

- task/project list
- kanban/board
- card stack
- too abstract
- no clear action
- weak connection to Today/Time/Capture

---

## 7. Wave 6 — Capture / Atmosphere Composer

Status: **Locked.**

### 7.1 Capture core identity

Capture primarily answers:

```text
How do I get this out of my head without organizing it manually?
```

Capture should feel like:

```text
A private thought-routing instrument.
```

Capture must not present as:

- Notes app
- inbox
- task list
- chat UI
- feed
- dashboard/card stack

Primary visible object:

```text
Adaptive by whether there is input.
```

Before input, the surface is quieter and composer-led. After input, it becomes route-aware and object-placement oriented.

### 7.2 Atmosphere Composer geometry

Atmosphere Composer model:

```text
Bottom-first composer with route preview.
```

Core geometry:

```text
Bottom composer anchored near the thumb zone.
```

Composer placement:

```text
Centered atmospheric empty-state object that settles toward bottom/thumb-zone behavior once input begins.
```

Implementation note:

- The empty state may center the composer as the primary atmosphere object.
- Once the user types, speaks, or adds content, the composer must become a practical thumb-zone capture control.
- Codex must not implement a chat-style transcript field.

Before input:

```text
Adaptive.
```

The empty state may show only the composer, gentle instruction, route possibilities, contextual examples, or recent state only when context makes those useful. It must not become tutorial-heavy, feed-like, or card-based.

After input:

```text
Adaptive combination of route preview, placement options, clarification prompt, and receipt.
```

Final behavior is determined by routing confidence, sensitivity, and whether the placement is material.

Route preview appears:

```text
Above the composer.
```

The route preview must not be a card. It should be implemented as an object-specific route lens or placement field that belongs to the Atmosphere Composer.

The capture atmosphere encodes:

- input state
- route confidence
- placement destination
- source/privacy state
- local processing/transformation state
- accessibility equivalents for each visual state

Captured text remains visible adaptively by input length:

- short captures may remain visible inline until placed
- long captures collapse into a summary with expand/edit affordance
- very long or high-stakes captures may open an editor sheet before placement

Empty-state atmosphere should combine:

- silent premium restraint
- helpful but not tutorial-heavy guidance
- slight celestial atmosphere
- direct action orientation

Celestial/atmospheric visuals:

```text
Present but restrained.
```

Capture may carry more atmosphere than other tabs, but visuals must do product work: orientation, route state, placement transition, or local/private confidence.

### 7.3 Input modes

Primary input model:

```text
Text first, with voice and add/attachment as secondary controls.
```

Voice capture should feel:

```text
Native dictation-style.
```

The mic belongs:

```text
Inside the composer field.
```

The add/attachment button should support all eventually:

- photo/image
- file
- link
- calendar/time source
- goal/source attachment

Links are adaptive:

- source records
- captures to place
- goal/context evidence
- external-intake candidates later

Quick one-tap capture is allowed:

```text
Save as held item, with high-confidence routes allowed to offer fast placement.
```

It must not become silent material placement unless the user has enabled that behavior and the action remains receipted.

Multiline drafting is supported, but the composer should remain visually compact by default.

Command-like entries such as “remind me tomorrow” are supported only as object actions, not chat. They should convert into local command/capture routing behavior.

Goal-like inputs such as “I want to…” route through an adaptive combination of:

- goal creation
- clarification
- starter goal draft
- explicit user confirmation

Step-like inputs such as “I need to…” route through an adaptive combination of:

- step draft
- Time if date/time appears
- Goal if connected
- preview before material placement

### 7.4 Routing and placement model

Canonical route states are all supported:

- Needs a Place
- Ready to Place
- Grow into Goal
- Becomes Step
- Shape Time
- Remember/Context

Root visibility ranking:

1. Needs a Place
2. Ready to Place
3. Grow into Goal
4. Becomes Step
5. Shape Time
6. Remember/Context

`Remember/Context` is intentionally trust-sensitive. It should surface clearly when relevant, but it must not make Capture feel like an opaque memory engine.

A captured item first becomes:

```text
Adaptive by confidence.
```

Possible first states:

- held item
- route candidate
- draft source
- direct object draft when confidence and user intent are strong

Route confidence is hidden unless low/conflicted by default.

When the route is obvious:

```text
Show one recommended placement.
```

Alternatives may exist behind the route lens/drawer, but the default should be one clear recommended placement.

When the route is ambiguous:

```text
Ask one clarification.
```

Manual placement and Needs a Place remain available if the user does not want to clarify.

Route alternatives appear as:

```text
Route paths.
```

Placement destinations include:

- Today step
- Goal thread
- Time block
- User System Profile / memory
- Held item
- Recovery/review

“Why this route?” is exposed by tapping the route label.

If Capture cannot route something, it should combine:

- save as Needs a Place
- ask one clarification
- offer manual placement
- explain what is missing

Route placement may be silent only if user-enabled auto-place is on. Material placement must still be inspectable and receipted.

### 7.5 Capture-to-object transformations

Capture → Goal:

```text
Open Create Goal.
```

The capture must attach as source where relevant.

Capture → Step:

```text
Adaptive.
```

It may create a step draft, attach to known goal, ask for goal/time context, or place into Today if fit.

Capture → Time:

```text
Adaptive.
```

It may create a time block draft, ask date/time clarification, open Time placement, or create a protected/flexible block if obvious.

Capture → You / memory:

```text
Ask whether Ambitions should remember, explain future use, create receipt, and allow correction/delete.
```

Capture → Recovery:

```text
Adaptive.
```

It may create recovery note/context, suggest lighter step, open closure/recovery flow, or mark source for future recommendations.

Capture → Held:

```text
Save quietly with receipt, show held state, prompt later when useful, and expose in Capture drill-down.
```

A capture attached to a goal must:

- remain visible as source
- affect goal recommendation where appropriate
- appear in proof/source lens
- be editable/removable

A capture that becomes a step must:

- preserve original capture text
- show transformed step
- attach receipt
- allow undo

A capture that becomes memory/context must:

- require explicit consent
- show future-use explanation
- be editable/resettable in You
- never infer sensitive identity

Undo after placement:

```text
Yes, always.
```

### 7.6 Detail depth and no-card replacement

Supporting capture details live in a combination of:

- route drawer
- placement lens
- native detail screens
- minimal below-composer depth only when object state requires it

Capture allows no repeated equal-weight containers in active UI.

Existing inbox/list/card-like Capture UI must become object-specific replacements:

- Atmosphere Composer
- route lenses
- held-item drawer
- native drill-down rows
- object-specific placement surfaces

Top-level detail is organized by object state, not generic sections.

Scrolling rule:

```text
Drill-downs scroll only.
```

The top-level Capture surface should remain composer-first and should not become a normal scrolling inbox/feed.

Composer visibility during detail:

```text
Depends on detail type.
```

Capture details open according to action state: sheet, drawer, native navigation, or object expansion.

Capture object-purity bans:

- active `Card` type names
- inbox/feed root
- notes-app root
- chat transcript root
- task-list root
- equal panel stacks

### 7.7 Trust, source, and privacy

Capture local/private status appears in the trust drawer.

When Capture wants to remember something for future recommendations, it must:

- ask explicitly
- show future-use explanation
- create receipt
- allow edit/delete later

Capture must distinguish:

- temporary draft
- held item
- source attached to goal
- memory/context
- proof

Sensitive input must:

- remain local
- avoid logs
- ask before becoming memory
- offer discard

“What Ambitions knows” from Capture routes to You.

Capture receipts are required for all material actions:

- saved held item
- placed into goal
- placed into step
- placed into Time
- saved as memory/context
- discarded when material

Source lineage must be exposed:

- on placement
- in destination object
- in receipt
- in trust lens

### 7.8 Motion and haptics

Capture motion metaphor:

```text
Atmosphere settling, route forming, aperture opening, placement landing, and receipt filing mapped to actions.
```

Typing should combine:

- subtle composer expansion
- route field awakening
- immediate route hints

After submit, route preview is adaptive:

- lift from composer
- settle into route lens
- open drawer
- animate paths to destinations when useful

Placement confirmation should:

- land into destination
- file receipt
- clear composer
- show undo

Haptics should fire on all material actions, subtly:

- capture submit
- placement confirmation
- memory consent
- discard
- route conflict

Reduce Motion replaces atmosphere/route motion with a combination of:

- fades
- instant state changes
- labels/before-after
- native sheet transitions only where needed

### 7.9 SwiftUI implementation contract

Named root:

```swift
AtmosphereComposerSurface
```

`CaptureScreen` becomes:

```text
Hybrid container.
```

It owns screen-level state/loading/shell integration. `AtmosphereComposerSurface` owns object composition.

Existing `CaptureAtmosphereComposer` should be:

```text
Renamed/rebuilt.
```

Existing `CaptureDraftRoutePreviewCard` must be:

```text
Renamed/rebuilt as CaptureRouteLens.
```

Capture object-purity is handled by:

```text
IOS26-T08-B01-atmosphere-composer-dominance.md
```

No separate `T08-B04` by default. If `T08-B01` leaves accepted-Yellow object-purity leftovers, a follow-up may be created, but the intended contract is that `T08-B01` owns Capture card removal.

Required previews:

- empty composer
- text entered
- obvious route
- ambiguous route
- low-confidence route
- memory consent
- held item
- placement receipt
- voice input
- Dynamic Type
- Reduce Motion

Required tests:

- no inbox/feed root
- no chat transcript
- no card architecture
- route preview appears
- placement requires consent where material
- receipts exist
- accessibility labels exist

Anti-card scan checks:

- active `Card` type names
- `CaptureCard` / draft-card naming
- inbox/feed root
- notes/chat/task language
- equal panel stacks

### 7.10 Final Capture success criteria

Capture succeeds when:

- user can enter anything quickly
- Ambitions shows where it can go
- no inbox/feed/card root remains
- user controls memory/placement
- placed captures stay attached as source/proof

First Capture screenshot priority:

1. Premium native product
2. Private local capture
3. Atmosphere Composer

Biggest Capture failure modes:

1. card stack
2. unclear routing
3. task capture list

Final Capture thesis:

```text
A private native composer where anything can become a step, goal, time shape, memory, or held item.
```

---

---

## 8. Wave 7 — You / User System Profile

Status: Locked from user answers.

### 8.1 Core identity

The You surface is a deliberate exception to the earlier “avoid settings wall” anxiety.

You is not a social profile, admin dashboard, AI memory dashboard, profile-card stack, or analytics console. It is:

```text
A premium Personal Profile and Configuration native surface — an Ambitions-themed version of the iOS 26 Settings app.
```

This means You should feel familiar, native, configurable, and trustworthy, while still being Ambitions-specific.

Final You thesis:

```text
A complete configuration hub for all things Ambitions: a premium native surface for personalizing the app specifically to the user across runtime behavior and frontend behavior.
```

The root job of You is to let the user inspect and configure:

- what Ambitions knows
- how Ambitions adapts
- runtime defaults
- frontend/personalization preferences
- privacy and local-first behavior
- export, reset, and delete controls
- trust/source status
- memory correction
- automation and recommendation posture

### 8.2 Relationship to native Settings patterns

You may borrow from iOS 26 Settings as an interaction and organization reference.

Allowed:

- native grouped control surfaces
- settings-style rows
- configuration detail screens
- toggles, pickers, disclosure rows, and confirmation sheets
- profile-like identity summary when useful
- clear hierarchy by consequence and sensitivity

Forbidden:

- generic settings wall with no Ambitions object structure
- social-profile visual language
- profile cards
- admin dashboard
- AI memory/chat settings screen
- analytics dashboard
- equal-weight card stacks
- “smart memory” black-box framing

Codex must treat the Settings inspiration as a native believability model, not a license to create generic rows without runtime consequence.

### 8.3 User System Profile geometry

Named root:

```swift
UserSystemProfileSurface
```

`YouScreen` becomes:

```text
Hybrid container.
```

It owns screen-level state/loading/shell integration. `UserSystemProfileSurface` owns the object composition.

Existing `YouRootSurface` should be:

```text
Renamed/rebuilt.
```

It must not remain the primary semantic owner if it preserves generic settings/card architecture.

The root geometry should be an Ambitions-themed native configuration hub with:

- personal profile/configuration summary
- runtime behavior controls
- trust and memory controls
- privacy/local-first controls
- frontend personalization controls
- export/delete/reset paths
- source and sync status where relevant

### 8.4 Organization model

Because the user answered questions 1–66 with the unified direction “Premium Personal profile and configuration native surface,” Codex should resolve those detailed sub-decisions through this hierarchy:

1. Runtime and recommendation configuration
2. What Ambitions knows / memory correction
3. Privacy, local-first, sync, export, delete
4. Frontend personalization and appearance behavior
5. Planning defaults and automation level
6. Source/trust status
7. Accessibility/status surfaced only where useful

The surface should remain configuration-first, not dashboard-first.

### 8.5 Runtime and frontend personalization

You is the complete configuration hub for both:

```text
runtime personalization + frontend personalization
```

Runtime personalization includes:

- planning aggressiveness
- recovery preference
- protected time rules
- reminder/notification defaults
- source trust/use controls
- personalization/learning controls
- recommendation duration preferences
- capacity fit preferences
- goal pacing defaults
- scheduling/reflow defaults
- automation level

Frontend personalization includes only user-facing configuration that the existing design system permits or that a scoped design-system extension batch explicitly adds.

Examples:

- appearance/accent preference if already supported
- density preference if supported
- surface behavior defaults
- visibility/default expansion of trust/source details
- route/confirmation behavior
- local-only/sync display preferences
- accessibility-related user-facing toggles if supported by platform/design system

Codex must not invent new global visual tokens while implementing frontend personalization.

### 8.6 What Ambitions knows

“What Ambitions knows” remains a major control area, but not necessarily the full root.

The user should be able to inspect, correct, reset, or delete knowledge. Knowledge items should clarify:

- what Ambitions believes
- where it came from
- what it affects
- when it was last used when relevant
- how to edit or delete it
- how changes affect future recommendations

Knowledge correction must create a receipt and update future local recommendations when the corrected knowledge is runtime-affecting.

### 8.7 Privacy, source, export, delete

Privacy/local-first behavior should be handled as user trust and control, not legalistic copy.

The surface must include protected paths for:

- individual knowledge item delete
- capture/source history delete
- closure history delete
- runtime learning reset
- all app data delete/reset
- export of goals, captures, receipts/proof, time blocks/defaults, memory/context, and settings/preferences

Sensitive destructive actions require confirmation and should preserve receipt/proof behavior where appropriate.

### 8.8 Detail depth and no-card replacement

You may use native settings-style detail navigation more than other surfaces because the user explicitly wants an Ambitions-themed iOS 26 Settings-style configuration surface.

Allowed in You:

- native grouped rows
- detail screens
- confirmation sheets
- configuration sections when they express runtime/frontend consequence
- search/inspection inside configuration depth if implemented later

Forbidden in You:

- profile-card root
- card stack root
- admin dashboard root
- AI memory/chat settings root
- equal-weight panel stacks
- generic settings rows with no Ambitions consequence

The root should feel like a premium configuration instrument, not a utility dump.

### 8.9 Trust/source/proof behavior

User must be able to inspect:

- why Ambitions made a recommendation
- what data it used
- what it ignored when relevant
- what it cannot know
- source freshness
- affected surfaces
- correction/reset actions

Proof/receipt history in You should be calm, searchable/filterable when implemented, and not feed-like.

Source failures should:

- appear in You
- appear contextually in affected objects
- never become notification badges
- offer repair/update path

### 8.10 Motion and haptics

You motion should remain native and configuration-oriented.

Motion metaphors:

- control surface opening
- trust lens focusing
- memory correction filing
- runtime switch changing consequence
- receipt filing for material changes

Haptics fire only for material actions, subtly:

- runtime control change
- memory correction
- delete/reset confirmation
- privacy/source change
- export completion

Reduce Motion should use the existing inherited fallback vocabulary:

- native navigation/sheet transitions
- fades
- instant state changes
- labels/before-after where needed

### 8.11 SwiftUI implementation contract

Named root:

```swift
UserSystemProfileSurface
```

`YouScreen`:

```text
Hybrid container.
```

Existing `YouRootSurface`:

```text
Renamed/rebuilt.
```

You object-purity is handled by:

```text
IOS26-T09-B01-runtime-affecting-profile.md
IOS26-T09-B02-trust-memory-controls.md
```

No separate `T09-B04` by default.

Required previews:

- first-run/low-data
- normal trusted state
- stale source
- memory correction
- privacy/export/delete
- automation guided state
- sync/local status
- source failure
- Dynamic Type
- Reduce Motion

Required tests:

- settings wall/card architecture removed
- runtime controls affect output
- memory correction creates receipt
- delete/reset/export paths exist
- source/trust is inspectable
- privacy/local status exists
- accessibility labels exist

Anti-card scan checks:

- active `Card` type names
- profile-card naming
- settings wall root
- admin/dashboard language
- AI memory/chat language
- equal panel stacks

### 8.12 Final You success criteria

You succeeds when:

- user can inspect what Ambitions knows
- user can correct/reset/delete/export
- runtime controls affect recommendations
- frontend controls personalize Ambitions where supported
- local/private trust is clear
- it does not look like profile cards, AI memory dashboard, or admin UI

First You screenshot priority:

1. Premium native product
2. User System Profile
3. Local/private system

Biggest You failure modes:

1. generic profile screen
2. AI memory dashboard
3. admin console

Final You thesis:

```text
A complete configuration hub for all things Ambitions: a premium native surface for personalizing the app specifically to the user across runtime behavior and frontend behavior.
```

---


## 9. Wave 8 — Proof, Receipts, Closure, Recovery

This section was inferred from the user’s prior waves. It is locked as the cross-surface trust system unless later explicitly revised.

### 9.1 Core identity

Proof, receipts, closure, recovery, replay, and source lineage are not separate UI features. They are the trust fabric that makes Ambitions feel local, deterministic, inspectable, and non-shaming.

Primary questions this system must answer:

1. what changed
2. what the user approved
3. why Ambitions changed or recommended it
4. what still counts
5. what can be replayed, inspected, corrected, exported, or undone later

Final system feel:

```text
A calm local proof layer and closure runtime that records what changed, why it changed, what the user approved, and what still counts.
```

Receipts are all of the following:

- user-facing confirmations
- inspectable proof records
- local runtime inputs for future decisions
- exportable history
- source-lineage anchors

Proof is separated by type:

- progress evidence
- source lineage
- decision trace
- user-approved mutation history
- proof transfer record

Closure replaces:

- task-completion-only thinking
- overdue/failure states
- generic review checklists
- streak/productivity pressure

### 9.2 Receipt model

Receipts are required for all material actions:

- Step closure
- Still Counts
- Capture placement
- Goal creation, pivot, archive, relationship change, or milestone change
- Time mutation, protection, recovery block, or reflow approval
- Memory/runtime setting changes
- Source/trust/privacy changes
- Export/delete/reset operations

Receipts are not created for:

- navigation
- opening/closing drawers
- non-mutating inspection
- minor visual state changes

Receipt severity must support:

- informational
- material change
- privacy/data change
- recovery/closure change
- reflow/schedule change

Receipt visibility:

- material receipts appear immediately as a calm tray or object-local confirmation
- receipts then archive into the affected object and You/history
- privacy/data receipts should remain more durable and inspectable
- minor informational confirmations may be brief

Receipt language:

- direct and factual
- warm but not cheerleading
- minimal at rest
- detailed enough on open to prove what happened
- adaptive by severity

Every receipt should include, where applicable:

- action taken
- affected object
- source/reason
- user approval status
- local/private status
- undo/revert path where technically safe
- what changed
- what did not change, if relevant
- downstream effect on Today, Time, Goals, Capture, or You

Visual representation:

- global shell: brief continuity tray only for material actions
- Today: Meridian node marker, closure state, receipt tray, Trust drawer
- Time: field-region marker, operation receipt, reflow proof
- Goals: thread proof light, milestone proof, pivot/proof transfer
- Capture: placement receipt, destination link, undo/revert path
- You: searchable calm receipt history, privacy/source change history, memory correction history

Undo/revert:

- always available when technically safe
- never silent
- may be immediate from receipt for low-risk operations
- material changes use explicit revert flow
- irreversible or destructive operations require protected confirmation

Receipt history must live:

- attached to each affected object
- in You as searchable/exportable history
- available through command/search later
- exportable with user control

### 9.3 Closure state model

Required closure outcomes:

- Completed
- Still Counts
- Moved
- Skipped / Not Needed
- Blocked
- Waiting
- Needs Recovery
- Needs Review

Closure should feel different by outcome, but it must generally communicate:

- reality updated
- proof filed
- future recommendations can adapt
- no shame was assigned

Still Counts:

- has equal dignity to Completed
- may be hidden until closure detail opens on dense surfaces
- must not read like consolation copy
- creates proof and can affect future recommendations

Skipped / Not Needed:

- neutral by default
- positive when the step truly no longer matters
- receipt-backed
- optional reason unless the skip affects schedule, goal proof, or recommendation learning

Blocked:

- asks what is blocking
- creates waiting/blocker state
- affects future recommendations
- offers alternate step, help, or source/action path

Waiting:

- tracks dependency/source
- pauses or alters recommendations
- prompts later only when useful
- creates receipt

Needs Recovery:

- reduces density where appropriate
- offers lighter plan
- may protect time
- preserves dignity and proof

Needs Review:

- creates soft unresolved state
- keeps object visible but non-blocking
- opens review later without forcing immediate cleanup

Prior unclosed steps appear as a combination of:

- soft closure prompts
- Meridian residue
- recovery/review queue
- object-local proof gaps

They must not appear as overdue failure.

### 9.4 Recovery model

Recovery is cross-surface, but Today and Time are its most visible homes.

Recovery may be triggered by:

- user choosing Needs Recovery
- overload/high pressure
- missed closures
- calendar/source conflict
- user schedule change
- repeated rejected recommendations

All inferred recovery must be user-visible and reversible.

Recovery tone:

```text
Comforting, direct, and supportive. No cheerleading. No fake AI personality. No shame. No obliviousness to the sensitivity of the user’s situation.
```

Recovery UI must:

- reduce density where recovery materially affects the moment
- show fewer, safer actions
- prefer lighter steps
- offer protected time
- preserve proof
- avoid pretending nothing changed

Recovery affects recommendations contextually:

- immediately for local UI state when user explicitly chooses recovery
- after confirmation for schedule/reflow changes
- across Today, Time, and Goals when recovery changes capacity or goal pacing
- never as silent schedule mutation

Recovery can end:

- manually
- after a closure event
- after protected recovery time
- after a time window expires
- when user reopens normal density

Recovery visibility:

- compact while active
- more visible in Today/Time
- shown elsewhere only when it affects recommendations, pacing, proof, or trust

Recovery actions include, when relevant:

- Make lighter
- Move
- Still Counts
- Not needed
- Protect time
- Ask for help

Recovery must never:

- shame the user
- hide proof
- silently delete steps
- silently change schedule
- create fake motivational copy

Recovery receipt includes:

- trigger
- user choice
- what changed
- what did not change
- next safe step
- local/private status

### 9.5 Proof and source lineage

Proof attaches to all relevant Ambitions objects:

- Step
- Goal
- Goal Thread
- Capture
- Time operation
- Memory/runtime setting
- Receipt
- Closure event
- Recovery state

Source lineage should show:

- original capture/source
- transformation path
- user approvals
- runtime decisions
- freshness/confidence
- affected objects

Proof detail should show:

- what happened
- why it mattered
- what object it affected
- what future decisions may use it
- what source was involved
- whether the user approved or corrected it

Proof visibility is contextual:

- compactly visible when it increases trust
- attached to selected objects
- available through drawers/lenses/details
- aggregated in You/history

Proof can influence future recommendations only when visible or inspectable. No hidden proof should materially steer the user without an inspection path.

Source confidence:

- hidden unless low/stale for calm surfaces
- compact label where trust matters
- drawer detail for full source/freshness view
- always accessible where Ambitions makes a recommendation or mutation

Stale source state must:

- downgrade recommendation confidence
- show source warning when relevant
- preserve last-known state
- offer refresh/update path
- avoid implying current certainty

Proof transfer exists for:

- goal pivot
- goal merge/split
- step moved
- schedule reflow
- capture promoted
- milestone changes
- archival/no-longer-needed changes

Proof transfer must show:

- what moved
- what stayed valid
- what no longer applies
- receipt
- future recommendation consequence

Proof must avoid:

- scoreboard feel
- KPI dashboard
- social proof
- streak pressure
- analytics wall

### 9.6 Replay and inspection

Replay is split by audience.

User-facing replay means:

- reconstructing the plain-language decision path
- reopening receipt history
- inspecting source lineage
- seeing before/after state
- seeing user choices
- seeing outcome and next effect

Developer/debug replay means:

- runtime diagnostic reconstruction
- proof artifacts
- optional exportable diagnostics with user consent
- separate from user-facing receipts

Replay is accessible from:

- receipt
- object detail
- You
- command/search later
- affected proof/source drawers

Replay must not feel like:

- log feed
- debug console
- analytics dashboard
- legal audit wall

Replay visual structures may include:

- proof path
- lineage drawer
- step-by-step receipt sequence
- object timeline
- object-specific replay lens

Replay export:

- all receipts/proof from You export
- selected object export where appropriate
- diagnostics export only with explicit user consent
- sensitive data export must obey privacy/delete/export rules

### 9.7 Cross-surface placement

Today placement:

- Meridian node markers
- receipt tray
- closure state
- Trust drawer for source/proof
- proof residue for prior unresolved items

Time placement:

- field-region marker
- operation receipt
- reflow proof
- trust/source drawer
- before/after reflow detail

Goals placement:

- thread proof light
- goal receipt
- milestone proof
- pivot/proof transfer
- attached capture/source lineage

Capture placement:

- placement receipt
- source lineage
- destination link
- undo/revert path
- future-use explanation when memory/context is created

You placement:

- searchable receipt history
- trust/memory correction history
- privacy/source change history
- export/delete proof
- local/private state history

Global shell placement:

- no persistent receipt feed
- material actions may show brief continuity tray
- shell receipt must not become notification badge or dashboard module

### 9.8 Motion and haptics

Receipt motion:

- filing
- settling
- attaching to object
- disappearing into history
- adaptive by severity

Closure motion:

- loop closing
- reality update
- proof attaching
- reflow if needed
- outcome-specific

Recovery motion:

- density softening
- pressure reducing
- step becoming lighter
- protected space forming
- always calm

Proof transfer motion:

- thread redirection
- receipt handoff
- valid proof staying attached
- old path dimming
- new path forming

Haptics:

- subtle only
- fire on material actions
- closure commit
- recovery accepted
- proof transfer approved
- privacy/data mutation
- receipt creation only if material

Reduce Motion:

- use fades, instant state changes, labels/before-after states, and native sheet/drawer transitions
- never make motion the only proof/relationship cue

### 9.9 SwiftUI implementation contract

Recommended architecture:

```text
ProofReceiptRuntime
```

as a thin cross-surface coordinator/facade over separate services by concern:

- `ReceiptLineageService`
- `ClosureRecoveryRuntime`
- source/proof lineage services
- object-specific adapters

This prevents every surface from inventing parallel receipt, closure, proof, and recovery behavior.

User-facing receipt component:

```text
AmbitionsReceiptTray
```

or the existing design-system tray if one already exists and can be adapted without card architecture. Object-specific wrappers may exist, but the user-facing behavior must remain consistent.

Closure UI should generalize the existing Today closure sheet into:

```text
ClosureOutcomeSurface
```

Object-specific closure entry points may wrap it, but closure outcomes and receipt writing must be shared.

Recovery UI should be object-specific at the surface layer, backed by shared recovery state:

- Today: Recovery current / Meridian recovery state
- Time: Recovery field/region
- Goals: goal-thread recovery/pacing state
- Capture: recovery route/context
- You: recovery preferences and history

Receipt/proof object-purity must ban:

- receipt cards
- proof cards
- closure cards
- audit log feed root
- analytics dashboard
- KPI/progress score
- equal panel stacks
- score/streak language

Previews must include:

- step closure
- Still Counts
- moved step
- blocked/waiting
- recovery
- capture placement
- schedule reflow
- goal pivot
- memory correction
- privacy/delete/export
- Dynamic Type
- Reduce Motion

Tests must prove:

- receipts are created for material actions
- no silent mutation
- closure states persist
- proof lineage is inspectable
- replay reconstructs decision path
- recovery updates recommendations safely
- accessibility labels exist

Anti-card scan must check:

- `ReceiptCard`
- `ProofCard`
- `ClosureCard`
- audit/feed/dashboard naming
- score/streak/KPI naming
- equal panel stacks

### 9.10 Ownership and batch posture

`TRAIN_10` owns the canonical cross-surface proof/receipt/closure/recovery system:

```text
IOS26-T10-B01-receipt-lineage-service.md
IOS26-T10-B02-cross-surface-proof-drawer.md
IOS26-T10-B03-recovery-replay.md
```

Earlier surface batches must use temporary local hooks only when required to ship object behavior. They must not create parallel proof, receipt, closure, or recovery runtimes.

Final global receipt/proof object-purity should exist as part of the final global anti-card/object-purity sweep rather than a separate standalone train unless T10 leaves accepted-Yellow residue.

### 9.11 Final success criteria

Proof/receipt/closure/recovery succeeds when:

- user can see what changed
- user can inspect why
- user can recover without shame
- user can trust no silent mutation happened
- future recommendations are affected only by inspectable local proof
- the system never becomes a feed, dashboard, score, or log wall

Biggest failure modes, ranked:

1. source/trust is hidden or confusing
2. recovery feels patronizing
3. receipts feel noisy

Secondary failure modes:

- proof feels like dashboards/logs
- closure feels like task completion
- receipt UI becomes card/feed architecture

Final proof/closure thesis:

```text
A calm proof layer that records what changed, why it changed, what the user approved, and what still counts.
```

---


## 10. Wave 9 — Motion, Haptics, Gestures, Interaction Choreography

Status: Locked from inferred recommendations based on Waves 0–8 and the user direction that Ambitions should feel innovative, rich, premium, and obvious.

This section does not redefine global animation durations, springs, haptic types, timing curves, materials, or accessibility baselines. It inherits AmbitionsDesignSystem motion/haptic/accessibility primitives and defines how object motion should be used.

### 10.1 Motion thesis

Final motion thesis:

```text
Ambitions moves like a native life instrument: calm, precise, rich, inspectable, and never decorative. Every motion either orients, reflows, proves, or recovers.
```

Motion exists to communicate:

1. object continuity
2. state change
3. cause and effect
4. trust/proof
5. calm orientation

Motion must feel:

- Apple-native
- instrument-like
- atmospheric only when it clarifies the object
- premium
- responsive
- obvious

Motion must never feel:

- gamified
- bouncy/cartoonish
- sci-fi HUD
- decorative
- slow/heavy
- required for meaning

### 10.2 Global motion rules

Default transitions should use inherited design-system motion unless an object has a documented semantic motion wrapper.

Large object transitions may use object-origin motion, semantic zoom, or native sheet/drawer transitions when the transition clarifies where the user came from and what changed.

Non-mutating navigation should stay native and minimal.

Mutating actions should use a combination of:

- visible object state change
- receipt/proof confirmation
- subtle haptic feedback
- cause/effect animation when helpful

Loading states must be quiet and object-shaped. Do not use generic card skeleton stacks.

Error/failure states must be calm, direct, recovery-oriented, and non-alarming unless the issue is materially destructive or privacy-related.

Motion should generally feel fast and responsive. Longer transitions are allowed only when they communicate meaningful object continuity, semantic zoom, proof transfer, reflow, or recovery.

Codex may add semantic object motion wrappers such as:

```swift
.meridianReflow(...)
.fieldReflow(...)
.atlasZoom(...)
.routeFormation(...)
.receiptAttach(...)
.recoverySoften(...)
```

but these wrappers must be backed by existing design-system primitives and Reduce Motion alternatives. No raw one-off animation recipes should be scattered through object views.

### 10.3 Today / Reality Meridian motion

Today motion is built around:

- Meridian current
- current node expansion
- reality reflow
- receipt filing
- recovery softening

Start here should expand from the collapsed current node. It should not appear as a detached recommendation card.

Start here collapse should return into the current Meridian marker or compact current state. The compact state must remain understandable without animation.

Meridian scroll should feel like native vertical scroll with instrument-like scrubbing quality. It must not become a generic list scroll.

Past/closed nodes should become proof trace, closed node state, or receipt marker depending on closure outcome.

Future/upcoming nodes may compress or expand by pressure. They should not animate like a task list entering the screen.

Rejecting Start here should open the reason sheet first, then show replacement reflow. Avoid dramatic rejection motion.

Today reflow must show:

- what changed
- what moved
- what stayed protected
- receipt/proof consequence

Recovery entry should:

- reduce density
- soften the Meridian
- collapse nonessential depth
- present a lighter Start here

Today haptics should be subtle and material-action based. Eligible actions include:

- Start now
- closure commit
- Still Counts
- reflow approval
- rejection save

### 10.4 Time / LifeShape Field motion

Time motion is built around:

- field reflow
- horizon zoom
- pressure softening
- protected edge lock/unlock
- receipt filing

Day / Week / Month / Year / Life Range transitions should feel like field morph / semantic zoom, not tab switching between unrelated calendar pages.

Open time should appear as visible field space with a subtle settle and action affordance.

Protecting time should form a boundary, lock the region, and create a receipt if material.

Schedule reflow must show:

- movement path
- before/after
- affected regions settling
- explicit approval before mutation
- receipt after mutation

Recovery block creation should soften surrounding pressure, form protected recovery space, affect Today when relevant, and create a receipt.

Calendar/source refresh should quietly update only changed regions. Source freshness labels should update when relevant. Receipt is required only when the refresh causes a material state change.

Time haptics should be subtle and material-action based. Eligible actions include:

- protect time
- approve reflow
- create recovery block
- move commitment
- material source refresh

### 10.5 Goals / Constellation Atlas motion

Goals motion is built around:

- Atlas zoom
- constellation orbit
- thread drawing
- proof lighting
- proof transfer

Selecting a goal should adaptively zoom/focus the node, draw relationships, reveal the thread timeline, and keep context visible where possible.

Scrubbing a goal thread timeline should move along the thread path, highlight steps/proof over time, and keep Atlas context visible.

Creating a goal should place a new body into the life-area planet/region, form the initial thread, attach source/capture when present, and file a receipt.

Pivoting a goal should redirect the thread, preserve proof transfer, dim old path, form new path, and avoid making the pivot feel destructive.

Archiving should move the goal into an archived constellation layer, preserve proof, and file a receipt. It must not feel like deletion.

Goals haptics should be subtle and material-action based. Eligible actions include:

- create goal
- focus goal
- attach proof/capture
- pivot/close/archive
- relationship change

### 10.6 Capture / Atmosphere Composer motion

Capture motion is built around:

- atmosphere settling
- route forming
- aperture opening
- placement landing
- receipt filing

Typing should subtly expand the composer, wake the route field, show hints only after meaningful input, and avoid excessive motion.

Submitting a capture should lift route preview above the composer, settle into a route lens, reveal confidence, and keep text editable.

Obvious routes should show one recommended path and destination landing after approval. Auto-place must not occur unless explicitly enabled.

Ambiguous routes should show route options, ask clarification where needed, save as Needs a Place if unresolved, and avoid frantic branching.

Placement should land into the destination object, clear or collapse the composer, show undo where safe, and file a receipt.

Capture haptics should be subtle and material-action based. Eligible actions include:

- capture submit
- placement confirmation
- memory consent
- discard
- route conflict

### 10.7 You / User System Profile motion

You motion should feel closest to:

- iOS Settings-native
- premium configuration surface
- trust lens focusing
- runtime consequence preview

Opening a row/detail should use native settings-style navigation. Avoid custom drama.

Changing runtime/frontend settings should show consequence preview, settle the control state, file a receipt if material, and highlight affected object only when previewed.

Memory correction should file a correction receipt, show affected surfaces when useful, update item state, and avoid AI-memory theater.

Delete/reset/export should use native confirmation, controlled removal, receipt/log behavior, and no expressive celebration.

You haptics should be subtle and material-action based. Eligible actions include:

- runtime control change
- memory correction
- delete/reset confirmation
- privacy/source change
- export completion

### 10.8 Gesture system

Primary interaction model:

- tap-first
- native sheets/drawers/details first
- discoverable gestures where valuable
- optional power-user gestures only when every gesture has a visible/tap fallback
- VoiceOver equivalent required

Any custom gesture must have:

- visible affordance
- tap fallback
- VoiceOver equivalent
- no conflict with iOS gestures
- no required hidden behavior

Swipe gestures should be avoided at top-level roots except as optional shortcuts for mature, safe, reversible actions. They must not be the only way to close, move, archive, or reflow.

Long press may reveal optional object actions, source/proof inspection, or relationship controls, but must never be required.

Scrubbing is allowed where meaningful:

- Reality Meridian history/future
- LifeShape horizon
- Goal thread timeline
- proof replay

Dragging should be deferred unless the surface can prove clarity and accessibility. It may eventually support Time reflow, Goal relationship adjustment, or Capture placement, but initial object implementation should not depend on drag-only behavior.

Pinch/zoom should be optional only. Goals Atlas and Time horizons may eventually support it, but iPhone root usability must not require pinch.

Gestures may differ by surface, but all surfaces share the tap/drawer/sheet baseline.

### 10.9 Haptic vocabulary

Haptics are restrained, material, and never decorative.

Haptic levels should include:

- selection
- soft commit
- material commit
- warning/boundary
- success/proof

Haptics must never be:

- decorative
- repetitive
- required for meaning
- gamified
- a substitute for visual/text/VoiceOver confirmation

Closure haptic should feel like soft commit / proof attach, with outcome-specific differences only when useful.

Recovery haptic should be softer than completion and may feel reassuring or boundary/protection-oriented depending on action.

Privacy/delete haptic should feel serious/material and different from ordinary success.

### 10.10 Reduce Motion and accessibility

Reduce Motion must replace object motion with an equivalent combination of:

- fades
- before/after labels
- state labels
- native sheet/navigation transitions
- instant state changes where appropriate

Motion meaning must always have:

- text equivalent
- VoiceOver equivalent
- state label equivalent
- non-color equivalent

Motion-sensitive users must still understand:

- what changed
- why it changed
- what object was affected
- what the user approved

VoiceOver announcements should be adaptive by severity:

- material changes get receipt summaries
- object updates get concise state announcements
- minor changes should avoid noise

Reduce Motion must be covered in:

- Today
- Time
- Goals
- Capture
- You
- Proof/receipts

### 10.11 SwiftUI implementation contract

Motion implementation should be hybrid:

- design-system primitives remain the base
- object-local semantic wrappers may be added
- raw animations should not be scattered through views
- all object-local motion wrappers must document Reduce Motion behavior

Object motion names should be semantic and documented, not generic timing labels.

Recommended semantic names:

```text
meridianCurrent
meridianReflow
startHereExpand
fieldReflow
horizonZoom
protectedEdgeLock
atlasZoom
threadDraw
proofLight
routeFormation
placementLanding
trustLensFocus
receiptAttach
recoverySoften
```

Haptic implementation should use a central policy/wrapper with object-specific calls. Do not call UIKit haptics ad hoc from every component without policy.

Gesture implementation requires:

- tap fallback
- accessibility equivalent
- preview state where relevant
- UI test for material gestures

Motion previews must include, where relevant:

- normal motion
- Reduce Motion
- Dynamic Type
- high-density state
- recovery state
- source-stale state

Motion tests must prove:

- Reduce Motion path exists
- state labels update
- no animation-only meaning
- important transitions are accessible

Codex must fail object motion if:

- motion is decorative
- motion hides cause/effect
- Reduce Motion is missing
- gesture has no fallback
- haptic is the only confirmation
- animation meaning lacks text/VoiceOver/state equivalent

### 10.12 Motion final success criteria

Motion succeeds when:

- the app feels innovative, rich, premium, and obvious
- object continuity is preserved
- state changes are understandable
- cause/effect is visible for material actions
- proof/receipts feel trustworthy but not noisy
- recovery feels supportive but not patronizing
- Reduce Motion users receive equivalent meaning
- no motion reads as game, HUD, decoration, or generic SwiftUI flourish

## 11. Wave 10 — SwiftUI File Map, Validators, Codex Batch Insertions

### 11.1 Final authority shape

The frontend invention work is not a single markdown file. It becomes a small implementation package:

```text
docs/codex/frontend/AMB_OBJECT_FRONTEND_IMPLEMENTATION_SPEC.md
docs/codex/frontend/IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN.md
docs/codex/frontend/IOS26_ANTI_CARD_VALIDATOR_SPEC.md
docs/codex/frontend/IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES.md
docs/codex/frontend/OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC.md
prompts/installers/IOS26_OBJECT_FRONTEND_INSTALLER_PROMPT.md
prompts/batches/IOS26-T04L-B01-living-chrome-object-purity.md
prompts/batches/IOS26-T10-B04-global-object-purity-sweep.md
```

This package is a Codex implementation authority for frontend object work, a product design supplement, and a batch insertion plan. It remains subordinate to:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- active AmbitionsDesignSystem source
- live source, tests, scripts, and proof artifacts

Codex must use this package to update, expand, and extend the existing iOS 26 frontend trains `T05`–`T16` where appropriate. It must not treat the package as release proof or implementation proof.

### 11.2 Design-system change boundary

Codex may modify AmbitionsDesignSystem in object frontend work when an object surface genuinely needs a missing primitive or semantic affordance. However, object batches must not casually redefine existing color, typography, spacing, base material, or base motion contracts.

Design-system changes are allowed only when all are true:

1. The change is needed by an object surface or validator.
2. Existing design-system primitives cannot express the object cleanly.
3. The change is semantic, tested, and preview-backed.
4. The final report lists it separately under “Design-system changes.”
5. Existing consumers remain green or are migrated safely.

New object primitives begin feature-local first and are promoted to shared/design-system only after reuse or after a specific shared primitive need is proven.

### 11.3 Target SwiftUI root map

Codex must infer exact file structure from current source at implementation time, but the target composition roles are:

| Surface | Target object root | Existing screen role | Existing object/component treatment |
|---|---|---|---|
| Today | infer from source, preferred `RealityMeridianSurface` | hybrid container | `RealityMeridianView` renamed/rebuilt; `TodayExecutionDepthDisclosure` renamed/rebuilt as object-specific drawer |
| Time | infer from source, preferred `LifeShapeFieldSurface` | hybrid container | `TimeLifeShapeField` renamed/rebuilt |
| Goals | infer from source, may keep `GoalsScreen` while installing Atlas internally | hybrid container | list/card/board components rename/rebuild into Atlas primitives |
| Capture | infer from source, preferred `AtmosphereComposerSurface` | hybrid container | `CaptureAtmosphereComposer` renamed/rebuilt; `CaptureDraftRoutePreviewCard` becomes `CaptureRouteLens` |
| You | infer from source, preferred `UserSystemProfileSurface` | hybrid container | `YouRootSurface` renamed/rebuilt as premium Ambitions-themed iOS 26 Settings-style configuration hub |

Generic active `Card` components must be rebuilt into object primitives. Generic active `Panel` components must be renamed or wrapped in object-specific language where rendered by top-level surfaces. Active `Hero` terminology must be renamed during the relevant object batch.

### 11.4 Final batch insertion decisions

Add `TRAIN_04L` before `TRAIN_05`.

```text
TRAIN_04L — Object Frontend Living Chrome Foundation
- IOS26-T04L-B01-living-chrome-object-purity.md
```

Expand existing batches instead of adding extra B04 batches for these surfaces:

```text
IOS26-T05-B01 — Today / Reality Meridian object installation + object purity
IOS26-T06-B02 — Time / LifeShape Field object installation + object purity
IOS26-T07-B01 — Goals / Constellation Atlas object installation + object purity
IOS26-T08-B01 — Capture / Atmosphere Composer object installation + object purity
IOS26-T09-B01/B02 — You / User System Profile object installation + object purity
IOS26-T10-B01…B03 — Proof / receipts / closure / recovery object purity
```

Add the final global sweep after `TRAIN_10`:

```text
IOS26-T10-B04-global-object-purity-sweep.md
```

Manifest/order/batch-matrix/prompt-freeze updates must be performed after the new prompts are created. Codex should use repo scripts where available instead of hand-maintaining generated files.

### 11.5 Validator decision

Install one strict validator:

```text
scripts/ios26-anti-card-check.py
```

The validator must support global and per-surface modes. It must scan active source/test/preview files, including app source and active design-system source, while excluding historical docs by default.

It must fail or classify:

- active `Card` type names
- active card root composition
- dashboard/feed/chat/list/calendar-clone roots
- equal-weight top-level panel stacks
- banned naming and accessibility IDs
- residual `.card` accessibility identifiers
- active `GoalCard`, `CaptureCard`, `ReceiptCard`, `ProofCard`, `ClosureCard`, dashboard, feed, chat, KPI/ring/score/streak language

The user chose no active compatibility allowance for card architecture. If compatibility wrappers remain, the batch cannot close Green unless they are not active/rendered and the validator proves they are outside the active UI surface. Otherwise close Yellow with exact files and follow-up gate.

Validator output must include:

```text
build/reports/frontend-object-purity/<batch-id>-anti-card.md
build/reports/frontend-object-purity/<batch-id>-anti-card.json
console summary
```

### 11.6 Screenshot and preview proof

Every object surface must provide a preview matrix. Screenshot proof is required for the final global sweep and may be Yellow-bounded earlier when automation is unavailable.

Required object preview categories:

- normal
- empty/low-data
- recovery/pressure
- source stale/unavailable
- Dynamic Type
- Reduce Motion

Screenshot proof should include relevant normal and edge states. If screenshot automation is unavailable, Codex must run a repair cycle: add validator coverage, add preview proof, add manual screenshot checklist, rerun validation, and only then close Yellow if still unproven.

### 11.7 Test gates

Object frontend batches must include:

- SwiftUI source changes
- view-state/view-model changes where needed
- preview matrix updates
- accessibility labels/identifiers
- focused tests
- validator execution
- proof artifact updates

Testing must include unit tests for state mapping and surface-specific logic, UI tests for visible object roots, accessibility state checks, Reduce Motion path checks, and anti-card validator tests where feasible.

### 11.8 Green / Yellow / Red

Green requires all of:

- source changed
- object root installed
- card architecture removed
- tests/previews updated
- validator clean
- screenshot/manual proof where required
- accessibility state covered

Yellow is allowed only with explicit owner, reason, no-claim boundary, follow-up gate, and repair-cycle evidence.

Red if any of these remain in active top-level UI:

- card stack
- dashboard/feed/chat/list/calendar clone
- missing object root
- design system overwritten without scoped need
- broken accessibility path
- silent mutation or unreceipted material change

### 11.9 Final implementation thesis

```text
Install an object-first SwiftUI frontend that inherits AmbitionsDesignSystem and removes generic card architecture from active top-level surfaces.

Convert Ambitions from screen/card UI into named native life instruments with proof, motion, accessibility, and validation.

Make Ambitions’ frontend implementation match its product objects: Meridian, Field, Atlas, Composer, Profile, and Proof.
```

## 12. Package Index

The companion files in this package are:

```text
docs/codex/frontend/IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN.md
docs/codex/frontend/IOS26_ANTI_CARD_VALIDATOR_SPEC.md
docs/codex/frontend/IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES.md
docs/codex/frontend/OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC.md
prompts/installers/IOS26_OBJECT_FRONTEND_INSTALLER_PROMPT.md
prompts/batches/IOS26-T04L-B01-living-chrome-object-purity.md
prompts/batches/IOS26-T10-B04-global-object-purity-sweep.md
```
