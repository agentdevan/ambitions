# Ambitions 2.0 Visual System

## Thesis

"Calm shell, rich panels, meaningful visual state."

Ambitions 2.0 uses rich widget-like panels throughout. A panel is a compact product object with state, hierarchy, action, and explanation. It is not a flat text card.

The flagship visual direction is a warm, near-black navy operating canvas with glassy elevated surfaces, restrained amber active accents, muted blue-gray inactive states, and short high-contrast hierarchy. It should feel premium, calm, coherent, intelligent, continuous, operating-system-like, visually grounded, and unlike a generic productivity dashboard.

## Density Rules

- Top-level screens: one dominant hero panel, one or two supporting panels, deeper content below the fold.
- Detail screens: denser panels are allowed when they explain or edit one object.
- Reviews and evidence: dense only after the user has chosen to inspect.
- No top-level screen should become a wall of equal-weight modules.

## Dark Mode Direction

- Flagship mode.
- Warm charcoal / blue-black / near-black navy base.
- The main app canvas must never be pure black and must avoid cold generic midnight blue.
- Subtle blue/violet atmospheric depth is allowed when it supports hierarchy.
- Surfaces use translucent dark fills, tonal lift, faint borders, inner light, subtle gradients, and quiet depth.
- Avoid heavy fake shadows, neon, harsh white-on-black, and flat generic cards.

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
- Amber is the default active accent family for active tabs, primary actions, selected focus state, protected action, and completion warmth.
- Amber must be used sparingly; the shell should not become one-note gold.
- Inactive shell states should prefer muted blue-gray for secondary icons, quiet metadata, and low-emphasis controls.
- Accent color must not carry meaning alone.
- Avoid purple-blue gradient dominance and one-note palettes.

## Global Shell / Chrome Direction

Global chrome is the persistent frame around every screen. It includes status-bar and safe-area backgrounds, global app canvas, top header/navigation bar, logo treatment, page title behavior, Mode Lens pill, notification/back/overflow buttons, bottom tab bar, active/inactive tab states, scroll-edge behavior, sheet/modal headers, shared spacing, panel-to-background relationship, receipt placement, and continuity/status messaging placement.

Global chrome must be token-driven and centralized:

- no hard-coded screen colors
- no one-off tab treatments
- no per-screen shell hacks
- no hidden navigation layers
- no generic toast spam
- no bypass of Appearance Studio
- no bypass of Accessibility Nutrition

Top-level header pattern:

- logo button
- Ambitions title or current screen title
- Mode Lens pill
- notification button

Detail-screen header pattern:

- back button
- centered title
- overflow button
- optional object status pill

Sheet/modal header pattern should reuse the same token, spacing, button, and contrast rules while staying attached to the owning route.

## Shell Invention Visual Treatments

- Mode Lens: compact pill/treatment for Focus, Triage, Plan, Recover, and Review. It changes emphasis, not navigation.
- Continuity Ribbon: thin persistent or contextual strip under the header with one continuity fact; calm, compact, and dismissible where appropriate.
- Action Closure Tray: premium receipt panel/tray after meaningful commands, with what happened, what changed, why, undo where safe, correction, and next action where relevant.
- Save the Day entry: easy to reach from Today, Mode Lens, Continuity Ribbon, or long-press Today tab when implemented; should never feel alarmist when not needed.
- Ambient Status Orb: qualitative state marker, not fake precision. Candidate states: Clear, Steady, Tight, Fragile, At risk, Recovered, Protected.
- Life Graph Breadcrumb: compact detail-screen path only; never clutter top-level screens.
- Mission Control Lanes: object-level lanes for Path, Now, Proof, and Risk in v1; not top-level navigation.
- Not Today / Anti-Plan strip: protective parked-work treatment, not negative or punitive.
- Proof Rail: compact visual rail for artifacts/evidence in Goal Detail, Reviews, and Path Builder.
- Trust Badge / Trust status: small trust treatment for You and Trust Center, surfaced globally only when action is needed.

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

### Receipt Panel

Shows what happened, what changed, why it changed, undo eligibility where safely supported, correction entry, and next action. It is a trust object, not a disposable toast.

### Proof Rail

Shows compact evidence artifacts such as notes, links, files, calendar completions, reflections, photos, milestones, decisions, feedback, and resolved blockers.

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
- Mode Lens, Continuity Ribbon, Action Closure Tray, bottom tabs, top headers, receipt/correction controls, Trust Badge, Ambient Status Orb, and Proof Rail require Dynamic Type, VoiceOver, Reduce Motion, contrast, distinguishability without color alone, and tap-target verification before user-facing claims.

## Appearance Studio Preservation

Appearance Studio remains integral. Dark mode is the flagship identity, light mode remains intentionally supported, and accent/theme customization must not be broken by global chrome work. Shell, panel, tab, header, ribbon, receipt, proof, and trust treatments must flow through centralized design tokens so Appearance Studio can influence them safely.
