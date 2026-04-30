# Ambitions 3.0 — Ambition Meridian Shell SwiftUI Build Spec

Status: Active implementation-grade child doc  
Parent: [`Ambitions_3_0_Front_End_Redesign_Index.md`](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Supporting frontend history: [`Ambitions_Full_Frontend_Transformation_Program.md`](./Ambitions_Full_Frontend_Transformation_Program.md)  
Surface ownership: System-wide shell across Today, Goals, Capture, Plan, and You  
Implementation status: Documentation only. Do not implement app code from this doc unless explicitly prompted.

---

## Product purpose

The Ambition Meridian Shell is the signature Ambitions 3.0 navigation invention.

It replaces the feeling of a standard five-tab dock with a premium connected-node navigation instrument that is calm, contextual, and system-wide. It preserves the canonical top-level destinations — Today, Goals, Capture, Plan, and You — while making the shell feel like Ambitions’ own life-operating-system layer instead of a generic app tab bar.

The Meridian should help the user understand:

- where they are
- where they can go
- what is currently active
- whether something needs closure
- whether proof was saved
- how Capture remains available without becoming a loud plus button

The shell is not decorative chrome. It is a trust, navigation, and context layer.

---

## Surface ownership

The Ambition Meridian Shell is system-wide.

It owns global navigation across:

- Today
- Goals
- Capture
- Plan
- You

It may also reflect system context from:

- Step Session
- Action Closure
- Receipts
- Proof
- Plan pressure
- Capture inbox / Needs a Place count
- Vacation / Away Time
- Automation & Trust where relevant

It does not own the internal content architecture of each tab. It routes to those surfaces and reflects state from them.

Canonical top-level destinations remain exactly:

```text
Today
Goals
Capture
Plan
You
```

Destination roles:

```text
Today   = Home / Now / current truth
Goals   = Path / meaning / ambition structure
Capture = Universal input / what needs a place
Plan    = Time / shape / believability
You     = System / trust / personalization
```

---

## User problem solved

A standard five-tab shell is clear, but it does not feel signature. It also treats Today, Goals, Capture, Plan, and You as five equal app departments instead of five roles in a personal operating system.

The Ambition Meridian Shell solves this by:

- keeping navigation obvious
- making Today feel like home
- making Capture feel globally available
- letting active step state appear without a bulky pill
- making closure and receipt state visible without red badges or shame
- creating a recognizable Ambitions visual signature

The goal is not novelty for its own sake. The goal is calmer orientation and stronger product identity.

---

## Signature interaction or component

The signature component is a bottom connected-node rail:

```text
●────○────✦────○────○
Today
```

The five nodes represent:

```text
Today   Goals   Capture   Plan   You
```

The selected destination is shown with:

- filled or emphasized node
- selected label only
- restrained gold or semantic accent
- accessibility selected state

The center Capture node is an aperture/star mark, not a large plus button.

The Meridian can reflect contextual states through the line and caption:

Normal Today:

```text
●────○────✦────○────○
Today
```

Active step:

```text
●━━━━○────✦────○────○
Today · Step · 18m
```

Closure needed:

```text
●────○────✦────○────○
Today · 1 closure
```

Receipt saved:

```text
●────○────✦────○────○
Saved · Still Counts
```

Plan selected:

```text
○────○────✦────●────○
Plan
```

Capture selected:

```text
○────○────✦────○────○
Capture
```

---

## Non-goals

The Ambition Meridian Shell must not become:

- a bulky rounded tab-bar capsule
- a floating active-step pill stacked above a dock
- a five-label tab bar with custom styling
- a giant center plus button
- an AI command button
- a radial menu
- a hamburger menu
- a notification banner surface
- a red-badge attention system
- a gamified streak / reward strip
- a calendar scrubber
- a dense status dashboard
- a place where Step Session controls permanently crowd navigation

The Meridian must never trap the user. Context must never hide navigation.

---

## Visual direction

The visual direction is a thin, premium, connected navigation instrument.

It should feel like:

- Apple quiet luxury
- OpenAI restraint
- executive command surface
- native iPhone system layer
- authored Ambitions signature object

It should use:

- warm graphite / charcoal / soft black
- thin connected rail line
- five calm nodes
- selected label only
- center capture aperture/star
- soft gold only for selected/accent/proof moments
- material depth only when necessary
- bottom safe-area awareness
- subtle shadow and top hairline, not heavy glass

It should not use:

- large capsules
- heavy glow
- bright gradients
- stock tab-bar energy
- large circular FAB treatment
- red or urgent badge systems
- novelty motion that reduces clarity

### Relation to Ambitions Day Rail

The Meridian should share visual grammar with the Ambitions Day Rail:

- rails
- nodes
- proof marks
- closure states
- calm connection lines
- restrained gold accents

The Today Day Rail is the vertical execution/proof spine. The Meridian is the bottom global navigation spine.

Together they create the Ambitions 3.0 shell language.

---

## SwiftUI architecture

The Meridian should be a reusable SwiftUI component owned by the app shell or design system, not a one-off Today component.

Preferred component:

```swift
struct AmbitionsMeridianShell: View {
    let state: AmbitionsMeridianState
    let onSelectDestination: (AmbitionsDestination) -> Void
    let onOpenCapture: (() -> Void)?
    let onReturnToActiveStep: (() -> Void)?
    let onOpenClosure: (() -> Void)?
}
```

Architectural principles:

- Keep `TabView` / `NavigationStack` infrastructure if already used for routing safety.
- Hide the stock tab bar only if the existing app architecture supports doing so safely.
- Render the Meridian as the user-facing shell.
- Keep routing state outside the visual component.
- Use view state models rather than direct domain coupling.
- Do not fetch data inside the shell component.
- Do not let the shell mutate domain objects directly.
- Expose actions via callbacks.
- Keep Step Session and Action Closure ownership in their feature areas.

Recommended root integration pattern:

```swift
ZStack(alignment: .bottom) {
    TabView(selection: $selectedDestination) {
        TodayScreen()
            .tag(AmbitionsDestination.today)

        GoalsScreen()
            .tag(AmbitionsDestination.goals)

        CaptureScreen()
            .tag(AmbitionsDestination.capture)

        PlanScreen()
            .tag(AmbitionsDestination.plan)

        YouScreen()
            .tag(AmbitionsDestination.you)
    }

    AmbitionsMeridianShell(
        state: meridianState,
        onSelectDestination: selectDestination,
        onOpenCapture: openCapture,
        onReturnToActiveStep: returnToActiveStep,
        onOpenClosure: openClosure
    )
}
```

If the repo already has a root shell abstraction, integrate there rather than creating a duplicate shell.

---

## File plan

Preferred files:

```text
Native/Ambitions/DesignSystem/Navigation/AmbitionsMeridianShell.swift
Native/Ambitions/DesignSystem/Navigation/AmbitionsMeridianModels.swift
Native/Ambitions/DesignSystem/Navigation/AmbitionsMeridianTokens.swift
Native/Ambitions/DesignSystem/Navigation/AmbitionsMeridianHaptics.swift
Native/Ambitions/DesignSystem/Navigation/AmbitionsMeridianPreviews.swift
```

Root integration files may include:

```text
Native/Ambitions/App/AmbitionsRootView.swift
Native/Ambitions/App/AppTab.swift
Native/Ambitions/App/AmbitionsAppShell.swift
```

Test files may include:

```text
Native/AmbitionsTests/DesignSystem/AmbitionsMeridianStateTests.swift
Native/AmbitionsUITests/AmbitionsMeridianShellUITests.swift
```

Use actual repo naming if different. Do not duplicate existing concepts if equivalent files already exist.

---

## Domain/view state models

### Destination

```swift
enum AmbitionsDestination: String, CaseIterable, Identifiable, Equatable {
    case today
    case goals
    case capture
    case plan
    case you

    var id: String { rawValue }
}
```

### Meridian state

```swift
struct AmbitionsMeridianState: Equatable {
    var selectedDestination: AmbitionsDestination
    var context: AmbitionsMeridianContext
    var unplacedCaptureCount: Int
    var planPressure: AmbitionsPlanPressure
    var hasGoalProofUpdate: Bool
}
```

### Context

```swift
enum AmbitionsMeridianContext: Equatable {
    case normal
    case activeStep(ActiveStepMeridianState)
    case closureNeeded(count: Int)
    case receiptSaved(message: String)
    case protectedTime(label: String)
}
```

### Active step

```swift
struct ActiveStepMeridianState: Identifiable, Equatable {
    let id: String
    let title: String
    let remainingMinutes: Int
    let goalLabel: String?
}
```

### Plan pressure

```swift
enum AmbitionsPlanPressure: Equatable {
    case open
    case workable
    case tight
    case overloaded
}
```

### Node visual state

```swift
enum AmbitionsMeridianNodeState: Equatable {
    case inactive
    case selected
    case capture
    case activeStep
    case closureNeeded
    case proofUpdated
    case planPressure(AmbitionsPlanPressure)
}
```

These are view-state models. They should adapt existing domain data into shell-ready state without forcing domain rewrites in the first shell implementation.

---

## Component breakdown

### `AmbitionsMeridianShell`

Owns:

- overall shell layout
- bottom safe-area treatment
- caption
- rail
- node row
- action callbacks
- accessibility grouping

Does not own:

- app-level route storage
- domain mutation
- Step Session content
- Action Closure sheet content
- Capture composer internals

### `AmbitionsMeridianCaption`

Owns:

- selected destination label
- active step caption
- closure-needed caption
- receipt-saved caption
- protected-time caption

Rules:

- one line by default
- Dynamic Type safe
- no constant `Close` button
- active step caption is tappable if active

### `AmbitionsMeridianRail`

Owns:

- connected baseline
- active segment
- selected segment treatment
- reduced-motion fallback

### `AmbitionsMeridianNode`

Owns:

- 44x44 minimum hit target
- destination-specific mark
- selected state
- special states such as plan pressure or closure-needed ring
- accessibility label / hint / selected trait

### `AmbitionsCaptureApertureMark`

Owns:

- center capture mark
- aperture/star/spark geometry
- selected/open state
- no giant plus styling

### `AmbitionsMeridianBackground`

Owns:

- safe-area gradient
- top hairline
- optional material layer
- no bulky capsule container

---

## Actions and navigation

### Destination selection

```swift
func selectDestination(_ destination: AmbitionsDestination) {
    switch destination {
    case .today:
        selectedDestination = .today
    case .goals:
        selectedDestination = .goals
    case .capture:
        openCapture()
    case .plan:
        selectedDestination = .plan
    case .you:
        selectedDestination = .you
    }
}
```

### Capture

Tapping Capture should:

1. Open the global Capture composer if available.
2. Otherwise route to the Capture tab.
3. Trigger a soft haptic.
4. Preserve existing navigation safety.

### Active step

When active step context exists:

- caption displays `Today · Step · 18m` or equivalent
- tapping caption returns to Step Session
- long press opens Action Closure if available
- shell does not show permanent `Close`

### Closure needed

When closure is needed:

- Today node may show an open-ring state
- caption may show `Today · 1 closure`
- tap Today opens Today
- closure action is owned by Today / Action Closure, not by a permanent shell button

### Receipt saved

When receipt is saved:

- caption briefly shows `Saved · Still Counts`, `Saved · Completed`, or equivalent
- state clears after 2–3 seconds
- optional proof animation may be deferred

---

## Adaptive states

Required states:

1. Normal navigation
2. Selected destination
3. Capture selected/open
4. Active step
5. Closure needed
6. Receipt saved
7. Plan pressure
8. Goal proof update
9. Protected / vacation / away context
10. Large Dynamic Type
11. Reduce Motion
12. Light mode
13. Offline / degraded state if existing app state supports it

State priority if multiple are present:

1. Receipt saved, while transient
2. Active step
3. Closure needed
4. Protected / away context
5. Selected destination
6. Secondary node marks such as capture count, goal proof, plan pressure

Do not stack captions into multiple lines of system noise. If multiple states compete, show the highest-priority caption and use subtle node marks for secondary state.

---

## Accessibility requirements

The Meridian must be accessibility-first.

Requirements:

- Each destination node is a `Button`.
- Each destination node has an accessibility label.
- Each destination node has an accessibility hint.
- Selected destination exposes selected trait.
- Visible state is not color-only.
- All tap targets are at least 44x44.
- Dynamic Type does not clip critical caption text.
- Reduce Motion is respected.
- VoiceOver order follows Today, Goals, Capture, Plan, You, then contextual active caption if needed.

Suggested labels:

```text
Today: Today, home view
Goals: Goals, your path and ambitions
Capture: Capture something that needs a place
Plan: Plan, your time and schedule
You: You, your personal system and trust settings
```

Active step label:

```text
Active step, 18 minutes remaining. Double tap to return to the active step. Long press for closure options.
```

Closure label:

```text
One step needs closure. Go to Today to close the loop.
```

Receipt label:

```text
Saved. Still Counts.
```

---

## Motion/haptics rules

Motion should be restrained.

Allowed:

- opacity transition
- line trim/fill
- small scale range such as 0.98–1.03
- soft caption crossfade
- subtle selected-node transition

Avoid:

- bounce
- springy tab jumps
- heavy glow pulse
- gamified bursts
- constant shimmer
- motion that implies urgency

Respect Reduce Motion:

- disable line-travel proof animations
- disable pulse
- use simple fade/state replacement

Haptics:

- destination tap: selection haptic
- Capture open: soft impact
- active step return: light impact
- receipt saved: success confirmation
- closure-needed state should not haptically nag the user without interaction

Suggested helper:

```swift
enum AmbitionsMeridianHaptics {
    static func selection()
    static func softImpact()
    static func confirmation()
    static func attention()
}
```

---

## Preview fixtures

Create deterministic previews for:

```text
Meridian — Today selected
Meridian — Goals selected
Meridian — Capture selected
Meridian — Plan selected
Meridian — You selected
Meridian — Active Step
Meridian — Closure Needed
Meridian — Receipt Saved
Meridian — Protected Time
Meridian — Plan Tight Pressure
Meridian — Goal Proof Update
Meridian — Large Dynamic Type
Meridian — Light Mode
Meridian — Reduce Motion
```

Use sample content:

```text
Active step: Draft PM transition notes
Remaining: 18m
Goal: Career Growth
Receipt: Saved · Still Counts
Closure: 1 closure
Protected: Away protected
Plan pressure: Tight but workable
```

Previews should show the Meridian alone and inside at least one root-shell mock container.

---

## Tests

Add or update tests for:

### Unit / model tests

- destination ordering is Today, Goals, Capture, Plan, You
- default caption equals selected destination title
- active step caption includes remaining minutes
- closure caption handles singular/plural
- receipt caption uses provided message
- protected-time caption includes selected destination + label
- state priority favors receipt over active step while receipt is transient

### UI tests

- Today node navigates to Today
- Goals node navigates to Goals
- Capture node opens Capture/composer
- Plan node navigates to Plan
- You node navigates to You
- active step token can return to Step Session or placeholder route
- no persistent `Close` button appears in the shell
- no five always-visible text labels appear by default if testable

### Accessibility tests

- all nodes have labels
- selected node exposes selected state
- hit targets are at least 44x44 where testable
- Reduce Motion does not block state changes
- Dynamic Type does not hide destination access

---

## Acceptance criteria

Visual acceptance:

- The user-facing shell is a connected-node Meridian, not a stock dock.
- It contains exactly five top-level destinations.
- Only selected destination label is visible by default.
- Capture appears as a center aperture/star, not a giant plus.
- Active step state appears through caption/line state, not a floating pill.
- No persistent shell `Close` button exists.
- Closure needed is calm and non-red.
- Receipt saved is calm and transient.
- The shell visually relates to the Ambitions Day Rail.

Interaction acceptance:

- All five destinations route correctly.
- Capture is globally reachable.
- Active step can be returned to from the shell.
- Closure can be opened through a deliberate action, not constant pressure.
- Receipt state appears and clears.
- Navigation is never hidden by context.

Engineering acceptance:

- No third-party dependencies.
- Shell is reusable.
- State is model-driven.
- Routing is callback-driven.
- Existing navigation stacks remain intact.
- Existing deep links are not broken.
- Previews exist.
- Tests exist.

Accessibility acceptance:

- VoiceOver labels and hints are clear.
- Dynamic Type remains usable.
- Reduce Motion is respected.
- Touch targets meet minimum size.
- Color is not the only state indicator.

Canon acceptance:

- Preserves Today / Goals / Capture / Plan / You.
- Does not widen the app.
- Does not reintroduce Insights/Profile as top-level surfaces.
- Uses current Ambitions language rules.
- Aligns with Day Rail, Action Closure, receipts, proof, guided automation, and trust posture.

---

## Codex implementation sequence

1. Read `docs/canon/SOURCE_OF_TRUTH_MAP.md`.
2. Read `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`.
3. Read this child doc in full.
4. Inspect the current root shell, tab routing, navigation stacks, and destination enum names.
5. Identify whether the repo already has shell/navigation tokens, haptics, or app tab models.
6. Add or adapt Meridian view-state models.
7. Build `AmbitionsMeridianShell` as a standalone reusable SwiftUI component.
8. Add previews for all required states.
9. Integrate the Meridian into the root app shell without breaking existing routing.
10. Hide or replace the visible stock tab bar only if safe in the current app architecture.
11. Wire callbacks for Today, Goals, Capture, Plan, You.
12. Wire active-step, closure-needed, and receipt states to existing or placeholder state adapters.
13. Add unit tests.
14. Add UI/accessibility tests where existing infrastructure supports them.
15. Run build and tests.
16. Document any intentionally deferred behavior in the implementation summary.

Do not implement future composer-slit transformation unless explicitly scoped in the implementation prompt.

---

## Known dependencies

Implementation depends on:

- existing root app shell / tab routing structure
- existing destination enum or equivalent app tab model
- existing Today / Goals / Capture / Plan / You screens
- existing Step Session route or placeholder route
- existing Action Closure route or placeholder route
- existing receipt/proof state if available
- existing design tokens or permission to add Meridian-local tokens
- SwiftUI
- Foundation
- UIKit only for haptics

No external dependencies are allowed.

Related canon dependencies:

- `docs/canon/SOURCE_OF_TRUTH_MAP.md`
- `docs/canon/Ambitions_Master_Product_Visual_System_Spec_v2.md`
- `docs/canon/Ambitions_Master_Product_Visual_System_v2_Decision_Addendum_2026_04_30.md`
- `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
- `docs/canon/Ambitions_3_0_Day_Rail_SwiftUI_Build_Spec.md`
- `docs/canon/IA_NAVIGATION_DRILLDOWN.md`
- `docs/canon/TODAY_NOW_STATE.md`
- `docs/canon/VISUAL_SYSTEM_COMPONENTS_MOTION.md`
- `docs/canon/design/DESIGN_TOKENS.md`
- `docs/canon/Ambitions_Full_Frontend_Transformation_Program.md` as historical/supporting frontend ambition context only

---

## Open questions

1. Should the first implementation fully hide the native tab bar, or should the Meridian initially ship behind a feature flag while TabView remains visible in debug builds?
2. Should the active step caption always begin with the selected destination name, or should it always anchor to Today even when the user is in Goals/Plan/You?
3. Should the Capture aperture open a composer overlay immediately, or navigate to the Capture screen until the global composer architecture is implemented?
4. Should Plan pressure be visible as a ring around the Plan node in the first implementation, or deferred until Plan state is more mature?
5. Should proof traveling from Today to Goals be implemented in v1, or deferred as a motion polish pass?
6. What existing app state should drive `closureNeeded(count:)` in the first implementation?
7. Should `receiptSaved(message:)` be driven by the existing receipt system or by a short-lived root-shell event bus?
8. Should the Meridian appear on all drill-downs, or only top-level surfaces plus selected execution flows?

---

## Implementation guardrail

This child doc is implementation-grade, but it is not permission to build app code by itself.

Codex must only implement it when the implementation prompt explicitly says to build the Ambition Meridian Shell.
