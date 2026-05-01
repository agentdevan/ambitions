# Ambitions 3.0 F22 Product Language + Active Repo Baseline Reset Report

Date: 2026-05-01
Train: F17-F30 FAANG Handoff Completion Train
Batch: F22 Product Language + Active Repo Baseline Reset
Gate: Green, with F22.5 triggered

## Result

F22 is Green.

The active train has been upgraded to the 3.0-as-baseline / human-made active
repo standard. Ambitions 3.0 is now explicitly documented as the current
baseline, with companion policies for human-made maintainability and active
history/archive handling.

F22.5 is triggered because doc QA still reports a large pre-existing
markdownlint backlog and 5 active broken links. F23 remains blocked until F22.5
if run and mandatory F22.7 are Green.

FAANG handoff remains PARTIAL until F27 explicitly passes.

## Source Truth Read

- `README.md`
- `docs/README.md`
- `docs/canon/README.md`
- `AGENTS.md`
- `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md`
- `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`
- `docs/codex/BATCH_TRAIN_F17_F30_FAANG_HANDOFF_PROMPT.md`
- `docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
- `docs/canon/Ambitions_3_0_Product_Language_System.md`
- `docs/canon/Ambitions_3_0_Repo_Hygiene_And_Active_Canon_Policy.md`
- `docs/canon/Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md`
- `docs/canon/Ambitions_3_0_FAANG_Handoff_Readiness_Gate.md`
- `docs/canon/Ambitions_3_0_SwiftUI_State_Contract_Architecture_Standard.md`
- `docs/canon/Ambitions_3_0_Feature_Boundary_And_File_Size_Constitution.md`
- `docs/canon/Ambitions_3_0_UI_Test_Contract.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- F21 and F21.5 evidence reports

## Baseline Policies Added

- `docs/canon/Ambitions_3_0_As_Current_Baseline_Policy.md`
- `docs/canon/Ambitions_3_0_Human_Made_Codebase_Standard.md`
- `docs/canon/Ambitions_3_0_Active_History_Archive_Policy.md`

These policies define:

- Ambitions 3.0 as the current product baseline;
- older versions as historical/supporting/compatibility context only;
- active docs as direct product guidance, not migration notes;
- compatibility seams as owner/reason/exposure/retirement/test obligations;
- human-made codebase expectations for ownership, state/projector/view
  separation, comments, reports, and handoff readability.

## Train Updates

Updated:

- `docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md`
- `docs/codex/BATCH_TRAIN_F17_F30_FAANG_HANDOFF_PROMPT.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/BATCH_REGISTRY.md`

The train now includes:

- F22 Product Language + Active Repo Baseline Reset
- F22.5 Doc QA Backlog Closure
- mandatory F22.7 Human-Made Active Repo Hygiene / 3.0-As-Baseline Gate
- mandatory F27.5 Human-Made Codebase Maintainability Audit

## Active Debt Fixed

User-facing / product-copy fixes:

- `Launch failed` -> `Ambitions could not finish launching`
- `Action failed` -> `Action could not finish`
- `Clarification failed` -> `Clarification could not finish`
- `Correction failed` -> `Correction could not finish`
- `Ritual action failed` -> `Ritual action could not finish`
- `Skipped, not failed` -> `Skipped, still okay`
- `missed day/week` support-report language -> `disrupted day/week`
- `Safe failure` visible receipt status -> `Safely blocked`
- `top-level Insights tab` visible/support copy -> `separate top-level destination`
- active screen-contract `Hero Decision Panel` references -> `Reality Rail`

Active doc baseline fixes:

- root/docs/canon indexes now link the baseline, human-made, and archive
  policies;
- the current implementation gap audit now states it is an F00 historical
  baseline with later addenda, not the live status ledger;
- design/backlog docs now say Ambitions 3.0 wins active product, IA, and
  language direction.

## Scan Totals

Post-fix deprecated-language scan over `Native AppUI Sources docs README.md
AGENTS.md .codex`: `928` hits.

Post-fix current-baseline risk scan over `README.md AGENTS.md docs Native AppUI
Sources`: `809` hits.

Post-fix active source/code/test scan over `Native AppUI Sources`: `257` hits.

## Classification Of Remaining Hits

Active user-facing debt:

- No known newly introduced user-facing legacy phrase from F22.
- Remaining `overdue` in Live Activity/widget code is an internal enum value
  projected as `Needs attention` / `Now`, not visible copy.
- Remaining `.failed` / `.failedSafely` values are internal state/result names
  or compatibility result taxonomies, with visible strings adjusted where F22
  found active leakage.

Active doc debt:

- Large doc QA backlog remains and triggers F22.5.
- Several active/supporting older docs still contain historical language. F22
  added current-baseline policy and stronger labels, but did not rewrite the
  full older corpus.

Active code/comment debt:

- `activeFocus`, `TodayFocus*`, `Profile`, `Insights`, and `Habits` remain
  compatibility or broad-migration seams.
- `activeFocus` is retained for external snapshot schema compatibility.
- `TodayFocus*` remains broad Today service/model naming debt and must be
  handled as a dedicated migration, not opportunistically renamed in F22.

Active test debt:

- Negative copy-guard assertions intentionally include forbidden phrases.
- Compatibility tests intentionally include legacy wire values.
- Screen contract tests were updated from `Hero Decision Panel` to
  `Reality Rail` where that was active current-baseline language.

