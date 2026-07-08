# Ambitions Flagship Visual Fidelity Contract

Status: Active remediation contract
Scope: Ambitions Frontend Flagship Shippability Remediation
Installed: 2026-07-08

This contract is process authority for visual remediation packets. It is not owner visual acceptance, Visual Green, Accessibility Green, Release Green, or shippability proof.

## 1. Purpose

This contract exists because passing tests is not product quality.

Passing tests is not product quality.
Passing source gates is not product quality.
Passing accessibility identifiers is not product quality.
Passing screenshot capture is not product quality.
A screenshot artifact proves the screen rendered; it does not prove the screen is good.

Ambitions may not ship or advance through visual/surface maturity as technically valid, test-passing, visually mediocre SwiftUI.

## 2. Product-quality target

Ambitions must feel like a premium native iPhone-first Personal Life OS.

It must feel:

- native
- calm
- intentional
- inspectable
- local-first
- private
- deep
- tactile
- premium
- durable
- flagship

It must not feel like:

- MVP
- dashboard
- generic productivity app
- task manager
- habit tracker
- chatbot
- AI wrapper
- web app
- template app
- proof harness
- internal tool
- SwiftUI demo
- normal Codex-generated UI

## 3. North Star visual principles

Ambitions must use:

- native SwiftUI quality
- intentional shell geometry
- visually calm first viewport
- strong object identity
- restrained liquid/material treatment
- typography with hierarchy and breath
- meaningful spacing
- responsive Dynamic Type behavior
- clean light/dark/system appearance
- object-driven depth
- local-first trust cues
- humane receipts
- contextual inspection surfaces

Ambitions must avoid:

- generic card walls
- nested rounded rectangles
- excessive borders
- fake glass everywhere
- noisy panels
- dashboard/control-center layouts
- debug/proof/test copy
- source architecture copy
- dead or disabled primary controls
- visual states that tests can distinguish but humans cannot
- shallow detail pages
- placeholder drilldowns
- module-menu sprawl
- root-surface proliferation

## 4. Deep, not wide law

The app must remain simple at rest and deep on inspection.

Persistent roots:

- Today
- Goals
- Time
- You

Global layers:

- Capture
- Search

Behavior/inspection layers:

- Motion
- Proof
- Source
- Privacy
- History
- Receipts

None of Capture, Search, Motion, Proof, Source, Privacy, History, or Receipts may become root destinations.

Depth must come from:

- object identity
- context
- fit/reason
- action
- proof
- receipt
- history
- control
- privacy boundary

The product target is:

"There are only a few places. But every place knows a lot."

## 5. Surface visual targets

### Today

Today must feel like a living execution window.

Target:

- one clear Start Here object
- one step that fits now when available
- time window
- protected boundary
- reason / fit explanation
- proof when done
- calm but not empty
- useful no-step/recovery state
- no generic task list
- no passive dashboard
- no decorative-only timeline

Failure conditions:

- no primary object
- static empty state with little value
- vague motivational copy
- generic cards
- disabled primary action without useful alternative
- timeline/Meridian that is decorative only

### Goals

Goals must feel like a living Life Area Atlas.

Target:

- active life areas
- clear selected state
- visible movement
- proof availability
- recovery/accomplishment state
- relationship to Today
- relationship to Time
- elegant map/atlas quality
- object depth beneath each area/goal

Failure conditions:

- default/selected/proof states look identical
- repeated fixture-like "Quiet" / "Add goal"
- decorative diagram with no operational depth
- generic goal list
- KPI card wall
- static constellation poster

### Time

Time must feel like a premium Life Calendar.

Target:

- obvious day/week structure
- protected windows
- open capacity
- fixed points
- realistic placement
- conflict/reflow suggestions
- receipts that explain changes
- clear time hierarchy
- Apple Calendar-level readability with Ambitions-specific intelligence
- not a gauge dashboard
- not a productivity score panel

Failure conditions:

- gauge-first UI
- score-like UI
- inaccessible timeline
- unclear placement review
- receipts cover controls
- disabled main action with no useful alternative
- dark-only appearance
- unreadable light mode
- visual density that collapses at large Dynamic Type

### Capture

Capture must feel like a private native composer.

Target:

- full-screen or clearly premium composer treatment
- typed capture routes
- free capture
- goal seed
- step seed
- proof
- protected time
- note/thought
- constraints/fixed points
- attachments
- local save/status
- clear destination
- receipt after save
- no chatbot feel
- no AI-wrapper cues

Failure conditions:

- AI glyphs
- prompt-box layout
- chatbot copy
- "Resolver"
- "activation"
- "receipt path"
- "local proof" in primary UI
- half-sheet prototype feel where full Stage treatment is required
- unclear destination
- no persistence/receipt proof

### Search

Search must feel like local Find / Act / Inspect.

Target:

- deterministic local object lookup
- exact route landing
- goals/steps/captures/time/receipts/proof/source/settings results
- accessible local search
- no chatbot
- no hosted AI implication
- no demo-only results

Failure conditions:

- shallow search sheet
- automation cannot see visible text
- only demo results
- generic search UI with no local object depth
- cloud/AI implication
- vague route landing

### You

You must feel like native iOS Settings plus personal system profile.

Target:

