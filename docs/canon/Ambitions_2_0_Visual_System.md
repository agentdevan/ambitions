# Ambitions 2.0 Visual System

## Thesis

"Calm shell, rich panels, meaningful visual state."

The active master product and visual direction is [Ambitions_Master_Product_Visual_System_Spec_v2.md](Ambitions_Master_Product_Visual_System_Spec_v2.md). Its visual/product thesis is that Ambitions is a premium iPhone-native life operating system built from adaptive panels, timeline rails, grounded time context, receipts, proof, and Action Closure.

Ambitions 2.0 uses rich widget-like panels throughout. A panel is a compact product object with state, hierarchy, action, and explanation. It is not a flat text card.

The active design source of truth is [design/Ambitions_Design_Constitution.md](design/Ambitions_Design_Constitution.md). Supporting contracts live in [design/component-contract-matrix.md](design/component-contract-matrix.md), [design/panel-density-size-spec.md](design/panel-density-size-spec.md), and [design/grouped-navigation-list-spec.md](design/grouped-navigation-list-spec.md).

The flagship visual direction is a warm, near-black navy operating canvas with glassy elevated surfaces, restrained amber active accents, muted blue-gray inactive states, and short high-contrast hierarchy. It should feel premium, calm, coherent, intelligent, continuous, operating-system-like, visually grounded, and unlike a generic productivity dashboard.

## Display Density And Panel Size

Display Density:

- Minimal.
- Balanced.
- Detailed.

Panel Size:

- Compact.
- Comfortable.
- Large.

Default: Balanced + Comfortable.

Density controls how much information appears. Size controls how large the same information feels. Large panels show fewer things at once. Compact panels must not become cramped. Large panels must not feel like stretched UI.

Hero panels are anchored. Critical panels cannot fully hide. Supporting panels can reorder only within safe zones. Noncritical panels can hide. Critical panels collapse into a signal, ribbon, badge, or required state. Modularity must not become dashboard-builder behavior.

## Density Rules

- Top-level screens: one dominant hero panel, one or two supporting panels, deeper content below the fold.
- Detail screens: denser panels are allowed when they explain or edit one object.
- Reviews and evidence: dense only after the user has chosen to inspect.
- No top-level screen should become a wall of equal-weight modules.
- Goals, Plan, and Today must prioritize current goal direction, Next Visible Step, current plan window, proof of momentum, risk/blocker clarity, timeline context, and archive/learning in that order.
- Task-board density belongs only inside Goal Detail as a Kanban-lite Task Lane; the app must never visually present itself as a generic task manager.

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
- no excessive blur stacking
- no expensive animations on every scroll

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
- Goal Lifecycle Rail: premium horizontal rail on Goals overview for Previous -> Active -> Future, with calm lifecycle labels and small counts. It should feel like a life timeline, not a segmented control.
- Goal Atlas: visual relationship map for goals. It begins as a compact preview, appears as connected goals in Goal Detail, expands in Path Builder, and matures in Portfolio Manager.
- Not Today / Anti-Plan strip: protective parked-work treatment, not negative or punitive.
- Proof Rail: compact visual rail for artifacts/evidence in Goal Detail, Reviews, and Path Builder.
- Proof Spine: vertical, elegant, receipt-like Proof Rail expression for one goal. It should show accumulated proof without becoming a streak or gamified productivity mechanic.
- Goal Weather: restrained, sophisticated visual signal for Clear, Cloudy, Stormy, Foggy, and Protected goal conditions. Avoid childish weather graphics; every state needs drilldown explanation.
- Decision Trail: editorial, journal-like, high-trust record of why a goal or plan changed. It should make changed plans feel intelligent, not shameful.
- Milestone Cards: spacious, scannable goal checkpoints with title, status, next action, proof count, and blockers, with details kept in drilldown.
- Kanban-lite Task Lane: restrained Goal Detail-only task lane for Later, Next, Doing, Waiting, and Done. Never make it the app's top-level identity.
- Weekly Plan Strip: calm seven-day visual strip showing how active goals become real this week, including buffer, rest, or recovery where appropriate.
- Completion Archive: premium archive treatment for completed, cancelled, dropped, parked, merged, or transformed goals. It is not a trash bin.
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
- Motion explains state change first, premium feel second, and delight only when earned.
- Future feature batches must set performance budgets for motion and visual richness.
- Smart Attachment motion communicates where the item went, not AI thinking or magic.
- Plan Reflow motion communicates cause, result, and deadline impact.

## Panel Types

### Hero Decision Panel

Dominant top-level panel. Shows the most important truth, one primary action, and one explanation or recovery affordance.

### Progress Panel

Shows progress, pace, confidence, or goal health with visual state and concise context.

