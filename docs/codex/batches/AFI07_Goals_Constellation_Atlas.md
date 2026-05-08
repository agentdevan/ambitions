# AFI07 — Goals Constellation Atlas

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Owner: Ambitions Flagship Interface
Scope: Goals top-level object language, first-screen contract, focused Goals/app
contracts, batch state, reports

## Purpose

Align Goals with the active AFI object model:

```text
Goals = Your Direction / Constellation Atlas + Orbital Lens
```

Goals must answer "What is my life pointed at?" with orientation. Life areas
must be visible without system ranking, scoreboards, KPI posture, habit rings,
or astrology-like metaphor drift. Mission Control remains valid inside Goal
Detail and internal compatibility seams only; it must not present as the
top-level Goals object.

## Result

Accepted Yellow.

AFI07 updated top-level Goals copy and contracts to Your Direction,
Constellation Atlas, and Orbital Lens. The existing Goals mechanics remain
intact, while visible top-level object labels, screen-contract content,
composition primitives, motion/degraded-state object titles, preview fixtures,
and focused tests now assert the AFI Goals object language.

Internal Mission Control type names and Goal Detail Mission Control surfaces
remain compatibility seams. AFI07 does not rename route raw values, persistence
models, or historical/internal test identifiers.

## Validation

- `xcodegen generate` passed.
- Focused Goals/App contract tests passed on rerun with 41 selected tests, 0
  failures. Raw log:
  `.codex/logs/2026-05-08T12-afi07-focused-tests-rerun.raw.log`.
- `scripts/build-local.sh` passed. Raw log:
  `output/logs/build-local-20260508-123100.log`.
- ACX quick, impact, docs, batch-closeout, and build-triage bundles ran. Docs
  and batch-closeout returned Green with advisory Yellow scan findings;
  build-triage returned informational Yellow because it prints discovered
  build/test docs only.
- Focused Goals/App contract tests prove:
  - Goals hero uses Your Direction.
  - Constellation Atlas is top-level Goals object language.
  - Orbital Lens keeps one thread connected to Today.
  - Life areas remain equal-weight and list-fallback capable.
  - Mission Control does not appear in top-level Goals first-screen copy.
  - No KPI/dashboard/ranked score/habit-ring/astrology drift appears in focused
    top-level copy.
- `git diff --check` passed.

## Yellow Carry

Rendered screenshots, full UI test suite, manual accessibility traversal, and
complete internal Mission Control identifier retirement remain unclaimed.
