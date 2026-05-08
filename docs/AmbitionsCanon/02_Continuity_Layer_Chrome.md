# 02 — Continuity Layer / Chrome

Status: locked continuity and chrome canon, docs-only.

Purpose:

- Context Crown
- Meridian Edge
- Continuity Dock
- Trust Seam
- Quiet Reflow
- Receipt Surface
- Object-Origin Transitions
- Ambient State Tint
- Cross-Object Threads
- signal routing law

This document does not implement app behavior.

---

## 1. Source-Truth Priority

1. Ambitions Design System
2. Canon Index / 10-10 Maturity Gate
3. Product Canon
4. Continuity Layer & Chrome
5. Signature Object Specs
6. Trust / Privacy / Automation
7. Accessibility / Motion / Performance
8. QA / Preview / Visual Drift
9. Native Shell / Tokens / Materials
10. Implementation / Codex / Repo Integration
11. Visual references
12. Existing repo convenience

---

## 2. Continuity Layer Thesis

The Ambitions Continuity Layer makes Today, Goals, Capture, Plan, and You feel like one native, evolving life operating system.

It connects:

- current time
- selected tab
- active object
- recommended step
- goal thread
- schedule reality
- pressure
- protected time
- receipts
- trust
- recovery
- user preferences

Desired reaction:

```text
This feels like iOS, but iOS for my life direction.
```

The Continuity Layer is not generic chrome, a toolbar, widget layer, AI assistant, dashboard, notification system, status feed, or decorative overlay.

---

## 3. Locked Continuity Components

The Continuity Layer consists of:

1. Context Crown
2. Meridian Edge
3. Living Continuity Dock
4. Trust Seam
5. Object-Origin Transitions
6. Quiet Reflow
7. Ambient State Tint
8. Receipt-First Automation
9. Cross-Object Threads

These are Ambitions-native systems, not optional styling ideas.

---

## 4. Signal Routing Law

Continuity signals may appear only in:

1. Context Crown
2. Meridian Edge
3. Continuity Dock
4. Trust Seam

Hard Red if continuity signals appear as:

- random badges
- banners
- alerts
- assistant bubbles
- floating chips
- notification counts
- status feeds
- dashboard widgets
- generic inline badges outside approved surfaces
- AI assistant chrome

This rule prevents Ambitions from becoming a notification center, dashboard, or chatbot interface.

---

## 5. Continuity Context Model

ContinuityContext represents the current relationship between user, time, active tab, active object, recommendations, trust, receipts, and recovery.

Conceptual Swift direction:

```swift
struct ContinuityContext {
    var activeTab: AmbitionsTab
    var activeObject: SignatureObjectID
    var timeContext: TimeContext
    var activeStep: StepReference?
    var activeGoalThread: GoalThreadReference?
    var capacityContext: CapacityContext?
    var pressureState: PressureState?
    var protectedState: ProtectedState?
    var captureState: CaptureState?
    var trustState: TrustState
    var receiptState: ReceiptState?
    var reflowState: ReflowState?
}

enum AmbitionsTab {
    case today
    case goals
    case capture
    case plan
    case you
}
```

No implementation starts from this type direction without repo audit and file-boundary approval.

---

## 6. Continuity Signal Model

Approved signal kinds:

- activeNow
- recommendedStep
- pressure
- protectedTime
- receipt
- needsReview
- needsRecovery
- waiting
- blocked
- captureUnplaced
- automationChanged
- goalThreadConnected
- planAdjusted
- sourceConflict

No feature may invent a new continuity signal without updating this canon.

Priority ladder:

| Priority | Signals | Behavior |
| --- | --- | --- |
| P0 | sourceConflict, automationChanged, needsRecovery | Trust Seam + Context Crown |
| P1 | activeNow, recommendedStep | Primary object + Context Crown + optional Dock marker |
| P2 | pressure, protectedTime, planAdjusted | Primary object + Trust Seam + optional Meridian Edge |
| P3 | captureUnplaced, goalThreadConnected | relevant object + optional Dock marker |
| P4 | ambient selected state | trace / edge only |

Priority rules:

1. Trust and recovery beat ambient continuity.
2. Live execution beats passive goal-thread state.
3. Capture composition suppresses nonessential signals.
4. Receipts suppress duplicate confirmation banners.
5. Dock markers appear only when useful and inspectable.

