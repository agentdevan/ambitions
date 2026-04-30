# Ambitions 3.0 — Day Rail SwiftUI Build Spec

Status: Active implementation spec draft  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Surface: Today  
Primary component: `AmbitionsDayRailView`  
Last updated: 2026-04-30

---

## 1. Product Purpose

The Ambitions Day Rail is the signature visual and interaction object for the Today screen.

It is not a generic timeline, checklist, schedule, dashboard, habit tracker, or focus timer. It is the visible projection of the Ambitions system:

```text
Goals decide meaning.
Plan decides fit.
Schedule decides availability.
Capture feeds possibilities.
Ambitions recommends the step.
User chooses.
Closure handles reality.
Receipts preserve trust.
Proof makes progress visible.
```

The Day Rail should show the user’s believable path through the day, not merely the user’s day.

The component must help the user answer these questions within 10 seconds:

1. What should I start now?
2. Why this step?
3. How long will it take?
4. What ambition or goal does it serve?
5. What happens if I cannot do it?
6. What already counted today?
7. Did Ambitions change anything silently?

---

## 2. Surface Ownership

Surface: Today  
Primary view: existing Today screen entry point  
New primary component: `AmbitionsDayRailView`

The Day Rail should be integrated near the top of Today and should become the dominant Today object.

Preferred Today hierarchy:

```text
1. Compact Today context header
2. Ambitions Day Rail
3. Secondary Today content, only if it does not duplicate the rail
```

Do not bury the Day Rail below multiple panels.

---

## 3. User Problem Solved

Users do not need another task list. They need a calm, trusted, realistic answer to:

> What matters now, what fits, what changed, and what still counts?

The Day Rail solves:

- Decision paralysis
- Overloaded daily plans
- Shame from missed tasks
- Disconnection between daily actions and larger goals
- Distrust of automated planning
- Lack of proof that progress happened
- Unclear next-step prioritization

---

## 4. Signature Interaction

The Day Rail combines five ideas:

1. `Start here` — one recommended step
2. `Today` — Now / Next / Later path
3. `Close the loop` — non-shaming closure for stale or changed steps
4. `Proof saved` — what counted and what changed
5. `No silent changes` — trust confirmation

Default flagship content:

```text
Thursday
Workday · first open window at 5:25 · Tight but workable

[Career Growth] [Build leverage daily]

Start here
● Draft PM transition notes
│ 25 min suggested · Career Growth
│ Why this: fits open window + high leverage
│ [Start now] [Adjust plan] [Why this?]

Today
● Now
│ Work block · Ambitions quiet until 5:25

○ Next
│ Pay Verizon bill
│ 5 min · Due today

○ Later
│ Music session
│ Flexible · optional if energy holds

Close the loop
◇ Gym from yesterday
│ [Still counts] [Move] [Skip]

Proof saved
◆ 2 things counted today
│ No silent changes
```

---

## 5. Non-Goals

Do not use this build to:

- Add or rename top-level tabs
- Build a full calendar
- Build a generic task list
- Build a habit tracker
- Build an AI assistant panel
- Build a productivity score
- Add streaks, badges, confetti, or gamified pressure
- Add cloud sync
- Add third-party dependencies
- Add persistence migrations unless already required by existing architecture
- Add networking
- Add a starfield background to Today

Starfield/dark-sky visual treatment belongs to Capture and First Run only unless canon is revised.

---

## 6. Visual Direction

The Day Rail should feel:

- Premium
- Calm
- Native iPhone-first
- Restrained
- Warm graphite / soft black / charcoal
- Material-like
- Expensive
- Human
- Trustworthy
- Deep, not wide

Visual ingredients:

- Vertical connected rail on the left
- Filled glowing node for `Start here`
- Hollow nodes for upcoming rows
- Diamond node for `Close the loop`
- Distinct proof/receipt marker for `Proof saved`
- Rounded premium cards on the right
- Warm gold accent used sparingly
- Thin hairline strokes
- Native typography
- No loud colors
- No dashboard clutter
- No generic checkbox affordances

---

## 7. SwiftUI Architecture

The Day Rail must be a reusable product object, not a one-off Today mockup.

Required top-level view:

```swift
struct AmbitionsDayRailView: View {
    let state: AmbitionsDayRailViewState
    let actions: AmbitionsDayRailActions

    var body: some View {
        // premium SwiftUI implementation
    }
}
```

Views render state. They should not own business logic.

Projection logic should live in a view model or projection service that converts existing Today/Plan/Goal/Schedule/Capture/Receipt state into `AmbitionsDayRailViewState`.

---

## 8. File Plan

