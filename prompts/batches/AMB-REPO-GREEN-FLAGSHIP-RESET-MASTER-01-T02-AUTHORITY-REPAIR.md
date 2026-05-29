<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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