---

## 7. Max Signal Budget

| Surface | Budget |
| --- | --- |
| Context Crown | 1 primary + 1 secondary phrase |
| Meridian Edge | 1 visual state expression |
| Continuity Dock | 1 marker per tab max |
| Trust Seam | 1 open explanation max |
| Primary object | object-owned states only |

Ambitions should feel aware, not noisy.

---

## 8. Suppression Rules

1. P0 trust/recovery suppresses ambient signals.
2. Active execution suppresses noncritical goal-thread markers.
3. Capture composing suppresses all nonessential continuity signals.
4. Receipt suppresses duplicate confirmation banners.
5. Dock marker appears only when the user can act or inspect.
6. Meridian Edge hides when it has no orientation or state work.
7. Context Crown never becomes a dashboard header.
8. Trust Seam never becomes a chat drawer.
9. Plan pressure does not create red badge anxiety.
10. Goals thread markers do not imply system-ranked life priorities.

---

## 9. Context Crown

Context Crown is Ambitions’ top safe-area-aware orientation layer. It replaces generic title behavior with compact, native-feeling context.

It tells the user where they are, what mode the surface is in, and when a trust/receipt state briefly matters.

It is not a dashboard header, assistant header, metrics strip, notification surface, or decorative chrome.

Modes:

| Mode | Purpose | Example |
| --- | --- | --- |
| Resting | screen identity + calm context | Today · Tuesday |
| Active | current execution or focused object | Now · 30 min open |
| Trust | proof/source/receipt cue | Receipt · Plan adjusted |
| Compressed | scroll/focus preserving orientation | Now |

Per-tab copy examples:

| Tab | Resting | Active | Trust |
| --- | --- | --- | --- |
| Today | Today · Tuesday | Now · 30 min open | Receipt · Still counts |
| Goals | Goals · Life areas | Music · Active thread | Source · Goal thread |
| Capture | Capture | Capturing | Saved · Needs a Place |
| Plan | Plan · This week | Pressure · Friday | Receipt · Plan adjusted |
| You | You | Automation & Trust | Source · Calendar |

Rules:

- one primary phrase
- one secondary phrase max
- no sentence-length headers
- no motivational copy
- no AI-branded context

Hard Red:

- header contains multiple widgets/metrics
- AI assistant identity appears
- recommendation is owned by Crown instead of object
- context copy becomes long or motivational
- Crown hides essential navigation or action

---

## 10. Meridian Edge

Meridian Edge is Ambitions’ subtle edge-based continuity trace. It provides orientation, state continuity, and object relationship without becoming decorative frame art.

It is visible only when it has product work.

Per-tab expression:

| Tab | Expression | Visibility |
| --- | --- | --- |
| Today | aligns with Reality Meridian | strongest when Now/active step matters |
| Goals | faint orbital/constellation edge | selected area/thread state |
| Capture | nearly absent | after capture as route trace only |
| Plan | capacity/pressure edge | pressure/protected/reflow states |
| You | practical trust boundary | rare; trust/settings only |

Visual rules:

- line weight 1–2 pt default
- max line weight 2.5 pt
- glow opacity 8–18% normally, never above 22%
- must not reduce text contrast
- must not compete with primary object
- must fade before it decorates

If Meridian Edge carries meaning, that meaning must also appear in Context Crown, primary object summary, Trust Seam, or accessible state label.

Hard Red:

- always-on decorative border
- neon/HUD effect
- state exists only in edge color/glow
- edge makes shell feel non-native
- Capture edge distracts from composer quietness

---

## 11. Living Continuity Dock

Continuity Dock is Ambitions’ five-tab native navigation system with restrained state awareness. It is the bottom tab bar, not a dashboard, toolbar, status strip, or notification center.

Locked tabs:

1. Today
2. Goals
3. Capture
4. Plan
5. You

Icon concepts:

| Tab | Icon concept |
| --- | --- |
| Today | solar/dayline symbol |
| Goals | constellation cluster |
| Capture | aperture/orbit symbol |
| Plan | orbital LifeShape symbol |
| You | refined person outline |

Hard Red:

- Capture uses plus icon
- Plan uses menu icon
- icons change meaning by state
- badges overpower selected state

Allowed markers:

