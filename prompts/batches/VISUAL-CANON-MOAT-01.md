<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# VISUAL-CANON-MOAT-01 - Ambitions Visual Canon + Moat Implementation

Status: Codex-ready implementation authority draft  
Owner posture: Product/design implementation bridge; not implementation proof, validation proof, accessibility proof, privacy proof, or release proof  
Target: native iPhone-first Ambitions app  
Primary implementation mode: SwiftUI, local-first, on-device-first, preview-fixture-backed  
Scope: visual canon, signature objects, surface states, moat mechanics, component mapping, preview fixtures, anti-drift gates

## Batch ID

VISUAL-CANON-MOAT-01

## Runner Command

```bash
scripts/ambitions-codex-train.sh VISUAL-CANON-MOAT-01 prompts/batches/VISUAL-CANON-MOAT-01.md
```

or:

```bash
make batch BATCH=VISUAL-CANON-MOAT-01 PROMPT=prompts/batches/VISUAL-CANON-MOAT-01.md
```

## Objective

Install and begin implementing the locked Ambitions visual canon and moat-state addendum as repo authority, SwiftUI scaffolding, preview fixtures, validation gates, and implementation gap maps.

This batch must bridge the approved visual north-star set into source truth without overclaiming implementation completeness.

The moat thesis is:

```text
Ambitions compounds private ambition context into proof-backed execution decisions.
```

Do not optimize Ambitions for generic planning. Optimize Ambitions for:

```text
ambition survival
proof-backed execution
private local context
trustworthy recovery
native iPhone execution
inspectable local intelligence
```

Assume execution through:

```text
GPT-5.5 plan -> GPT-5.3-Codex-Spark bounded patch -> GPT-5.5 review/repair/final commit.
```

GPT-5.5 owns source-truth interpretation, architecture, visual canon, review, repair, and final commit eligibility. Spark may only execute bounded implementation patches derived from the GPT-5.5 plan.

## Active Source Truth To Inspect First

