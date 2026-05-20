<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Codex OS Governance Baked-In Reset

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T06-CODEX-OS-GOVERNANCE

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T06-CODEX-OS-GOVERNANCE prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T06-CODEX-OS-GOVERNANCE.md`

## Objective
Make Codex governance truth-first, runner-safe, no-cost, and proof-honest.

## Active source truth to inspect
Truth files, `.codex/`, `.agents/`, `docs/codex/`, `codex-os/`, prompts, scripts, Makefile, and existing Codex OS reports.

## Allowed scope
Codex governance docs, runner/header validators, batch ID validators, Codex OS validator, prompts, Makefile targets if needed, reset-master reports.

## Forbidden scope
No app source, UI, product implementation, hosted CI, secrets, external AI/backend dependencies, signing, or release-readiness claims.

## Implementation requirements
Remove stale surface ownership from active governance owner names, mark old prompts historical/supporting, enforce runner/header discipline, quarantine cloud/backend/core LLM assumptions, and repair validators without weakening truth.

## Visual proof expectations
None.

## Accessibility expectations
No accessibility proof claims.

## Privacy / trust expectations
Governance must forbid unapproved cloud/LLM/backend/telemetry/cost-bearing services.

## Continuity expectations
Preserve existing batch history while subordinating stale prompts.

## Validation expectations
Run prompt header validator, batch ID validator, Codex OS validator, `make prompt-audit || true`, `make batch-self-check || true`, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Governance authorizes stale IA, false proof, hosted CI, cloud/core LLM/backend, or app-source edits.

## Rollback expectations
Restore touched governance/docs/scripts/prompts only.

## Expected final report format
Governance repairs, validators, legacy classifications, non-claims, remaining Yellow.