- Today: active step live
- Goals: goal thread feeding Today
- Capture: unplaced capture
- Plan: pressure needs review
- You: automation setting needs attention

Rules:

- one marker per tab max
- no counts
- no red badges
- no streak dots
- no productivity indicators
- markers appear only when useful and actionable/inspectable

Accessibility examples:

- Today, selected. Active step live.
- Capture. One unplaced capture.
- Plan. Pressure needs review.

---

## 12. Trust Seam

Trust Seam is Ambitions’ proof, source, and explanation surface. It makes recommendations, receipts, automation, calendar influence, protected time, and reflow inspectable without creating chatbot UI or notification behavior.

Placement: narrow Graphite Recess seam connected to the active object or lower content area.

It may not appear as a floating AI bubble, assistant drawer, toast, banner, notification feed, or modal alert by default.

State machine:

| State | Behavior |
| --- | --- |
| Closed | subtle seam or proof mark only |
| Peek | one-line reason or receipt confirmation |
| Open | source, explanation, control, undo/adjust path |
| Route | path to Automation & Trust, Adjust Plan, Receipt History, or source object |

Allowed content:

- Why this?
- Source
- Receipt
- Calendar updated
- Goal thread connected
- Plan adjusted
- Protected block preserved
- Still counts
- Moved
- Automation changed
- Source unavailable
- Needs review

Forbidden:

- AI coach
- AI recommends
- productivity advice
- motivational explanation
- black-box confidence claims
- long assistant prose

Every explanation includes what Ambitions is suggesting or did, why, source category, uncertainty when relevant, user control, and recovery/undo path when state changed.

---

## 13. Quiet Reflow

Quiet Reflow is Ambitions’ respectful adaptation system for reality changes.

It handles mismatch, pressure, incomplete steps, shortened windows, blocked work, waiting states, protected time, and recovery without shame or black-box automation.

Flow:

1. Detect mismatch.
2. Orient user calmly.
3. Offer clear choices.
4. Preview effect.
5. Apply with user consent or approved default.
6. Leave receipt.
7. Learn only within trust settings.

Allowed actions:

- Adjust plan
- Move this
- Still counts
- Protect this block
- Review pressure
- Open step
- Shorten
- Skip / Not Needed
- Waiting
- Blocked
- Needs recovery

Forbidden actions/copy:

- Failed
- Overdue again
- You missed it
- Productivity dropped
- Streak broken
- Optimize automatically

Launch cap: Preview Reflow.

Hard Red:

- silent schedule changes at launch
- shame copy
- no preview for meaningful change
- no receipt after applied change
- automation exceeds user level
- reflow appears as alert storm or notification feed

---

## 14. Receipt Surface

Receipt Surface is Ambitions’ proof system. It confirms meaningful actions, adaptive changes, source connections, and automation outcomes without becoming notifications, achievements, or a status feed.

Receipt types:

| Type | Example |
| --- | --- |
| Plan adjusted | Moved to 2:30 PM. |
| Calendar updated | Calendar updated. |
| Goal thread connected | Connected to Career goal. |
| Capture placed | Placed in Learning. |
| Still counts | Marked Still Counts. |
| Protected preserved | Protected block preserved. |
| Automation changed | Automation set to Preview Reflow. |
| Source unavailable | Calendar source unavailable. |

Lifecycle:

- created
- peeked
- opened
- dismissed
- archived
- reverted
- superseded

Retention:

- object-local: 7 days or until superseded, whichever is calmer
- global archive: You → Automation & Trust until cleared or governed by privacy policy

Forbidden:

- confetti
- streak language
- achievement badges
- red alerts
- notification feed
- AI-generated prose block

---

## 15. Object-Origin Transitions

Object-Origin Transitions preserve physical and conceptual continuity by making details, sheets, seams, and focused states emerge from the object the user touched.

Allowed patterns:

| Source | Destination | Transition |
| --- | --- | --- |
| Reality Meridian node | Step detail / Start Here | rises from active node |
| Start Here | Step detail | object-linked expansion or native push |
| Goal area | Orbital Lens | expands from selected constellation |
| Capture composer | input state | keyboard rises; atmosphere compresses |
| Captured item | route reveal | route trace from capture result |
| LifeShape pressure | pressure detail | sheet from affected field point |
| Trust proof mark | Trust Seam open | seam expands from proof mark |
| You row | setting detail | native push |

