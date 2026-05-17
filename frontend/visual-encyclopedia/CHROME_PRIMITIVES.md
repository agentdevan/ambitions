# Ambitions Chrome Primitives

Status: Active frontend canon overlay
Installed: 2026-05-16
Authority: Subordinate to `docs/truth/*`, `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`, and `frontend/visual-encyclopedia/CHROME_ENRICHMENT_DOCTRINE.md`; authoritative for chrome primitive naming, visual intent, and validation where compatible.
Implementation claim: Docs-only. This file does not prove SwiftUI implementation, simulator/device parity, screenshot parity, accessibility conformance, performance, release readiness, or shipped behavior.

## Purpose

This primitive spec gives Ambitions a named chrome layer that can be audited, designed, implemented, and reviewed consistently across Today, Goals, Capture, Time, and You.

A chrome primitive is a repeatable shell element that preserves orientation, action, proof, trust, or adaptation around the dominant object of a surface. A primitive is not a generic card, not decoration, and not an implementation component by itself unless a source packet later binds it to SwiftUI.

## Primitive Rules

1. Every primitive must serve object, state, action, proof, or recovery.
2. Every primitive must have an accessibility interpretation.
3. Every primitive must degrade under Reduce Motion without losing meaning.
4. Every primitive must avoid generic dashboard/card-stack behavior.
5. Every primitive must preserve the active IA: `Today / Goals / Capture / Time / You`.
6. Every primitive that implies local intelligence must expose proof, receipt, source basis, or an explicit no-receipt reason.
7. No primitive may use glow, color, motion, or iconography as the only state carrier.

## Required Primitive Inventory

| Primitive | Scope | Primary Job |
| --- | --- | --- |
| `ContextTopEdge` | global | Compact current context without thick headers. |
| `DestinationTabBar` | global | Preserve top-level IA and bottom reach. |
| `RealityMeridianRail` | Today / Time | Make time reality the primary object. |
| `CurrentTimeGlow` | Today / Time | Show exact current time as a live but truthful marker. |
| `StartHereSurface` | Today | Present the recommended step as the flagship daily decision object. |
| `ReceiptHandle` | cross-surface | Provide collapsed proof/reasoning access. |
| `ReceiptDrawer` | cross-surface | Expand local reasoning, proof, and source basis. |
| `ContinuityStrip` | global/contextual | Persist active execution or adaptation state across surfaces. |
| `StepDetailSheet` | Today / Goals / Time | Inspect a step before execution. |
| `ClosureSheet` | Today / cross-surface | Resolve an unclosed prior step without shame. |
| `RecoverySheet` | Today / Time | Repair broken plan state. |
| `AdjustPlanSheet` | Today / Time | Preview and accept or reject reflow. |
| `ScheduleConflictSheet` | Time / Today | Explain fit conflicts and available alternatives. |
| `ProofSheet` | Goals / Today / cross-surface | Inspect proof attachments and evidence. |
| `AtmosphereComposer` | Capture | Accept intent quickly and route it. |
| `LifeShapeScopeChip` | Time | Switch Day / Week / Month without calendar-clone drift. |
| `TrustProfilePanel` | You | Expose local trust, defaults, automation, and receipts. |
| `SourceQualityLine` | cross-surface | Explain source freshness, confidence basis, or missing source. |
| `LocalProofChip` | cross-surface | Mark local-only proof or local runtime basis. |
| `ObjectThreadRail` | Goals / Today | Show relationship from intent to plan to step to proof. |

---

# Primitive Specifications

## `ContextTopEdge`

### Role
Compact top-of-screen orientation that replaces thick static page headers.

### Visual intent
A safe-area-aware edge line or compact cluster that carries current context, local state, and origin. It should feel like operational state, not a title banner.

### Allowed content
- local status
- current date or time context
- destination/object label when needed
- free/protected/work/school/away context
- capacity or pressure summary
- origin/back affordance in drill-downs
- compact `Local · Ambitions` identity where it anchors trust

### Forbidden content
- large marketing title
- generic dashboard greeting
- ungrounded AI slogan
- crowded multi-line header
- user-facing Plan top-level destination language

### Accessibility
VoiceOver order: destination or origin, current context, state, available primary action if the edge owns one.

## `DestinationTabBar`

### Role
Global bottom navigation for the five active destinations.

### Required labels
`Today / Goals / Capture / Time / You`

### Visual intent
Premium, quiet, thumb-owned, safe-area aware. The selected state should be clear but not loud. Capture may receive subtle affordance priority, but it must not become a sixth action or break the IA.

