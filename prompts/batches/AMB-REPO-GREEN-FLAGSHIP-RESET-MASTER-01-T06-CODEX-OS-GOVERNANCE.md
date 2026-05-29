<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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
