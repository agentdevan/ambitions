# Capture Experience Canon
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; PX04 complete; not current app implementation truth
Date: 2026-05-02

## Purpose

Capture is the intake surface. It must feel ultra-minimal, private, fast, calm, magical but restrained, and visually distinct. It is not chat, notes, inbox, or a form.

Capture owns bottom composer, text field at bottom, mic inside field, add button to the right, first-use route reveal, no normal scrolling by default, restrained dark-sky/starfield signature, captured-thought privacy, Needs a Place, Ready to Place, Grow into Goal, quick capture, later classification, gentle routing, user confirmation before major promotion, ambiguous capture review, private/sensitive capture handling, and deferred placement.

Routes reveal after input, not before. Secondary flows are drill-downs, not top-level defaults. Dark-sky/starfield signature applies to Capture and First Run with restraint.

## PX04 Top-Level Orientation Surface

Capture answers one question first:

```text
What needs a place?
```

The first viewport should orient around one dominant object: the private intake
composer and the current captured thought. Capture is a fast place to put
something down and see where it belongs, not a long-lived inbox, notes library,
chat thread, task dump, or dashboard.

The top-level Capture composition is:

1. Quiet private intake field anchored low in the screen.
2. One captured thought or draft preview after input.
3. One placement state: `Needs a Place`, `Suggested Place`, `Ready to Place`,
   `Decide later`, or `Saved for review`.
4. One primary placement action only when enough information exists.
5. Secondary routing detail behind Capture routing review, not exposed as a
   stacked set of top-level cards.

Capture should feel immediate before input and precise after input. It should
not show every possible route, every old capture, every classification reason,
or every later destination on the top-level surface by default.

## Primary Object And Action

Primary object: the current captured thought.

Primary action: place or preserve the captured thought with user-visible
control. Preferred action labels include `Place it`, `Change`, `Decide later`,
`Grow into Goal`, `Save as proof`, or `Review route`.

Capture should show one primary action at a time:

- `Place it` confirms the suggested destination.
- `Change` opens routing review when the suggestion is wrong or ambiguous.
- `Decide later` preserves the capture without pretending it is handled.
- `Grow into Goal` starts the goal-seed handoff only after confirmation.
- `Save as proof` routes to proof only when the capture is evidence.
- `Review route` opens the owned placement detail for ambiguous captures.

## Placement States

| State | Meaning | Top-level Capture behavior |
| --- | --- | --- |
| Raw input | the user is still entering a thought | keep focus on the composer |
| Needs a Place | Ambitions cannot honestly route yet | ask for review, do not guess |
| Suggested Place | a likely destination exists | show destination and consequence |
| Ready to Place | enough information exists for confirmation | show `Place it` as primary |
| Decide later | the user parks the item intentionally | preserve without shame |
| Failed save | local save could not finish | explain recovery without blame |
| Offline capture | capture is local and safe | avoid cloud/platform claims |
| Sensitive capture | details may be private | redact preview and show privacy label |

## Placement Preview And Consequence Copy

Placement preview should show what will happen in plain language before the
user confirms it:

- where the capture will go;
- whether Today changes;
- whether Plan changes;
- whether a Goal is created or updated;
- whether proof is saved;
- whether anything stays private;
- whether a later review is needed.

Capture must not silently route, reschedule, create goals, expose sensitive
details, or claim automatic organization. If the destination is uncertain, the
surface should say so and ask for review.

## Grow Into Goal Boundary

`Grow into Goal` is a confirmation handoff from Capture to Goals. It is for a
captured thought that has enough intent to become a goal seed. It should not
turn every capture into a goal, and it must not create a goal without visible
confirmation.

The handoff belongs to:

- Capture for intake, source, privacy, and placement preview.
- Goals for goal creation, Goal Detail, path, proof, and Mission Control depth.
- Plan/Today only after the goal or placement creates an owned next step.

## Privacy And Trust Rules

Capture is private by default. Future UI should use quiet privacy labels such
as `Stored on this device`, `Needs your confirmation`, `Private detail hidden`,
or `No silent changes` when relevant.

Capture must keep calendar permission and planning authority out of onboarding.
Plan owns calendar/time permission and Life Shape setup. Capture may explain
that a capture can become a plan item later, but it must not request calendar
access or imply silent schedule changes.

## Visual Orientation Examples

Good Capture:

- bottom composer is unmistakable;
- one current captured thought is visually dominant after input;
- one placement state is clear;
- consequence copy is short and specific;
- route review is available but not forced;
- privacy labels appear when sensitive or consequential.

Bad Capture:

- generic notes list as the first screen;
- inbox-style backlog as the primary object;
- chat transcript as the main model;
- task dump with checkboxes;
- stacked cards for every possible route;
- silent suggestions with no consequence copy.

## Accessibility And Cognitive Load

Capture must support Dynamic Type, VoiceOver labels for the composer, captured
thought, placement state, privacy label, and primary action, Reduce Motion
alternatives for route reveal, no color-only placement meaning, visible
alternatives for gestures, and a first viewport that asks for only one
placement decision at a time.

The 3-second glance test passes only when the user can identify what was
captured, whether it needs a place, and the next safe action without reading a
history list.

## Required Source Stack

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/AmbitionsOS_Index.md`
- `docs/codex/PXOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Gates

- Product Decision Lock Gate: major choices must be locked by source truth or recorded as open/deferred.
- Surface Ownership Gate: every future UI change names Today, Goals, Capture, Plan, You, or a drill-down owner.
- Deep-Not-Wide Gate: deepen existing surfaces before creating new surface area.
- Accessibility / Cognitive Load Gate: future UI must specify Dynamic Type, VoiceOver, Reduce Motion, no color-only meaning, and cognitive-load expectations.
- Release Claim Gate: no release/platform/AI/personalization claim without evidence.
- ME Gate: no large UI expansion in known large-file zones without extraction review.
- CS Gate: no route/raw-value/external-surface/persistence breakage.

## Implementation Boundary

This is future canon and process guidance only. It does not implement app behavior, change production Swift, start PXOS, start AOS/ME/CS/REC02, retire compatibility seams, add dependencies, change workflows, add backend/sync/cloud/model runtime, or create release/platform readiness claims.
