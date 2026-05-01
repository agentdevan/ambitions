# Ambitions 3.0 F22.5 Doc QA Backlog Closure Report

Date: 2026-05-01
Train: F17-F30 FAANG Handoff Completion Train
Batch: F22.5 Doc QA Backlog Closure
Gate: Green

## Result

F22.5 is Green.

The active broken-link backlog that triggered F22.5 was closed. The affected
older canon/supporting docs now link to archived superseded-design-canon files
and are labeled as historical/supporting evidence where they could otherwise
read like current Ambitions 3.0 source truth.

The broader markdownlint backlog remains large and pre-existing. It is recorded
as advisory/background Yellow, not a blocker for F22.5, because the active
navigation and source-truth ambiguity improved and lychee now reports no broken
links.

F22.7 remains mandatory before F23.

FAANG handoff remains PARTIAL until F27 explicitly passes.

## Scope

Docs-only cleanup:

- active link fixes;
- historical/supporting labels for older continuity/front-end evidence;
- no app behavior changes;
- no product implementation;
- no deletion of useful history.

## Source Truth

- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
- `docs/canon/Ambitions_3_0_As_Current_Baseline_Policy.md`
- `docs/canon/Ambitions_3_0_Active_History_Archive_Policy.md`
- `docs/audits/ambitions-3-0-f22-product-language-baseline-reset-report.md`
- `docs/archive/superseded-design-canon/design/`

## Active Fixes

Broken links fixed:

- `docs/canon/Ambitions_Full_Frontend_Transformation_Program.md`
  now points execution classification to the archived superseded design-canon
  copy and labels it historical tiering evidence.
- `docs/canon/Ambitions_Product_Addendum_Continuity_Reality_Execution.md`
  now labels the addendum historical/supporting and points old shell and screen
  architecture references to the archived superseded design-canon copies.
- `docs/canon/Ambitions_State_Continuity_Mesh.md`
  now labels the document historical/supporting Batch 54 continuity evidence
  and points old cross-device/trust references to archived superseded
  design-canon copies.

No active source-of-truth doc was changed to make old canon current.

## Doc QA Classification

Active docs navigability:

- Improved. The known broken links from F22 now resolve.
- The current source-truth path still starts from `README.md`, `docs/README.md`,
  `docs/canon/README.md`, `AGENTS.md`, and the Ambitions 3.0 canon stack.

Orphan active docs:

- No new orphan active docs were introduced.
- F22.5 did not perform a corpus-wide orphan rewrite because the user scoped
  this gate to docs-only backlog closure without deleting useful history.

Markdownlint:

- `scripts/run-doc-qa.sh || true` still reports `10101` markdownlint errors.
- This remains a large pre-existing corpus-formatting backlog, not a new F22.5
  product-truth ambiguity.
- The backlog should not be called handoff-clean yet; it should remain indexed
  for future docs-system hardening.

Links:

- `scripts/run-doc-qa.sh || true` now reports `606` total links, `322` unique
  links, `606` OK, and `0` errors.

Deprecated/stale language:

- Remaining hits are still a mix of historical/supporting docs, guard lists,
  compatibility seams, and internal terminology that F22 classified.
- F22.5 did not broaden into copy or code naming work.

## Remaining Advisory Backlog

Accepted background Yellow:

- markdownlint backlog remains large;
- historical/supporting docs still contain old batch/version language by
  design;
- compatibility seams remain where documented by F22;
- pre-existing architecture warnings are reserved for F22.7/F27.5.

These do not block F22.5 because the active broken-link and current-canon
ambiguity issues that triggered this batch are closed.

## Validation

Pre-commit state:

- `git status --short`: only the three expected docs were dirty before report
  and state updates.
- current branch: `main`.
- current HEAD before F22.5 edits: `7e6357294141c4b5a6306e67ec5cd8361705e123`
  (`Complete F22 product language baseline reset`).
- `.github/workflows`: untouched.
- runtime dependency manifests: untouched.

Commands:

- `scripts/run-doc-qa.sh || true`: advisory PARTIAL; lychee `0` errors,
  markdownlint `10101` errors.
- `git diff --check`: PASS before report creation.
- `scripts/batch-train-gate-check.sh || true`: advisory Yellow because the
  F22.5 working tree was intentionally dirty.
- `scripts/build-local.sh`: PASS.
  Log: `output/logs/build-local-20260501-150758.log`.

## Gate Decision

Green.

F22.5 fixed the active broken-link trigger, improved active historical labeling,
and preserved useful history without making old canon appear current.

F22.7 is now the next mandatory gate before F23.
