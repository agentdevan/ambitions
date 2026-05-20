<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Active Truth And Authority Repair

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T02-AUTHORITY-REPAIR

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T02-AUTHORITY-REPAIR prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T02-AUTHORITY-REPAIR.md`

## Objective
Make repo authority unambiguous without weakening active truth.

## Active source truth to inspect
Read `docs/truth/*`, `AGENTS.md`, `README.md`, `docs/README.md`, `docs/status/current-implementation-map.md`, and any supporting vision docs in or near `docs/truth/`.

## Allowed scope
Truth front-door caveats, README/docs routing, status authority notes, reset-master authority map/report.

## Forbidden scope
No source, tests, UI, project config, package manifest, release proof claims, or demotion of core truth guardrails.

## Implementation requirements
Route root and docs front doors to truth first, caveat supporting/candidate vision material, preserve local-first/no-cloud-LLM/no-custom-backend guardrails, and label supporting/historical material.

## Visual proof expectations
None.

## Accessibility expectations
None.

## Privacy / trust expectations
Preserve local-first privacy posture and no external personal-data backend claims.

## Continuity expectations
Do not erase historical batch context; subordinate it.

## Validation expectations
Run prompt validators, Codex OS validator, targeted `rg` for active IA/front-door conflicts, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Truth weakened, stale surface names promoted as current IA, or proof overclaims introduced.

## Rollback expectations
Restore touched docs and reset-master reports.

## Expected final report format
Authority hierarchy, files changed, caveats added, validation, Yellow items, non-claims.
