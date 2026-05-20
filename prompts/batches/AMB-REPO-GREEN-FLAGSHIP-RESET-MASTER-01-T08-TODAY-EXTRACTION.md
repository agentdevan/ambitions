<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Today Object Extraction

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T08-TODAY-EXTRACTION

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T08-TODAY-EXTRACTION prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T08-TODAY-EXTRACTION.md`

## Objective
Make Today ownership clean around Reality Meridian, Start Here, Closure, Receipt Drawer, and Proof Trail.

## Active source truth to inspect
Truth files, source-refactor map, Today source/tests/previews, Today-related domain/runtime/proof models.

## Allowed scope
Scoped Today source splits, Today-specific primitives, tests/previews, imports, project regeneration.

## Forbidden scope
No behavior rewrite, route break, stale compatibility surface, generic card model, non-shaming regression, or broad visual rewrite.

## Implementation requirements
Split oversized Today source by object seam while preserving behavior. Start Here remains tied to Reality Meridian; closure/recovery/proof remains non-shaming and receipt-backed.

## Visual proof expectations
Run preview/screenshot checks if available; otherwise record Yellow.

## Accessibility expectations
Preserve VoiceOver order, Dynamic Type, Reduce Motion, and action labels.

## Privacy / trust expectations
No external data paths; proof/receipt language must remain local/inspectable.

## Continuity expectations
Existing Today navigation and tests should continue; update references safely.

## Validation expectations
Run `xcodegen generate`, focused Today tests/build when feasible, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Build/test failure due refactor, Today behavior deletion, route break, or source proof overclaim.

## Rollback expectations
Record moves/imports/types and restore this train only.

## Expected final report format
Today object map, files moved, validation, visual/accessibility proof status, Yellow/Red.
