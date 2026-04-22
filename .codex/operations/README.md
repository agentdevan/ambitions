# Ambitions Codex Operations

This folder is the production operating manual for Codex work in Ambitions.

Use it to standardize:

- task intake
- task classification
- execution mode selection
- batch-pass discipline
- change-type expectations
- validation policy
- regression-pack usage
- manual signoff policy
- known flaky-proof handling
- escalation rules
- release and merge readiness flow

## How To Use It

1. start with `task-intake.md`
2. classify the request with `task-classification.md`
3. choose the execution mode from `execution-modes.md`
4. for active-batch work, apply `batch-execution-protocol.md`
5. use `transformation-validation-matrix.md` to choose the narrowest truthful validation set
6. use `frontend-regression-pack.md` for recurring shell/Today/Goals regression proof
7. use `manual-signoff-checklists.md` when manual closeout is required
8. check `known-flakes.md` before spending time rediscovering accepted instability
9. use release flow documents when the work is nearing merge or release

## Operating Principles

- quality is the non-negotiable target
- speed comes from narrower reads, bounded passes, fixed regression packs, and truthful closeout rules
- do not spend tokens re-diagnosing already-known flakes
- do not use full UI validation as the default answer for every batch
- do not widen implementation while trying to close a validation-only gap

## Maintenance Rules

- review this layer when the same intake or execution confusion happens more than once
- update task classes when Ambitions adds a new recurring work type
- update regression packs when stable proof surfaces change
- update signoff checklists when a surface meaningfully changes its closeout bar
- update known flakes when a timing-sensitive proof is accepted, fixed, or retired
- update release and validation docs when the native build flow or shipped surfaces change
- prune stale operational examples when they no longer match current repo truth
