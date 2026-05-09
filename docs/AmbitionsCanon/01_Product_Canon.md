# 01 — Product Canon

Status: locked product canon, docs-only.

Purpose:

- product thesis
- source-truth priority
- taste profile
- locked top-level IA
- primary object model
- Signature Interface Architecture
- anti-drift rules
- launch scope
- non-goals
- Hard Red stop conditions

This document does not implement app behavior.

---

## 1. Source-Truth Priority

1. Ambitions Design System
2. Canon Index / 10-10 Maturity Gate
3. Product Canon
4. Continuity Layer & Chrome
5. Signature Object Specs
6. Trust / Privacy / Automation
7. Accessibility / Motion / Performance
8. QA / Preview / Visual Drift
9. Native Shell / Tokens / Materials
10. Implementation / Codex / Repo Integration
11. Visual references
12. Existing repo convenience

Implementation convenience never overrides product identity.

---

## 2. Locked Product Thesis

Ambitions is a premium native iPhone life operating system for turning long-term goals into grounded daily execution.

It must always feel:

- native
- obvious
- useful
- elegant
- celestial
- adaptive
- alive
- evolving

The product should feel like one living iPhone-native surface where time, goals, planning, capture, and self-setup continuously shape around the user’s real life.

---

## 3. Locked Taste Profile

Ambitions uses the locked taste profile:

- 70% Apple quiet luxury
- 20% OpenAI intelligence
- 10% executive command surface

Interpretation:

- Apple quiet luxury: native shell, restraint, spacing, legibility, confidence, polished interaction.
- OpenAI intelligence: adaptive, inspectable, calm, source-aware, never chatbot-first.
- Executive command surface: powerful orientation and control, never dashboard/SaaS/admin UI.

Native, obvious, and useful come before spectacle.

---

## 4. Locked Top-Level IA

Ambitions has exactly five top-level tabs:

1. Today
2. Goals
3. Capture
4. Plan
5. You

No other top-level tabs are allowed.

Hard Red top-level IA violations:

- Mission Control as top-level tab
- Dashboard as top-level tab
- Calendar as top-level tab
- Assistant as top-level tab
- Inbox as top-level tab
- Settings replacing You as top-level label
- Any sixth destination in the primary tab bar

Mission Control, if present, belongs inside Goal Detail only.

---

## 5. Locked Primary Object Model

| Tab | Primary object | Related object |
| --- | --- | --- |
| Today | Reality Meridian | Start Here Surface |
| Goals | Constellation Atlas | Orbital Lens |
| Capture | Atmosphere Composer | route reveal after input |
| Plan | LifeShape Field | scope control + shaping actions |
| You | User System Profile | Automation & Trust / Privacy controls |

Required composition model:

```text
TodayScreen = AmbitionsShell + RealityMeridian + StartHereSurface
GoalsScreen = AmbitionsShell + ConstellationAtlas + OrbitalLens
CaptureScreen = AmbitionsShell + AtmosphereComposer
PlanScreen = AmbitionsShell + LifeShapeField
YouScreen = AmbitionsShell + UserSystemProfile
```

Top-level screens must be thin compositions around these objects. They must not become ad hoc piles of views.

---

## 6. Signature Interface Architecture

Ambitions is implemented as a governed Signature Interface System:

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

A primitive-only component library is insufficient and is a maturity failure.

---

## 7. Locked Materials

Ambitions uses four primary materials:

1. Celestial Field
2. Graphite Recess
3. Luminous Trace
4. Quiet Glass

| Material | Role |
| --- | --- |
| Celestial Field | atmospheric operating surface |
| Graphite Recess | embedded product surface / seam / grouped setting |
| Luminous Trace | state, proof, continuity, relationship |
| Quiet Glass | restrained touch control material |

Hard Red material failures:

- fantasy space wallpaper
- generic glassmorphism
- neon HUD trace
- stacked SaaS cards
- decorative celestial elements with no product work

---

## 8. Locked Continuity Layer

The Ambitions Continuity Layer is the canonical chrome and behavior system.

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

Continuity signals may appear only in:

1. Context Crown
2. Meridian Edge
3. Continuity Dock
4. Trust Seam

Forbidden continuity patterns:

- random badges
- red notification counts
- banners
- alert feeds
- assistant bubbles
- status chips outside approved surfaces
- notification-center behavior
- generic dashboard widgets

---

## 9. Locked Council Decisions

### Token Philosophy

Hybrid token canon:

- semantic token names lock immediately
- exact core values become canon after visual QA validation
- expressive atmospheric values use bounded ranges until validated

### Today Object Structure

Reality Meridian is the primary Today object. Start Here is the action surface emerging from the active Meridian node. Start Here must never become a detached generic card.

### Continuity Signal Strictness

Continuity signals appear only in Context Crown, Meridian Edge, Continuity Dock, and Trust Seam.

### Automation Launch Posture

