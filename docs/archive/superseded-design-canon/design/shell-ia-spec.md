> Superseded document.
>
> This file is preserved for historical context only.
> Active canon now lives in:
> - `docs/canon/design/Ambitions_Design_Constitution.md`
> - `docs/canon/Ambitions_2_0_Implementation_Gap_Audit.md`
> - `docs/canon/Ambitions_2_0_Roadmap.md`
> - `docs/canon/Ambitions_2_0_Batch_Plan.md`
>
> Do not use this file as implementation source of truth.

# Shell IA Spec

Historical/superseded note: This file is preserved pre-Batch-61 frontend transformation context. Active Ambitions 2.0 shell truth is Today / Goals / Capture / Plan / You and now lives in [Ambitions_Design_Constitution.md](Ambitions_Design_Constitution.md). If this file references Today / Goals / Plan / Insights / Profile, Insights as a top-level tab, Profile as the user-facing name, or Habits as a standalone product area, treat those references as historical/superseded.

## Purpose

Define the canonical iPhone shell, route ownership, entry posture, and cross-route continuity rules for the future frontend transformation program.

## Batch Boundary

- The current five-tab shell remains the current shipping truth.
- Batch 39 defines shell reconsideration doctrine only.
- Batch 40 is the first allowed shell-implementation batch.
- No parallel-shell experimentation, hidden-navigation replacement, route rewiring, or speculative shell implementation may land before Batch 40.

## Product Posture

- The shell must feel like a calm command environment, not a utility dashboard.
- The shell must reduce ambiguity in under two seconds.
- The shell must preserve obviousness before novelty.
- The shell may evolve beyond the current five-tab implementation details, but the transformed iPhone truth keeps five top-level destinations unless a later canon update explicitly changes that.

## Top-Level Shell Truth

The transformed iPhone shell keeps five top-level destinations:

1. `Today`
2. `Goals`
3. `Plan`
4. `Insights`
5. `Profile`

These remain the only persistent top-level destinations.
`Captures`, `Habits`, `Review`, `History`, `Trust Center`, and `Memory Lens` do not become sixth or seventh tabs.

### Dominant Question Doctrine

Each top-level destination answers one dominant question:

- `Today`: What matters now?
- `Goals`: Where am I headed?
- `Plan`: How does this week hold together?
- `Insights`: What am I learning?
- `Profile / Trust`: How is my system configured?

Shell hierarchy, header posture, and default disclosure depth should reinforce these questions rather than compete with them.

## Why Five Tabs Stay

- `Today`, `Goals`, `Plan`, `Insights`, and `Profile` already map to the product's core mental model.
- Replacing the tab shell with a hidden navigation rail, mode switcher, or gesture-only shell would create unnecessary relearning cost.
- The shell redesign should improve hierarchy, transitions, and route ownership, not erase daily usability.

## Shell Layers

The shell has four layers:

1. `Persistent shell layer`
   - tab bar
   - adaptive header rail
   - contextual global compose affordance
2. `Primary route layer`
   - one active top-level destination at a time
3. `Subroute layer`
   - pushed or presented drill-down content owned by the current top-level route
4. `Transient overlay layer`
   - sheets
   - full-screen composition flows
   - trust drawers
   - recovery overlays
   - search / Memory Lens

## Cognitive Mode Lens

The shell supports one soft cognitive lens that reweights emphasis without changing the top-level IA.

### Modes

- `Focus`
- `Triage`
- `Shape`
- `Reflect`

### Shell placement

- expressed through header-rail posture
- reflected in the intent-sensitive primary action
- reinforced through hero emphasis and supporting-module suppression
- never rendered as a large persistent mode switcher on every screen

### Entry rules

- user may enter a lens directly from Quiet Command Sheet when the transition is meaningful
- most mode changes occur implicitly based on destination and state

### Default weighting by surface

- `Today`: Focus unless the day is drifted, then Focus with recovery weighting
- `Goals`: Triage by default, Shape when coming from create or refine flows
- `Plan`: Shape
- `Insights`: Reflect
- `Goal Detail`: Focus for immediate action, Shape when refining strategy, Reflect when browsing history depth

