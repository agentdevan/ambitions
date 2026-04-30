---
name: ambitions-v2-validation-closeout
description: Use at the end of broad Ambitions v2 product, design, model, documentation, or surface implementation to validate canon consistency, prevent stale claims, and produce the required honest closeout. Checks forbidden language, five-tab IA, Today copy, schedule/vacation/cognitive-fit/receipt truth, duration grounding, UI posture, previews, tests, and explicit verified/not-verified separation.
---

# Ambitions V2 Validation Closeout

## Purpose

Use this skill at the end of broad Ambitions v2 product/design implementation to validate consistency, prevent stale canon, and produce an honest completion summary.

## Required Checks

- Forbidden user-facing language scan.
- Today uses `Start here`.
- Primary Today CTA is `Start now` or `Open step`.
- No `Start Focus`.
- No normal `Overdue` / `Failed` / `Missed` / `Behind` state language.
- Five top-level tabs only.
- Schedule & Availability exists under `You -> Planning Behavior`.
- Guided automation default exists.
- Vacation is not free time by default.
- Per-vacation availability behavior exists or is clearly deferred.
- Cognitive fit supports inferred and user-selected paths or is clearly deferred.
- Closure receipts are visible in Today, Trust Center, and Goal Detail or are clearly deferred.
- Durations are grounded.
- Plan distinguishes real availability states.
- Capture remains bottom-composer-driven.
- Safe areas are respected.
- Previews/fixtures exist for core states.
- Tests cover core model rules where practical.

## Suggested Scan Commands

Use targeted variants as appropriate for the changed scope:

```sh
rg -n "Your best next move|next best move|Start Focus|Focus session|Overdue|Failed|Missed|Behind" Native Sources AppUI docs
rg -n "Start here|Start now|Open step|Schedule & Availability|Planning Behavior|Guided automation|vacation|Cognitive fit|Receipt" Native Sources AppUI docs
rg -n "Today|Goals|Capture|Plan|You|Insights|Habits|Tasks|Profile" Native/Ambitions/App Native/Ambitions/Features Sources AppUI
```

Interpret results carefully. Internal compatibility names, test guards, historical docs, and this skill's own forbidden-word lists are not automatically product violations.

## Validation Procedure

1. Re-read the task scope and changed files.
2. Check active docs and code for stale claims created by the work.
3. Run forbidden language and shell IA scans.
4. Run `git diff --check`.
5. Run `xcodegen generate` if Swift targets, `project.yml`, or generated project assumptions changed.
6. Run focused tests for touched model/service/UI seams.
7. Run simulator build or UI smoke when visible top-level surfaces changed and the environment supports it.
8. Separate verified from not verified and could not verify here.
9. Do not mark complete if required validation was skipped and the skipped item is central to the claim.

## Required Final Summary

Return this structure:

1. Current scope
2. Files changed
3. What changed
4. Models/components added or aligned
5. UI surfaces updated
6. Docs updated
7. Previews/fixtures added
8. Tests added/updated
9. Commands run and results
10. Verified
11. Not verified
12. Could not verify here
13. Likely risks
14. Deferred items with reasons
15. Completion claim: Complete / Not complete / Blocked

## Honesty Rules

- Do not claim validation that was not run.
- Do not claim implementation from docs-only changes.
- Do not claim TestFlight, App Store, physical-device, public accessibility, or final RC readiness unless current repo evidence proves that exact claim.
- If a check cannot be run locally, say so and name the manual follow-up.