Launch automation is capped at:

- Manual
- Suggest
- Preview Reflow

Approved Defaults and Guarded Automation are later unlocks only after trust, receipts, undo, privacy, and source labeling are mature.

### Calendar / Schedule Dependency

Ambitions is fully usable manually. Calendar access upgrades the experience. Calendar permission is not required for basic product value.

### Visual QA Standard

Top-level surfaces require 95+ to pass. Today and Capture target 98+.

### Accessibility Strictness

Full object-level nonvisual equivalence is required. No Signature Object is complete until it works without visual interpretation.

---

## 10. Locked Life Area Defaults

Goals default life areas:

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

User may reorder, pin, hide, and rename.

Ambitions must never imply system-ranked life priorities.

---

## 11. Locked You Structure

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

Forbidden by default:

- social profile
- family layer
- search-first UI
- admin console pattern
- AI assistant settings wall

---

## 12. Locked Plan Default

Plan opens to Week by default.

Adaptive openings:

- Day when immediate execution pressure is highest
- Month for higher-level shaping

Time must not become a calendar clone in active flagship canon.

---

## 13. Locked Receipt Retention

Recent object-local receipts remain visible for:

- 7 days, or
- until superseded,

whichever is calmer.

Global receipt archive lives in:

```text
You → Automation & Trust
```

Receipt archive remains until cleared by the user or governed by the privacy retention policy.

---

## 14. Locked Capture Classification

Capture route reveal follows confidence:

- high confidence: route choices may appear immediately
- low confidence: receipt-first with Needs a Place

Allowed route labels:

- Needs a Place
- Ready to Place
- Grow into Goal

Capture must remain quiet and composer-driven.

---

## 15. Launch Product Thesis

Launch Ambitions should prove:

1. Today can turn life direction into grounded daily action.
2. Capture can accept anything quietly and route it without pressure.
3. Time can reveal capacity without becoming a calendar clone.
4. Goals can hold life areas without ranking or gamifying the user.
5. You can make trust, privacy, planning defaults, and automation inspectable.

A flagship product does not need every future capability at launch. It needs a coherent, polished, governed launch scope.

---

## 16. Launch Must-Haves

| Area | Must-have |
| --- | --- |
| IA | Today, Goals, Capture, Time, You only |
| Today | Reality Meridian + Start Here relationship |
| Capture | Atmosphere Composer composer-first flow |
| Plan | LifeShape Field with Week default |
| Goals | Constellation Atlas with default life areas and user control |
| You | Automation & Trust, Privacy, Planning Defaults |
| Trust | Why this?, source labels, receipts |
| Accessibility | object-level summaries for all primary surfaces |
| Motion | reduced-motion equivalents |
| QA | visual gate + preview matrix |

---

## 17. Explicit Launch Non-Goals

Not launch scope:

- chatbot interface
- AI coach persona
- social/family profile
- team collaboration
- web dashboard
- desktop admin view
- gamified streaks
- habit rings as primary model
- productivity score
- life score
- full automatic scheduling agent
- public sharing
- marketplace/templates
- complex analytics dashboards
- top-level Mission Control tab
- top-level calendar tab
- top-level assistant tab

---

## 18. Anti-Drift Rules

Reject any direction that makes Ambitions resemble:

- generic productivity app
- task manager
- calendar clone
- habit tracker
- notes app
- chatbot
- KPI dashboard
- SaaS admin panel
- generic SwiftUI demo
- wireframe
- astrology app
- fantasy space art
- neon sci-fi HUD
- stack of rounded cards
- overdecorated concept UI
- dashboard-first layout
- habit-ring product
- badge-heavy notification system
- AI assistant chrome
- status feed

Native, obvious, and useful come before spectacle.

---

## 19. Hard Red Stop Conditions

Stop and repair if any are true:

1. Top-level IA contradiction.
2. Mission Control promoted to top-level tab.
3. Capture becomes feed, inbox, chat, category grid, or task board.
4. Today becomes generic task list or calendar timeline.
5. Time becomes calendar clone.
6. Goals becomes KPI dashboard, habit tracker, astrology, or ranked life score.
7. You becomes social profile or admin console.
8. Continuity signals appear outside Crown, Edge, Dock, Seam.
9. Trust becomes chatbot/AI coach.
10. Automation lacks source, control, receipt, or recovery path.
11. Primary object depends on visual-only meaning.
12. Reduced Motion removes essential meaning.
13. Design solves with decoration instead of product structure.
14. Completion/release claims lack proof.

---

## 20. Product Council Review Order

1. Canon conflict
2. Native iPhone believability
3. Primary object clarity
4. Anti-generic drift
5. Accessibility and nonvisual meaning
6. Trust/source/control
7. Motion/reduced-motion
8. Materials/tokens
9. Performance risk
10. Preview/test proof
11. Release-claim safety

Do not start with aesthetics. Start with canon.