### Overcrowding prevention

- only one cognitive lens is dominant at a time
- the lens changes emphasis and action posture, not the entire navigation model
- do not expose more than one mode-control affordance in the first screenful

## Route Ownership

### Today owns

- daily execution
- now / next / recovery
- open time and focus posture
- day-level recovery and protect flows
- transitions into active goal detail
- transitions into focus state

### Goals owns

- ambition and goal inventory
- direction pressure
- neglected goals
- create goal entry
- goal detail entry

### Plan owns

- week shaping
- fixed and flexible time
- room and overload
- weekly tradeoffs
- habit and capture integration into week structure
- weekly review entry

### Insights owns

- reflection
- activity history entry
- compare-period reflection
- narrative pattern truth
- review-history relationship

### Profile owns

- appearance
- trust center
- sync and integration state
- notifications and defaults
- account and billing if still relevant
- system utility controls

## Supporting Route Ownership

### Captures

- Entry points:
  - global compose
  - external surfaces
  - Plan subordinate route
  - Today quick capture
- Canonical home:
  - subordinate route under `Plan` for planning absorption
  - fast access from compose and search

### Habits

- Canonical home:
  - subordinate route under `Plan`
- Secondary presence:
  - Today for immediate execution relevance
  - Insights for reflection

### Weekly Review

- Canonical home:
  - subordinate route under `Plan`
- Secondary presence:
  - Insights as review history and summaries

### Monthly Review

- Canonical home:
  - subordinate route under `Insights`
- Entry points:
  - review prompts
  - Plan weekly review completion
  - Insight summaries

### Activity History

- Canonical home:
  - subordinate route under `Insights`
- Secondary entry:
  - Goal Detail
  - Today

### Memory Lens

- Canonical home:
  - shell-level utility surface, not owned by one tab
- Entry points:
  - contextual global compose
  - hardware keyboard shortcut on future larger screens
  - trust and correction entry points

### Quiet Command Sheet

- Canonical home:
  - shell-level transient overlay
- Entry points:
  - contextual global compose tap
  - hardware keyboard shortcut on larger screens later
  - long-press on compose affordance only as a secondary shortcut
- Purpose:
  - quick capture
  - open object
  - reschedule
  - recover
  - explain
  - correct
  - focus
- Rules:
  - not a developer command palette
  - not a chat shell
  - must remain consumer-readable and low-density

## Continuity Ribbon

The shell can host one continuity ribbon directly below the header rail or immediately beneath the hero when needed.

### Purpose

- carry the single most important continuity signal across Today, Goals, Plan, Insights, and Goal Detail

### Allowed content

- active focus context
- active recovery posture
- critical goal pressure continuity
- week-believability carryover
- recent correction or stale-truth reminder when it materially changes decisions

### Rules

- only one ribbon at a time
- ribbon is dismissible when informational but sticky when structurally important
- ribbon never becomes a scrolling notification stack

## Mobile Provenance Doctrine

On iPhone, provenance should be communicated through calm product-context signals, not classic breadcrumb chrome.

Preferred patterns:

- `Origin Chip`
- `Context Ribbon`
- `Return Stack Memory`

Rules:

- provenance should explain where the user came from or what context is still active
- provenance should not consume the primary shell hierarchy slot
- provenance should support return confidence without teaching a desktop navigation model

## Object-Persistent Navigation

When the same object appears across surfaces, navigation must preserve identity continuity.

### Applies to

- goals
- phases
- tasks or blocks
- captures
- review objects

### Rules

- the same goal should feel like the same object when opened from Today, Goals, Plan, Insights, review, or external surfaces
- object color posture, key title treatment, and dominant signal should remain stable
- transitions should preserve anchor relationship where possible
- if persistence cannot be animated, continuity must still be signaled through stable layout and identity framing

## Adaptive Header Rail

The shell uses one header system with surface-specific posture.

### Header rail zones

1. `Leading identity zone`
   - current screen title or role label
   - back or close affordance when needed
2. `Center truth zone`
   - hero-supporting summary, optional