Read in this order before editing anything:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
README.md
docs/README.md
AGENTS.md
docs/status/current-implementation-map.md
docs/status/release-evidence-packet.md
docs/status/repo-cleanup-index.md
docs/AmbitionsCanon/README.md
docs/AmbitionsCanon/03_Signature_Object_Specs.md
docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md
docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md
docs/AmbitionsCanon/12_Screen_Composition_Constitution.md
docs/AmbitionsCanon/13_Flagship_Experience_Laws.md
docs/AmbitionsCanon/14_Flagship_QA_And_Award_Caliber_Bar.md
docs/AmbitionsCanon/17_Ambitions_Product_Grammar.md
docs/AmbitionsCanon/18_Trust_Receipts_And_Closure_Language.md
prompts/batches/MOAT-ALIGNMENT-01.md
Native/Ambitions/App/
Native/Ambitions/Domain/
Native/Ambitions/Persistence/
Native/Ambitions/Features/Today/
Native/Ambitions/Features/Goals/
Native/Ambitions/Features/Captures/
Native/Ambitions/Features/Plan/
Native/Ambitions/Features/Profile/
Native/AmbitionsTests/
Native/AmbitionsUITests/
Sources/
AppUI/Sources/
scripts/
```

If any file is missing, record it in the final report and use the closest active equivalent. Do not invent proof.

## Canon Thesis

Ambitions must visually and behaviorally express this product moat:

```text
Ambitions compounds private ambition context into proof-backed execution decisions.
```

The interface must make Ambitions harder to mistake for a task app, calendar clone, AI planner, habit tracker, productivity dashboard, chatbot, SaaS dashboard, or generic settings/account app.

The visual canon has two layers:

- Top-level north-star surfaces: the premium product-family views for Today, Goals, Capture, Time, and You.
- Moat-state addendum: the drill-down and decision states that prove Ambitions compounds ambition context into proof-backed execution.

The top-level screens show the shell. The moat-state addendum shows the defensibility.

## Active IA

The active top-level IA is exactly:

```text
Today / Goals / Capture / Time / You
```

No sixth destination is allowed.

`Plan` is not a top-level destination. `PlanScreen`, `ProfileScreen`, `Captures`, and other legacy names may remain only as internal compatibility seams when unsafe to rename immediately.

## Locked Visual North-Star Set

The locked visual canon includes:

```text
1. Shell Overview Board - product-family / IA / material reference
2. Today / Reality Meridian - top-level daily execution reference
3. Goals / Constellation Atlas - top-level direction / life-area reference
4. Capture / Atmosphere Composer - resting/default intake reference
5. Time / Day Pressure Ledger - day-level shaping reference
6. Time / Week Pressure Ledger with Reflow Crown - primary Time reference
7. Time / Month LifeShape Node Calendar - month scan / drill-down reference
8. You / User System Profile - system control reference
9. Moat Alignment Visual Addendum - Ambition Graph / proof-backed execution / inspectable recommendations / recovery / Personal Runtime reference
```

### Shell Overview Board

Purpose: product-family / IA / material reference.

Locked contents:

- Brand: AMBITIONS
- Tagline: Your life operating system.
- Today - Reality Meridian
- Goals - Constellation Atlas
- Capture - Atmosphere Composer
- Time - LifeShape Field
- You - User System Profile
- Materials: Celestial Field, Graphite Recess, Luminous Trace, Quiet Glass
- Chrome and behavior: Context Crown, Why this? / Receipts, Quiet Controls, Adaptive Color
- Closure states: Completed, Still Counts, Moved, Skipped / Not Needed, Blocked, Waiting, Needs Recovery, Needs Review

The Shell Overview board is visual-family proof only. Standalone screens and moat-state screens are the detailed implementation references.

## Material System

### Celestial Field

Use as the atmospheric foundation. It supports orientation, continuity, and calm. It must never become fantasy space, astrology wallpaper, or decorative particle noise. Density must reduce automatically for contrast, legibility, and accessibility. Motion must be optional and meaningful; no decorative constant animation.

### Graphite Recess

Use for embedded surfaces, panels, and field backgrounds. It should be dark, quiet, matte, and premium, while preserving text contrast and native iPhone feel.

### Quiet Glass

Use for interactive grouped surfaces. It must be native-touch-target-first, with soft borders and material depth, not heavy cards. It must remain readable with Increase Contrast.

### Luminous Trace

Use for semantic state, active object edges, proof, current time, protected state, pressure state, and action affordance. Never use it as decorative-only neon. Color is not the sole state channel; pair it with glyph, label, shape, brightness, or position.

## Shared Shell and Dock

### Continuity Dock

Order:

```text
Today / Goals / Capture / Time / You
```

Dock icon grammar:

- Today: Reality Meridian / sun-meridian mark
- Goals: constellation-shaped goal-thread mark
- Capture: atmosphere composer aperture
- Time: LifeShape loop / time-reality mark
- You: user/system profile outline

Rules:

- Selected destination must match the visible surface.
- Dock is consistent across all surfaces.
- No Plan tab.
- No Assistant tab.
- No notification badge noise by default.

### Context Crown

A compact state/orientation layer near the top of a surface or decision state.

Examples:

- Today: why the recommended commitment fits.
- Time: "Friday is compressed. Tue AM can absorb goal time."
- Moat states: proof target, expected receipt, trust/control summary.

Rules:

- One high-signal statement.
- May include `Why this?`.
- Must not become chatbot prose.

### Trust Seam

Reusable explanation/control layer for recommendations and adaptive behavior.

Must expose, when relevant:

```text
source refs
reason codes
ambition link
proof gap
time fit
known constraint
uncertainty
user controls
what Ambitions will remember
```

Allowed actions:

```text
Start now
Open step
Shorten
Move
Still counts
Not today
Wrong recommendation
Why this?
Forget this pattern
```

Forbidden language:

```text
AI recommends
model confidence
best next move
next best move
assistant-style explanation
```

## Moat Object Graph

The visual system must preserve this hierarchy as the durable object model:

```text
Identity Direction
  -> Life Area
    -> Ambition
      -> Outcome
        -> Goal Thread
          -> Commitment
            -> Step
              -> Closure Event
                -> Proof
                  -> Reflection
                    -> Adaptation / Recovery