### Forbidden content
- Plan as visible top-level label
- More than five top-level destinations
- AI/chatbot destination
- hamburger/menu replacement for a primary tab
- selected-state ambiguity

### Accessibility
Each tab announces destination and selected state. Capture must not be described as only a plus button.

## `RealityMeridianRail`

### Role
Living temporal spine for Today and Time.

### Visual intent
A scrollable vertical day rail with exact time labels, connected nodes, partial continuation above/below, and current-time truth. It should feel like a premium reality instrument, not a timeline decoration.

### Required visible ingredients
- exact time labels
- scheduled nodes
- current-time marker as a separate object
- closure/recovery/protected/waiting/blocked states
- tappable rows or nodes
- safe continuation cues

### Forbidden content
- generic task list bullets
- equal-weight cards masquerading as timeline rows
- current-time marker snapped incorrectly to a stale scheduled node
- unlabelled glow as the only current-time indicator

### Accessibility
Nodes announce time, state, object title, source/proof availability, and action.

## `CurrentTimeGlow`

### Role
Exact live current-time marker.

### Visual intent
A subtle luminous cursor aligned to the exact current time on the Meridian. It does not move scheduled nodes. It reveals drift honestly.

### Required behavior
- if a step started at 10:00 and current time is 12:15, the 10:00 node remains at 10:00 and the glow sits at 12:15
- exact time label aligns to the glow
- overrun/drift is represented by state labels and attachment lines, not by falsifying time

### Accessibility
Provides a non-color label such as `Current time, 12:15 PM` and any drift state.

## `StartHereSurface`

### Role
Flagship Today decision object.

### Visual intent
A grounded daily command surface physically related to the Reality Meridian. It must never read as a generic AI suggestion card.

### Required visible ingredients
- `Start here` label
- recommended step title
- why-now line
- goal thread
- time-fit/buffer proof
- local receipt cue
- primary CTA: `Start now` or `Open step`
- secondary CTA: `Adjust plan`
- optional `Why this?` disclosure

### Allowed states
- normal
- compact
- explanation-expanded
- recovery-needed
- closure-needed
- no-free-time
- protected block
- away/vacation
- high-pressure
- new-user/empty

### Forbidden content
- `Next best move`
- `Begin Focus`
- `Start Focus`
- motivational pep talk
- ungrounded confidence score
- AI chat invitation as the main CTA

### Accessibility
VoiceOver order: label, step title, why now, time fit, goal thread, receipt availability, primary action, secondary action.

## `ReceiptHandle`

### Role
Collapsed affordance for proof/reasoning.

### Visual intent
Small object-attached handle such as `Why this? · 4 local signals` or `Receipt · local proof`. It must be visible enough to build trust and quiet enough not to compete with the primary action.

### Required behavior
Tapping opens `ReceiptDrawer` or an object-specific receipt sheet.

### Forbidden content
- ornamental icon with no text
- vague `AI says`
- confidence percentage without inspectable basis

## `ReceiptDrawer`

### Role
Expanded proof and reasoning surface.

### Visual intent
A bottom sheet or object-attached reveal that explains why a recommendation, reflow, closure, or proof state exists.

### Required visible ingredients
- reason list
- source-quality line
- local-only/proof basis where applicable
- what changed, if adaptation occurred
- no-receipt reason where receipt is unavailable
- undo or adjust path when state changed

### Example collapsed-to-expanded path
Collapsed: `Why this? · 4 local signals`

Expanded:

- free until 9:30 PM
- step fits 25 min
- goal has been idle 3 days
- two prior admin attempts were moved

### Accessibility
Structured as a sheet with heading, list of reasons, source/proof state, primary close/action control.

## `ContinuityStrip`

### Role
A persistent but conditional strip for active execution, closure, recovery, proof, or reflow state.

### Visual intent
Analogous to a mini-player or trip/order state, but Ambitions-native. It appears only when ongoing state should survive browsing.

### Examples
- `Now · Draft lease checklist · 24 min left · Local`
- `Needs closure · Workout step · 2 options`
- `Plan changed · 18 min recovered · View receipt`

### Forbidden behavior
- always-on clutter
- duplicate of Start Here at rest
- promotional announcement strip
- status with no action or inspection path

### Accessibility
Announces active state, object, time or status, and available action.

## `StepDetailSheet`

### Role
Lightweight inspection before starting or editing a step.

### Required visible ingredients
- step title
- context and time fit
- goal thread
- proof/receipt handle
- Start now or Open step action
- adjust/cancel path

### Forbidden behavior
- becoming a full project screen
- hiding why the step is recommended
- forcing timer-first execution

## `ClosureSheet`