Compatibility seams allowed:

| Seam | Why retained | Owner | User-facing exposure | Retirement condition | Coverage |
|---|---|---|---|---|---|
| `activeFocus` | External snapshot schema compatibility | External Surface Projection | Not visible copy | Schema-versioned adapter replaces it | External snapshot/widget tests |
| `TodayFocus*` | Broad Today model/service migration risk | Today / Step Execution | Not visible copy after F22 scan | Dedicated Step Session naming migration | Today unit/UI tests |
| `Profile` | Folder/type compatibility for user-facing You | You / Trust | User-facing label remains You | Broad feature-folder migration with route safety | Profile/You tests |
| `Insights` | Historical/internal Reviews/Plan/You seam | Reviews / Plan / You | No top-level visible destination | Route/type migration with compatibility adapter | Release truth and routing tests |
| `Habits` | Legacy feature folder for Rituals compatibility | Plan / Rituals | User-facing copy says Rituals | Folder/type migration after route audit | Ritual/route tests |
| `.failed` / `.failedSafely` | Internal error/result taxonomy | Domain / Services | Visible strings adjusted where found | Only renamed with domain-wide adapter | Receipt/automation tests |

Historical/audit/archive allowed:

- prior audit reports;
- 2.0/v2/Waves/D/M/R historical implementation evidence;
- deprecated-language guard lists;
- migration/deprecation docs;
- archived design/transformation docs.

Negative test allowed:

- tests asserting forbidden terms do not appear in visible copy;
- tests preserving old raw values for deep-link, route, App Intent, widget, or
  snapshot compatibility.

False positives:

- build/test/report language such as `failed` in validation contexts;
- `productivity score` and `AI confidence` inside banned-term lists;
- `missed` in older historical docs or recovery research context.

## Validation

Preflight:

- `git status --short`: clean at start.
- `git branch --show-current`: `main`.
- `git rev-parse HEAD`: `7f68fcd892f6dbc2a96f84509476cfa7bdf85cbb`.
- `git log -1 --oneline`: `7f68fcd8 Harden F21.5 UI smoke reliability`.
- `.github/workflows`: no changes.
- dependency files: no changes.
- `scripts/validate-dev-tools.sh || true`: PASS.
- `scripts/batch-train-preflight.sh || true`: PASS.
- `scripts/batch-train-gate-check.sh || true`: Green hint.

Build:

- `scripts/build-local.sh`: PASS.
- log: `output/logs/build-local-20260501-145838.log`.

Focused tests:

- Initial focused test attempt: failed with Xcode build database lock because
  it was incorrectly run concurrently with `scripts/build-local.sh`.
- Serial rerun:
  `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination
  'platform=iOS Simulator,name=iPhone 17'
  -only-testing:AmbitionsTests/ScreenContractRegistryTests
  -only-testing:AmbitionsTests/CoreSurfaceIntegrationScenarioTests
  -only-testing:AmbitionsTests/ActionClosureReceiptModelsTests`
- Result: PASS, `32` tests, `0` failures.

Docs QA:

- `scripts/run-doc-qa.sh || true`: advisory PARTIAL.
- stale-guidance: historical/supporting hits remain.
- deprecated-language: expected guard/history/internal hits remain.
- markdownlint: `10087` errors across the existing markdown corpus.
- lychee: `5` broken links in `3` docs.

Diff:

- `git diff --check`: PASS before report creation.

## F22 Gate

Green.

Reasons:

- build passes;
- focused touched-scope tests pass after serial rerun;
- active train and indexes now encode 3.0-as-baseline and human-made-codebase
  standards;
- active visible legacy copy found in touched surfaces was replaced;
- no workflow files were touched;
- no dependency files were changed;
- compatibility seams remain documented instead of blindly renamed;
- release, accessibility, device, App Store, and FAANG handoff readiness remain
  unclaimed.

## F22.5 Trigger

F22.5 is triggered.

Reasons:

- markdownlint backlog remains very large;
- lychee reports 5 broken links;
- active/supporting docs still contain historical-language scan hits that are
  labeled enough for F22 but not handoff-clean for docs QA;
- F22.7 must not run until F22.5 is resolved or formally classified Green.

## Next Exact Prompt

```text
Continue the F17-F30 FAANG Handoff Completion Train at F22.5 Doc QA Backlog
Closure.

Read:
- docs/audits/ambitions-3-0-f22-product-language-baseline-reset-report.md
- docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md
- docs/canon/Ambitions_3_0_As_Current_Baseline_Policy.md
- docs/canon/Ambitions_3_0_Human_Made_Codebase_Standard.md
- docs/canon/Ambitions_3_0_Active_History_Archive_Policy.md
- docs/audits/doc-qa/latest logs from 20260501-150212

Scope:
- docs-only cleanup;
- fix active index/navigation ambiguity first;
- fix broken active links where safe;
- classify remaining markdownlint/deprecated-language backlog as active,
  historical/advisory, or deferred;
- do not touch app behavior;
- do not delete useful history without archive-policy support;
- do not touch .github/workflows or dependency files.

Required validation:
- scripts/run-doc-qa.sh || true
- scripts/build-local.sh
- scripts/batch-train-gate-check.sh || true
- git diff --check

F22.5 must be Green before mandatory F22.7 can start. F23 remains blocked until
F22, F22.5 if triggered, and F22.7 are Green.
```
