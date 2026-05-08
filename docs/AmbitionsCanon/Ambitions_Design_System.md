# Ambitions Design System

Status: highest-level source truth.

The Ambitions Design System is the highest-level source of truth for all Ambitions visual, product, interaction, IA, implementation, shell, chrome, behavior, motion, image-generation, and design-system work.

If any prior project instruction, visual reference, prompt, preference, concept, implementation convenience, or generated image conflicts with this Design System, this Design System supersedes it.

Ambitions must always feel:

**native, obvious, useful, elegant, celestial, adaptive, alive, and evolving.**

Ambitions is a premium native iPhone life operating system for turning long-term goals into grounded daily execution. It should feel like a future-complete premium iPhone product, not a generic productivity app, task manager, calendar clone, habit tracker, notes app, chatbot, SaaS dashboard, generic SwiftUI demo, sci-fi HUD, astrology app, or decorative space-themed concept.

Locked taste profile:

- 70% Apple quiet luxury
- 20% OpenAI intelligence
- 10% executive command surface

The interface should be familiar enough to understand instantly, but proprietary enough that it could only belong to Ambitions.

Native, obvious, and useful come before spectacle.

Reject any direction that is beautiful but unclear, celestial but decorative, innovative but not iPhone-native, premium but not useful, or cohesive in a way that flattens the unique identity of Today, Goals, Capture, Time, and You.

---

## 1. Governing Theme

Ambitions should feel:

- native at the shell level
- obvious at the interaction level
- useful at the object level
- elegant at the composition level
- celestial at the atmosphere and continuity level
- adaptive at the state level
- alive at the behavioral level
- evolving at the system level

The product should feel like one living iPhone-native surface where time, goals, planning, capture, and self-setup continuously shape around the user’s real life.

---

## 2. Core Theme Definitions

### Native

Ambitions must feel deeply native to iPhone. Use realistic iPhone proportions, safe-area-aware layouts, familiar bottom tab navigation, native-feeling controls, readable typography, tappable rows, thumb-zone actions, believable iOS spacing, and expected push/sheet/drill-down behavior.

Avoid experimental hidden navigation, sci-fi control schemes, desktop SaaS patterns, web-dashboard layouts, over-customized controls that no longer feel iOS-native, and ornamental UI that sacrifices usability.

The macro shell should feel familiar. The invention should live inside Ambitions-specific objects, not in basic navigation.

### Obvious

A user should immediately understand where they are, what the screen is for, what is currently important, what can be tapped, what happens next, and why the system is suggesting something.

Every top-level screen needs one clear primary object:

- Today: Reality Meridian
- Goals: Constellation Atlas
- Capture: Atmosphere Composer
- Time: LifeShape Field
- You: User System Profile

The interface can be beautiful, but never mysterious.

### Useful

Every visual element must do product work. Celestial details are allowed only when they communicate time, goals, direction, continuity, pressure, capacity, protected time, current state, progress through the day, relationship between a step and a goal, proof that something happened, or where something belongs.

A star, line, glow, orbit, horizon, trace, or constellation cannot be decorative filler.

### Elegant

Ambitions should communicate quality through restraint: fewer objects, better hierarchy, calm spacing, strong alignment, muted color, subtle depth, precise typography, refined linework, low visual noise, and emotionally mature copy.

Avoid crowded surfaces, excessive glow, loud gradients, neon effects, too many panels, stacked cards, dashboard tiles, and decorative overkill.

### Celestial

The celestial language is a system metaphor, not an art style. It should suggest orientation, continuity, time, life shape, long-term direction, calm scale, quiet reflection, and motion through a day, week, and life.

Use dark graphite atmosphere, subtle star grain, faint constellation linework, soft horizon glow when appropriate, restrained blue-white highlights, thin luminous traces, and orbital geometry only when it clarifies relationships.

Avoid fantasy space art, astrology aesthetics, loud galaxies, neon sci-fi HUDs, decorative star clutter, cosmic spectacle, abstract blobs, and space wallpaper that competes with the interface.

### Adaptive

Ambitions should respond to the user’s reality: time of day, current context, available capacity, work/school/free/protected time, pressure, recovery state, goal relevance, schedule changes, incomplete steps, captured input, planning horizon, and user preferences.