Prefer this folder structure unless the repo’s existing convention requires adjustment:

```text
Native/Ambitions/Features/Today/DayRail/
  AmbitionsDayRailView.swift
  AmbitionsDayRailModels.swift
  AmbitionsDayRailViewModel.swift
  AmbitionsDayRailActions.swift
  AmbitionsDayRailTheme.swift
  AmbitionsDayRailPreviewFixtures.swift

Native/Ambitions/Features/Today/DayRail/Components/
  DayRailContextHeader.swift
  DayRailNodeColumn.swift
  DayRailNodeView.swift
  DayRailSectionHeader.swift
  DayRailHeroStepCard.swift
  DayRailTodayStackCard.swift
  DayRailTodayRowView.swift
  DayRailCloseLoopCard.swift
  DayRailProofSavedCard.swift
  DayRailChipView.swift
  DayRailActionButton.swift
  DayRailExplanationSheet.swift
  DayRailAdjustmentSheet.swift
  DayRailClosureSheet.swift
  DayRailReceiptPeekSheet.swift

Native/AmbitionsTests/Features/Today/DayRail/
  AmbitionsDayRailModelsTests.swift
  AmbitionsDayRailViewModelTests.swift
  AmbitionsDayRailAccessibilityTests.swift
  AmbitionsDayRailCopyGuardTests.swift
  AmbitionsDayRailPreviewFixtureTests.swift

Native/AmbitionsUITests/
  AmbitionsDayRailUITests.swift
```

If the repo has existing Today panel files, integrate without breaking current compilation.

---

## 9. Dependencies

Do not add third-party dependencies.

Allowed native imports:

```swift
import SwiftUI
import Foundation
```

Optional only if needed and repo style allows:

```swift
import UIKit
```

Use existing Ambitions theme/design token systems where available.

Do not add:

- External timeline libraries
- Animation packages
- Calendar libraries
- Chart libraries
- Network dependencies
- Persistence dependencies

---

## 10. Domain / View State Models

Create `AmbitionsDayRailModels.swift`.

### 10.1 Main state

```swift
import Foundation

struct AmbitionsDayRailViewState: Equatable, Identifiable {
    let id: String
    let dateTitle: String
    let contextSummary: String
    let dayTone: DayRailDayTone
    let density: DayRailDensity
    let chips: [DayRailChip]
    let startHere: DayRailRecommendedStep?
    let todayRows: [DayRailTodayRow]
    let closurePrompts: [DayRailClosurePrompt]
    let proofSummary: DayRailProofSummary?
    let footerMessage: String?
    let showsNoSilentChanges: Bool
}
```

### 10.2 Day tone

```swift
enum DayRailDayTone: String, CaseIterable, Equatable {
    case normal
    case calm
    case tightButWorkable
    case overloaded
    case recovery
    case lowEnergy
    case protected
    case away
    case empty
    case noSchedule
    case endOfDay
}
```

User-facing tone labels should be calm:

```text
Normal
Calm day
Tight but workable
Plan is too full
Recovery day
Low-energy fit
Protected day
Away today
Nothing needs you right now
Schedule not set
Wrap today
```

### 10.3 Density

```swift
enum DayRailDensity: String, CaseIterable, Equatable {
    case calm
    case balanced
    case detailed
}
```

Default: `.balanced`

Density behavior:

```text
Calm:
- Start here
- One next item
- One closure/proof summary if needed

Balanced:
- Start here
- Now
- Next
- Later
- Close the loop
- Proof saved

Detailed:
- Adds evidence labels
- Adds duration source
- Adds extra explanation lines
```

### 10.4 Chips

```swift
struct DayRailChip: Identifiable, Equatable {
    let id: String
    let title: String
    let systemImage: String?
    let role: DayRailChipRole
}

enum DayRailChipRole: String, Equatable {
    case ambition
    case context
    case pressure
    case evidence
    case mode
}
```

Maximum visible chips: 2.

If more chips exist, hide extras or show a restrained `+N` chip.

### 10.5 Recommended step

```swift
struct DayRailRecommendedStep: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let duration: DayRailDuration?
    let connectedAmbition: DayRailConnectedAmbition?
    let fit: DayRailStepFit
    let whySummary: String
    let explanation: DayRailRecommendationExplanation
    let primaryActionTitle: String
    let secondaryActionTitle: String
    let tertiaryActionTitle: String?
    let iconSystemName: String
}
```

Default preview example:

```swift
DayRailRecommendedStep(
    id: "pm-notes",
    title: "Draft PM transition notes",
    subtitle: nil,
    duration: .init(minutes: 25, source: .suggested, range: nil),
    connectedAmbition: .init(id: "career-growth", title: "Career Growth", systemImage: "target"),
    fit: .strong,
    whySummary: "fits open window + high leverage",
    explanation: .flagshipPMNotes,
    primaryActionTitle: "Start now",
    secondaryActionTitle: "Adjust plan",
    tertiaryActionTitle: "Why this?",
    iconSystemName: "pencil.and.outline"
)
```

### 10.6 Duration

```swift
struct DayRailDuration: Equatable {
    let minutes: Int
    let source: DayRailDurationSource
    let range: ClosedRange<Int>?
}

enum DayRailDurationSource: String, Equatable {
    case userSet
    case suggested
    case historicallyBased
    case acceptedFromPlan
    case calendarBlock
}
```

Labels:

```text
25 min · You set this
25 min suggested
Usually 20–30 min
25 min · Accepted from plan
25 min · From calendar block
```

Durations must not feel magical.

### 10.7 Connected ambition

```swift
struct DayRailConnectedAmbition: Identifiable, Equatable {
    let id: String
    let title: String
    let systemImage: String?
}
```

Examples:

```text
Career Growth
Financial Stability
Music
Home & Family
Health
```

### 10.8 Step fit

Do not display numeric confidence.

```swift
enum DayRailStepFit: String, CaseIterable, Equatable {
    case strong
    case good
    case light
    case optional
    case needsReview
}
```

Labels:

```text
Strong fit
Good fit
Light fit
Optional
Needs review
```

Never show:

```text
92% confidence
AI confidence
Productivity score
```

### 10.9 Recommendation explanation

```swift
struct DayRailRecommendationExplanation: Equatable {
    let title: String
    let reasons: [String]
    let notChosen: [DayRailNotChosenReason]
    let sourceFacts: [DayRailSourceFact]
    let canTeachSystem: Bool
}

struct DayRailNotChosenReason: Identifiable, Equatable {
    let id: String
    let title: String
    let reason: String
}

struct DayRailSourceFact: Identifiable, Equatable {
    let id: String
    let label: String
    let source: DayRailEvidenceSource
}

enum DayRailEvidenceSource: String, Equatable {
    case openWindow
    case dueDate
    case goalPriority
    case userPlan
    case schedule
    case protectedTime
    case lowEnergy
    case history
    case closureState
    case waitingOnSomeone
    case manualChoice
}
```

### 10.10 Today rows

```swift
struct DayRailTodayRow: Identifiable, Equatable {
    let id: String
    let slot: DayRailTodaySlot
    let title: String
    let subtitle: String?
    let duration: DayRailDuration?
    let connectedAmbition: DayRailConnectedAmbition?
    let nodeKind: DayRailNodeKind
    let iconSystemName: String
    let isTappable: Bool
    let explanation: DayRailRecommendationExplanation?
}

enum DayRailTodaySlot: String, CaseIterable, Equatable {
    case now
    case next
    case later
    case notNow
    case protected
    case waiting
    case blocked
}
```

Labels:

```text
Now
Next
Later
Not now
Protected
Waiting
Blocked
```

### 10.11 Node kind

```swift
enum DayRailNodeKind: String, CaseIterable, Equatable {
    case recommended
    case active
    case upcoming
    case flexible
    case closure
    case proof
    case protected
    case waiting
    case blocked
    case empty
}
```

Visual mapping:

```text
recommended → filled glowing circle
active → filled circle
upcoming → hollow circle
flexible → small hollow circle
closure → diamond
proof → receipt/document marker
protected → muted hollow node
waiting → muted clock node
blocked → muted diamond or pause node
empty → faint node
```

### 10.12 Closure prompt

```swift
struct DayRailClosurePrompt: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let plannedContext: String?
    let iconSystemName: String
    let suggestedActions: [DayRailClosureAction]
}

enum DayRailClosureAction: String, CaseIterable, Identifiable, Equatable {
    case completed
    case stillCounts
    case move
    case skippedNotNeeded
    case blocked
    case waiting
    case needsRecovery
    case needsReview
    case reviewLater

    var id: String { rawValue }
}
```

Labels:

```text
Completed
Still counts
Move
Skip
Blocked
Waiting
Needs recovery
Needs review
Review later
```

Do not show all closure actions at once. Show the top 3–4 likely actions.

### 10.13 Proof summary

```swift
struct DayRailProofSummary: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let countedItems: [DayRailProofItem]
    let systemChanges: [DayRailSystemChange]
    let noSilentChanges: Bool
}

struct DayRailProofItem: Identifiable, Equatable {
    let id: String
    let title: String
    let kind: DayRailProofKind
    let connectedAmbition: DayRailConnectedAmbition?
}

enum DayRailProofKind: String, Equatable {
    case completed
    case stillCounts
    case moved
    case skipped
    case blocked
    case waiting
    case note
}

struct DayRailSystemChange: Identifiable, Equatable {
    let id: String
    let title: String
    let approvedByUser: Bool
    let undoAvailable: Bool
}
```

