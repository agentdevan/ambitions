# UIQL-010 / AMB-965 Repair Reframe Report

Status: Required because AMB-965 exceeded three repair cycles.
Program: UIQL
Linear issue: AMB-965
Date: 2026-06-12 America/New_York

## Original Target

Reconstruct Motion so it shows actual proof, recovery, re-entry, movement, source inspection, and receipt paths without becoming an explainer page, analytics surface, score/streak/progress chart, or activity feed.

## Failed / Superseded Evidence

- Rerun1 passed automation but visual review found the bottom dock covered lower proof facts and the re-entry action was not visible enough.
- Rerun2 passed automation after moving Motion Current before the crown and moving actions above facts, but large Dynamic Type clipped the action proof and receipt/dock capture stayed on the top object.
- Rerun3 failed because the new frame-based large-text action anchor was too strict for the pre-repair layout.
- Rerun4 passed automation but visual review found large Dynamic Type action labels ellipsized.

## Reframed Repair

The repair target changed from "element exists somewhere in the UI hierarchy" to "the visual proof frame shows the required Motion action or receipt object without bottom dock collision, ellipsis, or clipped text."

Final repairs:

- Make proof-present Motion the default render state while retaining explicit empty-state proof.
- Put the Motion Current object before the contextual crown.
- Add visible proof, receipt, and re-entry action buttons.
- Reorder accessibility-size Motion field content to show title, actions, and trace facts before long summary copy.
- Stack accessibility-size action buttons full-width with wrapping labels.
- Anchor final screenshots to visible proof frames instead of relying on offscreen element existence.

## Final Evidence Used

- `artifacts/ui-quality-lockdown/script-output/AMB-965-motion-focused-unit-tests-rerun4.log`
- `artifacts/ui-quality-lockdown/script-output/AMB-965-motion-screenshot-matrix-rerun5.log`
- `artifacts/ui-quality-lockdown/screenshots/amb-965/rerun5/`

## Final Status

Green for scoped local AMB-965 after rerun5 visual inspection.

## Non-Claims

This reframe does not claim owner approval, release readiness, TestFlight readiness, App Store readiness, physical-device proof, full accessibility certification, VoiceOver certification, performance proof, privacy/legal approval, AMB-966+ completion, or Linear Done before manual push.
