# UI Studio 10 FAANG-Level UI Red Team

Status: Active red-team trace
Authority: subordinate to `docs/truth/*` and `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
Batch: `UI-STUDIO-10-FAANG-LEVEL-UI-RED-TEAM`

This file is a control-plane review artifact. It records failure modes, source-truth alignment, and proof boundaries. It is not implementation proof, screenshot proof, accessibility proof, device proof, performance proof, or release proof.

## Review Frame

- The active product/design truth locks `Today / Goals / Capture / Time / You`, keeps `Plan` out of the tab bar, and rejects generic task-app, dashboard, chatbot, calendar-clone, card-stack, streak, score, color-only, motion-only, and tap-target regressions: `docs/truth/PRODUCT_DESIGN_TRUTH.md:36-40`, `:86-87`, `:160-176`.
- The implementation truth says live source wins, docs alone do not prove implementation, and compatibility/history language does not establish current behavior: `docs/truth/IMPLEMENTATION_TRUTH.md:13-25`, `:39-40`, `:93-105`.
- UI Studio operating guidance preserves the active top-level IA, treats `Plan` as compatibility-only, and blocks screenshot/accessibility/release claims from docs alone: `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md:12-20`, `:51-58`, `:83-91`.

## Red-Team Failure Modes

| Failure mode | Evidence | Why it matters | Classification |
| --- | --- | --- | --- |
| Plan residue in preview copy | `Sources/Previews/SI03ShellNavigationPreviews.swift:10-15` still says "Today, Goals, Capture, Plan, and You." | This conflicts with the active top-level IA and risks re-normalizing Plan as user-facing top-level language. | Review/control-plane evidence, not implementation proof |
| Overload axis still names Plan | `Sources/Accessibility/AccessibilityNutrition.swift:474-548` includes `overloadedPlan`, `Overloaded Plan`, and `Native/Ambitions/Features/Plan/PlanScreen.swift`. | This is compatibility debt at best. It must not be misread as active top-level IA or as proof of a user-facing Plan tab. | Review/control-plane evidence, not implementation proof |
| Streak pressure residue | `AppUI/Sources/WidgetFoundation.swift:5-18` defines a `streak` widget family; `AppUI/Sources/WidgetPreviews.swift:74-77` renders a streak preview with "7 steady days" and celebration-styled state. | Active truth rejects streak pressure, score pressure, and shame loops. The existence of the fixture is a red-team risk even if the copy is softened. | Review/control-plane evidence, not implementation proof |
| Generic dashboard/card-stack drift risk | Active truth explicitly bans dashboard, card-stack, chatbot, and calendar-clone regressions: `docs/truth/PRODUCT_DESIGN_TRUTH.md:36-40`, `:165-176`; `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md:18-20`, `:57-58`, `:85-90`. | These are the canonical regressions the UI Studio family must keep rejecting before work is considered flagship. | Canonical risk register, not proof of a shipped regression |
| Accessibility proof gap | Active truth requires accessibility to be present, but also says docs do not prove conformance; the implementation truth says accessibility and release readiness require validation proof. | No current source excerpt here proves Dynamic Type, VoiceOver order, Increase Contrast, Reduce Motion parity, tap-target compliance, or non-color-only meaning. | Proof gap, not a failure claim |
| Over-animation and motion-only risk | Active truth requires Reduce Motion equivalents and forbids motion as the only relationship cue: `docs/truth/PRODUCT_DESIGN_TRUTH.md:159`, `:164`; UI Studio requires accessibility/performance proof before claims: `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md:51-58`, `:72-78`. | No animation or screenshot evidence was gathered in this docs-only phase, so any visual approval would be greenwashing. | Proof gap, not a failure claim |

## Evidence Notes

- The active IA is `Today / Goals / Capture / Time / You`, with `Plan` only compatibility-only unless current truth widens it: `docs/truth/PRODUCT_DESIGN_TRUTH.md:86-87`, `:116`, `:597-610`; `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md:14-16`, `:53-58`.
- The red-team surface should keep calling out dashboard, card-stack, chatbot-first, and calendar-clone defaults because those are hard stops in both product truth and UI Studio guidance: `docs/truth/PRODUCT_DESIGN_TRUTH.md:36-40`, `:165-176`; `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md:18-20`, `:57-58`.
- Tap targets, color-only state, and over-animation remain review gates, not proven-safe implementation characteristics, until current source and visual/accessibility proof demonstrate compliance.
- The source fragments above are evidence of residue, not proof of live user-facing behavior. They are useful only as review/control-plane signals.

## Non-Claims

- No screenshot proof is claimed.
- No accessibility conformance proof is claimed.
- No device proof is claimed.
- No performance proof is claimed.
- No release proof is claimed.
- No app behavior completion proof is claimed.
- No claim is made that the preview residue, streak fixture, or overload axis has been removed.

## Validation

Validated in this phase:

- `make prompt-audit`
- `git diff --check`
- focused evidence scan of the approved trace/index scope and the cited source files

Not validated in this phase:

- simulator behavior
- screenshot capture
- device accessibility behavior
- performance profiling
- release gating

## Summary

The control-plane evidence is coherent: active truth still blocks generic UI regressions, the preview and accessibility surfaces still contain Plan residue, and the widget preview set still carries streak-language risk. The file intentionally preserves those findings as review evidence only.
