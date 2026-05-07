# 04 — Trust / Privacy / Automation

Status: locked direction, pre-repo validation, docs-only.

Purpose:

- trust thesis
- forbidden AI/chatbot patterns
- automation levels
- recommendation contract
- source labels
- calendar/privacy posture
- permission states
- receipt lifecycle
- Automation & Trust requirements

Launch automation cap:

1. Manual
2. Suggest
3. Preview Reflow

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

---

## 2. Trust Thesis

Ambitions intelligence is embedded, inspectable, calm, and user-controlled.

It should feel like the system quietly understands the user’s day, goals, capacity, and preferences — not like a chatbot, AI coach, black-box scheduling agent, motivational assistant, or productivity optimizer.

Trust is earned through:

- source labels
- Why this?
- receipts
- preview before meaningful change
- user control
- undo/revert where possible
- permission clarity
- privacy restraint
- calm uncertainty language
- visible Automation & Trust controls

---

## 3. Forbidden Intelligence Patterns

Hard-ban these patterns:

- AI coach persona
- chatbot-first interaction
- AI recommends language
- best next move language
- black-box schedule mutation
- overconfident automation
- motivational productivity language
- hidden scoring
- life/productivity scores
- uninspectable recommendations
- automation without receipt
- permission coercion

Ambitions may be intelligent. It must not perform intelligence.

---

## 4. Automation Levels

| Level | Name | Behavior | Launch allowed |
| --- | --- | --- | --- |
| 0 | Manual | no automation; user controls planning | yes |
| 1 | Suggest | recommendations only; user applies | yes |
| 2 | Preview Reflow | previews adaptation before apply | yes |
| 3 | Approved Defaults | applies user-approved defaults with receipts | later |
| 4 | Guarded Automation | limited automation with source, undo, and receipts | later |

Initial launch cap: **Preview Reflow**.

Manual: no adaptive changes; manual planning remains viable.

Suggest: recommendations only; user explicitly applies; source and Why this? required.

Preview Reflow: proposes adaptation; meaningful change requires preview and consent; receipt required after apply.

Approved Defaults and Guarded Automation are later-only unlocks after trust, privacy, receipts, source labels, controls, and fallback paths are mature.

---

## 5. Recommendation Contract

Every recommendation must expose:

1. recommended action
2. reason
3. source category
4. uncertainty when relevant
5. user control
6. adjustment path
7. receipt after meaningful action

Approved labels:

- Recommended step
- Why this?
- Source
- Receipt
- Adjust plan
- Start now
- Open step

Forbidden:

- AI recommends
- AI coach
- best next move
- optimize your life
- maximize productivity
- black-box automation
- overconfident certainty

A recommendation is mature only if it is specific enough to act on, grounded in a source, visibly controllable, declineable/adjustable, non-shaming, and automation-level compliant.

---

## 6. Source Label Taxonomy

Approved source labels:

| Label | Meaning | Detail exposure |
| --- | --- | --- |
| You entered | user-created goal, step, capture, or setting | show direct object when useful |
| Calendar | calendar availability or conflict | event name only when needed |
| Planning default | user-approved default behavior | show setting path |
| Goal thread | relationship to long-term goal | show goal/life area when useful |
| Recent capture | captured input influenced route/recommendation | show capture title when useful |
| Protected block | user-protected time | show block label when useful |
| Manual adjustment | user previously moved/changed something | show prior action summary |
| Automation setting | approved automation level/default | show setting path |
| Local inference | on-device/local contextual inference | explain conservatively |

Forbidden source labels:

- AI knows
- Smart recommendation
- Optimized by Ambitions
- Best next move engine
- Productivity model
- Life score

---

## 7. Calendar / Schedule Trust Rules

Ambitions is manual-first and fully useful without calendar access.

Calendar access upgrades:

- open capacity accuracy
- pressure detection
- protected time awareness
- conflict-aware reflow
- source-grounded recommendations

Calendar access is not required for:

- Capture
- Goals
- manual Today planning
- manual Plan shaping
- You settings

Calendar-derived recommendations show event names only when needed for user understanding.

Default: Source: Calendar.

Use event name only when it clarifies conflict, pressure, protected time, reflow reason, or user-requested detail.

Permission prompts must appear at moments of obvious value, such as detecting open time, reviewing pressure, enabling schedule-aware recommendations, or opening Schedule & Availability.

Forbidden permission behavior:

- prompt at first launch without context
- blocking basic use
- shaming denial
- implying Ambitions is useless without permission

---

## 8. Permission State Model

| State | User-facing posture | Required fallback |
| --- | --- | --- |
| Not requested | calm invitation only when useful | manual planning |
| Denied | respectful, non-shaming | manual planning + editable defaults |
| Limited | disclose limited view | use visible calendar only |
| Granted | source labels available | adaptive capacity and pressure |
| Stale | explain refresh needed | keep last safe manual state |
| Disconnected | show connection issue | manual fallback |
| Error | explain without blame | retry + manual fallback |
| Needs refresh | route to settings or reconnect | continue without blocking |

Rules:

- Never block Capture because schedule permission is absent.
- Never block Goals because schedule permission is absent.
- Today and Plan gracefully degrade to manual planning.
- Permission denial is normal, not failure tone.

---

## 9. Data Sensitivity Classes

| Class | Examples | UI requirement |
| --- | --- | --- |
| Low sensitivity | display preferences, theme-adjacent settings | normal settings control |
| Personal planning | planning defaults, protected time, availability | source labels + editable controls |
| Life direction | goals, life areas, goal threads | user control, rename/hide/delete |
| Captured thought | raw captures, voice/text input | clear placement, deletion, privacy path |
| Schedule context | calendar availability, event conflicts | permission state + restrained detail |
| Automation history | receipts, applied defaults, reflows | archive + clear/revert where possible |

