# Run-State Standard

Status: Active Codex OS v2 standard
Authority: Process standard, subordinate to `docs/truth/*`

## What It Is

A program run-state file is compact memory for a future Codex session. It records current issue, last completed issue, latest pushed commit, branch, authority read, ownership, gates, evidence, script output, reviewer output, blockers, Yellow limits, Linear status, next dependency, unknowns, and update time.

## What It Is Not

Run-state is not product truth, implementation proof, release proof, Linear truth, or a replacement for current git/source/log inspection.

## Required Schema

```yaml
program:
current_issue:
last_completed_issue:
latest_pushed_commit:
branch:
authority_files_read:
source_ownership:
active_gates:
evidence_index:
script_output_index:
reviewer_output_index:
red_blockers:
yellow_tooling_limits:
linear_update_status:
next_dependency:
stale_or_unknown_fields:
updated_at:
```

## Required Behavior

Update run-state before and after each issue, before compaction, after any push, after Red stops, after accepted Yellow, and when proof ledger entries are added. Include exact commands and artifact paths, but summarize noisy logs. Never store secrets or private personal data.

## Gates

Green: all fields current, evidence paths exist, no hidden Red, no stale pushed hash.
Yellow: honest external proof or Linear limits remain.
Red: missing current issue/gates for active work, stale hash presented as current, hidden app-source changes, or release claims without evidence.

## Repair / Rollback / Linear

Repair by rechecking git, truth files, registry, proof ledger, and script outputs. Roll back only incorrect current-run entries. Linear may read run-state, but must verify git/proof directly before posting.
