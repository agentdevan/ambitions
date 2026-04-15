---
name: ios-qa-regression-checker
description: Run or document the real Ambitions iOS validation workflow after changes, including XcodeGen generation, build, tests, routing checks, and manual regression notes. Use when asked to validate a change, run regression checks, make sure the native app compiles, or verify routing/container wiring; do not use for generic QA advice that ignores the repo's actual build and CI commands.
---

# iOS QA Regression Checker

## Purpose

Validate Ambitions changes against the repo's actual native build, test, and manual-check workflow and report failures honestly.

## When To Use

- `validate this change`
- `run regression checks`
- `make sure this compiles and routes correctly`
- after meaningful native, routing, target, or extension edits

## When Not To Use

- The request is only planning with no code or config change.
- The user wants a vague QA checklist not tied to the repo.

## Required Inputs

- The changed files.
- Current validation docs and CI workflow.
- Available local toolchain constraints.

## Execution Steps

1. Identify the real validation path from:
   - `docs/native-build-and-release.md`
   - `.github/workflows/ios-validate.yml`
2. Decide what needs to run based on the change:
   - `xcodegen generate`
   - simulator build
   - unit tests
   - UI tests
   - archive sanity check
   - manual routing/OS-surface checks
3. Run what the current environment supports.
4. For changes affecting routing, container wiring, or screen composition, add focused manual validation notes even if automated coverage exists.
5. Report failures clearly with the failing step, file area, and whether the issue appears environmental or code-driven.

Use the runbook and checklist in `templates/`:

- `templates/validation-runbook.md`
- `templates/manual-test-checklist.md`

## Output Format Expectations

Report validation in this order:

1. commands run
2. result of each command
3. manual checks completed
4. checks not run and why
5. observed regressions or clean result

## Validation Requirements

- Never claim a build, test, or manual check passed unless it was actually run.
- Prefer the repo's documented XcodeGen and `xcodebuild` commands over ad hoc substitutes.
- If a task changes extension or OS-surface behavior, include manual notes for the affected surface.

## Ambitions-Specific Guardrails

- `project.yml` is part of the validation surface because the repo does not check in the generated project.
- Routing changes should consider `AppExternalRouting`, app tabs, and feature drill-in paths.
- Container changes should consider `AppContainerFactory`, `AppContainer`, and service exposure.
- Widget or Live Activity work should reference `docs/widget-live-activity-manual-testing.md` when relevant.

## Trigger Phrases

- `validate this change`
- `run regression checks`
- `make sure this compiles and routes correctly`
- `do the iOS preflight`
