# Ambitions 3.0 FAANG Engineer Handoff

Status: Active engineer handoff packet
Last updated: 2026-05-01

## What This Repo Is

Ambitions is a premium native iOS life execution system.

Current top-level destinations are:

- Today
- Goals
- Capture
- Plan
- You

The core loop is:

`Capture -> Place -> Plan -> Do Today -> Close / Recover -> Save Proof`

Ambitions is not a chatbot, generic task app, calendar clone, habit tracker, or
productivity score app. It should feel organized, local-first, calm, and
concrete.

## Current Train State

The F17-F30 FAANG handoff completion train is active.

Green by current train evidence:

- F17 repair through F28
- F27 final handoff gate rerun
- F27.5 maintainability audit

Next:

- F30 Beyond 3.0 Continuation Plan after F29 is committed and pushed

F29 creates this handoff package. It does not start new feature work.

## First-Hour Read Order

1. `README.md`
2. `AGENTS.md`
3. `docs/README.md`
4. `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
5. `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
6. `docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md`
7. `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
8. `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
9. `docs/canon/Ambitions_3_0_Product_Language_System.md`
10. `docs/codex/CONTEXT_INDEX.md`
11. `.codex/reports/current-batch-train-state.md`

Use `docs/codex/BATCH_REGISTRY.md` for implementation status truth only. It
does not override Ambitions 3.0 product direction.

## Where To Work

- App shell, dependency container, routing: `Native/Ambitions/App`
- Today: `Native/Ambitions/Features/Today`
- Goals and Goal Detail: `Native/Ambitions/Features/Goals`
- Capture: `Native/Ambitions/Features/Captures`
- Plan: `Native/Ambitions/Features/Plan`
- You: `Native/Ambitions/Features/Profile`
- Domain contracts: `Native/Ambitions/Domain`
- Services: `Native/Ambitions/Services`
- Persistence: `Native/Ambitions/Persistence`
- Shared UI/design system: `Sources`
- Widget/shared app UI: `AppUI/Sources`
- Tests: `Native/AmbitionsTests`, `Native/AmbitionsUITests`

## Build And Test

Primary local commands:

```bash
scripts/validate-dev-tools.sh || true
scripts/build-local.sh
scripts/test-local.sh
scripts/run-doc-qa.sh || true
scripts/swiftui-architecture-scan.sh || true
git diff --check
```

Latest full proof:

- `scripts/test-local.sh`: PASS
- Unit tests: 779, 0 failures
- UI tests: 29, 0 failures
- Log: `output/logs/test-local-20260501-220744.log`

Latest build proof:

- `scripts/build-local.sh`: PASS
- Log: `output/logs/build-local-20260501-224535.log`

## Compatibility Seams To Preserve

Do not blind-rename these seams:

- `Profile` feature/type names back the user-facing You surface.
- `Insights` route/model names preserve history/contextual-intelligence routes.
- `Habits` route/model names preserve Ritual/Plan compatibility.
- `activeFocus`, `TodayFocus*`, and `.focus` protect external snapshot and
  Today compatibility.
- Internal `.failed` states protect async/result taxonomy; visible copy should
  stay humane.

Retire any seam only with schema, route, widget, App Intent, deep-link,
persistence, and test coverage.

## Known Risks

- Large feature/service files remain indexed maintainability debt.
- Doc QA still has advisory markdownlint/deprecated-language backlog.
- Physical-device verification is not claimed.
- Manual VoiceOver, Dynamic Type, Reduce Motion, and accessibility conformance
  are not publicly claimed.
- TestFlight, App Store submission, signed archive validation, and final RC
  lock are not claimed.
- Rendered external-platform proof is not claimed.

## What Not To Touch Casually

- `.github/workflows/**`
- runtime dependency manifests
- route raw values, deep links, App Intent identifiers, widget payload schemas,
  Live Activity payloads, and import/export compatibility seams
- release, App Store, accessibility, privacy, or physical-device claims without
  fresh evidence
- historical docs unless a current source-truth conflict requires a narrow
  status fix

## How To Add Work Safely

Start from the target Ambitions 3.0 primitive or surface doc. Keep changes in
the owning feature seam. Prefer typed state, deterministic projectors, visible
privacy boundaries, accessibility identifiers, and focused product-contract
tests. If a target file is already over the architecture threshold, extract a
bounded seam before adding behavior.
