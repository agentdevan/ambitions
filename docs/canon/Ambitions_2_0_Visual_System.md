# Ambitions 2.0 Visual System

## Thesis

"Calm shell, rich panels, meaningful visual state."

Ambitions 2.0 uses rich widget-like panels throughout. A panel is a compact product object with state, hierarchy, action, and explanation. It is not a flat text card.

## Density Rules

- Top-level screens: one dominant hero panel, one or two supporting panels, deeper content below the fold.
- Detail screens: denser panels are allowed when they explain or edit one object.
- Reviews and evidence: dense only after the user has chosen to inspect.
- No top-level screen should become a wall of equal-weight modules.

## Dark Mode Direction

- Flagship mode.
- Warm charcoal / blue-black base.
- Avoid pure black, cold midnight, neon, and harsh white-on-black.
- Surfaces use tonal lift, faint borders, and quiet depth.

## Light Mode Direction

- Equal priority to dark mode.
- Warm off-white backgrounds.
- Soft warm neutral surfaces.
- Avoid stark white, gray wireframe, or washed-out contrast.

## Semantic Color Rules

- Success: calm, earned, not loud green.
- Caution: warm and specific, not alert spam.
- Risk: serious and non-punitive.
- Calendar-derived context: distinguishable from Ambitions-created plan data.
- Sync/trust: calm status with text or icon support.
- Accessibility: verified/unverified state must be explicit.

## Accent Color Rules

- One dominant accent per view.
- Accents emphasize primary action, current focus, selected state, or meaningful progress.
- Accent color must not carry meaning alone.
- Avoid purple-blue gradient dominance and one-note palettes.

## Typography, Spacing, And Radius Principles

- Type hierarchy must make the first decision obvious.
- Hero type is reserved for hero panels only.
- Body copy is concise and scannable.
- Use stable spacing rhythm: 4, 8, 12, 16, 20, 24, 32.
- Panels use controlled radius, generally 8-16 points depending on platform component context.
- Avoid bubble-like UI.

## Motion And Haptic Principles

- Motion clarifies state changes, recovery, completion, and route ownership.
- Reduce Motion must have equivalent non-motion state clarity.
- Haptics support meaningful confirmations only.
- Never use motion to compensate for unclear hierarchy.

## Panel Types

### Hero Decision Panel

Dominant top-level panel. Shows the most important truth, one primary action, and one explanation or recovery affordance.

### Progress Panel

Shows progress, pace, confidence, or goal health with visual state and concise context.

### Timeline Panel

Shows ordered events, path stages, plan changes, or review history for detail contexts.

### Schedule Panel

Shows fixed/flexible blocks, open windows, conflicts, and calendar-aware context.

### Insight Panel

Shows contextual decision evidence. It must connect to an action, review, or explanation.

### Recovery Panel

Shows lighter version, reschedule, split, protect later, accept changed reality, or review.

### Trust Panel

Shows source, memory, calendar-derived context, sync/export status, verified/unverified accessibility status, or why-this reasoning.

### Capture Panel

Shows raw capture, triage state, likely destination, and clear route action.

### Review Panel

Shows what happened, what changed, what remains believable, and what follows.

### Settings / Preference Panel

Shows a user-controlled preference with current value, consequence, and verification/trust status where relevant.

## Good Richness vs Bad Richness

Good richness:

- fewer panels with stronger jobs
- meaningful state visuals
- compact explanation
- clear action hierarchy
- warm material depth
- accessibility-preserving contrast

Bad richness:

- decorative gradients
- equal-weight dashboard grids
- nested cards
- dense charts on top-level screens
- motion without meaning
- icon-only ambiguity
- visual effects that reduce readability

## Accessibility Requirements For Panels

- Dynamic Type must preserve hierarchy and avoid clipping.
- VoiceOver labels must summarize panel purpose, state, and primary action.
- Reduce Motion must preserve state change comprehension.
- Contrast must pass in dark and light modes.
- Color must never be the only meaning carrier.
- Tap targets must be comfortable and stable.
- Gestures need button/menu alternatives.
- Panels must avoid cognitive overload through too many simultaneous decisions.