Adaptation must be visible, calm, inspectable, and user-controlled through Why this?, receipts, trust seams, and clear state labels.

### Alive

Alive means the system reflects reality. Use current time awareness, active state, soft motion, live context, changing capacity, proof marks, receipts, closure prompts, pressure indicators, protected-time awareness, goal threads, and adaptive surfaces.

Avoid bounce, excessive pulsing, dramatic zooms, particles, parallax gimmicks, sci-fi scanning, and animation without product meaning.

### Evolving

Ambitions should feel like a system that matures with the user through user-defined goal order, pinned life areas, planning defaults, learned preferences, improved schedule fit, richer receipts, better recommendations, calmer recovery support, trust calibration, and clearer life-shape awareness.

Avoid gamification, streak obsession, productivity scores, manipulative habit mechanics, and fake personalization.

---

## 3. Signature Interface Architecture

Ambitions is a governed Signature Interface System, not a generic primitive library alone.

Required architecture:

1. Design Tokens
2. Materials
3. Primitive Views
4. Compound Controls
5. Signature Objects
6. Top-Level Surfaces
7. Shell / Chrome Contract
8. Ambitions Continuity Layer
9. Governance Gates

Primitives provide consistency. Signature Objects are the product.

Top-level surfaces are thin compositions:

```text
TodayScreen = AmbitionsShell + RealityMeridian + StartHereSurface
GoalsScreen = AmbitionsShell + ConstellationAtlas + OrbitalLens
CaptureScreen = AmbitionsShell + AtmosphereComposer
TimeScreen = AmbitionsShell + LifeShapeField
YouScreen = AmbitionsShell + UserSystemProfile
```

---

## 4. Ambitions Continuity Layer

The Ambitions Continuity Layer is the canonical chrome and behavior model. It makes Today, Goals, Capture, Time, and You feel like one native, evolving life operating system.

It consists of:

- Context Crown
- Meridian Edge
- Living Continuity Dock
- Trust Seam
- Object-Origin Transitions
- Quiet Reflow
- Ambient State Tint
- Receipt-First Automation
- Cross-Object Threads

It is not a toolbar, tab bar treatment, widget layer, AI assistant, dashboard, status feed, notification system, or decorative overlay.

Continuity signals may appear only in Context Crown, Meridian Edge, Continuity Dock, and Trust Seam.

---

## 5. Final Interface Family Model

Ambitions has five top-level destinations only:

- Today
- Goals
- Capture
- Time
- You

Each tab owns one primary object.

### Today — Reality Meridian

Today is the live execution surface. It shows what fits now, what comes next, what remains later, and what still counts. The Reality Meridian is dominant. Start Here emerges from the active time state and must never become a detached generic card.

Approved language includes Start here, Recommended step, Start now, Open step, Adjust plan, Why this?, Still counts, and Receipt.

### Goals — Constellation Atlas

Goals is the life-area atlas. It shows all goal categories at once, equally weighted, with drillable depth. The user may reorder, pin, hide, and rename life areas. Avoid KPI dashboards, ranking systems, habit rings, progress scores, and astrology patterns.

Default life areas:

- Music
- Fitness
- Money
- Relationships
- Career
- Health
- Learning
- Home
- Creative
- Personal Growth

### Capture — Atmosphere Composer

Capture is the quiet intake surface. It is composer-first, bottom-oriented, keyboard-native, and quiet enough for thought to arrive. Route reveal appears after input.

Allowed route labels:

- Needs a Place
- Ready to Place
- Grow into Goal

The Capture tab icon is not a plus. The plus belongs to the composer action.

### Time — LifeShape Field

Time is the capacity-shaping surface. It reveals open time, goal time, protected time, pressure, and horizon structure without becoming a calendar clone.

Use Day / Week / Month, Open time, Goal time, Protected, Pressure, Shape week, and Review pressure.

### You — User System Profile

You is the practical, familiar, iOS Settings-like control center. The profile header is static. Do not add social profile emphasis, family layer, search-first UI, or admin-console behavior by default.

Locked structure:

Planning Setup:

