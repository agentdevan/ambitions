# 14 — Flagship QA And Award-Caliber Bar

Status: active canon, docs-only.

Purpose:

- convert flagship taste into proof requirements
- prevent false Green / false flagship claims
- require visual, accessibility, motion, state, and trust evidence before completion claims

## Core Rule

```text
No flagship claim without visual proof.
```

A surface can be planned, mapped, scaffolded, or partially implemented without screenshots. It cannot be called flagship, visually complete, award-caliber, or 10/10 without rendered preview or screenshot evidence.

## Visual QA Targets

| Surface | Minimum target | Preferred target |
| --- | ---: | ---: |
| Today | 98 | 99+ |
| Goals | 95 | 98 |
| Capture | 98 | 99+ |
| Time | 95 | 98 |
| You | 95 | 98 |
| Shell / Chrome | 95 | 98 |
| Trust / Receipts | 95 | 98 |

A surface below 95 is not flagship. Today and Capture below 98 remain Yellow even if otherwise functional.

## Required Screenshot / Rendered Preview Set

Each top-level surface requires proof for:

1. default state
2. empty state
3. active state
4. recovery state
5. large Dynamic Type
6. Reduce Motion equivalent where motion affects meaning
7. no-calendar/manual mode where relevant
8. source-unavailable mode where relevant
9. trust/receipt state where relevant
10. small iPhone and large iPhone form factors where feasible

Without these, the surface is Yellow for proof even if the implementation compiles.

## Award-Caliber Screenshot Gate

Before any flagship visual completion claim, Today, Goals, Capture, Time, and You screenshots must plausibly stand in a design-award review without a long explanation.

A reviewer should see:

- one dominant object
- native iPhone believability
- no generic app pattern
- clear hierarchy
- restrained premium materials
- meaningful celestial language
- obvious primary action or purpose
- trust/source/receipt clarity where relevant
- no shame, score, badge, or AI chrome

## Three-Second Identity Test

A screenshot fails if a reviewer says any of these within three seconds:

- task app
- calendar app
- notes app
- dashboard
- habit tracker
- chatbot
- SaaS admin
- generic SwiftUI
- sci-fi HUD
- astrology app
- space wallpaper
- settings clone, except You may intentionally use iOS Settings-like grouped navigation

## QA Rubric

| Category | Points |
| --- | ---: |
| Native iPhone believability | 15 |
| One primary object / silhouette | 15 |
| Anti-generic resistance | 15 |
| Visual hierarchy | 10 |
| Material restraint | 8 |
| Copy/human language | 8 |
| Trust/source/receipt clarity | 8 |
| Accessibility-visible states | 8 |
| Motion / Reduce Motion meaning | 6 |
| Emotional job success | 5 |
| Award-caliber memorability | 2 |
| Total | 100 |

Score bands:

- 98-100: flagship exemplar
- 95-97: pass for most top-level surfaces
- 90-94: strong but not flagship enough
- 80-89: substantial maturity gap
- below 80: reject

## Required Gate Tests

### Blur Test

The primary object silhouette must remain identifiable in a blurred screenshot.

### Grayscale Test

State and hierarchy must survive grayscale.

### Text-Removed Test

The screen should still feel like Ambitions when labels are hidden, not a generic template.

### Founder Demo Test

The founder must be able to use the screen to support the Founder Clarity Script.

### Tired User Test

A tired user should understand what matters without feeling judged or overloaded.

### Manual Mode Test

Manual mode must feel first-class, not degraded.

### No-Calendar Test

The app must remain useful without calendar access.

### Trust Before Action Test

Adaptive recommendations must expose Why this?, source, control, and receipt behavior.

### No Compatibility Name Test

Active user-facing UI and active canon must not contain superseded compatibility names except in migration/archive context.

## Accessibility Proof Requirements

A flagship claim requires:

- VoiceOver summary per primary object
- Dynamic Type screenshots or notes
- Reduce Motion equivalent notes
- Increase Contrast notes where material boundaries matter
- Differentiate Without Color notes for state/proof/pressure
- touch target audit
- focus/order notes for sheets and drill-downs
- no visual-only, motion-only, or color-only meaning

Public accessibility conformance cannot be claimed without manual verification evidence.

## Motion Proof Requirements

Every meaningful motion must identify:

- motion grammar type: Emerge, Settle, Trace, Breathe, Reflow, Seal, Dim, Focus, Return, Hold
- product meaning
- fallback when Reduce Motion is enabled
- whether motion is continuous or event-based
- performance risk

Decorative motion is rejected.

## Trust / Receipt Proof Requirements

Every adaptive surface must prove:

- recommendation
- source
- reason
- uncertainty if relevant
- user control
- receipt behavior
- manual fallback

Every meaningful system change must leave a receipt or explicitly explain why no receipt is needed.

## Hard Red QA Failures

Stop and repair if:

1. a screen looks like a generic task/calendar/notes/dashboard/chat/habit app
2. top-level screen is a stack of cards/modules
3. primary object is unclear
4. visual state is color-only, glow-only, or motion-only
5. compatibility names appear as active UI/canon language
6. screenshot proof is absent but visual Green is claimed
7. accessibility is claimed without proof
8. release/readiness/device/performance is claimed without evidence
9. Mission Control becomes top-level
10. Time becomes calendar clone
11. Goals becomes KPI/ranked life score
12. Capture becomes feed/inbox/chat
13. Today becomes task list
14. You becomes social/admin profile

## Final Flagship Completion Conditions

A full flagship UI completion claim requires:

- final IA: Today, Goals, Capture, Time, You
- active canon contains no compatibility names except archive/migration context
- one dominant object per top-level surface
- all five top-level screenshot sets captured or rendered
- each surface scored against the rubric
- Today and Capture score at least 98 or remain Yellow
- accessibility notes complete
- Reduce Motion notes complete
- trust/source/receipt notes complete
- validation commands recorded
- known limitations disclosed
- founder acceptance recorded
- no unresolved Hard Reds
