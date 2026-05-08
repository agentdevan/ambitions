# 06 — QA / Preview / Visual Drift

Status: locked direction, pre-visual-example validation, docs-only.

Purpose:

- Visual QA rubric
- preview fixture matrix
- gate matrix
- copy QA
- tab review checklists
- visual drift gallery spec
- council review ritual

Top-level surfaces require 95+ Visual QA.

Today and Capture target 98+.

This document does not implement previews, tests, screenshots, or visual QA artifacts.

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

---

## 2. QA Thesis

Ambitions cannot reach flagship quality through taste claims.

It needs gates, fixtures, screenshots, proof artifacts, pass/fail criteria, Hard Reds, and review rituals.

Green requires evidence. Yellow tracks incomplete proof. Red blocks canon violations.

---

## 3. Visual QA Rubric

Top-level surfaces require **95+** to pass.

Today and Capture target **98+**.

| Category | Points |
| --- | ---: |
| Native iPhone believability | 15 |
| Primary object clarity | 15 |
| Anti-generic resistance | 15 |
| Material discipline | 10 |
| Typography | 8 |
| Color / tint restraint | 8 |
| Accessibility-visible states | 8 |
| Continuity Layer correctness | 8 |
| Motion restraint | 5 |
| Trust / source clarity | 5 |
| Premium composition | 3 |
| Total | 100 |

Acceptance bands:

| Score | Meaning |
| --- | --- |
| 98–100 | flagship exemplar |
| 95–97 | pass for top-level surface |
| 90–94 | strong but not flagship enough |
| 80–89 | substantial maturity gap |
| below 80 | reject |

---

## 4. Hard Red Visual Failures

Immediate rejection if:

- Today looks like task list
- Plan looks like calendar clone
- Goals looks like KPI dashboard or astrology app
- Capture looks like notes feed, inbox, or chatbot
- You looks like social profile or admin console
- Dock shows red badges/counts
- primary object is unclear
- visual state lacks accessible equivalent
- celestial field becomes wallpaper
- generic stacked-card UI dominates
- AI assistant chrome appears
- Continuity signals appear outside Crown, Edge, Dock, Seam

---

## 5. Global Preview Conditions

Every top-level surface requires previews for:

- default state
- empty state
- loading state
- source unavailable
- active state
- trust open
- receipt available
- recovery state
- large Dynamic Type
- accessibility Dynamic Type
- Reduce Motion
- Increase Contrast
- Differentiate Without Color
- small iPhone size
- standard iPhone size
- Pro Max size
- keyboard visible when relevant
- long localized strings

Happy-path-only previews are a maturity failure.

---

## 6. Required Fixture Sets

### Today / Reality Meridian

- TodayEmptyManual
- TodayNowOpenCapacity
- TodayRecommendedStepReady
- TodayActiveStepLive
- TodayNextSoon
- TodayProtectedBlockActive
- TodayPressureSoon
- TodayMissedStillCounts
- TodayBlocked
- TodayWaiting
- TodayNeedsRecovery
- TodayReceiptPlanAdjusted
- TodayTrustWhyThisOpen
- TodayCalendarDeniedManualFallback
- TodayLargeText
- TodayReduceMotion

### Capture / Atmosphere Composer

- CaptureEmptyQuietField
- CaptureTypingKeyboardVisible
- CaptureDictating
- CaptureCapturedLocal
- CaptureClassifying
- CaptureHighConfidenceRoutes
- CaptureNeedsAPlace
- CaptureReadyToPlace
- CaptureGrowIntoGoal
- CaptureSaveError
- CaptureTrustClassificationOpen
- CaptureLargeTextKeyboard
- CaptureReduceMotion

### Time / LifeShape Field

- PlanWeekDefault
- PlanDayPressure
- PlanMonthShaping
- PlanOpenCapacity
- PlanLowCapacity
- PlanProtectedBlocks
- PlanPressureFriday
- PlanCalendarDeniedManual
- PlanSourceConflict
- PlanReflowPreview
- PlanReceiptAdjusted
- PlanLargeText
- PlanReduceMotion

### Goals / Constellation Atlas

- GoalsDefaultLifeAreas
- GoalsNoGoalsYet
- GoalsPinnedArea
- GoalsReorderedAreas
- GoalsHiddenArea
- GoalsSelectedArea
- GoalsOrbitalLensOpen
- GoalsThreadFeedingToday
- GoalsSourceUnavailable
- GoalsLargeText
- GoalsReduceMotion

### You / User System Profile

- YouDefault
- YouManualAutomation
- YouSuggestAutomation
- YouPreviewReflowAutomation
- YouCalendarDenied
- YouCalendarGranted
- YouReceiptArchive
- YouPrivacyControls
- YouLargeText
- YouIncreaseContrast

---

## 7. Fixture Quality Rules

Fixtures must:

- use canon copy
- use canon source labels
- avoid joke/sample filler
- include realistic time/capacity data
- include accessibility labels/summaries
- represent failure and recovery
- include at least one long-string localization stress case
- include trust/receipt states where relevant