- Schedule & Availability
- Planning Defaults
- Vacation / Away Time
- Automation & Trust

Account & Preferences:

- Notifications
- Capture Preferences
- Focus & Session Defaults
- Privacy

Support / System:

- Help
- About Ambitions

---

## 6. Materials

Ambitions uses four locked materials:

1. Celestial Field — atmospheric operating surface
2. Graphite Recess — embedded surface, seam, grouped setting
3. Luminous Trace — state, proof, continuity, relationship
4. Quiet Glass — restrained touch control material

Every material must do product work.

---

## 7. Typography

Ambitions uses two voices:

- Native Sans for controls, rows, metadata, body text, CTAs, explanations, receipts, tab labels, operational UI, Context Crown, Trust Seam, and Quiet Reflow.
- Editorial Serif sparingly for meaning moments: Capture hero phrase, selected Goal category title, Time title/date range, and reflective life-scale moments.

Rule: Sans is for control. Serif is for meaning.

---

## 8. Color System

The system should be mostly graphite, soft black, mist gray, cloud white, and restrained blue-white. Ambitions Blue is used only for active state, selected tab, focused input, current node, and primary interaction.

Ambient State Tint must remain restrained. It may touch active dock icons, trace nodes, selected object points, proof marks, CTA edges, Context Crown micro-state, and Trust Seam markers only.

Never let color turn Ambitions into a bright dashboard.

---

## 9. Intelligence and Trust

Ambitions intelligence should be embedded, not announced.

Use Why this?, receipts, proof marks, trust seams, source labels, calm explanations, editable defaults, and visible automation settings.

Avoid AI coach persona, chatbot framing, AI recommends, black-box decisions, overconfident automation, and motivational productivity language.

---

## 10. Closure and Recovery

Ambitions should never shame the user.

Supported closure states:

- Completed
- Still Counts
- Moved
- Skipped / Not Needed
- Blocked
- Waiting
- Needs Recovery
- Needs Review

Avoid failed, overdue again, you missed it, productivity dropped, and streak broken.

---

## 11. Motion and Living State

Motion should make the system feel alive, not flashy. It must orient, confirm, or reduce uncertainty.

Use soft active-node breathing, subtle line drawing, calm surface expansion, receipt seams, LifeShape morphing, constellation focus transitions, composer rise with keyboard, native pushes/sheets, Object-Origin Transitions, Ambient State Tint shifts, and Quiet Reflow previews.

Reduced Motion equivalents are mandatory.

---

## 12. Anti-Drift Rules

Ambitions must not drift into a generic productivity app, task manager, calendar clone, habit tracker, notes app, chatbot, KPI dashboard, SaaS admin panel, generic SwiftUI demo, wireframe, astrology app, fantasy space art, neon sci-fi HUD, stack of rounded cards, dashboard-first layout, badge-heavy notification system, AI assistant chrome, or status feed.

If a design starts to look impressive but becomes less native, less obvious, or less useful, reject it.

---

## 13. Flagship Quality Gate

Every Ambitions concept, response, prompt, design critique, implementation plan, visual, or component must pass:

1. Does it feel native to iPhone?
2. Is the purpose immediately obvious?
3. Does every visual element do useful product work?
4. Is the composition elegant and restrained?
5. Is the celestial layer subtle, meaningful, and premium?
6. Does the screen adapt to user context or state?
7. Does it feel alive through real system awareness?
8. Does it feel like it can evolve with the user over time?
9. Does it preserve the correct Ambitions object model?
10. Does it avoid generic productivity, dashboard, calendar, habit, notes, chatbot, and sci-fi patterns?
11. Does it follow the Signature Interface Architecture?
12. Does it use visual references correctly as anchors, not literal canon?
13. Does it use the Ambitions Continuity Layer for chrome and behavior?
14. Does it avoid generic chrome, badge-heavy notifications, AI assistant framing, and status-feed behavior?

The final Ambitions theme:

Native enough to trust. Obvious enough to use immediately. Useful enough to matter daily. Elegant enough to feel premium. Celestial enough to feel oriented. Adaptive enough to fit real life. Alive enough to feel current. Evolving enough to become personal.
