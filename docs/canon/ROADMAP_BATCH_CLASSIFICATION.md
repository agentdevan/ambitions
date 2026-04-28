# Ambitions Roadmap And Batch Classification

Status: Active post-SWOT roadmap/batch classification layer.

Purpose: Convert remaining content weaknesses, opportunities, and threats into launch-safe execution classifications. This document applies `GOLDEN_LAUNCH_LOOP.md`, `HUMAN_LANGUAGE_REVIEW.md`, `LAUNCH_SCOPE_MVP_QUALITY_BAR.md`, and `ROADMAP_BATCH_GOVERNANCE.md` to the current D01-D26 delta/alignment queue.

This document does not reopen completed historical batches. It classifies remaining work so Ambitions becomes stronger through execution instead of broader through scope.

## Classification Rules

Use these labels consistently:

- `launch-critical`: required to prove the Golden Launch Loop.
- `soon-after-launch`: important polish or depth after the loop is proven.
- `post-launch`: valuable but not required for first proof.
- `deferred`: intentionally later because it can distract, overclaim, or widen scope.
- `decision-gated`: requires a specific product decision before implementation.
- `infrastructure-unlock`: not directly user-visible but required by launch-critical work.

## Golden Launch Loop Reference

Launch-critical work must strengthen at least one step:

```text
1. Capture one meaningful goal or task.
2. Put it in the right place.
3. Turn it into a doable plan.
4. Show what to do today.
5. When today is too much, make it doable.
6. Save proof that progress happened.
```

## D01-D26 Classification Summary

| Delta | Name | Classification | Golden Launch Loop mapping | Why |
| --- | --- | --- | --- | --- |
| D01 | Shell IA / Tab Alignment Delta | launch-critical | Place/routing, Today, Trust | The five-tab shell must stay clean before any launch loop is believable. |
| D02 | Shared Object Terminology Cleanup | launch-critical | Capture, Place/routing, Today, Proof | Task vs Step and user-facing terminology must be clear before core flows ship. |
| D03 | GroupedNavigationList Component | infrastructure-unlock / soon-after-launch | Trust/privacy, You | Needed for You/Trust clarity, but not the first proof of the goal loop if simplified UI exists. |
| D04 | Panel Size + Display Density | soon-after-launch | Today, Accessibility | Useful for comfort/focus, but not required to prove the first goal loop. |
| D05 | Receipt / Action Closure Search and Privacy Contract | launch-critical foundation | Proof/receipt, Trust/privacy | Receipts/proof are part of the Golden Launch Loop; full search can follow after baseline proof exists. |
| D06 | Smart Attachment Foundation | launch-critical | Capture, Place/routing, Trust | Capture must know where things go without sounding like AI. |
| D07 | Life Areas Overview / Atlas Object Model | soon-after-launch | Place/routing, Goals | Life Areas help organization, but a simpler Creative/Career/etc. route can launch first. |
| D08 | North Stars / Dormant Ambitions Object Model | post-launch | Goals | Important for long-range depth, not required for one meaningful launch loop. |
| D09 | One-Step Goals Object Model | launch-critical | Capture, Today, Plan | Standalone tasks must exist cleanly without creating a Tasks tab. |
| D10 | Screen Contract Matrix Implementation Pass | infrastructure-unlock | All | Required to keep top-level screens focused and prevent dashboard creep. |
| D11 | Today 2.0 Design Constitution Alignment | launch-critical | Today, Recovery | Today is the core daily proof surface. |
| D12 | Capture + Quiet Command Sheet Alignment | launch-critical | Capture, Place/routing | Capture is the first step of the loop and must feel human. |
| D13 | Goals / Life Areas / North Stars Transformation and Semantic Zoom | split | Goals, Place/routing | Goals transformation is launch-critical; North Stars/Semantic Zoom are post-launch/deferred. |
| D14 | Goal Detail Mission Control Lanes Alignment | launch-critical / soon-after-launch | Plan, Proof | Goal Detail must show next step/proof; full lanes can be phased. |
| D15 | Plan Believability + Timeline Widget Alignment | launch-critical | Plan/doable path, Recovery | Plan must answer what fits and how to adjust. |
| D16 | Ritual Split Alignment | soon-after-launch | Today, Plan | Rituals should not block launch unless current Habits language breaks top-level IA. |
| D17 | You Personal System Center Alignment | soon-after-launch | Trust/privacy | You must be trustworthy; full categorized center can follow baseline trust. |
| D18 | Trust Center Alignment | launch-critical | Trust/privacy | Trust and privacy truth are launch requirements. |
| D19 | What Ambitions Knows | launch-critical / soon-after-launch | Trust/privacy | Baseline memory visibility is launch-critical if memory appears; richer center can follow. |
| D20 | UX Writing Cleanup | launch-critical | All | Human visible copy is a hard launch gate. |
| D21 | Accessibility Nutrition Verification | launch-critical | All | Accessibility is core product quality. |
| D22 | External Surfaces Contract Alignment | post-launch / decision-gated | Today, Trust/privacy | External surfaces should wait until core app loop is stable. |
| D23 | Widgets Alignment | deferred | Today | Defer until Today/Now truth is stable and privacy is verified. |
| D24 | Live Activities Alignment | deferred | Today, Plan | Defer until active focus/time-sensitive plan slices are verified. |
| D25 | App Intents / Shortcuts Alignment | post-launch | Capture, Trust/privacy | Useful, but not required to prove core loop in app. |
| D26 | Release Candidate Validation | launch-critical final gate | All | Required before claiming launch readiness. |

