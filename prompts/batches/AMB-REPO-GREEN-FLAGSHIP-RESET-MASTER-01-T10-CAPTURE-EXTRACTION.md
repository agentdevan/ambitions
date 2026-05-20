<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Capture Object Extraction

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T10-CAPTURE-EXTRACTION

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T10-CAPTURE-EXTRACTION prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T10-CAPTURE-EXTRACTION.md`

## Objective
Make Capture ownership clean around Atmosphere Composer and remove plural destination ownership.

## Active source truth to inspect
Truth files, source-refactor map, Capture/Captures source/tests/previews, capture routing docs and visual recipes.

## Allowed scope
Scoped Capture source organization, canonical naming, tests/previews, docs/recipe ID repair, project regeneration if paths move.

## Forbidden scope
No default notes feed/inbox top-level, no plural Captures destination ownership, no broad visual rewrite, no behavior deletion.

## Implementation requirements
Capture is the canonical destination; Atmosphere Composer is primary object. Route reveal after input remains; Needs a Place / Ready to Place / Grow into Goal language stays where applicable.

## Visual proof expectations
Run preview/screenshot checks if available or record Yellow.

## Accessibility expectations
Composer labels, route actions, and input semantics must remain accessible.

## Privacy / trust expectations
No cloud intake or external processing.

## Continuity expectations
Preserve existing capture promotion/routing behavior.

## Validation expectations
Run `xcodegen generate` if paths changed, focused Capture tests/build when feasible, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Plural destination remains active, route break, build failure, test deletion, or source-proof overclaim.

## Rollback expectations
Restore moved Capture files/imports and project changes from this train.

## Expected final report format
Capture object map, plural repair proof, validation, Yellow/non-claims.
