# Ambitions Flagship Visual Fidelity Contract

Status: Active remediation contract  
Scope: Ambitions frontend remediation  
Installed: 2026-07-08  
Owner override: real-device owner review can supersede simulator-Yellow at any time

This contract is process authority for visual remediation packets. It is not owner visual acceptance, Visual Green, Accessibility Green, Release Green, or shippability proof.

The active product target is:

**premium roots, native light/dark drilldowns and entire frontend, deeply inspectable object surfaces, all built with realistic SwiftUI proportions.**

The owner-rejection rebaseline is now part of this contract. If this file conflicts with `OWNER_REJECTION_REBASELINE.md`, the owner-rejection rebaseline controls.

## 1. Purpose

This contract exists because passing tests is not product quality.

Passing tests is not product quality.  
Passing source gates is not product quality.  
Passing accessibility identifiers is not product quality.  
Passing screenshot capture is not product quality.  
A screenshot artifact proves the screen rendered; it does not prove the screen is good.  
A simulator-Yellow result can still be owner-rejected by real-device review.

Ambitions may not ship or advance through visual/surface maturity as technically valid, test-passing, visually mediocre SwiftUI.

## 2. Real-device owner review override

Owner real-device review is authoritative over simulator self-score.

Owner rejection can force Needs Repair or Red even when:

- source gates pass
- tests pass
- screenshot lanes pass
- simulator screenshots are attached
- a prior packet was marked Yellow / Ready For Review

Visual scoring must not become self-protective. Real navigability, object discoverability, and functional user value are part of visual/product fidelity.

If the owner supplies real-device evidence that a surface is ugly, unclear, broken, non-functional, hard to navigate, or unable to reveal created objects, the relevant packet is Needs Repair or Red.

## 3. Product-quality target

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
- useful
- navigable

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
- decorative concept art
- a beautiful but non-functional prototype

The product should feel like:

> “There are only a few places. But every place knows a lot.”

Visually and functionally, the product should feel like:

> “This is a flagship native Apple-adjacent Life OS with obvious navigation, real object creation, inspectable local state, and no fake success.”

## 4. Deep, not wide law

The app remains simple at rest and deep on inspection.

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

Depth comes from:

- object identity
- context
- fit / reason
- action
- proof
- receipt
- history
- control
- privacy boundary
- exact destination after creation
- working route stack

## 5. Root surface premium standard

The root surfaces — Today, Goals, Time, and You — must feel premium, flagship, native, and useful.

Roots must have:

- realistic SwiftUI proportions
- strong visual hierarchy
- native iOS layout credibility
- restrained materials
- clear primary object/action
- refined spacing and typography
- seamless shell/chrome integration
- real navigability
- real functional value
- no dashboard clutter
- no generic productivity-app feel
- no proof-harness energy
- no placeholder composition
- no normal Codex SwiftUI feel

Weak roots are failures, not later polish. If a root looks technically valid but ordinary, generic, dashboard-like, card-heavy, non-actionable, or proportionally implausible, the packet is Needs Repair unless the failure is outside the packet and blocked by a named dependency.

## 6. Full-frontend light/dark standard

The appearance standard applies to the entire frontend, not isolated screens.

Root surfaces, drilldowns, overlays, inspectors, detail pages, Search, Capture, receipts, settings, edit flows, and object detail must be:

- credible native SwiftUI
- proportionally correct
- visually consistent
- intentionally designed in light
- intentionally designed in dark
- correct in system appearance
- readable in real detail routes
- not dark-only
- not light-only
- not generic

Light mode and dark mode are both first-class product modes. Light mode is not a technical variant. Dark mode is not the only designed experience. Drilldowns and sub-surfaces are not utilitarian leftovers under prettier roots.

The owner has already rejected a case where Appearance showed Light selected while detail content remained dark/dim/unreadable. That failure pattern is Red/Needs Repair.

## 7. Drilldown and sub-surface realism standard

Drilldowns, inspectors, and secondary routes must feel like practical, buildable iPhone screens.

They must use:

- believable navigation hierarchy
- working back behavior
- practical row heights
- practical list density
- practical card restraint
- native spacing
- proportionate headers
- legible control placement
- meaningful object context
- useful action/control paths
- exact object/destination after mutation or creation

They must not use:

- fantasy panels
- impossible geometry
- giant concept-board blocks
- fake design-shot distortions
- empty detail pages
- drilldowns that only repeat parent content
- ugly utilitarian subviews hidden below polished roots
- broken back arrows
- created objects that disappear

Visually weak or non-navigable drilldowns are failures, not later polish.

## 8. Surface visual targets

### Today

Today must feel like an actionable, rotary execution window.

Target:

- current time window
- previous and next time windows
- forward/backward temporal scrolling
- one clear Start Here object when a real step fits
- useful no-step state
- primary action even when no step is required
- Capture / Build Today / Add Step / Review Time / Protect Time paths as appropriate
- time window
- protected boundary
- reason / fit explanation
- proof/receipt after action
- no generic task list
- no passive dashboard
- no decorative-only timeline

