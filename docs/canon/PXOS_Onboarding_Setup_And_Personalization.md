# Onboarding Setup And Personalization
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; PX11 complete; not current app implementation truth
Date: 2026-05-02

## Purpose

Onboarding helps Ambitions become personal without making first run a configuration chore. It owns first-run promise, schedule and availability prompt, planning defaults prompt, automation trust setup, goal/capture starter path, privacy expectation, what Ambitions will and will not do, optional setup, progressive setup reminders, and setup completeness under You.

First Run may use the restrained dark-sky/starfield signature. Schedule & Availability should be visibly useful and reachable from relevant surfaces. The app should make clear why schedule/availability improves recommendations and planning, while not requiring full life setup before value.

PXOS onboarding has one job: get the user to a useful first object while
making trust, control, and optional setup clear. It should feel like a guided
start, not a form, tutorial wall, permissions gauntlet, chatbot interview, or
profile-building ceremony.

## First Useful Object

The first useful object should be created before optional setup becomes deep.
PXOS allows three starter paths:

- Capture something that needs a place.
- Choose or create a first Goal.
- Review a suggested `Start here` step only when the source and assumptions are
  visible.

The default first-run posture is Capture-first because it creates value without
requiring complete profile, calendar, notification, import, account, or
personalization setup.

First Run should make one primary action obvious and keep secondary setup
behind `Set up later`, `Review setup`, or You-owned setup routes.

## First Run Sequence

Future PXOS implementation should treat this as the locked default sequence
unless a later batch records a stronger decision:

1. Welcome promise: Ambitions helps turn raw intent into a placed next step.
2. Private first object: `What needs a place?`
3. Placement preview: show where the item may go and what will change.
4. Trust setup: show `Guided` automation as the default and explain that
   Ambitions asks before meaningful changes.
5. Optional setup: offer Schedule & Availability, Planning Defaults, import,
   and notification education as skippable routes.
6. First action: route to Today, Capture, or Goals with one clear next step and
   a visible way to adjust.

This sequence must not require account creation, calendar permission,
notification permission, import, model personalization, or full life setup
before the first useful object.

## Permission And Setup Boundaries

Calendar permission is Plan-owned and must not be requested during onboarding.
Onboarding may educate the user that Schedule & Availability can improve
planning, but it should route to Plan or You setup instead of prompting for OS
permission in First Run.

Notification, calendar, contacts, reminders, import/export, and external
platform setup are optional future routes. They need source truth, claim
boundaries, and platform proof before any implementation may claim they work.

## Automation And Trust Defaults

Default automation level: `Guided`.

Guided means Ambitions may suggest, organize, explain, and prepare changes, but
the user confirms meaningful routing, rescheduling, proof saving, importing,
or personalization changes.

First Run must show:

- `You are in control`
- `No silent changes`
- `Stored on this device` when the future implementation can prove it
- source/freshness labels when suggestions depend on prior context
- controls to skip, adjust, pause, or review setup later

Do not describe personalization as complete, automatic, production-ready, or
model-powered. Say what Ambitions can know, what it does not know yet, and
where the user can review or correct it.

## Optional Setup Areas

Setup belongs primarily under You, with contextual entry points from Today,
Plan, Capture, and Goals only when the missing setup affects the current
decision.

Future setup areas:

- Schedule & Availability: Plan-owned; explain protected time, free time, and
  planning windows without requesting calendar permission during onboarding.
- Planning Defaults: You-owned defaults for preferred pace, review rhythm,
  recovery posture, and confirmation level.
- Automation & Trust: You-owned controls for guided suggestions, confirmation,
  receipts, source labels, and what Ambitions may change.
- Import or Skip: optional, consequence-previewed, never required before
  first value.
- Source & Freshness: explain `Current`, `May Need Review`, and `Based on Older
  Context` labels when setup uses existing context.

## Returning User Onboarding

Returning setup should be progressive and contextual:

- show missing setup only when it would improve the current surface;
- avoid nagging, streak pressure, or shame;
- let the user dismiss or review later;
- keep setup completeness in You, not as a top-level dashboard score;
- show what will improve if setup is completed and what still works without it.

## Visual And Interaction Criteria

First Run may use the restrained dark-sky/starfield signature, but the
signature must support focus and not become decorative noise or fake AI glow.

PX11 passes visually when:

- one primary first action is obvious;
- optional setup does not compete with the first object;
- permission education is clearly separate from permission request;
- trust controls are visible before sensitive personalization;
- the user can skip without feeling punished;
- Dynamic Type, VoiceOver, Reduce Motion, and non-color-only state can be
  supported by future implementation.

## Non-Claims

PX11 does not prove onboarding exists in the app, does not prove screenshots,
previews, device behavior, public accessibility conformance, platform
integrations, import/export, personalization, calendar access, notifications,
or release readiness.

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