```

This hierarchy appears explicitly in the Moat Alignment Visual Addendum and implicitly through the top-level surfaces.

Implementation must never treat Goal or Step as the highest-value semantic object. A task-like action is either a Step or a Commitment. A Commitment is a dated, sized promise tied to an Ambition and expected proof.

## Surface Specifications

### Today - Reality Meridian

Primary object: Reality Meridian, a living day spine showing current state, fit, commitment, closure, and proof.

Locked top-level visual:

```text
Title: Today
Date line: Tuesday, May 20
Vertical Reality Meridian with active time node
Start here attached as a Meridian Expansion Surface
Recommended step: Draft Q3 investor update
Metadata: 30 min · Deep Work
CTA: Start now
Supporting nodes: Team sync, Review deck
Lower closure/receipt drawer:
Still counts. You protected the relationship.
What matters is fit to your time, energy, and priorities.
Receipt · 8:42 AM
Reschedule recorded. Receipt saved.
```

Today moat state: Proof-backed Start Here must include recommended step, commitment, expected proof, last proof, Why this?, Start now, and Still counts / Reality changed recovery affordance.

Recommended SwiftUI component names:

```text
RealityMeridianView
MeridianTimeNode
StartHereMeridianExpansion
CommitmentFitSummary
ExpectedProofRow
LastProofAnchor
StillCountsClosureDrawer
ReceiptSurface
TrustSeamSheet
```

Required states:

```text
Empty day
Active commitment
Protected time conflict
Pressure day
Low confidence recommendation
Source stale / unavailable
Still Counts
Needs Recovery
Waiting / Blocked
Receipt available
```

Hard Reds: Today becomes a task list; Start Here becomes a detached generic card; generic calendar timeline dominates; motivational dashboard or score language appears.

### Goals - Constellation Atlas

Primary object: Constellation Atlas with Orbital Lens.

Locked top-level visual:

- Relationships selected inside Orbital Lens
- Life area constellation-shaped icons:
  - Relationships: heart
  - Career: north-star / upward path / crown-like growth
  - Health: pulse / vitality / body-energy
  - Finance: refined coin / orbit / value mark
  - Creative: spark / brush-stroke / muse
  - Home: house / shelter
  - Learning: open book / knowledge path
  - Personal Growth: sprout / growth arc
- Central metadata: next milestone, active goals, recommended step

Goals moat state: Ambition Graph / Proof Trail must show Identity Direction, Life Area, Ambition, Goal Thread, Commitment, Proof, Proof Trail receipts, next milestone, and recommended commitment.

Recommended SwiftUI component names:

```text
ConstellationAtlasView
LifeAreaConstellationIcon
OrbitalLensView
AmbitionGraphPathView
ProofTrailView
GoalThreadSummary
RecommendedCommitmentRow
LifeAreaFocusCue
```

Required states:

```text
Selected life area
No active ambition
Active goal thread
Proof trail available
Needs attention
Low signal / quiet area
Archived / paused ambition
Recovery thread available
```

Hard Reds: astrology / horoscope UI, KPI dashboard, habit rings, life score or productivity score, ranked categories, generic goal card list.

### Capture - Atmosphere Composer

Primary object: Atmosphere Composer.

Locked resting/default visual:

```text
Title: Capture
Central text: Capture anything
Supporting text: Proof, a step, a dream, a goal, or a path.
Bottom composer with plus button and mic
Subtle unlabeled constellation hints only
No visible route labels at rest
```

Capture moat state: Route Reveal appears only after the user enters content.

Allowed route options:

```text
Save as Proof
Make Commitment
Grow into Goal
Mark Constraint
Reflect
Hold / Needs a Place
```

Rules:

- Resting state stays composer-first.
- Route reveal is a decision surface, not a category board.
- Capture can classify as Proof or Constraint.

Recommended SwiftUI component names:

```text
AtmosphereComposerView
CaptureInputBar
CaptureRouteRevealSheet
CaptureRouteOptionRow
NeedsAPlaceState
ReadyToPlaceState
ProofCaptureRoute
ConstraintCaptureRoute
```

Required states:

```text
Empty resting composer
Text input active
Voice input active
Route reveal
Needs a Place
Ready to Place
Saved as Proof
Made Commitment
Marked Constraint
Held
Receipt available
```

Hard Reds: notes feed, inbox, chat transcript, Assistant UI, category board at rest, default task entry screen.

### Time - LifeShape Field

Primary object: LifeShape Field represented through Pressure Ledger with Reflow Crown.

Time is a reimagined calendar, not an anti-calendar. Calendar-grade usability is preserved through bounded date ownership.

Shared Time rules:

- Date ownership is mandatory.
- No state crosses a date boundary unless the underlying object spans dates.
- No blobs, terrain, line graphs, weather maps, or analytics charts.
- Capacity, protected time, pressure, commitments, proof opportunity, and best fit live inside bounded time units.
- Time is overview-first; details drill down.
- Reflow is preview-based and primarily owned by Week.

Day visual:

```text
One bounded day lane
Time anchors: 6 AM, 9 AM, 12 PM, 3 PM, 6 PM, 9 PM
Best fit 10 AM
Protected 2-4 PM
Evening pressure
Recovery/flex
Status strip: Open 2h 45m · Protected 2h · Pressure Evening · Best fit 10 AM
Primary action: Shape day
Secondary action: Review pressure
```

Week visual:

```text
Context Crown: Friday is compressed. Tue AM can absorb goal time.
Seven bounded day lanes:
Mon 19 - Open
Tue 20 - Best fit
Wed 21 - Protected
Thu 22 - Open
Fri 23 - Pressure
Sat 24 - Flex
Sun 25 - Flex
Tue Best fit capsule
Wed protected lane/band
Fri pressure lane
Status strip: Open 8h 30m · Protected 9h · Pressure Friday · Best fit Tue AM
Primary action: Reflow week
Secondary action: Review pressure
```

Month visual:

```text
Deconstructed month calendar
Date-owned LifeShape Nodes
Month selected
May 2025
Week of May 19 selected as compressed week
May 20 best-fit node
May 23 pressure node
Status strip: Open days 12 · Protected 3 · Pressure 4 · Best fit May 20 AM
Primary action: Open May 19 week
Secondary action: Shape month
```

Reflow does not happen at Month level.

Time moat state: Reflow Preview must include Friday is compressed, Tue AM can absorb goal time, Before / After preview, What moves, What stays protected, Expected receipt, Confirm Reflow, and Cancel.

Rules:

- No silent calendar mutation.
- Reflow produces receipt.
- Protected time must remain protected unless user explicitly changes it.
- Time must reason about proof opportunity and commitment fit, not only time availability.

Recommended SwiftUI component names:

```text
LifeShapeFieldView
PressureLedgerWeekView
PressureLedgerDayView
LifeShapeMonthNodeCalendar
TimeContextCrown
BoundedDayLane
LifeShapeNode
BestFitPlacementCapsule
ProtectedTimeBand
PressureLane
LifeShapeStatusStrip
ReflowPreviewView
ReflowReceiptSurface
```

Required states:

```text
Open capacity
Best fit
Protected
Pressure
Flex / recovery
Proof opportunity
Commitment fit
Ambition starvation signal
Reflow preview
Reflow cancelled
Reflow confirmed
Reflow receipt
```

Hard Reds: generic calendar clone, line graph, terrain / blobs / weather map, analytics dashboard, heatmap dashboard, stacked event blocks, silent optimization, reflow without preview/receipt.

### You - User System Profile

Primary object: User System Profile with Personal Runtime.

Locked top-level visual:

```text
Title: You
Profile: Devan Warner
Subtitle: Planning system, trust, privacy, and more
Planning Setup:
Schedule & Availability
Planning Defaults
Vacation / Away Time
Automation & Trust
Account & Preferences:
Notifications
Capture Preferences
Focus & Session Defaults
Privacy
Personal Runtime
Support / System:
Help
About Ambitions
```

You moat state: Personal Runtime / Local Trust must show:

```text
What Ambitions has learned
What is used for recommendations
Reset this pattern
Forget this pattern
Stored locally
Apple sync future / user-owned
Public freshness packs only, never personal context
Trust & Automation controls
```

Recommended SwiftUI component names:

```text
UserSystemProfileView
UserProfileHeaderPanel
PlanningSetupSection
AccountPreferencesSection
PersonalRuntimeView
LocalTrustBoundaryView
LearnedPatternRow
RuntimeControlRow
PrivacyBoundaryRow
```

Required states:

```text
Normal runtime
No learned patterns yet
Pattern explanation
Reset pattern
Forget pattern
Local-only boundary explanation
Apple sync future/user-owned explanation
Public freshness packs explanation
Automation disabled / limited / enabled
```

Hard Reds: social profile, family hub, admin console, AI settings wall, generic account page, external/cloud personal context assumption.

## Moat Alignment Visual Addendum

The Moat Alignment Visual Addendum is supporting canon. It does not replace top-level north stars. It proves the defensible mechanics.

Required addendum screens:

```text
Today - Proof-backed Start Here
Goals - Ambition Graph / Proof Trail
Capture - Route Reveal after input
Time - Reflow Preview
You - Personal Runtime / Local Trust
```

Bottom panels to preserve conceptually:

```text
The Ambition Graph (Durable Object)
Proof-backed execution
Inspectable recommendations
Private by design
```

## Copy and Vocabulary Rules

Preferred active terms:

```text
Ambition
Commitment
Step
Proof
Proof Trail
Recovery Thread
Still Counts
Reality Meridian
Start Here
Recommended step
LifeShape Field
Constellation Atlas
Orbital Lens
Atmosphere Composer
User System Profile
Personal Runtime
Trust Seam
Receipt Surface
Quiet Reflow
Shape Time
Needs a Place
Ready to Place
Grow into Goal
```

Terms allowed only as compatibility seams or historical references:

```text
Plan
PlanScreen
ProfileScreen
Captures
DayTimelineRail
Hero Step Panel
Goal Mission Control
Mission Control
```

Banned active user-facing/product-direction terms:

```text
Dashboard
Assistant
AI recommends
best next move
next best move
Begin Focus
Start Focus
overdue
failed
streak broken
productivity dropped
behind
get back on track
crush your goals
optimize your life
habit score
life score
productivity score
calendar clone
AI planner
```

Preferred recovery language:

```text
Reality changed.
Still counts.
Make it smaller.
Recover this thread.
Preserve the proof.
Restart from the last honest point.
```

## Accessibility Requirements

Every signature object must provide nonvisual equivalence.

Minimum requirements:

- Dynamic Type support without breaking primary object comprehension.
- VoiceOver summaries for every primary object: Reality Meridian, Constellation Atlas / Orbital Lens, Atmosphere Composer, LifeShape Field / Pressure Ledger, User System Profile / Personal Runtime.
- Reduce Motion equivalents for origin, reflow, proof, and focus transitions.
- Increase Contrast mode reduces atmosphere and strengthens boundaries.
- 44 pt minimum touch targets, 48 pt preferred for primary actions.
- Color never carries state alone.
- Visual-only constellation/time/proof meaning must have text or accessibility labels.

## Preview Fixture Matrix

Codex should create or update preview fixtures for these states where source architecture allows:

```text
Today_ActiveCommitment_ProofTarget
Today_StillCounts_Receipt
Today_NeedsRecovery
Today_TrustSeam_WhyThis
Goals_ConstellationAtlas_Relationships
Goals_AmbitionGraph_ProofTrail
Goals_LifeArea_NeedsAttention
Goals_ArchivedAmbition
Capture_RestingComposer
Capture_TextInputActive
Capture_RouteReveal_SaveAsProof
Capture_RouteReveal_MarkConstraint
Capture_NeedsAPlace
Time_Day_PressureLedger
Time_Week_ReflowCrown
Time_Month_NodeCalendar
Time_ReflowPreview
Time_ReflowReceipt
You_UserSystemProfile
You_PersonalRuntime_Normal
You_PersonalRuntime_NoPatterns
You_LocalTrustBoundary
You_ResetForgetPattern
```

## SwiftUI Implementation Strategy

Phase 1 - Authority and routing:

- Install this spec as a repo design authority document.
- Update canon indexes to point to it.
- Do not claim UI implementation before source changes and previews exist.

Phase 2 - Shared primitives:

Create or align shared primitives:

```text
AmbitionsSurfaceShell
ContinuityDock
ContextCrown
TrustSeam
ReceiptSurface
QuietGlassPanel
LuminousTrace
LifeShapeStatusStrip
AmbitionsActionRow
StateGlyph
```

Phase 3 - Signature object scaffolds:

Implement or align one component group per surface:

```text
Today / Reality Meridian
Goals / Constellation Atlas
Capture / Atmosphere Composer
Time / LifeShape Field / Pressure Ledger
You / User System Profile
```

Phase 4 - Moat-state drilldowns:

Implement addendum states:

```text
Proof-backed Start Here
Ambition Graph / Proof Trail
Route Reveal after input
Reflow Preview / Receipt
Personal Runtime / Local Trust
```

Phase 5 - Fixture and validation:

- Add preview fixtures for each state.
- Add/extend snapshot or UI tests if repo supports them.
- Add drift scans for vocabulary and signature-object violations.

## Required Implementation Scope

Make the smallest safe source changes that begin implementation without attempting an unsafe full UI rewrite.

### Shared UI primitives

Inspect existing shared UI primitives. Add or align wrappers only where safe.

Target primitives:

```text
AmbitionsSurfaceShell
ContinuityDock
ContextCrown
TrustSeam
ReceiptSurface
QuietGlassPanel
LuminousTrace
LifeShapeStatusStrip
AmbitionsActionRow
StateGlyph
```

If equivalent components already exist, extend or alias them instead of duplicating.

### Signature object scaffolds

Add or align scaffold components where safe:

```text
RealityMeridianView
StartHereMeridianExpansion
ConstellationAtlasView
LifeAreaConstellationIcon
OrbitalLensView
AtmosphereComposerView
CaptureRouteRevealSheet
LifeShapeFieldView
PressureLedgerWeekView
PressureLedgerDayView
LifeShapeMonthNodeCalendar
ReflowPreviewView
UserSystemProfileView
PersonalRuntimeView
```

If current source names differ, prefer compatibility wrappers/adapters over destructive renames.

### Preview fixtures

Add or update preview/demo fixtures for:

```text
Today_ActiveCommitment_ProofTarget
Today_StillCounts_Receipt
Today_NeedsRecovery
Today_TrustSeam_WhyThis
Goals_ConstellationAtlas_Relationships
Goals_AmbitionGraph_ProofTrail
Goals_LifeArea_NeedsAttention
Capture_RestingComposer
Capture_TextInputActive
Capture_RouteReveal_SaveAsProof
Capture_RouteReveal_MarkConstraint
Capture_NeedsAPlace
Time_Day_PressureLedger
Time_Week_ReflowCrown
Time_Month_NodeCalendar
Time_ReflowPreview
Time_ReflowReceipt
You_UserSystemProfile
You_PersonalRuntime_Normal
You_LocalTrustBoundary
You_ResetForgetPattern
```

If rendered screenshot generation is not available, create source preview fixtures and record that rendered visual proof is not produced.

## Required Surface Alignment

Today:

```text
Reality Meridian
Start Here as attached Meridian Expansion Surface
one active commitment
proof target
last-proof anchor
recovery action
Trust Seam / Why this?
Receipt Surface
```

Goals:

```text
Constellation Atlas
Orbital Lens
life-area constellation-shaped icons
Ambition Graph
Proof Trail
next milestone
recommended commitment/step
```

Capture:

```text
Atmosphere Composer resting state
post-input Route Reveal
Save as Proof
Make Commitment
Grow into Goal
Mark Constraint
Reflect
Hold / Needs a Place
Ready to Place
```

Time:

```text
LifeShape Field as Pressure Ledger with Reflow Crown
Day = bounded day lane
Week = seven bounded day lanes + Reflow Crown
Month = deconstructed LifeShape Node calendar
Reflow Preview
Reflow Receipt
proof opportunity
commitment fit
preview-before-reflow
```

You:

```text
User System Profile
Planning Setup
Trust & Automation
Privacy
Personal Runtime
what Ambitions has learned
what is used for recommendations
reset / forget pattern
local storage boundary
Apple sync future/user-owned boundary
public freshness packs only / never personal context
```

## Allowed Scope

You may modify:

```text
docs/truth/
docs/AmbitionsCanon/
docs/status/
docs/README.md
README.md
AGENTS.md
Native/Ambitions/App/
Native/Ambitions/Domain/
Native/Ambitions/Persistence/
Native/Ambitions/Features/Today/
Native/Ambitions/Features/Goals/
Native/Ambitions/Features/Captures/
Native/Ambitions/Features/Plan/
Native/Ambitions/Features/Profile/
Native/AmbitionsTests/
Native/AmbitionsUITests/
Sources/
AppUI/Sources/
scripts/
prompts/batches/
docs/codex/
```

Only modify `project.yml` if source/test additions require it.

## Forbidden Scope

Do not:

```text
- add external/cloud LLM dependency
- add OpenAI/API/cloud model calls
- add custom hosted personal-data backend
- add account/auth system
- add Supabase/Firebase/server profile assumptions
- add paid services
- add hosted CI that could create cost
- claim R2 freshness is implemented unless real source and tests exist
- claim iCloud/CloudKit sync is implemented unless real entitlement/source/tests exist
- claim App Store/TestFlight/device readiness
- claim privacy/legal approval
- claim accessibility conformance without proof
- make Plan a top-level user-facing destination
- add a sixth top-level tab
- make Capture a feed/chat/inbox/category board
- make Time a graph, terrain, blob map, weather map, or generic calendar clone
- make Goals a dashboard/score/ring system
- make Today a generic task list
- make You a social profile/admin console
- remove useful compatibility seams without migration proof
```

## Validation Expectations

Run the strongest local validation available.

Minimum scans to run if present or created:

```bash
python3 scripts/ambitions-moat-drift-scan.py
python3 scripts/ambitions-vocabulary-drift-scan.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-signature-object-gate.py
python3 scripts/ambitions-control-plane-check.py
```

Also run where available:

```bash
xcodegen generate
./scripts/build-local.sh
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsTests test
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsUITests test
```

If a command cannot run, record:

```text
Command not run
Reason
What proof is still missing
```

## Visual Proof Expectations

If UI source changes are made, generate or update preview fixtures where feasible.

Required fixture coverage:

```text
Today / Reality Meridian / Start Here / proof target / recovery
Goals / Constellation Atlas / Ambition Graph / Proof Trail
Capture / Atmosphere Composer / Save as Proof / Mark as Constraint
Time / LifeShape Field / proof opportunity / commitment fit / reflow receipt
You / User System Profile / Personal Runtime / Trust & Automation
```

If rendered screenshots cannot be generated, record that visual proof is not produced.

Do not claim visual QA passed, flagship UI complete, screenshots approved, accessibility verified, or release ready unless current proof exists.

## Hard Red Stop Conditions

Stop, repair, and rerun validation if any are introduced:

```text
Plan appears as a top-level tab.
A sixth top-level tab is added.
Today becomes a task list/calendar timeline/focus widget.
Start Here becomes a detached generic card stack.
Capture becomes notes feed/inbox/chatbot/category board.
Time becomes graph/terrain/blob/weather-map/analytics dashboard/generic calendar clone.
Goals becomes KPI dashboard/habit ring/life score/ranked category system.
You becomes social profile/family hub/admin console/AI settings wall.
Any core flow requires external/cloud LLM.
Any core flow requires custom hosted backend/account.
Any recommendation lacks source/control path.
Any adaptive behavior lacks receipt or inspectability.
Any proof/recovery state uses shame language.
Any user-facing copy uses "Begin Focus," "Start Focus," "best next move," or "next best move."
Any release/readiness/privacy/legal claim is made without proof.
Any visual-only object has no accessibility equivalent.
```

## Rollback Expectations

Before broad edits, record current branch and commit.

For risky source changes:

```text
- prefer additive wrappers/adapters over destructive renames
- preserve compatibility seams where blind rename would break routing/tests
- keep migration plans separate from unsafe schema rewrites
- avoid large one-shot SwiftData migrations unless fully tested
- isolate new scripts so they can be disabled or repaired
```

If validation fails and repair is nontrivial, do not hide the failure. Leave the repo in the best safe state, document the failure, and specify exact next repair actions.

## Required Report Artifact

Create or update:

```text
docs/status/visual-canon-moat-implementation-report.md
```

It must include:

```text
- batch ID
- current commit
- files changed
- visual canon installed
- moat-state addendum installed
- docs changed
- source changed
- preview fixtures changed
- tests changed
- scripts/gates changed
- compatibility seams retained
- unimplemented items
- unproven items
- validation commands run / passed / failed / not run
- visual proof status
- accessibility proof status
- rollback notes
- next recommended batches
```

## Final Report Required

At the end, report exactly:

```text
Status: Green / Yellow / Red
Batch ID:
Branch:
Commit:
Files changed:
Visual canon installed:
Moat addendum installed:
Docs changed:
Source changed:
Preview fixtures changed:
Tests changed:
Scripts/gates changed:
Compatibility seams retained:
Commands run:
Commands passed:
Commands failed:
Commands not run:
Visual proof:
Accessibility proof:
Privacy/local-first proof:
Release claims allowed:
Release claims forbidden:
Unimplemented:
Unproven:
Rollback notes:
Next recommended batches:
```

## Success Criteria

Green only if:

```text
- active docs/canon now define the locked visual system
- moat-state addendum is installed as supporting canon
- source-level wrappers/scaffolds/previews are added where feasible
- Today / Goals / Capture / Time / You remain the only top-level tabs
- Time uses Pressure Ledger / Reflow Crown, not old graph/terrain/blob visuals
- Capture resting state remains composer-first
- Goals uses Constellation Atlas / Orbital Lens, not dashboard/astrology
- You uses User System Profile / Personal Runtime, not social/profile settings
- no forbidden architecture or copy was introduced
- validation ran or was honestly marked not run
- no false visual/accessibility/privacy/release claims were made
```

Yellow if:

```text
- docs/canon are installed
- source/previews are partially scaffolded but major UI implementation remains
- validation is partially blocked by local environment
- compatibility seams remain and are documented
```

Red if:

```text
- truth/canon conflicts are introduced
- forbidden product direction is introduced
- build breaks after source changes where build was previously possible
- external/cloud LLM or hosted personal backend dependency is introduced
- false release/privacy/accessibility claims are made
```

## Final Operating Rule

Every changed file should make Ambitions harder to mistake for Motion, Sunsama, Reclaim, Akiflow, Todoist, a habit tracker, a calendar app, a dashboard, or a chatbot.