Failure conditions:

- no primary action in no-step state
- static empty state with little value
- vague motivational copy
- generic cards
- disabled primary action without useful alternative
- timeline/Meridian that is decorative only
- inability to move backward/forward through time windows where the packet owns Today navigation

### Goals

Goals must move to a native hierarchy direction. The previous constellation / Life Area Atlas visual grammar is retired.

Target:

- Apple Reminders-style native hierarchy without cloning Reminders one-to-one
- life areas as groups, folders, or sections
- goals as visible rows
- active paths as rows/details
- clear add/edit flow
- created goals immediately visible
- goal detail drilldowns
- clear selected/proof/recovery state through native rows/sections/details
- practical row heights
- clear back navigation
- no dashboard wall
- no proof/root clutter

Failure conditions:

- radial constellation
- abstract orbit nodes
- decorative atlas map
- “Create your first goal” trapped inside a diagram
- tiny proof/status marks as primary state language
- created goal cannot be found in Goals
- goal detail repeats root without useful object depth
- generic KPI wall
- project-management clone

### Time

Time must feel Calendar-grade.

Target:

- day/week scroll
- now line
- time blocks/windows
- protected time
- open time
- fixed points
- scheduled Step blocks
- conflict/reflow review
- placement proposal
- clear temporal navigation
- local/private source boundary
- receipts that explain changes
- Apple Calendar-level readability with Ambitions-specific intelligence

Failure conditions:

- segmented control panel as primary grammar
- dashboard card
- abstract gauge/control panel
- score-like UI
- inaccessible timeline
- unclear placement review
- receipts cover controls
- disabled main action with no useful alternative
- dark-only appearance
- unreadable light mode
- static list of system facts
- visual density that collapses at large Dynamic Type

### Capture

Capture must be first-class, full-screen, and global without becoming a root tab.

Target:

- full-screen creation surface respecting safe area
- globally reachable
- not a dock/root destination
- route affordances visible
- free capture
- goal seed
- step seed
- proof
- protected time
- note/thought
- constraint/fixed point
- attachment if supported
- review before save
- destination before save
- exact destination after save
- open destination from receipt
- cancel/back/close works
- local save/status
- no chatbot feel
- no AI-wrapper cues

Failure conditions:

- sparse dead surface
- modal prompt-box feel
- AI glyphs
- chatbot copy
- “Resolver”
- “activation”
- “receipt path”
- “local proof” in primary UI
- unclear destination
- fake persistence
- created object cannot be found
- no receipt/destination proof
- Capture as dock/root tab

### Search

Search must feel like local Find / Act / Inspect.

Target:

- deterministic local object lookup
- exact route landing
- goals/steps/captures/time/receipts/proof/source/settings results
- accessible local search
- created object discoverability where indexing exists
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
- created objects not discoverable when Search claims to cover them

### You

You should remain closest to native Settings, but must become runtime-connected and cleaner.

Target:

- local-first status
- account optionality
- export/delete/reset/privacy controls
- source/history/receipt control
- compact native settings density
- secondary details as subtitles or detail content, not noisy right-side values
- runtime-connected settings where supported
- honest unavailable states where not supported
- no admin-wall feel
- no generic profile page
- no Capture-as-destination confusion

Failure conditions:

- trailing value words beside chevrons
- noisy right-side labels like “On device,” “No account,” “Light,” “Ready,” “Goals,” or “Time”
- settings that appear connected but do nothing
- unreadable Appearance detail route
- dock overlap
- rows hidden
- admin wall
- unproven privacy controls
- account ambiguity
- generic profile page
- settings dump without hierarchy

## 9. Shell / chrome clarity standard

Ambitions shell should be:

**Facebook-clear, Apple-native, Ambitions-private.**

Do not copy Facebook’s product, feed, social graph, content model, notification model, stories model, branding, engagement loops, or visual identity.

Extract only shell/chrome principles:

- clear top command header
- obvious search/create/global action controls
- working back on drilldowns
- visible surface identity
- visible mode/context
- large touch targets
- rounded anchored bottom dock
- four persistent roots only: Today / Goals / Time / You
- strong selected dock state
- content never hidden behind dock
- content-first scrolling
- detail routes as full native navigable surfaces
- no decorative-only icons
- no inert controls

Failure conditions:

- broken back behavior
- decorative dock
- ambiguous icons
- hidden global Capture/Search affordances
- content trapped under chrome
- dock/content collision
- header/content collision
- Capture becomes a fifth tab

## 10. Anti-patterns that force repair

Any of these force Needs Repair even when tests pass:

- broken navigation
- created object cannot be found
- no actionable value on a root
- roots that are not premium, flagship, or native-feeling
- drilldowns that look utilitarian under polished roots
- light mode that reads like an unfinished technical variant
- dark mode that carries all product design while light mode lags
- system appearance that is not deterministic or visually coherent
- unrealistic SwiftUI proportions
- fantasy panels or concept-art geometry
- pretty screenshots with impossible app layout
- isolated packet wins that do not converge into one cohesive product
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