3. `Trailing utility zone`
   - search
   - filter
   - trust status
   - route-local utility action

### Surface posture by tab

- `Today`: execution rail, compact and directional
- `Goals`: direction rail, slightly more editorial
- `Plan`: shaping rail, utility-heavy
- `Insights`: reflection rail, quieter
- `Profile`: utility rail, more stable and less dynamic

### Rail content by role

#### Execution

- route title or state label
- continuity ribbon trigger if active
- focus or recovery utility

#### Direction

- ambition or direction summary
- semantic zoom controls when relevant
- pressure access

#### Week shaping

- date scope
- pressure map access
- patch or protect action

#### Reflection

- time range
- compare control
- constellation expansion entry

#### Utility

- trust status
- appearance or settings utility
- integration health

## Tab Bar Behavior

- Always visible on top-level routes.
- Allowed to hide only during full-screen composition, immersive focus, or media-free full-screen trust flows.
- Active tab state must be visually obvious through tone, weight, and motion.
- Do not use badge noise except for meaningful pending review or trust-critical states.

## Contextual Global Compose

The compose affordance is persistent but restrained.

### Placement

- anchored above the tab bar or integrated just above it
- never floating high over content like a generic floating action button

### Default action

- opens shell-level compose hub

### Compose evolution rule

- contextual global compose is the shell affordance
- Quiet Command Sheet is the fully specified interaction surface it opens

### Primary options

- quick capture
- new goal
- patch plan
- quick recovery
- quick focus
- search / Memory Lens

## Deep-Link and External Entry Rules

Every external entry point must land in one of three states:

1. `Direct route landing`
   - user is taken to a canonical subroute under the owning tab
2. `Context landing`
   - user lands in owning tab with targeted module highlighted
3. `Overlay landing`
   - user lands in owning tab with compose, recovery, trust, or recall overlay open

Never land an external entry into an orphan route with no visible parent shell context.

## Cross-Tab Continuity Rules

- Top-level tabs must feel like rooms in one product, not separate apps.
- Shared actions keep the same verb order, visual treatment, and motion grammar.
- Progress, trust, and momentum signals must retain consistent semantics across tabs.
- If a user opens a goal from `Today`, `Plan`, `Insights`, or an external surface, the resulting Goal Detail route must be the same canonical screen.
- Continuity Ribbon and object-persistent motion must preserve the feeling that work is moving through one coherent system.

## Disclosure Rules

- First layer: one dominant truth, one dominant action.
- Second layer: supporting modules and state detail.
- Third layer: trust, history, audit, and correction depth.
- Shell destinations must not expose third-layer depth by default.

## Presentation Rules

### Use push navigation for

- subroutes that remain inside the owning tab narrative
- goal detail
- review history
- habits detail

### Use medium or large sheets for

- filters
- quick trust detail
- compact corrections
- week patching
- Quiet Command Sheet
- Path Preview Drawer when shown as shallow inspection

### Use full-screen covers for

- Strategy Composer
- Memory Lens when opened intentionally for exploration depth
- immersive focus mode
- onboarding and first-run education
- split-pane planning compositions only when the iPhone experience would otherwise require excessive route thrash

## Split-Pane Thinking on iPhone

Compact two-layer composition is allowed only when it reduces planning ambiguity without increasing clutter.

### Allowed surfaces

- Plan when shaping a week while inspecting a selected block or open-time window
- Goal Detail when inspecting a future-path preview while preserving current strategy context
- Weekly Review when carrying forward work into next-week shaping

### Not allowed

- Today default home state
- Goals overview list state
- Profile

### Rules

- one dominant pane and one contextual pane only
- contextual pane must collapse cleanly
- if the second pane becomes dense enough to feel like a second full screen, push or present instead

## Safe-Area Rules

- Content should breathe against device edges.
- The shell must not pin hero content under the notch or dynamic island with decorative crowding.
- Bottom-aligned actions must clear the compose affordance and tab bar without stacked control clutter.

## Anti-Patterns

- no hidden top-level navigation model
- no drawer menu
- no sixth utility tab
- no shell state that requires explanation copy to understand
- no route that duplicates another route's ownership