Proof must show `No silent changes` when true.

---

## 11. Actions and Navigation

Create `AmbitionsDayRailActions.swift`.

```swift
struct AmbitionsDayRailActions {
    var startRecommendedStep: (DayRailRecommendedStep) -> Void
    var openRecommendedStep: (DayRailRecommendedStep) -> Void
    var adjustPlan: (DayRailRecommendedStep?) -> Void
    var explainRecommendation: (DayRailRecommendationExplanation) -> Void
    var openTodayRow: (DayRailTodayRow) -> Void
    var openGoal: (DayRailConnectedAmbition) -> Void
    var closeLoop: (DayRailClosurePrompt, DayRailClosureAction) -> Void
    var openClosurePrompt: (DayRailClosurePrompt) -> Void
    var openProofSummary: (DayRailProofSummary) -> Void
    var chooseAnotherStep: () -> Void
    var makeStepSmaller: (DayRailRecommendedStep) -> Void
    var reviewLater: () -> Void
}

extension AmbitionsDayRailActions {
    static let preview = AmbitionsDayRailActions(
        startRecommendedStep: { _ in },
        openRecommendedStep: { _ in },
        adjustPlan: { _ in },
        explainRecommendation: { _ in },
        openTodayRow: { _ in },
        openGoal: { _ in },
        closeLoop: { _, _ in },
        openClosurePrompt: { _ in },
        openProofSummary: { _ in },
        chooseAnotherStep: {},
        makeStepSmaller: { _ in },
        reviewLater: {}
    )
}
```

Tap behavior:

| Tap target | Opens |
|---|---|
| Recommended step card | Step Detail |
| Start now | Step Session |
| Adjust plan | Adjustment sheet or Plan route |
| Why this? | Explanation sheet |
| Goal / ambition label | Goal Detail |
| Today row | Step Detail or context explanation |
| Closure row | Closure sheet |
| Still counts / Move / Skip | Closure action |
| Proof saved card | Receipt peek |

Important: tapping the step card must not immediately start the session. Only `Start now` starts the session.

---

## 12. ViewModel / Projection Requirements

Create `AmbitionsDayRailViewModel.swift` or integrate with existing Today view model if that is cleaner.

Responsibilities:

```text
- Convert Today/Plan/Goal/Capture/Receipt state into AmbitionsDayRailViewState.
- Enforce visible item limits.
- Choose adaptive day tone.
- Choose recommended step.
- Choose closure prompts.
- Choose proof summary.
- Format labels safely.
- Prevent forbidden language.
```

Suggested shape:

```swift
@MainActor
final class AmbitionsDayRailViewModel: ObservableObject {
    @Published private(set) var state: AmbitionsDayRailViewState

    init(state: AmbitionsDayRailViewState) {
        self.state = state
    }

    func update(with state: AmbitionsDayRailViewState) {
        self.state = state
    }
}
```

If the repo uses `@Observable`, follow repo convention.

### 12.1 Item limits

Maximum visible items:

```text
1 Start here card
1 Now row
1 Next row
1 Later row
1 Closure prompt
1 Proof summary
```

More items should route to Plan or Full Day, not clutter Today.

### 12.2 Day tone inference

Implement deterministic logic in a pure function where possible:

```swift
static func inferDayTone(
    openMinutesRemaining: Int,
    requiredMinutesRemaining: Int,
    isAway: Bool,
    isProtectedDay: Bool,
    hasUnclosedLoops: Bool,
    userSelectedMode: DayRailDayTone?
) -> DayRailDayTone
```

Rules:

```text
Away overrides all.
Protected day overrides normal planning.
If requiredMinutesRemaining > openMinutesRemaining by meaningful margin → overloaded.
If user selected recovery → recovery.
If low-energy mode → lowEnergy.
If no schedule → noSchedule.
If no recommended step and no rows → empty.
If near day end and open loops exist → endOfDay.
Otherwise normal or tightButWorkable.
```

---

## 13. Component Breakdown

### 13.1 `DayRailContextHeader`

Displays:

```text
Thursday
Workday · first open window at 5:25 · Tight but workable
[Career Growth] [Build leverage daily]
```

Requirements:

- Compact contextual header
- Not a large repeated tab title block
- Dynamic Type safe
- Max two chips visible

### 13.2 `DayRailSectionHeader`

