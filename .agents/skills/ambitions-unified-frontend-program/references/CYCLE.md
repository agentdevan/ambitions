# Unified frontend cycle

The cycle has two nested levels: the ordered UFP program milestones and the
existing maximum-polish cycle for each design component. Native Visual Foundry
is the fixture and proof harness inside both levels.

## Live-truth preflight

- Verify repository path, branch, local HEAD, remote main, worktrees, status,
  diff, installed Xcode/SDK, and current output artifacts.
- Read owning canon, current implementation/tests, accepted evidence, owner
  decisions, v2 ledger, active milestone, and next component.
- Separate historical evidence from current post-Owner-Taste authority.
- Stop and reconcile drift without cleaning unrelated work.

Exit: live truth and mutation boundaries are explicit.

## Component maximum-polish loop

Run this loop for each design component inside UFP-1 through UFP-5.

### 1. Current research

Use current primary Apple sources, installed SDK interfaces, and direct native
observation. Research behavior and mechanisms rather than copying brand,
layout, symbols, or information architecture. Record source, access date,
documented fact, inference, and artifact.

### 2. Baseline audit

Audit canon meaning, live implementation, accepted evidence, accessibility,
restoration, density, failure behavior, and P01-P15. Classify each finding as
preserve, repair, reject, investigate, harness proof required, runtime proof
required, or device proof required.

### 3. Internal exploration

Build materially different hypotheses, SWOT each against product meaning,
platform behavior, accessibility, feasibility, density, and identity, and
retain one decisive direction plus a concise rejection record.

### 4. Five compounding passes

Every completed pass contains nonempty `swot`, `review`, `repair`, `gap`,
`polish`, and `evidence` records. Passes complete in order, and later changes
reopen affected earlier assumptions.

1. Purpose, ownership, information, truth, consequence, action, return, and
   forbidden anatomy.
2. Anatomy, hierarchy, density, typography, spacing, symbols, material,
   appearance, and optical hierarchy.
3. Interaction, navigation, state, keyboard, focus, restoration, motion, and
   haptics.
4. Accessibility transformation, localization, RTL, device classes, contrast,
   transparency, motion, and ergonomics.
5. Feasibility, source ownership, performance plausibility, proof, gap
   disposition, and ruthless convergence.

### 5. Owner review

Present one direction with critical rendered frames, improvement, anatomy,
state/adaptation matrix, feasibility, rejection summary, and exact proof
ceiling. Record the owner's words and date. Approval selects only the bounded
component direction; revision reopens the affected pass and later dependencies.

## Ordered UFP milestones

### UFP-0 — program consolidation

Consolidate authority, lifecycle documents, ledger, workflow, component
controls, canonical-source boundary, and zero-legacy contract.

### UFP-1 — primary directions

Complete the post-authority primary frontend directions through the component
loop. Work only on the ledger's `next_component_id`.

### UFP-2 — complete coverage

Close the 47-screen and system-surface matrix, including typical, dense,
very-dense, Light, Dark, keyboard, localization, RTL, accessibility, failure,
and restoration states where applicable.

### UFP-3 — unified system and grammar

Derive and owner-approve one design system and cross-root grammar from approved
post-authority consumers. Do not impose a speculative component abstraction on
consumers that do not share semantics, lifecycle, state, and accessibility.

### UFP-4 — canonical component source

Establish one canonical source and give every Foundry and Maximum Polish
component exactly one disposition: `promote`, `rebuild`, `fixture-only`,
`historical`, or `delete`.

### UFP-5 — complete fixture frontend

Complete and owner-approve the entire fixture-driven frontend. Foundry must
render production-intended canonical views through synthetic adapters. Passing
UFP-5 does not authorize runtime integration until `frontend_design` and
`runtime_integration` are independently true.

### UFP-6 — runtime integration

Connect the approved canonical views to production-owned runtime adapters.
Preserve local-first authority, privacy, persistence/replay, migration, and
concurrency invariants. Runtime work may change adapters and ownership seams;
it may not silently redesign the approved frontend.

### UFP-7 — cutover and deletion

Perform one production cutover. Delete every legacy frontend source, component,
target, asset, dependency, wrapper, route, preview, UI test, flag, and other
classified legacy artifact. Preserve required nonvisual behavior only after it
has moved behind a runtime-owned boundary. Do not ship a dual renderer.

### UFP-8 — release closure

Close production, physical-device, manual accessibility, performance, privacy,
energy, localization, migration, and release proof. Release remains blocked
until zero-legacy verification is complete with recorded evidence and the owner
explicitly approves release.
