> Supporting note: This file supports Ambitions anti-card governance. It does not override `docs/truth/*`, live source, current validation logs, or release proof.

# Ambitions No-Card Replacement Taxonomy

Status: Active supporting governance
Scope: Classification and replacement guidance for UI structures that risk generic pile-of-panels behavior
Owner posture: Taxonomy, not source proof

## Purpose

Ambitions must not drift into a generic stack of rounded panels. This taxonomy gives Codex a shared language for identifying card-like UI and selecting object-first replacements.

## What Is Banned At Top Level

Top-level surfaces must not be structured as:

- Equal-weight vertical panel piles.
- Generic metric tile grids.
- Metric pressure panels.
- Generic task-list rows pretending to be the primary object.
- Chat transcript panels.
- Calendar-copy event cards as the root Time model.
- Habit-loop cards, reward-counter cards, points cards, or productivity-ranking cards.

## What Is Allowed

Some bounded containers are allowed when subordinate to the primary object:

- Native grouped rows inside You / Personal Runtime settings-style controls.
- Dialogs, sheets, popovers, and confirmation panels.
- Repeated receipt rows when the receipt list is not the root visual language.
- Compact source/proof chips when they serve a larger object.
- Accessibility-expanded text blocks when Dynamic Type requires a clearer reading order.

Allowed containers must remain subordinate to the primary object and must not become the page structure.

## Replacement Taxonomy

| Card-like smell | Replacement primitive direction | Required proof question |
|---|---|---|
| Equal vertical panels | One-primary-object surface with local seams | Is the primary object obvious if labels are blurred? |
| Metric tiles | Object state band, receipt trail, or proof path | Does the data explain a user-owned state transition? |
| Generic task rows | Recommended step, closure path, or recovery thread | Does the row connect to source, reason, and receipt? |
| Calendar event cards | LifeShape Field contour, protected-time band, or pressure seam | Is Time about availability/capacity instead of calendar density? |
| Progress chart card | Motion Current proof lane or re-entry path | Is proof inspectable without reward-counter pressure? |
| Assistant/chat panel | Source/trust seam or Capture route reveal | Is intelligence visible as local state instead of chat persona? |
| Floating utility card | Contextual toolbar action or activated composer seam | Is Capture invoked only after a surface-native entry point? |

## Audit Questions

Before accepting any top-level surface:

- What is the single primary object?
- Which state transition is the user performing?
- Which source, receipt, or trust seam is visible?
- What becomes simpler if every surrounding panel is removed?
- Could this UI ship unchanged in a generic productivity app?
- Does the layout still work with Dynamic Type and Reduce Motion?

## Replacement Closeout

Every card-replacement issue must list:

- Replaced smell
- Replacement primitive direction
- Owner surface
- Source paths touched
- Screenshot or proof artifact path
- Accessibility status
- Remaining Yellow debt or `none needed`
