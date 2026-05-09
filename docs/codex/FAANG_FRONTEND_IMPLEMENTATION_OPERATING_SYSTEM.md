# FAANG Frontend Implementation Operating System

<!-- markdownlint-disable MD013 -->

Status: Active Codex OS layer for future frontend/UI-touching Ambitions batches
Date: 2026-05-09
Batch: CQS25 / FET00

## Purpose

This operating system prevents a known Ambitions failure mode: SwiftUI builds, focused tests, and source-contract checks pass while the live simulator still reads as stacked generic panels, diagnostic cards, over-explained compliance UI, or a component proof screen.

FET does not claim the current UI is fixed. It is a Codex OS gate layer for future frontend work. It changes no app behavior, route/raw values, persistence/schema, workflows, signing, dependencies, or release posture.

## Source Truth

FET inherits these sources:

- `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/FRONTEND_EXCELLENCE_GATE_MATRIX.md`
- `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md`
- `docs/canon/Ambitions_Signature_Interface_System.md`
- `docs/canon/Ambitions_Visual_QA_Red_Team_Audit.md`
- FVQ and SI evidence packets where relevant

When docs conflict, preserve completed history and resolve active frontend execution in favor of the newest active canon/status files. FET strengthens gates; it does not weaken SI, FVQ, AFI, FCP, PD, PFC, AOS, LDI, PK, or release-evidence gates.

## Applicability

FET applies to every future batch that touches:

- visible SwiftUI surfaces, shell, tab bar, navigation chrome, top-level composition, or drill-down composition
- visual primitives, signature objects, layout systems, grouped lists, cards/panels, motion, haptics, symbols, material, typography, color, or spacing
- preview fixtures, screenshot packets, visual QA infrastructure, accessibility presentation, Dynamic Type, VoiceOver, reduced motion, copy visible in UI, onboarding, widgets, Live Activities, App Intents confirmation UI, or release screenshots
- FCP, AFI, DAV, PD, SI, FVQ, AOS UI, LDI UI, Source Atlas UI, or PFC external-surface UI work

Docs-only batches invoke FET when they define future visible UI gates or make frontend quality claims. Docs-only Green may be allowed without screenshots only when the batch explicitly makes no rendered UI claim.

## Frontend Leadership Model

Future UI batches must act like a senior product engineering room, not a generic executor:

- Product/design lead owns first-glance user value, emotional tone, native believability, and restraint.
- Senior SwiftUI systems engineer owns composition, state, file boundaries, previews, accessibility, and maintainability.
- Visual QA reviewer owns fresh simulator screenshots or preview evidence and blocks build-only closeout.
- Copy reviewer owns compression, user-value language, and removal of internal architecture explanations.
- Chrome/navigation reviewer owns tab bar, toolbar, floating action, receipt overlay, and bottom-safe-area ownership.

Required reviewer skills are named in `FRONTEND_EXCELLENCE_GATE_MATRIX.md`.

## Non-Negotiable Frontend Rules

- Build/test success is never a substitute for rendered visual proof in UI-touching work.
- One first viewport gets one primary object. Secondary objects must clearly support it.
- The native tab bar, custom tab rail, floating global action, toolbar, receipt overlay, and surface actions must not compete.
- A signature object must not degrade into a generic rounded card, panel stack, dashboard, list wall, or diagnostic module.
- Root surfaces must be visually distinguishable. Today, Goals, Capture, Time, and You cannot look like interchangeable card stacks with different labels.
- Copy must explain user value and next action, not internal architecture, proof machinery, implementation names, or compliance posture.
- Motion must orient, confirm, or reduce uncertainty. Meaningful motion needs Reduce Motion and non-motion equivalents.
- Accessibility evidence must cover more than identifiers. Dynamic Type, VoiceOver order, touch targets, contrast, non-color cues, and reduced cognitive load are part of the gate.
- Premium, flagship, Apple-level, FAANG-level, 10/10, visually approved, accessibility approved, release-ready, TestFlight-ready, or App Store-ready claims require the specific evidence demanded by the relevant gate and release docs.

