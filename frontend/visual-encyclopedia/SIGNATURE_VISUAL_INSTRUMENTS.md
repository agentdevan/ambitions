# Signature Visual Instruments

Status: Active top-level Visual Encyclopedia doctrine
Authority: subordinate to `docs/truth/*`; required by frontend implementation packets and UI-affecting Codex batches
Installed by: `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07`

## Purpose

Ambitions must not read as a styled card-stack productivity app. Its mature frontend should be built around a small set of custom, living, native iPhone visual instruments.

The product references that motivated this doctrine are not copied as brands, layouts, commerce mechanics, entertainment IP, weather UI, or market UI. They are abstracted into native interaction principles:

- live telemetry density without urgency mechanics
- cinematic drill-down identity without media-app dependency
- content-first floating chrome without decorative clutter
- contextual drill-down headers without heavy top-level tab headers
- state-driven living atmosphere without random decorative animation
- chart/replay/field-style instruments without generic dashboard modules

## Non-Negotiable Product Rule

A top-level Ambitions destination must be centered on a signature visual instrument, not a stack of generic cards.

Every future frontend implementation batch that touches Today, Goals, Capture, Time, You, visual primitives, or drill-down surfaces must either:

1. use an existing signature visual instrument from this doctrine, or
2. explicitly propose and register a new Ambitions-native instrument before implementation.

A screen that only arranges cards, lists, metrics, and buttons without an owning instrument is not flagship-complete.

## Signature Instruments

### 1. Reality Meridian Instrument

Owner: Today

Primary purpose: show the user's live day state, recommended start point, Now / Next / Later continuity, source/proof/receipt state, pressure, recovery, and closure path as one connected object.

Reference abstraction:

- live stat density from sports/event surfaces
- replay/trajectory object clarity from event visualizations
- semantic atmosphere from Weather-style state environments
- contextual source/proof headers from Stocks-style drill-downs

Required properties:

- object-first, not task-list-first
- visible day trajectory / rail / continuity spine
- live but non-urgent state language
- source freshness and proof status visible near decisions
- pressure/recovery/protected/open states rendered spatially, not only textually
- no streak, score, shame, or urgency loops
- no chatbot or AI confidence language

Likely source family:

- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- future `RealityMeridianSurface.swift`
- future `RealityMeridianLiveStatePanel.swift`
- future `RealityMeridianContinuitySpine.swift`

### 2. LifeShape Field Instrument

Owner: Time

Primary purpose: show capacity, protected time, pressure, free/open regions, reflow previews, and schedule source trust as a shapeable field rather than a generic calendar.

Reference abstraction:

- Apple Stocks-style chart ownership
- live-stat comparative telemetry stripped of pressure mechanics
- Weather-style background pressure state
- contextual drill-down headers for day/week/month details

Required properties:

- Day / Week / Month / Life Shape modes must feel like different lenses of one field
- pressure and capacity must be visual, not only labels
- protected time must have spatial and semantic treatment
- reflow must be preview/confirm/undo, never silent mutation
- vacation/away must not read as free time unless marked available
- no calendar clone, no market board, no fake precision

Likely source family:

- `Native/Ambitions/Features/Plan/**` while Time remains the active user-facing destination
- future `LifeShapeFieldView.swift`
- future `LifeShapePressureMap.swift`
- future `LifeShapeCapacityBars.swift`
- future `LifeShapeDrilldownHeader.swift`

### 3. Constellation Atlas Instrument

Owner: Goals

Primary purpose: show goals, proof, blockers, alternate paths, decisions, and mission continuity as an explorable atlas rather than a static goal list.

Reference abstraction:

- cinematic hero identity from media drill-downs
- trajectory/field visualization from replay surfaces
- visual graph/path clarity from chart-first surfaces
- floating immersive chrome where exploration needs space

Required properties:

- goal detail opens as a mission object, not a form
- proof and decisions orbit or attach to goal continuity
- blockers and alternate paths are visible as path state, not hidden notes
- path uncertainty must remain honest
- no motivational dashboard, no generic progress rings, no fake certainty

Likely source family:

- `Native/Ambitions/Features/Goals/**`
- future `ConstellationAtlasView.swift`
- future `GoalMissionHero.swift`
- future `ProofOrbitView.swift`
- future `GoalPathTrajectoryView.swift`

### 4. Atmosphere Composer Instrument

Owner: Capture

Primary purpose: make capture feel like a focused input atmosphere that resolves material into Needs a Place, Ready to Place, Grow into Goal, proof, commitment, constraint, or reflection routes.

Reference abstraction:

- content-first immersive chrome
- Weather-style state-driven atmosphere
- cinematic action dock when routing detail opens

Required properties:

- composer-first, not inbox-first
- routes appear after input, not as clutter before input
- visual atmosphere must signal safe local-first capture state
- uncertain parse, wrong route, duplicate, privacy-sensitive, offline, and failed attachment states must be visible
- no chatbot thread, no feed, no generic notes app, no inbox as top-level default

Likely source family:

- `Native/Ambitions/Features/Captures/**`
- future `AtmosphereComposerView.swift`
- future `CaptureRoutingField.swift`
- future `CapturePlacementResolver.swift`
- future `CaptureReceiptSurface.swift`

### 5. User System Profile Instrument

Owner: You

Primary purpose: show planning setup, automation trust, privacy, local runtime, source management, learned patterns, deletion/forget paths, and personal system controls as a calm control console.

Reference abstraction:

- Stocks-style drill-down header and metric ownership
- dense but readable status panels without urgency mechanics
- floating control affordances where appropriate

Required properties:

