<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Shared Design System And UI Primitive Organization

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T07-UI-PRIMITIVE-ORG

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T07-UI-PRIMITIVE-ORG prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T07-UI-PRIMITIVE-ORG.md`

## Objective
Organize shared UI primitives into native flagship seams without changing visual direction broadly.

## Active source truth to inspect
Truth files, source-refactor map, `Sources/`, `AppUI/`, `Native/Ambitions/UI/`, previews, accessibility helpers, design-system package.

## Allowed scope
Scoped file moves/extractions in shared UI seams, imports, project regeneration when needed, focused tests/previews.

## Forbidden scope
No broad visual rewrite, no new design language, no generic card/dashboard stacks, no unsafe animation/blur/glow, no app dependency additions.

## Implementation requirements
Only extract repeated primitives/literals where clear; preserve Dynamic Type, VoiceOver semantics, Reduce Motion, Increase Contrast, tap targets, and current product posture.

## Visual proof expectations
If UI source moves affect rendering, run previews/screenshot path when available or record Yellow if unavailable.

## Accessibility expectations
Preserve or improve accessibility primitives; no public conformance claim without proof.

## Privacy / trust expectations
No user-data or network changes.

## Continuity expectations
Keep existing call sites working; use XcodeGen after moves.

## Validation expectations
Run `xcodegen generate` if paths changed, focused build/test when feasible, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Broad visual change, build failure due refactor, source moved without project update, or accessibility regression hidden.

## Rollback expectations
Record moved/imported files and restore this train's moves only.

## Expected final report format
Files moved, imports changed, validation, visual/accessibility proof status, Yellow items.