- local-first status
- account optionality
- export/delete/reset/privacy controls
- source/history/receipt control
- compact native settings density
- no admin-wall feel
- no generic profile page
- no Capture-as-destination confusion

Failure conditions:

- dock overlap
- rows hidden
- admin wall
- unproven privacy controls
- account ambiguity
- generic profile page
- settings dump without hierarchy

## 6. Anti-patterns that force repair

Any of these force Needs Repair even when tests pass:

- technically valid but visually mediocre SwiftUI
- box-in-box card walls
- heavy rounded-rectangle stacks
- excessive borders
- fake glass everywhere
- dashboard panels masquerading as product surfaces
- generic productivity app layout
- chatbot or AI-prompt visual grammar
- source/proof/test harness copy in primary UI
- dead or disabled primary controls
- no obvious primary object
- screenshots that look like fixtures
- visual states tests can distinguish but humans cannot
- cramped Dynamic Type
- clipped text
- dock/content collision
- header/content collision
- receipt/control collision
- dark-only appearance
- shallow drilldowns repeating root content
- empty detail pages
- module-menu sprawl
- root-surface proliferation

## 7. Visual scoring rubric

For every visual repair packet and every surface maturity packet, score inspected screenshots from 1 to 5 across these categories:

1. Native iOS quality
2. Visual hierarchy
3. Surface identity
4. Object depth
5. Material restraint
6. Typography and spacing
7. Interaction clarity
8. Local-first trust clarity
9. Accessibility / Dynamic Type readiness
10. Similarity to Ambitions flagship target

Scoring:

- 5 = flagship / target-quality
- 4 = strong, reviewable Yellow
- 3 = technically acceptable but visually mediocre
- 2 = prototype-grade
- 1 = broken or product-law violating

Rules:

- Any category at 1 = Red or Needs Repair.
- Any category at 2 = Needs Repair unless explicitly outside packet scope and documented as a dependency.
- Average under 4.0 = not Ready For Review for visual/surface maturity packets.
- "Technically acceptable but visually mediocre" is not a pass.
- Simulator proof can only support Yellow maximum, but simulator screenshots must still be visually strong enough to justify continuing.
- Tests do not override the visual score.

## 8. Required visual delta before coding

Before coding any visual repair packet or surface maturity packet, write a Visual Delta in the ledger.

Visual Delta must include:

1. Current screenshot state
2. Target visual state
3. Gap from flagship target
4. Exact visual deltas to close
5. Product-law risks
6. Accessibility risks
7. Files likely responsible
8. Screenshot proof required
9. Self-review criteria
10. Repair-loop conditions

Do not start the packet implementation until this Visual Delta exists.

## 9. Required visual scorecard after coding

After every visual repair packet or surface maturity packet, update the ledger with:

1. Screenshot artifact paths
2. Visual inspection notes
3. Visual scorecard
4. Remaining visual deltas
5. Whether the screenshot moved closer to the flagship target
6. Whether any part still looks like normal Codex SwiftUI
7. Whether additional repair was performed
8. Whether the packet required multiple repair cycles
9. Final packet status

## 10. Repair-loop rule

A packet may pass tests and still fail.

If visual score is below threshold:

- repair implementation
- rerun focused validation
- recapture screenshots
- reinspect
- rescore
- repeat

Do not merely document visual failure as follow-up if it is within source/simulator scope for the current packet.

Do not advance to the next packet while the current packet has repairable visual failure.

Only defer if:

- physical-device proof is required and unavailable
- manual VoiceOver proof is required and unavailable
- a true product decision is required
- the fix belongs to a later packet by dependency and cannot be safely repaired now
- tool/session limits are reached

If deferring, explain why it is not repairable in the current packet. Do not use "later polish" as an excuse.

## 11. Packet closeout rule

A packet may not be Ready For Review from tests alone.

Ready For Review requires:

- source proof
- runtime proof where applicable
- screenshot proof where applicable
- visual inspection
- visual scorecard
- repair loops completed for repairable failures
- honest proof ceilings

Mark Needs Repair if:

- screenshots look mediocre
- visual hierarchy is weak
- surface identity is unclear
- root looks like cards/panels/dashboard
- Dynamic Type is cramped
- light mode is not truly designed
- UI appears technically correct but not premium
- proof exists only as identifiers/tests
- the surface does not materially move toward the flagship target
- current packet failure is repairable and not repaired

## 12. Required closeout sentence

Every visual/surface packet closeout must include:

"Passing tests did not determine this status. The status is based on source proof, runtime proof, screenshot inspection, repair-loop completion, and visual fidelity against the Ambitions flagship target."

## 13. No human review checkpoints during execution

Do not stop for human review during this remediation train.

Human review will happen at the end.

You may mark a packet Ready For Review only after self-scoring, screenshot inspection, and repair-loop completion.

Do not request owner visual acceptance.
Do not request human review mid-program.
Do not mark anything Done.
Do not claim shippable.

## 14. Final owner review remains external

At the end of the program, prepare an owner review package.

That package must include:

- physical-device proof if available
- simulator proof if physical device unavailable
- root screenshots
- core overlay screenshots
- accessibility proof
- known remaining risks
- proof ceilings
- visual scorecards
- before/after comparison

But do not stop for review before then unless a hard stop rule is reached.