Displays:

```text
START HERE
TODAY
CLOSE THE LOOP
PROOF SAVED
```

Use small uppercase, warm gold, restrained tracking.

### 13.3 `DayRailNodeView`

Renders one rail node.

Required node styles:

- filled glowing circle
- hollow circle
- diamond
- proof marker
- muted/protected
- waiting
- blocked

State must not be communicated by color alone.

### 13.4 `DayRailNodeColumn`

Renders the vertical rail line and aligned nodes.

The rail should feel structural, not decorative.

### 13.5 `DayRailHeroStepCard`

Includes:

- Icon
- Title
- Duration label
- Connected ambition
- Why summary
- Primary CTA: `Start now`
- Secondary CTA: `Adjust plan`
- Optional tertiary CTA: `Why this?`

### 13.6 `DayRailTodayStackCard`

Grouped card containing Today rows:

- Now
- Next
- Later

Rows should be grouped, not scattered as separate cards.

### 13.7 `DayRailTodayRowView`

Each row includes:

- Icon
- Slot label
- Title
- Subtitle/metadata
- Optional ambition/duration

### 13.8 `DayRailCloseLoopCard`

Default flagship content:

```text
Gym from yesterday
[Still counts] [Move] [Skip]
```

No shame language.

### 13.9 `DayRailProofSavedCard`

Default flagship content:

```text
2 things counted today
No silent changes
```

Tapping opens receipt peek.

### 13.10 `DayRailActionButton`

Reusable styles:

```swift
enum DayRailActionButtonStyle {
    case primary
    case secondary
    case outline
    case subtle
}
```

Primary: warm gold.  
Secondary: dark material.  
Outline: gold stroke.  
Subtle: text/material only.

---

## 14. Adaptive States

Implement fixtures and UI support for each state.

### 14.1 Normal day

```text
Start here
Today
Close the loop if needed
Proof saved
```

### 14.2 Active session

```text
In progress
● Draft PM transition notes
│ 12 min elapsed · 13 min planned
│ [Continue] [Pause] [Close]
```

If Step Session is not ready, provide compile-safe placeholder routing.

Do not use `Start Focus`.

### 14.3 Recovery day

```text
Today changed. Nothing is broken.

Close the loop
◇ Gym from yesterday
│ [Still counts] [Move] [Skip]

Start here
● Pick one small reset step
│ 10 min · Recovery-sized
│ [Start now]
```

### 14.4 Overloaded day

```text
Your plan is too full for the time left.

Start here
● Choose one step to protect the day
│ 12 min · Highest leverage
│ [Start now] [Reflow lightly]
```

### 14.5 Low-energy day

```text
Start here
● Clear one small blocker
│ 8 min · Low-energy fit
│ [Start now] [Make today lighter]
```

### 14.6 Away / vacation day

```text
Away today

Protected
Ambitions is quiet unless you choose otherwise.

Optional
Capture anything
Review after trip
```

Vacation/away is not free time unless explicitly marked available.

### 14.7 Empty day

```text
Nothing needs you right now.
Capture something, choose from a goal, or leave today open.
```

### 14.8 No schedule

```text
Ambitions can make better recommendations with your usual availability.
[Set schedule]
```

Do not block the app.

### 14.9 End of day

```text
Wrap today?

1 loop needs closure
3 things counted
Tomorrow has 2 planned steps

[Close loop] [Review tomorrow]
```

---

## 15. Sheets and Drill-Downs

### 15.1 Why This sheet

File: `DayRailExplanationSheet.swift`

Content pattern:

```text
Why this step?

Recommended because:
• You have a 42-minute open window.
• This step is estimated at 25 minutes.
• It moves Career Growth forward.
• It has been waiting 3 days.
• It does not require deep focus.

Not chosen:
• Music session — better later tonight.
• Budget review — needs more time.
```

Do not say:

```text
AI thinks
AI confidence
The algorithm decided
```

Preferred:

```text
Recommended because
Based on
Not chosen
You can change this
```

### 15.2 Adjustment sheet

File: `DayRailAdjustmentSheet.swift`

Actions:

```text
Choose another step
Make smaller
Move this
Reflow lightly
Review later
```

Keep short and calm.

### 15.3 Closure sheet

File: `DayRailClosureSheet.swift`

Options:

```text
Completed
Still counts
Move
Skip / Not needed
Blocked
Waiting
Needs recovery
Needs review
Review later
```

Definition for Still counts:

```text
You made real progress even if the original step changed.
```

### 15.4 Receipt peek sheet

File: `DayRailReceiptPeekSheet.swift`

Content pattern:

```text
Today’s proof

Completed
• Paid Verizon bill

Still counts
• Wrote hook idea for Music

Moved
• Gym moved to Friday
  Reason: low-energy evening

System changes
• Tomorrow adjusted lightly
  Approved by you

No silent changes
```

---

## 16. Step Detail and Step Session Hooks

The Day Rail must prepare for Step Detail and Step Session.

### 16.1 Step Detail

Tap a step card or row:

```text
Open Step Detail
```

Eventual Step Detail content:

```text
Draft PM transition notes
Career Growth

Why this is here:
• Fits current open window
• Moves PM transition goal
• You accepted 25 minutes

Plan:
Start with outline only.

[Start now]
[Make smaller]
[Move]
[Why this?]
```

### 16.2 Step Session

Tap `Start now`:

```text
Open Step Session
```

Step Session should be step-first, not timer-first.

Eventual session content:

```text
Draft PM transition notes

Do this first:
Open your notes and write 3 bullet points.

Optional timer
25 min suggested

[Mark done]
[Pause]
[Close differently]
```

If real Step Session does not exist yet, create a compile-safe placeholder or route to an existing safe placeholder. Do not name anything `Start Focus`.

---

## 17. Copy and Terminology Guardrails

Forbidden visible copy:

```text
Start Focus
Focus Session
Your best next move
Next best move
Best next move
AI confidence
Productivity score
Overdue
Failed
Behind
Missed
Incomplete
Streak
Crush your goals
Hustle
No excuses
```

Preferred copy:

```text
Start here
Recommended step
Start now
Open step
Adjust plan
Why this?
Close the loop
Still counts
Move
Skip
Blocked
Waiting
Needs recovery
Needs review
Review later
Proof saved
What counted
No silent changes
Tight but workable
Protected day
Away today
Make smaller
Protect tomorrow
Reflow lightly
```

Create tests to protect this language in the Day Rail fixtures and visible labels.

---

## 18. Accessibility Requirements

The Day Rail must support:

- VoiceOver
- Dynamic Type
- Reduce Motion
- High contrast
- Touch targets
- Cognitive accessibility

### 18.1 VoiceOver labels

Recommended step card:

```text
Start here. Recommended step. Draft PM transition notes. 25 minutes suggested. Connected to Career Growth. Why this: fits open window and high leverage.
```

Start button:

```text
Start now, Draft PM transition notes
```

Adjust button:

```text
Adjust plan for Draft PM transition notes
```

Close loop card:

```text
Close the loop. Gym from yesterday. Choose Still counts, Move, or Skip.
```

Proof card:

```text
Proof saved. 2 things counted today. No silent changes.
```

### 18.2 Dynamic Type

Requirements:

- No fixed-height cards that clip text
- Buttons can wrap or stack vertically at larger sizes
- Rows can expand to multiple lines
- Rail nodes remain legible even if not pixel-perfect aligned
- Use adaptive layout where needed

### 18.3 Touch targets

Minimum target: 44x44 pt.

Applies to:

- Start now
- Adjust plan
- Why this?
- Still counts
- Move
- Skip
- Proof card
- Goal link

### 18.4 Reduce Motion

If animation exists:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
```

When Reduce Motion is enabled:

- Disable glow pulsing
- Disable node expansion animations
- Use opacity or instant transitions only

### 18.5 Color dependence

Do not communicate state by color alone.

Use:

- Node shape
- Label
- Icon
- Position
- Accessibility text

---

## 19. Motion and Haptics

Motion should be restrained.

Allowed:

- Active node soft glow
- Completed row moves into proof summary
- Closure sheet rises from closure card
- Primary button press has subtle scale

Not allowed:

- Confetti
- Bounce animations
- Streak celebrations
- Loud success animations
- Constant pulsing

Haptics should use existing haptic utilities if present.

If no utility exists and repo style allows UIKit:

```swift
enum DayRailHaptics {
    static func light() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    static func softSuccess() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }
}
```

Use haptics sparingly:

- Start now → light
- Closure selected → soft success
- Proof opened → light
- Reflow applied → light

---

## 20. Preview Fixtures

Create `AmbitionsDayRailPreviewFixtures.swift`.

Required fixtures:

```swift
extension AmbitionsDayRailViewState {
    static let flagshipNormal: AmbitionsDayRailViewState
    static let activeSession: AmbitionsDayRailViewState
    static let recoveryDay: AmbitionsDayRailViewState
    static let overloadedDay: AmbitionsDayRailViewState
    static let lowEnergyDay: AmbitionsDayRailViewState
    static let awayDay: AmbitionsDayRailViewState
    static let emptyDay: AmbitionsDayRailViewState
    static let noSchedule: AmbitionsDayRailViewState
    static let endOfDay: AmbitionsDayRailViewState
}
```

Flagship normal fixture must use this content:

```text
Thursday
Workday · first open window at 5:25 · Tight but workable
Career Growth
Build leverage daily
Draft PM transition notes
25 min suggested · Career Growth
Why this: fits open window + high leverage
Work block · Ambitions quiet until 5:25
Pay Verizon bill
5 min · Due today
Music session
Flexible · optional if energy holds
Gym from yesterday
Still counts
Move
Skip
2 things counted today
No silent changes
Ambitions keeps your plan honest.
```

Required previews:

```swift
#Preview("Day Rail — Flagship Normal") {
    AmbitionsDayRailView(
        state: .flagshipNormal,
        actions: .preview
    )
    .preferredColorScheme(.dark)
}

