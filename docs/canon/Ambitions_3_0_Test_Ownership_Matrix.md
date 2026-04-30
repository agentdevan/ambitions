# Ambitions 3.0 Test Ownership Matrix

Status: Active QA governance

## Purpose

This matrix assigns ownership for Ambitions tests so failures can be classified before they are patched. Tests protect user promises, canon contracts, routing truth, accessibility contracts, and release evidence.

## Ownership Model

| Area | Primary owner | Test classes | Fixture owner | Stability expectation |
| --- | --- | --- | --- | --- |
| Today / Reality Rail | iOS Engineer + QA | Product contract, routing, fixture smoke | Today primitive owner | Stable across visual redesigns |
| Goals | iOS Engineer + Product Manager | Product contract, routing, visual structure | Goals primitive owner | Stable unless canon changes |
| Capture | iOS Engineer + UX Designer | Product contract, routing, copy, fixture smoke | Capture primitive owner | Stable identifiers required |
| Plan | iOS Engineer + QA + Privacy | State-machine, routing, privacy/trust | Plan primitive owner | High, because recovery must not shame or automate silently |
| You / What Ambitions Knows | Privacy/Trust + Accessibility + iOS | Privacy contract, accessibility, copy | Trust memory owner | High, because trust claims are sensitive |
| Shell / Navigation | iOS Engineer + Release Manager | Routing, accessibility, fixture smoke | Shell owner | Highest; broad regressions block release claims |
| External surfaces | iOS Engineer + Privacy + QA | Projection safety, routing, privacy | External surface owner | High but device evidence must be separated |
| Design system | Visual Design Lead + Accessibility | Component contracts, Dynamic Type, motion | Design-system owner | Stable API, flexible layout |
| Recommendations | AI/Personalization + Privacy | Eligibility, evidence hierarchy, copy | Recommendation owner | Deterministic fixtures only |

## Required Test Metadata

Every new or modernized UI test should declare or be classifiable by:

- User promise protected.
- Owning canon doc.
- Owning primitive.
- Owning surface.
- Stable accessibility identifier.
- Fixture state.
- Update trigger.
- Whether it should survive redesigns.

## Failure Classifications

- Real implementation bug.
- Outdated test expectation.
- Fixture drift.
- Accessibility identifier drift.
- Navigation drift.
- Copy migration.
- Product canon conflict.
- Simulator or environment issue.
- Flake.

## Quarantine Rules

Quarantine is allowed only when a test is demonstrably flaky or environment-bound and the protected promise remains covered elsewhere or has a replacement issue/report. Quarantine is forbidden for privacy, navigation, release-claim, or destructive-data safeguards unless a replacement guard lands first.

## Evidence Report

Use `.codex/templates/test-failure-report-template.md` for failures. Include exact command, simulator, failure class, owner, affected canon, replacement/repair plan, and whether release claims are blocked.