## Hard Frontend Red Conditions

Any of these is Red for a UI-touching batch:

- UI batch has no simulator screenshots or preview evidence.
- Build passes but no visual evidence exists.
- First viewport has more than one primary object.
- Native tab bar, custom tab rail, floating global action, or toolbar affordances compete visually.
- Hero/primary surface contains unlimited nested content or generic panel stacking.
- More than four chips appear above the fold.
- More than twelve body-copy lines appear above the fold.
- Product explains internal architecture instead of user value.
- Motion is decorative, unexplained, or lacks Reduce Motion equivalent.
- Accessibility identifiers exist but Dynamic Type, VoiceOver, touch target, contrast, or reduced cognitive load evidence is missing.
- The batch claims premium, flagship, Apple-level, FAANG-level, or 10/10 without screenshot evidence and rubric scoring.
- Top-level Today / Goals / Capture / Time / You surfaces look visually interchangeable.
- A primitive intended as a signature object becomes a generic rounded card.
- Build/test success is used as substitute for visual proof.

## Frontend Scorecard

Score 1-100 for:

| Category | Required evidence |
| --- | --- |
| First-glance clarity | Screenshot or preview proves the user knows the primary object and next action within the first viewport. |
| Native iPhone believability | Chrome, spacing, gestures, typography, safe areas, and controls feel plausible on iPhone. |
| Visual hierarchy | One primary object, supporting secondary content, no equal-weight panel pile. |
| Surface originality | The surface feels Ambitions-native, not generic task/calendar/dashboard UI. |
| Restraint | Above-fold density, chips, labels, copy, and decorations are bounded. |
| Emotional tone | Calm, mature, non-shaming, personally useful. |
| Accessibility resilience | Dynamic Type, VoiceOver, touch target, contrast, non-color, reduced cognitive load evidence. |
| Motion/interaction believability | Motion/haptics are purposeful and have Reduce Motion/non-motion equivalents. |
| Product-language quality | Copy uses user value and next action, not architecture explanations or AI theater. |
| System coherence | Surface fits Today / Goals / Capture / Time / You, shared primitives, trust, receipts, and route boundaries. |
| Maintainability | Small owner files, reusable components, previews/state matrix, no giant one-off view. |
| Screenshot evidence quality | Fresh, named, durable screenshot/preview packet with limitations and non-claims. |

Green requires average >= 90, no category below 85, and no Red in accessibility, screenshot evidence, bottom chrome ownership, first viewport composition, route compatibility, or release-claim safety.

Yellow is average 80-89 with no hard Red and a named owner.

Red is average below 80, any hard Red, missing screenshots for UI-touching work, or build/test success used as visual proof.

## Required FET Evidence Packet

Every UI-touching batch report must include:

- changed surfaces and owner files
- first-viewport screenshot or preview inventory
- above-fold budget: primary object, chip count, body-copy line count, competing chrome check
- bottom chrome ownership check
- primitive/object identity check
- copy compression check
- accessibility evidence beyond identifiers
- Reduce Motion or no-motion explanation
- frontend scorecard table
- Yellow/Red owners
- release-claim non-claims
- rollback path

## Advisory Scripts

Run these for frontend/UI-touching batches:

```bash
scripts/fet-readiness-gate.sh || true
scripts/fet-first-viewport-budget-scan.sh || true
scripts/fet-bottom-chrome-conflict-scan.sh || true
scripts/fet-primitive-density-scan.sh || true
scripts/fet-copy-density-scan.sh || true
scripts/fet-visual-qa-packet-check.sh || true
```

The scripts are read-only advisory scanners at FET00. The gate protocol decides when their findings become hard Red: UI-touching batches cannot close Green until hard frontend Red conditions are repaired or explicitly classified as not applicable with evidence.

## Non-Claims

FET00 does not fix the current UI, approve visual quality, prove accessibility, prove device behavior, approve release posture, or start FET01-FET12 implementation. It creates the operating system future UI work must satisfy.
