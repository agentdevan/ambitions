<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-95735940, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