## 11. Visual scoring rubric

For every visual repair packet and every surface maturity packet, score inspected screenshots from 1 to 5 across these categories:

1. Native iOS quality
2. Visual hierarchy
3. Surface identity
4. Object inspectability
5. Light/dark quality
6. Material restraint
7. Typography and spacing
8. Interaction clarity
9. SwiftUI realism / proportions
10. Similarity to Ambitions premium frontend target

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
- “Technically acceptable but visually mediocre” is not a pass.
- “Looks okay for now” is not a pass.
- “Only roots look premium” is not a pass.
- “Only drilldowns look premium” is not a pass.
- The entire affected frontend scope must move meaningfully toward the target.
- Simulator proof can only support Yellow maximum, but simulator screenshots must still be visually strong enough to justify continuing.
- Tests do not override the visual score.
- Owner real-device review can override any score.

## 12. Required Visual Delta before coding

Before coding any visual repair packet or surface maturity packet, write a Visual Delta in the ledger.

Visual Delta must include:

1. Current screenshot state
2. Target visual state
3. Gap from desired premium frontend target
4. Exact visual deltas to close
5. Exact inspectability deltas to close
6. Exact realism/proportion deltas to close
7. Product-law risks
8. Accessibility risks
9. Files likely responsible
10. Screenshot proof required
11. Self-review criteria
12. Repair-loop conditions

Do not start the packet implementation until this Visual Delta exists.

## 13. Required Visual Scorecard after coding

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
10. Root quality evaluation
11. Drilldown/sub-surface quality evaluation
12. Light/dark quality evaluation
13. Object inspectability evaluation
14. SwiftUI realism/proportion evaluation
15. Navigation/object-discoverability evaluation when the packet touches routes, creation, search, persistence, or settings

## 14. Packet repair-loop enforcement

A packet may pass tests and still fail.

If visual score or functional product reality is below threshold:

- repair implementation
- rerun focused validation
- recapture screenshots
- reinspect
- rescore
- repeat

If root quality, drilldown quality, light/dark quality, object inspectability, navigability, object discoverability, or SwiftUI realism is weak inside the affected packet scope, the packet must loop through repair. Do not advance from an isolated technical win when the affected frontend still fails the premium target.

Do not merely document visual or functional failure as follow-up if it is within source/simulator scope for the current packet.

Only defer if:

- physical-device proof is required and unavailable
- manual VoiceOver proof is required and unavailable
- a true product decision is required
- the fix belongs to a later packet by dependency and cannot be safely repaired now
- tool/session limits are reached

If deferring, explain why it is not repairable in the current packet. Do not use “later polish” as an excuse.

## 15. Packet closeout rule

A packet may not be Ready For Review from tests alone.

Ready For Review requires:

- source proof
- runtime proof where applicable
- screenshot proof where applicable
- visual inspection
- visual scorecard
- repair loops completed for repairable failures
- honest proof ceilings
- root quality evaluation
- drilldown/sub-surface quality evaluation
- light/dark quality evaluation
- object inspectability evaluation
- SwiftUI realism/proportion evaluation
- navigation/object-discoverability evaluation where relevant

Mark Needs Repair if:

- screenshots look mediocre
- visual hierarchy is weak
- surface identity is unclear
- root quality is weak
- drilldown/sub-surface quality is weak inside packet scope
- light/dark quality is weak
- object inspectability is shallow inside packet scope
- SwiftUI proportions feel unrealistic
- root looks like cards/panels/dashboard
- Dynamic Type is cramped
- light mode is not truly designed
- UI appears technically correct but not premium
- proof exists only as identifiers/tests
- created objects cannot be found
- route back behavior fails
- the surface does not materially move toward the flagship target
- current packet failure is repairable and not repaired

## 16. Required closeout sentence

Every visual/surface packet closeout must include:

> Passing tests did not determine this status. The status is based on source proof, runtime proof, screenshot inspection, repair-loop completion, actual navigability, object discoverability where relevant, and fidelity to the Ambitions premium frontend target: premium roots, native light/dark drilldowns and entire frontend, deeply inspectable object surfaces, and realistic SwiftUI proportions.

## 17. Owner review during execution

Do not request owner review as a substitute for packet proof.

However, owner real-device review may occur at any time and may override simulator-Yellow, Ready For Review, or self-scored packet status immediately.

If owner real-device evidence contradicts simulator proof, the owner evidence controls.

Do not mark anything Done. Do not claim shippable. Do not claim Visual Green, Accessibility Green, or Release Green without the required proof.

## 18. Final owner review package

At the end of the program, prepare an owner review package.

That package must include:

- physical-device proof if available
- simulator proof if physical device unavailable
- root screenshots
- core overlay screenshots
- drilldown screenshots
- accessibility proof
- known remaining risks
- proof ceilings
- visual scorecards
- navigation/object-discoverability proof
- before/after comparison
