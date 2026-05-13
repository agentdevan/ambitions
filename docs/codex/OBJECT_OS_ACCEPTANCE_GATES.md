# Object OS Acceptance Gates

Status: Active supporting canon
Parent: docs/codex/AMBITIONS_OBJECT_OS_CANON.md
Runtime impact in this batch: None

## Purpose

These gates prevent future Object OS implementation from becoming a generic productivity app with new names. Future MRI25-MRI34, FCP, PFC, visual/runtime, and native-surface work should pass these gates before claiming Object OS or visual runtime completion.

## Gate 1 — Object Dominance Gate

Every top-level surface must have a dominant object:

- Today: Start Here / Active Commitment / Reality State
- Goals: Ambition Graph / Orbital Lens
- Capture: Captured Input / Meaning Route
- Time: LifeShape / Reality State
- You: Personal Runtime / Learning Signal / Trust Control

Failure examples:

- surface is a dashboard stack
- surface is a list of generic tasks
- surface is a calendar clone
- surface is a feed
- surface has no primary object

## Gate 2 — Receipt Path Gate

Every meaningful action must either create or reference a receipt.

Meaningful actions include:

- start step
- close step
- mark Still Counts
- move commitment
- block/wait commitment
- reflow time
- add proof
- transfer proof
- delete/archive object
- correct recommendation
- reset/delete learning signal
- native surface mutation

Failure examples:

- widget marks step complete without receipt
- recommendation correction changes behavior without receipt
- proof transfer happens silently

## Gate 3 — Trust Seam Gate

Every recommendation or adaptation must expose at least one trust path:

- Why this?
- What source?
- What proof?
- What changed?
- What can I control?
- Why not now?

Failure examples:

- opaque recommendation
- confidence number without source/proof
- hidden personalization
- adaptation without inspection

## Gate 4 — Recovery-First Gate

Closure and failure states must support non-shaming recovery.

Required states:

- Completed
- Still Counts
- Moved
- Skipped / Not Needed
- Blocked
- Waiting
- Needs Recovery
- Needs Review

Failure examples:

- overdue/fail framing
- binary done/not-done only
- no last honest point
- no preserved proof
- no re-entry step

## Gate 5 — Proof Continuity Gate

Proof must survive pivots/deletion/archive when appropriate.

Required flows:

- Pivot Preview
- Proof Transfer Preview
- Proof state change receipt
- stale/contradicted proof state
- proof deletion confirmation

Failure examples:

- deleting a goal loses proof silently
- pivot does not show transferred proof
- source staleness does not affect proof/recommendation state

## Gate 6 — Meaning Router Gate

Capture must route to meaning, not an inbox by default.

Required routes:

- Proof
- Source
- Constraint
- Commitment
- Reflection
- Goal Seed
- Held Item
- Needs a Place
- Ready to Place
- Grow into Goal

Failure examples:

- captured input becomes notes feed only
- route options visible before input in a noisy way
- correction does not update local learning receipt

## Gate 7 — LifeShape Reality Gate

Time must represent capacity, pressure, protection, and recovery.

Required concepts:

- open capacity
- protected time
- pressure field
- commitment density
- recovery windows
- proof opportunities
- simulation/reflow preview

Failure examples:

- generic calendar grid dominates
- silent reflow
- no recovery windows
- no explanation for what moved

## Gate 8 — Personal Runtime Gate

Local learning must be inspectable, controllable, and receipted.

Required controls:

- view learned signal
- view source of learning
- view last used
- view affected recommendations
- disable
- reset
- delete
- receipt

Failure examples:

- hidden personalization
- no delete/reset path
- no learning receipt
- cloud profile assumption

## Gate 9 — Native Surface Receipt Gate

Widgets, Live Activities, App Intents, Share Extension, Spotlight, Control Center, and Action Button actions must preserve Object OS policy.

Required path:

policy guard -> command/event -> side-effect ledger -> receipt -> proof/trust trail

Failure examples:

- App Intent changes state without side-effect record
- widget displays sensitive detail by default
- Live Activity acts like a timer-only productivity feature
- Share Extension bypasses Meaning Router

## Gate 10 — Motion Meaning Gate

Motion must explain object state change and preserve continuity.

Required:

- object birth motion for capture-to-object
- commitment activation motion
- closure/proof/recovery/reflow motion
- Reduce Motion fallback
- static state labels for all motion meanings

Failure examples:

- decorative particles
- confetti/streaks
- information conveyed only by animation
- Reduce Motion losing meaning

## Gate 11 — Visual Object Grammar Gate

Major objects must follow Object OS visual grammar unless superseded by future proof.

Baseline grammar:

- Ambition = constellation / gravitational body
- Goal Thread = path / orbit
- Commitment = tether / active line
- Step = action bead / node
- Proof = trace / glint / anchor
- Source = foundation anchor
- Constraint = boundary / weight
- Recovery = return path
- Reflection = echo / afterimage
- Pressure = density field
- Protected time = quiet boundary
- Receipt = stamped evidence
- Learning Signal = local trace

Failure examples:

- all objects rendered as identical cards
- no visual differentiation between proof/source/recovery/commitment
- generic dashboard iconography

## Gate 12 — Founder QA Gate

Visual/runtime work must include proof hooks for QA.

Required fixture metadata:

- surface
- object type
- state
- proof condition
- source condition
- accessibility condition
- visual grammar state

Founder QA Overlay should expose:

- object ID
- state
- source/proof links
- recommendation trace
- receipt path
- accessibility summary
- performance marker

Failure examples:

- happy-path-only previews
- no state fixture identity
- no way to inspect object/proof linkage

## Gate 13 — No-Copy / Legal Pattern Gate

Ambitions may borrow abstract patterns from successful apps but must not copy protected expression.

Allowed pattern borrowing:

- select -> review -> confirm -> receipt -> track
- live object state
- filterable history
- object detail hierarchy
- command grammar
- glanceable widgets

Forbidden copying:

- visual layout clones
- brand language
- icons/logos
- category-specific gambling or sports mechanics
- proprietary copy
- identical flows with renamed nouns

## Gate 14 — No-Claim Gate

No Object OS implementation batch may claim:

- release readiness
- TestFlight readiness
- App Store readiness
- physical-device proof
- public accessibility conformance
- performance validation
- privacy/legal approval
- visual runtime completion
- global train completion

unless the relevant proof exists and is cited in the batch closeout.

## Use in Codex reviews

Future Codex reviews should classify every Object OS implementation as:

- PASS: all applicable gates satisfied
- YELLOW: implementation installed, proof deferred with explicit no-claim boundary
- RED: generic drift, missing receipt/trust/recovery/proof path, or false claim

## Claims not made

These gates do not implement Object OS runtime. They define future acceptance standards.
