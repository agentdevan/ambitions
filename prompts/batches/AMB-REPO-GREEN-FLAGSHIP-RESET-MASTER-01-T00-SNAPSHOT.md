<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Snapshot, Authority Read, And Train Manifest

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T00-SNAPSHOT

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T00-SNAPSHOT prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T00-SNAPSHOT.md`

## Objective
Establish current branch, SHA, worktree, truth-file authority, baseline command output, and the reset-master train manifest without touching app source.

## Active source truth to inspect
Read `docs/truth/README.md`, all files it requires, `AGENTS.md`, `README.md`, `docs/README.md`, `project.yml`, `Package.swift`, and the current audit/proof artifacts named in the master reset prompt. Record absences instead of inventing evidence.

## Allowed scope
`docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01*`, `build/reports/amb-repo-green-flagship-reset-master-01.json`, and validator allowlist changes only when required to validate the prompt-required report path.

## Forbidden scope
No `Native/`, `Sources/`, `AppUI/`, `project.yml`, `Package.swift`, `.xcodeproj`, signing, secrets, hosted CI, external LLM/backend, historical deletion, or release-claim work.

## Implementation requirements
Create or update the train manifest, authority map, validation proof, master audit scaffold, and JSON report. The JSON must not claim zero stale vocabulary hits before the vocabulary ledger runs.

## Visual proof expectations
None. This is docs/tooling only; do not claim visual proof.

## Accessibility expectations
None beyond non-claims; do not claim accessibility proof.

## Privacy / trust expectations
No new network, cloud, analytics, AI, credential, or backend dependency.

## Continuity expectations
Preserve existing batch history and route later trains through this master audit family.

## Validation expectations
Run `git status --short`, branch/SHA commands, baseline scans from the master prompt, prompt validators when present, `python3 -m json.tool build/reports/amb-repo-green-flagship-reset-master-01.json >/tmp/amb-green-reset.json`, Codex OS validator when present, and `git diff --check`.

## Hard Red stop conditions
Source/project mutation, invalid JSON, active truth weakening, false zero-hit vocabulary proof, or release/build/test/accessibility overclaim.

## Rollback expectations
Restore the validator if changed and remove only this train's `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01*` audit/report files.

## Expected final report format
Report Green/Yellow/Red, branch/SHA, files changed, validation results, non-claims, deferred trains, and rollback path.