### Timeline Panel

Shows ordered events, path stages, plan changes, or review history for detail contexts.

### Goal Lifecycle Rail

Shows Previous, Active, Future, and supporting state chips for Protected, Waiting, Blocked, Parked, Completed, and Cancelled / Dropped goals. It is a premium timeline treatment, not a dense analytics control.

### Goal Weather

Shows a qualitative goal-health signal: Clear when momentum is healthy, Cloudy when progress exists but the next step is vague, Stormy when risks/blockers/abandoned tasks are too high, Foggy when clarity or proof is missing, and Protected when the goal needs defense from distraction.

### Proof Spine

Shows accumulated proof vertically for a single goal, including actions, artifacts, feedback, decisions, resolved blockers, and reflections. It is the visual timeline expression of Proof Rail.

### Decision Trail

Shows why the path changed, including started, paused, resumed, cancelled, completed, merged, replaced, or parked decisions. It should preserve learning and dignity around cancelled or dropped goals.

### Milestone Cards

Show meaningful checkpoints before task detail. Each card may summarize tasks, notes, proof, blockers, deadlines, assumptions, risks, and decision notes without exposing an endless task list.

### Weekly Plan Strip

Shows the seven-day expression of the active plan window. It should make the week feel calm and possible, not overloaded.

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

### Today Plan Panel

Shows the planned day beyond the current step: planned items, compact timeline, open-window/free-busy awareness, and recovery signals.

### Life Areas Panel

Shows Life Areas as a primary organization lens inside Goals and You, including connected North Stars, goals, proof, decisions, and reviews. It must not imply a sixth tab.

### One-Step Goals Panel

Shows standalone Tasks without turning them into a top-level Tasks tab. It supports complete, attach to Goal, promote to Goal, convert to Ritual, and receipt-backed demotion from Goal where appropriate.

### Proof Rail

Shows compact evidence artifacts such as notes, links, files, calendar completions, reflections, photos, milestones, decisions, feedback, and resolved blockers.

### Completion Archive

Shows completed, cancelled intentionally, parked for later, replaced by better goal, merged into larger goal, or no-longer-relevant goals as learning artifacts with what happened, why it ended, proof collected, what replaced it, decision trail, and final status.

### Capture Panel

Shows raw capture, triage state, likely destination, and clear route action.

### Review Panel

Shows what happened, what changed, what remains believable, and what follows.

### Settings / Preference Panel

Shows a user-controlled preference with current value, consequence, and verification/trust status where relevant.

### GroupedNavigationList

Official categorized navigation/settings/depth pattern. It contains Navigation Sections, Navigation Rows, Disclosure Navigation Rows, Preference Rows, Status Navigation Rows, and Destructive Action Rows. It is used heavily in You and selectively in Goal Detail, Plan, Capture, Trust Center, Memory, and Settings. It is not the primary execution UI.

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
- Panel Size and Display Density combinations must be tested before claims.
- Mode Lens, Continuity Ribbon, Action Closure Tray, bottom tabs, top headers, receipt/correction controls, Trust Badge, Ambient Status Orb, and Proof Rail require Dynamic Type, VoiceOver, Reduce Motion, contrast, distinguishability without color alone, and tap-target verification before user-facing claims.

## Performance Expectations

Visual richness must stay fast. Future rich-panel, chrome, external-surface, and mature-invention batches must set a performance budget and avoid repeated duplicate calculations when shared projections exist.

Guidance:

- top-level first meaningful content should remain fast on supported devices
- content-heavy scrolling should remain smooth
- widgets and Live Activities should consume lightweight snapshots
- rich panel effects should degrade gracefully under Reduce Motion or lower performance conditions
- large graph, ledger, proof, and trust queries should not recompute the whole world on every render
- motion must clarify state and must not be required to understand state
- Semantic Zoom must provide accessible list fallbacks and bounded rendering before it is used for Goals, Life Areas, North Stars, or Path Builder.
- Safe-zone modularity must be validated across Display Density and Panel Size variants before user-facing customization claims.
- Notification and external-surface visual treatments must preserve privacy defaults and concise operational wording.

## Appearance Studio Preservation

Appearance Studio remains integral. Dark mode is the flagship identity, light mode remains intentionally supported, and accent/theme customization must not be broken by global chrome work. Shell, panel, tab, header, ribbon, receipt, proof, and trust treatments must flow through centralized design tokens so Appearance Studio can influence them safely.

Appearance Studio may control accent color, light/dark/system appearance, contrast preference, motion preference, future panel density, active tab treatment through tokens, and header/chrome treatment through tokens. It must not break accessibility, contrast minimums, tab IA, semantic state clarity, product identity, reduced motion, core shell readability, or trust/safety states.