- settings-style clarity with premium system depth
- trust/automation status must be inspectable and adjustable
- local-first and deletion/forget behavior must be visually explicit
- learned patterns must be inspectable, not mysterious
- no surveillance posture, no AI theater, no hidden learning claims

Likely source family:

- `Native/Ambitions/Features/Profile/**`
- future `UserSystemProfileSurface.swift`
- future `TrustConsoleView.swift`
- future `AutomationLadderView.swift`
- future `LocalRuntimeTrustMap.swift`

## Shared Instrument Primitives

### LivingBackground

Weather-inspired but Ambitions-native. A state-driven atmosphere layer for top-level and immersive surfaces.

Required states:

- open
- focused
- protected
- overloaded
- recovery
- stale_source
- source_conflict
- offline_local_only
- privacy_sensitive

Rules:

- atmosphere must be semantic, not decorative
- Reduce Motion must preserve meaning without animated background motion
- Reduce Transparency must use solid fallback surfaces and borders
- no random starfield outside Capture / First Run unless the state demands it

### ContextualDrilldownHeader

Stocks-inspired. Appears in drill-downs, after scroll, or when context is needed. Top-level tabs should remain compact and not title-heavy.

Used by:

- Step Detail
- Step Session
- Goal Detail
- Proof Detail
- Receipt Detail
- Time Detail
- Schedule & Availability
- Automation & Trust

Rules:

- never make top-level destination headers heavy by default
- drill-down headers must identify object, source/proof status, and safe exit path
- header should collapse/appear with scroll when appropriate

### CinematicObjectHero

Media-drilldown-inspired but Ambitions-native. A large object identity layer for important drill-downs.

Used by:

- Goal Detail
- Step Detail when focus/session begins
- Proof Detail
- LifeShape Month / Life Shape drill-down
- First Run privacy/local-runtime explanation

Rules:

- hero must communicate object identity and decision context
- action row must be clear and non-coercive
- metadata chips must be source/proof/context chips, not entertainment ratings
- no decorative poster-like imagery without semantic purpose

### FloatingGlassNav

Content-first floating chrome for immersive surfaces.

Used by:

- Capture root
- Constellation Atlas exploration
- Proof viewer
- LifeShape Month
- First Run / onboarding moments

Rules:

- chrome floats only when it gives content more room
- hit targets must remain 44pt minimum
- VoiceOver order must not be broken by visual float behavior
- Reduce Transparency must render solid fallback capsules

### LiveTelemetryPanel

Compact live status panels for current state.

Used by:

- Today pressure/source/receipt status
- Time capacity/protected/open/reflow status
- Goal proof/blocker/path status
- You automation/trust/runtime status

Rules:

- no streaks, urgency loops, or manipulative red/green pressure semantics
- telemetry must support a calm decision, not compulsive checking
- every metric needs a source/freshness/proof status or must be labeled suggested/estimated

### MetricInstrumentChart

Custom chart or field component for meaningful trends or state comparisons.

Used by:

- LifeShape capacity / pressure map
- Goal proof trend
- Today source freshness and day pressure
- Recovery pressure and protected-time relationship

Rules:

- chart must explain what decision it supports
- chart must be inspectable and accessible
- no tiny charts as decoration
- no fake precision

## Required Code Architecture Pattern

High-end visual instruments belong in dedicated SwiftUI visual-object files.

Pattern:

```text
Screen file = assembles destination and navigation state
Visual-object file = creates the signature instrument
ViewState file = feeds the instrument
Theme/token files = define material, typography, spacing, and semantic states
Preview files = prove normal/empty/error/recovery/overloaded/reduced-motion/dynamic-type variants
Receipt files = record implementation and proof status
```

Future implementation must prefer:

```text
Native/Ambitions/Features/<Feature>/<InstrumentName>.swift
Native/Ambitions/Features/<Feature>/<InstrumentName>ViewState.swift
Native/Ambitions/PreviewSupport/<InstrumentName>PreviewScenarios.swift
```

over adding more visual complexity directly inside root screen files.

## Required SwiftUI Techniques

Use when appropriate:

- `Canvas`
- `Shape`
- `Path`
- `GeometryReader`
- `TimelineView`
- `matchedGeometryEffect`
- custom gradients
- semantic material wrappers
- state-driven animation with Reduce Motion alternatives
- custom accessibility labels and reading order

Do not use these techniques as decoration. They must create a clearer instrument.

## Impact On Frontend Authority Packets

Every generated surface packet for a top-level destination or major drill-down should now include:

- owning signature instrument
- required shared instrument primitives
- forbidden reference-copy behavior
- native SwiftUI technique candidates
- preview/proof expectations for the instrument
- source files where the instrument should live

If a packet lacks this, future Codex work should treat it as needing packet upgrade before implementation.

## Implementation Proof Boundary

This doctrine is visual intent authority. It is not implementation proof.

A signature instrument is implemented only when:

- dedicated SwiftUI source exists or existing source is explicitly bound
- preview scenarios exist
- accessibility/reduced-motion/dynamic-type behavior is proven where relevant
- visual proof or screenshots exist when UI changed
- a frontend implementation receipt exists
- drift check passes

## Forbidden Interpretations

Do not copy:

- commerce pressure mechanics
- market-pressure behaviors
- media-poster IP style
- entertainment ratings rows
- weather visuals as decorative scenery
- floating chrome as generic buttons

Do synthesize:

- live state telemetry
- cinematic object identity
- contextual drill-down headers
- immersive content-first chrome
- semantic living atmosphere
- chart/replay/field-level custom instruments

## Lock Statement

The mature Ambitions frontend should feel like a set of living native instruments for life state, time shape, goals, capture, proof, and trust. Any future frontend implementation that reduces these surfaces to generic cards, lists, dashboards, or static forms is a regression.