### Role
Resolve an unclosed prior step without shame.

### Required closure states
- Completed
- Still Counts
- Moved
- Skipped / Not Needed
- Blocked
- Waiting
- Needs Recovery
- Needs Review

### Visual intent
Calm, object-attached, reversible where possible. It should never make the user feel punished for reality changing.

### Accessibility
Every closure option has an explicit label and effect summary.

## `RecoverySheet`

### Role
Repair broken plan state.

### Required visible ingredients
- what changed
- why the prior plan no longer fits
- safest recovery option
- user-controlled adjustment path
- receipt expectation

### Forbidden behavior
- silent rearrangement
- shame copy
- forced automation
- gamified penalty

## `AdjustPlanSheet`

### Role
Preview and accept/reject a proposed reflow.

### Required visible ingredients
- before state
- proposed after state
- time recovered or pressure changed
- affected steps
- preserved protected time
- Accept / Keep current / Adjust manually
- receipt after commit

### Accessibility
Before/after must be readable without layout comparison alone.

## `ScheduleConflictSheet`

### Role
Explain why a step does not fit and present alternatives.

### Required visible ingredients
- conflict reason
- hard context involved
- available alternatives
- protected/away distinction where relevant
- user choice path

### Forbidden behavior
- vague `not enough time`
- pretending vacation/away is free time unless explicitly available
- hidden override of protected blocks

## `ProofSheet`

### Role
Inspect proof/evidence attached to a step, goal, closure, or recommendation.

### Required visible ingredients
- proof object title
- source or attachment type
- time captured
- related goal/step
- receipt relationship
- missing-proof explanation if applicable

## `AtmosphereComposer`

### Role
Capture root primitive.

### Visual intent
A restrained dark-sky composer surface with bottom text input, mic inside the field, add button to the right, and minimal first-use routing.

### Required routes
- Needs a Place
- Ready to Place
- Grow into Goal

### Forbidden behavior
- chatbot destination framing
- normal scrolling feed as the root Capture experience
- bloated route picker before the user inputs anything

## `LifeShapeScopeChip`

### Role
Time scope switcher.

### Required labels
- Day
- Week
- Month

### Visual intent
Compact, native, thumb-reachable where possible, and semantically tied to the LifeShape Field.

### Forbidden behavior
- generic calendar clone tab bar
- Month as only a date grid
- scope state visible only by color

## `TrustProfilePanel`

### Role
Top primitive for You.

### Required visible ingredients
- user/system profile identity
- local trust status
- planning setup completeness
- automation level
- receipt/proof access
- grouped navigation below

### Forbidden behavior
- generic settings profile with no local intelligence meaning
- marketing privacy copy without inspectable controls
- burying Planning Setup below unrelated preferences

## `SourceQualityLine`

### Role
Compact explanation of source freshness and basis.

### Allowed states
- fresh
- stale
- unavailable
- local-only
- unresolved
- proof-backed
- user-set
- suggested
- historically grounded

### Accessibility
Announces state in plain language and where to inspect more.

## `LocalProofChip`

### Role
Show that a recommendation, receipt, or adaptation is grounded in local runtime state.

### Visual intent
Small proof chip attached to the object it supports. It should not become a decorative badge.

### Forbidden content
- `AI powered` badge
- cloud model branding
- local claim without inspection path

## `ObjectThreadRail`

### Role
Show continuity from intent to plan to step to proof.

### Required visible ingredients
- parent goal or lane
- current step
- proof or closure relationship
- next link or review action

### Forbidden behavior
- generic breadcrumb trail with no execution meaning
- project-management dependency chart as primary visual identity

## Cross-Primitive Validation Matrix

| Gate | Pass Condition |
| --- | --- |
| Object-first | The primitive supports the dominant object instead of competing with it. |
| State clarity | User can identify current state without color-only or motion-only cues. |
| Action clarity | The primary action is reachable and named in Ambitions language. |
| Proof clarity | Local intelligence has receipt/proof/source access. |
| Native believability | Looks plausible for premium iPhone UI and respects safe areas. |
| Accessibility | VoiceOver, Dynamic Type, Reduce Motion, and tap targets survive. |
| Anti-drift | Does not reintroduce Plan top-level, chatbot-first UI, card-dashboard shell, or generic productivity tropes. |
| Release honesty | Does not claim implementation or screenshot parity without proof artifacts. |

## Required Implementation Path

These primitives are canon names and visual contracts only. Implementation must be authorized by a surface packet or runner-compatible batch prompt, with allowed scope, forbidden scope, validation expectations, visual proof expectations, red stop conditions, rollback expectations, and receipt output.