---
name: design-system-guard
description: Preserve Ambitions' premium dark-first SwiftUI design quality during UI implementation and review. Use when polishing screens, matching the Ambitions design system, or preventing component drift, cheap styling, clutter, or inconsistent spacing across `Native/Ambitions/`, `Sources/`, and `AppUI/Sources/`; do not use for broad redesigns unrelated to the requested screen or feature.
---

# Design System Guard

## Purpose

Keep UI changes aligned with Ambitions' existing premium product feel instead of letting one-off implementation drift lower the quality bar.

## When To Use

- `polish this screen`
- `make this match Ambitions design system`
- `keep the UI premium`
- review or implementation work that changes visible SwiftUI surfaces

## When Not To Use

- The task is backend or domain-only.
- The user explicitly wants a larger product redesign instead of preserving current language.
- The request is a docs or copy audit with no UI change.

## Required Inputs

- The screen or component being changed.
- Relevant shared components and theme files.
- Existing Ambitions UI patterns in nearby screens.

## Execution Steps

1. Inspect the current UI surface and nearby shared primitives before editing.
2. Reuse existing theme, typography, spacing, card, navigation, and feedback primitives where they fit.
3. Keep the design focused:
   - strong hierarchy
   - calm premium density
   - dark-first legibility
   - clear primary actions
   - disciplined spacing
4. Remove or avoid:
   - enterprise dashboard clutter
   - random chip/button/card styles
   - overloaded empty states
   - cheap gradients or novelty styling that does not match the app
5. Scope polish to the requested surface. Do not redesign unrelated screens just because you touched a shared component.
6. Read `references/ambitions-ui-principles.md` for the current design guardrails.

## Output Format Expectations

When summarizing, explain:

1. what visual issue was corrected
2. which shared primitives or theme rules were followed
3. whether any intentional UI tradeoff was made

## Validation Requirements

- Verify the changed surface still compiles and renders in both theme contexts used by the repo.
- Check spacing, emphasis, and accessibility labels when visible components changed materially.
- Note any preview or simulator checks that were not run.

## Ambitions-Specific Guardrails

- Preserve the premium consumer-product tone already present in Today, Goals, Habits, Insights, Profile, and Captures.
- Prefer shared primitives from `Sources/Components/` and theme definitions from `Sources/Theme/`.
- Keep dark-mode quality high; light mode should remain supported where the app already supports it.
- Clarity beats ornament. Use motion and polish to support comprehension, not decoration.

## Trigger Phrases

- `polish this screen`
- `make this match Ambitions design system`
- `keep the UI premium`
- `tighten this SwiftUI surface`