## Recommended Launch-Critical Execution Spine

For the first shippable proof, prioritize:

```text
D01 Shell IA
D02 Shared Object Terminology Cleanup
D06 Smart Attachment Foundation
D09 One-Step Goals Object Model
D11 Today 2.0 Alignment
D12 Capture + Quiet Command Sheet Alignment
D15 Plan Doable Path / Recovery Alignment
D18 Trust Center Baseline
D20 UX Writing Cleanup
D21 Accessibility Verification
D26 Release Candidate Validation
```

Conditional launch-critical:

```text
D05 baseline receipts/proof only
D10 only the screen contracts needed for top-level launch surfaces
D13 only the Goals pieces needed for most important goal / next step / proof
D14 only the Goal Detail pieces needed for next step / proof / decisions
D19 only if memory is visible or used in launch UI
```

Post-launch/deferred for first proof:

```text
D04 full density customization
D07 full Life Areas Atlas
D08 North Stars
D13 Semantic Zoom
D16 Ritual maturity
D17 full You personal system center
D22 external surface contract maturity
D23 Widgets
D24 Live Activities
D25 full App Intents/Shortcuts maturity
```

## Surface-Specific Strength Fixes

### Today

Fix priority:

1. Replace visible AI/producty language.
2. Show one dominant `Do this next` action.
3. Show `Too much for today` when overloaded.
4. Offer `Make today doable` recovery.
5. Keep daily schedule below the main action.
6. Avoid dashboard/card-wall behavior.

### Capture

Fix priority:

1. Use `What needs a place?`.
2. Save with plain receipts: `Saved as...`.
3. Use `Suggested place` / `Move it here?` instead of confidence/classification language.
4. Preserve `Needs a Place` fallback.
5. Keep routing correction easy.

### Plan

Fix priority:

1. Visible labels use `Looks doable`, `Tight`, `Too much planned`, and `No longer works`.
2. Calendar CTA uses `Find open time from Calendar`.
3. No silent calendar writes.
4. Recovery asks what should stay.
5. Do not expose `believability`, `protected`, `fragile`, or `optimization` in normal UI.

### Goals

Fix priority:

1. Show the most important goal.
2. Show what is next.
3. Show how the goal is going.
4. Save/show proof.
5. Do not become a project board.

### You

Fix priority:

1. Start from `You are in control`.
2. Show `What Ambitions knows` when memory exists.
3. Keep settings/history/trust/data controls findable.
4. Avoid data-console language.

## Threat Neutralization Checklist

Before marking any work launch-ready:

- Does it map to Golden Launch Loop?
- Does it avoid AI/producty visible copy?
- Does it keep top-level IA unchanged?
- Does it avoid dashboard creep?
- Does it preserve local-first/no launch sync?
- Does it avoid unverified platform claims?
- Does it create visible product movement or unlock a required shared system?

## Required Roadmap Edit Pass

The main roadmap and batch plan should eventually be updated so each item has:

```markdown
Launch status: launch-critical / soon-after-launch / post-launch / deferred / decision-gated
Golden Launch Loop mapping:
- Capture:
- Place/routing:
- Plan/doable path:
- Today/next action:
- Recovery:
- Proof/receipt:
- Trust/privacy:
```

Do not rewrite the roadmap broadly until this classification is applied consistently.

## Current Implementation Note

The first targeted user-facing code cleanup was started in `Native/Ambitions/Features/Plan/PlanFeatureModels.swift` by humanizing visible Plan labels. Further code cleanup should continue with service-generated strings, previews, tests, widgets, notifications, and App Intents.

## Next Prompt

```markdown
Apply `docs/canon/ROADMAP_BATCH_CLASSIFICATION.md` to the active Ambitions roadmap and batch docs.

Read first:
1. `docs/canon/SOURCE_OF_TRUTH_MAP.md`
2. `docs/canon/GOLDEN_LAUNCH_LOOP.md`
3. `docs/canon/HUMAN_LANGUAGE_REVIEW.md`
4. `docs/canon/ROADMAP_BATCH_CLASSIFICATION.md`
5. `docs/canon/Ambitions_2_0_Roadmap.md`
6. `docs/canon/Ambitions_2_0_Batch_Plan.md`
7. `docs/canon/Ambitions_2_0_Implementation_Gap_Audit.md`
8. `docs/codex/BATCH_REGISTRY.md`

Task:
- Do not implement app code.
- Add launch status and Golden Launch Loop mapping to roadmap/batch docs where safe.
- Keep D01 as the next implementation batch unless user says otherwise.
- Mark widgets, Live Activities, sync, advanced memory, advanced reviews, semantic zoom, North Stars, and full personalization as post-launch/deferred/decision-gated unless required by a launch-critical loop.
- Preserve Today / Goals / Capture / Plan / You.
- Preserve local-first launch.
- Preserve human-language rules.

Acceptance:
- Roadmap no longer reads like every advanced system is needed for launch.
- Launch-critical work clearly maps to capture/place/plan/today/recovery/proof/trust.
- Deferred and decision-gated work remains visible without becoming launch scope.
```