---

## 10. Receipt Policy

Receipts are calm proof that something meaningful happened.

They are not notifications, achievements, badges, streaks, or feed items.

Receipt required when Ambitions:

- moves a step
- adjusts a plan
- updates calendar/schedule state
- connects a goal thread
- places a capture
- marks Still Counts
- preserves protected time
- changes automation setting
- applies an approved default
- encounters source unavailable state that affects behavior

Every receipt includes:

1. action taken
2. source when relevant
3. affected object
4. timestamp/reference
5. inspect control
6. undo/revert if available
7. archive route when needed

Lifecycle:

- created
- peeked
- opened
- dismissed
- archived
- reverted
- superseded

Retention:

- recent object-local receipts remain visible for 7 days or until superseded, whichever is calmer
- global receipt archive lives in You → Automation & Trust

Receipt detail levels:

| Level | Use |
| --- | --- |
| Compact | seam/proof mark |
| Peek | one-line confirmation |
| Open | source + controls |
| Archive | historical detail in You |

Receipt privacy rule: reveal enough proof to be trusted without overexposing sensitive content.

---

## 11. Automation & Trust Surface

Location:

```text
You → Planning Setup → Automation & Trust
```

Required content:

- current automation level
- recommendation behavior
- Preview Reflow setting
- calendar/source permissions
- approved defaults when available
- receipt history
- source explanations
- privacy controls
- clear/reset history controls where appropriate

Required states:

- Manual
- Suggest
- Preview Reflow
- Calendar not requested
- Calendar denied
- Calendar limited
- Calendar granted
- Calendar stale
- Receipt archive empty
- Receipt archive populated
- Privacy controls available
- Approved defaults unavailable at launch

Accessibility must announce automation level, what the level allows, permission state, source labels, receipt archive status, and destructive clear/reset actions.

---

## 12. Trust Seam Requirements

Trust Seam is the primary chrome-level trust mechanism.

It must support:

- Why this?
- Source
- Receipt
- Still counts
- Moved
- Protected
- Calendar updated
- Goal thread connected
- Plan adjusted
- Automation changed
- Source unavailable
- Needs review

Every adaptive recommendation must route to Trust Seam or an equivalent trusted explanation path.

Trust Seam may not become:

- chatbot drawer
- AI assistant panel
- notification banner
- long prose explanation
- generic alert

---

## 13. Privacy Principles

1. Manual use must be fully supported without calendar access.
2. Calendar access upgrades the experience; it is not required for basic value.
3. Ambitions explains source category before exposing sensitive details.
4. Event names appear only when needed for user understanding.
5. Adaptive behavior must always be inspectable.
6. User-entered goals, captures, and planning defaults are sensitive life-direction data.
7. Automation settings must be easy to find, understand, and change.
8. Meaningful system actions must leave receipts.
9. Deletion, disabling, and permission revocation must have graceful fallback states.
10. Ambitions never frames privacy controls as productivity friction.

---

## 14. User Control Model

Users must be able to:

- decline recommendations
- choose Manual / Suggest / Preview Reflow
- disable calendar-aware behavior
- inspect source labels
- open Why this?
- adjust plans manually
- mark Still Counts
- choose Waiting / Blocked / Needs recovery
- clear or review receipts according to retention policy
- change planning defaults
- revoke permissions without breaking core use

Hard Red if user cannot find trust/automation controls.

---

## 15. Uncertainty Language

Approved:

- This may fit before your next calendar event.
- Calendar source is limited.
- This looks connected to Career.
- Needs a Place.
- Review when ready.

Forbidden:

- Ambitions knows…
- The best choice is…
- You should…
- The AI decided…
- Optimized for you.

---

## 16. Trust Copy Patterns

Approved:

- Recommended because there is 30 minutes open now.
- Source: Calendar.
- Connected to Career goal.
- Moved after a calendar conflict.
- This uses your Planning Default.
- Calendar source unavailable. Manual planning is still available.
- Saved. Needs a Place.
- Protected block preserved.

Forbidden:

- Ambitions AI decided…
- Our model thinks…
- You should…
- The optimal choice is…
- To maximize productivity…

---

## 17. Object-Level Trust Requirements

| Object | Trust requirement |
| --- | --- |
| Reality Meridian | recommended step shows Why this? and source |
| Start Here | source and alternatives available |
| Atmosphere Composer | classification uncertainty shown; routes not overconfident |
| LifeShape Field | pressure/protected/source states inspectable |
| Constellation Atlas | goal-thread recommendations connect to source goal |
| Orbital Lens | selected thread relationship explained |
| User System Profile | automation/privacy/source controls visible |
| Continuity Dock | markers are inspectable, not anxiety badges |
| Trust Seam | owns explanation depth |
| Quiet Reflow | previews source and effect before apply |
| Receipt Surface | proves action and source |

---

## 18. Hard Reds

Stop and repair if any are true:

1. Automation occurs without source label.
2. Meaningful automation occurs without receipt.
3. Launch automation exceeds Preview Reflow.
4. User cannot find Automation & Trust controls.
5. Calendar permission is required for basic product use.
6. Permission denial is treated as failure.
7. Event names are exposed unnecessarily.
8. Recommendation language says AI recommends.
9. Trust explanation becomes chatbot prose.
10. User cannot decline or adjust recommendations.
11. Reflow changes schedule silently at launch.
12. Receipt archive is inaccessible.
13. Privacy settings are vague or hidden.
14. Captures are classified overconfidently.
15. Source labels use vague intelligence branding instead of concrete source categories.