Reduced Motion alternatives:

- native push
- native sheet
- fade/opacity state
- static before/after state
- clear title/context continuity

Hard Red:

- modal appears from nowhere for core object detail
- dramatic zoom/sci-fi effect
- hidden gesture required
- Reduced Motion loses relationship meaning
- transition feels like concept animation, not product behavior

---

## 16. Ambient State Tint

Ambient State Tint gives Ambitions subtle state orientation without recoloring the app or creating dashboard color coding.

It may touch only:

- active dock icon
- trace nodes
- selected object point
- small proof marks
- CTA edge
- Context Crown micro-state
- Trust Seam marker

Per-tab tint direction:

| Tab | Tint direction |
| --- | --- |
| Today | dawn blue-white / warm current trace |
| Goals | cool constellation blue |
| Capture | violet-blue open sky |
| Plan | amber-cyan pressure/capacity |
| You | graphite amber / system trust |

Tint is never the only state channel.

Hard Red:

- app becomes brightly color-coded
- pressure becomes red alert system
- user must perceive color to understand state
- tint competes with primary object

---

## 17. Cross-Object Threads

Cross-Object Threads make Ambitions feel like one life operating system instead of five disconnected tabs.

Thread types:

| Thread | Source | Destination |
| --- | --- | --- |
| Capture placement | Atmosphere Composer | Goal / Plan / Today |
| Goal execution | Constellation Atlas / Orbital Lens | Reality Meridian |
| Plan capacity | LifeShape Field | Today / Start Here |
| Protected time | You / Plan | Today / Plan |
| Receipt proof | Any object | Trust Seam / You archive |
| Automation setting | You | recommendations/reflow behavior |
| Recovery | Today / Plan | Quiet Reflow / receipts |

Allowed visual expression:

- Luminous Trace relationship
- Trust Seam source label
- Receipt copy
- Dock marker when actionable
- Context Crown temporary cue
- object-origin transition

Forbidden:

- activity feed
- cross-tab notification inbox
- dashboard overview map
- busy dependency graph
- decorative constellation connection

Relationships must be accessible as text.

---

## 18. Per-Tab Continuity Rules

### Today

Context Crown shifts from Today to Now when active state matters. Meridian Edge is strongest here. Start Here emerges from the active Meridian node. Trust Seam shows Why this? and receipts. Quiet Reflow handles missed, moved, blocked, shortened, or recovered steps.

Hard Red: Today becomes list/timeline or chrome dominates Reality Meridian.

### Goals

Context Crown shows Goals, Life areas, or selected area. Meridian Edge becomes faint orbital edge. Orbital Lens expands from selected constellation. Trust Seam connects recommended step to source goal. Dock may mark a goal thread feeding Today.

Hard Red: system-ranked life areas or KPI/habit dashboard.

### Capture

Context Crown remains minimal. Meridian Edge is nearly invisible. Composer is primary. Route trace appears after capture. Trust Seam appears only after classification or automation.

Hard Red: Capture becomes feed/inbox/chat/category board or continuity noise interrupts thought.

### Time

Context Crown shows horizon and key state. Meridian Edge becomes capacity trace. LifeShape Field drives behavior. Pressure opens from field. Protected time is respected structure. Trust Seam explains pressure/protection/source.

Hard Red: Time becomes calendar grid, agenda, or analytics dashboard.

### You

Context Crown is quiet or page identity only. Standard native push dominates. Trust Seam routes into Automation & Trust. Privacy, automation, defaults, and receipts are inspectable.

Hard Red: You becomes social profile/admin console or trust controls are hidden.

---

## 19. Continuity Layer Hard Reds

Stop and repair if any are true:

1. Continuity signal appears outside Crown, Edge, Dock, Seam.
2. Dock uses red badge/counts.
3. Capture tab icon is plus.
4. Time tab icon is menu.
5. Context Crown becomes dashboard header.
6. Trust Seam becomes chatbot/AI coach.
7. Quiet Reflow silently changes plan at launch.
8. Receipt becomes notification/achievement feed.
9. Meridian Edge becomes decorative border.
10. Ambient Tint carries meaning alone.
11. Cross-Object Threads become activity feed.
12. Object transitions are theatrical rather than clarifying.
13. Reduced Motion removes relationship/state meaning.
14. VoiceOver user cannot understand continuity state.