Forbidden:

- lorem ipsum
- fake productivity scores
- AI recommends mock copy
- only happy-path previews
- visual-only state fixtures
- cute or joke data

---

## 8. Governance Gate Matrix

| Gate | Purpose | Pass | Hard Red |
| --- | --- | --- | --- |
| Design System Gate | preserve highest canon | no conflict with Design System | lower source overrides canon |
| Native iPhone Gate | preserve believability | safe, familiar, tappable, readable | concept/web/SaaS shell |
| Object Model Gate | preserve Signature Objects | one primary object per surface | generic card pile/dashboard |
| Anti-Generic UI Gate | block drift | not task/calendar/habit/chat/dashboard | generic app pattern dominates |
| Continuity Dock Gate | preserve tab chrome | five tabs, stable icons, calm markers | plus Capture icon, red badges, extra tab |
| Continuity Layer Gate | route signals correctly | signals only in Crown/Edge/Dock/Seam | random badges/banners/feeds |
| Material System Gate | enforce visual substances | locked materials correctly used | ad hoc glass/glow/cards |
| Accessibility Gate | complete nonvisual behavior | object works without visuals | visual-only state |
| Motion Gate | meaningful restrained motion | state/origin clarity | spectacle motion |
| Trust Gate | inspectable intelligence | source/control/receipt | black-box automation |
| Privacy Gate | respectful data posture | fallback + labels | permission required unnecessarily |
| Preview Fixture Gate | complete state coverage | required fixtures exist | happy path only |
| Performance Gate | premium responsiveness | bounded effects | sluggish visual system |
| File Boundary Gate | implementation discipline | layer ownership preserved | giant ad hoc views |
| Release Claim Gate | proof-based status | evidence supports claims | done without proof |

---

## 9. Product Object Acceptance Matrix

| Object | Must prove | Hard Red failure |
| --- | --- | --- |
| Reality Meridian | Now / Next / Later feel inhabited, not listed | generic task list or calendar timeline |
| Start Here Surface | one primary action emerges from active Meridian node | detached card / Begin Focus / AI prompt |
| Constellation Atlas | equal-weight life areas with user order/pin/hide/rename | KPI dashboard, ranked life score, astrology |
| Orbital Lens | selected area focus preserves wider life context | isolated goal dashboard |
| Atmosphere Composer | quiet composer-first capture with route reveal after input | notes feed, inbox, chatbot, category board |
| LifeShape Field | open time, goal time, protected time, pressure are legible | calendar clone or analytics dashboard |
| User System Profile | native settings-like control of planning, trust, privacy | social profile, admin console, hidden trust |
| Continuity Dock | native five-tab nav with calm markers | extra tabs, red badges, Capture plus icon |
| Context Crown | compact orientation, one calm phrase | dashboard header / assistant status |
| Meridian Edge | edge continuity performs state/orientation work | decorative neon border |
| Trust Seam | source, receipt, explanation, control | chatbot drawer / black-box automation |
| Quiet Reflow | mismatch → options → preview → consent → receipt | silent reschedule / shame alert |
| Receipt Surface | calm proof with source/undo/archive | notification feed / achievement badge |
| Object-Origin Transitions | detail emerges from touched object/native pattern | modal from nowhere / dramatic zoom |
| Cross-Object Threads | relationships inspectable across objects | activity feed / visual-only graph |

---

## 10. Copy QA Matrix

Approved global terms:

| Concept | Approved language |
| --- | --- |
| primary recommendation | Recommended step |
| begin action | Start now |
| inspect detail | Open step |
| explain recommendation | Why this? |
| adjust mismatch | Adjust plan |
| partial completion | Still counts |
| proof | Receipt |
| protected time | Protected |
| pressure | Pressure |
| available capacity | Open time |
| goal allocation | Goal time |
| planning action | Shape week |
| pressure review | Review pressure |
| capture input | Capture anything |
| unplaced capture | Needs a Place |
| route-ready capture | Ready to Place |
| goal seed | Grow into Goal |
| trust settings | Automation & Trust |

Hard-ban:

- Begin Focus
- next best move
- best next move
- AI recommends
- AI coach
- crush your goals
- optimize your life
- maximize productivity
- life score
- productivity score
- streak broken
- failed
- overdue
- overdue again
- you missed it
- get back on track
- hustle
- grind
- unlock your potential

State copy examples:

| State | Approved copy | Forbidden copy |
| --- | --- | --- |
| recommendation ready | Recommended step | Best next move |
| start available | Start now | Begin Focus |
| detail required | Open step | Launch task |
| source explanation | Why this? | Ask AI |
| partial completion | Still counts | Incomplete / failed |
| blocked | Blocked for now | Failed |
| waiting | Waiting on a reply | Stalled again |
| recovery | Needs a lighter version | You fell behind |
| plan pressure | Review pressure | Warning / overloaded |
| protected block | Protected | Blocked time |
| receipt | Receipt · Plan adjusted | Alert / notification |
| permission denied | Continue with manual planning | Enable to continue |

