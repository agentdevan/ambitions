# Ambitions Accessibility And Focus Support

Status: Active canon consolidation layer.

Purpose: Consolidate accessibility, Focus Support, Dynamic Type, VoiceOver, color meaning, Reduce Motion, attention/executive-function support, and anti-infantilization rules into one implementation-readable reference. This document reflects Wave 13 product decisions.

## Core Accessibility Doctrine

Accessibility means:

```text
Core product quality.
```

Accessibility is not:

- compliance only
- optional polish
- a late launch pass
- limited to settings

Accessibility north star:

```text
Anyone can understand what matters next.
```

Rules:

- Accessibility must support comprehension, action, trust, and recovery.
- Accessibility belongs in every user-visible surface.
- Accessibility work must preserve the app's depth while improving clarity.

## Focus Support Naming

User-facing name:

```text
Focus Support
```

Avoid user-facing labels such as:

- ADHD Mode
- Neurodivergent Mode
- training wheels
- simplified mode
- disabled mode

Rules:

- Do not label the user.
- Do not make users disclose or identify with a diagnosis to get better clarity.
- Focus Support should feel like premium product intelligence, not remediation.

## Focus Support Purpose

Focus Support should primarily:

```text
Reduce decisions and protect next action clarity.
```

Focus Support should not primarily:

- make everything simple
- hide features
- add more reminders
- add gamification
- remove depth

Rules:

- Reduce decision load without removing capability.
- Preserve deep drilldowns.
- Keep the next useful action clear.
- Use recovery rather than shame.

## Attention / Executive-Function Guardrails

Ambitions should avoid:

```text
Card overload.
Shame language.
Unclear next action.
Dense dashboards.
```

Rules:

- Top-level screens should avoid equal-weight card walls.
- Today should prioritize one best next action.
- Goals should protect direction before exposing project-management detail.
- Plan should show whether the week can hold without becoming a calendar clone.
- You should not become a junk drawer.

## Dynamic Type

Dynamic Type is a:

```text
Core requirement.
```

Rules:

- Dynamic Type must be considered for core UI, not only settings.
- Larger text should not hide the primary action.
- Layouts should adapt before truncating important meaning.
- Dense surfaces should have drilldown/fallback behavior.

## VoiceOver

VoiceOver is a:

```text
Core requirement.
```

Rules:

- Interactive controls need clear labels, traits, and hints where useful.
- Status rows should expose state and value.
- Complex visual state such as Goal Weather, Plan believability, Now State, and receipts need equivalent spoken meaning.
- Route receipts should say what changed and where the item went.
- Grouped Navigation Lists should be navigable and understandable.

## Color Meaning

Color-only meaning:

```text
Never use color as the only meaning carrier.
```

Rules:

- Use labels, icons, shape, copy, or position alongside color.
- Goal Weather, Plan states, proof states, and sensitive/private indicators must remain understandable without color.
- Charts/patterns must not rely only on color.

## Reduce Motion

Reduce Motion should:

```text
Preserve meaning.
```

Rules:

- Motion is allowed when subtle and meaningful.
- Reduce Motion must provide equivalent static clarity.
- Motion should communicate where things went, what changed, or state transitions.
- If motion is disabled, receipts/copy/static transitions should carry the same meaning.

## Focus Support Must Never

Focus Support must never:

```text
Infantilize.
Remove depth.
Label the user.
Turn the app into training wheels.
```

Additional red flags:

- user-facing `ADHD Mode`
- making the app shallow instead of clearer
- hiding important capability without a path to access it
- using childish language or visuals
- replacing clarity with gamification

## Surface-Specific Requirements

### Today

- One best next action first.
- Full schedule below the main action.
- `Save the Day` recovery when the day breaks.
- Sensitive/private items collapse as `Private item`.

### Goals

- Protect direction before task detail.
- Goal Weather must have non-color meaning.
- Missing next step should ask/suggest rather than warn only.

### Capture

- Quiet Command Sheet should remain easy to understand with VoiceOver.
- Save failure preserves input.
- Needs a Place must be clear as a temporary holding area.

### Plan

- Believability states must not rely only on color.
- Calendar-aware planning must work manually without permission.
- Overload recovery should ask what to protect.

### You

- Grouped Navigation Lists should support screen-reader navigation.
- Trust, memory, reviews, and settings should not become a junk drawer.
- Appearance Studio should be accessible and reversible where meaningful.

## QA Acceptance Criteria

Accessibility / Focus Support is acceptable when:

- Accessibility is treated as core product quality.
- User-facing focus language is `Focus Support`.
- Focus Support reduces decisions and protects next-action clarity.
- The app avoids card overload, shame language, unclear next action, and dense dashboards.
- Dynamic Type is supported as a core requirement.
- VoiceOver is supported as a core requirement.
- Color is never the only meaning carrier.
- Reduce Motion preserves meaning.
- Focus Support does not infantilize, remove depth, label the user, or turn the app into training wheels.
- Anyone can understand what matters next.

## Open Questions For Future Waves

- Which Focus Support controls should ship first?
- Should Focus Support be an explicit setting or an invisible product-wide standard?
- What minimum Dynamic Type sizes are required for launch acceptance?
- Which complex states need custom VoiceOver summaries first?
- Should Accessibility Nutrition Labels be updated per focused canon doc?
