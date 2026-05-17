# Ambitions 3.0 — Task Width And Batch Combining Gate

Status: Historical supporting canon; subordinate to `docs/truth/*`

## Purpose

Every non-trivial Codex prompt must start by sizing the task. Width controls
role review, allowed file scope, validation, checkpointing, and whether the
batch must be split before edits.

## Task Sizes

- XS: docs/index/copy only, no app behavior.
- S: one file family, one validation pack.
- M: one primitive, one surface, focused tests.
- L: one primitive plus dependent tests/previews.
- XL: multiple coupled primitives, requires checkpoints and staged commits.
- XXL: not allowed as one batch.

## Hard Split Rules

Split the task if it includes more than:

- 3 primary surfaces,
- 2 primitives,
- 2 state machines,
- 1 navigation model change,
- 1 persistence/model migration,
- 1 external surface family,
- 1 release claim,
- 1 broad visual redesign plus product behavior changes.

## Allowed Multi-Primitive Combinations

- Action Closure + Proof & Receipt Ledger.
- Capture Composer + Placement Resolver.
- Step Detail + Step Session only when routing is stable.
- Recommendation Eligibility + Recommendation Ledger.
- Trust Memory + Evidence Hierarchy.
- Day Shape + Week Shape only inside Plan foundation.
- Legacy language migration + copy guard only when no routing changes.

## Disallowed Combinations

- Reality Rail + Plan Life Suite + Meridian Shell.
- Full UI redesign + UI test modernization + identifier migration.
- Plan Life Suite + external widgets.
- Shell replacement + core loop implementation.
- Dependency overhaul + product feature build.
- Broad refactor + new product behavior.

## Gate Output

Every non-trivial run must state:

- task size,
- owning primitive,
- owning surface,
- allowed files,
- forbidden files,
- validation pack,
- role passes,
- split decision.
