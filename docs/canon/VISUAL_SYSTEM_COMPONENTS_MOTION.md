# Ambitions Visual System, Components, And Motion

Status: Active canon consolidation layer.

Purpose: Consolidate visual-system feeling, top-level screen hierarchy, rich panel usage, component/token priority, motion, celebration, theme support, and visual anti-patterns into one implementation-readable reference. This document reflects Wave 12 product decisions.

## Core Visual Doctrine

Ambitions should feel like a:

```text
Premium calm OS.
```

Visual north star:

```text
Calm intelligent life OS.
```

Visual design must make the app feel organized, trustworthy, intelligent, and easy to act inside. Beauty is not separate from function.

## Top-Level Screen Rules

Top-level screens should avoid:

```text
Equal-weight card walls.
Dense dashboards.
Long paragraphs.
Too many exposed controls.
```

Rules:

- Each top-level screen should have one dominant purpose.
- Hierarchy should make the next useful action visually obvious.
- Information density should increase through drilldown, not top-level clutter.
- Top-level UI should feel calm without becoming empty or boring.

## Rich Panels

Rich panels should be used for:

```text
Meaningful state, hierarchy, and context.
```

Rich panels should not be used for:

- decoration only
- every card by default
- marketing polish without product meaning
- fake depth
- visual noise

Rules:

- Rich panels should clarify state or priority.
- They should help the user understand what matters.
- They should be token/component-backed where possible.
- They should not reduce readability.

## Component And Token Priority

Component priority:

```text
Build reusable components and tokens.
```

Rules:

- Prefer reusable components over one-off beautiful screens.
- Prefer design tokens over hard-coded colors/spacing/radius.
- Components should encode hierarchy, accessibility, state, and motion rules.
- One-off UI is acceptable only when it later becomes a named component or is clearly exceptional.

## Motion

Motion should be:

```text
Subtle and meaningful.
```

Motion should communicate:

```text
Where things went.
What changed.
State transitions.
```

Motion should not be:

- heavy
- ambient decoration
- personality theater
- progress confetti by default
- required to understand state

Rules:

- Use motion to clarify routing, action closure, state transition, and object movement.
- Reduce Motion must preserve equivalent clarity.
- Motion should not distract from primary action.
- Motion should not slow down frequent workflows.

## Celebratory Effects

Celebratory effects should appear:

```text
Rarely, for meaningful completions.
```

Rules:

- Do not celebrate ordinary task churn as if it is a major life win.
- Major goal completion may receive richer visual treatment.
- Completion should feel meaningful, not gamified.
- Avoid confetti as the default celebration language.

## Theme Support

Theme support:

```text
Light and dark mode both matter, with dark preferred if needed.
```

Rules:

- User-visible surfaces should work in light and dark mode.
- Dark mode can be prioritized if tradeoffs are required.
- Accent variants should preserve readability and hierarchy.
- Color must not be the only meaning carrier.

## Readability And Accessibility

Visual design must never:

```text
Reduce readability.
Create fake depth.
Use decoration without meaning.
Hide primary action.
```

Rules:

- Primary action must remain visible and understandable.
- Type hierarchy should support scanning.
- Contrast must support readability.
- Dynamic Type should not destroy the primary interaction.
- VoiceOver should get equivalent state meaning.

## Surface-Specific Visual Guardrails

### Today

- One best next action should be dominant.
- Schedule appears below the main next action.
- Recovery should feel calm and actionable.

### Goals

- One protected/most important goal and portfolio health should dominate top-level Goals.
- Avoid project-management-board appearance at top level.
- Goal Weather must communicate believability/risk/clarity, not decoration.

### Capture

- Capture should feel like a Quiet Command Sheet.
- It should not look like chat, search, notes, or an inbox form.
- Routing receipts should show where things went.

### Plan

- Plan should look plan-first, not calendar-first.
- Believability and overload should be visually clear without alarm clutter.

### You

- You should feel like a personal system center.
- Grouped Navigation Lists should organize settings/trust/memory/reviews/data controls.
- Avoid junk-drawer visual sprawl.

## Visual Anti-Patterns

Stop or redesign if a UI:

- creates an equal-weight card wall
- resembles a dense dashboard
- uses long explanatory paragraphs at top level
- exposes too many controls at once
- hides the primary action
- uses decoration without state meaning
- relies on blur/depth that hurts readability
- creates fake progress or fake precision
- uses motion that does not clarify change
- copies iOS Settings everywhere instead of using the right pattern selectively

## QA Acceptance Criteria

Visual system work is acceptable when:

- The experience feels like a premium calm OS.
- Top-level screens avoid equal-weight card walls, dense dashboards, long paragraphs, and too many exposed controls.
- Rich panels communicate meaningful state, hierarchy, and context.
- Motion is subtle and meaningful.
- Motion communicates where things went, what changed, and state transitions.
- Celebratory effects are rare and reserved for meaningful completions.
- Reusable components and tokens are preferred over one-off screens.
- Light and dark mode both work, with dark preferred if tradeoffs are required.
- Visual design does not reduce readability, create fake depth, use decoration without meaning, or hide primary action.
- Visual north star remains a calm intelligent life OS.

## Open Questions For Future Waves

- Which component set should be named first for Batch execution?
- What exact motion primitives should exist for route, receipt, completion, recovery, and state change?
- How should major goal completion differ visually from ordinary task completion?
- Which surfaces should receive dark-mode polish first if tradeoffs are required?
- Should the visual system define strict density budgets per top-level surface?
