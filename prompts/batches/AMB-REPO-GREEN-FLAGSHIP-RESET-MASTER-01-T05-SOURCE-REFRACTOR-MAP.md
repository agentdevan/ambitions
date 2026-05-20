<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Repo Architecture Organization Map

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP.md`

## Objective
Create the target source ownership map for flagship object seams without moving files blindly.

## Active source truth to inspect
Read truth files, current source tree, `project.yml`, `Package.swift`, implementation map, audit UI-sprawl and cleanup reports.

## Allowed scope
`docs/audits/*source-refactor-map.md`, master report/JSON, optional read-only source inventory output.

## Forbidden scope
No source moves, empty folder creation, UI rewrite, project regeneration, or release claims in this train unless explicitly needed for map accuracy.

## Implementation requirements
Map `App`, `Domain`, `Services`, `Persistence`, feature seams, shared UI, tests, proof ownership, and object-local seams. Scope future extraction trains with risk and validation.

## Visual proof expectations
None.

## Accessibility expectations
Map accessibility ownership under `Native/Ambitions/UI/Accessibility` or current equivalent.

## Privacy / trust expectations
Map trust/data controls and local-first runtime ownership.

## Continuity expectations
Respect existing compatibility seams; identify moves as future trains.

## Validation expectations
Run source inventory scans, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Unplanned source movement, empty architecture theater, or source-present/release-ready overclaim.

## Rollback expectations
Restore map/report artifacts only.

## Expected final report format
Ownership map, next extraction trains, non-goals, proof gaps, validation.
