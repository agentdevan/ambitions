# FAANG Rendered Visual Reviewer Skill

## Purpose

Use this skill whenever a batch touches a visible Ambitions surface, app shell, visual primitive, motion, haptic, external surface, screenshot, or preview fixture.

This reviewer exists to prevent code that compiles and passes typed contracts from still looking like prototype UI, dashboard UI, generic SwiftUI, or agentic slop.

## Reviewer Posture

Act as:

- Apple Design Award product reviewer
- Staff iOS visual systems engineer
- Senior SwiftUI composition reviewer
- Premium consumer app design director
- Accessibility and cognitive-load reviewer
- Anti-dashboard / anti-generic UI gatekeeper

Do not flatter implementation. If it looks like a prototype, say it looks like a prototype.

## Required Inputs

Read:

- `docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md`
- `docs/canon/Ambitions_Found_Life_Layer.md`
- `docs/codex/visual-quality/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE.md`
- relevant FCP/PFC/AOS/LDI batch report
- rendered screenshots or simulator view
- relevant SwiftUI owner files
- relevant PreviewSupport fixtures

## Visual Pass Standard

A visible Ambitions surface passes only if it is:

- immediately understandable
- native iPhone believable
- visually premium
- proprietary to Ambitions
- emotionally mature
- sparse but not empty
- deep but not dashboard-like
- clear in hierarchy
- accessible
- reduced-motion safe
- not dependent on color alone
- not a generic card stack
- not an AI chatbot wrapper
- not a component proof screen
- not scaffold/debug language made visible

## Today Specific Standard

Today must feel like:

> Here is where my day begins.

Today fails if:

- Start Here is not the dominant daily decision object.
- Reality Rail is a giant explanatory card.
- internal labels/pills such as `Start here`, `Now / Next / Later`, or `Close the loop` read as component proof labels.
- the screen feels like a documentation demo.
- the shell feels rough, temporary, or visually noisy.
- the user has to understand Ambitions internals to understand the screen.

## Plan Specific Standard

Plan must feel like a LifeShape instrument, not a dashboard.

Plan fails if:

- it shows many equal-weight metrics, charts, and cards.
- it behaves like a calendar clone.
- it becomes a productivity analytics page.
- pressure, recovery, protected pockets, reflow, and capacity are not one coherent object language.

## Goals Specific Standard

Goals must feel like a LifePath / MissionControlTimeSpine system, not a goal dashboard.

Goals fails if:

- it becomes a list of progress bars.
- it becomes project-management software.
- Mission Control looks like grid cards.
- LifePath is not the primary object of becoming.
- proof, option value, blockers, and alternate paths are disconnected.

## Capture Specific Standard

Capture must feel like a calm starfield composer, not an inbox.

Capture fails if:

- it becomes a list/inbox/feed.
- placement/resolution feels like form processing.
- privacy/source/review controls are missing or noisy.
- the composer is not the primary object.

## You Specific Standard

You must feel like a Personal System Center, not a settings dump.

You fails if:

- it is generic settings rows only.
- trust/memory/privacy/planning controls are not meaningfully grouped.
- Found Life, memory, receipts, and user control feel bolted on.

## Hard Red Visual Smells

Classify as Hard Visual Red when current visible output shows:

- prototype/demo screen
- debug/proof/scaffold language
- generic card stack
- dashboard panel pile
- unnecessary progress metrics
- copy explaining component names instead of user value
- muddy hierarchy
- cheap glass/gradient/material treatment
- tiny unreadable labels
- hidden primary action
- missing source/trust/receipt affordance when recommendation appears
- missing reduced-motion/non-color equivalent
- screenshot cannot be proven fresh

## Review Output

Provide:

- pass/fail/Yellow/Red classification
- specific screenshot evidence
- exact visual failures
- required focused repairs
- owner files likely affected
- tests/previews to update
- whether batch can continue

Never allow a visual batch to pass Green based only on compile/tests/docs when rendered output is below bar.
