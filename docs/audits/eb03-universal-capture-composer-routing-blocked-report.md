# EB03 Universal Capture Composer And Routing Blocked Report

Date: 2026-05-03
Batch: EB03 Universal Capture Composer And Routing
Global order: 075
Starting HEAD: 4c19849a
Ending HEAD: pending blocked-report commit in current run
Result: BLOCKED

## Source Truth Read

- `README.md`
- `AGENTS.md`
- `docs/codex/batches/EB03_Universal_Capture_Composer_And_Routing_Prompt.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md`

## Blocker

EB03 is the next eligible batch, but it is not safe to start product Swift from
the current prompt. The prompt allows broad `Native/Ambitions/Features/Captures`
and `Native/Ambitions/Domain` work "when gate opens" but does not name:

- exact owner files
- focused user-visible behavior target
- focused test lane
- preview/fixture evidence expectations for the concrete implementation
- rollback plan
- route/raw value non-change proof
- persistence/schema non-change proof
- accessibility identifier non-change proof

Proceeding directly would risk a broad Capture/Domain implementation pass and
could blur route/raw, persistence, privacy, and accessibility boundaries.

## No Product Change

No EB03 production Swift, app behavior, user-facing behavior, route/raw value,
persistence/schema, dependency, workflow, signing, top-level-tab, production
asset, or public release/accessibility claim change was made.

## Required Repair Path

Split EB03 into scoped stages before implementation:

1. `EB03A Universal Capture Composer Routing Owner Map`
   - Name exact Capture and Domain owner files.
   - Identify existing capture composer/routing seams.
   - Name explicit route/raw/persistence/accessibility identifier non-change
     proof.
   - Name focused tests and preview evidence before any production Swift.
2. `EB03B Universal Capture Composer Routing Implementation`
   - Implement only the named owner files and behavior target.
   - Preserve Capture as singular and keep Today / Goals / Capture / Plan / You.
   - Add or update focused tests and preview fixtures.
3. `EB03C Universal Capture Composer Routing Closeout`
   - Run focused tests, build, EB gates, privacy/claim scans, accessibility
     evidence, Reduce Motion/Dynamic Type evidence if UI changed, and update
     the Yellow owner ledger.

## Validation

Commands run for the stop state:

- `git status --short`: clean before EB03 inspection.
- `scripts/global-train-next-batch.sh || true`: EB03, global order 075.
- `sed -n '1,260p' docs/codex/batches/EB03_Universal_Capture_Composer_And_Routing_Prompt.md`: inspected.
- `git diff --check`: pending for blocked-report commit.

## Red / Yellow Classification

Red remaining: none in committed code.

Blocked condition: EB03 implementation scope is too broad for safe execution
without an owner-map repair stage.

Yellow advisories:

- EB03 remains active planned scope.
- EB03 product implementation is not complete.
- Existing repo-wide docs/copy/markdownlint advisory backlog remains outside
  EB03.

## Next Eligible Batch

EB03 remains next eligible. Exact next recommended path: create `EB03A
Universal Capture Composer Routing Owner Map` before any production Swift.