#Preview("Day Rail — Recovery") { ... }
#Preview("Day Rail — Overloaded") { ... }
#Preview("Day Rail — Away") { ... }
#Preview("Day Rail — Dynamic Type") { ... }
#Preview("Day Rail — Light Mode Check") { ... }
```

Light mode does not need to be final-perfect in the first implementation, but it must not be broken.

---

## 21. Today Screen Layout

Preferred layout:

```swift
ScrollView {
    VStack(spacing: 20) {
        AmbitionsDayRailView(
            state: viewModel.dayRailState,
            actions: dayRailActions
        )

        // Existing secondary panels may remain below,
        // but should not duplicate Start Here / Now / Next / Later.
    }
    .padding(.horizontal, 20)
    .padding(.top, 12)
}
.background(...)
```

If existing Today has a large top header, reduce or remove it if it duplicates the Day Rail context header.

---

## 22. Engineering Guardrails

- Views render state.
- ViewModel/projection prepares state.
- No fake network calls.
- No fake AI calls.
- No persistence migration required for this build.
- No new top-level tabs.
- No starfield on Today.
- No third-party dependencies.
- No hardcoded business logic in view code.
- No hidden automatic reflow without user-visible preview/receipt.

Canonical tabs remain:

```text
Today
Goals
Capture
Plan
You
```

---

## 23. Tests

### 23.1 Model tests

Create `AmbitionsDayRailModelsTests.swift`.

Test:

- Duration labels format correctly
- Day tone labels format correctly
- Closure action labels format correctly
- Step fit labels never use numeric confidence
- Proof summary handles no silent changes
- Density limits apply

### 23.2 View model tests

Create `AmbitionsDayRailViewModelTests.swift`.

Test:

- Away day overrides normal recommendation
- Overloaded day detected when required minutes exceed open minutes
- Empty day appears when no steps/rows/proof/closure exist
- End-of-day state prioritizes closure
- Low-energy state prefers smaller steps
- Max visible items enforced

### 23.3 Copy guard tests

Create `AmbitionsDayRailCopyGuardTests.swift`.

Scan new Day Rail fixture strings for forbidden copy:

```swift
let forbidden = [
    "Start Focus",
    "Focus Session",
    "best next move",
    "AI confidence",
    "Productivity score",
    "Overdue",
    "Failed",
    "Behind",
    "Missed",
    "Incomplete",
    "Streak",
    "No excuses"
]
```

### 23.4 Preview fixture tests

Create `AmbitionsDayRailPreviewFixtureTests.swift`.

Test:

- `flagshipNormal` has `startHere`
- `flagshipNormal` has Now, Next, Later
- `flagshipNormal` has a closure prompt
- `flagshipNormal` has proof summary
- Proof summary `noSilentChanges` is true

### 23.5 UI tests

Create or update `Native/AmbitionsUITests/AmbitionsDayRailUITests.swift`.

Test that Today contains:

```text
Start here
Draft PM transition notes
Start now
Adjust plan
Today
Pay Verizon bill
Close the loop
Still counts
Proof saved
No silent changes
```

Test forbidden copy absent:

```text
Start Focus
Overdue
Productivity score
```

If UI test infrastructure is not stable, add tests in the nearest existing UI smoke style.

---

## 24. Acceptance Criteria

### 24.1 Product acceptance

- Today clearly shows the Ambitions Day Rail.
- The rail is the primary Today component.
- User can identify what to start now.
- User can see why the step is recommended.
- User can see time fit/duration source.
- User can see connected ambition.
- User can adjust the plan.
- User can close a stale loop without shame.
- User can see proof saved.
- User can see `No silent changes`.

### 24.2 Visual acceptance

- The rail feels custom and premium.
- It does not look like a default checklist.
- It does not look like Apple Calendar.
- It does not look like a project-management board.
- It uses a vertical connected rail with distinct node shapes.
- Active node is visually distinct.
- Closure diamond is visible.
- Proof marker is distinct.
- Cards use restrained material styling.
- The screen is dark-mode-first and polished.
- The layout feels native to iPhone.

### 24.3 Content acceptance

Must use:

```text
Start here
Recommended step
Start now
Adjust plan
Why this?
Close the loop
Still counts
Proof saved
No silent changes
```

Must not use forbidden guilt/productivity/fake-AI language.

### 24.4 Technical acceptance

- App builds.
- Tests pass.
- No third-party dependencies added.
- No top-level tabs changed.
- No network calls added.
- No persistence migration required.
- Components are modular.
- Preview fixtures exist.
- Day Rail state is model-driven.
- Views do not own business logic.

### 24.5 Accessibility acceptance

- VoiceOver labels exist.
- Buttons have clear labels.
- Dynamic Type does not clip major content.
- Reduce Motion is respected if animations exist.
- Touch targets are at least 44x44 pt.
- State is not communicated by color alone.

---

## 25. Codex Implementation Sequence

### Step 1 — Inspect current Today architecture

Find:

```text
TodayScreen
TodayViewModel
TodayPanels
Today preview fixtures
Today tests
Theme/design token files
Routing/navigation helpers
Receipt/proof/action closure domain models
```

Do not start coding until the integration point is clear.

### Step 2 — Add models and actions

Create:

```text
AmbitionsDayRailModels.swift
AmbitionsDayRailActions.swift
```

Build.

### Step 3 — Add preview fixtures

Create:

```text
AmbitionsDayRailPreviewFixtures.swift
```

Build.

### Step 4 — Add theme bridge

Create:

```text
AmbitionsDayRailTheme.swift
```

Prefer existing Ambitions design tokens if available.

### Step 5 — Build components

Build in this order:

```text
DayRailActionButton
DayRailChipView
DayRailSectionHeader
DayRailNodeView
DayRailNodeColumn
DayRailHeroStepCard
DayRailTodayRowView
DayRailTodayStackCard
DayRailCloseLoopCard
DayRailProofSavedCard
DayRailContextHeader
```

### Step 6 — Compose main view

Create:

```text
AmbitionsDayRailView.swift
```

Use `flagshipNormal` preview fixture.

### Step 7 — Add sheets

Create:

```text
DayRailExplanationSheet
DayRailAdjustmentSheet
DayRailClosureSheet
DayRailReceiptPeekSheet
```

Use local sheet state if existing routing does not support these yet.

### Step 8 — Integrate into Today

Add `AmbitionsDayRailView` near the top of Today.

Prefer real Today projection if practical. If not, use fixture state temporarily and add:

```swift
// TODO: Replace preview Day Rail fixture with TodayPlan/Goal/Schedule projection once canonical projection service is wired.
```

Do not leave broken interactions.

### Step 9 — Add tests

Add model, view model, copy guard, fixture, accessibility, and UI smoke tests.

### Step 10 — Run validation

Use the repo’s standard validation commands. If no script exists, run an appropriate Xcode build/test for the Ambitions scheme and simulator destination.

Do not claim real-device or App Store readiness unless actually verified.

---

## 26. Final Commit Summary Format

When implementation is complete, Codex should report:

```text
Implemented Ambitions Day Rail as Today’s signature execution spine.

Changed:
- Added Day Rail models, actions, theme, fixtures, and SwiftUI components.
- Added Start Here hero step card, Today stack, Close the Loop card, and Proof Saved card.
- Added Why This, Adjust Plan, Closure, and Receipt Peek sheets.
- Integrated Day Rail into Today.
- Added tests for models, fixtures, copy guard, and UI smoke coverage.
- Preserved canonical tabs and avoided forbidden Today language.

Validation:
- Build: PASS/FAIL
- Tests: PASS/FAIL
- Known limitations:
```

---

## 27. Open Questions

These should be resolved during or immediately after implementation:

1. Should the first implementation use real Today domain state or a deterministic projection fixture while the projection service is built?
2. Does Step Session already exist in code, or should this batch add only a placeholder route?
3. Should `Why this?` open a sheet, push a detail view, or reuse an existing trust explanation pattern?
4. Should `Proof saved` use existing receipt models immediately or a local projection adapter first?
5. Should the rail use existing design tokens or introduce local tokens pending design-system merge?
6. How much of the older Today panels should remain below the Day Rail after initial integration?

---

## 28. Non-Negotiable Final Rule

The Ambitions Day Rail should not show the user’s day.

It should show the user’s believable path through the day.

That is the product.
