# AFI05 — Shell And Continuity Chrome

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Owner: Ambitions Flagship Interface
Scope: app shell, shared shell primitives, docs/canon, tests, reports

## Purpose

Align the active Ambitions shell and continuity chrome to the AFI top-level IA:

```text
Today / Goals / Capture / Time / You
```

## Result

Accepted Yellow.

The user-facing top-level tab title, meridian destination rail, screen-contract
validator, onboarding surface row, and shell continuity copy now use Time as
the fourth top-level destination while preserving `.plan` raw values and route
compatibility for existing storage, deep links, widgets, notifications, and
internal planning seams.

## Validation

- Focused app shell/navigation tests updated for Time as the user-facing tab.
- `xcodegen generate` passed.
- Focused `xcodebuild` lane passed on `iPhone 17`: 56 selected tests, 0
  failures after repairing one stale Plan-era expected title in the screen
  contract registry test.
- `scripts/build-local.sh` passed with `Build Succeeded`
  (`output/logs/build-local-20260508-114210.log`).
- ACX quick, docs, batch-closeout, and build-triage bundles completed; docs and
  batch-closeout carried advisory Yellow scan findings from broader historical
  source material.
- `git diff --check` passed.
- Global next-batch helper returns AFI06 after state updates.

## Yellow Carry

Internal `.plan` symbols, route payloads, model domains, and historical docs
remain compatibility seams. This batch does not rename persistence values,
routes, folders, feature modules, or domain enums.
