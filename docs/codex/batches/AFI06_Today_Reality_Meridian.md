# AFI06 — Today Reality Meridian

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Owner: Ambitions Flagship Interface
Scope: Today object naming, Start Here origin proof, focused Today/app contracts,
batch state, reports

## Purpose

Align Today with the active AFI object model:

```text
Today = Reality Meridian + Start Here Surface
```

Today must answer "What should I do now?" with relief and clarity. Start Here
must emerge from the active Meridian state, not sit as a detached task card.

## Result

Accepted Yellow.

AFI06 renamed user-facing Today object language from the older Reality Rail
wording to Reality Meridian across Today presentation copy, screen contracts,
composition primitives, motion policy titles, degraded-state object labels,
preview fixtures, and focused proof tests.

Internal `.realityRail` enum cases, `DayRail*` types, and
`TodayRealityRail*` UI automation identifiers remain compatibility seams so
existing runtime state and UI smoke selectors are not broken by this batch.

## Validation

- `xcodegen generate` passed.
- Focused Today/App contract tests passed on rerun with 63 selected tests, 0
  failures. Raw log:
  `.codex/logs/2026-05-08T11-afi06-focused-tests-rerun.raw.log`.
- `scripts/build-local.sh` passed. Raw log:
  `output/logs/build-local-20260508-120540.log`.
- ACX quick, impact, docs, batch-closeout, and build-triage bundles ran. Docs
  and batch-closeout returned Green with advisory Yellow scan findings;
  build-triage returned informational Yellow because it prints discovered
  build/test docs only.
- Focused Today tests prove:
  - Reality Meridian continuity title.
  - Start Here emerges from the active Meridian node.
  - Now / Next / Later remain connected.
  - Why this? source path remains available through context, time fit, and goal
    thread evidence.
  - Still-counts / closure / receipt proof remains reviewable.
  - No task-list/dashboard/overdue drift appears in focused visible copy.
- Focused app contract tests prove top-level contract and object-title
  expectations.
- `git diff --check` passed.

## Yellow Carry

Internal Reality Rail identifiers/types remain compatibility seams. AFI06 does
not claim final rendered screenshots, public accessibility conformance, full UI
suite proof, physical-device proof, release readiness, or full Today visual
quality completion.
