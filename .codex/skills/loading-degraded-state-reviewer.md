# Loading Degraded State Reviewer
<!-- markdownlint-disable MD013 -->

## Purpose

Ensure loading, progress, skeleton, waiting, empty, stale, denied, offline,
and degraded states are honest, calm, useful, and not fake intelligence.

## When It Applies

Use for SI13 and any SI/PD/AOS24 batch that touches unavailable sources,
recommendation recalculation, proof/history loading, disabled actions, denied
permissions, or local-only fallback.

## Source-Truth Hierarchy

User prompt, `AGENTS.md`, Ambitions 3.0 recovery/language/accessibility docs,
PXOS degraded-state canon, SI canon, current source behavior.

## Review Inputs

State matrix, copy, source/freshness labels, next action, accessibility labels,
preview evidence, and release/non-claim boundaries.

## Review Checklist

- No spinner-only default where context is needed.
- Stale, partial, denied, and local-only states are truthful.
- User has a next action or clear wait state.
- Copy avoids shame, fake precision, and fake AI certainty.
- Degraded states support VoiceOver and Dynamic Type.

## Green / Yellow / Red Criteria

- Green: states are specific, inspectable, accessible, and previewed where
  relevant.
- Yellow: noncritical state deferred with owner and no current blocker.
- Red: fake intelligence, hidden uncertainty, no next action, inaccessible
  degraded state, or unsupported platform/readiness claim.

## Forbidden Approvals

Do not approve fake loading certainty, hidden unavailable source, silent
automation, or shame language.

## Required Evidence

State matrix, copy review, preview/screenshot status, accessibility notes, and
source/freshness boundaries.

## Repair Guidance

Name the source state, add next action, simplify copy, add preview state, or
stop if uncertainty would be hidden.

## Claims

May claim degraded-state review for the touched scope. Must not claim model,
platform, or release proof.