---

## 11. Top-Level Tab Review Checklists

### Today

Today passes only if Reality Meridian is dominant, Start Here emerges from active node, Now / Next / Later are understandable, primary action is obvious, Why this? is available when adaptive, closure language is calm, receipts are inspectable, Later is summarized by default, VoiceOver explains state, and Reduced Motion preserves relationships.

Hard Red: Begin Focus appears, overdue/failed language appears, Start Here is detached generic card, or Today is mostly list rows/cards.

### Goals

Goals passes only if Constellation Atlas is primary, life areas are equal-weight by default, user can reorder/pin/hide/rename, selected area opens Orbital Lens, goal threads connect to Today, surrounding areas remain respected, and VoiceOver exposes ordered life areas and states.

Hard Red: system-ranked categories, progress rings dominate, decorative constellations have no meaning, or Goals becomes analytics dashboard.

### Capture

Capture passes only if Atmosphere Composer is primary, composer is bottom-oriented/keyboard-native, empty state is quiet, route reveal appears only after input, low confidence uses Needs a Place, plus action is inside composer context, and VoiceOver can complete capture.

Hard Red: Capture tab icon is plus, empty Capture shows feed/list, AI chat leads, or keyboard covers composer.

### Time

Time passes only if LifeShape Field is primary, Week is default shaping home, Day/Month appear adaptively, open time/goal time/protected time/pressure are legible, pressure opens from field, protected time is respected, reflow previews changes, and VoiceOver summarizes capacity/pressure.

Hard Red: top-level Time is a calendar clone, pressure is red alert system, protected time reads as blockage/failure, or silent reflow occurs.

### You

You passes only if User System Profile is practical and Settings-like, groups are Planning Setup / Account & Preferences / Support System, Automation & Trust and Privacy are visible, permission states are understandable, receipt archive is findable, and VoiceOver follows grouped navigation semantics.

Hard Red: You becomes social profile, trust controls are hidden, privacy controls are vague, or admin dashboard pattern dominates.

---

## 12. Visual Drift Gallery Specification

The Visual Drift Gallery trains designers, Codex, reviewers, and QA to distinguish Ambitions flagship quality from adjacent-but-wrong directions.

Each category needs at least one Pass and one Fail example during visual QA.

| Category | Pass | Fail |
| --- | --- | --- |
| Native shell | familiar iPhone structure with proprietary objects | experimental hidden nav |
| Celestial Field | subtle orientation atmosphere | fantasy space wallpaper |
| Graphite Recess | embedded product surface | stacked SaaS cards |
| Luminous Trace | state/proof/relationship | neon decorative lines |
| Quiet Glass | restrained touch controls | generic glassmorphism |
| Today | Reality Meridian + Start Here | task list/timeline |
| Goals | equal-weight atlas | KPI dashboard / astrology |
| Capture | quiet composer | notes feed / chatbot |
| Time | capacity field | calendar clone / analytics |
| You | premium settings | social profile / admin console |
| Trust | seam/source/receipt | AI assistant drawer |
| Continuity Dock | native five-tab with calm markers | red badges / notification bar |

Drift labels:

- Pass: flagship Ambitions
- Yellow: adjacent drift
- Red: canon violation
- Red: generic productivity
- Red: SaaS/dashboard
- Red: sci-fi/HUD
- Red: decorative celestial
- Red: inaccessible visual state

---

## 13. Council Review Ritual

Always review in this order:

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

Review output format:

```text
Status: Green / Yellow / Red

Canon conflicts:
- ...

P0 issues:
- ...

P1 issues:
- ...

P2 issues:
- ...

Required repairs:
- ...

Proof needed:
- ...

Decision:
- accept / revise / block
```

---

## 14. Required Proof Artifacts By Work Type

| Work type | Proof required |
| --- | --- |
| Design spec | source-truth references, acceptance criteria, anti-patterns |
| SwiftUI implementation | file list, screenshots/previews, tests/checks, accessibility notes |
| Visual update | before/after screenshots, Visual QA score, drift notes |
| Motion update | reduced-motion proof, timing notes |
| Trust/automation | source labels, receipt behavior, undo/recovery path |
| Release claim | passing gates, tests, screenshots, known limitations |

---

## 15. QA Hard Reds

Stop and repair if any are true:

1. Top-level IA conflict.
2. Mission Control top-level.
3. Primary object unclear.
4. Generic dashboard/card stack dominates.
5. Visual-only state.
6. No preview for primary object.
7. No recovery preview.
8. No large text preview.
9. No reduced-motion preview.
10. Continuity signal outside approved surfaces.
11. Trust/automation lacks source or receipt.
12. Completion/release claim lacks proof.

---

## 16. Validation Remaining

Actual visual drift gallery examples, screenshot rubrics, fixture payloads, launch copy QA, and implementation proof remain validation tasks, not canon gaps.
